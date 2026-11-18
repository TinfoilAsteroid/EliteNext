;;JUNK WORK? .madXAequQmulAaddRS:					;	Multiply and Add   X.A = Q*A + R.S
;;JUNK WORK? 			ex		af,af'
;;JUNK WORK? 			ld		a,(regX)
;;JUNK WORK? 			ld		b,a
;;JUNK WORK? 			ld		a,(varQ)
;;JUNK WORK? 			ld		d,a
;;JUNK WORK? 			ld		a,(varR)
;;JUNK WORK? 			ld		l,a
;;JUNK WORK? 			ld		a,(varS)
;;JUNK WORK? 			ld		h,a					
;;JUNK WORK? 			ex		af,af'				; Now b = regX, d = varQ, l = varR, h = varS, a restored to a register
;;JUNK WORK? .madBAequQmulAaddRS:					; Multiply and Add   B.A = D*A + L(r)S(h)
;;JUNK WORK? 			ld		e,a					; e ==  T1	 \ store hi
;;JUNK WORK? 			and		$80
;;JUNK WORK? 			ld		c,a					; c == T (sign bit of a)
;;JUNK WORK? 			xor		l					; L == S	(s = sign so xor will handle sign bit)
;;JUNK WORK? 			jp		m,.MU8				;  different signs
;;JUNK WORK? 			ld		a,l
;;JUNK WORK? 			add		

;TODP MEED A REG ONLY version
;Tuned for 16 bit add					
madfast:								; .MAD	\ -> &22AD  \ Multiply and Add  (DE also) X.A(Lo.Hi) = Q*A + R.S (Lo.Hi)
madXAequQmulAaddRS:
			call	APequQmulA			; MULT1 \ AP=Q * A, protects Y. (DE) A(hi).P(lo) = Q * A
			ex		de,hl				; De = 16 bit result of mult1 also so put into HL
XAequPAaddRSfast:
addfast:	ld		ixl,a				; IXL == T1			
			and		$80					; extract sign
			ld		b,a					; B == T
			ld		a,(varS)			
			ld		c,a					; C == S
			ld		a,b					; recover A
			xor		c					; a xor c (varS)
			jp		m,.MU8				; 
			ld		a,(varR)			; R	 \ lo
			ld		e,a					; E = R (lo)
			ld		a,(varS)
			ld		d,a					; D = S (hi)
			add		hl,de				; as we have rsult on mult1 in HL we jsut add RS (i.e. DE)
			ld		a,l
			ld		(regX),a			; store lo in X
			ld		a,h					; a = hi
			or		b					; restore sign bit
			ld		h,a
			ex		de,hl				; also drop result in DE as it may be helpful later
			ret
.MU8:		ld		a,(varS)			; S hi
			and		$7F					; hi S7
			ld		d,a					; d == U sign stripped S
			ld		a,(varP)			;
			ld		e,a					; e == lo
			or		a					; clear carry flag
			sbc		hl,de				; hl = result from asm_mult1 with no sign, de = RS with no sign
			bit		7,h					; is bit 7 set, i.e. negative?
			jr		nz,.MU9				; .MU9 DE was greater than H so there was no bit 7 on h
			call	negate16			; hl = negative 2's complimment to get back to +ve number
			ld		a,h
			or		$80
			ld		h,a					; set bit that the result was negative
			or		$80					;  set sign
.MU9:									;  sign ok
			ld		a,h					; get the high byte
			xor		b					;  B ==T (saved sign)
			ld		h,a					; hl = result too
			ld		a,l
			ld		(regX),a			; regX = low
			ld		a,h					; a = hi with sign bit
			ex		de,hl				; de = result rather than HL May bin this later
			ret




Raw version first then optimise for registers
mad:									;.MAD	\ -> &22AD  \ Multiply and Add   X.A = Q*A + R.S
			call	APequQmulA  		; MULT1 \ AP=Q * A, protects Y.
rawadd:									; .ADD	\ X.A = P.A + R.S
			ld		(varT1),a			; T1	 \ store 
			and		$80					; extract sign
			ld		(varT),a			; T
			ld		hl,	varS
			xor		(hl)				; S	
			jp		m,.MU8				; 
			ld		a,(varR)			;  R	 \ lo
			ld		hl,(varP)			; add lo P
			add		a,(hl)
			ld		(regX),a			; Xreg=lo
			ld		a,(varS)			; S	 \ hi
			ld		hl,varT1			; T1	 \ stored hi
			add		a,(hl)				
			ld		hl,(varT)
			or		(hl)				; ; T sign
			ret							
.MU8:		ld		a,(varS)			; S hi
			and		$7F					; hi S7
			ld		(varU),a			; U
			ld		a,(varP)			;  lo
			ld		hl,varR
			scf
			sbc		a,(hl)				; sub R +1
			ld		(regX),a			; Xreg=lo
			ld		a,(varT1)			;  restore hi
			and		$7F				    ;  hi T17
			ld		hl,varU
			sbc		a,(hl)				;  hi S7
			jr		c,.MU9				;  sign ok
			ld		(varU),a 			;  U
			ld		a,(regX)			;  lo
			neg							;  flip a (eor F add 1)
			ld		(regX),a			; negated lo
			xor		a					; negate hi
			ld		hl,varU
			sub		(hl)				; U
			or		$80					;  set sign
.MU9:									;  sign ok
			ld		hl,varT
			xor		(hl)				;  T
			ret

