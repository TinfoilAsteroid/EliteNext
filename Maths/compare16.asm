compare16HLDE:
; Input:
;       HL = 1st value
;       DE = 2nd value
; Output:
;       CF, ZF = results of comparison:
;
;               CF      ZF      Result
;               -----------------------------------
;               0       0       HL > DE
;               0       1       HL == DE
;               1       0       HL < DE
;               1       1       Impossible
;
		push    hl
		and     a
		sbc     hl,de
		pop     hl
		ret
