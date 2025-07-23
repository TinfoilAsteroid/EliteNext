                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"
                DISPLAY "rp24test test"
                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"


    DEFINE DEBUGMODE 1
    DEVICE ZXSPECTRUMNEXT
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    ;DEFINE  TESTING_MATHS_DIVIDE 1
 CSPECTMAP rp24test.map
 OPT --zxnext=cspect --syntax=a --reversepop
               DEFINE     MAIN_INTERRUPTENABLE 1
DEBUGSEGSIZE   equ 1
DEBUGLOGSUMMARY equ 1


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
SignMask8Bit		equ %01111111
SignMask16Bit		equ %0111111111111111
SignOnly8Bit		equ $80
SignOnly16Bit		equ $8000

Bit7Only            equ %10000000
Bit6Only            equ %01000000
Bit5Only            equ %00100000
Bit4Only            equ %00010000
Bit3Only            equ %00001000
Bit2Only            equ %00000100
Bit1Only            equ %00000010
Bit0Only            equ %00000001
Bit7Clear           equ %01111111
Bit6Clear           equ %10111111
Bit5Clear           equ %11011111
Bit4Clear           equ %11101111
Bit3Clear           equ %11110111
Bit2Clear           equ %11111011
Bit1Clear           equ %11111101
Bit0Clear           equ %11111110
ConstPi				equ $80
ConstNorm           equ 197



                        INCLUDE "../../Macros/jumpMacros.asm"
                        INCLUDE "../../Macros/MathsMacros.asm"
                        INCLUDE "../../Macros/ShiftMacros.asm"
                        INCLUDE "../../Macros/NegateMacros.asm"                        
                        INCLUDE "../../Macros/carryFlagMacros.asm"
                        INCLUDE "../../Macros/UniverseObjectPosMacros.asm"
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

TopOfStack              equ $5CCB ;$6100

                        ORG $5DCB;      $6200
EliteNextStartup:       di
                        break
                        ld      a,0
                        ld      (Pitch),a
                        ld      a,8
                        or      $80
                        ld      (Roll),a
                        ld      iy,Test1
                        ld      b,15
.testloop:              push    iy,,bc
                        call    TestRollPitch
                        pop     iy,,bc
                        ld      hl,iy
                        ld      a,$10
                        add     hl,a
                        ld      iy,hl
                        djnz    .testloop
                        break

ErrorCount:             DW  0

MultiplyResult:         DS  16  ; reserve 6 bytes for maths result, little endian rest is padding for console display alignment

      
                        ;  X.............  Y............  Z............                               Pass/Fail
                        ;   0    1    2    3    4    5    6    7,   8,   9,   A,   B,   C,   D,   E,   F
                        ; result X Y Z
                        ;  10   11   12   13   14   15   16   17   18   10   1A   1B   1C   1D   1E   1F
Test1:                  DB $00, $00, $00, $00, $2C, $01, $00, $BC, $02, $00, $00, $00, $00, $00, $00, $11 ;
Test2:                  DB $60, $09, $00, $00, $2C, $01, $00, $BC, $02, $00, $00, $00, $00, $00, $00, $11
Test3:                  DB $C6, $F9, $00, $1E, $AA, $80, $00, $BC, $02, $00, $00, $00, $00, $00, $00, $11 ; 250.6692 * 75 = 18802.44
Test4:                  DB $D9, $FE, $00, $4F, $A2, $80, $00, $BC, $02, $00, $00, $00, $00, $00, $00, $11 ; 77.4296875 * 75.4296875 = 5840.497131
Test5:                  DB $00, $00, $00, $12, $BC, $82, $00, $BC, $02, $00, $00, $00, $00, $00, $00, $11
Test6:                  DB $00, $00, $00, $95, $BB, $82, $00, $BC, $02, $00, $00, $00, $00, $00, $00, $11
Test7:                  DB $00, $00, $00, $2D, $01, $00, $00, $BC, $02, $00, $00, $00, $00, $00, $00, $11
Test8:                  DB $00, $00, $00, $00, $00, $00, $00, $BC, $02, $00, $00, $00, $00, $00, $00, $11
Test9:                  DB $00, $00, $00, $00, $00, $00, $00, $BC, $02, $00, $00, $00, $00, $00, $00, $11
TestA:                  DB $00, $00, $00, $00, $00, $00, $00, $BC, $02, $00, $00, $00, $00, $00, $00, $11
TestB:                  DB $00, $00, $00, $00, $00, $00, $00, $BC, $02, $00, $00, $00, $00, $00, $00, $11
TestC:                  DB $00, $00, $00, $00, $00, $00, $00, $BC, $02, $00, $00, $00, $00, $00, $00, $11
TestD:                  DB $00, $00, $00, $00, $00, $00, $00, $BC, $02, $00, $00, $00, $00, $00, $00, $11
TestE:                  DB $00, $00, $00, $00, $00, $00, $00, $BC, $02, $00, $00, $00, $00, $00, $00, $11
TestF:                  DB $00, $00, $00, $00, $00, $00, $00, $BC, $02, $00, $00, $00, $00, $00, $00, $11
Roll                    DB 0
Pitch                   DB 0

TestRollPitch:          break
                        ld      ix,iy               ; set IX up with X Y and Z
                        call    ApplyRollAndPitchIX ;
                        ret


;	alpha = flight_roll / 256.0;
;	beta = flight_climb / 256.0;
;    k2 = y - alpha * x;
;	z = z + beta * k2;
;	y = k2 - z * beta;
;	x = x + alpha * y;
;divs32   dehl = dehl' / dehl in our case it will be S78.0/ 0S78.0 to give us 0S78.0
; IX 0 Xl 1 Xm 2 Xh 3 Yl 4 Ym 5 Yh 6 Zl 7 Zm 8 zh
AlphaDecimal                DS  3   ; roll /256 as 24 bit 16.8
BetaDecimal                 DS  3   ; pitch /256 as 24 bit 16.8
RPK2                        DS  3

RotEqeuRotDiv256            MACRO   Rotator, RotatorDecimal
                            ld      a,(Rotator)             ; Alpha = alpha / 256 signed
                            ld      b,a                     ; we strip lead sign bit off and move it to H
                            and     $7F                     ; .
                            ld      (RotatorDecimal),a      ; .
                            ld      a,b                     ; .
                            and     $80                     ; .
                            ld      hl,0                    ; .
                            or      h                       ; .
                            ld      h,a                     ; .
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
ApplyRollAndPitchIX:        RotEqeuRotDiv256 Roll, AlphaDecimal  ; Alpha = alpha / 256 signed
                           
CalcBetaDecimal:            RotEqeuRotDiv256 Pitch, BetaDecimal  ; Alpha = alpha / 256 signed
                            ; k2 = y - alpha * x;
                            break
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

;	x = x + alpha * y;


;--------------------------------------------------------------------------------------
    INCLUDE	"../../Maths24/asm_addition24.asm"
    INCLUDE	"../../Maths24/asm_mul24_notbank0safe.asm"
    
    SAVENEX OPEN "rp24test.nex", EliteNextStartup , TopOfStack
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
   
