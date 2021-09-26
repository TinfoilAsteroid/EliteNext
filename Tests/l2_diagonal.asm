test2:	
	ld		b, 20
	ld		c, 20
	ld		d, 50
	ld		e, 50
	ld		a,  $D0
	call	l2_draw_diagonal
test2a:		
	ld		b, 20
	ld		c, 20
	ld		d, 20
	ld		e, 50
	ld		a, $C6
	call	l2_draw_diagonal	
test3:
	ld		b, 20	; $14
	ld		c, 20	; $14
	ld		d, 30	; $1E
	ld		e, 50	; $32
	ld		a, $D6
	call	l2_draw_diagonal	
test4:
	ld		b, 20
	ld		c, 20
	ld		d, 10
	ld		e, 50
	ld		a,  $A0
	call	l2_draw_diagonal	
test5:
	ld		b, 20
	ld		c, 20
	ld		d, 10
	ld		e, 20
	ld		a, $A1
	call	l2_draw_diagonal	
test6:	
	ld		b, 20
	ld		c, 20
	ld		d, 50
	ld		e, 10
	ld		a, $A3
	call	l2_draw_diagonal
test7:	
	ld		b, 20
	ld		c, 20
	ld		d, 50
	ld		e, 20
	ld		a, $A4
	call	l2_draw_diagonal
test8:	
	ld		b, 20
	ld		c, 20
	ld		d, 20
	ld		e, 1
	ld		a, $A5
	call	l2_draw_diagonal
test9:	
	ld		b, 20
	ld		c, 20
	ld		d, 10
	ld		e, 10
	ld		a, $A6
	call	l2_draw_diagonal
test10:	
	ld		b, 20
	ld		c, 20
	ld		d, 10
	ld		e, 20
	ld		a, $B0
	call	l2_draw_diagonal
test11:	
	ld		b, 20
	ld		c, 20
	ld		d, 10
	ld		e, 25
	ld		a, $B1
	call	l2_draw_diagonal
test12:	
	ld		b, 20
	ld		c, 20
	ld		d, 40
	ld		e, 0
	ld		a, $40
	call	l2_draw_diagonal
test13:	
	ld		b, 20
	ld		c, 20
	ld		d, 10
	ld		e, 0
	ld		a, $41
	call	l2_draw_diagonal		
	
test14:	
	ld		b, 20
	ld		c, 20
	ld		d, 10
	ld		e, 15
	ld		a, $42
	call	l2_draw_diagonal	
;ld		bc, $3040
;ld		de, $3005
;ld		a,  $C2
;call	l2_draw_diagonal
;ld		bc, $3040
;ld		de, $4505
;ld		a,  $C3
;call	l2_draw_diagonal
;ld		bc, $3040
;ld		de, $0540
;ld		a,  $C4
;call	l2_draw_diagonal
;ld		bc, $3040
;ld		de, $0575
;ld		a,  $C5
;call	l2_draw_diagonal
;ld		bc, $3040
;ld		de, $3075
;ld		a,  $C6
;call	l2_draw_diagonal
;ld		bc, $3040
;ld		de, $4540
;ld		a,  $C6
;call	l2_draw_diagonal
;ld		bc, $3040
;ld		de, $4575
;ld		a,  $C7
;call	l2_draw_diagonal
