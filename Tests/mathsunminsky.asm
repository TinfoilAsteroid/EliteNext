                        DEVICE ZXSPECTRUMNEXT
                        DEFINE  DOUBLEBUFFER 1
                        CSPECTMAP mathsunminsky.map
                        OPT --zxnext=cspect --syntax=a --reversepop

testStartup:            ORG         $8000

                        ld      ix, TestCase1
.TestLoop:              ld      a,(testCounter)
                        ld      hl, testTotal
                        cp      (hl)
                        jp     z,.Done
.CopyXYZ:               ld      bc,9
                        push    ix
                        pop     hl
                        ld      de,SBnKxlo
                        ldir
                        ld      a,(hl)
                        ld      (ALPHA),a
                        inc     hl
                        ld      a,(hl)
                        ld      (BETA),a
                        call    SunApplyMyRollAndPitch
.SaveResults:           push    ix
                        pop     hl
                        ld      a,32
                        add     hl,a
                        ex      hl,de
                        ld      hl,SBnKxlo
                        ld      bc,9
                        ldir
                        ex      de,hl
.TestX:                 ld      iyl,'X'
                        push    ix
                        pop     hl
                        ld      a,16
                        add     hl,a
                        ld      de,SBnKxlo
                        dec     de
                        ld      bc,3
.NextXByte:             inc     de
                        ld      a,(de)
                        cpi
                        jp      po,.TestY
                        jp      z,.NextXByte
                        jp      .failed
.TestY:                 ld      iyl,'Y'
                        push    ix
                        pop     hl
                        ld      a,16 + 3
                        add     hl,a
                        ld      de,SBnKylo
                        dec     de
                        ld      bc,3
.NextYByte:             inc     de
                        ld      a,(de)
                        cpi
                        jp      po,.TestZ
                        jp      z,.NextYByte
                        jp      .failed
.TestZ:                 ld      iyl,'Z'
                        push    ix
                        pop     hl
                        ld      a,16 + 6
                        add     hl,a
                        ld      de,SBnKzlo
                        dec     de
                        ld      bc,3
.NextZByte:             inc     de
                        ld      a,(de)
                        cpi
                        jp      po,.TestDone
                        jp      z,.NextZByte
                        jp      .failed
.TestDone:              ld      iyl,'P'
.failed:                ld      hl,ix
                        ld      a,15
                        add     hl,a
                        ld      a,iyl
                        ld      (hl),a
                        ld      a,16
                        add     hl,a
                        ld      a,iyl
                        ld      (hl),a
                        ld      a,16
                        add     hl,a
                        ld      a,iyl                        
                        ld      (hl),a
                        ld      (FailPoint),a
                        ld      hl,ix
                        ld      a,48
                        add     hl,a
                        ld      ix,hl
                        ld      hl,testCounter
                        inc     (hl)
                        jp      .TestLoop

.Done                   break
                        jp      .Done                   ; complete tight loop

                        INCLUDE "../Variables/constant_equates.asm"
                        INCLUDE "../Hardware/L2ColourDefines.asm"
                        INCLUDE "../Macros/carryFlagMacros.asm"
                        INCLUDE "../Macros/signBitMacros.asm"
                        INCLUDE "../Macros/jumpMacros.asm"
                        INCLUDE "../Macros/ReturnMacros.asm"
                        INCLUDE "../Macros/ldCopyMacros.asm"
                        INCLUDE "../Macros/ShiftMacros.asm"
                        INCLUDE "../Macros/NegateMacros.asm"                        
                      
                        INCLUDE "../Variables/general_variables_macros.asm"
                        INCLUDE "../Maths/multiply.asm"
                        INCLUDE "../Maths/asm_add.asm"
                        INCLUDE "../Variables/general_variables.asm"



                        STRUCT testCase
