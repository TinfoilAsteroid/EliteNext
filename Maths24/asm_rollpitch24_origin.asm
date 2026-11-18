RotEquRotDiv256             MACRO   Rotator, RotatorDecimal
                            ld      a,(Rotator)             ; Alpha = alpha / 256 signed 
                            bit     7,a                     ; determine if its + or -
                            ld      hl,0                    ; .
                            jp      z,.RotPositive          ;
.RotNegative:               res     7,a                     ; 
                            ld      h,$80                   ; 
.RotPositive:               ld      (RotatorDecimal),a      ; .
                            ld      (RotatorDecimal+1),hl   ; .
                            ENDM

Rot16EquRotDiv256           MACRO   Rotator, RotatorDecimal
                            ld      a,(Rotator)             ; Alpha = alpha / 256 signed 
                            bit     7,a                     ; determine if its + or -
                            ld      hl,0                    ; .
                            jp      z,.RotPositive          ;
.RotNegative:               res     7,a                     ; 
                            ld      h,$80                   ; uses only 16 bits of rotator decimal, sign + 8 bit value
.RotPositive:               ld      l,a                     ;
                            ld      (RotatorDecimal),hl     ; .
                            ENDM

CDEEquDeltaDiv256           MACRO   SpeedDelta
                            ld      a,(SpeedDelta)          ; Speed = Delta / 256 signed 
.SpeedRelative:             ld      d,$00                   ; 
                            ld      e,a
.RotPositive:               ld      c,$80                   ; .
                            ENDM
                            
SetBHLtoAlpha:              MACRO
                            ld      a,(AlphaDecimal+2)      ; set BHL to Beta
                            ld      b,a                     ;
                            ld      hl,(AlphaDecimal)       ;
                            ENDM
                            
SetBHLtoBeta:               MACRO
                            ld      a,(BetaDecimal+2)       ; set BHL to Beta
                            ld      b,a                     ;
                            ld      hl,(BetaDecimal)        ;
                            ENDM

SetHLtoAlpha16:             MACRO
                            ld      hl,(AlphaDecimal)       ;
                            ENDM
                            
SetHLtoBeta16:              MACRO
                            ld      hl,(BetaDecimal)        ;
                            ENDM

SetBHLtoK2:                 MACRO
                            ld      a,(RPK2+2)
                            ld      b,a                     ; bhl = K2
                            ld      hl,(RPK2)               ; .
                            ENDM
                            
SetHLtoMatK2:               MACRO
                            ld      hl,(RPK2)               ; .
                            ENDM
                            
SetCDEtoDEH                 MACRO
                            ld      c,d                     ; move DE.H into CD.E for multiply
                            ld      d,e                     ; .
                            ld      e,h                     ; .
                            ENDM   
                            
SetCDEtoAHL                 MACRO
                            ld      c,a                     ; move DE.H into CD.E for multiply
                            ex      de,hl
                            ENDM   
                            
; Apply roll (alpha) and pitch (beta) takes 3 24 bit X, Y, Z and applies player roll, pitch and speed
; for readability all steps are done via macros
ApplyMyRollAndPitchIX:      RotEquRotDiv256 ALPHAFLIP, AlphaDecimal  ; Alpha = alpha / 256 signed             
.CalcBetaDecimal:           RotEquRotDiv256 BETA,  BetaDecimal  ; Beta = beta / 256 signed
                            ; k2 = y - alpha * x;
.StartK2Calc:               SetBHLtoAlpha                   ; HL.L = Alpha decimal
                            SetCDEtoX                       ; CD.E = X
.CalcAlphaX                 call    mul24Signed             ; BH.L by CD.E putting result in BCDE.HL, we want to keep DE.H
.CalcK2:                    SetCDEtoDEH                     ; CD.E = Alpha * X
                            SetBHLtoY                       ; BH.L = Y
                            call    AHLequBHLminusCDE       ; AHL = Y - (Alpha * X)
.WriteK2:                   ld      (RPK2),hl               ; RPK2 = K2
                            ld      (RPK2+2),a              ; .
                            ; z = z + beta * k2;
.StartZCalc:                SetCDEtoAHL                     ; CDE = K2 (previosly loaded to AH.L)
                            SetBHLtoBeta                    ; BH.L = Beta Decimal
