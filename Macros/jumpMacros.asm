JumpIfPositive:	        MACRO target
                        jp		p, target
                        ENDM

JumpIfNegative:	        MACRO target
                        jp		m, target
                        ENDM


JumpIfUnderflow:	    MACRO target
                        jp		po, target
                        ENDM

JumpIfOverflow:	        MACRO target
                        jp		po, target
                        ENDM


JumpIfNotZero:	        MACRO target
                        jp	nz,target
                        ENDM

JumpIfZero:	            MACRO target
                        jp	z,target
                        ENDM

;.. Bit routines
JumpOnLeadSignSet:      MACRO   reg, target
                        ld      a,reg
                        and     SignOnly8Bit
                        jp      nz,target
                        ENDM

JumpOnLeadSignClear:    MACRO   reg, target
                        ld      a,reg
                        and     SignOnly8Bit
                        jp      z,target
                        ENDM

JumpOnLeadSignSetA:     MACRO   target
                        and     SignOnly8Bit
                        jp      nz,target
                        ENDM

JumpOnLeadSignClearA:   MACRO   target
                        and     SignOnly8Bit
                        jp      z,target
                        ENDM

JumpOnMemBitSet:        MACRO mem, bitnbr, target
                        ld      a,(mem)
                        bit 	bitnbr,a
                        jp      nz,target
                        ENDM

JumpOnMemBitClear:      MACRO mem, bitnbr, target
                        ld      a,(mem)
                        bit 	bitnbr,a
                        jp      z,target
                        ENDM

JumpOnABit5Set:         MACRO   target
                        and     Bit5Only 
                        jp      nz,target
                        ENDM

JumpOnABit5Clear:       MACRO   target
                        and     Bit5Only 
                        jp      z,target
                        ENDM

JumpOnBitMaskSet:       MACRO   bitmask, target
                        and     bitmask
                        jp      nz,target
                        ENDM

JumpOnBitMaskClear:     MACRO   bitmask, target
                        and     bitmask
                        jp      z,target
                        ENDM
                        
JumpOnBitSet:           MACRO  reg, bitnbr, target
                        bit 	bitnbr,reg
                        jp      nz,target
                        ENDM

JumpOnBitClear:         MACRO  reg, bitnbr, target
                        bit 	bitnbr,reg
                        jp      z,target
                        ENDM

; Comparison Routines
JumpIfAGTEusng:         MACRO
                        jp		nc,target
                        ENDM

JumpIfAGTENusng:        MACRO reg,target
                        cp     reg
                        jp		nc,target
                        ENDM

JumpIfAGTEMemusng:      MACRO mem,target
                        ld      hl,mem
                        cp      (hl)
                        jp		nc,target
                        ENDM

JumpIfALTMemusng:       MACRO mem,target
                        ld      hl,mem
                        cp      (hl)
                        jp		c,target
                        ENDM

JumpIfMemGTENusng:      MACRO mem, value, target
                        ld     a,(mem)
                        cp     value
                        jp	  nc,target
                        ENDM

JumpIfMemGTEMemusng:    MACRO mem, address, target
                        ld   a,(mem)
                        ld   hl,address
                        cp   (hl)
                        jp	  nc,target
                        ENDM

JumpIfMemEqMemusng:     MACRO mem, address, target
                        ld   a,(mem)
                        ld   hl,address
                        cp   (hl)
                        jp	  z,target
                        ENDM

JumpIfMemNeMemusng:     MACRO mem, address, target
                        ld   a,(mem)
                        ld   hl,address
                        cp   (hl)
                        jp	  nz,target
                        ENDM
                        
JumpIfMemTrue:          MACRO mem, target
                        ld      a,(mem)
                        and     a
                        jp      z, target
                        ENDM
                        
JumpIfMemFalse:         MACRO mem, target
                        ld      a,(mem)
                        and     a
                        jp      nz, target
                        ENDM

JumpIfATrue:            MACRO target
                        and     a
                        jp      z, target
                        ENDM
                        
JumpIfAFalse:           MACRO target
                        and     a
                        jp      nz, target
                        ENDM

JumpIfALTusng:          MACRO target
                        jp		c,target
                        ENDM

JumpIfALTNusng:         MACRO value, target
                        cp      value
                        jp		c, target
                        ENDM

JumpIfMemLTNusng:       MACRO mem, value, target
                        ld      a,(mem)
                        cp      value
                        jp	  c,target
                        ENDM

JumpIfMemLTMemusng:     MACRO mem, value, target
                        ld    a,(mem)
                        ld    hl,value
                        cp    (hl)
                        jp	  c,target
                        ENDM

JumpIfMemEqNusng:       MACRO mem,value,target
                        ld  a,(mem)
                        cp  value
                        jp  z,target
                        ENDM

JumpIfMemNeNusng:       MACRO mem,value,target
                        ld  a,(mem)
                        cp  value
                        jp  nz,target
                        ENDM

JumpIfMemZero:          MACRO mem,target
                        ld  a,(mem)
                        and a
                        jp  z,target
                        ENDM

JumpIfMemNotZero:       MACRO mem,target
                        ld  a,(mem)
                        and a
                        jp  nz,target
                        ENDM
                        
JumpIfALTMemHLusng:     MACRO target
                        cp    (hl)
                        jp	  c,target
                        ENDM

JumpIfANENusng:         MACRO value, target
                        cp     value
                        jp      nz,target
                        ENDM

JumpIfANEMemusng:       MACRO  value, target
                        ld    hl,value
                        cp    (hl)
                        jp      nz,target
                        ENDM

JumpIfAEqNusng:         MACRO value, target
                        cp     value
                        jp      z,target
                        ENDM

JumpIfAIsZero:	        MACRO target
                        and a   ; cp 0 - changed to and a for optimisation but affects other flags
                        jp	z, target
                        ENDM

JumpIfAIsNotZero:       MACRO target
                        cp	0
                        jp	nz,target
                        ENDM

IfResultZeroGoto:	    MACRO target
                        jp	z,target
                        ENDM

IfResultNotZeroGoto:    MACRO target
                        jp	nz,target
                        ENDM
