                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"
                DISPLAY "d24test test"
                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"


    DEFINE DEBUGMODE 1
    DEVICE ZXSPECTRUMNEXT
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    ;DEFINE  TESTING_MATHS_DIVIDE 1
    DEFINE  TESTING_ROLL_PITCH 1
 CSPECTMAP d24test.map
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
                        ld      b,6
.testloop:              push    iy,,bc
                        call    TestDiv24
                        pop     iy,,bc
                        ld      hl,iy
                        ld      a,$10
                        add     hl,a
                        ld      iy,hl
                        djnz    .testloop
                        break

ErrorCount:             DW  0

MultiplyResult:         DS  16  ; reserve 6 bytes for maths result, little endian rest is padding for console display alignment

                         ;  Dividend.....  Divisor...... Filler....Result...........................                                                                           E H  L    B  C
Test1:                  DB $80, $25, $00, $00, $04, $00, $00, $00, $60, $09, $00, $00, $00, $00, $00, $11 ; 37.5 / 4 = 9.375 
Test2:                  DB $80, $25, $00, $00, $04, $80, $00, $00, $55, $08, $00, $00, $00, $00, $00, $11 ; 37.5 / 4.5 = 8.3333 
Test3:                  DB $80, $7F, $00, $80, $02, $00, $00, $00, $00, $33, $00, $00, $00, $00, $00, $11 ; 128.5 / 2.5 = 51 
Test4:                  DB $40, $7F, $00, $40, $05, $00, $00, $00, $00, $00, $18, $00, $00, $00, $00, $11 ; 127.25/5.25=24.238	
Test5:                  DB $80, $F7, $00, $80, $0A, $00, $00, $00, $00, $00, $0c, $00, $00, $00, $00, $11 ; -119.5/10.5=-11.3809 
Test6:                  DB $FF, $03, $00, $00, $8A, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $11 ; 3.996 / -10 = -0.3996 


TestDiv24:              ld      hl,(iy+0)           ; dehl = X0
                        ld      a,(iy+2)
                        ld      de,(iy+3)           ; dehl = 0Y
                        ld      c,(iy+5)            ;
                        break
                        call    divs24              ; dehl' / dehl result in BCDE.HL
                        ld      (iy+$0B),hl         ; .
                        ld      (iy+$0D),de         ; .
                        exx
                        ld      a,l
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


TestDiv:                ld      hl,(iy+1)           ; dehl = X0
                        ex      de,hl
                        ld      a,(iy+0)
                        ld      h,a                 ; .
                        ld      l,0
                        exx                         ; de'hl' = X
                        ld      hl,(iy+3)           ; dehl = 0Y
                        ld      a,(iy+5)            ;
                        ld      e,a                 ;
                        ld      d,0
                        exx                         ; dehl correct way round
                        break
                        call    divu32              ; dehl' / dehl result in BCDE.HL
                        exx                         ; so now we have l'de.h to consdier                     ; we only care about lde'.h' in the resul
                        ld      a,h                 ; we only care about lde'.h' in the resul
                        ld      (iy+$0B),a          ; .
                        ld      (iy+$0C),de         ; .
                        exx
                        ld      a,l
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
    INCLUDE	"../../Maths24/asm_divide24.asm"




    SAVENEX OPEN "d24test.nex", EliteNextStartup , TopOfStack
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
   
