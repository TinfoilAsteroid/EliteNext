; "ASM_FMUTKL .FMLTU	\ -> &2847  \ A=A*Q/256unsg  Fast multiply"
fmltu:
AequAmulQdiv256:        ld	d,a
                        ld	a,(varQ)
                        ld	e,a
                        mul
                        ld	a,d				; we get only the high byte which is like doing a /256 if we think of a as low
                        ret
	
AequAmulDdiv256:        ld  e,a
                        mul
                        ld  a,d
                        ret
