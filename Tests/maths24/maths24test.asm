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


AHLequHLAddCarryAViaDE: MACRO
                        ld      d,0                         ; de = P1 carry
                        ld      e,a                         ; .
                        xor     a                           ; Clear carry and prep a for P2 carry
                        add     hl,de                       ; .
                        adc     a,a                         ; .
                        ENDM
; variants on AHLequBHLplusCD
; If it will fit
;  HLBC = BHL * CDE  Lead Sign bit, carry Clear
; else
;  AHLBC = BHL * CDE Lead sign bit , carry set
; performs p0 = x0*y0                               L*E
;          p1 = x1*y0 + x0*y1 + p0 carry            H*E + D*L
;          p2 = x2*y0 + x0*y2 + x1*y1 + p1 carry    B*E + L*C + H*D
;          p3 = x2*y1 + x1 * y2 + p2 carry          B*D + H*C
;          p4 = x2* y2                              B*C
; reverse order for stack retrival                                                                                              B H L  C D E
; performs p4 = x2* y2                              B*C                B*C                     leave as is           BHL*CDE   020305 01040A 0201            02                  P4 = 2
;          p3 = x2*y1 + x1 * y2 + p2 carry          B*D + H*C          Swap B<>E and C<>L      E*D + H * L           EHC*LDB    E H C  L D B 0204 0301       08+03 = 0B          P3 = B
;          p2 = x2*y0 + x0*y2 + x1*y1 + p1 carry    E*B + C*L + H*D    Swap B<>D and C<>H      E*D + H * L + C * B   ECH*LBD    E C H  L B D 020A 0501 0304  14+05+0C=25         P2 = 25
;          p1 = x1*y0 + x0*y1                       C*D + H*B          Swap C<>E and L<>B      E*D + H * L           CEH*BLD    C E H  B L D 030A 0504       1E+14 = 32          P1 = 32 carry = 0
;          p0 = x0*y0                               C*B                Swap E,H, ex hl,de in calc                    CHE*BDL                 050A            32                  P0 = 32 Carry = 0
SwapViaA:               MACRO   r1, r2
                        ld      a,r1
                        ld      r1,r2
                        ld      r2,a
                        ENDM
HLBCequBHLmulCDE:       ld      a,b                         ; multiply is simpler as same signs is always positive
                        xor     c                           ; opposite is always negative
                        and     $80                         ; .
.SaveSign:              push    af                          ; save a to the stack that will now hold 0 or $80,
.ClearSignBits:         res     7,b
                        res     7,c
.PrepP4:                push    bc                          ; save registers for p4 = x2*y2 p3 carry > BC = x0 y0
.PrepP3:                SwapViaA b,e                        ; save registers for p3  = x2*y1 + x1*y2 + p2 carry
                        SwapViaA c,l
                        push    de,,hl                      ; DE = X2 Y1 HL = X1 Y2
.PrepP2:                SwapViaA d,b                         ; save registers for p2  = x2*y0 + x0*y2 + x1*y1 + p1 carry
                        SwapViaA c,h
                        push    de,,hl,,bc                  ; save registers for p1 = x1*y0 + x0*y1 + p0 carry
.PrepP1:                SwapViaA c,e
                        SwapViaA l,b
                        push    de,,hl
.PrepP0:                SwapViaA e,h                        ; we don't care about original values now as they are on the stack
.CalcP0:                mul     de                          ; de = x0 * y0 no need for carry logic as even FF*FF = FE01
                        ld      bc,de                       ; so b = P0 carry,c = P0
.CalcP1:                pop     de                          ; get P1 components off stack
                        mul     de                          ; hl = x1*y0
                        ex      de,hl                       ; so de = P1c P1 b =P0c P0
.AddP0Carry:            xor     a                           ; hl = x1*y0 + P0 carry
                        ld      d,0                         ; .
                        ld      e,b                         ; .
                        add     hl,de                       ; .
                        adc     a,a                         ; a = carry
                        pop     de
                        mul     de                          ; de = x0*y1
                        and     a                           ; clear carry flag whilst retaining a
                        add     hl,de                       ; hl = x1*y0 + x0*y1
.CalcP1Carry:           adc     a,0                         ;
                        add     h                           ; a = P1 carry
                        ld      b,l                         ; A = P1 carry bc = P1 P0
.CalcP2:                pop     de                          ; we pull in bc later directly into de
                        mul     de                          ; hl = x2*y0
                        ex      hl,de                       ; .
.AddP1Carry:            AHLequHLAddCarryAViaDE
.CalcP2Pt2:             pop     de                          ; de = x0*y2
                        mul     de                          ; .
                        and     a                           ; Clear carry preserve a
                        add     hl,de                       ; hl = x2*y0 + x0*y2
                        adc     a,a                         ; a = new carry
.CalcP2Pt3:             pop     de                          ; de = x1*y1
                        mul     de                          ; .
                        and     a                           ; hl = x2*y0 + x0*y2 + x1*y1, preserve carry flag
                        add     hl,de                       ; so we have hl = P2c P2 BC = P1P1
.CalcP2Carry:           adc     a,0                         ; A = calc carry + P2 carry in h
                        add     a,h                         ; l = P2 bc = P1 P0
                        ld      e,l                         ; ixl = l (via e as you can't do hl to ix direct)
.SaveP2:                ld      ixl,e                       ; a = P2 carry ixl:bc = P2 P1 P0
.CalcP3                 pop     de                          ; hl = x2*y1
                        mul     de                          ; .
                        ex      de,hl                       ; .
.AddP2Carry:            AHLequHLAddCarryAViaDE
.CalcP3Pt2:             pop     de                          ; de =  x1*y2
                        mul     de                          ; .
                        and     a                           ; Clear carry preserve a
                        add     hl,de                       ; hl = x2*y1 + x1*y2
                        adc     a,0                         ; a = new carry for P3, l = p3
                        add     a,h                         ; .
.SaveP3:                ld      e,l                         ; load ixh via e
                        ld      ixh,e                       ; so we now have a = P3 carry ix P3P2 bc = P1P0
.CalcP4:                pop     de                          ; de = x2* y2 + P3 carry
                        mul     de                          ; .
                        ex      de,hl                       ;
.AddP3Carry:            AHLequHLAddCarryAViaDE              ; hl ix bc = P5P4 P3P2 P1P0
.RecoverSignBit:        ld      a,l                         ; Is P4 populated,
                        and     a
                        jp      z,.P3toP0                   ; if not then we have result P3P2P1P0
.P4toP0:                pop     af                          ; else return with AHLBC
                        or      l
                        ld      hl,ix
                        ret
.P3toP0:                pop     af
                        ld      hl,ix                       ; move P2P2 into hl
                        or      h
                        ld      h,a
                        xor     a                           ; return result in hlbc with CarryClear
                        ret


    SAVENEX OPEN "maths24test.nex", EliteNextStartup , TopOfStack
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
   
