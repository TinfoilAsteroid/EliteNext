RotEqeuRotDiv256            MACRO   Rotator, RotatorDecimal
                            ld      a,(Rotator)             ; Alpha = alpha / 256 signed 
                            bit     7,a                     ; determine if its + or -
                            ld      hl,0                    ; .
                            jp      z,.RotPositive          ;
.RotNegative:               res     7,a                     ; 
                            ld      h,$80                   ; 
.RotPositive:               ld      (RotatorDecimal),a      ; .
                            ld      (RotatorDecimal+1),hl   ; .
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

SetBHLtoK2:                 MACRO
                            ld      a,(RPK2+2)
                            ld      b,a                     ; bhl = K2
                            ld      hl,(RPK2)               ; .
                            ENDM
SetCDEtoX:                  MACRO
                            ld      c,(ix+2)
                            ld      de,(ix)
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
SetBHLtoX:                  MACRO
                            ld      b,(ix+2)
                            ld      hl,(ix)
                            ENDM
SaveDEHToX:                 MACRO
                            ld      (ix+2),d                ; save DE.H into Zd
                            ld      (ix+1),e                ; .
                            ld      (ix),h                  ; .
                            ENDM
SaveAHLToX:                 MACRO
                            ld      (ix+2),a                ; save DE.H into Zd
                            ld      (ix+1),h                ; .
                            ld      (ix),l                  ; .
                            ENDM
SetCDEtoY:                  MACRO
                            ld      c,(ix+5)
                            ld      de,(ix+3)
                            ENDM
SetBHLtoY:                  MACRO
                            ld      b,(ix+5)
                            ld      hl,(ix+3)
                            ENDM
SaveDEHToY:                 MACRO
                            ld      (ix+5),d                ; save DE.H into Zd
                            ld      (ix+4),e                ; .
                            ld      (ix+3),h                ; .
                            ENDM
SaveAHLToY:                 MACRO
                            ld      (ix+5),a                ; save DE.H into Zd
                            ld      (ix+4),h                ; .
                            ld      (ix+3),l                ; .
                            ENDM
SetCDEtoZ:                  MACRO
                            ld      c,(ix+8)
                            ld      de,(ix+6)
                            ENDM
SetBHLtoZ:                  MACRO
                            ld      b,(ix+8)
                            ld      hl,(ix+6)
                            ENDM
SaveDEHToZ:                 MACRO
                            ld      (ix+8),d                ; save DE.H into Zd
                            ld      (ix+7),e                ; .
                            ld      (ix+6),h                ; .
                            ENDM
SaveAHLToZ:                 MACRO
                            ld      (ix+8),a                ; save DE.H into Zd
                            ld      (ix+7),h                ; .
                            ld      (ix+6),l                ; .
                            ENDM                               
                                DISPLAY "Later oprimise to do decimal calc in main loop"
                                DISPLAY "Also update compasses"
ApplyRollAndPitchIX:        RotEqeuRotDiv256 ALPHA, AlphaDecimal  ; Alpha = alpha / 256 signed             
CalcBetaDecimal:            RotEqeuRotDiv256 BETA, BetaDecimal  ; Alpha = alpha / 256 signed
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
                            ret
