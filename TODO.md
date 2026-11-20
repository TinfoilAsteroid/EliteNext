# EliteNext TODO

Moved here from the `DISPLAY "TODO ..."` messages that were printed on every build. Each item links to the file it came from and names the nearest label above where it was. Items are moved to [DONE.md](DONE.md) once done; a follow-up left open stays here as its own item. Reorganised by subject on 2026-11-20, with a suggested order.

## Suggested order

Bugs and checks first, then the tools that decide the optimisation work, then the gameplay loops that make the existing features count (traders using the station, damage, collisions), then new features, the largest last.

1. [Check on CSpect / a Next](#checks-and-tools): confirms several "probably fixed" items at once; low effort.
2. [Lasers](#flight-and-combat): the laser sound lag (a bug), anger the station when hit (small), then per view lasers. (The ShipInSights sign byte bug is fixed.)
3. [Per routine T-state profile](#checks-and-tools): needed before any optimisation item (log divides, ProcessShip).
4. [Verify post hyper space](#jumps): an end to end jump test; the code is done, only the test is missing.
5. [Traders head for the station and dock](#ai-and-spawning): the station and safe zone exist now, so the AI can use them.
6. [Docking and collisions with the station](#flight-and-combat), then [equipment damage](#flight-and-combat) (decide the design first).
7. [The "mass locked" message](#jumps): the first use of the message queue (EnqueMessage has never been called), so test the queue with it.
8. [Spawn tables](#ai-and-spawning), JunkCount / PirateCount, bravery, the jump flash.
9. [Jump drive extras](#jumps), then the [galaxy drive jump](#jumps).
10. [Missile types and equipment names](#missiles-equipment-and-the-commander), [load and save](#missiles-equipment-and-the-commander).
11. [Radar range, line colours, the redocking flicker](#screens-and-display).
12. [Missions](#missiles-equipment-and-the-commander), [solid hulls phase 2](#solid-hulls), [80 column text](#screens-and-display); [input](#input-deferred) waits on the ZPolice keyboard logic.

## Checks and tools

- [ ] Check on CSpect / a Next (things the emulator can't show or judge)
  - Ships no longer vanish or flatten after a while (the rotation matrix drift, fixed by TidyOrientation); a long flight with ships about.
  - The station: never destroyed, the docking angle test, bouncing off it (see "Docking and collisions with the station").
  - The sound effects: tune them by ear, and the noise channel (explosions are tone only as InitAudio's mixer has noise off). (Was its own item, from "Sound FXs".)
  - The system map's text and layout (the emulator has no ROM font), and the station 160 behind us in the rear view after launch (StationLaunchMargin).
  - The safe zone indicator, the menus' text, the solid planet.
- [ ] Per routine T-state profile in the emulator (replaces "Optimisation")
  - In Tools/nexsim.py: while running, add each instruction's T-states to the label containing PC (from eliteN.sym, nearest label below, per bank), over a few hundred main loop frames in flight with ships about; a tool (Tools/profile.py) printing the top routines by T-states per frame and their share of the 560,000 T a 50 Hz frame has at 28 MHz, and call counts. Then optimise only what it shows matters (candidates so far: projection and clipping divides, the planet fill, the dot products).
- [ ] Log divide maths
  - Partly done: the log / antilog routines (Maths/logmaths.asm) are used by ScaleXX16Matrix197, NormaliseTransMat and the node scaling (AEquAmul256DivBLog). Projection (RequAmul256divQ in univ_ship_data.asm) and clipping (AEquAmul256DivD in CLIP-LL145.asm) use the shift and subtract divides.
  - Suggested: measure first (see the per routine T-state profile item); move a divide to logs only where it's hot and the log version's error (about 1 part in 64) is acceptable. Clipping needs exact end points, so probably not there.
- [ ] NormalizeTactics is up to 3 of 96 low on small components (7 bit scale, the divide's halving for lengths of 128 or more, its 3/8 step); more precision if missiles need it ([Maths/normalise96.asm](Maths/normalise96.asm), `NormalizeTactics`): left open, the missile tests pass so not needed yet

## Flight and combat

- [ ] Sound enqueuing for lasers seems to cause a lag of several seconds, then the shots play very rapidly.
  - Where to look: PlaySFX SFXLaser on each pulse (Macros/MathsMacros.asm sets SoundFxPending[id]) and the sound interrupt that starts pending effects on free channels and plays a step a frame (Hardware/sound.asm). Tools/test_sound.py covers the effects on nexsim's AY registers; a test firing the laser for a few seconds and timing when each pulse's sound starts would show the lag.
- [ ] Improve laser code
  - The timing was reworked (frame timed pulses and beams, Tools/test_laser.py). Remaining: ShipInSights (eliteNext.asm) checks the x / y hi bytes but not the integer bits in the sign bytes, so a ship 65536 or more off to the side could count as in the sights; only the front laser is handled (LaserDamagedFlag has 4 entries: front, rear, left, right); hitting the space station does no damage (right) but doesn't make it hostile.
  - Suggested: add the sign bytes to ShipInSights' test; per view lasers (rear / left / right views using their own laser stats with the ship position mirrored into that view); anger the station when hit; the laser sound is done (see Sound FXs in [DONE.md](DONE.md)).
  - Done (2026-11-20): ShipInSights now also checks the sign bytes' integer bits, so a ship 65536 or more to the side or above is not in the sights. Tools/test_laser.py test_ship_in_sights_sign_bytes (fails on the old code). Still to do: per view lasers and angering the station.
- [ ] Docking and collisions with the station ([eliteNext.asm](eliteNext.asm), GetStationVectorToWork; [GameEngine/UpdateUniverseObjects.asm](GameEngine/UpdateUniverseObjects.asm) .CollisionCheck)
  - Bouncing off the station is wrong: hitting it outside the docking angle should push us back and damage us.
  - Collision damage to both ships proportional to speed (DamageShip is called on a collision; "dent target too, make damage proportional to speed").
  - (was: Docking works but bouncing off is wrong for space station ([eliteNext.asm](eliteNext.asm), `GetStationVectorToWork`))
- [ ] Add in damage status displays
  - The damage variables exist (Variables/EquipmentVariables.asm: LaserDamagedFlag, ECMDamageStatus ... WarpDriveDamageStatus) but nothing sets them and no screen shows them.
  - Suggested: two parts: (1) damage equipment when the shields are down and the ship is hit (BBC: a random item is lost; the comments here plan a 0 to 255 damage level), (2) show it on the status or inventory screen, coloured by level. (1) needs deciding first.
  - TODO, how equipment damage should work (to decide before coding):
    - When: only when a hit gets through the shields (ApplyDamage's overflow onto PlayerEnergy, GameEngine/DamagePlayer.asm), as BBC Elite, or a chance on any hit.
    - What: BBC Elite loses one random fitted item outright (often cargo); the variables here (Variables/EquipmentVariables.asm) plan a 0 (good) to 255 (destroyed) level per item, each with its own effect: lasers a chance not to fire (LaserDamagedFlag, 4 mounts), ECM / energy bomb / docking computer / galactic drive a chance to fail, escape pod lost at 255, fuel scoop slower, cargo hold a chance to lose an item, warp drive random mass lock.
    - How much: damage proportional to the overflow, spread over one random item or several.
    - Repair: at a station (a cost per point on the equipment screen), or only by buying the item again.
    - Display: the status or inventory screen, each item coloured by level (green / yellow / red), and a console warning when something is destroyed.
    - Save: the levels in the commander save.

## AI and spawning

- [ ] Traders and other non hostile ships head for the station and dock, or for the sun and jump out ([GameEngine/NormalAI.asm](GameEngine/NormalAI.asm), ShipHeadingToUnivBody, UpdatePlanetTracking, UpdateSunTracking)
  - Now they steer for the planet (UnivSteerToBody) and stop at its safe zone; the station is what they should head for, then a docking phase (line up with the slot, fly in, leave the slot list), and a random direction where needed. At the sun they jump out (UnivMoveToJump).
  - (was: Change this from move to planet to move to station as moving to planet is now superfluous ([GameEngine/NormalAI.asm](GameEngine/NormalAI.asm), `ShipHeadingToUnivBody`))
  - (was: Sort out targeting station not planet ([GameEngine/NormalAI.asm](GameEngine/NormalAI.asm), `UpdatePlanetTracking`))
  - (was: Add in transitiion to docking phase ([GameEngine/NormalAI.asm](GameEngine/NormalAI.asm), `UpdatePlanetTracking`))
  - (was: Sort out random directio etc if needed ([GameEngine/NormalAI.asm](GameEngine/NormalAI.asm), `UpdatePlanetTracking`))
  - (was: Sort out docking ([GameEngine/NormalAI.asm](GameEngine/NormalAI.asm), `UpdateSunTracking`))
- [ ] Add flash of light jump logic into ships. similar to explosion but just a star of random lines and no kill score ([GameEngine/NormalAI.asm](GameEngine/NormalAI.asm), `UnivMoveToJump`)
- [ ] Spawn tables by rank, galaxy and the commander ([GameEngine/SpawnObject.asm](GameEngine/SpawnObject.asm), SelectSpawnTableData)
  - Only the 'A' tables are used (Tables/ShipClassTable.asm has B and C hunter / pirate tables); choose by the commander's rank, the galaxy, the cargo's value and FIST, as the comments in the spawn handlers plan.
  - (was: SelectSpawnTableData needs algorithim for selecting the spawn rank table based on commander, galaxy etc ([GameEngine/SpawnObject.asm](GameEngine/SpawnObject.asm), `SpawnTrader`))
  - (was: SelectSpawnTableData for now only does basic 'A' table selection ([GameEngine/SpawnObject.asm](GameEngine/SpawnObject.asm), `SpawnTrader`))
- [ ] JunkCount and PirateCount only go up: nothing lowers them when junk or a pirate is destroyed or taken away; only a jump (ProcessWarp) and ClearJunk reset them. Once the junk handler is used, junk would stop spawning after 5 until a jump (from "Fix the latent spawn defects", see DONE.md)
- [ ] Add bravery based on rank, new bits and type of ship ([Variables/constant_equates.asm](Variables/constant_equates.asm))

## Jumps

- [ ] Verify post hyper space: an end to end jump test
  - WeHaveCompletedHJump (GameEngine/MainLoop.asm) seeds the system, generates the market, clears the slots, resets the player ship and makes the sun and planet, but no space station is ever created afterwards: that waits on the safe zone, which wasn't implemented (see the safe boundary item in [DONE.md](DONE.md)). The commented out generateSunAndPlanetPos / CopyBodyToUniverse lines are leftovers.
  - Suggested: after the safe zone work, an emulator test that runs a jump to the end (DockedFlag through StateHJumping, StateHEntering, StateCompletedHJump) and checks the present system, fuel, an empty slot list, the sun and planet positions from the seeds, the front view, and the station appearing on flying into the safe zone. Remove the dead commented lines.
  - Done (2026-11-19): the station now appears on reaching the planet's safe zone (see the safe boundary item in [DONE.md](DONE.md)). Still to do: the end to end jump test and removing the dead commented lines.
- [ ] A "mass locked" message through the message queue when the jump drive is mass locked (ProcessWarp .MassLocked; from "Jump stop bong noise", see DONE.md)
- [ ] In system jump drive extras ([GameEngine/ProcessWarp.asm](GameEngine/ProcessWarp.asm), ProcessWarp)
  - A malfunction (random mass lock or misjump, with equipment damage).
  - Flash the jump drive status icon while hot / mass locked.
  - (was: Need logic for in system jump drive malfunction ([GameEngine/ProcessWarp.asm](GameEngine/ProcessWarp.asm), `ProcessWarp`))
  - (was: Flash jump drive status icon ([GameEngine/ProcessWarp.asm](GameEngine/ProcessWarp.asm), `ProcessWarp`))
- [ ] Galaxy drive jump
  - Not implemented. GalacticHyperDrive (equipment), its damage status and NextGalaxyNamingSeed (one twist of the seeds, Universe/Galaxy/galaxy_data.asm) exist; no key, countdown or jump uses them.
  - Suggested: a key (BBC Elite: CTRL-H) that, with the drive fitted, starts the same countdown and then: Galaxy = (Galaxy + 1) & 7, rotate the galaxy seeds (each seed byte rotated left once, as BBC Ghy), use up the drive, and land at the system nearest the galaxy's centre (96, 96) as BBC Elite does; reuse WeHaveCompletedHJump for the arrival.

## Missiles, equipment and the commander

- [ ] Different missile types and the equipment names
  - There's one type (ShipMissileTable = ShipID_Missile, the "For now only 1 missile type" TODOs). Note: MAINLOOP_LAUNCHMISSILE is commented out at the top of MainLoop.asm, so the player can't launch missiles in the current build.
  - Suggested: first decide whether that define being off is deliberate. Then a missile type table (model, speed, turn rates RAT / RAT2 / CNT2, blast range and damage, lifespan), chosen per launch (player: a key or the equipment; enemies: from their blueprint), with UnivSetPlayerMissile / UnivSetEnemyMissile taking their settings from it instead of constants.
  - Done (2026-11-19): MAINLOOP_LAUNCHMISSILE is back on. IsMissileLockedOn returned its answer in carry but the front view tested the zero flag, so firing with no lock launched at slot 14 / 15, and a lock checked slot 0 rather than its target: fixed (carry set only for $80 | slot on an occupied slot). Tools/test_missile.py test_player_missile_launch. The types themselves are still to do.
  - Equipment names: build the names from the item and its facing so only one laser name per type is needed ([Tables/EquipmentTables.asm](Tables/EquipmentTables.asm)); the missile type in the equipment as well as the count, and in the commander save.
  - (was: FOR NOW ONLY 1 MISSILE TYPE ([GameEngine/MainLoop.asm](GameEngine/MainLoop.asm), `LaunchPlayerMissile`))
  - (was: FOR NOW ONLY 1 MISSILE TYPE ([GameEngine/SpawnObject.asm](GameEngine/SpawnObject.asm), `SpawnMissileHandler`))
  - (was: This coudl actually be used to dynamically build names of componets based on ship build ([Tables/EquipmentTables.asm](Tables/EquipmentTables.asm)))
  - (was: Then we only need 1 laser for each facing and build the name ([Tables/EquipmentTables.asm](Tables/EquipmentTables.asm)))
  - (was: Need to redo missiles as we need type in equipment as well as count, chagne save game to handle this ([Tables/EquipmentTables.asm](Tables/EquipmentTables.asm), `EquipNameIndex`))
- [ ] Load and save commander logic (FileSave / FileLoad need the ROM paged into slots 0 and 1, MMUSelectROMS, for rst $08: the start up has it, a menu calling them must too)
  - At start up the default commander is made and saved as Default.SAV. "Load Commander (Y/N)": Y skips defaultCommander but nothing loads (SkipDefaultCommander only has comments), and the default was set up before the question anyway, so Y and N do the same. loadCommander is never called and there's no in game save.
  - Suggested: Y calls loadCommander (with MMUSelectROMS, a file name prompt or a fixed name to start with, and the default on any error: FileLoad now returns errors cleanly); a save option on the status screen while docked, as BBC Elite's disc menu. Tools/test_commander_file.py covers the file round trip; add a test for the menu path.
  - Done (2026-11-19): Load Commander Y now loads Default.SAV (MMUSelectROMS, loadCommander), keeping the default commander if that fails (FileLoad sets carry on every error now; a handle of 0 came back with carry clear). Tools/test_commander_file.py test_load_commander_keeps_on_error. Still to do: a file name / browser, and an in game save.
- [ ] Mission coding
  - Only hooks exist: HandleMissionLogic (MainLoop.asm, a self modifying call into a mission bank, never set) and SpawnTypeMissionHandler / SpawnTypeMissionEventHandler (just ret).
  - Suggested: design first (which missions: BBC's Constrictor and Thargoid plans?), then a mission state byte in the commander save, triggers on docking / jumping (BBC checks on docking) and the mission bank routine called from HandleMissionLogic.
  - TODO, mission building:
    - Decide the missions (BBC Elite's: the Constrictor hunt, galaxy 1 after 256 kills; the Thargoid documents and the Thargoid base, galaxy 2), and how they are told (briefing screens).
    - A mission state byte in the commander save (copyCommanderToSave / FromSave), as BBC TP.
    - Triggers: checked on docking (BBC: MainLoop after docking checks kills, galaxy and TP) and on jumping, setting the mission bank for HandleMissionLogic (MainLoop.asm, a self modifying call, never set now).
    - Mission spawns through SpawnTypeMissionHandler / SpawnTypeMissionEventHandler (both just ret), the mission ship's blueprint, and the rewards (cash, equipment, rating).
    - Tests: an emulator test per trigger (dock with the conditions met, check the briefing screen and the state byte).
  - The mission bank: MMUSelectMissionBankA for HandleMissionLogic (MainLoop.asm, a self modifying call, never set).
  - (was: Add MMUSelectMissionBankA ([GameEngine/MainLoop.asm](GameEngine/MainLoop.asm), `HandleMissionLogic`))

## Screens and display

- [ ] After docking the screen is not properly tidied: large yellow sections are left on screen as the background to the game menus. It may be that one of the layers is not correctly reset.
  - Related: the "Redocking" item below. Its emulator check (2026-11-20) found Layer 1 and Layer 2 matching a freshly drawn status screen after the tunnel, so the yellow may come from something that check didn't compare: a palette (Layer 2's or the ULA's), the global transparency colour, the layer order or clip windows (NextRegs $14, $15, $18 / $1A), or a later menu than the status screen.
- [ ] Redocking: the space station disappears, showing just the dust field for a few frames; the tunnel effect then runs but doesn't fully clear before the menu is shown. Check that the menu draw clears both Layer 1 and Layer 2.
  - The path (2026-11-20): UpdateUniverseObjects (.WeAreDocking) forces ScreenDocking. draw_docking_ship clears Layer 1 (l1_cls, l1_attr_cls) and the sprites, sets Layer 2 to 256 x 192 double buffered and paints both buffers (upper two thirds white, the tube edges, the console). loop_docking_ship draws one tunnel box a main loop, the main loop flipping buffers after each (the screen's double buffer flag), and when its table ends it forces ScreenStatus. draw_status_menu then: l1_cls and attributes to 7; asm_l2_double_buffer_off, l2_320_initialise, l2_320_cls; sprites cleared; the border and text.
  - Checked in the emulator: the tunnel run to its end (25 loops, flipping as the main loop does) and then the status screen leaves Layer 1 and Layer 2 as a status screen drawn straight from start up (Layer 1 the same, Layer 2 within 64 bytes, all text). So both layers are cleared in the end, nothing left over.
  - What is likely seen: the order. draw_status_menu switches the display to 320 x 256 (l2_320_initialise) before clearing it: for the 0.3 of a frame l2_320_cls takes, the screen shows whatever the 320 pages held (the tunnel's or an older menu's bytes, read column major). The menu then builds up in view over about 2.5 frames (the text is most of it), single buffered. draw_docking_ship has the same order (l2_initialise to 256 x 192, then the paint).
  - The station vanishing before the tunnel is separate and still to look at: probably the near clipping as we fly into the slot (CheckVisible's close range, or under SOLID_HULL a vertex behind the camera making it wireframe, its lines clipped away), until the docking check fires.
  - Suggested: clear the 320 pages (l2_320_cls) before l2_320_initialise switches to them, or hide Layer 2 (NextReg $69 bit 7, or the clip window) from the mode switch until the menu is drawn, then show it; the same in draw_docking_ship and the other menu draws (a shared "blank, draw, show" wrapper in SetScreenA would cover every screen). An emulator test: dock (station placed in the slot, the docking check passing), record each frame's shown Layer 2 and Layer 1 through the tunnel to the status screen, and check no frame shows a mix of the old and new screens.
- [ ] Switch radar range functionality
  - Not implemented: the scanner has one scale (Shift24BitScan in Views/ConsoleDrawing.asm, the hi byte and the top 3 bits of the lo byte; things whose sign bytes have integer bits are off the scanner and shown by the RadarEdge dots).
  - Suggested: a range variable (e.g. x1, x2, x4) changed by a key, applied as an extra shift in Shift24BitScan and the in range test, and shown on the console. Needs a key assigned.
  - TODO, radar range key: a key to cycle the scanner range (e.g. x1, x2, x4), to be assigned with the ZPolice keyboard logic and key pages; then a range variable applied as an extra shift in Shift24BitScan and its in range test (Views/ConsoleDrawing.asm), shown on the console.
- [ ] Line drawing colour improvement
  - Every ship is drawn in $BF: DrawLinesLateClipping sets line_gfx_colour itself, so ProcessShip's `ld a,$E3` just before is dead (and $E3 is the transparent colour).
  - Suggested: a colour per ship from its blueprint (a spare byte, or a table by ship type), and maybe dimmer with distance (z hi into a palette ramp); remove the dead store.
- [ ] Chars and displays into 80 column mode
  - Text is Layer 1 (the ULA screen, 32 columns) for the console and messages, and l2_print_at_320 on the 320 x 256 menus. No tilemap code exists (only the register defines).
  - Suggested: a large change, so decide the goal first. The Next's 80 x 32 tilemap could replace the Layer 1 text with a font loaded once; it needs its own memory (tilemap and patterns in bank 5 or 7), a print routine, and every l1_print_at caller moved over. Could start with the menus only.
  - TODO, scope (for deciding before any work):
    - What: the Next's tilemap layer in 80 x 32 mode (8 x 8 characters on a 640 x 256 grid) for text, in place of Layer 1 (the ULA screen, 32 columns) and l2_print_at_320 on the menus.
    - Needs: 4K of tilemap (80 x 32 x 2 bytes with attributes, or 2.5K without) and the font's patterns (up to 8K for 256 characters) in bank 5 or 7 where the tilemap must live, which is where Layer 1's screen is now; NextRegs $6B / $6C / $6E / $6F and the clip window $1B; the font loaded once (from the ROM or a file).
    - Code: a print routine (character, string, at row / column, with colour from the attribute byte), clear line / clear screen, and every caller moved over: the console text and messages (l1_print_at, the hyperspace countdown, the message queue), the menus (status, market, equipment, inventory, system data, the charts' labels) and the attract screen.
    - Interactions: the tilemap over or under Layer 2 and the sprites (NextReg $15 layer order), transparency, and the console graphics now drawn on Layer 1.
    - Suggested order: the menus first (most text, least timing), then the console, then remove Layer 1 text. Probably a few days of work; it changes most screens.

## Input (deferred)

What the joystick and the extended keys do is to be defined with the ZPolice keyboard logic and redefinable key pages.

- [ ] Test joystick
  - There's no joystick code: nothing reads port $1F (Kempston) or the NextReg $05 joystick modes.
  - Suggested: read the Kempston port in scan_keyboard and OR its bits into the matching key states (up / down / left / right / fire to the flight controls), then an emulator test (nexsim would need the port modelled).
  - Deferred (2026-11-19): what the joystick does is to be defined with the ZPolice keyboard logic and redefinable key pages.
- [ ] Test exetended keys
  - The extended keys (NextReg $B0 / $B1) are scanned into Keys and Tools/test_keys.py covers every control, the extended ones too, but nothing in the game acts on any c_Pressed_Ext control (ExtMarket, ExtCurUp, ExtSystemJump etc. are only mapped). (EDIT now opens the system map, see DONE.md)
  - Suggested: decide which extended keys do what (e.g. the cursor keys for the chart cursors and steering, EXTEND for the in system jump as its name says) and wire them in; test_keys already checks the scanning.
  - Deferred (2026-11-19): what the extended keys do is to be defined with the ZPolice keyboard logic and redefinable key pages.

## Solid hulls

- [ ] Optimise for solid fill
  - Proposal for solid ships (SOLID_HULL, which replaces SOLIDHULLTEST): [Documentation/SolidHulls.md](Documentation/SolidHulls.md), for review. It covers face polygons rebuilt offline from the edges by a tool, a convex polygon filler, the drawing order and the steps, with the decisions needed.
  - Planets are solid (PLANETSARESOLID: l2_draw_clipped_circle_filled, one l2_draw_horz_line a row, which uses the DMA for spans of 10 or more). Solid ships aren't built (SOLIDHULLTEST; the triangle fill code is in Unused).
  - Suggested: N/A for ships unless solid ships are wanted. For the planet the spans are already DMA; on REAL_HARDWARE the DMA+ 2D fill could do it with less set up, worth it only if the profile shows the planet fill matters.
  - Done (2026-11-20): steps 1 to 4 of the proposal, behind SOLID_HULL (off by default). See the status at the top of Documentation/SolidHulls.md. Tools/test_solid_hull.py builds SOLID_HULL and draws every model through ProcessShip. It found that a flat polygon (one row high) drew nothing, so a small or edge-on ship vanished; l2_fill_convex_polygon now fills that row. Still to do: step 5 (colours, shading, DMA+, tuning) and the proposal's open decisions (13 models with faces that don't close are still wireframe).
  - Decisions (2026-11-20): convex polygons; the models whose faces don't close are review items (Solid hulls, under Rendering and graphics); `SOLID_OUTLINES ALL` / `DECORATION` / not defined; ordering explained in the proposal's decision 4 (faces sorted for every model, the sort costs about 1%; ships already sorted furthest first, SortShipsFurthestFirst, now tested); colours later; `WIREFRAME_FALLBACK` with `WIREFRAME_DISTANCE` (256/10, 0.1) to tune on hardware.
  - [ ] Put the planet and sun in the furthest first draw order with the ships (they're drawn before every ship, so a ship behind the planet is drawn over it).

### Phase 2 polygons (ports)

- [ ] Flag which ports are engines, to draw in the ship's engine colour, or a thrust colour while the ship is manoeuvring (accelerating / turning). The port type is in the table now (PortEngine); still to do: the thrust colour and when to use it.
- [ ] More models' ports. Closed decoration loops the tool would make ports from (model: face, loops and their sides): Adder 0: 1 (4); Asp Mk 2 11: 1 (4); Bushmaster 8: 1 (4); Chameleon 12: 1 (4); Constrictor 9: 2 (3/3); Cougar 5: 1 (4); Fer De Lance 0: 2 (3/3), 9: 1 (3); Ghavial 0: 1 (3); Krait 4, 5: 1 each (3); Mamba 0: 2 (3/3), 1: 1 (4), 4: 3 (3/3/4); Moray 4: 1 (3); Ophidian 11: 1 (4); Rattler 12: 2 (3/3); Shuttle Type 9 9: 1 (4), 10, 11: 1 each (3); Shuttle Mk 2 12: 1 (4); Sidewinder 3: 1 (4); Transport Type 10 0: 1 (4), 6: 1 (3); Viper 6: 2 (3/3). Each needs a look: which are engines, entrances, view ports or just markings (some may be better as lines), and the filler takes convex polygons of up to 8 points only (the Logo's loop has 12 sides). Models still wireframe (Adder, Asp, Cougar, Krait, Ophidian) need their faces fixed first.
- [ ] View ports (cockpit windows) on ships that have them, as ports, when the models are reviewed.

### Models whose faces don't close (for review)

These 11 models (8 now: the Missile and the two Cobra Mk 3s are done) stay wireframe under SOLID_HULL: Tools/ship_faces.py can't chain at least one face's edges into a closed loop. (Decoration edges, whose two faces are the same, are already left out.) Vertex numbers below are vertex indices (the edges store them x4). An open end is a vertex on only one of the face's edges; a branch is a vertex on three or more. Each suggestion was tried in a scratch script, not yet in the tool.

Checked (2026-11-20) for single lines: four models fail only because of a single line out of the nose, the sensor / gun port. It's an edge on its own, touching no other edge, labelled with the two faces it sits between: Asp Mk 2 (17-18), Cobra Mk 1 (9-10), Cobra Mk 3 and Cobra Mk 3 P (20-21). These should be drawn as lines, never as part of a face. **Fix C:** the tool leaves any edge touching no other edge out of the faces and lists it as a line, and SolidHullDraw draws those lines over the fill whatever SOLID_OUTLINES is. (With `DECORATION` they'd vanish otherwise, as their two faces differ; with no SOLID_OUTLINES, always.) That alone makes these four models solid. The header's gun vertex is the line's front end for the Cobras (21, 21, 10). The Asp's is 8, which isn't on its nose line: check the Asp's gun vertex. No other model has a lone line at its gun vertex. The other stray edges below are spurs joined to the hull (prongs, fins), not lone lines.

Two more general fixes would cover most of the rest:
- **A. Prune.** Drop a face's edges that hang off its loop or stand apart from it. These are guns, fins and prongs labelled with the faces they sit on. This closes every face of 8 models: the 4 with nose lines (where C is the narrower fix) and Iguana, Krait, Missile and Ophidian. The dropped edges would then not be filled: they'd still be drawn with `SOLID_OUTLINES ALL`, but not with `DECORATION`, which only draws edges whose two faces are the same. So the tool could also list them for the decoration lines.
- **B. Close.** Where a face has exactly two open ends, add the missing edge between them (the BBC model left it out, probably because the faces either side are nearly flat to each other).
- [ ] Adder: faces 6, 7 and 8, a strip of three faces with only 2 edges each. Face 6: (3, 4), (3, 9), open ends 4 and 9. Face 7: (4, 5), (9, 8), open ends 4, 5, 8 and 9. Face 8: (5, 6), (8, 6), open ends 5 and 8. Fix B closes 6 (3-4-9) and 8 (5-6-8). Face 7 needs both edges, 4-9 and 5-8, to make 4-5-8-9. Suggested: a hand fix, or B plus pairing the open ends by the edges added to the faces either side.
- [ ] Asp Mk 2: faces 0 and 4 each have a loop, plus the nose line 17-18 (x 0, z 73 to 83), a lone line, on both. Fix C: face 0 = 0, 4, 8, 9, 7; face 4 = 8, 9, 11, 10, and the nose line drawn as a line. The header's gun vertex is 8, not on the nose line: check it.
- [ ] Cobra Mk 1: faces 0 and 1 have a loop plus the nose line 9-10 (x 0, z 50 to 60, the gun vertex 10), a lone line. Fix C: face 0 = 1, 0, 8; face 1 = 1, 0, 6, 7, and the nose line drawn as a line.
- [ ] Cougar: faces 0, 1, 3 and 4 have no open ends but two branch vertices each, so two loops share an edge. Face 0 is the quad 0-1-2-3 and the quad 1-7-8-2, sharing 1-2. Face 1 is the triangle 1-2-4 and the same 1-7-8-2. Faces 3 and 4 are the same on the other side: face 3 is the triangle 4-5-6 and face 4 the quad 0-3-6-5, each with the quad 5-6-10-9, sharing 5-6. The shared quad looks like a fin or panel standing on the face, labelled with both faces. Neither A nor B fixes it. Needs a look at the model: take each face's own loop (0-1-2-3, 1-2-4, ...) and the panel as separate polygons, or the outer boundary.
- [ ] Iguana: faces 0 to 3 are triangles, each with a spur from a corner: (2, 9) on faces 0 and 1, (4, 10) on faces 2 and 3. Fix A: 0-1-2, 0-2-3, 0-1-4, 0-3-4.
- [ ] Krait: faces 0 to 3 are triangles, each with a spur (the prongs): (3, 5) on faces 0 and 1, (4, 6) on faces 2 and 3. Fix A: 0-1-3, 0-2-3, 0-2-4, 0-1-4. The prongs then aren't filled, and with `SOLID_OUTLINES DECORATION` they'd vanish unless they're added to the decoration lines.
- [ ] Logo: faces 0 to 2 (lettering). Fix A closes face 0 (14-15-16-17); face 1 (5 edges, open ends 4, 8, 12 and 16) and face 2 (one edge, 13-16) can't close. Suggested: leave the Logo wireframe.
- [ ] Ophidian: faces 3, 4, 9 and 10 each have a loop plus a 2 edge spur: 11-12-13 on faces 3 and 9, 8-9-10 on faces 4 and 10. Fix A: face 3 = 4, 5, 6, 11; face 4 = 3, 5, 7, 8; face 9 = 4, 11, 14, 15; face 10 = 3, 8, 14, 15.
