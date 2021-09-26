gc3:								; Xlo.YHi = P.A
XHiYLoequPA:
		ld		(regY),a
		ld		a,(varP)
		ld		(regX),a
		ret
