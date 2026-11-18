; Routines moved out of Maths24/asm_divide_helpers.asm as nothing in the eliteNext.asm build references them.
; Not included in the game build; INCLUDE this after asm_divide_helpers.asm to use them again.

Floor_DivQSigned:       ld      a,b             ; save resultant sign
                        xor     d               ;
                        and     $80             ;
                        ld      ixh,a           ;
                        ld      a,b
                        and     $7F
                        ld      b,a
                        ld      a,d
                        and     $7F
                        ld      d,a
                        call    Floor_DivQ
                        ld      a,b
                        or      ixh
                        ld      b,a
                        ret

div_de_div_96_signed:   ld      a,d
                        or      b
                        and     $80
                        ex      af,af'          ; save sign bit
                        res     7,d
                        res     7,b
                        ld      a,d
                        or      e
                        jp      z,  .ResultIsZero
                        ld      a,b
                        or      c
                        jp      nz, .OKtoDivide
                        ld      c,1
.OKtoDivide:            call    DEequDEDivBC    ; get back sign and set as needed
                        ex      af,af'          ; 
                        or      d               ; 
                        ld      d,a             ; 
                        ret
.ResultIsZero:          ld      de,0
                        ret

DIV16Amul256dQUNDOC:    ld      b,a
                        ld      c,0
                        ld      hl,varQ
                        ld      a,(hl)
                        ld      d,0
                        ld      e,a
; NOTE: originally falls through into DIV16BCDivDEUNDOC / DIV16UNDOC in asm_divide_helpers.asm