XLo                     BYTE 1  ; ROW 1
XHi                     BYTE 2  ; ROW 1
XSgn                    BYTE 3  ; ROW 1
YLo                     BYTE 4  ; ROW 1
YHi                     BYTE 5  ; ROW 1
YSgn                    BYTE 6  ; ROW 1
ZLo                     BYTE 7  ; ROW 1
ZHi                     BYTE 8  ; ROW 1
ZSgn                    BYTE 9  ; ROW 1
Pitch                   BYTE 10 ; ROW 1
Roll                    BYTE 11 ; ROW 1
Padding1                BYTE 12 ; ROW 1
Padding2                BYTE 13 ; ROW 1
Padding3                BYTE 14 ; ROW 1
Padding4                BYTE 15 ; ROW 1
Padding5                BYTE 16 ; ROW 1
XLoRes                  BYTE 17 ; ROW 2
XHRes                   BYTE 18 ; ROW 2
XSgnRes                 BYTE 19 ; ROW 2
YLoRes                  BYTE 20 ; ROW 2
YHRes                   BYTE 21 ; ROW 2
YSgnRes                 BYTE 22 ; ROW 2
ZLoRes                  BYTE 23 ; ROW 2
ZHiRes                  BYTE 24 ; ROW 2
ZSgnRes                 BYTE 25 ; ROW 2
Padding6                BYTE 26 ; ROW 2
Padding7                BYTE 27 ; ROW 2
Padding8                BYTE 28 ; ROW 2
Padding9                BYTE 29 ; ROW 2
Padding10               BYTE 30 ; ROW 2
Padding11               BYTE 31 ; ROW 2
PassFail                BYTE 32 ; ROW 3
XLoAct                  BYTE 33 ; ROW 3
XHAct                   BYTE 34 ; ROW 3
XSgnAct                 BYTE 35 ; ROW 3
YLoAct                  BYTE 36 ; ROW 3
YHAct                   BYTE 37 ; ROW 3
YSgnAct                 BYTE 38 ; ROW 3
ZLoAct                  BYTE 39 ; ROW 3
ZHiAct                  BYTE 40 ; ROW 3
ZSgnAct                 BYTE 41 ; ROW 3
Padding12               BYTE 42 ; ROW 3
Padding13               BYTE 43 ; ROW 3
Padding14               BYTE 44 ; ROW 3
Padding15               BYTE 45 ; ROW 3
Padding16               BYTE 46 ; ROW 3
Padding17               BYTE 47 ; ROW 3
Padding18               BYTE 48 ; ROW 3


                        ENDS
                        ;    X              Y              Z              pit  rll                            X              Y              Z           
