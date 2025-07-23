                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"
                DISPLAY "sqrt24test test"
                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"


    DEFINE DEBUGMODE 1
    DEVICE ZXSPECTRUMNEXT
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    ;DEFINE  TESTING_MATHS_DIVIDE 1
 CSPECTMAP sqrt24test.map
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
                        ld      hl,Test1
                        ld      b,2
                        ld      de,16000
.OuterLoop:             push    bc
                        ld      b,0
.WriteLoop:             ld      (hl),e
                        inc     hl
                        ld      (hl),d
                        inc     hl
                        inc     de
                        inc     hl
                        inc     hl
                        djnz    .WriteLoop
                        pop     bc
                        djnz    .OuterLoop
                        break
PerformTests:           ld      hl,Test1
                        ld      b,2
.OuterLoop:             push    bc
                        ld      b,0
.WriteLoop:             ld      a,(hl)
                        ld      e,a
                        inc     hl
                        ld      a,(hl)
                        ld      d,a
                        inc     hl
                        inc     hl
                        push    bc,,hl
                        ex      de,hl
                        call    sqrtHL
                        pop     bc,,hl
                        ld      (hl),a
                        inc     hl
                        djnz    .WriteLoop
                        pop     bc
                        djnz    .OuterLoop
                        break
    INCLUDE	"../../Maths24/asm_sqrt24.asm"

                        ;  X............  Y............   Fill Expected (hlbc)...  Actual............  Pass/Fail
                        ;   0    1    2    3    4    5    6    7,   8,   9,   A,   B,   C,   D,   E,   F
Test1:                   DS     32*4
;--------------------------------------------------------------------------------------

    SAVENEX OPEN "sqrt24test.nex", EliteNextStartup , TopOfStack
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
   
