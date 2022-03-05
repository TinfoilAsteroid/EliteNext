; bc = start position, d = length, e = colour
Draw3LineBar:           ld      e,16
                        push    bc,,de
                        MMUSelectLayer2
                        call    l2_draw_horz_line
                        pop     bc,,de
                        dec     b
                        push    bc,,de
                        ld      e,20
                        MMUSelectLayer2
                        call    l2_draw_horz_line
                        pop     bc,,de
                        dec     b    
                        MMUSelectLayer2
                        call    l2_draw_horz_line
                        ret
                        
DrawColourCodedBar:     ld      e,124
                        cp      40
                        jr      nc,DrawColourEBar
                        ld      e,84
                        cp      30
                        jr      nc,DrawColourEBar
                        ld      e,216
                        cp      20
                        ld      e,236
                        cp      10
                        jr      nc,DrawColourEBar
                        ld      e,225
                        cp      5
                        jr      nc,DrawColourEBar
                        ld      e,224
DrawColourEBar:         push    bc,,de
                        MMUSelectLayer2
                        call    l2_draw_horz_line
                        pop     bc,,de
                        dec     b
                        push    bc,,de
                        MMUSelectLayer2
                        call    l2_draw_horz_line
                        pop     bc,,de
                        dec     b    
                        MMUSelectLayer2
                        call    l2_draw_horz_line
                        ret
                    
                        ; no ret needed as jp handles it


UpdateConsole:          ld      a,(DELTA)
                        cp      0                           ; don't draw if there is nothing to draw
                        jr      z,.UpdateRoll   
                        ld      bc,SpeedoStart
                        ld      hl,SpeedoMapping
                        add     hl,a
                        ld      d,(hl)
                        call    Draw3LineBar
.UpdateRoll:            ld      a,(ALP1)
                        cp      0
                        jp      z,.UpdatePitch
                        ld      hl,RollMiddle
                        ld      a,(ALP2)
                        cp      0
                        jp     z,.PosRoll
.NegRoll:               ld      d,0
                        ld      a,(ALP1)
                        sla     a
                        ld      e,a
                        or      a
                        sbc     hl,de
                        ld      bc,hl
                        ld      a,DialMiddleXPos
                        sub     c
                        ld      d,a
                        ld      e,$FF
                        call    Draw3LineBar
                        jr      .UpdatePitch
.PosRoll:               ld      bc,RollMiddle
                        ld      a,(ALP1)
                        sla     a
                        ld      d,a
                        ld      e,$FF
                        call    Draw3LineBar
.UpdatePitch:           ld      a,(BET1)
                        cp      0
                        jp      z,.Fuel
                        ld      hl,PitchMiddle
                        ld      a,(BET2)
                        cp      0
                        jp      z,.PosPitch
.NegPitch:              ld      d,0
                        ld      a,(BET1)
                        sla     a
                        ld      e,a
                        or      a
                        sbc     hl,de
                        ld      bc,hl
                        ld      a,DialMiddleXPos
                        sub     c
                        ld      d,a
                        ld      e,$FF
                        call    Draw3LineBar
                        jp      .Fuel
.PosPitch:              ld      bc,PitchMiddle
                        ld      a,(BET1)
                        sla     a
                        ld      d,a
                        ld      e,$FF
                        call    Draw3LineBar
.Fuel:                  ld      a,(Fuel)
                        srl     a               ; divide by 4 to get range on screen
                        ld      hl,FuelMapping
                        add     hl,a
                        ld      a,(hl)
                        ld      bc,FuelStart
                        ld      d,a
                        call    DrawColourCodedBar                        
.ForeShield:            ld      a,(ForeShield)
                        srl     a
                        srl     a
                        srl     a               
                        ld      bc,FShieldStart
                        call    DrawColourCodedBar                        
.AftShield:             ld      a,(AftShield)
                        srl     a
                        srl     a
                        srl     a               
                        ld      bc,AShieldStart
                        ld      d,a
                        call    DrawColourCodedBar  ;ld		(ForeShield),a
.EnergyBars:            ld      a,(PlayerEnergy)
                        srl     a                   ; energy = energy / 2 so 31 per bar
                        CallIfALTNusng  31 + 1,.Draw1EnergyBar
                        CallIfALTNusng  (31*2) + 1,.Draw2EnergyBars
                        CallIfALTNusng  (31*3) + 1,.Draw3EnergyBars
