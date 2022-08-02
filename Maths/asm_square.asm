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
