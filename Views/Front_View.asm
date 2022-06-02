front_page_page_marker  DB "FrontView   PG62"    

draw_front_calc_alpha:  ld      b,a
                        and     $80
                        ld      (ALP2),a                            ; set sign 
                        ld      c,a                                 ; save sign
                        xor     $80
                        ld      (ALP2FLIP),a                        ; and oppsite sign
                        ld      a,(JSTX)
                        test    $80
                        jr      z,  .PositiveRoll
.NegativeRoll:          neg
.PositiveRoll           srl     a                                   ; divide sign by 4
                        srl     a                                  
                        cp      8
                        jr      c,.NotIncreasedDamp                 ; if a < 8 divide by 2 again
.IncreasedDamp          srl     a
.NotIncreasedDamp:      ld      (ALP1),a
                        or      c
                        ld      (ALPHA),a                           ; a = signed bit alph1
.RestartDampenRoll:     ld      hl,dampenRcounter
                        ld      (hl),dampenRate
                        ret
                        
; Do the same for pitch                        
draw_front_calc_beta:   ld      b,a
                        and     $80
                        ld      (BET2),a                            ; set sign 
                        ld      c,a                                 ; save sign
                        xor     $80
                        ld      (BET2FLIP),a                        ; and oppsite sign
                        ld      a,(JSTY)
                        test    $80
                        jr      z,  .PositivePitch
.NegativePitch:         neg
.PositivePitch:         srl     a                                   ; divide sign by 4
                        srl     a                                  
                        cp      8
                        jr      c,.NotIncreasedDamp                 ; if a < 8 divide by 2 again
.IncreasedDamp          srl     a
.NotIncreasedDamp:      ld      (BET1),a
                        or      c
                        ld      (BETA),a                            ; a = signed bit bet1
.RestartDampenPitch:    ld      hl,dampenPcounter          ; TODO mach dampen rates ship properies by having teh $20 as a ship config
                        ld      (hl),dampenRate
                        ret
                        
draw_front_view:        MMUSelectLayer1
                        call    l1_cls
                        call    l1_attr_cls
                        MMUSelectLayer2
                        call     asm_l2_double_buffer_on
                        MMUSelectSpriteBank
                        call    sprite_cls_cursors
                        call    sprite_reticule
                        call    sprite_laser
                        call    sprite_targetting
                        call    sprite_lock
                        call    sprite_targetting_hide      ; do not show targeting initially
                        call    sprite_ECM
                        call    sprite_missile_1
                        call    sprite_missile_2
                        call    sprite_missile_3
                        call    sprite_missile_4
                        call    sprite_ecm_hide
                        call    sprite_missile_all_hide
                       ; call    sprite_laser_show
                        MMUSelectConsoleBank
                        ld          hl,ScreenL1Bottom       ; now the pointers are in Ubnk its easy to read
                        ld          de,ConsoleImageData
                        ld          bc, ScreenL1BottomLen
                        call        memcopy_dma
                        ld          hl,ScreenL1AttrBtm       ; now the pointers are in Ubnk its easy to read
                        ld          de,ConsoleAttributes
                        ld          bc, ScreenL1AttrBtmLen
                        call        memcopy_dma
                        call        InitialiseStars
                        xor         a
                        ld          (DockedFlag),a              ; we can never be docked if we hit a view screen
                        ld          (CurrentLock),a             ; we are on no targetting sprites
                        ld          (ShowingLock),a
                        ret

CurrentLock             DB      0
ShowingLock             DB      0
update_front_view:      ld      a,(MissileTargettingFlag)
                        JumpIfANEquNusng StageMissileNoTarget,  .NoTarget
                        JumpIfANEquNusng StageMissileTargeting, .Targetting
                        bit     7,a
                        jr      nz, .Locked
                        call    sprite_targetting_hide
                        ret
.NoTarget:              ld      a,(ShowingLock)
                        ReturnIfAIsZero
                        MMUSelectSpriteBank
                        call     sprite_targetting_hide
                        ret
