                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"
                DISPLAY "maths24test test"
                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"


    DEFINE DEBUGMODE 1
    DEVICE ZXSPECTRUMNEXT
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    ;DEFINE  TESTING_MATHS_DIVIDE 1
    DEFINE  TESTING_ROLL_PITCH 1
 CSPECTMAP maths24test.map
 OPT --zxnext=cspect --syntax=a --reversepop
                DEFINE  SOUNDPACE 3
;                DEFINE  ENABLE_SOUND 1
               DEFINE     MAIN_INTERRUPTENABLE 1
;               DEFINE INTERRUPT_BLOCKER 1
DEBUGSEGSIZE   equ 1
DEBUGLOGSUMMARY equ 1
;DEBUGLOGDETAIL equ 1

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
#define TESTING_MATHS_MULTIPLY
TopOfStack              equ $5CCB ;$6100

                        ORG $5DCB;      $6200
EliteNextStartup:       di
                        break
                IFDEF TESTING_MATHS_MULTIPLY
                        ld      iy,Test1
                        call    TestMult
                        break
                        ld      iy,Test2
                        call    TestMult
                        break
                        ld      iy,Test3
                        call    TestMult
                        break
                        ld      iy,Test4
                        call    TestMult
                        break
                        ld      iy,Test5
                        call    TestMult
                        break
                        ld      iy,Test6
                        call    TestMult
                        break
                        ld      iy,Test7
                        call    TestMult
                        break
                        ld      iy,Test8
                        call    TestMult
                        break
                        ld      iy,Test9
                        call    TestMult
                        break
                        ld      iy,TestA
                        call    TestMult
                        break
                        ld      iy,TestB
               

               call    TestMult
                        break
                        ld      iy,TestC
                        call    TestMult
                        break
                        ld      iy,TestD
                        call    TestMult
                        break
                ENDIF
                IFDEF TESTING_MATHS_DIVIDE
                        ld      iy,TestD12424
                        call    TestDivide
                        break
                        ld      iy,TestD22424
                        call    TestDivide
                        break
                        ld      iy,TestD32424
                        call    TestDivide
                        break
                        ld      iy,TestD42424
                        call    TestDivide
                        break
                        ld      iy,TestD52416
                        call    TestDivide
                        break
                ENDIF
                IFDEF   TESTING_ROLLL_PITCH
                        break
                
                
;   1. K2 = y - alpha * x
;   2. z = z + beta * K2
;   3. y = K2 - beta * z
;   4. x = x + alpha * y
MyhRollAndPitch24Bit:   ld      a,(ALPHA)                   ; Calc alpha * x
                        ld      d,a                         ;
                        ld      hl,(UBnKxhi)                ;
                        ld      a,(UBnKxlo)                 ;
                        ld      e,a                         ;
                        call    DECLequHLEmulDs             ; DELC = alpha * x so DEL is what we want
                        brek
                ENDIF
                        
                        ld      
UBnKxlo                 DB  0
UBnKxhi                 DB  0
UBnKxsgn                DB  0
UBnKylo                 DB  $79
UBnKyhi                 DB  $05
UBnKysgn                DB  0
UBnKzlo                 DB  $10
UBnKzhi                 DB  $06
UBnKzsgn                DB  $80
Alpha                   DB  0
Beta                    DB  0

ErrorCount:             DW  0
                        ;  X              Y              Filler....Result...........................
                        ;    0    1    2    3    4    5    6    7,   8,   9,   A,   B,   C,   D,   E,   F
Test1:                  DB $00, $10, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
                        ;  Pass/Fail (00/FF)                       Answer.........................  ...
                        ;                                           24   25   26   27   28   29   30   31
                        DB $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $10, $00, $00, $00, $00, $00, $00
Test2:                  DB $05, $03, $02, $0A, $04, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
                        DB $FF, $FF, $FF, $FF, $00, $00, $00, $00, $32, $32, $25, $0B, $02, $00, $00, $00
Test3:                  DB $05, $03, $02, $00, $0A, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
                        DB $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $32, $1E, $14, $00, $00, $00, $00
