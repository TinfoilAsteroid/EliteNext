baddll38:				;.LL38	\ -> &4812 \ BADD(S)A=R+Q(SA) \ byte add (subtract)   (Sign S)A = R + Q*(Sign from A^S) 
SAEquSRPlusAQ:
; Calculate the following between sign-magnitude numbers:
;   (S A) = (S R) + (A Q)
; where the sign bytes only contain the sign bits, not magnitudes.
; note goes wrong at <-127 >128 so need 16 bit version
; so need to fix the issue with carry flag not returning a fault correctly
LL38:
;	ld		d,a
;	ld		a,(varQ)
;	ld		e,a
;	ld		a,(varS)
;	ld		h,a
;	ld		a,(varR)
;	ld		l,a
;	call	ADDHLDESignedv3
;	ld		a,h
;	ld		(varS),a
;	ld		a,l
;	ret
; calculation table
;   R     Q    Op            Sign calc
;	10    5    Add           +    sign same add R sign
;   -10   5    ABS Sub       -    sign diff ABS R > S sub R sign
;   10   -5    ABS sub       +    sign diff ABS R > S sub R sign
;	-10  -5    ABS Add       -    sign same add R sign
;   5    10    Add           +    sign same add R sign
;   -5   10    Swap ABS SUB  +    sign diff ABS Q > R swap SUB Q sign
;   5    -10   swap ABS Sub  -    sign diff ABS Q > R swap SUB R sign
;   -5   -10   ABS  add      -    sign same add R sign

;   -10   5    ABS Sub       -    sign diff ABS R > S sub R sign
;   10   -5    ABS sub       +    sign diff ABS R > S sub R sign
;   -5   10    Swap ABS SUB  +    sign diff ABS Q > R swap SUB Q sign
;   5    -10   swap ABS Sub  -    sign diff ABS Q > R swap SUB R sign


; Calculate sign for Q from A and varS
	ld		hl,varS							;
	xor		(hl)							;  EOR &83		\ S	\ sign of operator is A xor S
	jp		m,.LL39Subtraction  			; if signs are different then we have subtraction
	ld		a,(varQ)						; Q	\ else addition, S already correct
	ld		hl,varR
	add		a,(hl)							; a = Q + R
	ret										; Done carry set if overflow
.LL39Subtraction:							; 1 byte subtraction (S)A = R-Q
	ld		a,(varR)						; a = R
	ld		hl,varQ                         ; Q
;--	JumpIfALTMemHLusng LL39SwapSubtraction	; if a < (hl) then do LL39SwapSubtraction
	ClearCarryFlag                          ; we need to not use carry (6502 is different that it uses the compliement)
	sbc		a,(hl)							; A = R - Q which as R >= Q will always be a positive result
    jr      c,.LL39SignCorrection
;--    jr      a,.LL39ResultZero  
;--   JumpIfNegative LL39SignCorrection		; if there was underflow we have to correct sign
;--	or		a								; Clear carry flag to say result is correct
	ret
.LL39SignCorrection:
    cp      0                               ; if its 0 then neg will affect flag so we just zero result to save compute
    jr      z,.LL39ResultZero
    neg                                     ; flip A 2'c value to positive
	ex		af,af'							; save A temporarily
	ld		a,(varS)						; Flip Sign bit in varS
	xor		$80							    ;
	ld		(varS),a                        ; flip sign bit of a
	ex		af,af'                          ; get back a which is the result
    ClearCarryFlag                          ; clear carry as NEG instrunction sets it for non zero
	ret
.LL39ResultZero:
    ld      (varS),a                        ; a is zero at this stage so set sign as well
    ClearCarryFlag                          ; clear carry
    ret
;--LL39SwapSubtraction:
;--	push	bc
;--	ld		b,a
;--	ld		a,(hl)
;--	sub		b
;--	pop		bc
;--	ex		af,af'							; do we flip here or negate. i think its flip as its overflowed unsigned
;--	ld		a,(varS)
;--	xor		$80
;--	ld		(varS),a
;--	ex		af,af'
;--	ret

;;;;	baddll38:				;.LL38	\ -> &4812 \ BADD(S)A=R+Q(SA) \ byte add (subtract)   (Sign S)A = R + Q*(Sign from A^S) 
;;;;; Calculate the following between sign-magnitude numbers:
;;;;;   (S A) = (S R) + (A Q)
;;;;; where the sign bytes only contain the sign bits, not magnitudes.
;;;;; note goes wrong at <-127 >128 so need 16 bit version
;;;;LL38:
;;;;; Calculate sign for Q from A and varS
;;;;	ld		hl,varS							;
;;;;	xor		(hl)							;  EOR &83		\ S	\ sign of operator is A xor S
;;;;	jp		m,.LL39Subtraction  			; if signs are different then we have subtraction
;;;;	ld		a,(varQ)						; Q	\ else addition, S already correct
;;;;	ld		hl,varR
;;;;	add		a,(hl)							; a = Q + R
;;;;	ret										; Done
;;;;.LL39Subtraction:							; 1 byte subtraction (S)A = R-Q
;;;;	ld		hl,varQ                         ;
;;;;	ld		a,(hl)
;;;;	JumpIfAGTENusng 128,LL39Sub16bit		; does this need to be 16 bit
;;;;	ld		a,(varR)						; 
;;;;	ClearCarryFlag                          ; we need to not use carry (6502 is different that it uses the compliement)
;;;;	sbc		a,(hl)							; A = R - Q
;;;;	jr		c,.SignCorrection				; if there was underflow we have to correct sign
;;;;	or		a								; Clear carry flag to say result is correct
;;;;	ret
;;;;.SignCorrection:
;;;;    neg                                     ; flip A 2'c value to positive
;;;;	ex		af,af'							; save A temporarily
;;;;	ld		a,(varS)						; Flip Sign bit in varS
;;;;	xor		$80							    ;
;;;;	ld		(varS),a                        ; flip sign bit of a
;;;;	ex		af,af'                          ; get back a which is the result
;;;;	ret
;;;;LL39Sub16Bit:
;;;;	ld		e,a
;;;;	ld		d,0
;;;;	ld		a,(varR)
;;;;	ld		l,a
;;;;	ld		h,0
;;;;	ClearCarryFlag
;;;;	sbc		hl,de
;;;;	jr		c,.SignCorrection16bit
;;;;	bit		7,h
;;;;	jr		z,.GoodToReturn
;;;;.Needtonegate:
;;;;	macronegate16hl
;;;;.GoodToReturn	
;;;;	ld		a,l
;;;;	or		a
;;;;	ret
;;;;.SignCorrection16bit:
;;;;	macronegate16hl
;;;;	ld		a,(varS)						; Flip Sign bit in varS
;;;;	xor		$80							    ;
;;;;	ld		(varS),a                        ; flip sign bit of a
;;;;	ld		a,l
;;;;	ret
	