.Targetting:            CallIfMemZero CurrentLock, sprite_targetting
                        CallIfMemZero ShowingLock, sprite_targetting_show
                        ld      hl,$0100                        ; set both bytes in one go
                        ld      (CurrentLock),hl
                        ret
.Locked:                CallIfMemNotZero CurrentLock, sprite_lock
                        CallIfMemZero ShowingLock, sprite_targetting_show
                        ld      hl,$0101                        ; set both bytes in one go
                        ld      (CurrentLock),hl
                        ret     

                        ;  1......................  2......................  3......................  4......................  5......................  6...................... 7......................  8......................
                        ;  1......................  2......................  3......................  4......................  5......................  6...................... 7......................  8......................
LightningLines:         db 128, 064, 096, 040, 255, 097, 042, 076, 035, 031, 082, 039, 079, 020, 026, 079, 026, 058, 018, 022, 064, 021, 032, 026, 018, 038, 025, 030, 009, 026, 035, 020, 005, 016, 018, 037, 021, 000, 000, 018
                        db 128, 064, 139, 040, 255, 137, 045, 160, 035, 031, 150, 040, 157, 056, 026, 160, 036, 175, 010, 022, 156, 037, 196, 040, 018, 197, 041, 223, 033, 026, 223, 033, 245, 030, 018, 223, 032, 254, 047, 018
                        db 128, 064, 090, 089, 255, 089, 089, 064, 098, 031, 079, 092, 064, 072, 025, 065, 075, 030, 070, 022, 035, 071, 038, 064, 018, 067, 095, 021, 099, 026, 031, 097, 000, 080, 018, 031, 097, 021, 110, 018
                        db 128, 064, 097, 113, 255, 098, 110, 064, 115, 031, 070, 115, 073, 127, 025, 071, 114, 060, 112, 022, 030, 120, 020, 126, 018, 070, 114, 050, 120, 026, 050, 120, 027, 119, 018, 020, 125, 010, 120, 018
                        db 128, 064, 132, 089, 255, 131, 081, 145, 098, 031, 145, 097, 133, 103, 025, 145, 098, 150, 110, 022, 150, 109, 154, 105, 018, 150, 110, 146, 120, 026, 145, 120, 140, 126, 018, 147, 120, 159, 126, 018
                        db 128, 064, 159, 103, 255, 161, 102, 171, 108, 031, 160, 102, 175, 127, 025, 175, 124, 200, 122, 022, 200, 121, 223, 120, 018, 224, 120, 225, 127, 026, 224, 119, 245, 116, 018, 246, 117, 254, 123, 018
                        db 128, 064, 145, 074, 255, 145, 073, 158, 072, 031, 159, 072, 179, 064, 025, 159, 073, 185, 085, 022, 182, 084, 197, 076, 018, 195, 075, 207, 079, 026, 206, 079, 245, 063, 018, 206, 080, 245, 105, 018

; Draw line at hl for b lines
DrawLighningLine:       push    hl,,bc
                        ld      c,(hl)
                        inc     hl
                        ld      b,(hl)
                        inc     hl
                        ld      e,(hl)
                        inc     hl
                        ld      d,(hl)
                        inc     hl
                        ld      a,(hl)          ; colour
                        call    l2_draw_diagonal
                        pop     hl,,bc
                        ld      a,5
                        add     hl,a
                        djnz    DrawLighningLine
                        ret

;Loop though all lines
;   60$% chance of drawing a line, call draw line
;   go to next line
;repeat
hyperspace_Lightning:   ld      b, 7                    ; total number of lightning bolts
                        ld      hl,LightningLines 
                        MMUSelectLayer2
                        ;break
; above here select which lines table we will use
.LineLoop:              push    bc,,hl
                        call    doRandom
                        cp      30
                        jr      nc,.NextLine
                        call    doRandom
                        and     $07
                        inc     a
                        ld      b,a
                        pop     hl
                        push    hl
                        call    DrawLighningLine
