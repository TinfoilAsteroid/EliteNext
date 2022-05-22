MainLoop:	            call    doRandom                                                ; redo the seeds every frame
                        UpdateLaserCounters                                             ; update laser counters every frame
                        CoolLasers                  
                        call    scan_keyboard                                           ; perform the physical input scan
;.. This bit allows cycling of ships on universe 0 in demo.........................................................................
DemoOfShipsDEBUG:       call    TestForNextShip
;.. Check if keyboard scanning is allowed by screen. If this is set then skip all keyboard and AI..................................
InputBlockerCheck:      ld      a,$0
                        JumpIfAEqNusng $01, SkipInputHandlers                           ; as we are in a transition the whole update AI is skipped
                        JumpIfMemTrue TextInputMode, SkipInputHandlers                  ; in input mode all keys are processed by input
                        InputMainMacro
;.. Process cursor keys for respective screen if the address is 0 then we skill just skip movement.................................
HandleMovement:         ld      a,(CallCursorRoutine+2)
                        JumpIfAIsZero     TestAreWeDocked
;.. Handle displaying correct screen ..............................................................................................
HandleBankSelect:       ld      a,$00
                        MMUSelectScreenA
CallCursorRoutine:      call    $0000
;.. Check to see if we are docked as if we are (or are docking.launching then no AI/Ship updates occur.............................
;.. Also end up here if we have the screen input blocker set
SkipInputHandlers:      
;.. For Docked flag its - 0 = in free space, FF = Docked, FE transition, FD = Setup open space and transition to not docked
TestAreWeDocked:        ld      a,(DockedFlag)                                          ; if if we are in free space do universe update
                        JumpIfANENusng  0, UpdateLoop                                   ; else we skip it. As we are also in dock/transition then no models should be updated so we dont; need to draw
.UpdateEventCounter:    ld      hl,EventCounter                                         ; evnery 256 cycles we do a trigger test
                        dec     (hl)    
.ProcessEvent:          call    z,LoopEventTriggered    
.ProcessRecharge:       ld      a,(EventCounter)    
                        and     7   
                        call    z, RechargeShip 
.PlayerMissileLaunch:   ld      a,(MissileTargettingFlag)                               ; if bit 7 is clear then we have a target and launch requested
                        and     $80
                        call    z,  LaunchPlayerMissile
;.. If we get here then we are in game running mode regardless of which screen we are on, so update AI.............................
;.. we do one universe slot each loop update ......................................................................................
;.. First update Sun...............................................................................................................
.UpdateShips:           call    UpdateUniverseObjects
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
.ConsoleDrawBuffer2:     ld      (hl),ConsoleRefreshInterval                         
.ConsoleDrawBuffer1:     SetMemTrue ConsoleRedrawFlag
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
                        call    SunUpdateAndRender
.UpdatePlanet:          MMUSelectPlanet
                        call    PlanetUpdateAndRender
;..Later this will be done via self modifying code to load correct stars routine for view..........................................
DrawDustForwards:       ld     a,$DF
                        ld     (line_gfx_colour),a                         
DustUpdateBank:         MMUSelectViewFront                                              ; This needs to be self modifying
DustUpdateRoutine:      call   DustForward                                              ; This needs to be self modifying
;ProcessSun:             call    DrawForwardSun
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
ProcessPlanet:
ProcessShipModels:      call   DrawForwardShips                                     ; Draw all ships (this may need to be self modifying)
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
WeHaveCompletedHJump:   ld      a,(Galaxy)      ; DEBUG as galaxy n is not working
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
;;TODO                       call    GetShipBankId
;;TODO                       MMUSelectUniverseBankN 1
;;TODO                       call    CopyBodyToUniverse
                        SetMemFalse DockedFlag
                        jp  DoubleBufferCheck
                        
LoopEventTriggered:     call    FindNextFreeSlotInC                 ; c= slot number, if we cant find a slot
                        ret     c                                   ; then may as well just skip routine
.DEBUGTEST:             SetMemFalse SpaceStationSafeZone                        
.SpawnIsPossible:       ld      iyh,c                               ; save slot free in iyh
.AreWeInWhichSpace:     JumpIfMemTrue MissJumpFlag, .WitchSpaceEvent
.JunkOrNot:             call    doRandom                            ; if random > 35 then its not junk
                        JumpIfAGTENusng 35, .NotJunk                ; .
.JunkLimitHitTest:      TestRoomForJunk .NotJunk                    ; can we fit in any junk
.CouldBeTraderInstead:  call    doRandom                            ; so its now a 50/50 change of being a trader
                        and     1
                        jp      z,.SpawnTrader
;... Handle spawning of junk if possible
.SpawnJunk:             call    doRandom
                        cp      10                                  ; will set carry if a < 10
                        FlipCarryFlag                               ; so now carry is set if a > 10
                        and     1                                   ; so only have carry flag
                        adc     ShipID_CargoType5                   ; so now a = 4 + random + poss carry
                        ld      b,a                                 ; save ship type
                        ; if in space station zone then we can't do asteroids
.CanWeSpawnAsteroid:    JumpIfMemFalse  SpaceStationSafeZone, .NotInSafeZone
                        ld      a,b
.FailIfAsteroidInSafe:  ReturnIfAEqNusng   ShipID_Asteroid          ; we can't spawn asteroids near a space station
.NotInSafeZone:         AddJunkCount                                ; so its an increase in junk
                        ld      a,b                                 ; get ship type back
                        jp      SpawnShipTypeA
                        ;.......implicit ret
;... Handle spawing of non junk type object
.NotJunk:               JumpIfMemTrue SpaceStationSafeZone, .SpawnTrader ; changed so that it can spawn friendly ships around a space station
.PossibleCop:           MMUSelectCommander                          ; get cargo rating
.AreWeABadPerson:       call    calculateBadness                    ; a = badness
                        sla     a                                   ; double badness for scans
                        JumpIfMemZero CopCount,.NoCopsInSystem      ; are there any cops already
.CopsAlreadyPresent:    ld      hl,FugitiveInnocentStatus           ; or a with FIST status
                        or      (hl)
.NoCopsInSystem:        ld      (BadnessStatus),a                   ; if badness level triggers a cop     
                        call    doRandom                            ; then its hostile
                        CallIfAGTEMemusng BadnessStatus, .SpawnHostileCop  ; 
                        ReturnIfMemNotZero CopCount                 ; if here are police then we are done
                        ld      hl, ExtraVesselsCounter             ; count down extra vessels counter
                        dec     (hl)                                ; to prevent mass spawing
                        ret     p                                   ;
.ExtraVesselHit0:       inc     (hl)                                ; set counter to 0
          ;TODO              JumpIfMemNotZero MissionData,.DoMissionPlans; call special mission spawn logic routine
           ;TODO             ret     c                                   ; return if carry was set (i.e. it did something)
                        ld      a,(Galaxy)      ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        ld      a,(GalaxyDisplayGovernment)
                        JumpIfAIsNotZero .NotAnarchySystem
                        ld      b,a
                        call    doRandom                            ; if random > 120 then don't spawn
                        ReturnIfAGTENusng 120                       ;
                        and     7                                   ; if random 0 ..7 < gov rating
                        ReturnIfALTNusng b                          ; then return
.SpawnTrader:       ; TODO
; ... Spawn a cop at hostile status
.SpawnHostileCop:       ld      a,ShipID_Viper
                        call    SpawnShipTypeA                      ; call rather than jump
                        call    SetShipHostile                      ; as we have correct universe banked in now
                        ret
; ... Spawb a hostile ship or cluster
.SpawnHostile:          call    doRandom
                        JumpIfAGTENusng 100,.SpawnPirates           ; 100 in 255 change of one or more pirates
.SpawnAHostileHunter:   ld      hl, ExtraVesselsCounter             ; prevent the next spawning
                        inc     (hl)                                ; 
                        and     3                                   ; a = random 0..3
                        MMUSelectShipBank1 
                        GetByteAInTable ShipHunterTable             ; get hunter ship type
                        call    SpawnShipTypeA
                        call    SetShipHostile
                        ret
.NotAnarchySystem:      ret                        
.SpawnPirates:          call    doRandom                           ; a = random 0..3
                        and     3
                        ld      (ExtraVesselsCounter),a
.PirateLoop:            call    doRandom
                        ld      c,a                                 ; random and random and 7
                        call    doRandom
                        and     c
                        and     7
                        GetByteAInTable ShipPackList
                        call    SpawnShipTypeA
                        call    SetShipHostile                      ; make sure its hostile
                        AddPirateCount                              ; another pirate has been spawned
                        ld      hl,ExtraVesselsCounter
                        dec     (hl)
                        jr      nz,.PirateLoop
                        ret
.WitchSpaceEvent:       ret; TODO for now


LaunchPlayerMissile:    call    FindNextFreeSlotInC                 ; Check if we have a slot free
                        jr      c,.MissileMissFire                  ; give a miss fire indicator as we have no slots
.LaunchGood:            ld      a,0                                 ; TODO For now only 1 missile type
                        GetByteAInTable ShipMissileTable            ; swap in missile data
                        call    SpawnShipTypeA                      ; spawn the ship
                        ld      a,(MissileTargettingFlag)           ; Get target from computer
                        ld      (UBnKMissileTarget),a               ; load target Data
                        call    UnivSetPlayerMissile                ; .
                        ClearMissileTarget                          ; reset targetting
                        ; TODO handle removal of missile from inventory and console
                        ret
.MissileMissFire:       ret ; TODO bing bong noise misfire message

; a = ship type, iyh = universe slot to create in
SpawnShipTypeA:         ld      iyl,a                               ; save ship type
                        ReturnIfAGTENusng   ShipTotalModelCount     ; current ship count limit 
                        MMUSelectShipBank1                          ; select bank 1
                        ld      a,iyh                               ; select unverse free slot
                        ld      b,iyl
                        call    SetSlotAToTypeB
                        MMUSelectUniverseA                          ; .
                        push    af                                  ; save computed bank number
                        ld      a, iyl                              ; retrive ship type
                        ;call    SetSlotAToTypeB                    ; record in the lookup tables
                        call    GetShipBankId                       ; find actual memory location of data
                        MMUSelectShipBankA
                        ld      a,b                                 ; b = computed ship id for bank
                        call    CopyShipToUniverse
                        call    UnivSetSpawnPosition                ; set initial spawn position
                        pop     af                                  ; we need bank nbr in a
                        call    UnivInitRuntime                     ; Clear runtime data before startup, iy h and l are already set up
                        ld      a,(ShipTypeAddr)
                        ld      b,a
                        ld      a,iyl
                        call    SetSlotAToClassB
                        ret

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
BruteForceChange:       ld      d,a
                        ld      e,ScreenMapRow
                        mul
                        ld      ix,ScreenKeyMap
                        add     ix,de                               ; Force screen transition
                        call    SetScreenAIX
                        jp MainLoop