;                            01   02   03   04   05   06   07   08   09   10   11   12   13   14   15   16    01   02   03   04   05   06   07   08   09   10   11   12   13   14   15   16    01   02   03   04   05   06   07   08   09   10   11   12   13   14   15   16  
TestCase1               DB  $00, $00, $00, $00, $00, $00, $32, $00, $00, $0B, $00, $00, "T", "0", "1", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "R", "0", "1", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "0", "1", $00      ;TestCase1 
TestCase2               DB  $64, $00, $00, $00, $00, $00, $32, $00, $00, $0B, $0B, $00, "T", "0", "2", $00,  $64, $00, $00, $06, $00, $80, $32, $00, $00, $00, $00, $00, "R", "0", "2", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "0", "2", $00      ;TestCase2 
TestCase3               DB  $64, $00, $00, $00, $00, $00, $32, $00, $00, $0B, $00, $00, "T", "0", "3", $00,  $64, $00, $00, $04, $00, $80, $32, $00, $00, $00, $00, $00, "R", "0", "3", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "0", "3", $00      ;TestCase3 
TestCase4               DB  $64, $00, $00, $00, $00, $00, $32, $00, $00, $0B, $0B, $00, "T", "0", "4", $00,  $64, $00, $00, $06, $00, $80, $32, $00, $00, $00, $00, $00, "R", "0", "4", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "0", "4", $00      ;TestCase4 
TestCase5               DB  $00, $00, $00, $64, $00, $00, $32, $00, $00, $0B, $00, $00, "T", "0", "5", $00,  $04, $00, $00, $64, $00, $00, $32, $00, $00, $00, $00, $00, "R", "0", "5", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "0", "5", $00      ;TestCase5 
TestCase6               DB  $00, $00, $00, $64, $00, $00, $32, $00, $00, $0B, $00, $00, "T", "0", "6", $00,  $04, $00, $00, $64, $00, $00, $32, $00, $00, $00, $00, $00, "R", "0", "6", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "0", "6", $00      ;TestCase6 
TestCase7               DB  $00, $00, $00, $64, $00, $00, $32, $00, $00, $00, $0B, $00, "T", "0", "7", $00,  $00, $00, $00, $62, $00, $00, $36, $00, $00, $00, $00, $00, "R", "0", "7", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "0", "7", $00      ;TestCase7 
TestCase8               DB  $00, $00, $00, $64, $00, $00, $32, $00, $00, $00, $0B, $00, "T", "0", "8", $00,  $00, $00, $00, $62, $00, $00, $36, $00, $00, $00, $00, $00, "R", "0", "8", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "0", "8", $00      ;TestCase8 
TestCase9               DB  $E2, $04, $00, $64, $00, $00, $C8, $00, $00, $0B, $00, $00, "T", "0", "9", $00,  $E4, $04, $00, $2f, $00, $00, $C8, $00, $00, $00, $00, $00, "R", "0", "9", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "0", "9", $00      ;TestCase9 
TestCase10              DB  $E3, $04, $00, $64, $00, $00, $C8, $00, $00, $00, $0B, $00, "T", "1", "0", $00,  $E3, $04, $00, $5C, $00, $00, $CC, $00, $00, $00, $00, $00, "R", "1", "0", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "1", "0", $00      ;TestCase10
TestCase11              DB  $E4, $04, $00, $64, $00, $00, $C8, $00, $00, $0B, $0B, $00, "T", "1", "1", $00,  $E5, $04, $00, $27, $00, $00, $CA, $00, $00, $00, $00, $00, "R", "1", "1", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "1", "1", $00      ;TestCase11
TestCase12              DB  $64, $00, $00, $E2, $04, $00, $C8, $00, $00, $0B, $00, $00, "T", "1", "2", $00,  $99, $00, $00, $DE, $04, $00, $C8, $00, $00, $00, $00, $00, "R", "1", "2", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "1", "2", $00      ;TestCase12
TestCase13              DB  $64, $00, $00, $E2, $04, $00, $C8, $00, $00, $00, $0B, $00, "T", "1", "3", $00,  $64, $00, $00, $D8, $04, $00, $FD, $00, $00, $00, $00, $00, "R", "1", "3", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "1", "3", $00      ;TestCase13
TestCase14              DB  $64, $00, $00, $E2, $04, $00, $C8, $00, $00, $0B, $0B, $00, "T", "1", "4", $00,  $99, $00, $00, $D4, $04, $00, $FD, $00, $00, $00, $00, $00, "R", "1", "4", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "1", "4", $00      ;TestCase14
TestCase15              DB  $E2, $04, $00, $64, $00, $00, $C8, $00, $00, $0B, $00, $00, "T", "1", "5", $00,  $E4, $04, $00, $2F, $00, $00, $C8, $00, $00, $00, $00, $00, "R", "1", "5", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "1", "5", $00      ;TestCase15
TestCase16              DB  $64, $00, $00, $E2, $04, $00, $D0, $07, $00, $0B, $00, $00, "T", "1", "6", $00,  $99, $00, $00, $DE, $04, $00, $D0, $07, $00, $00, $00, $00, "R", "1", "6", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "1", "6", $00      ;TestCase16
TestCase17              DB  $64, $00, $00, $E2, $04, $00, $D0, $07, $00, $00, $0B, $00, "T", "1", "7", $00,  $64, $00, $00, $8A, $04, $00, $05, $08, $00, $00, $00, $00, "R", "1", "7", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "1", "7", $00      ;TestCase17
TestCase18              DB  $64, $00, $00, $E2, $04, $00, $D0, $07, $00, $0B, $0B, $00, "T", "1", "8", $00,  $95, $00, $00, $86, $04, $00, $05, $08, $00, $00, $00, $00, "R", "1", "8", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "1", "8", $00      ;TestCase18
TestCase19              DB  $E2, $04, $00, $64, $00, $00, $D0, $07, $00, $0B, $00, $00, "T", "1", "9", $00,  $E4, $04, $00, $2F, $00, $00, $D0, $07, $00, $00, $00, $00, "R", "1", "9", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "1", "9", $00      ;TestCase19
TestCase20              DB  $E2, $04, $00, $64, $00, $00, $D0, $07, $00, $00, $0B, $00, "T", "2", "0", $00,  $E2, $04, $00, $0E, $00, $00, $D4, $07, $00, $00, $00, $00, "R", "2", "0", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "2", "0", $00      ;TestCase20
TestCase21              DB  $E2, $04, $00, $64, $00, $00, $D0, $07, $00, $0B, $0B, $00, "T", "2", "1", $00,  $E1, $04, $00, $27, $00, $80, $D2, $07, $00, $00, $00, $00, "R", "2", "1", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "2", "1", $00      ;TestCase21
TestCase22              DB  $64, $00, $00, $64, $00, $00, $D0, $07, $00, $0B, $00, $00, "T", "2", "2", $00,  $68, $00, $00, $60, $00, $00, $D0, $07, $00, $00, $00, $00, "R", "2", "2", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "2", "2", $00      ;TestCase22
TestCase23              DB  $64, $00, $00, $64, $00, $00, $D0, $07, $00, $00, $0B, $00, "T", "2", "3", $00,  $64, $00, $00, $0E, $00, $00, $D4, $07, $00, $00, $00, $00, "R", "2", "3", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "2", "3", $00      ;TestCase23
TestCase24              DB  $64, $00, $00, $64, $00, $00, $D0, $07, $00, $0B, $0B, $00, "T", "2", "4", $00,  $64, $00, $00, $0A, $00, $00, $D4, $07, $00, $00, $00, $00, "R", "2", "4", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "2", "4", $00      ;TestCase24
TestCase25              DB  $88, $01, $03, $64, $00, $00, $C8, $00, $00, $0B, $00, $00, "T", "2", "5", $00,  $21, $00, $03, $AC, $20, $80, $C8, $00, $00, $00, $00, $00, "R", "2", "5", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "2", "5", $00      ;TestCase25
TestCase26              DB  $88, $01, $03, $64, $00, $00, $C8, $00, $00, $00, $0B, $00, "T", "2", "6", $00,  $88, $01, $03, $5C, $00, $00, $CC, $00, $00, $00, $00, $00, "R", "2", "6", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "2", "6", $00      ;TestCase26
TestCase27              DB  $88, $01, $03, $64, $00, $00, $C8, $00, $00, $0B, $0B, $00, "T", "2", "7", $00,  $21, $00, $03, $A6, $20, $80, $9F, $00, $00, $00, $00, $00, "R", "2", "7", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "2", "7", $00      ;TestCase27
TestCase28              DB  $E2, $04, $00, $64, $00, $00, $88, $01, $03, $0B, $00, $00, "T", "2", "8", $00,  $E4, $04, $00, $2F, $00, $00, $88, $01, $03, $00, $00, $00, "R", "2", "8", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "2", "8", $00      ;TestCase28
TestCase29              DB  $E2, $04, $00, $64, $00, $00, $88, $01, $03, $00, $0B, $00, "T", "2", "9", $00,  $E2, $04, $00, $AD, $20, $80, $8C, $01, $03, $00, $00, $00, "R", "2", "9", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "2", "9", $00      ;TestCase29
TestCase30              DB  $E2, $04, $00, $64, $00, $00, $88, $01, $03, $0B, $0B, $00, "T", "3", "0", $00,  $79, $03, $00, $E1, $20, $80, $8A, $01, $03, $00, $00, $00, "R", "3", "0", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "3", "0", $00      ;TestCase30
TestCase31              DB  $E2, $04, $00, $88, $01, $03, $88, $01, $03, $0B, $00, $00, "T", "3", "1", $00,  $F0, $25, $00, $53, $01, $03, $88, $01, $03, $00, $00, $00, "R", "3", "1", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "3", "1", $00      ;TestCase31
TestCase32              DB  $E2, $04, $00, $88, $01, $03, $88, $01, $03, $00, $0B, $00, "T", "3", "2", $00,  $E2, $04, $00, $0C, $DF, $02, $98, $22, $03, $00, $00, $00, "R", "3", "2", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "3", "2", $00      ;TestCase32
TestCase33              DB  $E2, $04, $00, $88, $01, $03, $88, $01, $03, $0B, $0B, $00, "T", "3", "3", $00,  $75, $24, $00, $D7, $DE, $02, $96, $22, $03, $00, $00, $00, "R", "3", "3", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "3", "3", $00      ;TestCase33
TestCase34              DB  $88, $01, $03, $64, $00, $00, $D0, $07, $00, $0B, $00, $00, "T", "3", "4", $00,  $21, $00, $03, $AC, $20, $80, $D0, $07, $00, $00, $00, $00, "R", "3", "4", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "3", "4", $00      ;TestCase25
TestCase35              DB  $E2, $04, $00, $64, $00, $00, $C8, $00, $00, $0B, $00, $00, "T", "3", "5", $00,  $E4, $04, $00, $2F, $00, $00, $C8, $00, $00, $00, $00, $00, "R", "3", "5", $00,  $00, $00, $00, $00, $00, $00, $32, $00, $00, $00, $00, $00, "A", "3", "5", $00      ;TestCase28
PaddingString           DB "----------------"
PaddingString2          DB ">"
testTotal               DB  ($-TestCase1)/48
PaddingString3          DB "~"
testCounter             DB   0
PaddingString4          DB "~"
FailPoint               DB   0
PaddingString5          DB "<---------"
SBnKxlo                 DB 0
SBnKxhi                 DB 0
SBnKxsgn                DB 0
SBnKylo                 DB 0
SBnKyhi                 DB 0
SBnKysgn                DB 0
SBnKzlo                 DB 0
SBnKzhi                 DB 0
SBnKzsgn                DB 0

