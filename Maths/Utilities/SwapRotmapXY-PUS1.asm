SwapRotmapXY:								;.PUS1	\ -> &546C \ swop rotmat x and z
; Code for sign looks odd as it useds Xhi not XSign on original
; The sign logic looks totally wrong in original but may make sense in real world with RAT and RAT2
pus1:	
; Get Xlo hi to BC Sign to ixh
		ld		hl,UBnKxlo
		ld 		a,(hl)							; save x Coord to BC
		ld		c,a
		inc		hl
		ld		a,(hl)
		ld		b,a
		inc		hl
		ld		a,(hl)
		ld		ixh,a							; BC = x IXH = x sign
; Get Ylo hi to DE Sign to iyh
		ld 		a,(hl)							; save x Coord to BC
		inc		hl
		ld		e,a
		inc		hl
		ld		d,(hl)
		ld		b,a
		inc		hl
		ld		a,(hl)
		ld		iyh,a							; DE = y IXH = y sign
; Sort out signs
		ld		a,(RAT)
		ld		h,a								; h = RAT
		ld		a,b								; a = xhi
		xor		h								; a = xhi XORT RAT
		ld		l,a								;  hold result in l so we can put it in iyh later
		ld		a,(RAT2)
		ld		h,a
		ld		a,iyh							; get Y sign (don;t know why previous uses x hi not x sign TODO
		xor		h
		ld		b,a								; now b holds IY Sign manuipulated and L holds IX Sign manuipulated
; Set values
		ld 		(UbnKxlo),de					; write out Y to X
		ld 		(UbnKylo),bc					; write out X to Y
		ld		a,l								; write out Y sign to x sign  X was manipulated in B
		ld		(UbnKxsgn),a
		ret