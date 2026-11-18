# EliteNext TODO

Moved here from the `DISPLAY "TODO ..."` messages that were printed on every build. Each item links to the file it came from and names the nearest label above where it was.

## Master list

(Was the MASTER TODO LIST at the top of eliteNext.asm.)

- [ ] Optimisation
- [ ] Review spawn logic for crash
- [ ] Add space station safe boundary indicator
- [ ] Optimise apply my to planets and sun to consider if 24 bit can be doen using 16 bit if sgn is just a sign bit
- [ ] Verify post hyper space
- [ ] Why no count down text sometimes
- [ ] Galaxy drive jump
- [ ] Different missile types
- [ ] Log divide maths
- [ ] Optimise for solid fill
- [ ] Load and save commander logic (FileSave / FileLoad need the ROM paged into slots 0 and 1, MMUSelectROMS, for rst $08: the start up has it, a menu calling them must too)
- [ ] Chars and displays into 80 column mode
- [ ] Mission coding
- [ ] Improve laser code
- [ ] Improve chart cursor code
- [ ] Test joystick
- [ ] Test exetended keys
- [ ] Line drawing colour improvement
- [ ] Remove meridian code
- [ ] Sound FXs
- [ ] Jump stop bong noise
- [ ] Switch radar range functionality
- [ ] Add in damage status displays
- [ ] Bug random dissapearance of ship in front view after time
- [ ] Bug random flattening of ship in front view after time
- [ ] Bug random exploising of station in front view after time, seems to affect short distance out
- [ ] System map, showing planet, sun, space station and ship position, flat map compress Z, perhaps a +/- height value, say +/- character for every + 40 on z sign?

## Game engine

