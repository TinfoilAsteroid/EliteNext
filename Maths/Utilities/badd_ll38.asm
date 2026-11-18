baddll38:				;.LL38	\ -> &4812 \ BADD(S)A=R+Q(SA) \ byte add (subtract)   (Sign S)A = R + Q*(Sign from A^S) 
SAEquSRPlusAQ:
; Calculate the following between sign-magnitude numbers:
;   (S A) = (S R) + (A Q)
; where the sign bytes only contain the sign bits, not magnitudes.
; note goes wrong at <-127 >128 so need 16 bit version
; so need to fix the issue with carry flag not returning a fault correctly
LL38:
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

;;;;; Calculate the following between sign-magnitude numbers:
;;;;;   (S A) = (S R) + (A Q)
;;;;; where the sign bytes only contain the sign bits, not magnitudes.
;;;;; note goes wrong at <-127 >128 so need 16 bit version
;;;;; Calculate sign for Q from A and varS
;;;;	ex		af,af'							; save A temporarily
;;;;	ex		af,af'                          ; get back a which is the result
;;;;.GoodToReturn	
	
