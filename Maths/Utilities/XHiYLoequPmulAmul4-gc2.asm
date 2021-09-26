gc2:								; Xlo.Yhi = P.A *=4
XHiYLoequPmulAmul4:
		ld		e,a
		ld		a,(varP)
		ld		d,a
		mul							; de = P * Q
		sla		e
		rl		d					; de = de * 2
		sla		e
		rl		d					; de = de * 4 by here
		ld		a,e
		ld		(regX),a
		ld		a,d
		ld		(regY),a
		ret
