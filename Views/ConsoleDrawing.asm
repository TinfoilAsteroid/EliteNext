; bc = start position, d = length, e = colour
;                        DEFINE MISSILEDIAGNOSTICS 1
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

MissileDiagPositive:    ld      d,"P"
                        call    l2_print_chr_at
                        ret

MissileDiagNegative:    ld      d,"N"
                        call    l2_print_chr_at
                        ret

MissileDiagZero:        ld      d,"Z"
                        call    l2_print_chr_at
                        ret

MissileValue:           ld      e,$FF
                        cp      0
                        push    af
                        call    z,MissileDiagZero
                        pop     af
                        ret     z
                        bit     7,a
                        push    af
                        call    z,MissileDiagNegative
                        pop     af
                        ret     z
                        call    nz,MissileDiagPositive
                        ret

Hex2Char:       DB "0123456789ABCDEF"

MissileHexDigit:        push    af,,hl,,bc,,de
                        and     $0F
                        ld      hl, Hex2Char
                        add     hl,a
                        ld      d,(hl)
                        call    l2_print_chr_at
                        pop     af,,hl,,bc,,de
                        ret

MissileHexToChar:       swapnib
                        and     $0F
                        ld      e,$FF
                        JumpIfALTNusng 8,.SkipNeg
                        ld      e,$68
                        sub     8
.SkipNeg:               call    MissileHexDigit
                        swapnib
                        push    af
                        ld      a,c
                        add     8
                        ld      c,a
                        pop     af
                        and     $0F
                        call    MissileHexDigit
                        ret

MissileValue2Byte:      ld      e,$FF
                        ld      a,(hl)
                        inc     hl
                        or      (hl)
                        cp      0
                        push    af
                        call    z,MissileDiagZero
                        pop     af
                        ret     z
                        ld      a,(hl)
                        bit     7,a
                        push    af
                        call    z,MissileDiagNegative
                        pop     af
                        ret     z
                        call    nz,MissileDiagPositive
                        ret

MissileDiagPrintBoiler: ld      d,"x"
                        ld      e, $30
                        ld      bc,$8088
                        call    l2_print_chr_at
                        ld      bc,$8888
                        ld      d,"z"
                        ld      e, $30
                        call    l2_print_chr_at
                        ld      bc,$9088
                        ld      d,"s"
                        ld      e, $30
                        call    l2_print_chr_at
                        ld      bc,$9048
                        ld      d,"n"
                        ld      e, $30
                        call    l2_print_chr_at
                        ld      bc,$8048
                        ld      d,"s"
                        ld      e, $30
                        call    l2_print_chr_at
                        ld      bc,$8848
                        ld      d,"r"
                        ld      e, $30
                        call    l2_print_chr_at
                        ret

MissileDiagnotics:      MMUSelectLayer2
                        call    MissileDiagPrintBoiler
                        ld      e,$FF
                        ld      bc,$8090
                        ld      a,(TacticsRotX)
                        call    MissileHexToChar; MissileValue
                        ld      bc,$8890
                        ld      a,(TacticsRotZ)
                        call    MissileHexToChar; MissileValue
                        ld      bc,$9090
                        ld      a,(TacticsSpeed)
                        call    MissileHexToChar; MissileValue
.VectorSideX:           ld      bc,$8050
                        ld      a,(TacticsSideX+1)
                        call    MissileHexToChar;issileValue2Byte
                        ld      bc,$8062
                        ld      a,(TacticsSideY+1)
                        call    MissileHexToChar
                        ld      bc,$8074
                        ld      a,(TacticsSideZ+1)
                        call    MissileHexToChar                        
.VectorRoofX:           ld      bc,$8850
                        ld      a,(TacticsRoofX+1)
                        call    MissileHexToChar
                        ld      bc,$8862
                        ld      a,(TacticsRoofY+1)
                        call    MissileHexToChar
                        ld      bc,$8874
                        ld      a,(TacticsRoofZ+1)
                        call    MissileHexToChar                        
