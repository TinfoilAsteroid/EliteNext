
FlipMemSign:            MACRO mem
                        ld  a,(mem)
                        xor SignOnly8Bit
                        ld  (mem),a
                        ENDM

ClearSignBit:           MACRO reg
                        ld      a,reg
                        and     SignMask8Bit
                        ld      reg,a
                        ENDM
                        