SunAlphaMulX            DS 4
SunAlphaMulY            DS 4
SunBetaMulZ             DS 4
SunK2                   DS 3
UBnKxlo                 DS 4


SunApplyMyRollAndPitch: ld      a,(ALPHA)                   ; no roll or pitch, no calc needed
                        ld      hl,BETA
                        or      (hl)
                        and     SignMask8Bit
                        jp      z,.NoRotation
.CalcAlphaMulX:         ld      a,(ALPHA)                   ; get roll magnitude
                        xor     SignOnly8Bit                ; d = -alpha (Q value)
                        ld      d,a                         ; .
                        ld      a,(SBnKxlo)                 ; HLE = x sgn, hi, lo
                        ld      e,a                         ; .
                        ld      hl,(SBnKxhi)                ; .
                        call    mulHLEbyDSigned             ; DELC = x * -alpha, so DEL = X * -alpha / 256 where d = sign byte
.SaveAlphaMulX:         ;ld      a,c                         ; a = upper byte of results which will have the sign               ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      (SunAlphaMulX),a            ; save sign from result, ELC holds actual result                   ONLY NEEDED FOR DEBUGGING TEST
                        ld      a,l                         ; also save all of alpha *X as we will need it later
                        ld      (SunAlphaMulX+1),a
                        ld      a,e
                        ld      (SunAlphaMulX+2),a
                        ld      a,d
                        ld      (SunAlphaMulX+3),a          ; we actually only want X1 X2 X3 later as its /256
