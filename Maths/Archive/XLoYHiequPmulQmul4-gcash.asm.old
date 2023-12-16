gcash:								; Xlo.Yhi = P*Q*4
XYequPmulQmul4:
		ld		a,(varP)
		ld		d,a
		ld		a,(varQ)
		ld		e,a
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
