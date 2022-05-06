 DEVICE ZXSPECTRUMNEXT
 DEFINE  DOUBLEBUFFER 1
 CSPECTMAP eliteN.map
 OPT --zxnext=cspect --syntax=a --reversepop

DEBUGSEGSIZE   equ 1
DEBUGLOGSUMMARY equ 1
;DEBUGLOGDETAIL equ 1

;----------------------------------------------------------------------------------------------------------------------------------
; Game Defines
ScreenLocal      EQU 0
ScreenGalactic   EQU ScreenLocal + 1
ScreenMarket     EQU ScreenGalactic + 1
ScreenMarketDsp  EQU ScreenMarket + 1
ScreenStatus     EQU ScreenMarketDsp + 1
ScreenInvent     EQU ScreenStatus + 1
ScreenPlanet     EQU ScreenInvent + 1
ScreenEquip      EQU ScreenPlanet + 1
ScreenLaunch     EQU ScreenEquip + 1
ScreenFront      EQU ScreenLaunch + 1
ScreenAft        EQU ScreenFront+1
ScreenLeft       EQU ScreenAft+1
ScreenRight      EQU ScreenLeft+1
ScreenDocking    EQU ScreenRight+1
ScreenHyperspace EQU ScreenDocking+1
;----------------------------------------------------------------------------------------------------------------------------------
; Colour Defines
    INCLUDE "./Hardware/L2ColourDefines.asm"
    INCLUDE "./Hardware/L1ColourDefines.asm"
;----------------------------------------------------------------------------------------------------------------------------------
; Total screen list
; Local Chart
; Galactic Chart
; Market Prices
; Inventory
; Comander status
; System Data
; Mission Briefing
; missio completion
; Docked  Menu (only place otehr than pause you can load and save)
; Pause Menu (only place you can load from )
; byint and selling equipment
; bying and selling stock

                        INCLUDE "./Hardware/register_defines.asm"
                        INCLUDE "./Layer2Graphics/layer2_defines.asm"
                        INCLUDE	"./Hardware/memory_bank_defines.asm"
                        INCLUDE "./Hardware/screen_equates.asm"
                        INCLUDE "./Data/ShipModelEquates.asm"
                        INCLUDE "./Menus/clear_screen_inline_no_double_buffer.asm"	
                        INCLUDE "./Macros/graphicsMacros.asm"
                        INCLUDE "./Macros/callMacros.asm"
                        INCLUDE "./Macros/carryFlagMacros.asm"
                        INCLUDE "./Macros/CopyByteMacros.asm"
                        INCLUDE "./Macros/ldCopyMacros.asm"
                        INCLUDE "./Macros/ldIndexedMacros.asm"
                        INCLUDE "./Macros/jumpMacros.asm"
                        INCLUDE "./Macros/MathsMacros.asm"
                        INCLUDE "./Macros/MMUMacros.asm"
                        INCLUDE "./Macros/NegateMacros.asm"
                        INCLUDE "./Macros/returnMacros.asm"
                        INCLUDE "./Macros/ShiftMacros.asm"
                        INCLUDE "./Macros/signBitMacros.asm"
                        INCLUDE "./Tables/message_queue_macros.asm"
                        INCLUDE "./Variables/general_variables_macros.asm"
                        INCLUDE "./Variables/UniverseSlot_macros.asm"
                        
                        INCLUDE "./Data/ShipIdEquates.asm"
                        
InputMainMacro:         MACRO
                        call    ViewKeyTest
                        call    TestPauseMode
                        ld      a,(GamePaused)
                        cp      0
                        jr      nz,MainLoop
                        call    MovementKeyTest
                        ENDM

DecrementIfPossible:    MACRO   memaddr,notpossjp
                        JumpIfMemZero memaddr, notpossjp
                        dec     a
                        ld      (memaddr),a
                        ENDM
                        
UpdateOnCounter:        MACRO
                        DecrementIfPossible  CurrLaserPulseOnCount, .UpdateOnDone  
                        JumpIfAIsNotZero     .UpdateOnDone
                        ldCopyByte CurrLaserPulseOffTime, CurrLaserPulseOffCount
.UpdateOnDone:
                        ENDM

UpdateOffCounter:       MACRO
                        DecrementIfPossible  CurrLaserPulseOffCount,  .UpdateOffDone
                        JumpIfAIsNotZero     .UpdateOffDone
                        JumpIfMemNeMemusng   CurrLaserPulseRate, CurrLaserPulseRateCount, .UpdateOffDone
                        ldCopyByte CurrLaserPulseRest, CurrLaserPulseRestCount
.UpdateOffDone:
                        ENDM

UpdateRestCounter:      MACRO
                        DecrementIfPossible CurrLaserPulseRestCount, .UpdateRestDone                     ; if pulse rest > 0 then  pulse rest --                   
.DonePulseRest:         JumpIfMemNotZero CurrLaserPulseRestCount, .UpdateRestDone                        ; if pulse rest = 0
.ResetRate:             ZeroA                                                                           ;    then pulse rate count = 0
                        ld      (CurrLaserPulseRateCount),a                                             ;    .
.UpdateRestDone
                        ENDM


UpdateLaserCounters:    MACRO
                       
                        UpdateOnCounter
                        UpdateOffCounter
                        UpdateRestCounter
                        ENDM      

UpdateLaserCountersold: MACRO
                        JumpIfMemZero CurrLaserPulseOnCount,   .SkipPulseOn     ; if beam on count > 0 then beam on count --
                        dec     a                                               ; .
                        ld      (CurrLaserPulseOnCount),a                       ; .
.SkipPulseOn:           JumpIfAIsNotZero  .SkipRestCounter                      ;    if beam on = 0 then                        
                        ld      a,(CurrLaserPulseOffCount)                      ;       if beam off > 0 then  beam off --
                        JumpIfMemZero CurrLaserPulseOffCount, .SkipPulseOff     ;       .
                        dec     a                                               ;       .
                        ld      (CurrLaserPulseOffCount),a                      ;       .
.SkipPulseOff:          JumpIfAIsNotZero  .SkipRestCounter                      ;       if beam off = 0
                        JumpIfMemZero CurrLaserPulseRestCount, .ZeroRateCounter ;
                        dec     a
                        ld      (CurrLaserPulseRestCount),a
                        jr      nz,.SkipRestCounter
.ZeroRateCounter:       ld      (CurrLaserPulseRateCount),a
.SkipRestCounter:       
                        ENDM
                        
                        
charactersetaddr		equ 15360
STEPDEBUG               equ 1

TopOfStack              equ $7F00

EliteNextStartup:       ORG         $8000
                        di
                        ; "STARTUP"
                        ; Make sure  rom is in page 0 during load
                        MMUSelectLayer2
                        call        asm_disable_l2_readwrite
                        MMUSelectROMS
.GenerateDefaultCmdr:   MMUSelectCommander
                        call		defaultCommander
                        call        saveCommander
                        MMUSelectLayer1
                        call		l1_cls
                        ld			a,7
                        call		l1_attr_cls_to_a
                        ld          a,$FF
                        call        l1_set_border
                        MMUSelectSpriteBank
                        call		sprite_load_sprite_data
Initialise:             MMUSelectLayer2
                        call 		l2_initialise
                        call        init_keyboard
                        ClearForceTransition
TidyDEBUG:              ld          a,16
                        ld          (TidyCounter),a
TestText:               xor			a
                        ld      (JSTX),a
DEBUGCODE:              ClearSafeZone ; just set in open space so compas treacks su n
                        MMUSelectSpriteBank
                        call		init_sprites
.ClearLayer2Buffers:    DoubleBufferIfPossible
                        DoubleBufferIfPossible
; Set up all 8 galaxies, 7later this will be pre built and loaded into memory from files                        
InitialiseGalaxies:     call		ResetUniv                       ; Reset ship data
                        call        ResetGalaxy                     ; Reset each galaxy copying in code
                        call        SeedAllGalaxies
StartAttractMode:       call        AttractMode
                        JumpIfAIsZero  .SkipDefault
                        MMUSelectCommander
                        call		defaultCommander
                        jp          InitialiseMainLoop:
.SkipDefault                        
;                        call    FindNextFreeSlotInA
;                        ld      b,a
;                        ld      a,13 ;Coriolis station
;                        call    InitialiseShipAUnivB
;                        xor     a
InitialiseMainLoop:     call    InitMainLoop
;..MAIN GAME LOOP..................................................................................................................
; MACRO BLOCKS.....................................................................................................................
;.. Check if keyboard scanning is allowed by screen. If this is set then skip all keyboard and AI..................................



