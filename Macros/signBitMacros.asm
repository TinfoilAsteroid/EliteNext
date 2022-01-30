
FlipMemSign:            MACRO mem
                        ld  a,(mem)
                        xor SignOnly8Bit
                        ld  (mem),a
                        ENDM