.VectorNoseX:           ld      bc,$9050
                        ld      a,(TacticsNoseX+1)
                        call    MissileHexToChar
                        ld      bc,$9062
                        ld      a,(TacticsNoseY+1)
                        call    MissileHexToChar
                        ld      bc,$9074
                        ld      a,(TacticsRoofZ+1)
                        call    MissileHexToChar                        
                        ret

UpdateConsole:          IFDEF   MISSILEDIAGNOSTICS
                                call    MissileDiagnotics
                        ENDIF
                        ld      a,(DELTA)
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
.FrontShield:           ld      a,(ForeShield)
                        srl     a
                        srl     a
                        srl     a               
                        ld      bc,FShieldStart
                        ld      d,a
                        call    DrawColourCodedBar
.AftShield:             ld      a,(AftShield)
                        srl     a
                        srl     a
                        srl     a               
                        ld      bc,AShieldStart
                        ld      d,a
                        call    DrawColourCodedBar                          
.SpriteDraw:            MMUSelectSpriteBank          
                        
.DrawCompases:          call    show_sprite_sun_compass
                        call    show_sprite_planet_compass
                        call    show_sprite_station_compass

.DrawECM:               ld      a,(ECMCountDown)   
                        JumpIfAIsZero   .HideECM                                                 
.ShowECM:               call    show_ecm_sprite                                                 
                        jp      .ProcessedECM                                              
.HideECM:               call    sprite_ecm_hide  
.ProcessedECM:                      
.DrawMissiles:          ld      a,(NbrMissiles)  
                        ld      iyl,a
                        JumpIfAIsZero   .HideAllMissiles                    ; First off do we have any missiles                                                     
.DrawMissile_1:         ld      a,(MissileTargettingFlag)                   ; have we the targetting flag
                        JumpIfAEqNusng  StageMissileNotTargeting,.MissileReady                   
                        JumpIfAEqNusng  StageMissileTargeting,   .MissileArmed
.Missile1Locked:        call    show_missile_1_locked    
                        jp      .DrawMissile_2           
.MissileReady:          call    show_missile_1_ready     
                        jp      .DrawMissile_2           
.MissileArmed:          call    show_missile_1_armed     
.DrawMissile_2:         ld      a,iyl                    
                        JumpIfALTNusng 2, .Only1Missile  
                        call    show_missile_2_ready     
.DrawMissile_3:         ld      a,iyl                    
                        JumpIfALTNusng 3, .Only2Missiles 
                        call    show_missile_3_ready     
.DrawMissile_4:         ld      a,iyl                    
                        JumpIfALTNusng 4, .Only2Missiles 
                        call    show_missile_4_ready                       
                        ret                              
.HideAllMissiles:       call    sprite_missile_1_hide    
.Only1Missile:          call    sprite_missile_2_hide    
.Only2Missiles:         call    sprite_missile_3_hide    
.Only3Missiles:         call    sprite_missile_4_hide   
;PlayerEnergy                      
; BNEED LASER temp
; NEED CABIN TEMP
;NEED ALTITUDE   
; Draw compas - if in range draw station, else do planet                        
.EnergyBars:            ld      a,(PlayerEnergy)
                        srl     a                   ; energy = energy / 2 so 31 per bar
                        JumpIfALTNusng  31 + 1,     Draw1EnergyBar
                        JumpIfALTNusng  (31*2) + 1, Draw2EnergyBars
                        JumpIfALTNusng  (31*3) + 1, Draw3EnergyBars 
                        jp      Draw4EnergyBars
    
Draw1EnergyBar:         ld      e,224
                        ld      d,a
                        ld      bc,EnergyBar1Start
                        call    DrawColourEBar                        
                        ret
Draw2EnergyBars:        ld      e,216
                        sub     31
                        ld      d,a
                        ld      bc,EnergyBar2Start
                        call    DrawColourEBar                        
                        ld      d,31
                        ld      e,216
                        ld      bc,EnergyBar1Start
                        call    DrawColourEBar                        
                        ret
Draw3EnergyBars:        ld      e,20
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
                        ret