; if beam on count > 0
;    then beam on count --
;         if beam on count = 0 
;            then beam off count = beam off
; if beam off > 0 
;    then beam off --
;         if beam off = 0 and pulse rate count = max count
;            then pulse rest count = pulse rest
; if pulse rest > 0 then pulse rest --
;    if pulse rest = 0
;       then pulse rate count = 0

          
; counter logic
;    if beam on count > 0 then beam on count --
;    if beam on = 0 then  
;       if beam off count >0 then beam off count --
;       if beam off count = 0 them
;          if pulse rest count > 0 then pulse rest count --
;             if reset count = 0 then pulse rate count = 0
; shoting logic
;    if pulse on count is 0 and pulse off count is 0 and rest count is 0                        
;       then  if fire pressed is OK
;                if not beam type
;                   then pulse rate count ++
;                        if pulse rate count < pulse max count
;                           then pulse on count = pulse on time
;                                pulse off count = pulse off time
;                                pulse rest count = pulse rest time
;                           else pulse rest count = pulse rest time
;                                pulse rate count, pulse on count, pulse off count = 0
;                   else pulse on count = $FF
;                        pulse off time , rest time = 0

;..................................................................................................................................
MainLoop:	            call    doRandom                            ; redo the seeds every frame
                        UpdateLaserCounters
                        CoolLasers
                        call    scan_keyboard                       ; perform the physical input scan
;.. This bit allows cycling of ships on universe 0 in demo.........................................................................
DemoOfShipsDEBUG:       call    TestForNextShip
;.. Check if keyboard scanning is allowed by screen. If this is set then skip all keyboard and AI..................................
InputBlockerCheck:      ld      a,$0
                        JumpIfAEqNusng $01, SkipInputHandlers       ; as we are in a transition the whole update AI is skipped
                        JumpIfMemTrue TextInputMode, SkipInputHandlers  ; in input mode all keys are processed by input
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
TestAreWeDocked:        ld      a,(DockedFlag)                                ; if if we are in free space do universe update
                        JumpIfANENusng  0, UpdateLoop                        ; else we skip it. As we are also in dock/transition then no models should be updated so we dont; need to draw
.UpdateEventCounter:    ld      hl,EventCounter                               ; evnery 256 cycles we do a trigger test
                        dec     (hl)
                        call    z,LoopEventTriggered
                        ld      a,(MissileTargettingFlag)                     ; if bit 7 is clear then we have a target and launch requested
                        and     $80
                        call    z,  LaunchPlayerMissile
;.. If we get here then we are in game running mode regardless of which screen we are on, so update AI.............................
;.. we do one universe slot each loop update ......................................................................................
;.. First update Sun...............................................................................................................
.UpdateShips:           call    UpdateUniverseObjects
                        JumpIfMemNeNusng ScreenTransitionForced, $FF, BruteForceChange                          ; if we docked then a transition would have been forced
CheckIfViewUpdate:      ld      a,$00                                         ; if this is set to a view number then we process a view
                        JumpIfAIsZero  UpdateLoop                             ; This will change as more screens are added TODO
;..Processing a view...............................................................................................................
;..Display any message ............................................................................................................
.CheckHyperspaceMessage:AnyHyperSpaceMacro .HandleMessages
                        call    HyperSpaceMessage
.HandleMessages:        AnyMessagesMacro  .NoMessages
                        call    DisplayCurrentMessage
                        call    UpdateMessageTimer
                      
.NoMessages:            MMUSelectLayer2
                        call   l2_cls_upper_two_thirds
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
DustUpdateBank:         MMUSelectViewFront                                    ; This needs to be self modifying
DustUpdateRoutine:      call   DustForward                                   ; This needs to be self modifying
PrepLayer2:             ld      hl,ConsoleRefreshCounter
                        dec     (hl)
                        jp      z,ConsoleDraw
                        jp      m,ConsoleDrawReset
.ConsoleNotDraw:        SetMemFalse ConsoleRedrawFlag                        
                        jp      ProcessPlanet
ConsoleDraw:            SetMemTrue ConsoleRedrawFlag
                        MMUSelectLayer2 
                        call    l2_cls_lower_third                                  ; Clear layer 2 for graphics
                        jp      ProcessPlanet
ConsoleDrawReset:       SetMemTrue ConsoleRedrawFlag
                        ld      (hl),ConsoleRefreshInterval                     
                        MMUSelectLayer2 
                        call    l2_cls_lower_third                                  ; Clear layer 2 for graphics
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
ProcessShipModels:      call   DrawForwardShips                               ; Draw all ships (this may need to be self modifying)
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
.LaunchGood:            ld      a,ShipID_Missile                    ; TODO For now only 1 missile type
                        GetByteAInTable ShipPackList                ; swap in missile data
                        call    SpawnShipTypeA                      ; spawn the ship
                        ld      a,(MissileTargettingFlag)           ; Get target from computer
                        ld      (UBnKMissileTarget),a               ; load target Data
                        call    UnivSetPlayerMissile                ; .
                        ClearMissileTarget                          ; reset targetting
                        ret
.MissileMissFire:       ret ; TODO bing bong noise misfire message

; a = ship type, iyh = universe slot to create in
SpawnShipTypeA:         ld      iyl,a                               ; save ship type
                        MMUSelectShipBank1                          ; select bank 1
                        ld      a,iyh                               ; select unverse free slot
                        ld      b,iyl
                        call    SetSlotAToTypeB
                        MMUSelectUniverseA                          ; .
                        ld      a, iyl                              ; retrive ship type
                        ;call    SetSlotAToTypeB                    ; record in the lookup tables
                        call    GetShipBankId                       ; find actual memory location of data
                        MMUSelectShipBankA
                        ld      a,b                                 ; b = computed ship id for bank
                        call    CopyShipToUniverse
                        call    UnivSetSpawnPosition                ; set initial spawn position
                        call    UnivInitRuntime                     ; Clear runtime data before startup
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

;..................................................................................................................................
;..Process A ship..................................................................................................................
; Apply Damage b to ship based on shield value of a
; returns a with new shield value
ApplyDamage:            ClearCarryFlag
                        sbc     b
                        ret     nc                  ; no carry so was not negative
                        
.KilledShield:          neg                         ; over hit shield
                        ld      c,a                 ; save overhit in c
                        ld      a,(PlayerEnergy)    ; and apply it to player energy
                        ClearCarryFlag
                        sbc     c
                        jp      p,.DoneDamage       ; if result was 0 or more then completed damage
.KilledPlayer:          xor     a
.DoneDamage:            ld      (PlayerEnergy),a
                        xor     a                   ; shield is gone
                        ret

;..Update Universe Objects.........................................................................................................
UpdateUniverseObjects:  xor     a
                        ld      (SelectedUniverseSlot),a
.UpdateUniverseLoop:    ld      d,a                                             ; d is unaffected by GetTypeInSlotA
;.. If the slot is empty (FF) then skip this slot..................................................................................
                        call    GetTypeAtSlotA
                        ld      iyl,a                                           ; save type into iyl for later
                        cp      $FF
                        jp      z,.ProcessedUniverseSlot            
.UniverseObjectFound:   ld      a,d                                             ; Get back Universe slot as we want it
                        MMUSelectUniverseA                                      ; and we apply roll and pitch
                        call    ApplyMyRollAndPitch
                        call    ApplyShipRollAndPitch
;.. If its a space station then see if we are ready to dock........................................................................
.CheckExploding:        ld      a,(UBnKexplDsp)                                 ; is it destroyed
                        and     %10100000                                       ; or exploding
                        jp      nz,.ProcessedUniverseSlot                       ; then no action
.CheckIfClose:          ld      hl,(UBnKxlo)                                    ; chigh byte check or just too far away
                        ld      de,(UBnKylo)                                    ; .
                        ld      bc,(UBnKzlo)                                    ; .
                        or      h                                               ; .
                        or      d                                               ; .
                        or      b                                               ; .
                        jp      nz,.CollisionDone                                    ; .
.CheckLowBit7Close:     or      l                                               ; if bit 7 of low is set then still too far
                        or      e                                               ; .
                        or      c                                               ; .
                        ld      iyh,a                                           ; save it in case we need to check bit 6 in collision check
                        and     $80                                             ; .
                        jp      nz,.CollisionDone                                    ; .