Test4:                  DB $FF, $03, $02, $FF, $0A, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
                        DB $FF, $FF, $FF, $FF, $00, $00, $00, $00, $01, $F1, $29, $16, $00, $00, $00, $00
Test5:                  DB $05, $FF, $02, $00, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
                        DB $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $FB, $05, $FC, $02, $00, $00, $00
Test6:                  DB $FF, $03, $07, $FF, $07, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
                        DB $FF, $FF, $FF, $FF, $00, $00, $00, $00, $01, $F4, $18, $38, $00, $00, $00, $00
Test7:                  DB $FF, $03, $07, $FF, $0A, $07, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
                        DB $FF, $FF, $FF, $FF, $00, $00, $00, $00, $01, $F1, $1D, $69, $31, $00, $00, $00
Test8:                  DB $05, $03, $82, $0A, $04, $81, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
                        DB $FF, $FF, $FF, $FF, $00, $00, $00, $00, $32, $32, $25, $0B, $02, $00, $00, $00
Test9:                  DB $05, $03, $82, $00, $0A, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
                        DB $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $32, $1E, $94, $00, $00, $00, $00
TestA:                  DB $FF, $03, $02, $FF, $0A, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
                        DB $FF, $FF, $FF, $FF, $00, $00, $00, $00, $01, $F1, $29, $96, $00, $00, $00, $00
TestB:                  DB $05, $FF, $82, $00, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
                        DB $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $FB, $05, $FC, $82, $00, $00, $00
TestC:                  DB $FF, $03, $07, $FF, $07, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
                        DB $FF, $FF, $FF, $FF, $00, $00, $00, $00, $01, $F4, $18, $B8, $00, $00, $00, $00
TestD:                  DB $FF, $03, $00, $FF, $0A, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
                        DB $FF, $FF, $FF, $FF, $00, $00, $00, $00, $01, $F1, $1D, $69, $B1, $00, $00, $00
                        ;  Dividend.....  Divisor......                                                                             E H  L    B  C
TestD12424:             DB $80, $7F, $00, $80, $02, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 128.5 / 2.5 = 51 Pass
                        DB $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
TestD22424:             DB $40, $7F, $00, $40, $05, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 127.25/5.25=24.238	Pass
                        DB $FF, $FF, $FF, $FF, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00
TestD32424:             DB $80, $F7, $00, $80, $0A, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; -119.5/10.5=-11.3809 Pass
                        DB $FF, $FF, $FF, $FF, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00
TestD42424:             DB $FF, $03, $00, $00, $8A, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 3.996 / -10 = -0.3996 pass
                        DB $FF, $FF, $FF, $FF, $01, $01, $00, $00, $8F, $04, $00, $00, $00, $00, $00, $00
TestDivide:             ld      hl,(iy+0)   ; BHL = IY [0,1,2]
                        ld      de,(iy+3)   ; BHL = IY [0,1,2]
                        call    fixedS88_divs; BHLequBHLdivCDEs
                        
                        ret

TestMult:               ld      hl,(iy+0)
                        ld      a,(iy+2)
                        ld      b,a
                        ld      de,(iy+3)
                        ld      a,(iy+5)
                        ld      c,a
                        call    HLBCequBHLmulCDE
                        ld      (iy+8),bc
                        ld      (iy+10),hl
                        ld      (iy+12),a
.CheckResult:           ld      a,c
                        cp      (iy+24)
                        jp      nz,.Fail
                        ld      a,b
                        cp      (iy+25)
                        jp      nz,.Fail
                        ld      a,l
                        cp      (iy+26)
                        jp      nz,.Fail
                        ld      a,h
                        cp      (iy+27)
                        jp      nz,.Fail
                        xor     a
                        ld      (iy+16),a
                        ret
.Fail:                  ld      a,$01
                        ld      (iy+16),a
                        ld      hl,ErrorCount
                        inc     (hl)
                        ret

;--------------------------------------------------------------------------------------
    INCLUDE	"../../MathsFPS78\asm_multiply_S78.asm"
    INCLUDE	"../../MathsFPS78/asm_divide_S78.asm"
    INCLUDE	"../../Maths24/asm_addition24.asm"




    SAVENEX OPEN "maths24test.nex", EliteNextStartup , TopOfStack
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
   
