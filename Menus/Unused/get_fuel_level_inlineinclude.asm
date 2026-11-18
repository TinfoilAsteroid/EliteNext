

	ld		a,(Fuel)
	ld		de,txt_fuel_level
	ld	c, -100
	call	.Num1
	ld	c,-10
	call	.Num1
	ld	c,-1
.Num1:	
	ld	b,'0'-1
.Num2:	
	inc		b
	add		a,c
	jr		c,.Num2
	sub 	c
	push	bc
	push	af
	ld		a,c
	cp		-1
	call	z,.InsertDot
	ld		a,b
	ld		(de),a
	inc		de
	pop		af
	pop		bc
	ret 
.InsertDot:
	ld		a,'.'
	ld		(de),a
	inc		de
	ret
	