.CalcBetaK2:                call    mul24Signed             ; BH.L by CD.E putting result in BCDE.HL, we want to keep DE.H
.CalcNewZ:                  SetCDEtoDEH                     ; CD.E = Beta * K2 result
                            SetBHLtoZ                       ; BH.L = Z
                            call    AHLequBHLplusCDE        ; AH.L = Z + Beta * K2
                            SaveAHLToZ                      ; New Z= Z + Beta * K2
.StartYCalc:                SetCDEtoAHL                     ; Set CD.E to New Z
                            SetBHLtoBeta                    ; Set BHL to Beta Decimal
                            ; y = k2 - z * beta;
.CalcBetaZ:                 call    mul24Signed             ; BH.L by CD.E putting result in BCDE.HL, we want to keep DE.H
.CalcNewY:                  SetCDEtoDEH                     ; CD.E now holds Z*Beta
                            SetBHLtoK2                      ; BH.L = K2
                            call    AHLequBHLminusCDE       ; AH.L = K2 - Z*Beta
.WriteNewY:                 SaveAHLToY                      ; New Y= K2 - Z*Beta
                            ;	x = x + alpha * y;                            
.StartXCalc:                SetCDEtoAHL                     ; CD.E = Y 
                            SetBHLtoAlpha                   ; BH.L = Alpha Decimal
.CalcAlphaY                 call    mul24Signed             ; DE.H = Y * Alpha
.CalcNewX:                  SetCDEtoDEH                     ; CD.E = Y * Alpha
                            SetBHLtoX                       ; BH.L = X
                            call    AHLequBHLplusCDE        ; DE.H = X + Alpha*y
.WriteNewX:                 SaveAHLToX                      ; NewX = X * Alpha*Y
.SetDeltaDecimal:           CDEEquDeltaDiv256 DELTA         ; set CDE t
.ApplySpeed:                SetBHLtoZ
                            call    AHLequBHLplusCDE
                            SaveAHLToZ
                            ret
                            
;----------------------------------------------------------------------------------------------------------------------------------
; Ship version of ApplyMyRollAndPitchIX with an extra fraction byte per axis.
; With roll / pitch rates of only 1..2 / 256 per frame, alpha * x truncated to whole raw units is 0 for any |x| below
; 128..256 raw, so nearby ships close to the centre of view never moved when the player rolled. Here each axis is
; worked as a 32 bit 2's complement value (raw * 256 + fraction) and the fraction is kept between frames.
; Products are truncated towards zero so the Minsky rotation has no drift in either direction.
; ix = 24 bit lead sign position (x, y, z each lo, hi, sign), iy = 3 fraction bytes (x, y, z). ix and iy preserved
; Its work variables (RPX32 .. RPSign) are in general_variables.asm, not here: this bank is in slot 0 and writes to
; $0000-$3FFF can be going to layer 2, so variables in this bank read back as garbage

; 32 bit 2's complement value at dest = position axis at ix+ixoff (lo, hi, sign) * 256 + fraction at iy+iyoff
RPLoadAxis:                 MACRO   dest, ixoff, iyoff
                            ld      a,(iy+iyoff)
                            ld      (dest),a
                            ld      a,(ix+ixoff)
                            ld      (dest+1),a
                            ld      a,(ix+ixoff+1)
                            ld      (dest+2),a
                            ld      a,(ix+ixoff+2)
                            ld      b,a
                            and     $7F
                            ld      (dest+3),a
                            bit     7,b
                            jr      z,.Positive
                            ld      hl,dest
                            call    RPNeg32
.Positive:
                            ENDM

; position axis at ix+ixoff and fraction at iy+iyoff = 32 bit 2's complement value at src (src is left as |src|)
RPSaveAxis:                 MACRO   src, ixoff, iyoff
                            ld      b,0
                            ld      a,(src+3)
                            and     a
                            jp      p,.Positive
                            ld      hl,src
                            call    RPNeg32
                            ld      b,$80
.Positive:                  ld      a,(src)
                            ld      (iy+iyoff),a
                            ld      a,(src+1)
                            ld      (ix+ixoff),a
                            ld      a,(src+2)
                            ld      (ix+ixoff+1),a
                            ld      a,(src+3)
                            or      b
                            ld      (ix+ixoff+2),a
                            ENDM

ApplyMyRollAndPitchFracIX:  RPLoadAxis RPX32, POS_XOFFSET, 0
                            RPLoadAxis RPY32, POS_YOFFSET, 1
                            RPLoadAxis RPZ32, POS_ZOFFSET, 2
