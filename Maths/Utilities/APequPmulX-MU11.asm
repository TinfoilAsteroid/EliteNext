APequPmulX:								; \ \ P*X will be done
MU11:										; P*X will be done
	ld		d,a
	ld		a,(varP)
	ld		e,a
	mul										; de = d * e
	ld		a,d
	ld		(varP),a
	ld		a,e
	ret
