AequAdivDmul96Unsg:     ld			ixl,b						; Get sign bit passed in as bit 7 in b
                        JumpIfAGTENusng d, TISXAccGTEQ			; if A >= Q then return with a 1 (unity i.e. 96) with the correct sign
                        ld			c,a
                        call		asm_div8
                        ld			a,c							; a = result
                        srl			a							; result / 4
                        ld			b,a							; t = t /4
                        srl			a							; result / 8
                        add			a,b							; result /8 + result /4
                        ld			b,a							; b = 3/8*Acc (max = 96)
                        ld			a,ixl						; copy of Acc to look at sign bit
                        and			$80							; recover sign only
                        or			b							; now put b back in so we have a leading sign bit (note not 2's compliment)
                        ret
TISXAccGTEQ:
;TI4:										;\ clean to +/- unity
                        ld			a,ixl     					; get saved sign from b
                        and			$80							; copy of Acc
                        or			$60							; unity
                        ret
	
	


normaliseXX1596fast:
    ; .NORM	\ -> &3BD6 \ Normalize 3-vector length of XX15
	ld		a,(XX15)		    ; XX15+0
	ld		ixh,a               ; ixh = signed x component
	and		SignMask8Bit                 ; a = unsigned version
N96SQX:	
	inline_squde				; Use inline square for speed	objective is SQUA \ P.A =A7*A7 x^2
	ld		h,d					; h == varR d = varO e= varA
	ld		l,e					; l == varQ  															:: so HL = XX15[x]^2
N96SQY:
	ld		a,(XX15+1)			
	ld		ixl,a               ; ixl = signed y componet
	and		SignMask8Bit                 ; = abs 
	inline_squde				; Use inline square for speed	objective is SQUA \ P.A =A7*A7 x^2		:: so DE = XX15[y]^2
	add		hl,de				; hl = XX15[x]^2 + XX15[y]^2
N96SQZ:
	ld		a,(XX15+2)			; Note comments say \ ZZ15+2  should be \ XX15+2 as per code
	ld		iyh,a               ; iyh = signed
	and		SignMask8Bit                 ; unsigned
	inline_squde				; Use inline square for speed	objective is SQUA \ P.A =A7*A7 x^2		:: so DE = XX15[z]^2
N96SQADD:
	add		hl,de				; hl = XX15[x]^2 + XX15[y]^2 + XX15[z]^2
	ex		de,hl				; hl => de ready for square root
N96SQRT:
	call	asm_sqrt			; hl = sqrt(XX15[x]^2 + XX15[y]^2 + XX15[z]^2), we just are interested in l which is the new Q
N96NORMX:
	ld		a,(XX15+0)
	and		SignMask8Bit
	ld		c,a
	ld		d,l					; Q(i.e. l) => D, later we can just pop into de
	call	AequAdivDmul96	; does not use HL so we can retain it
	ld		b,a				;++SGN
	ld		a,ixh			;++SGN
	and		$80				;++SGN
	or		b				;++SGN
	ld		(XX15+0),a
N96NORMY:
	ld		a,(XX15+1)
	and		SignMask8Bit
	ld		c,a
	ld		d,l					; Q(i.e. l) => D, later we can just pop into de
	call	AequAdivDmul96     	; does not use HL so we can retain it
	ld		b,a				;++SGN
	ld		a,ixl			;++SGN
	and		$80				;++SGN
	or		b				;++SGN
	ld		(XX15+1),a
N96NORMZ:
	ld		a,(XX15+2)
	and		SignMask8Bit
	ld		c,a
	ld		d,l					; Q(i.e. l) => D, later we can just pop into de
	call	AequAdivDmul96	; does not use HL so we can retain it
	ld		b,a				;++SGN
	ld		a,iyh			;++SGN
	and		$80				;++SGN
	or		b				;++SGN
	ld		(XX15+2),a
	ret

normaliseSunScaled96:   ld		a,(SunXScaled)		    ; XX15+0
                        ld		ixh,a                   ; ixh = signed x component
                        and		SignMask8Bit            ; a = unsigned version
N96SQX:	
	inline_squde				; Use inline square for speed	objective is SQUA \ P.A =A7*A7 x^2
	ld		h,d					; h == varR d = varO e= varA
	ld		l,e					; l == varQ  															:: so HL = XX15[x]^2
N96SQY:
	ld		a,(XX15+1)			
	ld		ixl,a               ; ixl = signed y componet
	and		SignMask8Bit                 ; = abs 
	inline_squde				; Use inline square for speed	objective is SQUA \ P.A =A7*A7 x^2		:: so DE = XX15[y]^2
	add		hl,de				; hl = XX15[x]^2 + XX15[y]^2
N96SQZ:
	ld		a,(XX15+2)			; Note comments say \ ZZ15+2  should be \ XX15+2 as per code
	ld		iyh,a               ; iyh = signed
	and		SignMask8Bit                 ; unsigned
	inline_squde				; Use inline square for speed	objective is SQUA \ P.A =A7*A7 x^2		:: so DE = XX15[z]^2
N96SQADD:
	add		hl,de				; hl = XX15[x]^2 + XX15[y]^2 + XX15[z]^2
	ex		de,hl				; hl => de ready for square root
N96SQRT:
	call	asm_sqrt			; hl = sqrt(XX15[x]^2 + XX15[y]^2 + XX15[z]^2), we just are interested in l which is the new Q
N96NORMX:
	ld		a,(XX15+0)
	and		SignMask8Bit
	ld		c,a
	ld		d,l					; Q(i.e. l) => D, later we can just pop into de
	call	AequAdivDmul96	; does not use HL so we can retain it
	ld		b,a				;++SGN
	ld		a,ixh			;++SGN
	and		$80				;++SGN
	or		b				;++SGN
	ld		(XX15+0),a
N96NORMY:
	ld		a,(XX15+1)
	and		SignMask8Bit
	ld		c,a
	ld		d,l					; Q(i.e. l) => D, later we can just pop into de
	call	AequAdivDmul96     	; does not use HL so we can retain it
	ld		b,a				;++SGN
	ld		a,ixl			;++SGN
	and		$80				;++SGN
	or		b				;++SGN
	ld		(XX15+1),a
N96NORMZ:
	ld		a,(XX15+2)
	and		SignMask8Bit
	ld		c,a
	ld		d,l					; Q(i.e. l) => D, later we can just pop into de
	call	AequAdivDmul96	; does not use HL so we can retain it
	ld		b,a				;++SGN
	ld		a,iyh			;++SGN
	and		$80				;++SGN
	or		b				;++SGN
	ld		(XX15+2),a
	ret


; .NORM	\ -> &3BD6 \ Normalize 3-vector length of XX15
normaliseXX1596:        ld		a,(XX15)		    ; XX15+0
                        inline_squde				; Use inline square for speed	objective is SQUA \ P.A =A7*A7 x^2
                        ld		a,d					
                        ld		(varR),a			; R	 \ hi sum later use b
                        ld		a,e
                        ld		(varQ),a			; Q	 \ lo sum later use c
                        ld		(varP),a			; P	 \ lo sum later just drop
                        ld		a,(XX15+1)
                        inline_squde				; Use inline square for speed	objective is SQUA \ P.A =A7*A7 x^2
                        ld		a,d					
                        ld		(varT),a			; T	 \ hi sum
                        ld		a,e
                        ld		(varP),a			; P	 \ lo sum
                        ld		hl,varQ
                        adc		a,(hl)				; +Q
                        ld		(varQ),a			; =>Q
                        ld		a,(varT)			;
                        ld		hl,varR
                        adc		a,(hl)				;  R
                        ld		(varR),a			; R
                        ld		a,(XX15+2)			; Note comments say \ ZZ15+2  should be \ XX15+2 as per code
                        inline_squde				; Use inline square for speed	objective is SQUA \ P.A =A7*A7 x^2
                        ld		a,d					
                        ld		(varT),a			; T	 \ hi sum
                        ld		a,e
                        ld		(varP),a			; P	 \ lo sum
                        ld		hl,varQ
                        adc		a,(hl)				; +Q
                        ld		(varQ),a			; =>Q  xlo2 + ylo2 + zlo2
                        ld		a,(varT)			; T temp Hi
                        ld		hl,varR
                        adc		a,(hl)				; +R
                        ld		(varR),a			; R 
                        call	sqrtQR				; Q = SQR(Qlo.Rhi) Q <~127
                        ld		a,(XX15+0)
                        call	AequAdivQmul96		;  TIS2 \ *96/Q
                        ld		(XX15+0),a
                        ld		a,(XX15+1)
                        call	AequAdivQmul96		;  TIS2 \ *96/Q
                        ld		(XX15+1),a
                        ld		a,(XX15+1)
                        call	AequAdivQmul96		;  TIS2 \ *96/Q
                        ld		(XX15+1),a
                        ret


