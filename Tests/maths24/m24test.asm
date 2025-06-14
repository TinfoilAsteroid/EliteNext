                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"
                DISPLAY "m24test test"
                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"


    DEFINE DEBUGMODE 1
    DEVICE ZXSPECTRUMNEXT
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    ;DEFINE  TESTING_MATHS_DIVIDE 1
 CSPECTMAP m24test.map
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
                        ld      iy,Test1
                        ld      b,11
.testloop:              push    iy,,bc
                        call    TestMult
                        pop     iy,,bc
                        ld      hl,iy
                        ld      a,$10
                        add     hl,a
                        ld      iy,hl
                        djnz    .testloop
                        break

ErrorCount:             DW  0
      
                        ;  X............  Y............   Fill Expected (hlbc)...  Actual............  Pass/Fail
                        ;   0    1    2    3    4    5    6    7,   8,   9,   A,   B,   C,   D,   E,   F
Test1:                   DB $00, $FA, $C0, $00, $4B, $00, $00, $49, $76, $40, $00, $00, $00, $00, $00, $11
Test2:                   DB $04, $00, $C0, $00, $00, $C0, $00, $03, $00, $90, $00, $00, $00, $00, $00, $11
Test3:                   DB $00, $FA, $B3, $00, $4B, $00, $00, $49, $72, $80, $00, $00, $00, $00, $00, $11
Test4:                   DB $00, $4D, $6E, $00, $4D, $6E, $00, $17, $6B, $67, $00, $00, $00, $00, $00, $11
Test5:                   DB $00, $73, $00, $00, $D7, $00, $00, $60, $95, $00, $00, $00, $00, $00, $00, $11
Test6:                   DB $0B, $00, $00, $00, $00, $C0, $00, $08, $40, $00, $00, $00, $00, $00, $00, $11
Test7:                   DB $02, $54, $40, $00, $0E, $80, $00, $21, $C5, $A0, $00, $00, $00, $00, $00, $11
Test8:                   DB $00, $00, $C0, $00, $02, $00, $00, $00, $01, $80, $00, $00, $00, $00, $00, $11
Test9:                   DB $00, $00, $40, $00, $02, $00, $00, $00, $00, $80, $00, $00, $00, $00, $00, $11
TestA:                   DB $05, $06, $80, $00, $02, $00, $00, $0A, $0D, $00, $00, $00, $00, $00, $00, $11
TestB:                   DB $04, $00, $C0, $00, $00, $C0, $00, $03, $00, $90, $00, $00, $00, $00, $00, $11
                       
                        ;  Dividend.....  Divisor......                                                                             E H  L    B  C


TestMult:               ld      hl,(iy+0)           ; bhl = X
                        ld      a,(iy+2)            ; .
                        ld      b,a                 ; .
                        ld      de,(iy+3)           ; cde = Y
                        ld      a,(iy+5)            ;
                        ld      c,a                 ;
                        call    BCDEHLequBHLmulCDEs ; BCDEHL = result is BCDE.HL
                        ld      a,h                 ; save result but we only care about de.h
                        ld      (iy+$0B),a          ; .
                        ld      (iy+$0C),de         ; .
.CheckResult:           ld      a,(iy+$07)
                        cp      c
                        jp      nz,.Fail
                        ld      a,(iy+$08)
                        cp      b
                        jp      nz,.Fail
                        ld      a,(iy+$09)
                        cp      l
                        jp      nz,.Fail
                        ld      a,(iy+$0A)
                        cp      h
                        jp      nz,.Fail
                        ld      a,$FF
                        ld      (iy+$0F),a
                        ret
.Fail:                  ld      a,$00
                        ld      (iy+$0F),a
                        ld      hl,ErrorCount
                        inc     (hl)
                        ret

;--------------------------------------------------------------------------------------
    INCLUDE	"../../Maths24/asm_multiply24.asm"

    SAVENEX OPEN "m24test.nex", EliteNextStartup , TopOfStack
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
   
