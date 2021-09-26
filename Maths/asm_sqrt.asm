; "ASM SQRT : TESTGOOD"
; "16-bit integer square root"
; "call with de = number to square root"
; "returns   hl = square root"
; "corrupts  bc, de"
asm_sqrt:
	ld bc,$8000
	ld h,c
	ld l,c
.sqrloop:
	srl b
	rr c
	add hl,bc
	ex de,hl
	sbc hl,de
	jr c,.sqrbit
	ex de,hl
	add hl,bc
	jr .sqrfi
.sqrbit:
	add hl,de
	ex de,hl
	or a
	sbc hl,bc
.sqrfi:
	srl h
	rr l
	srl b
	rr c
	jr nc,.sqrloop
	ret
	
	
sqrtQR:					; Q = SQR(Qlo.Rhi) Q <~127
	ld		a,(varQ)
	ld		e,a
	ld		a,(varR)
	ld		d,a
	call	asm_sqrt
    ld      a,l
	ld		(varQ),a
	ret