.CheckIfDockable:       ld      a,(ShipTypeAddr)                                ; Now we have the correct bank
                        JumpIfANENusng  ShipTypeStation, .CollisionCheck        ; if its not a station so we don't test docking
.IsDockableAngryCheck:  JumpOnMemBitSet ShipNewBitsAddr, 4, .CollisionCheck     ; if it is angry then we dont test docking
.CheckHighNoseZ:        JumpIfMemLTNusng  UBnkrotmatNosevZ+1 , 214, .CollisionCheck ; get get high byte of rotmat this is the magic angle to be within 26 degrees +/-
.GetStationVector:      call    GetStationVectorToWork                          ; Normalise position into XX15 as in effect its a vector from out ship to it given we are always 0,0,0, returns with A holding vector z
                        JumpIfALTNusng  89, .CollisionCheck                     ; if the z axis <89 the we are not in the 22 degree angle,m if its negative then unsigned comparison will cater for this
.CheckAbsRoofXHi:       ld      a,(UBnkrotmatRoofvX+1)                          ; get abs roof vector high
                        and     SignMask8Bit                                    ; .
                        JumpIfALTNusng 80, .CollisionCheck                      ; note 80 decimal for 36.6 degrees horizontal
;.. Its passed all validation and we are docking...................................................................................
.WeAreDocking:          MMUSelectLayer1
                        ld        a,$6
                        call      l1_set_border
.EnterDockingBay:       ForceTransition ScreenDocking                           ;  Force transition 
                        ret                                                     ;  don't bother with other objects
                        ; So it is a candiate to test docking. Now we do the position and angle checks
.CollisionCheck:        ld      a,iyl
                        JumpIfAEqNusng ShipTypeStation, .HaveCollided           ; stations dont check bit 6
                        JumpIfAEqNusng ShipTypeMissile, .CollisionDone          ; Missile collisions are done in the tactics code
.VeryCloseCheck:        ld      a,iyh                                           ; bit 6 is still too far
                        and     %11000000                                       ; .
                        jr      nz,.CollisionDone                                    ; .
.ScoopableCheck:        ld      a,iyl                                           ; so if its not scoopable
                        JumpIfANENusng  ShipTypeScoopable, .HaveCollided        ; then its a collision
.ScoopsEquiped:         ld      a,(FuelScoop)                                   ; if there is no scoop then impact
                        JumpIfANENusng  EquipmentItemNbr updatotFitted, .HaveCollided   ; 
.ScoopRegion:           ld      a,(UBnKysgn)                                    ; if the y axis is negative then we are OK
                        JumpIfAIsZero   .HaveCollided                           ; else its a collision
.CollectedCargo:        call    ShipCargoType
.DoWeHaveCapacity:      ld      d,a                                             ; save cargotype
                        call    CanWeScoopCargoD
                        jr      c, .NoRoom
.CanScoop:              call    AddCargoTypeD
.NoRoom:                ClearSlotMem    SelectedUniverseSlot                    ; we only need to clear slot list as univ ship is now junk
                        jp      .CollisionDone
; ... Generic collision
.HaveCollided:          JumpIfMemLTNusng DELTA, 5, .SmallBump
.BigBump:               ld      a,(UBnKEnergy)                                  ; get energy level which gives us an approximate to size and health
                        SetCarryFlag
                        rla                                                     ; divide by 2 but also bring in carry so its 128 + energy / 2
                        ld      b,a
                        call    KillShip                                        ; mark ship as dead (if possible)
                        jp      .ApplyDamage
.SmallBump:             ld      a,(DELTA)                                       ; if out ship speed < 5 then set damage to 
                        ld      b,a
                        call    DamageShip                                      ; dent target too  TODO make damge totally proportional to speed
                        jp      .ApplyDamage
.ApplyDamage:           call    SetSpeedZero
                        ld      a,(UBnKzsgn)                                    ; front or back
                        and     $80
                        jr      nz,.HitRear
                        ld      a,(ForeShield)
                        call    ApplyDamage
                        ld      (ForeShield),a
                        jp      .CollisionDone
.HitRear:               ld      a,(AftShield)
                        call    ApplyDamage
                        ld      (AftShield),a
; Now check laser
.CollisionDone:         call    ShipInSights
                        jr      nc,.ProcessedUniverseSlot                        ; for laser and missile we can check once
                        ld      a,(CurrLaserPulseOnTime)
                        JumpIfAIsZero   .PlayerMissileLock                      ; if no pulse on time then check missile
                        ld      a,(CurrLaserDamage)
                        call    DamageShip
                        ld      a,(UBnKexplDsp)                                 ; is it destroyed
                        and     %10100000      
                        jp      nz,.ProcessedUniverseSlot                        ; can't lock on debris
; Now check missile lock
.PlayerMissileLock:     JumpIfMemNeNusng MissileTargettingFlag, StageMissileTargeting, .ProcessedUniverseSlot
.LockPlayerMissile:     ld      a,(SelectedUniverseSlot)                        ; set to locked and nto launchedd
                        LockMissileToA                                          ; .                        
.ProcessedUniverseSlot: 
.AreWeReadyForAI:       CallIfMemEqMemusng SelectedUniverseSlot, CurrentUniverseAI, UpdateShip
                        ld      a,(SelectedUniverseSlot)                        ; Move to next ship cycling if need be to 0
                        inc     a                                               ; .
                        JumpIfAGTENusng   UniverseSlotListSize, .UpdateAICounter    ; .
                        ld      (SelectedUniverseSlot),a
                        jp      .UpdateUniverseLoop
.UpdateAICounter:       ld      a,(CurrentUniverseAI)
                        inc     a
                        cp      12
                        jr      c,.IterateAI
                        xor     a
.IterateAI:             ld      (CurrentUniverseAI),a
.CheckIfStationAngry:   ReturnIfMemFalse  SetStationAngryFlag
.SetStationAngryIfPoss: ReturnIfMemNeNusng UniverseSlotList, ShipTypeStation
                        MMUSelectUniverseN 0
                        call    SetShipHostile
                        SetMemFalse    SetStationAngryFlag
                        ret


;..................................................................................................................................                        
;; TODODrawForwardSun:         MMUSelectSun
;; TODO                        ld      a,(SunKShipType)
;; TODO.ProcessBody:           cp      129
;; TODO                        jr      nz,.ProcessPlanet
;; TODO.ProcessSun:            call    ProcessSun
;; TODO
;; TODOProcessSun:             call    CheckSunDistance
;; TODO
;; TODO                        ret
;; TODO.ProcessPlanet:         call    ProcessPlanet
;; TODO                        ret                        
;..................................................................................................................................                        
DrawForwardShips:       xor     a
.DrawShipLoop:          ld      (CurrentShipUniv),a
                        call    GetTypeAtSlotA
                        cp      $FF
                        jr      z,.ProcessedDrawShip
; Add in a fast check for ship behind to process nodes and if behind jump to processed Draw ship
.SelectShipToDraw:       ld      a,(CurrentShipUniv)
                        MMUSelectUniverseA
.CheckIfExploding:      JumpOnMemBitMaskClear   UBnkaiatkecm, ShipExploding, .ProcessUnivShip
.ShipIsExploding        ld      a,(ShipExplosionDuration)   ; Reduce explosion counter
                        dec     a                           ; on zero we just exit which means main
                        ld      (ShipExplosionDuration),a   ; loop can remove it from the slot list
                        jp      nz,.ProcessUnivShip         ; if its not zero we can continue
.ClearDebris:           ClearSlotMem CurrentShipUniv
                        jp      ProcessedDrawShip
                        ; Need check for exploding here
.ProcessUnivShip:       call    ProcessShip          ; TODFO TUNE THIS   ;; call    ProcessUnivShip
; Debris still appears on radar                        
.UpdateRadar: 
;;;Does nothing                       ld      a,BankFrontView
;;;Does nothing                       MMUSelectScreenA
;;;Does nothing         ld      a,(CurrentShipUniv)
;;;Does nothing         MMUSelectUniverseA
                        
                        CallIfMemTrue ConsoleRedrawFlag,UpdateScannerShip ; Always update ship positions                        
.ProcessedDrawShip:     ld      a,(CurrentShipUniv)
                        inc     a
                        JumpIfALTNusng   UniverseSlotListSize, .DrawShipLoop