.Draw4EnergyBars:       ld      e,24
                        sub     (32*3)
                        ld      d,a
                        ld      bc,EnergyBar4Start
                        call    DrawColourEBar 
                        ld      d,31
                        ld      e,24
                        ld      bc,EnergyBar3Start
                        call    DrawColourEBar                        
                        ld      d,31
                        ld      e,24
                        ld      bc,EnergyBar2Start
                        call    DrawColourEBar                        
                        ld      d,31
                        ld      e,24
                        ld      bc,EnergyBar1Start
                        call    DrawColourEBar                        
                        jp      .DoneEnergyBars
.Draw1EnergyBar:        ld      e,224
                        ld      d,a
                        ld      bc,EnergyBar1Start
                        call    DrawColourEBar                        
                        jp      .DoneEnergyBars
.Draw2EnergyBars:       ld      e,216
                        sub     31
                        ld      d,a
                        ld      bc,EnergyBar2Start
                        call    DrawColourEBar                        
                        ld      d,31
                        ld      e,216
                        ld      bc,EnergyBar1Start
                        call    DrawColourEBar                        
                        jp      .DoneEnergyBars
.Draw3EnergyBars:       ld      e,20
                        sub     31*2
                        ld      d,a
                        ld      e,20
                        ld      bc,EnergyBar3Start
                        call    DrawColourEBar                        
                        ld      d,31
                        ld      e,20
                        ld      bc,EnergyBar2Start
                        call    DrawColourEBar                        
                        ld      d,31
                        ld      e,20
                        ld      bc,EnergyBar1Start
                        call    DrawColourEBar                        
.DoneEnergyBars:                                

                        
                        
; NEED ENERGY BAR
;PlayerEnergy                      
; BNEED LASER temp
; NEED CABIN TEMP
;NEED ALTITUDE   
; Draw compas - if in range draw station, else do planet
.DoneConsole:           ret
    


ScannerBottom           equ 190
ScannerTypeMissle       equ 2
ScannerXRangeOffset     equ $35
ScannerCenter           equ 127

ScannerDefault          equ 0
ScannerMissile          equ 2
ScannerStation          equ 4
ScannerEnemy            equ 6


SunXScaled              DB  0
SunYScaled              DB  0
SunZScaled              DB  0


ScannerColourTable:     DB  L2ColourGREEN_2, L2ColourGREEN_1, L2ColourYELLOW_4,L2ColourYELLOW_1,L2ColourCYAN_2,L2ColourCYAN_1,L2ColourRED_4,L2ColourPINK_4
ScannerColourTableAngry:DB  L2ColourRED_2, L2ColourRED_1 ; just a place holder for now

GetShipColor:           MACRO                   
                        ld      a,(ShipTypeAddr)
                        sla     a                            ; as its byte pairs * 2
                        ld      hl,ScannerColourTable
                        add     hl,a
                        ld      a,(hl)
                        ENDM
GetShipColorBright:     MACRO                   
                        ld      a,(ShipTypeAddr)
                        sla     a                            ; as its byte pairs * 2
                        inc     a
                        ld      hl,ScannerColourTable
                        add     hl,a
                        ld      a,(hl)
                        ENDM

Shift24BitScan:         MACRO   regHi, reglo
                        ld      hl,(regHi)
                        ld      b,h
                        ld      a,h
                        and     SignMask8Bit
                        ld      h,a
                        ld      a,(reglo)
                        sla     a
                        rl      l
                        rl      h
                        sla     a
                        rl      l
                        rl      h
                        sla     a
                        rl      l
                        rl      h
                        sla     a
                        rl      l
                        rl      h
                        sla     a
                        rl      l
                        rl      h
                        sla     a
                        rl      l
                        rl      h
                        ENDM
                        
SunShiftRight           MACRO   reglo, reghi, regsgn
                        ld      a,regsgn
                        srl     a
                        rr      reghi
                        rr      reglo
                        ld      regsgn,a
                        ENDM

