RSequABSrs:
LL129:										; RS = abs(RS) and return Acc = hsb x1 EOR hi, Q = (1/)gradient
		ldCopyByte UbnkGradient,varQ		; XX12+2	\ gradient to Q
		ld		a,(varS)					;  S	\ hi
		JumpOnBitClear a,7,LL127Positive	; hop to eor if S (Sign) is positive
.LL129Negative:
		ld		d,a							; save a copy of varS
		ld		hl,(varR)
		NegHL
		ld		(varR),hl
		ld		a,d							; restore a copy of varS
LL127Positive:
LL127:
		ld		hl,UBnkDeltaXHi				; XX12+3	\ Acc ^= quadrant info
		xor		(hl)						; a = original varS Xor Delta X Hi
		ret									; CLIP, bounding box is now done,