.DrawSunCompass:        MMUSelectSun
                        call    UpdateCompassSun                ; Always update the sun position
                        call    UpdateScannerSun                ; Always attempt to put the sun on the scanner 
.CheckPlanetCompass:    JumpIfMemFalse SpaceStationSafeZone, .DrawStationCompass
.DrawPlanetCompass:     MMUSelectPlanet
                        call    UpdateCompassPlanet
                        call    UpdateScannerPlanet
                        ret
.DrawStationCompass:

                        ret    
;..................................................................................................................................
CurrentShipUniv:        DB      0

;;;ProcessUnivShip:        call    CheckVisible               ; Will check for negative Z and skip (how do we deal with read and side views? perhaps minsky transformation handles that?)
;;;                        ret     c
;;;                        ld      a,(UbnkDrawAsDot)
;;;                        and     a
;;;                        jr      z,.CarryOnWithDraw
;;;.itsJustADot:           ld      bc,(UBnkNodeArray)          ; if its at dot range
;;;                        ld      a,$FF                       ; just draw a pixel
;;;                        MMUSelectLayer2                     ; then go to update radar
;;;                        call    l2_plot_pixel               ; 
;;;                        ClearCarryFlag
;;;                        ret
;;;.ProcessShipNodes:      call    ProcessShip
;;;
;;;call    ProcessNodes ; it hink here we need the star and planet special cases
;;;.DrawShip:              call    CullV2				        ; culling but over aggressive backface assumes all 0 up front TOFIX
;;;                        call    PrepLines                   ; LL72, process lines and clip, ciorrectly processing face visibility now
;;;                        ld      a,(CurrentShipUniv)
;;;                        MMUSelectUniverseA
;;;                        call   DrawLines
;;;                        ClearCarryFlag
;;;                        ret                        
                        
    
TestForNextShip:        ld      a,c_Pressed_Quit
                        call    is_key_pressed
                        ret     nz
                        ld      a,(currentDemoShip)
                        inc     a
                        cp      44
                        jr      nz,.TestOK
                        xor     a
.TestOK:                ld      (currentDemoShip),a
                        call    ClearUnivSlotList
                        ld      a,(currentDemoShip)
                        ld      b,a
                        xor     a
                        call    SetSlotAToTypeB
                        MMUSelectUniverseN 2
                        call    ResetUBnkData                         ; call the routine in the paged in bank, each universe bank will hold a code copy local to it
                        ld      a,(currentDemoShip)
                        MMUSelectShipBank1
                        call    GetShipBankId
                        MMUSelectShipBankA
                        ld      a,b
                        call    CopyShipToUniverse
                        call    SetInitialShipPosition
                        call    DEBUGSETNODES                        
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
NeedAMessageQueue:

UpdateCountdownNumber:  ld		a,(OuterHyperCount)
                        ld		de,Hyp_counter
                        ld	c, -100
                        call	.Num1
                        ld	c,-10
                        call	.Num1
                        ld	c,-1
.Num1:	                ld	b,'0'-1
.Num2:	                inc		b
                        add		a,c
                        jr		c,.Num2
                        sub 	c
                        push	bc
                        push	af
                        ld		a,c
                        cp		-1
                        ld		a,b
                        ld		(de),a
                        inc		de
                        pop		af
                        pop		bc
                        ret 

;----------------------------------------------------------------------------------------------------------------------------------
Hyp_message             DB "To:"
Hyp_to                  DS 32
Hyp_space1              DB " "
Hyp_dist_amount         DB "0.0"
Hyp_decimal             DB "."
Hyp_fraction            DB "0"
Hyp_dis_ly              DB " LY",0
Hyp_charging            DB "Charging:"
Hyp_counter             DB "000",0
Hyp_centeredTarget      DS 32
Hyp_centeredEol         DB 0
Hyp_bufferpadding       DS 32   ; just in case we get a buffer ovverun. shoudl never get beyond 32 chars
Hyp_centeredCharging    DS 32
Hyp_centeredEol2        DB 0
Hyp_bufferpadding2      DS 32   ; just in case we get a buffer ovverun. shoudl never get beyond 32 chars


;DisplayTargetAndRange
;DisplayCountDownNumber
;----------------------------------------------------------------------------------------------------------------------------------
TestPauseMode:          ld      a,(GamePaused)
                        cp      0
                        jr      nz,.TestForResume
.CheckViewMode:         ld      a,(ScreenIndex)                     ; we can only pause if not on screen view
                        ReturnIfAGTENusng       ScreenFront
.CheckPauseKey:         ld      a,c_Pressed_Freeze
                        call    is_key_pressed
                        ret     nz
.PausePressed:          SetAFalse                                  ; doesn't really matter if we were in pause already as resume is a different key
                        ld      (GamePaused),a
                        ret
.TestForResume:         ld      a,c_Pressed_Resume                  ; In pause loop so we can check for resume key
                        call    is_key_pressed
                        ret     nz
.ResumePressed:         xor     a             
                        ld      (GamePaused),a                      ; Resume pressed to reset pause state
                        ret

TestQuit:               ld      a,c_Pressed_Quit
                        call    is_key_pressed
                        ret
currentDemoShip:        DB      13;$12 ; 13 - corirollis 


;----------------------------------------------------------------------------------------------------------------------------------
UpdateShip:             ;  call    DEBUGSETNODES ;       call    DEBUGSETPOS
                        ld      hl,TidyCounter
                        dec     (hl)
                        ret     nz
                        ld      a,16
                        ld      (TidyCounter),a
                        ; call    TIDY TIDY IS BROKEN
                       ; add AI in here too
                        ret


GetStationVectorToWork: ld      hl,UBnKxlo
                        ld      de,varVector9ByteWork
                        ldi
                        ldi
                        ldi
                        ldi
                        ldi
                        ldi
                        ldi
                        ldi
                        ldi
.CalcNormalToXX15:      ld      hl, (varVector9ByteWork)  ; X
                        ld      de, (varVector9ByteWork+3); Y
                        ld      bc, (varVector9ByteWork+6); Z
                        ld      a,l
                        or      e
                        or      c
                        or      1
                        ld      ixl,a                   ; or all bytes and with 1 so we have at least a 1
                        ld      a,h
                        or      d
                        or      b                       ; or all high bytes but don't worry about 1 as its sorted on low bytes
.MulBy2Loop:            push    bc
                        ld      b,ixl
                        sla     b                       ; Shift ixl left 
                        ld      ixl,b
                        pop     bc
                        rl      a                       ; roll into a
                        jr      c,.TA2                  ; if bit rolled out of rl a then we can't shift any more to the left
                        ShiftHLLeft1                    ; Shift Left X
                        ShiftDELeft1                    ; Shift Left Y
                        ShiftBCLeft1                    ; Shift Left Z
                        jr      .MulBy2Loop              ; no need to do jr nc as the first check looks for high bits across all X Y and Z
.TA2:                   ld      a,(varVector9ByteWork+2); x sign
                        srl     h
                        or      h
                        ld      (XX15VecX),a         ; note this is now a signed highbyte
                        ld      a,(varVector9ByteWork+5); y sign
                        srl     d
                        or      d
                        ld      (XX15VecY),a         ; note this is now a signed highbyte                        
                        ld      a,(varVector9ByteWork+8); y sign
                        srl     b
                        or      b
                        ld      (XX15VecZ),a         ; note this is now a signed highbyte                        
                        call    normaliseXX1596fast 
                        ret                          ; will return with a holding Vector Z

TidyCounter             DB  0

            INCLUDE "./debugMatrices.asm"