.CalcK2:                    ld      hl,RPX32                ; K2 = y - alpha * x
                            ld      a,(ALPHAFLIP)           ; .
                            call    RPMulRot                ; .
                            ld      hl,RPY32                ; .
                            ld      de,RPK232               ; .
                            ld      bc,4                    ; .
                            ldir                            ; .
                            ld      de,RPK232               ; .
                            ld      hl,RPProd               ; .
                            call    RPSub32                 ; .
.CalcZ:                     ld      hl,RPK232               ; z = z + beta * K2
                            ld      a,(BETA)                ; .
                            call    RPMulRot                ; .
                            ld      de,RPZ32                ; .
                            ld      hl,RPProd               ; .
                            call    RPAdd32                 ; .
.CalcY:                     ld      hl,RPZ32                ; y = K2 - beta * z
                            ld      a,(BETA)                ; .
                            call    RPMulRot                ; .
                            ld      hl,RPK232               ; .
                            ld      de,RPY32                ; .
                            ld      bc,4                    ; .
                            ldir                            ; .
                            ld      de,RPY32                ; .
                            ld      hl,RPProd               ; .
                            call    RPSub32                 ; .
.CalcX:                     ld      hl,RPY32                ; x = x + alpha * y
                            ld      a,(ALPHAFLIP)           ; .
                            call    RPMulRot                ; .
                            ld      de,RPX32                ; .
                            ld      hl,RPProd               ; .
                            call    RPAdd32                 ; .
.ApplySpeed:                xor     a                       ; z = z - DELTA (raw units), as ApplyMyRollAndPitchIX
                            ld      (RPProd),a              ; .
                            ld      (RPProd+2),a            ; .
                            ld      (RPProd+3),a            ; .
                            ld      a,(DELTA)               ; .
                            ld      (RPProd+1),a            ; .
                            ld      de,RPZ32                ; .
                            ld      hl,RPProd               ; .
                            call    RPSub32                 ; .
                            RPSaveAxis RPX32, POS_XOFFSET, 0
                            RPSaveAxis RPY32, POS_YOFFSET, 1
                            RPSaveAxis RPZ32, POS_ZOFFSET, 2
                            ret

; RPProd = (hl) * a / 256, (hl) = 32 bit 2's complement, a = lead sign S7 rotator, truncated towards zero
; uses a, bc, de, hl
RPMulRot:                   ld      (RPRot),a
                            ld      de,RPAbs                ; RPAbs = |(hl)|
                            ld      bc,4                    ; .
                            ldir                            ; .
                            ld      a,(RPAbs+3)             ; .
                            ld      b,a                     ; b bit 7 = sign of (hl)
                            and     a                       ; .
                            jp      p,.Positive             ; .
                            ld      hl,RPAbs                ; .
                            call    RPNeg32                 ; .
.Positive:                  ld      a,(RPRot)               ; sign of the result
                            xor     b                       ; .
                            and     $80                     ; .
                            ld      (RPSign),a              ; .
                            ld      a,(RPRot)               ; c = |rotator|
                            and     $7F                     ; .
                            ld      c,a                     ; .
                            ld      a,(RPAbs)               ; |v| * c / 256: byte 0 of the product is dropped
                            ld      d,a                     ; .
                            ld      e,c                     ; .
                            mul     de                      ; .
                            ld      b,d                     ; b = carry in to byte 1
                            ld      a,(RPAbs+1)             ; .
                            ld      d,a                     ; .
                            ld      e,c                     ; .
                            mul     de                      ; .
                            ld      a,e                     ; .
                            add     a,b                     ; .
                            ld      (RPProd),a              ; .
                            ld      b,d                     ; (mul leaves the carry flag alone)
                            ld      a,(RPAbs+2)             ; .
                            ld      d,a                     ; .
                            ld      e,c                     ; .
                            mul     de                      ; .
                            ld      a,e                     ; .
                            adc     a,b                     ; .
                            ld      (RPProd+1),a            ; .
                            ld      b,d                     ; .
                            ld      a,(RPAbs+3)             ; .
                            ld      d,a                     ; .
                            ld      e,c                     ; .
                            mul     de                      ; .
                            ld      a,e                     ; .
                            adc     a,b                     ; .
                            ld      (RPProd+2),a            ; .
                            ld      a,d                     ; .
                            adc     a,0                     ; .
                            ld      (RPProd+3),a            ; .
                            ld      a,(RPSign)              ; apply the sign
                            and     a                       ; .
                            ret     z                       ; .
                            ld      hl,RPProd               ; .
                            ; fall into RPNeg32