- [ ] Add MMUSelectMissionBankA ([GameEngine/MainLoop.asm](GameEngine/MainLoop.asm), `HandleMissionLogic`)
- [ ] Check callers as they may be doign this as a duplicate ([GameEngine/MainLoop.asm](GameEngine/MainLoop.asm), `InitialiseLocalUniverse`)
- [ ] GENEATE SUB AND PLANET POS ([GameEngine/MainLoop.asm](GameEngine/MainLoop.asm), `WeHaveCompletedHJump`)
- [ ] Disabled spawing for diagnostics ([GameEngine/MainLoop.asm](GameEngine/MainLoop.asm), `SpawnEvent`)
- [ ] Optimise spawn so it saves off spawn data where there are more than one to do ([GameEngine/MainLoop.asm](GameEngine/MainLoop.asm), `SpawnEvent`)
- [ ] Optimise spawn and counts down in loop to avoid a stall where it spawns 3 ships on one game cycle ([GameEngine/MainLoop.asm](GameEngine/MainLoop.asm), `SpawnEvent`)
- [ ] Check spawn code as some refers to HL address, a refers to ship number but its not a ship number e.g. in test it was E1 ([GameEngine/MainLoop.asm](GameEngine/MainLoop.asm), `SpawnEvent`)
- [ ] FOR NOW ONLY 1 MISSILE TYPE ([GameEngine/MainLoop.asm](GameEngine/MainLoop.asm), `LaunchPlayerMissile`)
- [ ] Handle removal of missile from inventory and console ([GameEngine/MainLoop.asm](GameEngine/MainLoop.asm), `LaunchPlayerMissile`)
- [ ] Change this from move to planet to move to station as moving to planet is now superfluous ([GameEngine/NormalAI.asm](GameEngine/NormalAI.asm), `ShipHeadingToUnivBody`)
- [ ] Sort out targeting station not planet ([GameEngine/NormalAI.asm](GameEngine/NormalAI.asm), `UpdatePlanetTracking`)
- [ ] Add in transitiion to docking phase ([GameEngine/NormalAI.asm](GameEngine/NormalAI.asm), `UpdatePlanetTracking`)
- [ ] Sort out random directio etc if needed ([GameEngine/NormalAI.asm](GameEngine/NormalAI.asm), `UpdatePlanetTracking`)
- [ ] Sort out docking ([GameEngine/NormalAI.asm](GameEngine/NormalAI.asm), `UpdateSunTracking`)
- [ ] Add flash of light jump logic into ships. similar to explosion but just a star of random lines and no kill score ([GameEngine/NormalAI.asm](GameEngine/NormalAI.asm), `UnivMoveToJump`)
- [ ] Need logic for in system jump drive malfunction ([GameEngine/ProcessWarp.asm](GameEngine/ProcessWarp.asm), `ProcessWarp`)
- [ ] Call bong jump drive hot ([GameEngine/ProcessWarp.asm](GameEngine/ProcessWarp.asm), `ProcessWarp`)
- [ ] Flash jump drive status icon ([GameEngine/ProcessWarp.asm](GameEngine/ProcessWarp.asm), `ProcessWarp`)
- [ ] FOR NOW ONLY 1 MISSILE TYPE ([GameEngine/SpawnObject.asm](GameEngine/SpawnObject.asm), `SpawnMissileHandler`)
- [ ] Handle removal of missile from inventory and console ([GameEngine/SpawnObject.asm](GameEngine/SpawnObject.asm), `SpawnPlayerMissileHandler`)
- [ ] SPAWN TRADER ([GameEngine/SpawnObject.asm](GameEngine/SpawnObject.asm), `SpawnHostileCop`)
- [ ] SelectSpawnTableData needs algorithim for selecting the spawn rank table based on commander, galaxy etc ([GameEngine/SpawnObject.asm](GameEngine/SpawnObject.asm), `SpawnTrader`)
- [ ] SelectSpawnTableData for now only does basic 'A' table selection ([GameEngine/SpawnObject.asm](GameEngine/SpawnObject.asm), `SpawnTrader`)
- [ ] Check if these two are the wrogn way round and init runtime is wiping spawn ([GameEngine/SpawnShipTypeA.asm](GameEngine/SpawnShipTypeA.asm), `SpawnSpaceStation`)
- [ ] Capture duff jumps ([GameEngine/Tactics.asm](GameEngine/Tactics.asm), `UpdateShip`)
- [ ] Remove all this as its moved to maths banked fns ([GameEngine/Tactics.asm](GameEngine/Tactics.asm), `DebugTacticsCopy`)
- [ ] TactivtsPosMinus Target ([GameEngine/Tactics.asm](GameEngine/Tactics.asm), `CalcTargetVector`)
- [ ] FIX TIDY Make all 4 of these 1 call ([GameEngine/UpdateUniverseObjects.asm](GameEngine/UpdateUniverseObjects.asm), `UpdateUniverseObjects`)
- [ ] Det target too ([GameEngine/UpdateUniverseObjects.asm](GameEngine/UpdateUniverseObjects.asm), `UpdateUniverseObjects`)
- [ ] Tune this ([GameEngine/UpdateUniverseObjects.asm](GameEngine/UpdateUniverseObjects.asm), `DrawForwardShips`)
- [ ] Add all ships back to radar ([GameEngine/UpdateUniverseObjects.asm](GameEngine/UpdateUniverseObjects.asm), `DrawForwardShips`)
- [ ] Change update to only run with ConsoleRedrawFlag ([GameEngine/UpdateUniverseObjects.asm](GameEngine/UpdateUniverseObjects.asm), `DrawForwardShips`)
- [ ] Call Reset ([GameEngine/UpdateUniverseObjects.asm](GameEngine/UpdateUniverseObjects.asm), `SetInitialShipPosition`)
- [ ] Add bravery based on rank, new bits and type of ship ([Variables/constant_equates.asm](Variables/constant_equates.asm))
- [ ] UPDATE RUNNING TOTAL FOR CARGO ([Variables/general_variablesRoutines.asm](Variables/general_variablesRoutines.asm), `AddCargoTypeD`)
- [ ] Check collision detection as currently can destroy space station ([eliteNext.asm](eliteNext.asm), `GetStationVectorToWork`)
- [ ] Docking works but bouncing off is wrong for space station ([eliteNext.asm](eliteNext.asm), `GetStationVectorToWork`)

## Maths

