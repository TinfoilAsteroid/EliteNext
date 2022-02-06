ReturnOnBitSet:         MACRO  reg, bitnbr,
                        bit 	bitnbr,reg
                        ret     nz
                        ENDM

ReturnOnMemBitSet:      MACRO mem, bitnbr
                        ld   a,(mem)
                        bit 	bitnbr,a
                        ret     nz
                        ENDM

ReturnOnBitClear:       MACRO reg, bitnbr
                        bit 	bitnbr,reg
                        ret		z
                        ENDM

ReturnOnMemBitClear:    MACRO mem, bitnbr
                        ld     a,(mem)
                        bit 	bitnbr,a
                        ret		z
                        ENDM

ReturnIfMemFalse:       MACRO   mem
                        ld      a,(mem)
                        and     a
                        ret     nz
                        ENDM

ReturnIfMemTrue:        MACRO   mem
                        ld      a,(mem)
                        and     a
                        ret     z
                        ENDM

ReturnIfAIsZero:        MACRO
                        and a
                        ret    z
                        ENDM
    
ReturnIfMemisZero:      MACRO mem
                        ld   a,(mem)
                        and a
                        ret    z
                        ENDM
                        
ReturnIfBitMaskClear    MACRO   bitmask
                        and     bitmask
                        ret     z
                        ENDM
    
ReturnIfBitMaskSet      MACRO   bitmask
                        and     bitmask
                        ret     nz
                        ENDM

ReturnIfMemEquN:        MACRO mem, value
                        ld     a,(mem)
                        cp     value
                        ret    nz
                        ENDM
    
ReturnIfMemNeNusng:     MACRO mem, value
                        ld   a,(mem)
                        cp     value
                        ret    z
                        ENDM
                        
ReturnIfANotZero:       MACRO
                        cp     0
                        ret    nz
                        ENDM
    
ReturnIfMemNotZero:     MACRO mem
                        ld     a,(mem)
                        cp     0
                        ret    nz
                        ENDM
    
ReturnIfAGTEusng:       MACRO value
                        cp    value
                        ret	 nc
                        ENDM
    
ReturnIfALTNusng:       MACRO value
                        cp    value
                        ret	 c
                        ENDM
    
ReturnIfAGTENusng:      MACRO value
                        cp    value
                        ret	 nc
                        ENDM
    
ReturnIfANENusng:       MACRO value
                        cp      value
                        ret     nz
                        ENDM
    
ReturnIfAEqNusng:       MACRO value
                        cp      value
                        ret     z
                        ENDM
