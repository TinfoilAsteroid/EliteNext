
NegIY:			    MACRO
                    xor a
                    sub iyl
                    ld iyl,a
                    sbc a,a
                    sub iyh
                    ld iyh,a
                    ENDM

NegHL:			    MACRO
                    xor a
                    sub l
                    ld l,a
                    sbc a,a
                    sub h
                    ld h,a
                    ENDM

NegDE:			    MACRO
                    xor a
                    sub e
                    ld e,a
                    sbc a,a
                    sub d
                    ld d,a
                    ENDM

NegBC:			    MACRO
                    xor a
                    sub c
                    ld c,a
                    sbc a,a
                    sub  b
                    ld b,a
                    ENDM

NegH                MACRO
                    ld      a,h
                    neg
                    ld      h,a
                    ENDM

NegD                MACRO
                    ld      a,d
                    neg
                    ld      d,a
                    ENDM

NegB                MACRO
                    ld      a,b
                    neg
                    ld      b,a
                    ENDM
                    