; (hl) = -(hl), 32 bit 2's complement. Uses a, hl
RPNeg32:                    xor     a
                            sub     (hl)
                            ld      (hl),a
                            inc     hl
                            ld      a,0
                            sbc     a,(hl)
                            ld      (hl),a
                            inc     hl
                            ld      a,0
                            sbc     a,(hl)
                            ld      (hl),a
                            inc     hl
                            ld      a,0
                            sbc     a,(hl)
                            ld      (hl),a
                            ret

; (de) = (de) + (hl), 32 bit. Uses a, b, de, hl
RPAdd32:                    ld      b,4
                            or      a
.Loop:                      ld      a,(de)
                            adc     a,(hl)
                            ld      (de),a
                            inc     hl
                            inc     de
                            djnz    .Loop
                            ret

; (de) = (de) - (hl), 32 bit. Uses a, b, de, hl
RPSub32:                    ld      b,4
                            or      a
.Loop:                      ld      a,(de)
                            sbc     a,(hl)
                            ld      (de),a
                            inc     hl
                            inc     de
                            djnz    .Loop
                            ret

;----------------------------------------------------------------------------------------------------------------------------------
; The orientation vectors are the ship's axes in the player's frame (a vertex is x*side + y*roof + z*nose, see
; XX12EquNodeDotOrientation using the transposed matrix) so they must turn exactly as the position does in
; ApplyMyRollAndPitchIX, i.e. the same ALPHAFLIP and BETA. Using ALPHA / BETAFLIP made ships spin the wrong way on roll
ApplyMyRollAndPitchMatIX:   Rot16EquRotDiv256  ALPHAFLIP, AlphaDecimal           ; Alpha = alpha / 256 signed  16 bit
.CalcBetaDecimal:           Rot16EquRotDiv256  BETA,  BetaDecimal                ; Beta = beta / 256 signed     16 bit
                            ; k2 = y - alpha * x;
.StartK2Calc:               SetHLtoAlpha16                  ; HL.L = Alpha decimal
                            SetDEtoMatX                     ; CD.E = X
.CalcAlphaX                 call    mul16Signed             ; D.E = H.L * D.E 
.CalcK2:                   ; ld      de,bc                   ; CD.E = Alpha * X
                            SetHLtoMatY                     ; BH.L = Y
                            call    HLequHLminusDE          ; AHL = Y - (Alpha * X)
.WriteK2:                   ld      (RPK2),hl               ; RPK2 = K2
                            ; z = z + beta * k2;
.StartZCalc:                ex      de,hl                   ; DE = K2 (previosly loaded to AH.L)
                            SetHLtoBeta16                   ; BH.L = Beta Decimal
.CalcBetaK2:                call    mul16Signed             ; D.E = H.L * D.E
.CalcNewZ:                  ;ld      de,bc                  ; D.E = Beta * K2 result
                            SetHLtoMatZ                     ; H.L = Z
                            call    HLequHLplusDE           ; H.L = Z + Beta * K2
                            SaveHLToMatZ                    ; New Z= Z + Beta * K2
.StartYCalc:                ex      de,hl                   ; Set D.E to New Z
                            SetHLtoBeta16                   ; Set HL to Beta Decimal
                            ; y = k2 - z * beta;
.CalcBetaZ:                 call    mul16Signed             ; D.E = H.L * D.E
.CalcNewY:                  ;ld      de,bc                  ; D.E now holds Z*Beta
                            SetHLtoMatK2                    ; BH.L = K2
                            call    HLequHLminusDE          ; AH.L = K2 - Z*Beta
.WriteNewY:                 SaveHLToMatY                    ; New Y= K2 - Z*Beta
                            ;	x = x + alpha * y;                            
.StartXCalc:                ex      de,hl                   ; D.E = Y 
                            SetHLtoAlpha16                  ; BH.L = Alpha Decimal
.CalcAlphaY                 call    mul16Signed             ; D.E = H.L * D.E
.CalcNewX:                  ;ld      de,bc                  ; D.E = Y * Alpha
                            SetHLtoMatX                     ; BH.L = X
                            call    HLequHLplusDE           ; DE.H = X + Alpha*y
.WriteNewX:                 SaveHLToMatX                    ; NewX = X * Alpha*Y
                            ret
 