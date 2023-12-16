asm_mlu1:
PAequDustYIdxYmulQ:
; "ASM MLU1 : TESTGOOD"
; "Y1 = dustY[Y]hi and P.A = Y1 7bit * Q A = low, P = hi"
	ld hl, varDustY 	;
	ld a, (regY)		;
	add hl,a			;
	add hl,a			;
	; inc hl STICK TO Lo for now
	ld a, (hl)			; a = dustY[a]
	ld (varY1),a		; Y1 = a
	and SignMask8Bit	; 
	ld d,a				; d = a
	ld a,(varQ)
	ld e,a   			; e = q
	mul					; de = a * q
	ld (varP),de		; P = d
	ld a,e				; a = e
	ret