.CalcK2:                ld      de,(SBnKyhi)                ; DEL = Y
                        ld      a,(SBnKylo)                 ; .
                        ld      l,a                         ; .
                        ld      bc,(SunAlphaMulX+2)         ; BCH = Y sgn, hi, lo, we loose the C from result
                        ld      a,(SunAlphaMulX+1)          ; Deal with sign in byte 4
                        ld      h,a                         ; .
                        call    AddBCHtoDELsigned           ; DEL = y - (alpha * x)
                        ld      a,l                         ; K2  = DEA = DEL = y - (alpha * x)
                        ld      (SunK2),a                   ; we also need to save l for teh beta k2 calc
                        ld      (SunK2+1),de                ; 
.CalcBetaMulK2:         ex      de,hl                       ; HLE == DEA
                        ld      e,a                         ; .
                        ld      a,(BETA)                    ; D = BETA
                        ld      d,a                         ; .
                        call    mulHLEbyDSigned             ; DELC = Beta * K2, DEL = Beta/256 * K2
.CalcZ:                 ld      bc,(SBnKzhi)                ; BCH = z
                        ld      a,(SBnKzlo)                 ;
                        ld      h,a                         ;
                        call    AddBCHtoDELsigned           ; DEL still = Beta * K2 so its z + Beta * K2
                        ld      (SBnKzhi),de                ; z = resuklt
                        ld      a,l                         ; .
                        ld      (SBnKzlo),a                 ; .