;TODO Optimisation
; Need this table to handle differnet events 
; 1-main loop update - just general updates specfic to that screen that are not galaxy or stars, e.g. update heat, console
; cursor key, joystick press
; cursor key, joystick press
; non cursor keys presses
;
; First byte is now docked flag
; 
; Padded to 8 bytes to allow a * 8 for addressing    
; Byte 0   - Docked flag  : 0 = not applicable (always read), 1 = only whilst docked, 2 = only when not docked, 3 = No keypress allowed
; Byte 1   - Screen Id
; Byte 2,3 - address of keypress table
; Byte 4   - Bank with Display code
; Byte 5,6 - Function for display
; Byte 7,8 - Main loop update routine
; Byte 9   - Draw stars Y/N ; also are we in an external view that can have guns?
; byte 10  - Input Blocker (set to 1 will not allow keyboard screen change until flagged, used by transition screens and pause menus)
; byte 11  - Double Buffering 0 = no, 1 = yes
; byte 12,13  - cursor key input routine
; byte 14  - HyperspaceBlock - can not select this screen if in hyperpace - 00 can , 01 can not
; byte 15    padding at the momnent (should add in an "AI enabled flag" for optimistation, hold previous value and on change create ships
;
;                          0    1                 2                              3                               4                    5                            6                              7                     8                       9   10  11  12                          13                          14  15    
ScreenKeyMap:           DB 0,   ScreenLocal     , low addr_Pressed_LocalChart,   high addr_Pressed_LocalChart,   BankMenuShrCht,      low draw_local_chart_menu,   high draw_local_chart_menu,    $00,                  $00,                    $00,$00,$00,low local_chart_cursors,    high local_chart_cursors,   $01,$00;low loop_local_chart_menu,   high loop_local_chart_menu
ScreenKeyGalactic:      DB 0,   ScreenGalactic  , low addr_Pressed_GalacticChrt, high addr_Pressed_GalacticChrt, BankMenuGalCht,      low draw_galactic_chart_menu,high draw_galactic_chart_menu, low loop_gc_menu,     high loop_gc_menu,      $00,$00,$00,low galctic_chart_cursors,  high galctic_chart_cursors, $01,$00
                        DB 1,   ScreenMarket    , low addr_Pressed_MarketPrices, high addr_Pressed_MarketPrices, BankMenuMarket,      low draw_market_prices_menu, high draw_market_prices_menu,  low loop_market_menu, high loop_market_menu,  $00,$00,$00,$00,                        $00,                        $01,$00
                        DB 2,   ScreenMarketDsp , low addr_Pressed_MarketPrices, high addr_Pressed_MarketPrices, BankMenuMarket,      low draw_market_prices_menu, high draw_market_prices_menu,  $00,                  $00,                    $00,$00,$00,$00,                        $00,                        $01,$00
ScreenCmdr:             DB 0,   ScreenStatus    , low addr_Pressed_Status,       high addr_Pressed_Status,       BankMenuStatus,      low draw_status_menu,        high draw_status_menu,         low loop_STAT_menu,  high loop_STAT_menu,     $00,$00,$00,$00,                        $00,                        $01,$00
                        DB 0,   ScreenInvent    , low addr_Pressed_Inventory,    high addr_Pressed_Inventory,    BankMenuInvent,      low draw_inventory_menu,     high draw_inventory_menu,      $00,                  $00,                    $00,$00,$00,$00,                        $00,                        $01,$00
                        DB 0,   ScreenPlanet    , low addr_Pressed_PlanetData,   high addr_Pressed_PlanetData,   BankMenuSystem,      low draw_system_data_menu,   high draw_system_data_menu,    $00,                  $00,                    $00,$00,$00,$00,                        $00,                        $01,$00
                        DB 1,   ScreenEquip     , low addr_Pressed_Equip,        high addr_Pressed_Equip,        BankMenuEquipS,      low draw_eqshp_menu,         high draw_eqshp_menu,          low loop_eqshp_menu,  high loop_eqshp_menu,   $00,$00,$00,$00,                        $00,                        $01,$00
                        DB 1,   ScreenLaunch    , low addr_Pressed_Launch,       high addr_Pressed_Launch,       BankLaunchShip,      low draw_launch_ship,        high draw_launch_ship,         low loop_launch_ship, high loop_launch_ship,  $00,$01,$01,$00,                        $00,                        $01,$00
ScreenKeyFront:         DB 2,   ScreenFront     , low addr_Pressed_Front,        high addr_Pressed_Front,        BankFrontView,       low draw_front_view,         high draw_front_view,          low update_front_view,high update_front_view, $01,$00,$01,low input_front_view,      high input_front_view,       $00,$00
                        DB 2,   ScreenAft       , low addr_Pressed_Front,        high addr_Pressed_Front,        BankFrontView,       low draw_front_view,         high draw_front_view,          $00,                  $00,                    $01,$00,$01,low input_front_view,      high input_front_view,       $00,$00
                        DB 2,   ScreenLeft      , low addr_Pressed_Front,        high addr_Pressed_Front,        BankFrontView,       low draw_front_view,         high draw_front_view,          $00,                  $00,                    $01,$00,$01,low input_front_view,      high input_front_view,       $00,$00
                        DB 2,   ScreenRight     , low addr_Pressed_Front,        high addr_Pressed_Front,        BankFrontView,       low draw_front_view,         high draw_front_view,          $00,                  $00,                    $01,$00,$01,low input_front_view,      high input_front_view,       $00,$00
                        DB 3,   ScreenDocking   , $FF,                           $FF,                            BankLaunchShip,      low draw_docking_ship,       high draw_docking_ship,        low loop_docking_ship,high loop_docking_ship, $00,$01,$01,$00,                        $00,                        $01,$00
                        DB 1,   ScreenHyperspace, $FF,                           $FF,                            BankFrontView,       low draw_hyperspace,         high draw_hyperspace,          low loop_hyperspace,  high loop_hyperspace,   $00,$01,$01,$00

;               DB low addr_Pressed_Aft,          high addr_Pressed_Aft,          BankMenuGalCht,      low SelectFrontView,         high SelectFrontView,          $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;               DB low addr_Pressed_Left,         high addr_Pressed_Left,         BankMenuGalCht,      low SelectFrontView,         high SelectFrontView,          $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;               DB low addr_Pressed_Right,        high addr_Pressed_Right,        BankMenuGalCht,      low SelectFrontView,         high SelectFrontView,          $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
ScreenMapRow        EQU ScreenKeyGalactic - ScreenKeyMap
ScreenMapLen        EQU ($ - ScreenKeyMap) / ScreenMapRow
ScreenViewsStart    EQU (ScreenKeyFront - ScreenKeyMap)/ScreenMapRow
ScreenTransitionForced  DB $FF    
    INCLUDE "./GameEngine/resetUniverse.asm"


;----------------------------------------------------------------------------------------------------------------------------------
LaunchedFromStation:    MMUSelectSun
                        call    CreateSunLaunched                   ; create the local sun and set position based on seed
                        MMUSelectPlanet
                        call    CreatePlanetLaunched
                        call    ClearUnivSlotList
                        call    SetSlot0ToSpaceStation              ; set slot 1 to space station
                        MMUSelectUniverseN 0                        ; Prep Target universe
                        MMUSelectShipBank1                          ; Bank in the ship model code
                        call    UnivInitRuntime                     ; Zerp ship runtime data
                        ld      a,CoriloisStation
                        call    GetShipBankId             
                        MMUSelectShipBankA                          ; Select the correct bank found
                        ld      a,b                                 ; Select the correct ship
                        call    CopyShipToUniverse
.BuiltStation:          call    ResetStationLaunch
.NowInFlight:           xor     a
                        ld      (DockedFlag),a
                        ForceTransition ScreenFront
                        call    ResetPlayerShip
                        ret
    
InitialiseCommander:    ld      a,(ScreenCmdr+1)
                        ld      ix,ScreenCmdr
                        jp      SetScreenAIX
                
InitialiseFrontView:    ld      a,(ScreenKeyFront+1)
                        ld      ix,ScreenKeyFront
                        jp      SetScreenAIX
; false ret here as we get it free from jp    

;----------------------------------------------------------------------------------------------------------------------------------
SetScreenAIX:           ld      (ScreenIndex),a                 ; Set screen index to a
                        ClearForceTransition                    ; In case it was called by a brute force change in an update loop
                        ld      (ScreenChanged),a               ; Set screen changed to FF                       
.IsItAViewPort:         ld      a,(ix+9)                        ; Screen Map Byte 9  - Draw stars Y/N and also guns present
                        ld      (CheckIfViewUpdate+1),a         ; Set flag to determine if we are on an exterior view
                        JumpIfAIsZero .NotViewPort              ;
                        ld      a,(ix+1)                        ; get screen view number
                        sub     ScreenFront                     ; Now a = screen number 0 = front, 1 = aft, 2 = left 3 = right
                        MMUSelectCommander                      ; Load view laser to current
                        call    LoadLaserToCurrent              ;
.NotViewPort:           ld      a,(ix+4)                        ; Screen Map Byte 4   - Bank with Display code
                        ld      (ScreenLoopBank+1),a            ; setup loop            
                        ld      (HandleBankSelect+1),a          ; setup cursor keys
                        MMUSelectScreenA
                        ld      a,(ix+5)                        ; Screen Map Byte 5 - Function for display
                        ld      (ScreenUpdateAddr+1),a
                        ld      a,(ix+6)                        ; Screen Map Byte 6 - Function for display
                        ld      (ScreenUpdateAddr+2),a
                        ld      a,(ix+7)                        ; Screen Map Byte 7 - Main loop update routine
                        ld      (ScreenLoopJP+1),a
                        ld      a,(ix+8)                        ; Screen Map Byte 8 - Main loop update routine
                        ld      (ScreenLoopJP+2),a   
                        ld      a,(ix+10)                       ; Screen Map Byte 10  - Input Blocker (set to 1 will not allow keyboard screen change until flagged, used by transition screens and pause menus)
                        ld      (InputBlockerCheck+1),a          ; Set flag to block transitions as needed e.g. launch screen    
                        ld      a,(ix+11)                       ; Screen Map Byte 11  - Double Buffering 0 = no, 1 = yes
                        ld      (DoubleBufferCheck+1),a
                        ld      a,(ix+12)
                        ld      (CallCursorRoutine+1),a
                        ld      a,(ix+13)
                        ld      (CallCursorRoutine+2),a
                      
ScreenUpdateAddr:       jp      $0000                          ; We can just drop out now and also get a free ret from caller
;----------------------------------------------------------------------------------------------------------------------------------                    
ViewKeyTest:            ld      a,(ScreenIndex)
                        ld      c,a
                        ld      b,ScreenMapLen                  ; For now until add screens are added
                        ld      ix,ScreenKeyMap
                        ld      hl,(InnerHyperCount)
                        ld      a,h
                        or      l
                        ld      iyh,a
ViewScanLoop:           ld      a,iyh
.HyperspaceCountdown:   and     a
                        jr      z,.DockedFlag
                        ld      a,(ix+14)
                        cp      1
                        jp      z,NotReadNextKey
.DockedFlag:            ld      a,(ix+0)                        ; Screen Map Byte 0 Docked flag 
; 0 = not applicable (always read), 1 = only whilst docked, 2 = only when not docked, 3 = No keypress allowed
                        cp      3                               ; if not selectable then don't scan this (becuase its a transition screen)
                        jr      z,NotReadNextKey                ; 
                        cp      0                               ; if itr a always read skip docking check
                        jr      z,.NoDocCheck
.DocCheck:              ld      d,a
                        ld      a,(DockedFlag)
                        cp      0                               ; if we are docked
                        jr      z,.NotDockedCheck
.DockedCheck:           ld      a,d
                        cp      1                               ; if we are docked and its a dock only then scan
                        jr      nz,NotReadNextKey
                        jr      .NoDocCheck
.NotDockedCheck:        ld      a,d
                        cp      2                               ; if we are not docked and its a flight only then scan
                        jr      nz,NotReadNextKey
.NoDocCheck:            ld      a,(ix+1)                        ; Screen Map Byte 1 Screen Id
                        cp      c                               ; is the index the current screen, if so skip the scan
                        ld      e,a
                        jr      z,NotReadNextKey   
                        ld      a,(ix+2)                        ; Screen Map Byte 2 - address of keypress table
                        cp      $FF                             ; if upper byte is FF then we do not respond
                        jr      z,NotReadNextKey
                        ld      (ReadKeyAddr+1),a               ; Poke address into the ld hl,(....) below
                        ld      a,(ix+3)                        ; Screen Map Byte 3 - address of keypress table
                        ld      (ReadKeyAddr+2),a
ReadKeyAddr:            ld      hl,($0000)                      ; address is entry in the pointer table to the actual keypress
                        ld      a,(hl)                          ; now fetch the actual keypress
                        JumpIfAIsZero NotReadNextKey
.ValidScreenChange:     ld      a,e
                        jp      SetScreenAIX
;--- CODE WILL NOT FALL TO HERE ---
NotReadNextKey:         ld      de,ScreenMapRow
                        add     ix,de                           ; we have only processed 3 of 8 bytes at here
                        djnz    ViewScanLoop
                        ret

SetInitialShipPosition: ld      hl,$0000
                        ld      (UBnKxlo),hl
                        ld      hl,$0000
                        ld      (UBnKylo),hl
                        ld      hl,$03B4
                        ld      (UBnKzlo),hl
                        xor     a
                        ld      (UBnKxsgn),a
                        ld      (UBnKysgn),a
                        ld      (UBnKzsgn),a
;    call    Reset TODO
                        call	InitialiseOrientation            ;#00;
                        ld      a,1
                        ld      (DELTA),a
                        ld      hl,4
                        ld      (DELTA4),hl
                        ret    

; Checks to see if current ship swapped in is in our sights
; we don;t need to deal with planets or sun as they have their own memory bank
ShipInSights:           ClearCarryFlag                          ; Carry clear no hit
                        ReturnIfMemIsNegative UBnKzsgn
                        ld      a,(UBnKexplDsp)                 ; get exploding flag and or with x and y high
                        ld      hl,(UBnKxlo)                    ; do 16 bit fetch as we will often need both bytes
                        ld      bc,(UBnKylo)                    ; .
                        or      h
                        or      b
                        ret     nz                              ; if exploding or x hi or y hi are set then its nto targetable
                        ld      a,l                             ; hl =xlo ^ 2
                        DEEquSquareA                            ; .
                        ld      hl,de                           ; .
                        ld      a,c                             ; de = de = ylo ^ 2
                        DEEquSquareA                            ; .
                        add     hl,de                           ; hl = xlo ^ 2 + ylo ^ 2
                        ret     c                               ; if there was a carry then out of line of sight
                        ld      de,(MissileLockLoAddr)          ; get targettable area ^ 2 from blueprint copy
                        cpHLDE                                  ; now compare x^2 + y^2 to target area
                        jr      z,.EdgeHit                      ; if its an edge hit then we need to set carry
                        ret                                     ; if its < area then its a hit and carry is set, we will not work on = 
.EdgeHit:               SetCarryFlag                            ; its an edge hit then we need to set carry
                        ret
                        

            INCLUDE "./Views/ConsoleDrawing.asm"
            INCLUDE "./Tables/message_queue.asm"
            INCLUDE "./Tables/LaserStatsTable.asm"
            INCLUDE "./Tables/ShipClassTable.asm"

SeedGalaxy0:            xor     a
                        MMUSelectGalaxyA
                        ld      ix,galaxy_data
                        xor		a
                        ld		(XSAV),a
                        call    copy_galaxy_to_system
SeedGalaxy0Loop:        push    ix
                        pop     de
                        ld      hl,SystemSeed
                        call    copy_seed
                        push    ix
                        pop     hl
                        add     hl,8
                        push    hl
                        pop     ix
                        call    next_system_seed
                        ld		a,(XSAV)
                        dec		a
                        cp		0
                        ret		z
                        ld		(XSAV),a
                        jr      nz,SeedGalaxy0Loop
                        ret



            
    ;include "./ModelRender/testdrawing.asm"
    include "./Menus/AttractMode.asm"

    include "./Maths/Utilities/XX12EquNodeDotOrientation.asm"
    include "./ModelRender/CopyXX12ToXX15.asm"	
    include "./ModelRender/CopyXX15ToXX12.asm"
    include "./Maths/Utilities/ScaleXX16Matrix197.asm"
		    
    include "./Universe/StarDust/StarRoutines.asm"
;    include "Universe/move_object-MVEIT.asm"
;    include "./ModelRender/draw_object.asm"
;    include "./ModelRender/draw_ship_point.asm"
;    include "./ModelRender/drawforwards-LL17.asm"
;    include "./ModelRender/drawforwards-LL17.asm"
    
    INCLUDE	"./Hardware/memfill_dma.asm"
    INCLUDE	"./Hardware/memcopy_dma.asm"
XX12PVarQ			DW 0
XX12PVarR			DW 0
XX12PVarS			DW 0
XX12PVarResult1		DW 0
XX12PVarResult2		DW 0
XX12PVarResult3		DW 0
XX12PVarSign2		DB 0
XX12PVarSign1		DB 0								; Note reversed so BC can do a little endian fetch
XX12PVarSign3		DB 0
    INCLUDE "./Hardware/keyboard.asm"
    
    INCLUDE "./Variables/constant_equates.asm"
    INCLUDE "./Variables/general_variables.asm"
    INCLUDE "./Variables/general_variablesRoutines.asm"

    INCLUDE "./Variables/UniverseSlotRoutines.asm"

    INCLUDE "./Variables/EquipmentVariables.asm"
    
    INCLUDE "./Variables/random_number.asm"
    INCLUDE "./Variables/galaxy_seed.asm"
    INCLUDE "./Tables/text_tables.asm"
    INCLUDE "./Tables/dictionary.asm"
    INCLUDE "./Tables/name_digrams.asm"
;INCLUDE "Tables/inwk_table.asm" This is no longer needed as we will write to univer object bank

; Include all maths libraries to test assembly
    
    INCLUDE "./Maths/addhldesigned.asm"
    INCLUDE "./Maths/asm_add.asm"
    INCLUDE "./Maths/Utilities/AddDEToCash.asm"
    INCLUDE "./Maths/DIVD3B2.asm"
    INCLUDE "./Maths/multiply.asm"
    INCLUDE "./Maths/asm_square.asm"
    INCLUDE "./Maths/asm_sqrt.asm"
    INCLUDE "./Maths/asm_divide.asm"
    INCLUDE "./Maths/asm_unitvector.asm"
    INCLUDE "./Maths/compare16.asm"
    INCLUDE "./Maths/negate16.asm"
    INCLUDE "./Maths/normalise96.asm"
    INCLUDE "./Maths/binary_to_decimal.asm"
    include "./Maths/ADDHLDESignBC.asm"    
;INCLUDE "badd_ll38.asm"
;;INCLUDE "XX12equXX15byXX16.asm"
    INCLUDE "./Maths/Utilities/AequAdivQmul96-TIS2.asm"
    INCLUDE "./Maths/Utilities/AequAmulQdiv256-FMLTU.asm"
    INCLUDE "./Maths/Utilities/PRequSpeedDivZZdiv8-DV42-DV42IYH.asm"
    INCLUDE "./Maths/Utilities/AequDmulEdiv256usgn-DEFMUTL.asm"
;INCLUDE "AP2equAPmulQunsgEorP-MLTU2.asm"
;INCLUDE "APequPmulQUnsg-MULTU.asm"
;INCLUDE "APequPmulX-MU11.asm"
    INCLUDE "./Maths/Utilities/APequQmulA-MULT1.asm"
    INCLUDE "./Maths/Utilities/badd_ll38.asm"
    INCLUDE "./Maths/Utilities/moveship4-MVS4.asm"
;INCLUDE "MoveShip5-MVS5.asm"
;INCLUDE "PAequAmulQusgn-MLU2.asm"
;INCLUDE "PAequDustYIdxYmulQ-MLU1.asm"
;INCLUDE "PlanetP12addInwkX-MVT6.asm"
    INCLUDE "./Maths/Utilities/RequAmul256divQ-BFRDIV.asm"
    INCLUDE "./Maths/Utilities/RequAdivQ-LL61.asm"
;    INCLUDE "./Maths/Utilities/RSequABSrs-LL129.asm"
    INCLUDE "./Maths/Utilities/RSequQmulA-MULT12.asm"
;INCLUDE "SwapRotmapXY-PUS1.asm"
    INCLUDE "./Maths/Utilities/tidy.asm"
    INCLUDE "./Maths/Utilities/LL28AequAmul256DivD.asm"    
    INCLUDE "./Maths/Utilities/XAequMinusXAPplusRSdiv96-TIS1.asm"
;INCLUDE "XAequQmuilAaddRS-MAD-ADD.asm"
;INCLUDE "XHiYLoequPA-gc3.asm"
;INCLUDE "XHiYLoequPmulAmul4-gc2.asm"
;INCLUDE "XLoYHiequPmulQmul4-gcash.asm"
;INCLUDE "XX12equXX15byXX16-LL51.asm"
  ;  INCLUDE "./Maths/Utilities/XYeqyx1loSmulMdiv256-Ll120-LL123.asm"

    INCLUDE "./Tactics.asm"
    INCLUDE "./Hardware/drive_access.asm"

    INCLUDE "./Menus/common_menu.asm"
; ARCHIVED INCLUDE "Menus/draw_fuel_and_crosshair.asm"
;INCLUDE "./title_page.asm"

; Blocks dependent on variables in Universe Banks
; Bank 49
;    SEG RESETUNIVSEG
;seg     CODE_SEG,       4:              $0000,       $8000                 ; flat address
;seg     RESETUNIVSEG,   BankResetUniv:  StartOfBank, ResetUniverseAddr      

;	ORG ResetUniverseAddr
;INCLUDE "./GameEngine/resetUniverse.asm"
; Bank 50
         


    SLOT    MenuShrChtAddr
    PAGE    BankMenuShrCht
	ORG     MenuShrChtAddr,BankMenuShrCht
    INCLUDE "./Menus/short_range_chart_menu.asm"
; Bank 51

    SLOT    MenuGalChtAddr
    PAGE    BankMenuGalCht
	ORG     MenuGalChtAddr
    INCLUDE "./Menus//galactic_chart_menu.asm"
; Bank 52

    SLOT    MenuInventAddr
    PAGE    BankMenuInvent
	ORG     MenuInventAddr
    INCLUDE "./Menus/inventory_menu.asm"        

; Bank 53

    SLOT    MenuSystemAddr
    PAGE    BankMenuSystem
	ORG     MenuSystemAddr
    INCLUDE "./Menus/system_data_menu.asm"

; Bank 54	

    SLOT    MenuMarketAddr
    PAGE    BankMenuMarket
    ORG     MenuMarketAddr
    INCLUDE "./Menus/market_prices_menu.asm"

; Bank 66	

    SLOT    DispMarketAddr
    PAGE    BankDispMarket
    ORG     DispMarketAddr
    INCLUDE "./Menus/market_prices_disp.asm"

; Bank 55

    SLOT    StockTableAddr
    PAGE    BankStockTable
    ORG     StockTableAddr  
    INCLUDE "./Tables/stock_table.asm"

; Bank 57

    SLOT    LAYER2Addr
    PAGE    BankLAYER2
    ORG     LAYER2Addr
     
    INCLUDE "./Layer2Graphics/layer2_bank_select.asm"
    INCLUDE "./Layer2Graphics/layer2_cls.asm"
    INCLUDE "./Layer2Graphics/layer2_initialise.asm"
    INCLUDE "./Layer2Graphics/l2_flip_buffers.asm"
    INCLUDE "./Layer2Graphics/layer2_plot_pixel.asm"
    INCLUDE "./Layer2Graphics/layer2_print_character.asm"
    INCLUDE "./Layer2Graphics/layer2_draw_box.asm"
    INCLUDE "./Layer2Graphics/asm_l2_plot_horizontal.asm"
    INCLUDE "./Layer2Graphics/asm_l2_plot_vertical.asm"
    INCLUDE "./Layer2Graphics/layer2_plot_diagonal.asm"
    INCLUDE "./Layer2Graphics/asm_l2_plot_triangle.asm"
    INCLUDE "./Layer2Graphics/asm_l2_fill_triangle.asm"
    INCLUDE "./Layer2Graphics/layer2_plot_circle.asm"
    INCLUDE "./Layer2Graphics/layer2_plot_circle_fill.asm"
    INCLUDE "./Layer2Graphics/l2_draw_any_line.asm"
    INCLUDE "./Layer2Graphics/clearLines-LL155.asm"
    INCLUDE "./Layer2Graphics/l2_draw_line_v2.asm"
; Bank 56  ------------------------------------------------------------------------------------------------------------------------
    SLOT    CommanderAddr
    PAGE    BankCommander
    ORG     CommanderAddr, BankCommander
    INCLUDE "./Commander/commanderData.asm"
    INCLUDE "./Commander/zero_player_cargo.asm"
; Bank 58  ------------------------------------------------------------------------------------------------------------------------
    SLOT    LAYER1Addr
    PAGE    BankLAYER1
    ORG     LAYER1Addr, BankLAYER1

    INCLUDE "./Layer1Graphics/layer1_attr_utils.asm"
    INCLUDE "./Layer1Graphics/layer1_cls.asm"
    INCLUDE "./Layer1Graphics/layer1_print_at.asm"
; Bank 59  ------------------------------------------------------------------------------------------------------------------------
; In the first copy of the banks the "Non number" labels exist. They will map directly in other banks
; as the is aligned and data tables are after that
; need to make the ship index tables same size in each to simplify further    
    SLOT    ShipModelsAddr
    PAGE    BankShipModels1
	ORG     ShipModelsAddr, BankShipModels1
    INCLUDE "./Data/ShipModelMacros.asm"
    INCLUDE "./Data/ShipBank1Label.asm"
GetShipBankId:
GetShipBank1Id:        MGetShipBankId ShipBankTable
CopyVertsToUniv:
CopyVertsToUniv1:       McopyVertsToUniverse
CopyEdgesToUniv:
CopyEdgesToUniv1:       McopyEdgesToUniverse
CopyNormsToUniv:        
CopyNormsToUniv1:       McopyNormsToUniverse
ShipBankTable:
ShipBankTable1:         MShipBankTable
CopyShipToUniverse:
CopyShipToUniverse1     MCopyShipToUniverse     BankShipModels1
CopyBodyToUniverse:
CopyBodyToUniverse1:    MCopyBodyToUniverse     CopyShipToUniverse1
    INCLUDE "./Data/ShipModelMetaData1.asm"
; Bank 67  ------------------------------------------------------------------------------------------------------------------------
    SLOT    ShipModelsAddr
    PAGE    BankShipModels2
	ORG     ShipModelsAddr, BankShipModels2

    INCLUDE "./Data/ShipBank2Label.asm"
GetShipBank2Id:         MGetShipBankId ShipBankTable2                        
CopyVertsToUniv2:       McopyVertsToUniverse
CopyEdgesToUniv2:       McopyEdgesToUniverse
CopyNormsToUniv2:       McopyNormsToUniverse
ShipBankTable2:         MShipBankTable
CopyShipToUniverse2     MCopyShipToUniverse     BankShipModels2
CopyBodyToUniverse2:    MCopyBodyToUniverse     CopyShipToUniverse2

    INCLUDE "./Data/ShipModelMetaData2.asm"
; Bank 68  ------------------------------------------------------------------------------------------------------------------------
    SLOT    ShipModelsAddr
    PAGE    BankShipModels3
	ORG     ShipModelsAddr, BankShipModels3

    INCLUDE "./Data/ShipBank3Label.asm"
GetShipBank3Id:         MGetShipBankId ShipBankTable3
CopyVertsToUniv3:       McopyVertsToUniverse
CopyEdgesToUniv3:       McopyEdgesToUniverse
CopyNormsToUniv3:       McopyNormsToUniverse    
ShipBankTable3:         MShipBankTable
CopyShipToUniverse3     MCopyShipToUniverse     BankShipModels3
CopyBodyToUniverse3:    MCopyBodyToUniverse     CopyShipToUniverse3
    INCLUDE "./Data/ShipModelMetaData3.asm"
;;Privisioned for more models ; Bank 69  ------------------------------------------------------------------------------------------------------------------------
;;Privisioned for more models     SLOT    ShipModelsAddr
;;Privisioned for more models     PAGE    BankShipModels4
;;Privisioned for more models 	ORG     ShipModelsAddr, BankShipModels4

; Bank 60  ------------------------------------------------------------------------------------------------------------------------
    SLOT    SpritemembankAddr
    PAGE    BankSPRITE
	ORG     SpritemembankAddr, BankSPRITE
    INCLUDE "./Layer3Sprites/sprite_routines.asm"
    INCLUDE "./Layer3Sprites/sprite_load.asm"
    INCLUDE "./Layer3Sprites/SpriteSheet.asm"
; Bank 61  ------------------------------------------------------------------------------------------------------------------------
    SLOT    ConsoleImageAddr
    PAGE    BankConsole
	ORG     ConsoleImageAddr, BankConsole

    INCLUDE "./Images/ConsoleImageData.asm"
; Bank 62  ------------------------------------------------------------------------------------------------------------------------
    SLOT    ViewFrontAddr
    PAGE    BankFrontView
    ORG     ViewFrontAddr  
    INCLUDE "./Views/Front_View.asm"    
; Bank 63  ------------------------------------------------------------------------------------------------------------------------
    SLOT    MenuStatusAddr
    PAGE    BankMenuStatus
    ORG     MenuStatusAddr
    INCLUDE "./Menus/status_menu.asm"

; Bank 64  ------------------------------------------------------------------------------------------------------------------------

    SLOT    MenuEquipSAddr
    PAGE    BankMenuEquipS
    ORG     MenuEquipSAddr  
    INCLUDE "./Menus/equip_ship_menu.asm"    


    SLOT    LaunchShipAddr
    PAGE    BankLaunchShip
    ORG     LaunchShipAddr
    INCLUDE "./Transitions/launch_ship.asm"

; Bank 70  ------------------------------------------------------------------------------------------------------------------------
    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA0
	ORG	    UniverseBankAddr,BankUNIVDATA0
    INCLUDE "./Universe/Ships/univ_ship_data.asm"
    DISPLAY "Universe Data - Bytes free ",/D, $2000 - (UnivBankSize)
    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA1
	ORG	UniverseBankAddr,BankUNIVDATA1
UNIVDATABlock1      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA2
	ORG	UniverseBankAddr,BankUNIVDATA2
UNIVDATABlock2      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA3
	ORG	UniverseBankAddr,BankUNIVDATA3
UNIVDATABlock3      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA4
	ORG	UniverseBankAddr,BankUNIVDATA4
UNIVDATABlock4      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA5
	ORG	UniverseBankAddr,BankUNIVDATA5
UNIVDATABlock5      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA6
	ORG	UniverseBankAddr,BankUNIVDATA6
UNIVDATABlock6      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA7
	ORG	UniverseBankAddr,BankUNIVDATA7
UNIVDATABlock7      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA8
	ORG	UniverseBankAddr,BankUNIVDATA8
UNIVDATABlock8      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA9
	ORG	UniverseBankAddr,BankUNIVDATA9
UNIVDATABlock9      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA10
	ORG	UniverseBankAddr,BankUNIVDATA10
UNIVDATABlock10     DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA11
	ORG	UniverseBankAddr,BankUNIVDATA11
UNIVDATABlock11     DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    
    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA12
	ORG	UniverseBankAddr,BankUNIVDATA12
UNIVDATABlock12     DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
 
    SLOT    GalaxyDataAddr
    PAGE    BankGalaxyData0
	ORG GalaxyDataAddr, BankGalaxyData0
    INCLUDE "./Universe/Galaxy/galaxy_data.asm"                                                            
    
    DISPLAY "Galaxy Data - Bytes free ",/D, $2000 - ($- GalaxyDataAddr)

; Bank 83  ------------------------------------------------------------------------------------------------------------------------
    SLOT    SunBankAddr
    PAGE    BankSunData
	ORG	    SunBankAddr,BankSunData
    INCLUDE "./Universe/Sun/sun_data.asm"

; Bank 84  ------------------------------------------------------------------------------------------------------------------------
    SLOT    PlanetBankAddr
    PAGE    BankPlanetData
	ORG	    PlanetBankAddr,BankPlanetData
    INCLUDE "./Universe/Planet/planet_data.asm"

    SLOT    GalaxyDataAddr
    PAGE    BankGalaxyData1
	ORG GalaxyDataAddr, BankGalaxyData1
GALAXYDATABlock1         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now  

    SLOT    GalaxyDataAddr
    PAGE    BankGalaxyData2
	ORG GalaxyDataAddr, BankGalaxyData2
GALAXYDATABlock2         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now
    SLOT    GalaxyDataAddr
    PAGE    BankGalaxyData3
	ORG GalaxyDataAddr, BankGalaxyData3
GALAXYDATABlock3         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now
    SLOT    GalaxyDataAddr
    PAGE    BankGalaxyData4
	ORG GalaxyDataAddr, BankGalaxyData4
GALAXYDATABlock4         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now
    SLOT    GalaxyDataAddr
    PAGE    BankGalaxyData5
	ORG GalaxyDataAddr,BankGalaxyData5
GALAXYDATABlock5         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now
    SLOT    GalaxyDataAddr
    PAGE    BankGalaxyData6
	ORG GalaxyDataAddr,BankGalaxyData6
GALAXYDATABlock6         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now
    SLOT    GalaxyDataAddr
    PAGE    BankGalaxyData7
	ORG GalaxyDataAddr,BankGalaxyData7
GALAXYDATABlock7         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now




    SAVENEX OPEN "EliteN.nex", $8000 , $7F00
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    