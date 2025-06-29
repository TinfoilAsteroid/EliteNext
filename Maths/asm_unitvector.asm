asm_tis2: 
; ">TIS2 A = (A / Q * 96) so A = -96 ---- 96  range "
; ">DOES NOT DO SIGNED YET"
	push af
    and SignMask8Bit
	ld d,a				;; d = A
	ld a,(varQ)
	ld e,a
	ld a,d
	cp e
	jr nc, .tis2_set96	;; jump if a >= Q
	ld e, 96
	mul				; de = d * 96 (also a * 96 )
	ex de,hl		
	ld a,(varQ)
	ld c,a
    MMUSelectMathsBankedFns
	call div_hl_div_c; asm_div16
	pop af
	and $80
	or l
	ret
.tis2_set96:
	pop af
	and $80
	or $96
	ret
	
	
asm_unit_vector:
squareregfx:
	ld a,(UBnkXScaled)
	ld d,a
	ld e,a
	mul
	ex de,hl
squareregfy:
	ld a, (UBnkYScaled)
	ld d,a
	ld e,a
	mul
	add hl,de
squareregfz:
	ld a, (UBnkZScaled)
	ld d,a
	ld e,a
	mul
	add hl,de
	ex de,hl			; de de to number to root
hlequsquareroot:
	call asm_sqrt		; hl = sqrt (fx^2 + fy^2 + fx^2)
	push hl				; save it for work 3 copies
	push hl				; save it for work
	push hl				; save it for work
normfx:
	ld a,(UBnkXScaled)	
	pop hl				; get copy #1
	ld a,l				; we assume only l had worthwhile data but could spill into h
	ld c,a
	call asm_tis2
	ld (UBnkXScaled),a
normfy:
	ld a,(UBnkYScaled)	
	pop hl				; get copy #2
	ld a,l
	ld c,a
	call asm_tis2
	ld (UBnkYScaled),a
normfz:
	ld a,(UBnkZScaled)	
	pop hl				; get copy #2
	ld a,l
	ld c,a
	call asm_tis2
	ld (UBnkZScaled),a
asm_unit_vector_end:	
	ret
	