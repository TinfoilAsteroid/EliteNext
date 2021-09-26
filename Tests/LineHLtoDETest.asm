test2:	
	ld		h, 20
	ld		l, 20
	ld		d, 50
	ld		e, 50
	ld		a,  $D0
	call	LineHLtoDE
test2a:		
	ld		h, 20
	ld		l, 20
	ld		d, 20
	ld		e, 50
	ld		a, $C6
	call	LineHLtoDE	
test3:
	ld		h, 20	; $14
	ld		l, 20	; $14
	ld		d, 30	; $1E
	ld		e, 50	; $32
	ld		a, $D6
	call	LineHLtoDE	
test4:
	ld		h, 20
	ld		l, 20
	ld		d, 10
	ld		e, 50
	ld		a,  $A0
	call	LineHLtoDE	
test5:
	ld		h, 20
	ld		l, 20
	ld		d, 10
	ld		e, 20
	ld		a, $A1
	call	LineHLtoDE	
test6:	
	ld		h, 20
	ld		l, 20
	ld		d, 50
	ld		e, 10
	ld		a, $A3
	call	LineHLtoDE
test7:	
	ld		h, 20
	ld		l, 20
	ld		d, 50
	ld		e, 20
	ld		a, $A4
	call	LineHLtoDE
test8:	
	ld		h, 20
	ld		l, 20
	ld		d, 20
	ld		e, 1
	ld		a, $A5
	call	LineHLtoDE
test9:	
	ld		h, 20
	ld		l, 20
	ld		d, 10
	ld		e, 10
	ld		a, $A6
	call	LineHLtoDE
test10:	
	ld		h, 20
	ld		l, 20
	ld		d, 10
	ld		e, 20
	ld		a, $B0
	call	LineHLtoDE
test11:	
	ld		h, 20
	ld		l, 20
	ld		d, 10
	ld		e, 25
	ld		a, $B1
	call	LineHLtoDE
test12:	
	ld		h, 20
	ld		l, 20
	ld		d, 40
	ld		e, 0
	ld		a, $40
	call	LineHLtoDE
test13:	
	ld		h, 20
	ld		l, 20
	ld		d, 10
	ld		e, 0
	ld		a, $41
	call	LineHLtoDE		
	
test14:	
	ld		h, 20
	ld		l, 20
	ld		d, 10
	ld		e, 15
	ld		a, $42
	call	LineHLtoDE	
	ld		hl, $3040
	ld		de, $3005
	ld		a,  $C2
	call	LineHLtoDE
	ld		hl, $3040
	ld		de, $4505
	ld		a,  $C3
	call	LineHLtoDE
	ld		hl, $3040
	ld		de, $0540
	ld		a,  $C4
	call	LineHLtoDE
	ld		hl, $3040
	ld		de, $0575
	ld		a,  $C5
	call	LineHLtoDE
	ld		hl, $3040
	ld		de, $3075
	ld		a,  $C6
	call	LineHLtoDE
	ld		hl, $3040
	ld		de, $4540
	ld		a,  $C6
	call	LineHLtoDE
	ld		hl, $3040
	ld		de, $4575
	ld		a,  $C7
	call	LineHLtoDE


