; "ASM_SQUA : TESTGOOD"
; "AP = A^2 A = low,P = hi"

inline_squde: MACRO
			ld	e,a
			ld  d,a
			mul
			ENDM

inline_squa: MACRO
			ld	e,a
			ld  d,a
			mul
			ld	a,e
			ENDM


asm_squa:
	and SignMask8Bit
; "ASM SQUA2 : TESTGOOD"
; "AP = A^2 A = low,P = hi singed"
asm_squa2:
	ld e, a
	ld d,a
	mul
	ld (varP),de
	ld a,e
	ret