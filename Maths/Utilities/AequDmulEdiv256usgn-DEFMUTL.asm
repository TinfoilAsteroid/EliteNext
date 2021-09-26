    
asm_defmutl:
AequDmulEdiv256usgn:
; "ASM_FMUTKL .FMLTU	\ -> &2847  \ A=D*E/256unsg  Fast multiply"
	mul
	ld	a,d				; we get only the high byte which is like doing a /256 if we think of a as low
	ret


