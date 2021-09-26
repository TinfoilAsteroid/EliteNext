AP2equAPmulXunsgEorP:
MLTU22:						; MLTU22 \ AP(2)= AP* Xunsg(EOR P)
	ld		a,(regX)
	ld		(varQ),a		; Q = regX
AP2equAPmulQunsgEorP:
:										;.MLTU2	\ AP(2)=AP*Qunsg(EORP)
	xor		$FF				; use 2 bytes of P and A for result
	srl		a
	ld		(varPhi),a		; hi  P+1
	xor		a
	ld		b,16
	ld		hl,varP
	rr		(hl)			;  P	\ lo
.MUL7:						; MUL7	\ counter X
	jr		c,.MU21			; carry set, don't add Q
    ld      hl, varQ
	adc		a,(hl)		    ; Q
	rra						;  3 byte result
	ld      hl, varPhi      
	rr		(hl)            ; P+1
    dec     hl
	rr		(hl)            ; p
	djnz	.MUL7			; loop X
	ret
.MU21:						; .MU21	\ carry set, don't add Q
	srl		a				;  not ROR A
	ld      hl, varPhi      
	rr		(hl)            ; P+1
    dec     hl
	rr		(hl)            ; p
	djnz	.MUL7			; loop X
	ret
