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
                        ld      a,(ix+testCase.SrcH)
                        ld      h,a
                        ld      a,(ix+testCase.SrcC)
                        ld      c,a
                        ld      a,(ix+testCase.SrcB)
                        ld      b,a
                        ld      a,(ix+testCase.SrcL)
                        ld      l,a
                        ld      a,(ix+testCase.SrcE)
                        ld      e,a
                        ld      a,(ix+testCase.SrcD)
                        ld      d,a
                        call    AddBCHtoDELsigned
                        ld      iyl,'P'
                        ld      a,l
                        ld      (ix+testCase.ActualL),a
                        cp      (ix+testCase.ExpectedL)
                        jr      z,.LOK
                        ld      iyl,'1'
.LOK:
                        ld      a,e
                        ld      (ix+testCase.ActualE),a
                        cp      (ix+testCase.ExpectedE)
                        jr      z,.EOK
                        ld      iyl,'2'
.EOK:
                        ld      a,d
                        ld      (ix+testCase.ActualD),a
                        cp      (ix+testCase.ExpectedD)
                        jr      z,.DOK
                        ld      iyl,'3'
.DOK:

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
                        INCLUDE "../Variables/general_variables.asm"

; DEL = DEL + BCH signed, uses BC, DE, HL, IY, A
AddBCHtoDELsigned:      ld      a,b                 ; Are the values both the same sign?
                        xor     d                   ; .
                        and     SignOnly8Bit        ; .
                        jr      nz,.SignDifferent   ; .
.SignSame:              ld      a,b                 ; if they are then we only need 1 signe
                        and     SignOnly8Bit        ; so store it in iyh
                        ld      iyh,a               ;
                        ld      a,b                 ; bch = abs bch
                        and     SignMask8Bit        ; .
                        ld      b,a                 ; .
                        ld      a,d                 ; del = abs del
                        and     SignMask8Bit        ; .
                        ld      d,a                 ; .
                        ld      a,h                 ; l = h + l
                        add     l                   ; .
                        ld      l,a                 ; . 
                        ld      a,c                 ; e = e + c + carry
                        adc     e                   ; .
                        ld      e,a                 ; .
                        ld      a,b                 ; d = b + d + carry (signed)
                        adc     d                   ; 
                        or      iyh                 ; d = or back in sign bit
                        ld      d,a                 ; 
                        ret                         ; done
.SignDifferent:         ld      a,b                 ; bch = abs bch
                        ld      iyh,a               ; iyh = b sign
                        and     SignMask8Bit        ; .
                        ld      b,a                 ; .
                        ld      a,d                 ; del = abs del
                        ld      iyl,a               ; iyl = d sign
                        and     SignMask8Bit        ; .
                        ld      d,a                 ; .
                        push    hl                  ; hl = bc - de
                        ld      hl,bc               ; if bc < de then there is a carry
                        sbc     hl,de               ;
                        pop     hl                  ;
                        jr      c,.BCHltDEL
                        jr      nz,.DELltBCH        ; if the result was not zero then DEL > BCH
.BCeqDE:                ld      a,h                 ; if the result was zero then check lowest bits
                        JumpIfALTNusng l,.BCHltDEL
                        jr      nz,.DELltBCH
; The same so its just zero
.BCHeqDEL:              xor     a                  ; its just zero
                        ld      d,a                ; .
                        ld      e,a                ; .
                        ld      l,a                ; .
                        ret                        ; .
;BCH is less than DEL so its DEL - BCH the sort out sign
.BCHltDEL:              ld      a,l                ; l = l - h                      ; ex
                        sub     h                  ; .                              ;   01D70F DEL
                        ld      l,a                ; .                              ;  -000028 BCH
                        ld      a,e                ; e = e - c - carry              ;1. 
                        sbc     c                  ; .                              ;
                        ld      e,a                ; .                              ;
                        ld      a,d                ; d = d - b - carry              ;
                        sbc     b                  ; .                              ;
                        ld      d,a                ; .                              ;
                        ld      a,iyl              ; as d was larger, take d sign
                        and     SignOnly8Bit       ;
                        or      d                  ;
                        ld      d,a                ;
                        ret
.DELltBCH:              ld      a,h                ; l = h - l
                        sub     l                  ;
                        ld      l,a                ;
                        ld      a,c                ; e = c - e - carry
                        sbc     e                  ;
                        ld      e,a                ;
                        ld      a,b                ; d = b - d - carry
                        sbc     d                  ;
                        ld      d,a                ;
                        ld      a,iyh              ; as b was larger, take b sign into d
                        and     SignOnly8Bit       ;
                        or      d                  ;
                        ld      d,a                ;
                        ret


                        STRUCT testCase
SrcH                    BYTE 1
SrcC                    BYTE 2
SrcB                    BYTE 3
SrcL                    BYTE 4
SrcE                    BYTE 5
SrcD                    BYTE 6
ExpectedL               BYTE 7
ExpectedE               BYTE 8
ExpectedD               BYTE 9
ActualL                 BYTE 10
ActualE                 BYTE 11
ActualD                 BYTE 12
Padding1                BYTE 13
Padding2                BYTE 14
Padding3                BYTE 15
PassFail                BYTE 16
                        ENDS
;                            01   02   03   04   05   06   07   08   09   10   11   12   13   14   15   16
TestCase1               DB  $05, $05, $00, $05, $05, $00, $0A, $0A, $00, $00, $00, $00, $00, $00, $01, $00 ; basic
TestCase2               DB  $05, $05, $03, $05, $05, $03, $0A, $0A, $06, $00, $00, $00, $00, $00, $02, $00 ; basic 3 byte
TestCase3               DB  $05, $05, $83, $05, $05, $03, $00, $00, $00, $00, $00, $00, $00, $00, $03, $00 ; - + = 0
TestCase4               DB  $05, $05, $03, $05, $05, $83, $00, $00, $00, $00, $00, $00, $00, $00, $04, $00 ; + -  =0
TestCase5               DB  $05, $05, $83, $05, $05, $83, $0A, $0A, $86, $00, $00, $00, $00, $00, $05, $00 ; - -  add
TestCase6               DB  $05, $05, $83, $05, $05, $02, $00, $00, $81, $00, $00, $00, $00, $00, $06, $00 ; - +<1
TestCase7               DB  $05, $05, $03, $05, $02, $83, $00, $03, $00, $00, $00, $00, $00, $00, $07, $00 ; + -<1
TestCase8               DB  $05, $02, $82, $05, $05, $03, $00, $03, $01, $00, $00, $00, $00, $00, $08, $00 ; - +>1
TestCase9               DB  $05, $02, $03, $05, $05, $83, $00, $03, $80, $00, $00, $00, $00, $00, $09, $00 ; + ->1
testTotal               DB  ($-TestCase1)/16
testCounter             DB   0


    SAVENEX OPEN "mathssun2.nex", $8000 , $7F00
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    