- [ ] Add leading sign to mul24 ([Maths24/asm_mul24_notbank0safe.asm](Maths24/asm_mul24_notbank0safe.asm))
- [ ] Optimisae mul24 for leading 0's to do 8.8 x 8.8 ([Maths24/asm_mul24_notbank0safe.asm](Maths24/asm_mul24_notbank0safe.asm))
- [ ] Replace this with non memory access version ([MathsFPS78/asm_multiply_S78.asm](MathsFPS78/asm_multiply_S78.asm), `AequAmulQdiv256u`)
- [ ] HLequHLmulDEu doesn't return H.L * D.E as 8.8 as its comment says: H and L both come back as bits 8-15 of the product. Its only caller, XX12EquNodeDotOrientation, uses H with node values under 256, where that is right; fix the routine and the caller together ([MathsFPS78/asm_multiply_S78.asm](MathsFPS78/asm_multiply_S78.asm), `HLequHLmulDEu`; Tools/test_maths.py test_s78_multiplies)
- [ ] DEequDmulEs and the MathsBankedFns routines that call it (ApplyMyAngleAToIXIY, ApplyRollAndPitchToIX) are built but nothing calls them: move to Unused ([MathsFPS78/asm_multiply_S78.asm](MathsFPS78/asm_multiply_S78.asm), `DEequDmulEs`)
- [ ] NormalizeTactics is up to 3 of 96 low on small components (7 bit scale, the divide's halving for lengths of 128 or more, its 3/8 step); more precision if missiles need it ([Maths/normalise96.asm](Maths/normalise96.asm), `NormalizeTactics`)
- [ ] Don't bother with overflow for now ([Maths/MathsBankedFns.asm](Maths/MathsBankedFns.asm), `ADDHLDESignBC`)
- [ ] Check if ADDHLDESignedV4 is deprecated by AddDEtoHLSigned ([Maths/MathsBankedFns.asm](Maths/MathsBankedFns.asm), `ADDHLDESignBC`)
- [ ] WRITE CODE FOR UnivDistanceToTarget ([Maths/MathsBankedFns.asm](Maths/MathsBankedFns.asm), `UnivDistanceToTarget`)

## Universe (ships, planet, sun)

- [ ] Get rid of planet position macros and do as per sun and ship ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm))
- [ ] Pick colour based on galaxy map ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `PlanetUpdateAndRender`)
- [ ] Pick colour based on galaxy map ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `PlanetDraw`)
- [ ] Calculate STP step based on planet size ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `PlanetDraw`)
- [ ] Set color green ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `PlanetDraw`)
- [ ] Draw circle (do we draw solid??) ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `PlanetDraw`)
- [ ] Add check to see if on screen rather than checkign clipped Circle ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `PlanetDraw`)
- [ ] Need logic to generate Planet Type ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `PlanetDraw`)
- [ ] PCNT2Debug ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `DrawPlanetMeridian`)
- [ ] Debug whilst sorting meridain ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `DrawPlanetMeridian`)
- [ ] PCNT2Debug ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `DrawPlanetMeridian`)
- [ ] Move code back in that was pulled outof BLINE ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `DrawPlanetCrater`)
- [ ] DEBUG STP Default of 1 ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `DrawMeridian`)
- [ ] Sort out sign byte for uxuy vxvy in calling code ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `DrawMeridian`)
- [ ] Set up proper variables, hold variables for previous X Y, we don't need ball heap ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `BLINE_HL`)
- [ ] Created a plot xy heap to store for debugging purposes, delete once not needed ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `BLINE_HL`)
- [ ] Need flag for start which is probably CNT being 0? ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `BLINE_HL`)
- [ ] Removed BnKLSP, check fine ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `BLINE_HL`)
- [ ] Removed BnKLSP, check fine ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `BLINE_HL`)
- [ ] What was the Ld de for? ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `BLINE_HL`)
- [ ] SORT OUT PROPER PLANET COLOR ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `BLINE_HL`)
- [ ] Removed check for starting line segments again as we draw direct ([Universe/Planet/planet_data.asm](Universe/Planet/planet_data.asm), `BLINE_HL`)
- [ ] Change to rotate IXIY axis ([Universe/Ships/ApplyShipRollAndPitch.asm](Universe/Ships/ApplyShipRollAndPitch.asm), `ApplyShipRollAndPitch`)
- [ ] Add recharge rate logic for ship types ([Universe/Ships/univ_ship_data.asm](Universe/Ships/univ_ship_data.asm), `RechargeEnergy`)
- [ ] Fall into SpaceStation Launch Position once startup fixed ([Universe/Ships/univ_ship_data.asm](Universe/Ships/univ_ship_data.asm), `UnivSpawnSpaceStationLaunched`)
- [ ] Fault is probably as maths for xyz is 16 bit and shoudl be 24 ([Universe/Ships/univ_ship_data.asm](Universe/Ships/univ_ship_data.asm), `UnivSpawnSpaceStationLaunched`)
- [ ] Change to a tidy that checks for normal accuracy first ([Universe/Ships/univ_ship_data.asm](Universe/Ships/univ_ship_data.asm), `SetAllFacesHiddenLoop`)
- [ ] Can we remove this and just use BnkCNT = 0 as the same thing? ([Universe/UniverseMacros/UniverseVarsDefineMacro.asm](Universe/UniverseMacros/UniverseVarsDefineMacro.asm), `UnivCoreAIVarsMacro`)

## Rendering and graphics

