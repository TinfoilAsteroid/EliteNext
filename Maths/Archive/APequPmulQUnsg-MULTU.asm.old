APequPmulQUnsg:								; \ AP=P*Qunsg
MULTU:                  ld		a,(varQ)
                        cp		0
                        jr		z,.MU1							; up, P = Acc = Xreg = 0
; P*X will be done
.MUL1:			        ld		d,a
                        ld		a,(varP)
                        ld		e,a
                        mul										; de = d * e
                        ld		a,d
                        ld		(varP),a
                        ld		a,e
                        ret
.MU1:                   ld		(varP),a
                        or		a								; clear carry flag
                        ret