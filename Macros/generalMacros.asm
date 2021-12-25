JumpIfPositive:	        MACRO target
                        jp		p, target
                        ENDM

JumpIfNegative:	        MACRO target
                        jp		m, target
                        ENDM


JumpIfUnderflow:	    MACRO target
                        jp		po, target
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


JumpOnBitSet:           MACRO  reg, bitnbr, target
                        bit 	bitnbr,reg
                        jp      nz,target
                        ENDM

JumpOnBitClear:         MACRO  reg, bitnbr, target
                        bit 	bitnbr,reg
                        jp      z,target
                        ENDM

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

CallIfAGTENusng:        MACRO   reg,target
                        cp      reg
                        call	nc,target
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

CallIfMemEqMemusng:     MACRO mem, address, target
                        ld   a,(mem)
                        ld   hl,address
                        cp   (hl)
                        call    z,target
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
                        jr  z,target
                        ENDM

JumpIfMemNeNusng:       MACRO mem,value,target
                        ld  a,(mem)
                        cp  value
                        jr  nz,target
                        ENDM

JumpIfMemZero:          MACRO mem,target
                        ld  a,(mem)
                        and a
                        jr  z,target
                        ENDM

JumpIfALTMemHLusng:     MACRO target
                        cp    (hl)
                        jp	  c,target
                        ENDM

JumpIfANENusng: MACRO value, target
                cp     value
                jp      nz,target
                ENDM

JumpIfANEMemusng: MACRO  value, target
                  ld    hl,value
                  cp    (hl)
                  jp      nz,target
                  ENDM

JumpIfAEqNusng: MACRO value, target
                cp     value
                jp      z,target
                ENDM

IfAIsZeroGoto:	MACRO target
				and a   ; cp 0 - changed to and a for optimisation but affects other flags
				jp	z, target
				ENDM

IfANotZeroGoto:	MACRO target
				cp	0
				jp	nz,target
				ENDM

IfResultZeroGoto:	MACRO target
					jp	z,target
					ENDM

IfResultNotZeroGoto:MACRO target
					jp	nz,target
					ENDM

ReturnIfAIsZero:    MACRO
                    and a
                    ret    z
                    ENDM

ReturnIfMemisZero:  MACRO mem
                    ld   a,(mem)
                    and a
                    ret    z
                    ENDM

ReturnIfMemEquN:    MACRO mem, value
                    ld   a,(mem)
                    cp     value
                    ret    z
                    ENDM

ReturnIfANotZero:   MACRO
                    cp     0
                    ret    nz
                    ENDM

ReturnIfMemNotZero: MACRO mem
                    ld     a,(mem)
                    cp     0
                    ret    nz
                    ENDM

ReturnIfAGTEusng:   MACRO value
                    cp    value
                    ret	 nc
                    ENDM

ReturnIfALTNusng:   MACRO value
                    cp    value
                    ret	 c
                    ENDM

ReturnIfAGTENusng:  MACRO value
                    cp    value
                    ret	 nc
                    ENDM

ReturnIfANENusng:   MACRO value
                    cp      value
                    ret     nz
                    ENDM

ReturnIfAEqNusng:   MACRO value
                    cp      value
                    ret     z
                    ENDM

SetCarryFlag:       MACRO
                    scf
                    ENDM

ClearCarryFlag:	    MACRO
                    or a
                    ENDM

FlipCarryFalg:      MACRO
                    ccf
                    ENDM

pushbcde:		    MACRO
                    push	bc
                    push	de
                    ENDM

popdebc:		    MACRO
                    pop		de
                    pop		bc
                    ENDM

pushhlde:		    MACRO
                    push	hl
                    push	de
                    ENDM

popdehl:		    MACRO
                    pop		de
                    pop		hl
                    ENDM

pushbcdeaf:		    MACRO
                    push	bc
                    push	de
                    push	af
                    ENDM

popafdebc:		    MACRO
                    pop		af
                    pop		de
                    pop		bc
                    ENDM

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

FourLDIInstrunctions:   MACRO
                        ldi
                        ldi
                        ldi
                        ldi
                        ENDM

FiveLDIInstrunctions:   MACRO
                        ldi
                        ldi
                        ldi
                        ldi
                        ldi
                        ENDM

SixLDIInstrunctions:    MACRO
                        ldi
                        ldi
                        ldi
                        ldi
                        ldi
                        ldi
                        ENDM

EightLDIInstrunctions:  MACRO
		                ldi
		                ldi
		                ldi
		                ldi
		                ldi
		                ldi
		                ldi
		                ldi
                        ENDM

NineLDIInstrunctions:  MACRO
		                ldi
		                ldi
		                ldi
		                ldi
		                ldi
		                ldi
		                ldi
		                ldi
		                ldi
                        ENDM

FlipMemSign:        MACRO mem
                    ld  a,(mem)
                    xor SignOnly8Bit
                    ld  (mem),a
                    ENDM