;SunShiftPosTo15Bit:     ld      de,(SBnKzlo)
;                        ld      a,(SBnKzsgn)
;                        push    af
;                        and     SignMask8Bit
;                        ld      iyl,a
;                        ld      hl,(SBnKxlo)
;                        ld      a,(SBnKxsgn)
;                        push    af
;                        and     SignMask8Bit
;                        ld      ixl,a
;                        ld      bc,(SBnKylo)
;                        ld      a,(SBnKysgn)
;                        and     SignMask8Bit
;                        push    af
;                        ld      iyh,a
;.ShiftLoop:             ld      a,iyh
;                        or      iyl
;                        or      ixl
;                        jr      z,.ShiftBit15
;.ShiftZ:                SunShiftRight iyl, d, e
;.ShiftX:                SunShiftRight ixl, h, l
;.ShiftY:                SunShiftRight ixh, b, c
;                        jr      .ShipLoop
;.ShiftBit15:            ld      a,iyh
;                        or      iyl
;                        or      ixl
;                        jr      z,.CompletedShift
;.ShiftZ:                SunShiftRight iyl, d, e
;.ShiftX:                SunShiftRight ixl, h, l
;.ShiftY:                SunShiftRight ixh, b, c             ; finally shift to 15 bits so we can get the sign back
;.CompletedShift:        pop     af                          ; get ysgn
;                        and     SignOnly8Bit
;                        or      b
;                        ld      b,a
;                        pop     af                          ; get xsgn
;                        and     SignOnly8Bit
;                        or      h
;                        ld      h,a                        
;                        pop     af                          ; get zsgn
;                        and     SignOnly8Bit
;                        or      d
;                        ld      d,a
;                        ret
;                        
ScaleSunPos:            ld      de,(SBnKzhi)                ; de = abs z & save sign on stack
                        ld      a,d                         ; .
                        push    af                          ; .
                        and     SignMask8Bit                ; .
                        ld      d,a                         ; .
                        ld      hl,(SBnKxhi)                ; hl = abs x & save sign on stack
                        ld      a,h                         ; .
                        push    af                          ; .
                        and     SignMask8Bit                ; .
                        ld      h,a                         ; .
                        ld      bc,(SBnKyhi)                ; bc = abs y & save sign on stack
                        ld      a,b                         ; .
                        push    af                          ; .
                        and     SignMask8Bit                ; .
                        ld      b,a                         ; .
.ShiftLoop:             ld      a,b                         ; Scale down to an 8 bit value
                        or      d                           ; .
                        or      h                           ; .
                        jr      z,.Shifted                  ; .
                        ShiftBCRight1                       ; .
                        ShiftHLRight1                       ; .
                        ShiftDERight1                       ; .
                        jr      .ShiftLoop
.Shifted:               ld      a,c                         ; See if we already have 7 bit
                        or      l                           ; 
                        or      d                           ; 
                        and     $80                         ; 
                        jr      z,.NoAdditionalShift        ;
                        ShiftBCRight1                       ; we want 7 bit 
                        ShiftHLRight1                       ; to acommodate the sign
                        ShiftDERight1                       ; .
.NoAdditionalShift:     pop     af                          ; get ysgn
                        and     SignOnly8Bit                ; 
                        ld      b,a                         ; bc = shifted signed Y
                        pop     af                          ; get xsgn
                        and     SignOnly8Bit                ;
                        ld      h,a                         ; hl = shifted signed X 
                        pop     af                          ; get zsgn
                        and     SignOnly8Bit                ;
                        ld      d,a                         ; de = shifted signed Z
                        ret
 


UpdateCompassSun:       MMUSelectSun
                        call    ScaleSunPos                 ; get as 7 bit signed
                        push    bc,,de,,hl,,de              ; save to stack Y, Z, X and copy of X scaled and signed hihg = sign, low = 7 bit value
.normaliseYSqr:         ld      d,c                         ; bc = y ^ 2 
                        ld      e,c                         ; .
                        mul                                 ; .
                        ld      bc,de                       ; .
.normaliseXSqr:         ld      d,l                         ; hl = x ^ 2
                        ld      e,l                         ; .
                        mul                                 ; .
                        ex      de,hl                       ; .
.normaliseZSqr:         pop     de                          ; get saved from stack 2
                        ld      d,e                         ; de = z ^ 
                        mul                                 ; .
