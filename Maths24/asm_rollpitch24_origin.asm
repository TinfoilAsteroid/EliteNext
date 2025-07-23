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

SetBHLtoK2:                 MACRO
                            ld      a,(RPK2+2)
                            ld      b,a                     ; bhl = K2
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
                            
SetCDEtoDelta:              MACRO
                            ld      a,(DeltaDecimal+2)      ; set BHL to Beta
                            ld      b,a                     ;
                            ld      hl,(DeltaDecimal)       ;
                            ENDM
                                
                              
                                DISPLAY "Later oprimise to do decimal calc in main loop"
                                DISPLAY "Also update compasses"
; Apply roll and pitch takes 3 24 bit X, Y, Z and applies player roll, pitch and speed
; for readability all steps are done via macros
ApplyMyRollAndPitchIX:      RotEquRotDiv256 ALPHAFLIP, AlphaDecimal  ; Alpha = alpha / 256 signed             
.CalcBetaDecimal:           RotEquRotDiv256 BETA,  BetaDecimal  ; Alpha = alpha / 256 signed
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
