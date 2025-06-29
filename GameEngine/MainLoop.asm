
    DEFINE  MAINLOOP_COOL_LASERS
    DEFINE  MAINLOOP_ECM
    DEFINE  MAINLOOP_KEYBOARDSCAN
;    DEFINE  MAINLOOP_DEMOSHIPS
;   DEFINE  MAINLOOP_DEBUGMISSILE 1
    DEFINE  MAINLOOP_INPUTHANDLER
    DEFINE  MAINLOOP_EVENTHANDLER 1
    DEFINE  MAINLOOP_RECHARGE 1
 ;   DEFINE  MAINLOOP_LAUNCHMISSILE
    DEFINE  MAINLOOP_UPDATEUNIVERSE 1
    DEFINE  MAINLOOP_DUST_RENDER 1    
    DEFINE  MAINLOOP_SUN_RENDER 1
    DEFINE  MAINLOOP_PLANET_RENDER 1
    DEFINE  MAINLOOP_MODEL_RENDER    1
   ; DEFINE  MAINLOOP_SPAWN_ALWAYS_OUTSIDE_SAFEZONE 1
    DEFINE  MAINLOOP_WARP_ENABLED 1
   ; used to block ship spawning whilst debugging
    DEFINE  SPAWN_SHIP_DISABLED 1
    DEFINE  BODY_DIAGNOSTICS 1
;.................................................................................................................................    
; Main loop
;   bank in Maths
;   do random number
;   update lasers
;   update ECM
;   cool warp engines
;   refreshKeyboard
;   if keyboard blocking is set then skip the following
;       test for view key
;       test for pause key
;       if paused then jump back to main loop
;       test for movement keys
;       handle movement 
;           have we got a cursor routine loaded 
;               if yes then select screen (self modifying code)
;               call cursor routine (self modifying code)
;   Is there a main loop mission set?
;       if yes then jump to it
;   Are we docked?
;       if yes jump to UpdateLoop
;       else    decrement Event Counter (cycles 0 to 255)
;                if its zero then call LoopEventTriggered
;                if Event Counter %00001111 is 0 then call RechargeShip
;                if there are any player missiles left 
;                    if player launch missile flag set call LaunchPlayerMissile
;                if WarpPressed call ProcessWarp
;                if UpdateShipsControl is 0 call UpdateUniverseObjects
;                if a ScreenTransition is forced, then jump to BruteForceChange
;                if ViewUpdate is zero jump to UpdateLoop
;                else
;                   Check for Hyperspace countdown message
;                   Display any message in queuye and update message timer
;                   dec console refresh timer and if zero update console then reset timer, set console redraw flag
;                   clear view port
;                   Update and render sun
;                   Update and render planet
;                   Draw space dust on layer 1
;                   if laser is on then draw laser sprites
;                                       drain laser
;                                  else hide laser sprites
;                   draw ships in viewport
;                   if console redraw flag set, call UpdateConsole
;UpdateLoop:        if ScreenLoopJp is not zoer
;                       call screen loop hook (self modifying code)
;                   switch docked flag:  StateCompletedLaunch,   goto WeHaveCompletedLaunch (these all then jump to DoubleBufferCheck)
;                                        StateInTransition,      goto WeAreInTransition
;                                        StateHJumping,          goto WeAreHJumping
;                                        StateHEntering,         goto WeAreHEntering
;                                        StateCompletedHJump,    goto WeHaveCompletedHJump
;                   else goto Double BufferCheck
;DoubleBufferCheck  Flip buffers if double buffered
;                   if ScreenTransitionForced set
;BruteForceChange:      then call SetScreenA
;                   jump back to main loop
;.................................................................................................................................    
MainLoop:	    MMUSelectMathsBankedFns                                         ; make sure we are in maths routines in case a save paged out
.doRandom:      call    doRandom                                                ; redo the seeds every frame
.doLasers:
                IFDEF LASER_V2
                        call    LaserBeamV2
                ELSE
                        UpdateLaserOnCounter
                        UpdateLaserOffCounter
                        UpdateLaserRestCounter
                        CoolLasers
                ENDIF
;...............ECM                
.doECM:
                IFDEF MAINLOOP_ECM
                        INCLUDE "./GameEngine/MainLoop_ECM.asm"
                ENDIF
