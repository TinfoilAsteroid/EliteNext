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
                        ret
                        
dampenRate:             equ     $04
dampenRcounter:         DB      dampenRate
dampenPcounter:         DB      dampenRate
input_front_view:       xor         a
                        ld      hl,(addr_Pressed_Accellerate)
                        ld      a,(hl)
                        IfAIsZeroGoto     TestDecellerate
                        ld      a,(SHIPMAXSPEED)
                        ld      d,a
                        ld      a,(DELTA)
                        JumpIfAGTENusng d,TestDecellerate
                        inc     a
                        ld      (DELTA),a
                        ld      hl,(DELT4Lo)
                        add     hl,4
                        ld      (DELT4Lo),hl
TestDecellerate:        ld      hl,(addr_Pressed_Decellerate)
                        ld      a,(hl)
                        IfAIsZeroGoto   TestLeftPressed
                        ld      a,(DELTA)
                        IfAIsZeroGoto   TestLeftPressed
                        dec     a
                        ld      (DELTA),a
                        ld      hl,(DELT4Lo)
                        dec     hl
                        dec     hl
                        dec     hl
                        dec     hl
                        ld      (DELT4Lo),hl    
TestLeftPressed:        ld      hl,(addr_Pressed_RollLeft)
                        ld      a,(hl)
                        IfAIsZeroGoto   TestRightPressed
                        ld      a,(JSTX)                            ; have we maxed out Joystick?
                        ld      hl,ALP1MAXL                         ; currnet ship max left roll
                        cp      (hl)
                        jr      z,TestRightPressed
                        ;break
                        dec     a                                   ; increase joystick roll
                        ld      (JSTX),a
                        call    draw_front_calc_alpha
                        jp      TestDivePressed                    ; when pressing ignore damper
TestRightPressed:       ld      hl,(addr_Pressed_RollRight)
                        ld      a,(hl)
                        IfAIsZeroGoto   .DampenRoll
                        ld      a,(JSTX)                            ; have we maxed out Joystick?
                        ld      hl,ALP1MAXR                         ; currnet ship max left roll
                        cp      (hl)
                        jr      z,TestDivePressed                   ; if its held then we don't dampen
                        ;break
                        inc     a                                   ; increase joystick roll
.UpdateAlphRoll:        ld      (JSTX),a
                        call    draw_front_calc_alpha
                        jp      TestDivePressed                    ; when pressing ignore damper
.DampenRoll:            ld      hl,dampenRcounter
                        dec     (hl)
                        jr      nz,TestDivePressed
                        ld      a,dampenRate
                        ld      (hl),a
                        ld      a,(JSTX)
                        cp      0
                        jr      z, TestDivePressed
                        bit     7,a
                        jr      z,.PosRollDampen
.NegRollDampen:         inc     a
                        jr      .ApplyRollDampen
.PosRollDampen:         dec     a
.ApplyRollDampen:       jr      .UpdateAlphRoll
; Dive and Climb input
TestDivePressed:        ld      hl,(addr_Pressed_Dive)
                        ld      a,(hl)
                        IfAIsZeroGoto   TestClimbPressed
                        ld      a,(JSTY)                            ; have we maxed out Joystick?
                        ld      hl,BET1MAXD                         ; currnet ship max left roll
                        cp      (hl)
                        jr      z,TestClimbPressed
                        ;break
                        dec     a                                   ; increase joystick roll
                        ld      (JSTY),a
                        call    draw_front_calc_beta
                        jp      ForwardViewDoneKeys
TestClimbPressed:       ld      hl,(addr_Pressed_Climb)
                        ld      a,(hl)
                        IfAIsZeroGoto   .DampenPitch
                        ld      a,(JSTY)                            ; have we maxed out Joystick?
                        ld      hl,BET1MAXC                         ; currnet ship max left roll
                        cp      (hl)
                        jr      z,ForwardViewDoneKeys
                        inc     a                                   ; increase joystick roll
.UpdateBetaPitch:       ld      (JSTY),a
                        call    draw_front_calc_beta
                        jp      ForwardViewDoneKeys
.DampenPitch:           ld      hl,dampenPcounter          ; TODO mach dampen rates ship properies by having teh $20 as a ship config
                        dec     (hl)
                        jr      nz,ForwardViewDoneKeys
                        ld      a,dampenRate
                        ld      (hl),a
                        ld      a,(JSTY)
                        cp      0
                        jr      z,ForwardViewDoneKeys
                        bit     7,a
                        jr      z,.PosPitchDampen
.NegPitchDampen:        inc     a
                        jr      .ApplyPitchDampen
.PosPitchDampen:        dec     a
.ApplyPitchDampen:      jr      .UpdateBetaPitch
ForwardViewDoneKeys:    ret






                