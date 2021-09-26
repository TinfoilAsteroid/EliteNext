APequQmulA:
asm_mult1:
; "ASM_MULT1 (DE) A(hi).P(lo) = Q * A first part of MAD, multiply and add. Visited Quite often. A=hi P = lo also returns result in DE"
	cp	0
	jr	z,.mul0			; quick exit if its Q * 0
	ld	e,a
	ld	a,(varQ)
	ld	d,a
	cp	0				; compare a
	jr	z,.mul0			; quick exit if its 0 * a
	xor	e				; -- = + +- = - -+ = - ++ = +
	and $80				; get the resultant sign and save into b
	ld	b,a
	ld	a,d
	and	SignMask8Bit	; now strip off sign bits
	ld	d,a
	ld	a,e
	and SignMask8Bit
	ld	e,a
	mul					; zxn de = d * e
	ld	a,e				
	ld	(varP),a		; p = lo
	ld	a,d				; a = hi
	or	b				; de goes to a and varP also re-do sign bit
	ld	d,a				; we will work with de having result as we may bin vars later
	ret
.mul0:	
	xor	a
	ld	(varP),a
	ld	d,a
	ld  e,a
	ret
	