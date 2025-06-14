                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"
                DISPLAY "mathsRollPitch test"
                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"


    DEFINE DEBUGMODE 1
    DEVICE ZXSPECTRUMNEXT
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    ;DEFINE  TESTING_MATHS_DIVIDE 1
    DEFINE  TESTING_ROLL_PITCH 1
 CSPECTMAP mathsRollPitch.map
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
                

MyRollAndPitch24Bit:    ld      hl,(ALPHA)
                        ld      a,h
                        or      l
                        jp      nz,.NotZero
                        ;break
.NotZero:
;   1. K2 = y - alpha * x
.Step1:                 ld      a,(ALPHA)                   ; Calc alpha * x
                        ld      d,a                         ;
                        ld      hl,(UBnKxhi)                ;
                        ld      a,(UBnKxlo)                 ;
                        ld      e,a                         ;
                        ;break
                        call    DEHLequHLEmulDs             ; DELC = alpha * x so DEL is what we want
                        ld      (Ax),hl                     ;
                        ld      (Ax+2),de                   ;
.YMinusAx:              ld      c,h
                        ld      a,(UBnKysgn)
                        ld      b,a
                        ld      hl,(UBnKylo)
                        ;break
                        call    AHLequBHLminusDEC           ; K2 = y - alpha * x
                        ld      (K2),hl
                        ld      (K2+2),a
;   2. z = z + beta * K2
.Step2:                 ld      e,l                         ; HEL = AHL
                        ld      l,h
                        ld      h,a
                        ld      a,(BETA)
                        ld      d,a
                        ;break
                        call    DEHLequHLEmulDs             ; DELC = beta * K2 so DEL is what we want
                        ld      (Bk),hl                     ;
                        ld      (Bk+2),de                   ;
.ZPlusBk:               ld      c,h
                        ld      hl,(UBnKzlo)
                        ld      a,(UBnKzsgn)
                        ld      b,a
                        ;break
                        DISPLAY "OPTIMISE TO AHL = BHL + DEC to improv post multiply"
                        call    AHLequBHLplusDEC
.SetZ:                  ld      (UBnKzlo),hl
                        ld      (UBnKzsgn),a                        
;   3. y = K2 - beta * z
.Step3:                 ld      a,(BETA)
                        ld      d,a
.GetZBack:              ld      hl,(UBnKzhi)
                        ld      a,(UBnKzlo)
                        ld      e,a
                        ;break
                        call    DEHLequHLEmulDs             ; DELC = beta * K2 so DEL is what we want
                        
.K2MinusBZ:             ld      (Bz),hl
                        ld      (Bz+2),de
                        ld      b,l                    
                        ld      c,h
                        ld      hl,(K2)
                        ld      a,(K2+2) ; will it go wrong if K2 negative?
                        ld      b,a
                        ;break
                        call    AHLequBHLminusDEC          ; y = K2 -Bz
.SetY:                  ld      (UBnKylo),hl
                        ld      (UBnKysgn),a                        
;   4. x = x + alpha * y 
.Step4:                 break
                        ld      a,(ALPHA)                   ; Calc alpha * x
                        ld      d,a                         ;
.GetYBack:              ld      hl,(UBnKyhi)                ;
                        ld      a,(UBnKylo)                 ;
                        ld      e,a                         ;
                        break
                        call    DEHLequHLEmulDs             ; DELC = alpha * x so DEL is what we want
                        ld      (Ay),hl                     ;
                        ld      (Ay+2),de                   ;
                        ; now DEHL holds DELC so we can use that but shift by 8 bits to get correct value to add
                        ; now d holds sign so we need to pull that back in and get HL into DE  as DE should only ever be S000                        
.XPlusAx:               ld      c,h
.GetXBack:              ld      a,(UBnKxsgn)
                        ld      b,a
                        ld      hl,(UBnKxlo)
                        break
                        call    AHLequBHLplusDEC           ; x+ alpha * x
.SetX:                  ld      (UBnKxlo),hl
                        ld      (UBnKxsgn),a    
                        break
                        jp      .NotZero
                        
Bz                      DS  4                        
Bk                      DS  4                        
Ax                      DS  4
Ay                      DS  4
K2                      DS  4
UBnKxlo                 DB  0
UBnKxhi                 DB  0
UBnKxsgn                DB  0
UBnKylo                 DB  $79
UBnKyhi                 DB  $05
UBnKysgn                DB  0
UBnKzlo                 DB  $10
UBnKzhi                 DB  $64
UBnKzsgn                DB  $80
ALPHA                   DB  1
BETA                    DB  0
varQ                    DB  0
varRS                   DB  0
                        ret

;--------------------------------------------------------------------------------------
    INCLUDE	"../../MathsFPS78/asm_multiply_S78.asm"
    INCLUDE	"../../MathsFPS78/asm_divide_S78.asm"
    INCLUDE	"../../Maths24/asm_addition24.asm"




    SAVENEX OPEN "mathsRollPitch.nex", EliteNextStartup , TopOfStack
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
   