- [ ] Place odler for debugging ([Hardware/screen_equates.asm](Hardware/screen_equates.asm))
- [ ] Looks liek rogue popde ([Layer1Graphics/layer1_print_at.asm](Layer1Graphics/layer1_print_at.asm), `l1_print_at`)
- [ ] Need 1 pixel logic ([Layer2Graphics/asm_l2_plot_horizontal.asm](Layer2Graphics/asm_l2_plot_horizontal.asm), `l2_draw_horz_line_320`)
- [ ] Need 1 pixel logic ([Layer2Graphics/asm_l2_plot_vertical.asm](Layer2Graphics/asm_l2_plot_vertical.asm), `l2_draw_vert_line_320`)
- [ ] Dma optimise ([Layer2Graphics/layer2_draw_box.asm](Layer2Graphics/layer2_draw_box.asm))
- [ ] DMA+ fill mode for l2_draw_6502_line's long spans too (a fixed colour; check the extra set-up is worth it on spans of 20+) ([Layer2Graphics/l2_draw_any_line.asm](Layer2Graphics/l2_draw_any_line.asm), `L2LDmaProg`)
- [ ] IXH and IXL need to be 16 bit and in IX and IY ([Layer2Graphics/layer2_plot_circle.asm](Layer2Graphics/layer2_plot_circle.asm), `l2_draw_clipped_circle`)
- [ ] Add double x calc ([Layer2Graphics/layer2_plot_circle_fill.asm](Layer2Graphics/layer2_plot_circle_fill.asm), `l2_draw_circle_fill`)
- [ ] IXH and IXL need to be 16 bit and in IX and IY ([Layer2Graphics/layer2_plot_circle_fill.asm](Layer2Graphics/layer2_plot_circle_fill.asm), `l2_draw_clipped_circle_filled`)
- [ ] Optimisation ([Layer2Graphics/layer2_plot_diagonal.asm](Layer2Graphics/layer2_plot_diagonal.asm), `l2D_adjustCol2`)
- [ ] SORT OUT SPRITE GAP-just code tidy, spacing is needed for local chart ([Layer3Sprites/sprite_routines.asm](Layer3Sprites/sprite_routines.asm))
- [ ] Compass positions, correct offsets for indicators, add in hide/show ([Layer3Sprites/sprite_routines.asm](Layer3Sprites/sprite_routines.asm), `sprite_local_hyper_cursor`)
- [ ] Add min max on X and Y ([Layer3Sprites/sprite_routines.asm](Layer3Sprites/sprite_routines.asm), `compass_sun_move`)
- [ ] Remove all teh processing of rotmat to load craft to camera as its already been done ([ModelRender/BackfaceCull.asm](ModelRender/BackfaceCull.asm), `CheckVisible`)

## Menus

