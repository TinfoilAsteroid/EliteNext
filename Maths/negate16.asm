;;----------------------------------------------------------------------------------------------------------------------
;; 16-bit negate
negate16:
negate16hl:
        ; Input:
        ;       HL = value
        ; Output:
        ;       HL = -value
        ; Destroys:
        ;       AF
        ;
	xor 	a
	sub 	l
	ld 		l,a
	sbc 	a,a
	sub 	h
	ld 		h,a
	ret

negate16de:
	xor 	a
	sub 	e
	ld 		e,a
	sbc 	a,a
	sub 	d
	ld 		d,a
	ret

negate16bc:
	xor 	a
	sub 	c
	ld 		c,a
	sbc 	a,a
	sub 	b
	ld 		b,a
	ret


macronegate16hl:	MACRO
					xor 	a
					sub 	l
					ld 		l,a
					sbc 	a,a
					sub 	h
					ld 		h,a
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