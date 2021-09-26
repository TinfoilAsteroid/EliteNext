test1:	; cls
	call 	l2_cls
	ld 		bc, $0505
	ld		a, 74
test2:	
	ld		bc, $0504
	ld		a,  $C0
	call	l2_plot_pixel
	ld		bc, $4004
	ld		a,  $C0
	call	l2_plot_pixel
	ld		bc, $8004
	ld		a,  $C0
	call	l2_plot_pixel
	ld  	bc , $0505
	ld		de , $05B7
	call	l2_draw_vert_line
	ld  	bc , $0507
	ld		de , $15B7
	call	l2_draw_vert_line
	ld  	bc , $0509
	ld		de , $35B7
	call	l2_draw_vert_line
	ld  	bc , $050B
	ld		de , $45B7
	call	l2_draw_vert_line
	ld  	bc , $050D
	ld		de , $96B7
	call	l2_draw_vert_line
	ld  	bc , $4530
	ld		de , $05B7
	call	l2_draw_vert_line
	ld  	bc , $9035
	ld		de , $05B7
	call	l2_draw_vert_line