- [ ] Optimise ([Menus/equip_ship_menu.asm](Menus/equip_ship_menu.asm), `EQSHP_DispPriceAtoDE`)
- [ ] Move cursor code ([Menus/galactic_chart_menu.asm](Menus/galactic_chart_menu.asm), `l2_GCM_circle_320`)
- [ ] Optimise ([Menus/market_prices_menu.asm](Menus/market_prices_menu.asm), `MPM_DispPriceAtoDE`)
- [ ] Space for occupied cells may mvoe to bit flags ([Menus/short_range_chart_menu.asm](Menus/short_range_chart_menu.asm), `SRM_detail_dist_blank2`)
- [ ] GetStatMissileCount:    ld      a,( ([Menus/status_menu.asm](Menus/status_menu.asm), `STAT_expand_name`)
- [ ] Rewrite for all weapon types and set colour as per status ([Menus/status_menu.asm](Menus/status_menu.asm), `STAT_buffer_list`)
- [ ] IN ALL MENUS INITIALISE BOILER TEXT TO BLANKS IN CASE REDISPLAY IS POST A STATUS CHANGE ([Menus/status_menu.asm](Menus/status_menu.asm), `status_equipment_list`)

## Data and tables

- [ ] This coudl actually be used to dynamically build names of componets based on ship build ([Tables/EquipmentTables.asm](Tables/EquipmentTables.asm))
- [ ] Then we only need 1 laser for each facing and build the name ([Tables/EquipmentTables.asm](Tables/EquipmentTables.asm))
- [ ] Need to redo missiles as we need type in equipment as well as count, chagne save game to handle this ([Tables/EquipmentTables.asm](Tables/EquipmentTables.asm), `EquipNameIndex`)

## Not in the game build

From files eliteNext.asm doesn't assemble: moved to Unused folders (SpriteWriter.asm, now Tools/sprite_writer.py, among them). Only relevant if the file comes back into the game.

- [ ] Clear up LSX2 and LSY2 references ([Variables/Unused/initialise_game.asm](Variables/Unused/initialise_game.asm), `WipeScanner`)
- [ ] Don't bother with overflow for now ([Maths/Unused/asm_add.asm](Maths/Unused/asm_add.asm), `ADDHLDEsBCSameNeg`)
- [ ] Dont bother with overflow for now ([Maths/Unused/asm_add.asm](Maths/Unused/asm_add.asm), `ADDHLDESignedV4`)
- [ ] AddAusngToHLsng not used ([Maths/Unused/asm_add.asm](Maths/Unused/asm_add.asm), `ADDHLDESignedV4`)
- [ ] HLEequAusngMinusHLsng not used ([Maths/Unused/asm_add.asm](Maths/Unused/asm_add.asm), `ADDHLDESignedV4`)
- [ ] AddAHLtoDEsigned not used ([Maths/Unused/asm_add.asm](Maths/Unused/asm_add.asm), `AddBCHtoDELsigned`)
- [ ] Neds rewrite of whoel DIDV3B2 ([Maths/Unused/asm_divide.asm](Maths/Unused/asm_divide.asm))
- [ ] Merge Requ256mulAdivQ_6502  RequAmul256divQ ([Maths/Unused/asm_divide.asm](Maths/Unused/asm_divide.asm), `Requ256mulAdivQ_6502`)
- [ ] DVL9 and DVL6 move P and QRS into registers for faster shift ([Maths/Unused/asm_divide.asm](Maths/Unused/asm_divide.asm), `DVID3B`)
- [ ] Check oprimisation here for var r  in b ([Maths/Unused/asm_divide.asm](Maths/Unused/asm_divide.asm), `DVID3B`)
- [ ] TEST ([Maths/Unused/asm_multiply.asm](Maths/Unused/asm_multiply.asm), `mulDEbyLSigned`)
- [ ] Optimise ([Maths/Unused/binary_to_decimal.asm](Maths/Unused/binary_to_decimal.asm), `DispPriceAtoDE`)
- [ ] Dbugtodo ([ModelRender/Unused/PrepTriangles.asm](ModelRender/Unused/PrepTriangles.asm), `IsEdgeInVisibilityRange`)
- [ ] Debug bodge todo ([ModelRender/Unused/PrepTriangles.asm](ModelRender/Unused/PrepTriangles.asm), `IsFace1Visibile`)
- [ ] Revert back to macro later ([ModelRender/Unused/drawforwards-LL17.asm](ModelRender/Unused/drawforwards-LL17.asm), `LastNormalAlwaysVisible`)
- [ ] Add in roll max rates and data to allow ship replacement, reference to custom console ([Data/Unused/ShipModels.asm](Data/Unused/ShipModels.asm), `ShipNormalTable`)

## Done

- [x] SpriteWriter.asm (run in CSpect to write the NESprNN.dat sprite files) replaced by Tools/sprite_writer.py, run by build.bat; it and Layer3Sprites/SpriteSheet.asm, export.asm moved to Unused; Tools/test_sprites.py
- [x] DMA+ fill mode (core 3.03.00) for the Layer 2 clear and memfill_dma in REAL_HARDWARE builds (EliteNHW.nex, `build.bat hardware`); Documentation/ZXNDDMA.md, Tools/test_hardware.py
- [x] Z80 test programs (clipTst, keyTst, macroTst, Tools/testwrite) replaced by the Python emulator tests in Tools/ (run_tests.py, run by elitebuild.bat / build.bat; `notest` skips them)
- [x] Keys table was 55 bytes for 56 key states: VK_EXTEND (and control ExtSystemJump) overwrote RawKeys and init_keyboard missed it ([Hardware/keyboard.asm](Hardware/keyboard.asm), `Keys`)
- [x] fOpen hung (jp to itself) on any open error, so FileLoad / FileSave's error handling never ran; FileSave's write error path returned with the handle still on the stack ([Hardware/drive_access.asm](Hardware/drive_access.asm), `fOpen`, `FileSave`)
- [x] Clean up console and remove compasses
- [x] Re-Write of Tidy
- [x] Apply my Roll and Pitch to 24 bit
- [x] Move compases to border
- [x] Removed test harness code and moved to Test folder
- [x] Later reorg these offsets for better 16 bit read ([Data/Unused/ShipModels.asm](Data/Unused/ShipModels.asm), `ShipNormalTable`)
- [x] Set up blast radius ([GameEngine/Tactics.asm](GameEngine/Tactics.asm), `PlayerHitByMissile`): MissileBlast applies the blast to us and every ship in range
- [x] Missle AI only works on S15 spread over 24 bits, i.e. ignores Sign byte 7 bits ([Maths/normalise96.asm](Maths/normalise96.asm), `NormalseUnivTarget`): now S15.8 throughout, NormalizeTactics scales the sign byte bits down first
