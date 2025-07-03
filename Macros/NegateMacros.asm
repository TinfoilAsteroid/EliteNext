
macronegate16hl:	MACRO
					xor 	a
					sub 	l
					ld 		l,a
					sbc 	a,a
					sub 	h
					ld 		h,a
					ENDM


macroAbsHL:         MACRO
                    bit     7,h
                    jp      z,.alreadyABS
					xor 	a
					sub 	l
					ld 		l,a
					sbc 	a,a
					sub 	h
					ld 		h,a
.alreadyABS:        
                    ENDM                                        

macronegate16de:	MACRO
					xor 	a
                    sub 	e
                    ld 		e,a
                    sbc 	a,a
                    sub 	d
                    ld 		d,a
					ENDM		
                    
macronegate16bc:	MACRO
					xor 	a
                    sub 	c
                    ld 		c,a
                    sbc 	a,a
                    sub 	b
                    ld 		b,a
					ENDM		

macronegate16ix:	MACRO
					xor 	a
                    sub 	ixl
                    ld 		ixl,a
                    sbc 	a,a
                    sub 	ixh
                    ld 		ixh,a
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
                    xor     a
                    sub     l
                    ld      l,a
                    sbc     a,a
                    sub     h
                    ld      h,a
                    ENDM

NegBHL:             MACRO
                    ld      a,l
                    cpl
                    add     a,1
                    ld      l,a
                    ld      a,h
                    cpl
                    adc     a,0
                    ld      h,a
                    ld      a,b
                    cpl
                    adc     a,0
                    ld      b,a
                    ENDM

NegCDE:             MACRO
                    ld      a,e
                    cpl
                    add     a,1
                    ld      e,a
                    ld      a,d
                    cpl
                    adc     a,0
                    ld      d,a
                    ld      a,c
                    cpl
                    adc     a,0
                    ld      c,a
                    ENDM
                    
NegAHL:			    MACRO
                    ld      b,a
                    ld      a,l
                    cpl
                    add     a,1
                    ld      l,a
                    ld      a,h
                    cpl
                    adc     a,0
                    ld      h,a
                    ld      a,b
                    cpl
                    adc     a,0
                    ENDM


NegDE:			    MACRO
                    xor     a
                    sub     e
                    ld      e,a
                    sbc     a,a
                    sub     d
                    ld      d,a
                    ENDM

NegBC:			    MACRO
                    xor     a
                    sub     c
                    ld      c,a
                    sbc     a,a
                    sub     b
                    ld      b,a
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
                    