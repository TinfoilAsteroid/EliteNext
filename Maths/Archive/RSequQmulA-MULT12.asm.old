asm_mult12:
RSequQmulA:
; "asm_ult12  R.S = Q * A \ visited quite often S = hi, R = lo, odd that its opposite to mult1"
	call APequQmulA
	ex 	af,af'
	ld	a,d
	ld	(varS),a
	ld	a,e
	ld	(varR),a
	ex 	af,af'
	ret
