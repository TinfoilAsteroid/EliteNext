
    DEFINE  MAINLOOP_COOL_LASERS
    DEFINE  MAINLOOP_ECM
    DEFINE  MAINLOOP_KEYBOARDSCAN
;    DEFINE  MAINLOOP_DEMOSHIPS
;   DEFINE  MAINLOOP_DEBUGMISSILE 1
    DEFINE  MAINLOOP_INPUTHANDLER
   ; DEFINE  MAINLOOP_EVENTHANDLER 1
    DEFINE  MAINLOOP_RECHARGE 1
 ;   DEFINE  MAINLOOP_LAUNCHMISSILE
    DEFINE  MAINLOOP_UPDATEUNIVERSE 1
    DEFINE  MAINLOOP_DUST_RENDER 1    
;    DEFINE  MAINLOOP_SUN_RENDER 1
;    DEFINE  MAINLOOP_PLANET_RENDER 1
    DEFINE  MAINLOOP_MODEL_RENDER    1
    DEFINE  MAINLOOP_SPAWN_ALWAYS_OUTSIDE_SAFEZONE 1
    DEFINE  MAINLOOP_WARP_ENABLED 1

;.................................................................................................................................    
MainLoop:	            call    doRandom                                                ; redo the seeds every frame
                IFDEF LASER_V2
                        call    LaserBeamV2
                ELSE
                        UpdateLaserOnCounter
                        UpdateLaserOffCounter
                        UpdateLaserRestCounter
                        CoolLasers
                ENDIF
                IFDEF MAINLOOP_ECM
                        INCLUDE "./GameEngine/MainLoop_ECM.asm"
                ENDIF
                IFDEF MAINLOOP_WARP_ENABLED
                        ld      a,(WarpCooldown)
                        and     a
                        jp      z,.AlreadyCool
                        dec     a
                        ld      (WarpCooldown),a
.AlreadyCool
                ENDIF
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
                IFDEF MAINLOOP_WARP_ENABLED
ProcessWarp:            JumpIfMemFalse  WarpPressed, .NoWarp
.WarpIsPressed:         SetMemFalse     WarpPressed                               ; clear and acknowlege
                        JumpIfMemZero   WarpCooldown, .WarpDriveCool
;Need logic for jump drive malfunction
.JumpDriveHot:          ; call bong jump drive hot
                        ; flash jump drive status icon
                        jp      .NoWarp
.WarpDriveCool:         JumpIfMemFalse    SpaceStationSafeZone, .NotInSpaceStationRange
.MassLocked:            ; call bong
                        ; message mass locked
                        jp      .NoWarp
.NotInSpaceStationRange:call    AreShipsPresent
                        jr      nc,     .MassLocked
.NoShipsInSystem:      ;MMUSelectPlanet
                       ;ld      a,(PBnKzsgn)
                       ;and     $80
                       ;jp      z,.JumpToPlanetCheck
                        MMUSelectSun
                        ld      a,(SBnKzsgn)
                        and     $80
                        jp      z,.JumpToSunCheck
.NotCorrectFacing:      ;       call bong, align with body
                        jp      .NoWarp
.JumpToPlanetCheck:     ld      a,(PBnKzhi)
                        JumpIfAGTENusng  2, .PlanetRangeOK 
                        ld      a,(PBnKyhi)
                        JumpIfAGTENusng  2, .PlanetRangeOK
                        ld      a,(PBnKxhi)
                        JumpIfAGTENusng  2, .PlanetRangeOK
                        jp      .MassLocked
.PlanetRangeOK:         call    WarpPlanetCloser
                        MMUSelectSun
                        call    WarpSunFurther
                        jp      .MoveJunk
.JumpToSunCheck:        ld      a,(SBnKzsgn)
                        ld      hl,SBnKxsgn
                        or      (hl)
                        ld      hl,SBnKysgn
                        or      (hl)
                        and     SignMask8Bit
                        JumpIfAGTENusng  2, .SunRangeOK
                        jp      .MassLocked
