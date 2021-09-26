RequAdivQ:
	; R = A/Q, U = remainder, code looked a little odd as if R is reminader and U = result
LL61:										; Handling division R=A/Q for case further down
	ld		c,a								; c = A
	ld		a,(varQ)						; test for divide by 0
	cp		0
	jr		z,LL84							; divide by zero error
	ld		d,a								; now we can do C/D
    ld b,8
    xor a
LL63:										; roll divide loop
    sla c
    rla
    cp d
    jr c,LL64
    inc c
    sub d
LL64:	 
    djnz LL63
	ld	(varU),a							; store remainder in U
	ld	a,c
	ld	(varR),a							; store remainder in R	
    ret
LL84:										; div error  R=U=#5
	ld		a,50
	ld		(varR),a
	ld		(varU),a
	ret