.normaliseSqrt:         add     hl,de                       ; hl = x^2 + y^2 + x^2
                        add     hl,bc       
                        ex      de,hl
                        call    asm_sqrt                    ; (Q) = hl = sqrt (x^2 + y^2 + x^2)
                        ; if h <> 0 then more difficult
                        ld      d,l                         ; iyl = q
                        ld      iyl,d                       ; .
.NormaliseX:            pop     hl                          ; hl x scaled
                        ld      a,h                         ; c = sign
                        and     SignOnly8Bit                ; .
                        ld      c,a                         ; .
                        push    bc                          ; save sign to stack
                        ld      a,l                         ; a = 8 bit abs z
                        call    AequAdivQmul96ABS              ; e = a /q * 96 (d was already loaded with q)
                        ld      e,a                         ; .
                        EDiv10Inline                        ; a = e / 10
                        ld      a,h                         ; .
                        pop     bc                          ; retrieve sign
                        cp      0
                        jr      z,.DoneNormX                 ; in case we end up with - 0
                        bit     7,c                         ; if sign is negative then 2'c value
                        jr      z,.DoneNormX 
                        neg
.DoneNormX:             ld      ixh,a                       ; ixh = (signed 2's c x /q * 96) / 10
.NormaliseZ:            ld      d,iyl                       ; d = q
                        pop     hl                          ; hl z scaled
                        ld      a,h                         ; c = sign
                        and     SignOnly8Bit                ; .
                        ld      c,a                         ; .
                        push    bc                          ; save sign to stack
                        ld      a,l                         ; e = a /q * 96
                        call    AequAdivQmul96ABS              ; .
                        ld      e,a                         ; a = e / 10
                        EDiv10Inline                        ; .
                        ld      a,h                         ; retrieve sign
                        pop     bc                          ; retrieve sign
                        bit     7,c                         ; if sign is negative then 2'c value
                        jr      z,.DoneNormZ 
                        neg
.DoneNormZ:             ld      ixl,a                       ; .
.NormaliseY:            ld      d,iyl                       ; d = q
                        pop     hl                          ; hl y scaled
                        ld      a,h                         ; c = sign
                        and     SignOnly8Bit                ; .
                        ld      c,a                         ; .
                        push    bc                          ; save sign to stack
                        ld      a,l                         ; a = 8 bit signed z
                        call    AequAdivQmul96ABS              ; .
                        ld      e,a                         ; a = e / 10
                        EDiv10Inline                        ; .
                        ld      a,h                         ; retrieve sign
                        pop     bc                          ; retrieve sign
                        cp      0
                        jr      z,.DoneNormY                 ; in case we end up with - 0
                        bit     7,c                         ; if sign is negative then 2'c value
                        jr      z,.DoneNormY
                        neg
.DoneNormY:             ld      b,a                       ; .
                        ld      c,ixh
.SetSprite:             MMUSelectSpriteBank
                        call    compass_sun_move
                        ld      a,ixl
                        bit     7,a
                        jr      nz,.SunBehind
.SunInfront:            call    show_compass_sun_infront
                        ret
.SunBehind:             call    show_compass_sun_behind                        
                        ret
                        
UpdateCompassStation:   MMUSelectShipBankN 0

                        call    ScaleSunPos                 ; get as 7 bit signed
                        push    bc,,de,,hl,,de              ; save to stack Y, Z, X and copy of X scaled and signed hihg = sign, low = 7 bit value
.normaliseYSqr:         ld      d,c                         ; bc = y ^ 2 
                        ld      e,c                         ; .
                        mul                                 ; .
                        ld      bc,de                       ; .
.normaliseXSqr:         ld      d,l                         ; hl = x ^ 2
                        ld      e,l                         ; .
                        mul                                 ; .
                        ex      de,hl                       ; .
.normaliseZSqr:         pop     de                          ; get saved from stack 2
                        ld      d,e                         ; de = z ^ 
                        mul                                 ; .
.normaliseSqrt:         add     hl,de                       ; hl = x^2 + y^2 + x^2
                        add     hl,bc       
                        ex      de,hl
                        call    asm_sqrt                    ; (Q) = hl = sqrt (x^2 + y^2 + x^2)
                        ; if h <> 0 then more difficult
                        ld      d,l                         ; iyl = q
                        ld      iyl,d                       ; .
.NormaliseX:            pop     hl                          ; hl x scaled
                        ld      a,h                         ; c = sign
                        and     SignOnly8Bit                ; .
                        ld      c,a                         ; .
                        push    bc                          ; save sign to stack
                        ld      a,l                         ; a = 8 bit abs z
                        call    AequAdivQmul96ABS              ; e = a /q * 96 (d was already loaded with q)
                        ld      e,a                         ; .
                        EDiv10Inline                        ; a = e / 10
                        ld      a,h                         ; .
                        pop     bc                          ; retrieve sign
                        cp      0
                        jr      z,.DoneNormX                 ; in case we end up with - 0
                        bit     7,c                         ; if sign is negative then 2'c value
                        jr      z,.DoneNormX 
                        neg
.DoneNormX:             ld      ixh,a                       ; ixh = (signed 2's c x /q * 96) / 10
.NormaliseZ:            ld      d,iyl                       ; d = q
                        pop     hl                          ; hl z scaled
                        ld      a,h                         ; c = sign
                        and     SignOnly8Bit                ; .
                        ld      c,a                         ; .
                        push    bc                          ; save sign to stack
                        ld      a,l                         ; e = a /q * 96
                        call    AequAdivQmul96ABS              ; .
                        ld      e,a                         ; a = e / 10
                        EDiv10Inline                        ; .
                        ld      a,h                         ; retrieve sign
                        pop     bc                          ; retrieve sign
                        bit     7,c                         ; if sign is negative then 2'c value
                        jr      z,.DoneNormZ 
                        neg
.DoneNormZ:             ld      ixl,a                       ; .
.NormaliseY:            ld      d,iyl                       ; d = q
                        pop     hl                          ; hl y scaled
                        ld      a,h                         ; c = sign
                        and     SignOnly8Bit                ; .
                        ld      c,a                         ; .
                        push    bc                          ; save sign to stack
                        ld      a,l                         ; a = 8 bit signed z
                        call    AequAdivQmul96ABS              ; .
                        ld      e,a                         ; a = e / 10
                        EDiv10Inline                        ; .
                        ld      a,h                         ; retrieve sign
                        pop     bc                          ; retrieve sign
                        cp      0
                        jr      z,.DoneNormY                 ; in case we end up with - 0
                        bit     7,c                         ; if sign is negative then 2'c value
                        jr      z,.DoneNormY
                        neg
.DoneNormY:             ld      b,a                       ; .
                        ld      c,ixh
.SetSprite:             MMUSelectSpriteBank
                        call    compass_sun_move
                        ld      a,ixl
                        bit     7,a
                        jr      nz,.SunBehind
.SunInfront:            call    show_compass_sun_infront
                        ret
.SunBehind:             call    show_compass_sun_behind                        
                        ret
                        

UpdateScannerSun:       MMUSelectSun
                        Shift24BitScan  SBnKyhi, SBnKylo
.IsItInRange:           ld      a,(SBnKxsgn)                ; if the high byte is not
                        ld      hl,SBnKysgn                 ; a sign only
                        or      (hl)                        ; then its too far away
                        ld      hl,SBnKzsgn                 ; for the scanner to draw
                        or      (hl)                        ; so rely on the compass
                        and     SignMask8Bit                ;
                        ret     nz                          ;
.ItsInRange:            ld      hl,(SBnKzlo)                ; we will get unsigned values
                        ld      de,(SBnKxlo)
                        ld      bc,(SBnKylo)
                        ld      a,h
                        or      d
                        or      b
                        and     %11000000
                        ret     nz                          ; if distance Hi > 64 on any ccord- off screen
.MakeX2Compliment:      ld      a,(SBnKxsgn)
                        bit     7,a
                        jr      z,.absXHi
                        NegD                                
.absXHi:                ld      a,d
                        add     ScannerX           
                        ld      ixh,a                       ; store adjusted X in ixh
.ProcessZCoord:         srl     h
                        srl     h
.MakeZ2Compliment:      ld      a,(SBnKzsgn)
                        bit     7,a
                        jr      z,.absZHi
                        NegH
.absZHi:                ld      a,ScannerY
                        sub     h
                        ld      iyh,a                       ; make iyh adjusted Z = row on screen
.ProcessStickLength:    srl     b                           ; divide b by 2
                        jr      nz,.StickHasLength
.Stick0Length:          ld      a,iyh                       ; abs stick end is row - length   
                        ld      iyl,a    
                        MMUSelectLayer2  
                        jp      .NoStick
.StickHasLength:        ld      a,(SBnKysgn)                ; if b  =  0 then no line
                        bit     7,a
                        jr      z,.absYHi
                        NegB
.absYHi:                ld      a,iyh
.SetStickPos:           sub     b
                        JumpIfALTNusng ScannerBottom, .StickOnScreen
                        ld      a,ScannerBottom
.StickOnScreen:         ld      iyl,a                       ; iyh is again stick end point   
                        ld      ixl,a
                        ld      b,iyh                       ; from row
                        ld      c,ixh                       ; from col
                        ld      d,iyl                       ; to row
                        ld      e,L2SunScanner
                        MMUSelectLayer2  
                        call    l2_draw_vert_line_to
.NoStick:               ld      b,iyl                       ; row
                        ld      c,ixh                       ; col
                        ld      a,L2SunScannerBright
                        call    l2_plot_pixel
                        ld      b,iyl
                        ld      c,ixh
                        inc     c
                        ld      a,L2SunScannerBright
                        call    l2_plot_pixel
                        ret

; This will do a planet update if we are not in space station range
UpdateScannerPlanet:    
          
; As the space station is always ship 0 then we can just use the scanner
                        
; This will go though all the universe ship data banks and plot, for now we will just work on one bank
UpdateScannerShip:      ld      a,(UBnKexplDsp)             ; if bit 4 is clear then ship should not be drawn
                        bit     4,a                         ; .
                        ;DEBUG ret     z                           ; .
                        ld      a,(ShipTypeAddr)            ; if its a planet or sun, do not display
                        bit     7,a
                        ret     nz
; DEBUG Add in station types later                       
.NotMissile:            ld      hl,(UBnKzlo)
                        ld      de,(UBnKxlo)
                        ld      bc,(UBnKylo)
                        ld      a,h
                        or      d
                        or      b
                        and     %11000000
                        ret     nz                          ; if distance Hi > 64 on any ccord- off screen
.MakeX2Compliment:      ld      a,(UBnKxsgn)
                        bit     7,a
                        jr      z,.absXHi
                        NegD                                
.absXHi:                ld      a,d
                        add     ScannerX           
                        ld      ixh,a                       ; store adjusted X in ixh
.ProcessZCoord:         srl     h
                        srl     h
.MakeZ2Compliment:      ld      a,(UBnKzsgn)
                        bit     7,a
                        jr      z,.absZHi
                        NegH
.absZHi:                ld      a,ScannerY
                        sub     h
                        ld      iyh,a                       ; make iyh adjusted Z = row on screen
.ProcessStickLength:    srl     b                           ; divide b by 2
                        jr      nz,.StickHasLength
.Stick0Length:          ld      a,iyh                       ; abs stick end is row - length   
                        ld      iyl,a    
                        ld      a,ixl
                        GetShipColorBright
                        MMUSelectLayer2  
                        jp      .NoStick
.StickHasLength:        ld      a,(UBnKysgn)                ; if b  =  0 then no line
                        bit     7,a
                        jr      z,.absYHi
                        NegB
.absYHi:                ld      a,iyh
.SetStickPos:           sub     b
                        JumpIfALTNusng ScannerBottom, .StickOnScreen
                        ld      a,ScannerBottom
.StickOnScreen:         ld      iyl,a                       ; iyh is again stick end point   
                        GetShipColor
                        ld      ixl,a
                        ld      b,iyh                       ; from row
                        ld      c,ixh                       ; from col
                        ld      d,iyl                       ; to row
                        ld      e,ixl                       ; colur will only be green or yellow for now
                        push    hl
                        MMUSelectLayer2  
                        call    l2_draw_vert_line_to
                        pop     hl
                        inc     hl
                        ld      a,(hl)
.NoStick:               ld      b,iyl                       ; row
                        ld      c,ixh                       ; col
                        push    af
                        call    l2_plot_pixel
                        pop     af
                        ld      b,iyl
                        ld      c,ixh
                        inc     c
                        call    l2_plot_pixel
                        ret
                        
