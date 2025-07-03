                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"
                DISPLAY "a24test test"
                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"


    DEFINE DEBUGMODE 1
    DEVICE ZXSPECTRUMNEXT
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    ;DEFINE  TESTING_MATHS_DIVIDE 1
 CSPECTMAP a24test.map
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
                        ld      b,15
.testloop:              push    iy,,bc
                        call    TestAdd
                        pop     iy,,bc
                        ld      hl,iy
                        ld      a,$10
                        add     hl,a
                        ld      iy,hl
                        djnz    .testloop
                        break

ErrorCount:             DW  0

MultiplyResult:         DS  16  ; reserve 6 bytes for maths result, little endian rest is padding for console display alignment

      
                        ;  X............  Y............   Fill Expected (hlbc)...  Actual............  Pass/Fail
                        ;   0    1    2    3    4    5    6    7,   8,   9,   A,   B,   C,   D,   E,   F
Test1:                   DB $C0, $FA, $00, $00, $4B, $00, $00, $C0, $45, $01, $00, $00, $00, $00, $00, $11 ;
Test2:                   DB $C0, $00, $04, $C0, $00, $00, $00, $80, $01, $04, $00, $00, $00, $00, $00, $11
Test3:                   DB $B3, $FA, $02, $00, $4B, $00, $00, $B3, $45, $03, $00, $00, $00, $00, $00, $11 ; 250.6692 * 75 = 18802.44
Test4:                   DB $6E, $4D, $00, $6E, $4B, $80, $00, $00, $02, $00, $00, $00, $00, $00, $00, $11 ; 77.4296875 * 75.4296875 = 5840.497131
Test5:                   DB $00, $73, $80, $00, $D7, $00, $00, $00, $64, $00, $00, $00, $00, $00, $00, $11
Test6:                   DB $00, $00, $8B, $C0, $00, $80, $00, $C0, $00, $8B, $00, $00, $00, $00, $00, $11
Test7:                   DB $40, $54, $02, $80, $0E, $00, $00, $C0, $62, $02, $00, $00, $00, $00, $00, $11
Test8:                   DB $C0, $00, $80, $00, $02, $80, $00, $C0, $02, $80, $00, $00, $00, $00, $00, $11
Test9:                   DB $40, $00, $00, $00, $02, $00, $00, $40, $02, $00, $00, $00, $00, $00, $00, $11
TestA:                   DB $80, $06, $05, $00, $02, $80, $00, $80, $04, $05, $00, $00, $00, $00, $00, $11
TestB:                   DB $C0, $00, $80, $C0, $00, $03, $00, $00, $00, $03, $00, $00, $00, $00, $00, $11
TestC:                   DB $C0, $00, $04, $C0, $00, $04, $00, $80, $01, $08, $00, $00, $00, $00, $00, $11
TestD:                   DB $40, $00, $02, $80, $00, $00, $00, $C0, $00, $02, $00, $00, $00, $00, $00, $11
TestE:                   DB $C0, $00, $04, $80, $61, $00, $00, $40, $62, $04, $00, $00, $00, $00, $00, $11
TestF:                   DB $66, $12, $06, $80, $61, $00, $00, $E6, $73, $06, $00, $00, $00, $00, $00, $11

TestAdd:                ld      hl,(iy+0)           ; BHL = X
                        ld      a,(iy+2)            ; .
                        ld      b,a                 ; .
                        ld      de,(iy+3)           ; CDE = Y
                        ld      a,(iy+5)            ;
                        ld      c,a                 ;
                        break
                        call    AHLequBHLplusCDE    ; BH.L by CD.E putting result in BCDE.HL 
                        ld      (iy+$0B),hl        ; save AHL
                        ld      (iy+$0D),a         ; .
                        ZeroA
                        ld      (iy+$0E),a          ; and finally l
.CheckResult:           ld      a,(iy+$07)
                        ld      b,a
                        ld      a,(iy+$0B)
                        cp      b
                        jp      nz,.Fail
                        
                        ld      a,(iy+$08)
                        ld      b,a
                        ld      a,(iy+$0C)
                        cp      b
                        jp      nz,.Fail
                        
                        ld      a,(iy+$09)
                        ld      b,a
                        ld      a,(iy+$0D)
                        cp      b
                        jp      nz,.Fail
                        
                        ld      a,(iy+$0A)
                        ld      b,a
                        ld      a,(iy+$0E)
                        cp      b
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
    INCLUDE	"../../Maths24/asm_addition24.asm"

    SAVENEX OPEN "a24test.nex", EliteNextStartup , TopOfStack
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
   