.NextLine:              pop     bc,,hl
                        ld      d,8
                        ld      e,5
                        mul
                        add     hl,de
                        djnz    .LineLoop
                        ld      a,(HyperCircle)
                        ld      d,a
                        ld      bc, $4080
                        ;break
                        ld      e,$00
                        call    l2_draw_circle_fill; ; ">l2_draw_circle_fill BC = center row col, d = radius, e = colour"
                        ld      bc, $4080
                        ld      a,(HyperCircle)
                        inc     a
                        ld      d,a
                        ld      e,$FF
                        call    l2_draw_circle
                        ld      a,(HyperCircle)
                        inc     a
                        inc     a
                        cp      64
                        ret     nc
                        ld      (HyperCircle),a
                        SetCarryFlag
                        ret
                        
                       
draw_hyperspace:        MMUSelectLayer1
                        call    l1_cls
                        call    l1_attr_cls
                        MMUSelectLayer2
                        call     asm_l2_double_buffer_on
                        MMUSelectSpriteBank
                        call    sprite_cls_cursors
                        MMUSelectConsoleBank
                        ld          hl,ScreenL1Bottom       ; now the pointers are in Ubnk its easy to read
                        ld          de,ConsoleImageData
                        ld          bc, ScreenL1BottomLen
                        call        memcopy_dma
                        ld          hl,ScreenL1AttrBtm       ; now the pointers are in Ubnk its easy to read
                        ld          de,ConsoleAttributes
                        ld          bc, ScreenL1AttrBtmLen
                        call        memcopy_dma
                        call        InitialiseHyperStars
                        xor         a
                        ld          (DockedFlag),a              ; we can never be docked if we hit a view screen
                        ld          a,2
                        ld          (HyperCircle),a
                        ld          a,$FC
                        ld          (DockedFlag),a
                        ret
                        
                        
loop_hyperspace                        
                        
dampenRate:             equ     $04
dampenRcounter:         DB      dampenRate
dampenPcounter:         DB      dampenRate
input_front_view:       xor         a
                        ld      hl,(addr_Pressed_Accellerate)
                        ld      a,(hl)
                        JumpIfAIsZero     .TestDecellerate
                        ld      a,(SHIPMAXSPEED)
                        ld      d,a
                        ld      a,(DELTA)
                        JumpIfAGTENusng d,.TestDecellerate
                        inc     a
                        ld      (DELTA),a
                        ld      hl,(DELT4Lo)
                        add     hl,4
                        ld      (DELT4Lo),hl
.TestDecellerate:       ld      hl,(addr_Pressed_Decellerate)
                        ld      a,(hl)
                        JumpIfAIsZero   .TestLeftPressed
                        ld      a,(DELTA)
                        JumpIfAIsZero   .TestLeftPressed
                        dec     a
                        ld      (DELTA),a
                        ld      hl,(DELT4Lo)
                        dec     hl
                        dec     hl
                        dec     hl
                        dec     hl
                        ld      (DELT4Lo),hl    
.TestLeftPressed:       ld      hl,(addr_Pressed_RollLeft)
                        ld      a,(hl)
                        JumpIfAIsZero   .TestRightPressed
                        ld      a,(JSTX)                            ; have we maxed out Joystick?
                        ld      hl,ALP1MAXL                         ; currnet ship max left roll
                        cp      (hl)
                        jr      z,.TestRightPressed
                        ;break
                        dec     a                                   ; increase joystick roll
                        ld      (JSTX),a
                        call    draw_front_calc_alpha
                        jp      .TestDivePressed                    ; when pressing ignore damper
.TestRightPressed:       ld      hl,(addr_Pressed_RollRight)
                        ld      a,(hl)
                        JumpIfAIsZero   .DampenRoll
                        ld      a,(JSTX)                            ; have we maxed out Joystick?
                        ld      hl,ALP1MAXR                         ; currnet ship max left roll
                        cp      (hl)
                        jr      z,.TestDivePressed                   ; if its held then we don't dampen
                        ;break
                        inc     a                                   ; increase joystick roll