.SunRangeOK:            call    WarpSunCloser
                        MMUSelectPlanet
                        call    WarpPlanetFurther
.MoveJunk:              call    ClearJunk;  call    WarpJunk - as it will move sign bit hi then all junk will be lost
                        ld      a,WarpCoolDownPeriod
                        ld      (WarpCooldown),a
                        MMUSelectLayer1
                        call    WarpSFX             ; Do the visual SFX based on facing
                        jp      .DoneWarp
.NoWarp:                MMUSelectLayer1
.DoneWarp:
                ENDIF
UpdateShipsControl:     ld      a,0
                        and     a
    IFDEF MAINLOOP_UPDATEUNIVERSE
.UpdateShips:           call    z, UpdateUniverseObjects
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
.UpdateSun:             MMUSelectSun
.DEBUGFORCE:            
                       ;ld          hl,$0081
                       ;ld          (SBnKxlo),hl
                       ;ld          hl,$0001
                       ;ld          (SBnKylo),hl
                       ; ld          hl,$0160
                       ; ld          (SBnKzlo),hl
                        ;ld          a,$80
                        ;ld          (SBnKxsgn),a
                        ;ld          (SBnKysgn),a
                       ; ZeroA
                      ;  ld          (SBnKzsgn),a
    IFDEF   MAINLOOP_SUN_RENDER
                            call    SunUpdateAndRender
    ENDIF
.UpdatePlanet:          MMUSelectPlanet
    IFDEF   MAINLOOP_PLANET_RENDER
                            call    PlanetUpdateAndRender
    ENDIF
;..Later this will be done via self modifying code to load correct stars routine for view..........................................
DrawDustForwards:       ld     a,$DF
                        ld     (line_gfx_colour),a                         
DustUpdateBank:         MMUSelectViewFront                                              ; This needs to be self modifying
    IFDEF   MAINLOOP_DUST_RENDER
DustUpdateRoutine:      call   DustForward                                              ; This needs to be self modifying
    ENDIF
;ProcessSun:             call    DrawForwardSun
            IFDEF   LASER_V2            
ProcessLaser:           MMUSelectSpriteBank
                        JumpIfMemFalse LaserBeamOn, .NoLaser
.FireLaser:             call    sprite_laser_show
                        call    LaserDrainSystems
                        jp      ProcessPlanet
.NoLaser:               call    sprite_laser_hide
            ELSE
ProcessLaser:           ld      a,(CurrLaserPulseRate)
                        JumpIfAIsNotZero .CheckForPulse
                        JumpIfMemFalse FireLaserPressed, .NoLaser
                        jp      .FireLaser
.CheckForPulse:         JumpIfMemZero CurrLaserPulseOnCount, .NoLaser
.FireLaser:             MMUSelectSpriteBank
                        call    sprite_laser_show
                        call    LaserDrainSystems
                        jp      ProcessPlanet
.NoLaser:               MMUSelectSpriteBank
                        call    sprite_laser_hide
            ENDIF
ProcessPlanet:
    IFDEF   MAINLOOP_MODEL_RENDER
ProcessShipModels:      call   DrawForwardShips                                     ; Draw all ships (this may need to be self modifying)
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
HandleLaunched:         JumpIfAEqNusng  StateCompletedLaunch,   WeHaveCompletedLaunch
                        JumpIfAEqNusng  StateInTransition,      WeAreInTransition
                        JumpIfAEqNusng  StateHJumping,          WeAreHJumping
                        JumpIfAEqNusng  StateHEntering,         WeAreHEntering
                        JumpIfAEqNusng  StateCompletedHJump,    WeHaveCompletedHJump
                        
                        jp  DoubleBufferCheck
WeHaveCompletedLaunch:  call    LaunchedFromStation
                        jp      DoubleBufferCheck
