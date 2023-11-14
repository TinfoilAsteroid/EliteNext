TransposeXX12ByShipToXX15:
        ld		hl,(UBnkXX12xLo)					; get X into HL
		ld		a,h			                        ; get XX12 Sign						
		and		$80									; check sign bit on high byte
		ld		b,a									; and put it in of 12xlo in b
        ;110921 debugld      h,0
        ld      a,h
        and     $7F
        ld      h,a
        ;110921 debugld      h,0
		ld		de,(UBnkxlo)						;
		ld		a,(UBnkxsgn)						; get Ship Pos (low,high,sign)
		and		$80									; make sure we only have bit 7
		ld		c,a									; and put sign of unkxsgn c
		call 	ADDHLDESignBC; XX12ProcessCalcHLPlusDESignBC		; this will result in HL = result and A = sign
		or		h									; combine sign in A with H to give 15 bit signed (*NOT* 2's c)
		ld		h,a
		ld		(UBnkXScaled),hl					; now write it out to XX15 X pos
; ..................................
		ld		hl,(UBnkXX12yLo)					; Repeat above for Y coordinate
		ld		a,h
		and		$80
		ld		b,a
        ;110921 debugld      h,0
        ld      a,h
        and     $7F
        ld      h,a
        ;110921 debugld      h,0
		ld		de,(UBnkylo)
		ld		a,(UBnkysgn)
		and		$80									; make sure we only have bit 7
		ld		c,a
		call 	ADDHLDESignBC; XX12ProcessCalcHLPlusDESignBC
		or		h									; combine sign in A with H
		ld		h,a
		ld		(UBnkYScaled),hl
; ..................................
		ld		hl,(UBnkXX12zLo)					; and now repeat for Z cooord
		ld		a,h
		and		$80
		ld		b,a
        ;110921 debugld      h,0
        ld      a,h
        and     $7F
        ld      h,a
        ;110921 debugld      h,0
		ld		de,(UBnkzlo)
		ld		a,(UBnkzsgn)
		and		$80									; make sure we only have bit 7
		ld		c,a
		call 	ADDHLDESignBC; XX12ProcessCalcHLPlusDESignBC
		or		h									; combine sign in A with H
		ld		h,a
		bit		7,h                                 ; if sign if positive then we don't need to do the clamp so we ony jump 
		jr		nz,ClampZto4                        ; result was negative so we need to clamp to 4
        and     $7F                                 ; a = value unsigned
        jr      nz,NoClampZto4                      ; if high byte was 0 then we could need to clamp still by this stage its +v but and will set z flag if high byte is zero
        ld      a,l                                 ; get low byte now
		JumpIfALTNusng 4,ClampZto4					; if its < 4 then fix at 4
NoClampZto4:
		ld		(UBnkZScaled),hl					; hl = signed calculation and > 4
		ld		a,l									; in addition write out the z cooord to UT for now for backwards compat (DEBUG TODO remove later)
        ld      (varT),a
		ld		a,h
        ld      (varU),a
		ret
ClampZto4:											; This is where we limit 4 to a minimum of 4
		ld		hl,4
		ld		(UBnkZScaled),hl; BODGE FOR NOW
		ld		a,l
        ld      (varT),a                            ;                                                                           ;;;
		ld		a,h
        ld      (varU),a 						; compatibility for now
		ret
