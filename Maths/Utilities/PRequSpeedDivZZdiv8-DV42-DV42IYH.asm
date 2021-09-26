; "DV42,DV42IYH DE = P.R, c = R"
DV42IYH:									; as per DV42 but using iyl for Y reg
		ld		hl,varDustZ
		ld		a,iyl
		add		hl,a
		ld		a,(hl)
		jp		DV41
DV42:										; travel step of dust particle front/rear
		ld		hl,varDustZ
		ld		a,(regY)
		add		hl,a
		ld		a,(hl)						; a = SZ[y]
DV41:										; P.R = speed/ (ZZ/8) dust left/right
		ld		e,a							; using E as Q var replacement
		ld		a,(DELTA)					; DELTA \ speed, how far has dust moved based on its z-coord.
DVID4:										; P-R=A/Qunsg  \P.R = A/Q unsigned called by Hall
		ld		b,8							; counter
		sla		a							; 
		ld		d,a							; use d for - p = delta * 2
		xor		a
DVL4:										; counter x loop (b reg)
		rl		a							; a = a * 2
		jr		c,DV8						; jump on carry
		cp		e							; var Q
		jr		c,DV5						; skip subtraction
DV8:
		sbc		a,e							; a = a - q (with carry)
		scf									;  carry gets set
DV5:										; skipped subtraction
		rl		d							; d (P hi)
		djnz	DVL4						; dec b and loop loop X, hi left in P.
.CalcRemainder:								; BFRDIV R=A*256/Q
; Note we are not going to call LL28+4 but inline code here:
		ld		b,$FE						; remainder R for AofQ *256/Q
		ld		c,a							; use c as R var
.RollRemainder:
		sla		a
		jr		c,.Reduce					; if a >> generates carry reduce
		cp		b							; a < q?
		jr		nc,.DontSBC
.DoSBC:										; a is < q 
		sbc		a,b							; 	a -= q
.DontSBC:	
		rl		c							; r << 1									
		jr		c, .RollRemainder			; if rol generated a carry, continue
		ld		a,c
		ld		(varR),a					; for backwards compat
		ld		a,d
		ld		(varP),a
		ret									; R (c) left with remainder
.Reduce:									; a geneated a carry
		sbc		a,b							; a = a - (q +1)
		scf									; set carry flag for rl
		rl		c							; r << 1 briging in carry
		jr		c,	.RollRemainder			; if a carry fell off bit 7 then repeat
		ld		a,c
		ld		(varR),a					; for backwards compat
		ld		a,d
		ld		(varP),a
		ret
.AnswerTooBig:
		ld		c,$FF						; arse its too big
		ld		a,c
		ld		(varR),a					; for backwards compat
		ld		a,d
		ld		(varP),a
		ret