WeAreHJumping:          call    hyperspace_Lightning
                        jp      c,DoubleBufferCheck
                        ld      a,StateHEntering
                        ld      (DockedFlag),a
                        jp      DoubleBufferCheck
WeAreHEntering:         ld      a,StateCompletedHJump
                        ld      (DockedFlag),a
                        jp      DoubleBufferCheck

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
WeHaveCompletedHJump:   ld      a,(Galaxy)                      ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        ld      hl,(TargetSystemX)
                        ld      (PresentSystemX),hl
                        ld      b,h
                        ld      c,l
                        CorrectPostJumpFuel
                        ForceTransition ScreenFront            ; This will also trigger stars 
                        ld      a,$00
                        ld      (ExtraVesselsCounter),a
                        ld      (DockedFlag),a
                        call    GalaxyGenerateDesc             ; bc  holds new system to generate system
                        call    copy_working_to_system         ; and propogate copies of seeds
                        call    copy_working_to_galaxy         ; .
                        call    get_planet_data_working_seed   ; sort out system data
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
                        jp      SpawnEvent
                        ; implicit ret from jp

    DEFINE  SPAWN_TABLE_SELECT   1
    DEFINE  SPAWN_GENERATE_COUNT 1
    DEFINE  SPAWN_LOOP           1
;    DEFINE  SPAWN_IGNORE         1
    

SpawnEvent:             IFDEF   SPAWN_IGNORE
                            ret
                        ENDIF
                        call    FindNextFreeSlotInC                 ; c= slot number, if we cant find a slot
                        ret     c                                   ; then may as well just skip routine
                        IFDEF   MAINLOOP_SPAWN_ALWAYS_OUTSIDE_SAFEZONE
                            SetMemFalse SpaceStationSafeZone                        
                        ENDIF
.SpawnIsPossible:       ld      iyh,c                               ; save slot free in iyh
                        call    SelectSpawnTable                    ; ix = correct row in spawn table
.GetSpawnDetails:       call    SelectSpawnTableData                ; get table data, 
.CheckIfInvalid:        ld      a,b                                 ; if b was 0
                        or      a                                   ; then its an invalid
                        ret     z                                   ; ship or just not to spawn
.SetNbrToSpawn:         push    hl,,bc                              ; b will be set to the
                        call    doRandom                            ; actual number to spawn
                        pop     bc                                  ; a is not really needed now as de and hl hold
                        and     b                                   ; addresses for table and handler code
                        or      1                                   ; at least 1 
                        ld      b,a                                 ; so b = the number to spawn
                        pop     hl                                  ; get back address of spawn handler
; b = nbr to spawn, hl = handler for spawn, de = lookup table of ship type to spawn                        
.SpawnLoop:             push    bc,,de,,hl                          ; save loop counter lookup table and handler
                        ex      de,hl                               ; hl = lookup spawn type table, de = handler for spawn
                        call    SelectSpawnType                     ; a = shipId to Spawn
                        call    .SpawnAShipTypeA                    ; if we get a carry then stop spawning
                        pop     bc,,de,,hl                          ; get back values
                        djnz    .SpawnLoop                          ; repeat until B = 0
                        ret                                         ; we are done
.SpawnAShipTypeA        ex      de,hl                               ; hl= handler to spawn, a = ship to spawn
                        jp      hl                                  ; we call this so we can do a dynamic jp
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
.LaunchGood:            ld      a,0                                 ; TODO For now only 1 missile type
                        GetByteAInTable ShipMissileTable            ; swap in missile data
                        call    SpawnShipTypeA                      ; spawn the ship
                        ld      a,(MissileTargettingFlag)           ; Get target from computer
                        ld      (UBnKMissileTarget),a               ; load target Data
                        call    UnivSetPlayerMissile                ; .
                        ClearMissileTargetting                      ; reset targetting
                        ld      hl, NbrMissiles
                        dec     (hl)
                        ; TODO handle removal of missile from inventory and console
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

