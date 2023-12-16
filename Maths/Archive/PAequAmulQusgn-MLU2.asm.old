asm_mlu2:
PAequAmulQusgn:
; "ASM MLU2 : TESTGOOD"
; "P.A = a7bit  * q"
	and SignMask8Bit	; 
	ld d,a				; d = a
    ld a,(varQ)
	ld e,a   			; e = q
	mul					; de = a * q
	ld (varP),de		; P = d
	ld a,e				; a = e
	ret	
