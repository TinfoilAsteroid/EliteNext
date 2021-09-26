testMaths:
; "Testing Maths"
test1:	
	ld hl, 50
	ld (varDustY),hl
	ld hl,5
	ld (varQ),hl
	ld a,0
	ld (varY),a
	call asm_mlu1
	ld a,0
	call writeResult
test2:
    ld a,100
	ld hl,varQ
	ld (hl),a
	ld a,3
	call asm_mlu2
	ld a,1
	call writeResult
test3:
	ld a,9
	call asm_squa
	ld a,2
	call writeResult ;; 8`
test4:
	ld de,$1EF1
	call asm_sqrt
	ex de,hl
	ld a,3
	call writeResult	;; 3
test5:
	ld hl, varQ
	ld (hl),43
	ld a, 43
	call asm_tis2
	ex de,hl
	ld a,4
	call writeResult ;; 96
test6:
	ld hl, varQ
	ld (hl),22
	ld a, 56
	call asm_tis2 ;; hl = result
	ex de,hl
	ld a,5
	call writeResult ;; 96
test7:
	ld hl, varQ
	ld (hl),56
	ld a, 22
startLoop:
	jp startLoop
	call asm_tis2
	ex de,hl
	ld a,6
	call writeResult;; 38
test8:
	ld hl, varQ
	ld (hl),22
	ld a, 11
	call asm_tis2
	ex de,hl
	ld a,7
	call writeResult	 ;; 48	