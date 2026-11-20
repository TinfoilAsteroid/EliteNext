
    DEFINE  MAINLOOP_COOL_LASERS
    DEFINE  MAINLOOP_ECM
    DEFINE  MAINLOOP_KEYBOARDSCAN
;    DEFINE  MAINLOOP_DEMOSHIPS
;   DEFINE  MAINLOOP_DEBUGMISSILE 1
    DEFINE  MAINLOOP_INPUTHANDLER
    DEFINE  MAINLOOP_EVENTHANDLER 1
    DEFINE  MAINLOOP_RECHARGE 1
    DEFINE  MAINLOOP_LAUNCHMISSILE
    DEFINE  MAINLOOP_UPDATEUNIVERSE 1
    DEFINE  MAINLOOP_DUST_RENDER 1    
    DEFINE  MAINLOOP_SUN_RENDER 1
    DEFINE  MAINLOOP_PLANET_RENDER 1
    DEFINE  MAINLOOP_MODEL_RENDER    1
   ; DEFINE  MAINLOOP_SPAWN_ALWAYS_OUTSIDE_SAFEZONE 1
    DEFINE  MAINLOOP_WARP_ENABLED 1
   ; used to block ship spawning whilst `ging
   ; DEFINE  SPAWN_SHIP_DISABLED 1

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
                        call    LaserUpdate                                     ; pulses timed in frames (FrameCounter16)
                        call    HyperSpaceTick                                  ; the hyperspace countdown, in seconds of FrameCounter16
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
.MissionLogic:    ; so select mission bank
MissionJump:            call    $0000                                                   ; and call custom logic routined
;.. Handle displaying correct screen ..............................................................................................
HandleBankSelect:       ld      a,$00
                        MMUSelectScreenA
CallCursorRoutine:      call    $0000
;.. Check to see if we are docked as if we are (or are docking.launching then no AI/Ship updates occur.............................
;.. Also end up here if we have the screen input blocker set
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
                        call    UpdateSafeZone                                  ; the space station's safe zone, and the station on entering it
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
.CheckHyperspaceMessage:ld      a,(InnerHyperCount)                                     ; counting, or the text still to clear
                        ld      hl,HyperTextOnScreen
                        or      (hl)
                        call    nz,HyperSpaceMessage
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
                        INCLUDE "./GameEngine/Diagnostics-BODY-DIAGNOSTICS.asm"
;..Later this will be done via self modifying code to load correct stars routine for view..........................................
DrawDustForwards:       ld     a,$DF
                        ld     (line_gfx_colour),a                         
DustUpdateBank:         MMUSelectViewFront                                              ; This needs to be self modifying
                        IFDEF   MAINLOOP_DUST_RENDER
DustUpdateRoutine:          call   DustForward                                              ; This needs to be self modifying
                        ENDIF
ProcessLaser:           MMUSelectSpriteBank                                         ; the beam's sprite (LaserUpdate drains
                        JumpIfMemFalse LaserBeamOn, .NoLaser                        ; energy and adds heat)
                        call    sprite_laser_show
                        jp      ProcessPlanet
.NoLaser:               call    sprite_laser_hide
ProcessPlanet:
                        IFDEF   MAINLOOP_MODEL_RENDER
ProcessShipModels:          call   DrawForwardShips                                     ; Draw all ships and bodies in system (this may need to be self modifying)
                        ENDIF
                        call    DrawSunDistance                                     ; every frame as the view area it prints in is cleared every frame
                        call    DrawPlanetDistance
                        call    DrawStationDistance
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
;----------------------------------------------------------------------------------------------------------------------------------
; Laser, once a main loop. Times are 50 Hz frames of FrameCounter16 (the interrupt's count, stopped while paused), so a
; pulse lasts as long however fast the loop runs. Like Z-Police's game clock (clock_step): dt = the frames since the last
; update (at most LaserMaxFrames, so a stall doesn't jump), and each state's end is a frame number, compared by 16 bit
; subtraction so it works across the counter's wrap.
;   LaserReady  fire held (LaserFireHeld, from the front view's keys) starts a burst of CurrLaserPulseRate pulses,
;               or with a rate of 0 a beam
;   LaserOn     a pulse, CurrLaserPulseOnTime frames; a beam stays on while fire is held
;   LaserOff    CurrLaserPulseOffTime frames between a burst's pulses
;   LaserRest   CurrLaserPulseRest frames after a burst (or a beam) before the next
; Out: LaserBeamOn (the sprite), LaserHitDamage (what a ship in the sights takes this loop: a pulse's damage when it
; starts, a beam's for each frame it was on), energy drained and heat added for each frame on, the gun cooled for each
; frame off. LaserFireHeld is cleared: the keys set it again each loop while fire is held.
LaserReady              equ 0
LaserOn                 equ 1
LaserOff                equ 2
LaserRest               equ 3
LaserMaxFrames          equ 8

LaserUpdate:            ld      hl,(FrameCounter16)                     ; (one instruction: the interrupt can't split it)
                        ld      (LaserNow),hl
                        ld      de,(LaserLastFrame)
                        ld      (LaserLastFrame),hl
                        or      a
                        sbc     hl,de                                   ; frames since the last update
                        ld      a,h
                        or      a
                        jr      nz,.Cap
                        ld      a,l
                        cp      LaserMaxFrames+1
                        jr      c,.DtOk
.Cap:                   ld      a,LaserMaxFrames
.DtOk:                  ld      (LaserFrames),a
                        ZeroA
                        ld      (LaserHitDamage),a
                        ld      a,(LaserFireHeld)                       ; (true is 0, false $FF: SetMemTrue)
                        ld      (LaserFireThisLoop),a
                        SetMemFalse LaserFireHeld                       ; the keys set it again if still held
                        ld      a,(LaserState)
                        cp      LaserOn
                        jr      z,.On
                        cp      LaserOff
                        jr      z,.Off
                        cp      LaserRest
                        jr      z,.Rest
.Ready:                 ld      a,(LaserFireThisLoop)
                        and     a
                        jr      nz,.Idle                                ; fire not held
                        call    IsLaserUseable                          ; z: none fitted or destroyed
                        jr      z,.Idle
                        ld      a,(CurrLaserPulseRate)
                        ld      (CurrLaserBurstCount),a
.StartPulse:            PlaySFX SFXLaser                                       ; each pulse (or a beam) starting
                        ld      a,(CurrLaserPulseOnTime)
                        ld      e,a
                        ld      a,LaserOn
                        call    LaserSetState
                        ld      a,(CurrLaserPulseRate)                  ; a pulse hits once, as it starts
                        and     a
                        jr      z,.Firing
                        ld      a,(CurrLaserDamageOutput)
                        ld      (LaserHitDamage),a
                        jr      .Firing
.On:                    ld      a,(CurrLaserPulseRate)
                        and     a
                        jr      nz,.PulseOn
.BeamOn:                ld      a,(LaserFireThisLoop)                   ; a beam: on while fire is held
                        and     a
                        jr      z,.Firing
                        jr      .StartRest
.PulseOn:               call    LaserStillRunning
                        jr      c,.Firing
                        ld      hl,CurrLaserBurstCount                  ; the pulse is over
                        dec     (hl)
                        jr      z,.StartRest                            ; that was the burst's last
                        ld      a,(CurrLaserPulseOffTime)
                        ld      e,a
                        ld      a,LaserOff
                        call    LaserSetState
                        jr      .Idle
.Off:                   call    LaserStillRunning
                        jr      c,.Idle
                        jr      .StartPulse
.Rest:                  call    LaserStillRunning
                        jr      c,.Idle
                        ld      a,LaserReady
                        ld      (LaserState),a
                        jr      .Ready                                  ; (fire again straight away if held)
.StartRest:             ld      a,(CurrLaserPulseRest)
                        ld      e,a
                        ld      a,LaserRest
                        call    LaserSetState
                        ; fall into .Idle
.Idle:                  SetMemFalse LaserBeamOn
                        ld      a,(LaserFrames)                         ; the gun cools a step a frame
                        and     a
                        ret     z
                        ld      b,a
.Cool:                  push    bc
                        CoolLasers
                        pop     bc
                        djnz    .Cool
                        ret
.Firing:                SetMemTrue LaserBeamOn
                        ld      a,(CurrLaserPulseRate)                  ; a beam hits for each frame it was on
                        and     a
                        jr      nz,.Drain
                        ld      a,(LaserFrames)
                        ld      e,a
                        ld      a,(CurrLaserDamageOutput)
                        ld      d,a
                        mul     de
                        ld      a,d
                        and     a
                        ld      a,e
                        jr      z,.BeamHit
                        ld      a,255
.BeamHit:               ld      (LaserHitDamage),a
.Drain:                 ld      a,(LaserFrames)                         ; energy and heat a frame
                        and     a
                        ret     z
                        ld      b,a
.DrainLoop:             push    bc
                        call    LaserDrainSystems
                        pop     bc
                        djnz    .DrainLoop
                        ret

; a = the new state, e = the frames it lasts from now
LaserSetState:          ld      (LaserState),a
                        ld      hl,(LaserNow)
                        ld      d,0
                        add     hl,de
                        ld      (LaserStateEnd),hl
                        ret

; carry set while the state's time hasn't run out (now - end < 0, 16 bit: right across the wrap)
LaserStillRunning:      ld      hl,(LaserNow)
                        ld      de,(LaserStateEnd)
                        or      a
                        sbc     hl,de
                        ld      a,h
                        rla
                        ret

; the laser ready and off, its frame count from now (a new ship, a launch, a loaded commander)
LaserReset:             ZeroA
                        ld      (LaserState),a
                        ld      (LaserHitDamage),a
                        ld      (CurrLaserBurstCount),a
                        SetMemFalse LaserBeamOn
                        SetMemFalse LaserFireHeld
                        ld      hl,(FrameCounter16)
                        ld      (LaserLastFrame),hl
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
                        MMUSelectStockTable                    ; .
                        call    generate_stock_market          ; generate new prices
                        call    ClearUnivSlotList              ; clear out any ships
                        call    ResetPlayerShip
                        HalveFugitiveStatus                    ; halves status and brings bit into carry
                        MMUSelectSun
                        call    CreateSun                      ; create the local sun and set position based on seed
                        MMUSelectPlanet
                        call    CreatePlanet
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
;----------------------------------------------------------------------------------------------------------------------------------
; The space station's safe zone (as BBC Elite): inside the cube |x|, |y|, |z| < $C000 round the planet (sign bytes no
; integer bits, hi bytes < $C0). SpaceStationSafeZone is 0 inside, $FF outside (SetSafeZone / ClearSafeZone); the spawn
; tables, the status screen and the station's arrival use it. On flying in, if slot 0 (kept for it) is free, the station
; is made there: on the line from the planet's centre towards us, |normal| * 192 out (49000 at most, as BBC's 2 nosev
; lengths), its slot towards us (UnivSetStationInSafeZone). Once a main loop while in flight
StationPlaceDistance    equ 192
StationPlacePos:        DS 9                                        ; x, y, z (lo, hi, sign) for UnivSetStationInSafeZone
StationPlaceNose:       DS 3                                        ; its nose's hi bytes (lead sign)

StationAxisFromPlanet:  MACRO   pos, norm, dest, nose               ; dest = pos - planet normal * StationPlaceDistance
                        ld      a,(norm)                            ; |normal| (0 to 255)
                        ld      d,a
                        ld      e,StationPlaceDistance
                        mul     de                                  ; de = |normal| * 192
                        ld      c,d                                 ; bch = that, the sign flipped (from the planet to us)
                        ld      h,e                                 ; .
                        ld      a,(norm+1)                          ; .
                        and     SignOnly8Bit                        ; .
                        xor     SignOnly8Bit                        ; .
                        ld      b,a                                 ; .
                        ld      a,(norm)                            ; the nose: |normal| * 96 / 256, same sign
                        ld      d,a
                        ld      e,96
                        mul     de
                        ld      a,d
                        or      b
                        ld      (nose),a
                        ld      a,(pos)                             ; del = the planet's position
                        ld      l,a                                 ; .
                        ld      de,(pos+1)                          ; .
                        call    AddBCHtoDELsigned                   ; del = planet + offset
                        ld      a,l
                        ld      (dest),a
                        ld      (dest+1),de
                        ENDM

UpdateSafeZone:         MMUSelectPlanet
                        ld      a,(P_BnKxsgn)                       ; any axis 65536 or more off?
                        ld      hl,P_BnKysgn
                        or      (hl)
                        ld      hl,P_BnKzsgn
                        or      (hl)
                        and     SignMask8Bit
                        jp      nz,.Outside
                        ld      a,(P_BnKxhi)                        ; or $C000 or more
                        cp      $C0
                        jp      nc,.Outside
                        ld      a,(P_BnKyhi)
                        cp      $C0
                        jp      nc,.Outside
                        ld      a,(P_BnKzhi)
                        cp      $C0
                        jp      nc,.Outside
.Inside:                ld      a,(SpaceStationSafeZone)            ; already in
                        and     a
                        ret     z
                        SetSafeZone
                        ld      a,(UniverseSlotList)                ; slot 0 free?
                        cp      $FF
                        ret     nz                                  ; (the station is already there)
.PlaceStation:          MMUSelectMathsBankedFns                     ; AddBCHtoDELsigned (the planet bank stays in slot 6)
                        StationAxisFromPlanet P_BnKxlo, P_BnKxlo+POS_NORMXOFFSET, StationPlacePos,   StationPlaceNose
                        StationAxisFromPlanet P_BnKylo, P_BnKxlo+POS_NORMYOFFSET, StationPlacePos+3, StationPlaceNose+1
                        StationAxisFromPlanet P_BnKzlo, P_BnKxlo+POS_NORMZOFFSET, StationPlacePos+6, StationPlaceNose+2
                        MMUSelectSpaceStation                       ; slot 0's bank
                        call    UnivSelSpaceStationType
                        ld      iyh,0
                        ld      iyl,a
                        call    SpawnSpaceStation                   ; slot 0, the model, runtime data
                        MMUSelectSpaceStation
                        call    UnivSetStationInSafeZone            ; position and facing
                        ret
.Outside:               ClearSafeZone
                        ret

LoopEventTriggered:     ; for now just do spawn
                        call        SpawnEvent
                        ret ; implicit ret from jp to be added later
                        

    DEFINE  SPAWN_TABLE_SELECT   1
    DEFINE  SPAWN_GENERATE_COUNT 1
    DEFINE  SPAWN_LOOP           1
    
;--- Handle spawn event --------------------------------------------
SpawnEvent:             IFDEF SPAWN_SHIP_DISABLED
                            ret
                        ENDIF
                        call    FindNextFreeSlotInC                 ; set c= slot number, if we cant find a slot                   Stack     > 0
                        ret     c                                   ; then may as well just skip routine
;.. Found a slot free so can spawn, now this define controls filtering of what can be spawned near a safe zone
                        IFDEF   MAINLOOP_SPAWN_ALWAYS_OUTSIDE_SAFEZONE
                            SetMemFalse SpaceStationSafeZone        ; This if def allows spawning inside space 3 safe zone
                        ENDIF
;.. A slot is free for a spawn to occur so select a spawn table and data
.SpawnIsPossible:       call    SelectSpawnTable                    ; ix = correct row in spawn table, indexed on the random value found on FreeSpaceSpawnTableLow
.GetSpawnDetails:       call    SelectSpawnTableData                ; get table data, b = max ships to spawm, de = rank table address, hl = address of spawn handler code                  
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
                        call    UnivSetEnemyMissile
                        PlaySFX SFXMissile                 ; as per player but sets as angry
                        ld      a,$FF
                        ld      (UBnKMissileTarget),a               ; set as definte player as target
                        ld      a,(EnemyShipBank)                   ; Direct restore current bank
                        MMUSelectUnivBankA                          ;
                        ld      hl, UBnKMissilesLeft                ; reduce enemy missile count
                        dec     (hl)
                        ret

LaunchEnemyFighter:     ld      a,10
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
                        PlaySFX SFXMissile
                        ret
.MissileMissFire:       ClearMissileTargetting
                        PlaySFX SFXBong                             ; no free slot (TODO misfire message)
                        ret

                        include "./SpawnShipTypeA.asm"

                        ; reset main loop counters
                        ; from BBC TT18 jump code
                        ; need to set system corrodinates, flush out univere ships etc
                        ; set up new star system and landing location in system     
                        ; reset ship speed etc (RES2)
                        ; update legal status, missle indicatrions, planet data block, sun data block (SOLAR)
                        ;   put planet into data blokc 1 of FRIN
                        ;   put sun inot data block (NWWSHIP)
                        ; need to look at in system warp code (WARP) - note we need to -reorg all to code for teh 3 as that will never be in slot 0

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