.UpdateAlphRoll:        ld      (JSTX),a
                        call    draw_front_calc_alpha
                        jp      .TestDivePressed                    ; when pressing ignore damper
.DampenRoll:            ld      hl,dampenRcounter
                        dec     (hl)
                        jr      nz,.TestDivePressed
                        ld      a,dampenRate
                        ld      (hl),a
                        ld      a,(JSTX)
                        cp      0
                        jr      z, .TestDivePressed
                        bit     7,a
                        jr      z,.PosRollDampen
.NegRollDampen:         inc     a
                        jr      .ApplyRollDampen
.PosRollDampen:         dec     a
.ApplyRollDampen:       jr      .UpdateAlphRoll
; Dive and Climb input
.TestDivePressed:       ld      hl,(addr_Pressed_Dive)
                        ld      a,(hl)
                        JumpIfAIsZero   .TestClimbPressed
                        ld      a,(JSTY)                            ; have we maxed out Joystick?
                        ld      hl,BET1MAXD                         ; currnet ship max left roll
                        cp      (hl)
                        jr      z,.TestClimbPressed
                        ;break
                        dec     a                                   ; increase joystick roll
                        ld      (JSTY),a
                        call    draw_front_calc_beta
                        jp      .ForwardCursorKeysDone
.TestClimbPressed:      ld      hl,(addr_Pressed_Climb)
                        ld      a,(hl)
                        JumpIfAIsZero   .DampenPitch
                        ld      a,(JSTY)                            ; have we maxed out Joystick?
                        ld      hl,BET1MAXC                         ; currnet ship max left roll
                        cp      (hl)
                        jr      z,.ForwardCursorKeysDone
                        inc     a                                   ; increase joystick roll
.UpdateBetaPitch:       ld      (JSTY),a
                        call    draw_front_calc_beta
                        jp      .ForwardCursorKeysDone
.DampenPitch:           ld      hl,dampenPcounter          ; TODO mach dampen rates ship properies by having teh $20 as a ship config
                        dec     (hl)
                        jr      nz,.ForwardCursorKeysDone
                        ld      a,dampenRate
                        ld      (hl),a
                        ld      a,(JSTY)
                        cp      0
                        jr      z,.ForwardCursorKeysDone
                        bit     7,a
                        jr      z,.PosPitchDampen
.NegPitchDampen:        inc     a
                        jr      .ApplyPitchDampen
.PosPitchDampen:        dec     a
.ApplyPitchDampen:      jr      .UpdateBetaPitch
; Now test hyperpsace. We can't be docked as this is a view routine piece of logic but for say local charts we may 
; be in flight and they have to force a forward view when hyperspace is pressed
; We won't do galatic here, but for other views force to forward view
.ForwardCursorKeysDone: ld      a,c_Pressed_Hyperspace              ; Check for hyperspace
                        call    is_key_pressed
                        jr      nz,.NotHyperspace
; If we are in hyperspace countdown then test for hyperspace
                        ld      hl,(InnerHyperCount)                ; if hyperspace was enaged then cancel
                        ld      a,h                                 ; hyperspace
                        or      l                                   ; .
                        jr      nz,.CancelHyperspace                ; .
; check selected target if we find one then after gettting galaxy at bc a=0 if not found
                        ld      de,(PresentSystemX)
                        ld      hl,(TargetSystemX)
                        call    compare16HLDE
                        jr      z,.NoTargetSelected                 ; can't jump to current system
                        ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        ld      bc,(TargetSystemX)
                        call    galaxy_name_at_bc
                        cp      0
                        jr      z,.NotHyperspace
; check fuel is sufficient
                        ld      bc,(PresentSystemX)
                        ld      (GalaxyPresentSystem),bc
                        ld      bc,(TargetSystemX)
                        ld      (GalaxyDestinationSystem),bc
                        call    galaxy_find_distance            ; get distance into HL
                        ld      a,h
                        and     a
                        jr      nz,.InsufficientFuel            ; max jump capacity is 25 ly for any ship
                        ld      a,(Fuel)
                        JumpIfALTNusng    l, .InsufficientFuel