Draw4EnergyBars:        ld      e,24
                        sub     31*3
                        JumpIfALTNusng 31,.NoMax
.Max                    ld      a,31
.NoMax:                 ld      d,a
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
                        ret

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

                        ;   ShipTypeNormal
ScannerColourTable:       DB  L2ColourGREEN_2,    L2ColourGREEN_1, L2ColourYELLOW_4,  L2ColourYELLOW_1,   L2ColourCYAN_2, L2ColourCYAN_1, L2ColourRED_4,  L2ColourPINK_4
ScannerColourTableHostile:DB  L2ColourRED_2,      L2ColourRED_1,   L2ColourRED_2,     L2ColourRED_1,      L2ColourRED_2,  L2ColourRED_1,  L2ColourRED_2,  L2ColourRED_1; just a place holder for now

GetShipColor:           MACRO     
                        ld      hl,ScannerColourTable
                        ld      a,(ShipTypeAddr)         ; for now to bypass hostile missile
                        cp      1                        ; for now to bypass hostile missile
                        jr      z,.UsingColourTable    ; for now to bypass hostile missile
                        ld      a,(ShipNewBitsAddr)
                        and     ShipIsHostile
                        jr      z,.UsingColourTable
.UsingHostileColour:    ld      hl,ScannerColourTableHostile
.UsingColourTable:      ld      a,(ShipTypeAddr)
                        sla     a                            ; as its byte pairs * 2
                        add     hl,a
                        ld      a,(hl)
                        ENDM
GetShipColorBright:     MACRO                   
                        ld      hl,ScannerColourTable
                        ld      a,(ShipTypeAddr)         ; for now to bypass hostile missile
                        cp      1                        ; for now to bypass hostile missile
                        jr      z,.UsingColourTable    ; for now to bypass hostile missile
                        ld      a,(ShipNewBitsAddr)
                        and     ShipIsHostile
                        jr      z,.UsingColourTable
.UsingHostileColour:    ld      hl,ScannerColourTableHostile
.UsingColourTable:      ld      a,(ShipTypeAddr)
                        sla     a                            ; as its byte pairs * 2
                        inc     a
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
ScalePlanetPos:         ld      de,(P_BnKzhi)               ; de = abs z & save sign on stack
                        ld      a,d                         ; .
                        push    af                          ; .
                        and     SignMask8Bit                ; .
                        ld      d,a                         ; .
                        ld      hl,(P_BnKxhi)               ; hl = abs x & save sign on stack
                        ld      a,h                         ; .
                        push    af                          ; .
                        and     SignMask8Bit                ; .
                        ld      h,a                         ; .
                        ld      bc,(P_BnKyhi)                ; bc = abs y & save sign on stack
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
                        or      e                           ; 
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
                        or      e                           ; 
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