;...............Warp
.doWarp:
                IFDEF MAINLOOP_WARP_ENABLED
                        ld      a,(WarpCooldown)
                        and     a
                        jp      z,.AlreadyCool
                        dec     a
                        ld      (WarpCooldown),a
.AlreadyCool
                ENDIF
;...............Keyboard
.doKeyboard
                IFDEF MAINLOOP_KEYBOARDSCAN
                        MMUSelectKeyboard
                        call    scan_keyboard                                           ; perform the physical input scan
                ENDIF
;.. This bit allows cycling of ships on universe 0 in demo.........................................................................
                IFDEF MAINLOOP_DEMOSHIPS
DemoOfShipsDEBUG:       call    TestForNextShip
                ENDIF
;.. Check if keyboard scanning is allowed by screen. If this is set then skip all keyboard and AI..................................
InputBlockerCheck:      ld      a,$0
                IFDEF MAINLOOP_INPUTHANDLER
                        JumpIfAEqNusng $01, SkipInputHandlers                           ; as we are in a transition the whole update AI is skipped
                        JumpIfMemTrue TextInputMode, SkipInputHandlers                  ; in input mode all keys are processed by input
                        call    ViewKeyTest
                        call    TestPauseMode
                        ld      a,(GamePaused)
                        cp      0
                        jp      nz,MainLoop
                        MMUSelectKeyboard
                        call    MovementKeyTest
;.. Process cursor keys for respective screen if the address is 0 then we skill just skip movement.................................
                ENDIF
HandleMovement:         ld      a,(CallCursorRoutine+2)
                        JumpIfAIsZero     TestAreWeDocked
;.. Handle Special Mission logic  .................................................................................................
HandleMissionLogic:     ld      a,$00                                                   ; if we have a bank then we have a mission
                        and     a                                                       ;
                        jp      z,HandleBankSelect                                      ;
.MissionLogic:          DISPLAY "TODO Add MMUSelectMissionBankA"                                          ; so select mission bank
MissionJump:            call    $0000                                                   ; and call custom logic routined
;.. Handle displaying correct screen ..............................................................................................
HandleBankSelect:       ld      a,$00
                        MMUSelectScreenA
