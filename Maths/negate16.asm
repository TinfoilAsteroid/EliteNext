;;----------------------------------------------------------------------------------------------------------------------
;; 16-bit negate
        ; Input:
        ;       HL = value
        ; Output:
        ;       HL = -value
        ; Destroys:
        ;       AF
        ;
negate16:
negate16hl:         xor 	a
                    sub 	l
                    ld 		l,a
                    sbc 	a,a
                    sub 	h
                    ld 		h,a
                    ret

negate16de:         xor 	a
                    sub 	e
                    ld 		e,a
                    sbc 	a,a
                    sub 	d
                    ld 		d,a
                    ret

negate16bc:         xor 	a
                    sub 	c
                    ld 		c,a
                    sbc 	a,a
                    sub 	b
                    ld 		b,a
                    ret

