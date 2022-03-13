                        DEVICE ZXSPECTRUMNEXT
                        DEFINE  DOUBLEBUFFER 1
                        CSPECTMAP testMaths.map
                        OPT --zxnext=cspect --syntax=a --reversepop

testStartup:            ORG         $8000

                        ld      ix, TestCase1
.TestLoop:              ld      a,(testCounter)
                        ld      hl, testTotal
                        cp      (hl)
                        jr      z,.Done
                        ld      a,(ix+testCase.XLo)
                        ld      e,a
                        ld      a,(ix+testCase.XHi)
                        ld      l,a
                        ld      a,(ix+testCase.XSgn)
                        ld      h,a
                        ld      a,(ix+testCase.DVal)
                        ld      d,a
                        call    mulHLEbyDSigned
                        ld      iyl,'P'
                        ld      a,d
                        ld      (ix+testCase.ActualD),a
                        cp      (ix+testCase.ExpectedD)
                        jr      z,.DOK
                        ld      iyl,'1'
.DOK:
                        ld      a,e
                        ld      (ix+testCase.ActualE),a
                        cp      (ix+testCase.ExpectedE)
                        jr      z,.EOK
                        ld      iyl,'2'
.EOK:
                        ld      a,l
                        ld      (ix+testCase.ActualL),a
                        cp      (ix+testCase.ExpectedL)
                        jr      z,.LOK
                        ld      iyl,'3'
.LOK:
                        ld      a,c
                        ld      (ix+testCase.ActualC),a
                        cp      (ix+testCase.ExpectedC)
                        jr      z,.COK
                        ld      iyl,'4'
.COK:
                        ld      a,iyl
                        ld      (ix+testCase.PassFail),a
                        ld      hl,testCounter
                        inc     (hl)
                        push    ix
                        pop     hl
                        ld      a,16
                        add     hl,a
                        push    hl
                        pop     ix
                        jp      .TestLoop

.Done                   break
                        jp      .Done                   ; complete tight loop

                        INCLUDE "../Variables/constant_equates.asm"
                        INCLUDE "../Hardware/L2ColourDefines.asm"
                        INCLUDE "../Macros/carryFlagMacros.asm"
                        INCLUDE "../Macros/jumpMacros.asm"
                        INCLUDE "../Macros/ldCopyMacros.asm"
                        INCLUDE "../Macros/ShiftMacros.asm"
                        INCLUDE "../Macros/NegateMacros.asm"                        
                        INCLUDE "../Variables/general_variables_macros.asm"
                        INCLUDE "../Maths/multiply.asm"
                        INCLUDE "../Variables/general_variables.asm"

                        STRUCT testCase
XLo                     BYTE 1
XHi                     BYTE 2
XSgn                    BYTE 3
DVal                    BYTE 4
ExpectedC               BYTE 5
ExpectedL               BYTE 6
ExpectedE               BYTE 7
ExpectedD               BYTE 8
ActualC                 BYTE 9
ActualL                 BYTE 10
ActualE                 BYTE 11
ActualD                 BYTE 12
Padding1                BYTE 13
Padding2                BYTE 14
Padding3                BYTE 15
PassFail                BYTE 16
                        ENDS
;                            01   02   03   04   05   06   07   08   09   10   11   12   13   14   15   16
TestCase1               DB  $05, $05, $00, $05, $19, $19, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00
TestCase2               DB  $05, $05, $03, $05, $19, $19, $0F, $00, $00, $00, $00, $00, $00, $00, $02, $00
TestCase3               DB  $05, $05, $83, $05, $19, $19, $0F, $80, $00, $00, $00, $00, $00, $00, $03, $00
TestCase4               DB  $05, $05, $03, $85, $19, $19, $0F, $80, $00, $00, $00, $00, $00, $00, $04, $00 
TestCase5               DB  $05, $0A, $00, $05, $19, $32, $00, $00, $00, $00, $00, $00, $00, $00, $05, $00
TestCase6               DB  $0A, $05, $80, $05, $32, $19, $00, $80, $00, $00, $00, $00, $00, $00, $06, $00
TestCase7               DB  $05, $05, $80, $05, $19, $19, $00, $80, $00, $00, $00, $00, $00, $00, $07, $00
TestCase8               DB  $05, $05, $83, $0A, $32, $32, $1E, $80, $00, $00, $00, $00, $00, $00, $08, $00
TestCase9               DB  $05, $05, $83, $CA, $72, $73, $DF, $00, $00, $00, $00, $00, $00, $00, $09, $00 
TestCase10              DB  $05, $05, $03, $CA, $72, $73, $DF, $80, $00, $00, $00, $00, $00, $00, $10, $00 
testTotal               DB  ($-TestCase1)/16
testCounter             DB   0


    SAVENEX OPEN "mathssun.nex", $8000 , $7F00
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    