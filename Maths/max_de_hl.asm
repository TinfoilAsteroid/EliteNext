;;----------------------------------------------------------------------------------------------------------------------
;; max
MaxDEHL:
; Input:
;       HL = 1st value
;       DE = 2nd value
; Output:
;       HL = maximum value
;       DE = minimum value
;       CF = 1 if DE was maximum
;
	and     a
	sbc     hl,de
	add     hl,de           ; Restore HL (does produce same CF as sbc before)
	ret     nc              ; HL >= DE, CF=0
	ex      de,hl           ; CF=1 -> HL < DE -> Choose DE!
	ret
