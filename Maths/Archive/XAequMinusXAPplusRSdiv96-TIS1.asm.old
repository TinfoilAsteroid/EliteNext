XAequMinusXAplusRSdiv96:					;.TIS1	\ -> &293B  \ Tidy subroutine 1  X.A =  (-X*A  + (R.S))/96
TIS1:
		ex		af,af'
		ld		a,(regX)
		ld		b,a
		ex		af,af'
BAequMinusBAplusRSdiv96:					;.TIS1	\ -> &293B  \ Tidy subroutine 1 using B register = X
		ex		af,af'
		ld		a,b
		ld		(varQ),a
		ex		af,af'
		xor		$80							;	 flip sign of Acc
		call	madXAequQmulAaddRS			; \ MAD \ multiply and add (X,A) =  -X*A  + (R,S)
; USES 				A BC E
; DOES NOT USE		D HL
Div96:										; .DVID96	\ Their comment A=A/96: answer is A*255/96
		ld		b,a
		and		$80							;	hi sign
		ld		e,a							;   e = varT
		ld		a,b
		and		$7F							;	hi A7
		ld		b,$FE						;   slide counter
		ld		c,b							;   c == T1 ::  T1
.DVL3:										;   roll T1  clamp Acc to #96 for rotation matrix unity
		sla		a
		cp		$60							; max 96
		jr		nc,.DV4
		sbc		a,$60							;  SBC #&60
.DV4:										; skip subtraction
		rl		c							;  T1
		jr		c,.DVL3
		ld		a,c							;   T1
		or		e							;   restore T sign
		ret		