CallCursorRoutine:      call    $0000
;.. Check to see if we are docked as if we are (or are docking.launching then no AI/Ship updates occur.............................
;.. Also end up here if we have the screen input blocker set
;DEFUNCT?EngineSounds:       ;HasEngineSoundChanged
;DEFUNCT?                    ;call    nz,UpdateEngineSound
SkipInputHandlers:      
;.. For Docked flag its - 0 = in free space, FF = Docked, FE transition, FD = Setup open space and transition to not docked
TestAreWeDocked:        JumpIfMemNeNusng DockedFlag, StateNormal, UpdateLoop            ; if if we are in free space do universe updateelse we skip it. As we are also in dock/transition then no models should be updated so we dont; need to draw
                IFDEF MAINLOOP_EVENTHANDLER
.UpdateEventCounter:    ld      hl,EventCounter                                         ; evnery 256 cycles we do a trigger test
                        dec     (hl)    
.ProcessEvent:          call    z,LoopEventTriggered    
                ENDIF
                IFDEF MAINLOOP_RECHARGE
.ProcessRecharge:       ld      a,(EventCounter)    
                        and     7   
                        call    z, RechargeShip 
                ENDIF
                IFDEF MAINLOOP_LAUNCHMISSILE
.PlayerMissileLaunch:   AnyMissilesLeft
                        jr      z,.NoMissiles                                           ; just in case last one gets destroyed
                        IsMissileLaunchFlagged
                        call    z,  LaunchPlayerMissile
.NoMissiles
                ENDIF
;.. If we get here then we are in game running mode regardless of which screen we are on, so update AI.............................
;.. we do one universe slot each loop update ......................................................................................
;.. First update Sun...............................................................................................................
;... Warp or in system jump thsi moves everything by 1 on the high (sign) byte away or towards ship based on their z axis only
;... its not a true move in the right direction, more a z axis warp                
CheckForWarp:           CallIfMemTrue  WarpPressed, ProcessWarp
UpdateShipsControl:     ld      a,0
                        and     a
                        IFDEF MAINLOOP_UPDATEUNIVERSE
.UpdateShips:               call    z, UpdateUniverseObjects
                        ENDIF
                        JumpIfMemNeNusng ScreenTransitionForced, $FF, BruteForceChange  ; if we docked then a transition would have been forced
CheckIfViewUpdate:      ld      a,$00                                                   ; if this is set to a view number then we process a view
                        JumpIfAIsZero  UpdateLoop                                       ; This will change as more screens are added TODO
;..Processing a view...............................................................................................................
;..Display any message ............................................................................................................
.CheckHyperspaceMessage:AnyHyperSpaceMacro .HandleMessages
                        call    HyperSpaceMessage
.HandleMessages:        AnyMessagesMacro  .NoMessages
                        call    DisplayCurrentMessage
                        call    UpdateMessageTimer
                      
.NoMessages:            MMUSelectLayer2
CheckConsoleReDraw:     ld      hl,ConsoleRefreshCounter
                        dec     (hl)
                        jp      z,.ConsoleDrawBuffer1                                   ; when it hits 0 then frame 1 of console is drawm
                        jp      m,.ConsoleDrawBuffer2                                   ; need top also do next frame for double buffering
.ConsoleNotDraw:        SetMemFalse ConsoleRedrawFlag                        
                        jp      .JustViewPortCLS
.ConsoleDrawBuffer2:    ld      (hl),ConsoleRefreshInterval                         
.ConsoleDrawBuffer1:    SetMemTrue ConsoleRedrawFlag
                        call    l2_cls                                                  ; Clear layer 2 for graphics
                        jp      .ViewPortCLSDone
.JustViewPortCLS:       call   l2_cls_upper_two_thirds
.ViewPortCLSDone:
                        MMUSelectLayer1
.UpdateSun:             
                        IFDEF   MAINLOOP_SUN_RENDER
                            MMUSelectSun
                            call    SunUpdateAndRender
                        ENDIF
.UpdatePlanet:          IFDEF   MAINLOOP_PLANET_RENDER
                            MMUSelectPlanet
                            call    PlanetUpdateAndRender
                        ENDIF
                        IFDEF  BODY_DIAGNOSTICS
                            MMUSelectLayer1
                            ld      a,$47
                            ld      d,1
                            call    l1_attr_line_d_to_a
                            ld      a,$47
                            ld      d,2
                            call    l1_attr_line_d_to_a
                            ld      a,$47
                            ld      d,3
                            call    l1_attr_line_d_to_a
                            MMUSelectPlanet
                            ld      a,(P_BnKxlo)
                            ld      hl,(P_BnKxhi)
                            ld      de,$0103
                            call    l1_print_s24_hex_at_char: ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      a,(P_BnKylo)
                            ld      hl,(P_BnKyhi)
                            ld      de,$0203
                            call    l1_print_s24_hex_at_char: ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      a,(P_BnKzlo)
                            ld      hl,(P_BnKzhi)
                            ld      de,$0303
                            call    l1_print_s24_hex_at_char: ; prints 16 bit lead sign hex value in HLA at char pos DE
                            MMUSelectSun
                            ld      a,(SBnKxlo)
                            ld      hl,(SBnKxhi)
                            ld      de,$010C
                            call    l1_print_s24_hex_at_char: ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      a,(SBnKylo)
                            ld      hl,(SBnKyhi)
                            ld      de,$020C
                            call    l1_print_s24_hex_at_char: ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      a,(SBnKzlo)
                            ld      hl,(SBnKzhi)
                            ld      de,$030C
                            call    l1_print_s24_hex_at_char: ; prints 16 bit lead sign hex value in HLA at char pos DE
                            MMUSelectSun
                        ENDIF
;..Later this will be done via self modifying code to load correct stars routine for view..........................................
DrawDustForwards:       ld     a,$DF
                        ld     (line_gfx_colour),a                         
DustUpdateBank:         MMUSelectViewFront                                              ; This needs to be self modifying
                        IFDEF   MAINLOOP_DUST_RENDER
DustUpdateRoutine:          call   DustForward                                              ; This needs to be self modifying
                        ENDIF
;ProcessSun:             call    DrawForwardSun
                        IFDEF   LASER_V2            
ProcessLaser:               MMUSelectSpriteBank
                            JumpIfMemFalse LaserBeamOn, .NoLaser
.FireLaser:                 call    sprite_laser_show
                            call    LaserDrainSystems
                            jp      ProcessPlanet
.NoLaser:                   call    sprite_laser_hide
                        ELSE
ProcessLaser:               ld      a,(CurrLaserPulseRate)
                            JumpIfAIsNotZero .CheckForPulse
                            JumpIfMemFalse FireLaserPressed, .NoLaser
                            jp      .FireLaser
.CheckForPulse:             JumpIfMemZero CurrLaserPulseOnCount, .NoLaser
.FireLaser:                 MMUSelectSpriteBank
                            call    sprite_laser_show
                            call    LaserDrainSystems
                            jp      ProcessPlanet
.NoLaser:                   MMUSelectSpriteBank
                            call    sprite_laser_hide
                        ENDIF
ProcessPlanet:
                        IFDEF   MAINLOOP_MODEL_RENDER
ProcessShipModels:          call   DrawForwardShips                                     ; Draw all ships and bodies in system (this may need to be self modifying)
                        ENDIF
                        ; add in loop so we only update every 4 frames, need to change CLS logic too, 
                        ; every 4 frames needs to do 2 updates so updates both copies of buffer
                        ; now will CLS bottom thrid
                        CallIfMemTrue ConsoleRedrawFlag, UpdateConsole
;..If we were not in views then we were in display screens/menus...................................................................
UpdateLoop:             JumpIfMemZero ScreenLoopJP+1,LoopRepeatPoint
;..This is the screen update routine for menus.....................................................................................
;.. Also used by transition routines
ScreenLoopBank:         ld      a,$0
                        MMUSelectScreenA
ScreenLoopJP:           call    $0000
LoopRepeatPoint:        ld      a,(DockedFlag)
                        ; Could optimise this to a jp hl lookup table
HandleLaunched:         JumpIfAEqNusng  StateCompletedLaunch,   WeHaveCompletedLaunch
                        JumpIfAEqNusng  StateInTransition,      WeAreInTransition
                        JumpIfAEqNusng  StateHJumping,          WeAreHJumping
                        JumpIfAEqNusng  StateHEntering,         WeAreHEntering
                        JumpIfAEqNusng  StateCompletedHJump,    WeHaveCompletedHJump
                        jp      DoubleBufferCheck
;-- Player launched from station, moved routines from eliteMext.asm to remove call and simplify code                        
WeHaveCompletedLaunch:  call    InitialiseLocalUniverse             ; intiailise local bubble and set us as in flight
.GenerateSun:           MMUSelectSun
                        call    CreateSunLaunched                   ; create the local sun and set position based on seed
.GeneratePlanet:        MMUSelectPlanet
                        call    CreatePlanetLaunched
                        call    ClearUnivSlotList                   ; slot list is clear to 0 is gauranteed next slot
.GenerateSpaceStation:  ld      a,CoriloisStation
                        MMUSelectSpaceStation                       ; Switch to space station (Universe bank 0)
                        call    UnivSelSpaceStationType
                        ld      iyh,0
                        ld      iyl,a
                        call    SpawnSpaceStation                   ; Sets position that we have to overwrite in next step
.BuiltStation:          call    UnivSpawnSpaceStationLaunched       ; replaced with the 0,0,-10000 version ResetStationLaunch
.NowInFlight:           ld      a,StateNormal
                        ld      (DockedFlag),a
                        ForceTransition ScreenFront
                        ld      a,$FF
                        ld      (LAST_DELTA),a                      ; force sound update in interrupt
                        call    ResetPlayerShip
                        jp      DoubleBufferCheck                   ; Then move through to the rest of the loop
WeAreHJumping:          call    hyperspace_Lightning
                        jp      c,DoubleBufferCheck
                        ld      a,StateHEntering
                        ld      (DockedFlag),a
                        jp      DoubleBufferCheck
WeAreHEntering:         ld      a,StateCompletedHJump
                        ld      (DockedFlag),a
                        jp      DoubleBufferCheck
;--
LaunchedFromStation:    
                        ret
; laser duration goign below 0 for some reason
; if laser is on
;    if laser duration = master duration - do sfx
;    laser duration ---
;    if laser duration = 0
;          **should set beam off***
;       curr burst count --
;       if busrt count = 0 
;          set cooldown to post pulserests
;       else
;          set cooldown to 0
;          pause = pulse off time
;    else
;       return
;  else
;     if burst count <> 0
;        current burst pause --
;        return if not zero
;        set laser beam on
;        return
;      else
;         cooldown-- if not zero

LaserBeamV2:            JumpIfMemFalse LaserBeamOn, .LaserIsOff                          ; If laser is not on then skip
.LaserIsOn:             ld          hl,CurrLaserPulseOnTime
                        ld          a,(CurrLaserDuration)
                        cp          (hl)                                                ; if duration just started
                        ;call        z, SoundLaserFiring                                ; queue sound
                        dec         a
                        ld          (CurrLaserDuration),a                               ; if duration is 0    
                        ;break
                        ReturnIfANotZero                                                ; the do the end of pulse
.EndOfPulse:            SetMemFalse LaserBeamOn
                        ld          a,(CurrLaserBurstCount)
                        dec         a
                        ld          (CurrLaserBurstCount),a                             ; if we have run out of
                        JumpIfAIsNotZero    .SkipBurstEnd                               ; pulses then 
.EndOfBurst:            ldCopyByte  CurrLaserPulseRest,  CurrentCooldown                ; main cool down
                        ret
.SkipBurstEnd:          SetMemZero  CurrentCooldown                                     ; else its just pulse 
                        ldCopyByte  CurrLaserPulseOffTime,  CurrentBurstPause           ; cooldown
.SkipPulseEnd:          ret
.LaserIsOff:            ld          a,(CurrLaserBurstCount)
                        JumpIfAIsZero .FullCool
.BurstCool:             ld          a,(CurrentBurstPause)
                        dec         a
                        ld          (CurrentBurstPause),a
                        ret         nz
                        SetMemTrue  LaserBeamOn
                        ldCopyByte  CurrLaserPulseOnTime, CurrLaserDuration
                        ret
.FullCool:              ld          a,(CurrentCooldown)
                        ReturnIfAIsZero
                        dec         a
                        ld          (CurrentCooldown),a
                        ret

;;called from LaunchedFromStation  & WeHaveCompletedHJump to re-seed the system
;-- Get seed for galaxy system and copy into working vars for system and galaxy, correct post jump fuel, force to front view, set extra vessels to spawn to 0 and mark as undocked
InitialiseLocalUniverse:ld      a,(Galaxy)                      ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        ld      hl,(TargetSystemX)
                        ld      (PresentSystemX),hl
                        ld      b,h
                        ld      c,l
                        CorrectPostJumpFuel
                        ForceTransition ScreenFront            ; This will also trigger stars 
                        ld      a,$00
                        ld      (ExtraVesselsCounter),a
                        DISPLAY "TODO: Check callers as they may be doign this as a duplicate"
                        ld      (DockedFlag),a
                        call    GalaxyGenerateDesc             ; bc  holds new system to generate system
                        call    copy_working_to_system         ; and propogate copies of seeds
                        call    copy_working_to_galaxy         ; .
                        call    get_planet_data_working_seed   ; sort out system data
                        ret


; to create planet position 
;       take seed 2 AND %00000011 + 3 + carry and store in z sign
;       take result and divide by 2 then store in x and y sign
;         
;       take seed 4 AND %00000111 OR %10000001 and store in z sign
;       take seed 6 AND %00000011 and store in x sign and y sign
;       set pitch and roll to 0
;
;
;                                   
; --- At the end of a hyperspace jump we have to reset compass, market universe sun and planets etc
WeHaveCompletedHJump:   call    InitialiseLocalUniverse
                        ;call    GetDigramGalaxySeed           ; .           
                        MMUSelectStockTable                    ; .
                        call    generate_stock_market          ; generate new prices
                        call    ClearUnivSlotList              ; clear out any ships
                        call    ResetPlayerShip
                        HalveFugitiveStatus                    ; halves status and brings bit into carry
                        MMUSelectSun
                        call    CreateSun                      ; create the local sun and set position based on seed
                        MMUSelectPlanet
                        call    CreatePlanet
            DISPLAY "TODO:  GENEATE SUB AND PLANET POS"
;TODO                        call    generateSunAndPlanetPos        ; uses current carry state too
;TODO.CreateSun:             call    SetSunSlot
; PROBABLY NOT NEEDED NOW                      MMUSelectShipBank1
; PROBABLY NOT NEEDED NOW                      call    GetShipBankId
;;SELECT CORRECT BANK                        MMUSelectUniverseN 0
;;TODO                        call    CopyBodyToUniverse
;;TODO                        call    CreateSun
;;TODOCreatePlanet:          call    SetPlanetSlot
;;TODO                       MMUSelectShipBank1
;;TODO                    eliteb       call    GetShipBankId
;;TODO                       MMUSelectUniverseBankN 1
;;TODO                       call    CopyBodyToUniverse
                        SetMemFalse DockedFlag
.TriggerEngineSound:    ld      a,$FF
                        ld      (LAST_DELTA),a              ; force sound update in interrupt
                        jp  DoubleBufferCheck
                        

WarpSFX:                ld      a,(WarpRoutineAddr+1)
                        and     a
                        ret     z
WarpMMUBank:            ld      a,$00
                        MMUSelectScreenA
WarpRoutineAddr:        call    0000
                        ret

;--- From here is the new simplified logic. This uses the current spawn table
;--- Events such as jumping to a system, ending up in which space, 
;--- special mission events
;--- We will need actually two tables, 1 for in station range 1 for not else flipping tables on the Z boundary
;--- Would be difficult
;--- load the table to work from. This then leaves all teh logic configurable
LoopEventTriggered:     ; for now just do spawn
                        call        SpawnEvent
                        ret ; implicit ret from jp to be added later
                        

    DEFINE  SPAWN_TABLE_SELECT   1
    DEFINE  SPAWN_GENERATE_COUNT 1
    DEFINE  SPAWN_LOOP           1
    
;--- Handle spawn event --------------------------------------------
SpawnEvent:             IFDEF SPAWN_SHIP_DISABLED
                            DISPLAY "TODO: Disabled spawing for diagnostics"
                            ret
                        ENDIF
                        ;break
                        call    FindNextFreeSlotInC                 ; set c= slot number, if we cant find a slot                   Stack     > 0
                        ret     c                                   ; then may as well just skip routine
;.. Found a slot free so can spawn, now this define controls filtering of what can be spawned near a safe zone
                        IFDEF   MAINLOOP_SPAWN_ALWAYS_OUTSIDE_SAFEZONE
                            SetMemFalse SpaceStationSafeZone        ; This if def allows spawning inside space station safe zone
                        ENDIF
;.. A slot is free for a spawn to occur so select a spawn table and data
            DISPLAY "TODO: Optimise spawn so it saves off spawn data where there are more than one to do"
            DISPLAY "TODO: Optimise spawn and counts down in loop to avoid a stall where it spawns 3 ships on one game cycle"
.SpawnIsPossible:       call    SelectSpawnTable                    ; ix = correct row in spawn table, indexed on the random value found on FreeSpaceSpawnTableLow
.GetSpawnDetails:       call    SelectSpawnTableData                ; get table data, b = max ships to spawm, de = rank table address, hl = address of spawn handler code                  
            DISPLAY "TODO: Check spawn code as some refers to HL address, a refers to ship number but its not a ship number e.g. in test it was E1"
.CheckIfInvalid:        ld      a,b                                 ; if b was 0 then its a count of 0 so no spawn
                        or      a                                   ; .
                        ret     z                                   ; .                            
.SetNbrToSpawn:         push    hl,,bc                              ; de not affected by doRandom                               Stack + 2 > 2
                        call    doRandom                            ; generate a random number to spawn
                        pop     bc                                  ; mask it against b and make sure we have at least 1        Stack - 1 > 1
                        and     b                                   ; .
                        or      1                                   ; .
                        ld      b,a                                 ; so b = the actual number to spawn
                        pop     hl                                  ; get back address of spawn handler                         Stack - 1 > 0
; b = nbr to spawn, c= next free slot for first ship to spawn, hl = handler for spawn, de = rank lookup table of ship type to spawn                        
.SpawnLoop:             push    bc,,de,,hl                          ; save loop counter lookup table and handler                Stack +3  > 3
.FindSlotRequried:      ex      de,hl                               ; hl = lookup spawn type table, de = handler for spawn
                        call    SelectSpawnType                     ; a = shipId to Spawn
                        ex      de,hl                               ; hl = handler routine for spawning ship
                        call    .SpawnAShipTypeC                    ; now we have bc with rank and id for ship type to spawn, hl = address of handler to run
                        pop     bc,,de,,hl                          ; get back values for next iteration                        Stack -3  > 0
                        ret     c                                   ; if Spawn failed carry will be set so we can assume its run out of slots and bail out
                        djnz    .SpawnLoop                          ; repeat until B = 0
                        ret                                         ; we are done
.SpawnAShipTypeC        ld      a,c                                 ; hl= handler to spawn, c = ship to spawn set a to ship type to spawn
                        jp      hl                                  ; we call this so we can do a dynamic jp and get an implicit ret, it will return with carry set if it failed else carry clear
                        ; implicit ret from jp                      ; SpawnShipTypeA handles free slot tests etc


EnemyShipBank:          DS 1
EnemyMissileLaunchPos:  DS 3 * 3
EnemyMissileLaunchMat:  DS 2 * 3


LaunchEnemyMissile:     ; break
                        ld      a,(UbnKShipUnivBankNbr)             ; save current bank number
                        ld      (EnemyShipBank),a                   ;
                        ld      a,5
                        call    CalcLaunchOffset
                        ld      a,0                                 ; TODO For now only 1 missile type
                        GetByteAInTable ShipMissileTable            ; swap in missile data
                        call    SpawnShipTypeA                      ; spawn the ship
                        ret     c                                   ; return if failed
                        call    UnivSetEnemyMissile                 ; as per player but sets as angry
                        ld      a,$FF
                        ld      (UBnKMissileTarget),a               ; set as definte player as target
                        ld      a,(EnemyShipBank)                   ; Direct restore current bank
                        MMUSelectUnivBankA                          ;
                        ld      hl, UBnKMissilesLeft                ; reduce enemy missile count
                        dec     (hl)
                        ret

LaunchEnemyFighter:     ld      a,10
                        ;break;call    CopyUBnKtoLaunchParameters
                        ;copymatrix,rot and speed
                        ret

LaunchPlayerMissile:   ; break
                        call    FindNextFreeSlotInC                 ; Check if we have a slot free
                        jr      c,.MissileMissFire                  ; give a miss fire indicator as we have no slots
            DISPLAY "TODO: FOR NOW ONLY 1 MISSILE TYPE"
.LaunchGood:            ld      a,0                                 ; TODO For now only 1 missile type
                        GetByteAInTable ShipMissileTable            ; swap in missile data
                        call    SpawnShipTypeA                      ; spawn the ship
                        ld      a,(MissileTargettingFlag)           ; Get target from computer
                        ld      (UBnKMissileTarget),a               ; load target Data
                        call    UnivSetPlayerMissile                ; .
                        ClearMissileTargetting                      ; reset targetting
                        ld      hl, NbrMissiles
                        dec     (hl)
            DISPLAY "TODO: handle removal of missile from inventory and console"
                        ret
.MissileMissFire:       ClearMissileTargetting
                        ret ; TODO bing bong noise misfire message

                        include "./SpawnShipTypeA.asm"

                        ; reset main loop counters
                        ; from BBC TT18 jump code
                        ; need to set system corrodinates, flush out univere ships etc
                        ; set up new star system and landing location in system     
                        ; reset ship speed etc (RES2)
                        ; update legal status, missle indicatrions, planet data block, sun data block (SOLAR)
                        ;   put planet into data blokc 1 of FRIN
                        ;   put sun inot data block (NWWSHIP)
                        ; need to look at in system warp code (WARP) - note we need to -reorg all to code for teh station as that will never be in slot 0

WeAreInTransition:                        
DoubleBufferCheck:      ld      a,00
                        IFDEF DOUBLEBUFFER
                            cp      0
                            jp      z,TestTransition
                            MMUSelectLayer2
                            ld     a,(varL2_BUFFER_MODE)
                            cp     0
                            call   nz,l2_flip_buffers
                        ENDIF
TestTransition:         ld      a,(ScreenTransitionForced)          ; was there a bruite force screen change in any update loop
                        cp      $FF
                        jp      z,MainLoop
BruteForceChange:       call    SetScreenA
                        jp MainLoop

                    
;......................................................................
; Sound Code

              

;As speed goes up so does pitch