; set up timer countdown
                        ld      hl,HyperSpaceTimers                 ; set both timers to 15
                        ld      (InnerHyperCount),hl                ; .
.CancelHyperspace
.NoTargetSelected
.InsufficientFuel
.NotHyperspace:         
.CheckForLaserPressed:  call    IsLaserUseable                      ; no laser or destroyed?
                        jr      z,.CheckTargetting
.CanLaserStillFire:     SetMemFalse FireLaserPressed                ; default to no laser
                        ld      a,(CurrLaserPulseRate)              ; if not beam type
                        JumpIfAIsZero .BeamType                     ; .
                        ld      b,a                                 ; and not run out of pulses
                        ld      a,(CurrLaserPulseRateCount)         ;
                        ld      a,(CurrLaserPulseOnCount)           ;    if not already on
                        JumpIfAEqNusng  b, .PulseLimitReached       ;
                        ld      hl,CurrLaserPulseOffCount           ;       and not in off phase
                        or      (hl)                                ;    
                        inc     hl  ; CurrLaserPulseRestCount       ;       and not in rest phase.
                        or      (hl)                                ;    .
                        jr      nz, .CheckTargetting                ;    .
.IsFirePressed:         ld      a,c_Pressed_FireLaser               ;       if fire is pressed
                        call    is_key_up_state                     ;       .
                        jr      z,.CheckTargetting                  ;       .
.CanProcesFire:         ld      a,(CurrLaserPulseRateCount)         ;            pulse rate count ++
                        inc     a                                   ;            .
.StillHavePulsesLeft:   ld      (CurrLaserPulseRateCount),a         ;            .
                        ldCopyByte CurrLaserPulseOnTime, CurrLaserPulseOnCount  ; pulse on count = pulse on time
                     ;   ldCopyByte CurrLaserPulseOffTime, CurrLaserPulseOffCount; pulse off count = pulse off time
                     ;   ldCopyByte CurrLaserPulseRest, CurrLaserPulseRestCount  ; pulse rest count = pulse rest time
                        jp      .CheckTargetting                   
.BeamType:              ld      a,c_Pressed_FireLaser               ; else (beam type) if fire is pressed
                        call    is_key_up_state                     ;                   .
                        jr      z,.CheckTargetting                  ;                   .
                        SetMemTrue FireLaserPressed                 ;                   set pulse on to 1
                        jp      .CheckTargetting
.PulseLimitReached:     ;ZeroA                                       ;
                        ;ld      (CurrLaserPulseRateCount),a         ;
                        ;ldCopyByte CurrLaserPulseRest, CurrLaserPulseRestCount   ; start the rest phase
; . Here we check to see if the target lock has been pressed                        
.CheckTargetting:       call    TargetMissileTest
.CheckForMissile:       ld      a,c_Pressed_FireMissile             ; launch pressed?
                        call    is_key_pressed
                        jr      nz,.NotMissileLaunch
                        AnyMissilesLeft                             
                        jr      z,.NotMissileLaunch                 ; no missiles in rack
                        call    IsMissileLockedOn
                        jr      z,.MissileNotLocked
.MissileLaunch:         SetMissileLaunch
.MissileNotLocked:                       ; later on we need a "bing bong" nose for trying to launch an unlocked missile
.NotMissileLaunch:
.CheckForECM:           ld      a,(ECMPresent)
                        JumpIfAEqNusng EquipmentItemNotFitted,.NoECM
.CheckECMActive:        ld      a,(PlayerECMActiveCount)
                        JumpIfAIsNotZero .NoECM
.CheckForKeyPress:      ld      a, c_Pressed_ECM
                        call    is_key_pressed
                        jr      nz, .NoECM
.FireECM:               SetMemToN      PlayerECMActiveCount, ECMCounterMax 
                        ld      a,(ECMCountDown)
                        JumpIfAGTENusng ECMCounterMax, .NoECM
                        SetMemToN      ECMCountDown, ECMCounterMax 
.NoECM:                 ret






                