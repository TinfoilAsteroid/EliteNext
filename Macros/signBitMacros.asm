SetMemBitN              MACRO mem,bitnbr
                        ld      hl,mem
                        set     bitnbr,(hl)
                        ENDM

ClearMemBitN            MACRO mem,bitnbr
                        ld      hl,mem
                        res     bitnbr,(hl)
                        ENDM

                        
ClearSignBitMem:        MACRO mem
                        ld      a,(mem)
                        and     SignMask8Bit
                        ld      (mem),a
                        ENDM

SetSignBitMem:          MACRO   mem
                        ld      a,(mem)
                        or      SignOnly8Bit
                        ld      (mem),a
                        ENDM

FlipSignMem:            MACRO mem
                        ld  a,(mem)
                        xor SignOnly8Bit
                        ld  (mem),a
                        ENDM

SignBitOnlyMem:         MACRO mem
                        ld      a
                        and     SignOnly8Bit
                        ld      (mem),a
                        ENDM
                        
ClearSignBit:           MACRO reg
                        ld      a,reg
                        and     SignMask8Bit
                        ld      reg,a
                        ENDM

SetSignBit:             MACRO   reg
                        ld      a,reg
                        or      SignOnly8Bit
                        ld      reg,a
                        ENDM
                        
FlipSignBit:            MACRO   reg
                        ld      a,reg
                        xor     SignOnly8Bit
                        ld      reg,a
                        ENDM

SignBitOnly:            MACRO   reg
                        ld      a,reg
                        and     SignOnly8Bit
                        ld      reg,a
                        ENDM
                        
ClearSignBitA:          MACRO 
                        and     SignMask8Bit
                        ENDM

SetSignBitA:            MACRO   
                        or      SignOnly8Bit
                        ENDM

FlipSignBitA:           MACRO   
                        xor     SignOnly8Bit
                        ENDM

SignBitOnlyA:           MACRO
                        and     SignOnly8Bit
                        ENDM                        