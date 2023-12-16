; a equal a / d * 96
; Tested and works with signed numbers
NormaliseIXVector:      ld		a,(ix+1)			; Vector X high
                        and		SignMask8Bit        ; a = abs X high
                        ld      d,a                 ; hl = abs X ^ 2
                        ld      e,a                 ; .
                        mul     de                  ; .
                        ex      de,hl               ; .
                        ld		a,(ix+3)			; vector = Y high
                        and		SignMask8Bit        ; unsigned
                        ld      d,a                 ; de = abs Y ^ 2
                        ld      e,a                 ; .
                        mul     de                  ; .
                        add     hl,de               ; hl = x^2 + y ^2
                        ld		a,(ix+5)			; vector = Z high
                        and		SignMask8Bit        ; unsigned
                        ld      d,a                 ; de = abs Z ^ 2
                        ld      e,a                 ; .
                        mul     de                  ; .
                        add     hl,de               ; de = x^2 + y ^2 + z ^ 2
                        ex      de,hl               ; .
.n96SQRT:               call	asm_sqrt			; hl = sqrt de
.n96NORMX:              ld		a,(ix+1)            
                        ld		d,l					; Q(i.e. l) => D, later we can just pop into de
                        call	AequAdivDmul96Q8    ; does not use HL so we can retain it
                        ld		b,a				    ; Sort out restoring sign bit
                        ld      c,0                 ; .
                        ld		(ix+0),bc           ; .
.n96NORMY:              ld		a,(ix+3)            
                        ld		d,l					; Q(i.e. l) => D, later we can just pop into de
                        call	AequAdivDmul96Q8	; does not use HL so we can retain it
                        ld		b,a				    ; Sort out restoring sign bit
                        ld      c,0                 ; .
                        ld		(ix+2),bc           ; .
.n96NORMZ:              ld		a,(ix+5)            
                        ld		d,l					; Q(i.e. l) => D, later we can just pop into de
                        call	AequAdivDmul96Q8 	; does not use HL so we can retain it
                        ld		b,a				    ; Sort out restoring sign bit
                        ld      c,0                 ; .
                        ld		(ix+4),bc           ; .
                        ret                      

; .NORM	\ -> &3BD6 \ Normalize 3-vector length of XX15
normaliseXX1596S7:      ld		a,(XX15VecX)	    ; XX15+0
                        ld		ixh,a               ; ixh = signed x component
                        and		SignMask8Bit        ; a = unsigned version
.n96SQX:	            inline_squde				; Use inline square for speed	objective is SQUA \ P.A =A7*A7 x^2
                        ld		h,d					; h == varR d = varO e= varA
                        ld		l,e					; l == varQ  															:: so HL = XX15[x]^2
.n96SQY:                ld		a,(XX15VecY)			
                        ld		ixl,a               ; ixl = signed y componet
                        and		SignMask8Bit                 ; = abs 
                        inline_squde				; Use inline square for speed	objective is SQUA \ P.A =A7*A7 x^2		:: so DE = XX15[y]^2
                        add		hl,de				; hl = XX15[x]^2 + XX15[y]^2
.n96SQZ:                ld		a,(XX15VecZ)			; Note comments say \ ZZ15+2  should be \ XX15+2 as per code
                        ld		iyh,a               ; iyh = signed
                        and		SignMask8Bit                 ; unsigned
                        inline_squde				; Use inline square for speed	objective is SQUA \ P.A =A7*A7 x^2		:: so DE = XX15[z]^2
.n96SQADD:              add		hl,de				; hl = XX15[x]^2 + XX15[y]^2 + XX15[z]^2
                        ex		de,hl				; hl => de ready for square root
.n96SQRT:               call	asm_sqrt			; hl = de = sqrt(XX15[x]^2 + XX15[y]^2 + XX15[z]^2), we just are interested in l which is the new Q
.n96NORMX:              ld		a,(XX15VecX)
                        and		SignMask8Bit
                        ld		c,a
                        ld		d,l					; Q(i.e. l) => D, later we can just pop into de
                        call	AequAdivDmul967Bit	; does not use HL so we can retain it
                        ld		b,a				    ;++SGN
                        ld		a,ixh			    ;++SGN
                        and		$80				    ;++SGN
                        or		b				    ;++SGN
                        ld		(XX15VecX),a
.n96NORMY:              ld		a,(XX15VecY)
                        and		SignMask8Bit
                        ld		c,a
                        ld		d,l					; Q(i.e. l) => D, later we can just pop into de
                        call	AequAdivDmul967Bit     	; does not use HL so we can retain it
                        ld		b,a				    ;++SGN
                        ld		a,ixl			    ;++SGN
                        and		$80				    ;++SGN
                        or		b				    ;++SGN
                        ld		(XX15VecY),a
.n96NORMZ:              ld		a,(XX15VecZ)
                        and		SignMask8Bit
                        ld		c,a
                        ld		d,l				; Q(i.e. l) => D, later we can just pop into de
                        call	AequAdivDmul967Bit;AequAdivDmul96	; does not use HL so we can retain it
                        ld		b,a				    ;++SGN
                        ld		a,iyh			    ;++SGN
                        and		$80				    ;++SGN
                        or		b				    ;++SGN
                        ld		(XX15VecZ),a
                        ret

; Normalise vector
; scale Q = Sqrt (X^2 + Y^2 + Z^2)
; X = X / Q with 96 = 1 , i.e X = X / Q * 3/8
; Y = Y / Q with 96 = 1 , i.e Y = Y / Q * 3/8
; Z = Z / Q with 96 = 1 , i.e Z = Z / Q * 3/8