.CalcBetaZ:             ld      a,(BETA)
                        xor     SignOnly8Bit                ; d = -beta (Q value)
                        ld      d,a                         ; .
                        ld      a,(SBnKzlo)                 ; HLE = z
                        ld      e,a                         ; .
                        ld      hl,(SBnKzhi)                ; .
                        call    mulHLEbyDSigned             ; DELC = z * -beta, so DEL = Z * -beta / 256 where d = sign byte
.SaveAlphaMulZ:         ;ld      a,c                         ; a = upper byte of results which will have the sign             ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      (SunBetaMulZ),a             ; save sign from result, ELC holds actual result                 ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      a,l                         ; also save all of alpha *X as we will need it later             ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      (SunBetaMulZ+1),a           ; .                                                              ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      a,e                         ; .                                                              ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      (SunBetaMulZ+2),a           ; .                                                              ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      a,d                         ; .                                                              ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      (SunBetaMulZ+3),a           ; we actually only want X1 X2 X3 later as its /256               ONLY NEEDED FOR DEBUGGING TEST
.CalcY:                 ld      bc,de                       ; bch = - Beta * z
                        ld      h,l
                        ld      de,(SunK2+1)                ; DEL = k2
                        ld      a,(SunK2)
                        ld      l,a
                        call    AddBCHtoDELsigned           ; DEL = K2 - Beta * Z
                        ld      (SBnKyhi),de                ; y = DEL = K2 - Beta * Z
                        ld      a,l                         ; .
                        ld      (SBnKylo),a                 ; .
.CalcAlphaMulY:         ld      a,(ALPHA)
                        ld      d,a                         ; d = alpha (Q value)
                        ld      a,(SBnKylo)                 ; HLE = x sgn, hi, lo
                        ld      e,a                         ; .
                        ld      hl,(SBnKyhi)                ; .
                        call    mulHLEbyDSigned             ; DELC = y * alpha, so DEL = Y * alpha / 256 where d = sign byte
.SaveAlphaMulY:         ld      a,c                         ; a = upper byte of results which will have the sign
                        ld      (SunAlphaMulY),a            ; save sign from result, ELC holds actual result
                        ld      a,l                         ; also save all of alpha *X as we will need it later
                        ld      (SunAlphaMulY+1),a
                        ld      a,e
                        ld      (SunAlphaMulY+2),a
                        ld      a,d
                        ld      (SunAlphaMulY+3),a                                             
.CalcxPLusAlphaY:       ld      bc,de                        ; BCH = Y sgn, hi, lo, we loose the C from result Deal with sign in byte 4
                        ld      h,l                         ; .
                        ld      de,(SBnKxhi)                ; DEL = Y
                        ld      a,(SBnKxlo)                 ; .
                        ld      l,a                         ; .
                        call    AddBCHtoDELsigned           ; DEL = x + alpha * Y
.SaveResult1:           ld      a,d                         ; Result 1 (X) = AHL + DEL
                        ld      h,e                         ;
.CopyResultTo2:         ld      (SBnKxlo+2),a               ; .
                        ld      (SBnKxlo) ,hl               ; .
                        ret
.NoRotation:            ld      a,(DELTA)                   ; BCH = - Delta
                        ReturnIfAIsZero
                        ld      c,0                         ;
                        ld      h,a                         ; 
                        ld      b,$80                       ;
                        ld      de,(SBnKzhi)                ; DEL = z position
                        ld      a,(SBnKzlo)                 ; .
                        ld      l,a                         ; .
                        call    AddBCHtoDELsigned           ; update speed
                        ld      (SBnKzhi),DE                ; write back to zpos
                        ld      a,l
                        ld      (SBnKzlo),a                ;
                        ret
                        


    SAVENEX OPEN "mathsunminsky.nex", $8000 , $7F00
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    