;compass sun
;            if value is still 24 bit
;                copy xhi/xsgn y and z to xxx15 ([2 1 0 ] [ 5 4 3] [ 8 7 6 ]
;                normalise vector (note this assumes sun is just sign byte+ 2 bytes)
;                tempk39 = OR 3 low bytes
;                tempkA = OR 3 high bytes
;                 TAL2:    repeat
;                             asl tempka tempk39
;                             exit if carry set
;                             x coord << 1
;                             y corrd << 1
;                             z coord << 1
;                          until carry clear   
;                 TA2:     shift x y and z right one and put sign bit in from sign bytes
;                          now XX15 holds sign + 7 bit bytes maximused for coords
;                          RQ = AP = X ^ 2
;                          TP = AP = Y ^ 2
;                          RQ = RQ + TP
;                          TP = AP = Z ^ 2
;                          RQ = RQ + TP
;                          Q = SQRT (RQ)
;                          for each coord - A = A/Q * 3/ 8
;                
;                

UpscaleSunPosition:     ld      de,(SBnKzhi)                ; de = abs z & save sign on stack
                        ld      hl,(SBnKxhi)                ; hl = abs x & save sign on stack
                        ld      bc,(SBnKyhi)                ; bc = abs y & save sign on stack
                        ld      a,d
                        and     SignOnly8Bit
                        srl     a
                        ld      iyl,a
                        ld      a,h
                        and     SignOnly8Bit
                        or      iyl
                        srl     a
                        ld      a,b
                        and     SignOnly8Bit
                        or      iyl
                        ld      iyl,a                       ; IYL now equals YXH00000 where letters = sign bits
                        ClearSignBit d
                        ClearSignBit h
                        ClearSignBit b
                        ld      a,b
                        or      e
                        or      h
                        or      l
                        or      b
                        or      c
                        jr      z, .Setto1                 ; to prevent and infinite loop in upscale if all zero
                        ld      a,d
                        or      e
                        or      h
                        sla     a
                        jr      c,.DoneCalc
                        jr      z,.DoneCalc                 
.UpscaleLoop:           ShiftDELeft1
                        ShiftHLLeft1
                        ShiftBCLeft1
                        sla     a
                        jr      c,.DoneCalc
                        jp      .UpscaleLoop
.DoneCalc               ShiftDERight1
                        ShiftHLRight1
                        ShiftBCRight1
.NowSetResultInLowByte: ld      e,d
                        ld      l,h
                        ld      c,b
                        ld      a,iyl
                        and     SignOnly8Bit
                        ld      b,a
                        ld      a,iyl
                        sla     a
                        ld      iyl,a
                        and     SignOnly8Bit
                        ld      h,a
                        ld      a,iyl
                        sla     a
                        and     SignOnly8Bit
                        ld      d,a
                        ret
.Setto1:                ld      a,1
                        ld      c,a
                        ld      e,a
                        ld      l,a
                        ld      a,iyl
                        sla     a
                        sla     a
                        and     SignOnly8Bit
                        or      e
                        ld      e,a
                        ret


UpdateCompassSun:       MMUSelectSun
                        call    ScaleSunPos                 ; get as 7 bit signed
                        push    bc,,hl,,de                  ; +3 save to stack Y, X and Z scaled and signed hihg = sign, low = 7 bit value
.normaliseYSqr:         ld      d,c                         ; bc = y ^ 2 
                        ld      e,c                         ; .
                        mul                                 ; .
                        ld      bc,de                       ; .
.normaliseXSqr:         ld      d,l                         ; hl = x ^ 2
                        ld      e,l                         ; .
                        mul                                 ; .
                        ex      de,hl                       ; .
.normaliseZSqr:         pop     de                          ; +2 get Z saved from stack so now stack contains Y Z X
                        ld      d,e                         ; de = z ^ 
                        mul                                 ; .
.normaliseSqrt:         add     hl,de                       ; de = x^2 + y^2 + z^2
                        add     hl,bc                       ; .
                        ex      de,hl                       ; .
                        call    asm_sqrt                    ; (Q) = hl = sqrt (x^2 + y^2 + x^2)
                        ; if h <> 0 then more difficult
                        ld      d,l                         ; iyl = q
                        ld      iyl,d                       ; .
.NormaliseX:            pop     hl                          ; +1 get back hl x scaled
                        ld      a,h                         ; c = sign
                        and     SignOnly8Bit                ; .
                        ld      c,a                         ; .
                        push    bc                          ; +2 save bc temporarily as it will get altered
                        ld      a,l                         ; a = 8 bit abs z
                        call    AequAdivQmul96ABS           ; e = a /q * 96 (d was already loaded with q)
                        ld      e,a                         ; .
                        EDiv10Inline                        ; a = e / 10
                        ld      a,h                         ; .
                        pop     bc                          ; +1 retrieve bc
                        cp      0                           ; if result in h was 0 then done 
                        jr      z,.DoneNormX                ; in case we end up with - 0
                        bit     7,c                         ; if sign is negative then 2'c value
                        jr      z,.DoneNormX 
                        neg
.DoneNormX:             ld      ixh,a                       ; ixh = (signed 2's c x /q * 96) / 10
.NormaliseY:            ld      d,iyl                       ; d = q
                        pop     hl                          ; +0 hl y scaled
                        ld      a,h                         ; c = sign
                        and     SignOnly8Bit                ; .
                        ld      c,a                         ; .
                        push    bc                          ; +1 save sign to stack
                        ld      a,l                         ; a = 8 bit signed z
                        call    AequAdivQmul96ABS           ; .
                        ld      e,a                         ; a = e / 10
                        EDiv10Inline                        ; .
                        ld      a,h                         ; retrieve sign
                        pop     bc                          ; +1 retrieve sign
                        cp      0
                        jr      z,.DoneNormY                ; in case we end up with - 0
                        bit     7,c                         ; if sign is negative then 2'c value
                        jr      z,.DoneNormY
                        neg                                 ;
.DoneNormY:             ld      b,a                         ; result from Y
                        ld      c,ixh                       ; x = saved X
                        call    LimitCompassBC
.SetSprite:             MMUSelectSpriteBank
                        call    compass_sun_move
                        ld      a,(SBnKzsgn)
                        bit     7,a
                        jr      nz,.SunBehind
.SunInfront:            call    show_compass_sun_infront
                        ret
.SunBehind:             call    show_compass_sun_behind                        
                        ret

; takes B = Y and C = X, limits to +/-16 in each direction
LimitCompassBC:         ld      a,b
                        JumpIfALTNsigned -16, .ClampBNeg16
                        JumpIfAGTENsigned 17, .ClampBPos16
.ClampBNeg16:           ld      b,-16
                        jp      .CheckCReg
.ClampBPos16:           ld      b,16
.CheckCReg:             ld      a,c
                        JumpIfALTNsigned -16, .ClampCNeg16
                        JumpIfAGTENsigned 17, .ClampCPos16
                        ret
.ClampCNeg16:           ld      c,-16
                        ret
.ClampCPos16:           ld      c,16
                        ret

UpdateCompassPlanet:    MMUSelectPlanet
                        call    ScalePlanetPos              ; get as 7 bit signed
                        push    bc,,hl,,de                  ; save to stack Y, Z, X and copy of X scaled and signed hihg = sign, low = 7 bit value
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
.normaliseSqrt:         add     hl,de                       ; hl = x^2 + y^2 + z^2
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
                        jr      z,.DoneNormX                ; in case we end up with - 0
                        bit     7,c                         ; if sign is negative then 2'c value
                        jr      z,.DoneNormX 
                        neg
.DoneNormX:             ld      ixh,a                       ; ixh = (signed 2's c x /q * 96) / 10
.NormaliseY:            ld      d,iyl                       ; d = q
                        pop     hl                          ; hl y scaled
                        ld      a,h                         ; c = sign
                        and     SignOnly8Bit                ; .
                        ld      c,a                         ; .
                        push    bc                          ; save sign to stack
                        ld      a,l                         ; a = 8 bit signed z
                        call    AequAdivQmul96ABS           ; .
                        ld      e,a                         ; a = e / 10
                        EDiv10Inline                        ; .
                        ld      a,h                         ; retrieve sign
                        pop     bc                          ; retrieve sign
                        cp      0
                        jr      z,.DoneNormY                 ; in case we end up with - 0
                        bit     7,c                         ; if sign is negative then 2'c value
                        jr      z,.DoneNormY
                        neg                                 ;
.DoneNormY:             ld      b,a                         ; result from Y
                        ld      c,ixh                       ; x = saved X
.SetSprite:             MMUSelectSpriteBank
                        call    LimitCompassBC
                        call    compass_station_move
                        ld      a,(P_BnKzsgn)
                        bit     7,a
                        jr      nz,.PlanetBehind
.PlanetInfront:         call    show_compass_station_infront
                        ret
.PlanetBehind:          call    show_compass_station_behind                        
                        ret

UpdatePlanetSun:        MMUSelectPlanet
                        Shift24BitScan  P_BnKyhi, P_BnKylo
.IsItInRange:           ld      a,(P_BnKxsgn)                ; if the high byte is not
                        ld      hl,P_BnKysgn                 ; a sign only
                        or      (hl)                        ; then its too far away
                        ld      hl,P_BnKzsgn                 ; for the scanner to draw
                        or      (hl)                        ; so rely on the compass
                        and     SignMask8Bit                ;
                        ret     nz                          ;
.ItsInRange:            ld      hl,(P_BnKzlo)                ; we will get unsigned values
                        ld      de,(P_BnKxlo)
                        ld      bc,(P_BnKylo)
                        ld      a,h
                        or      d
                        or      b
                        and     %11000000
                        ret     nz                          ; if distance Hi > 64 on any ccord- off screen
.MakeX2Compliment:      ld      a,(P_BnKxsgn)
                        bit     7,a
                        jr      z,.absXHi
                        NegD                                
.absXHi:                ld      a,d
                        add     ScannerX           
                        ld      ixh,a                       ; store adjusted X in ixh
.ProcessZCoord:         srl     h
                        srl     h
.MakeZ2Compliment:      ld      a,(P_BnKzsgn)
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
.StickHasLength:        ld      a,(P_BnKysgn)                ; if b  =  0 then no line
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
                        jr      z,.DoneNormY                ; in case we end up with - 0
                        bit     7,c                         ; if sign is negative then 2'c value
                        jr      z,.DoneNormY
                        neg
.DoneNormY:             ld      b,a                         ; .
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
UpdateScannerPlanet:    MMUSelectPlanet
                        Shift24BitScan  P_BnKyhi, P_BnKylo
.IsItInRange:           ld      a,(P_BnKxsgn)                ; if the high byte is not
                        ld      hl,P_BnKysgn                 ; a sign only
                        or      (hl)                        ; then its too far away
                        ld      hl,P_BnKzsgn                 ; for the scanner to draw
                        or      (hl)                        ; so rely on the compass
                        and     SignMask8Bit                ;
                        ret     nz                          ;
.ItsInRange:            ld      hl,(P_BnKzlo)                ; we will get unsigned values
                        ld      de,(P_BnKxlo)
                        ld      bc,(P_BnKylo)
                        ld      a,h
                        or      d
                        or      b
                        and     %11000000
                        ret     nz                          ; if distance Hi > 64 on any ccord- off screen
.MakeX2Compliment:      ld      a,(P_BnKxsgn)
                        bit     7,a
                        jr      z,.absXHi
                        NegD                                
.absXHi:                ld      a,d
                        add     ScannerX           
                        ld      ixh,a                       ; store adjusted X in ixh
.ProcessZCoord:         srl     h
                        srl     h
.MakeZ2Compliment:      ld      a,(P_BnKzsgn)
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
.StickHasLength:        ld      a,(P_BnKysgn)                ; if b  =  0 then no line
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

          
; As the space station is always ship 0 then we can just use the scanner
                        
; This will go though all the universe ship data banks and plot, for now we will just work on one bank
; Supports 24 bit xyz
UpdateScannerShip:      ld      a,(UBnKexplDsp)             ; if bit 4 is clear then ship should not be drawn
                        bit     4,a                         ; .
                        ;DEBUG ret     z                           ; .
                        ld      a,(ShipTypeAddr)            ; if its a planet or sun, do not display
                        bit     7,a
                        ret     nz
; DEBUG Add in station types later                       
.NotMissile:            ld      a,(UBnKzsgn)                ; any high byte causes skip
                        ld      b,a
                        ld      a,(UBnKxsgn)                ; .
                        ld      c,a
                        ld      a,(UBnKysgn)                ; .
                        or      b                           ; .
                        or      c                           ; .
                        and     SignMask8Bit                ; so we are checking to see if very high byte is non zero
                        ret     nz
.CheckLowAndMidByte:    ld      hl,(UBnKzlo)                ; Any distance > 64 causes skip
                        ld      de,(UBnKxlo)                ; 
                        ld      bc,(UBnKylo)                ;
                        ld      a,h                         ;
                        or      d                           ;
                        or      b                           ;
                        and     %11000000                   ;
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
                        
