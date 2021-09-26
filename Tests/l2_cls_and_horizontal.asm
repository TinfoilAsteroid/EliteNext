test1:	; cls
	call 	l2_cls
	ld 		bc, $0505
	ld		a, 74
test2: 	;  then plot 5 pixels	
	call	l2_plot_pixel
	ld 		bc, $0555
	ld		a, 70
	call	l2_plot_pixel
	ld 		bc, $05F2
	ld		a, 80
	call	l2_plot_pixel
	ld 		bc, $4215
	ld		a, 123
	call	l2_plot_pixel
	ld 		bc, $8725
	ld		a, 123
	call	l2_plot_pixel
test3: ; 	Horzontal lines DMA, note it does no bank shift
	xor 	a
	call 	asm_l2_bank_n_select
	ld 		bc, $0610
	ld		de, $2040
	call	l2_draw_horz_dma ;; BAD
test4: ;    Horizontal lines length
	ld 		bc, $071F
	ld		de, $20A0
	call	l2_draw_horz_line
	ld 		bc, $4BA0
	ld		de, $10B0
	call	l2_draw_horz_line
	ld 		bc, $A070
	ld		de, $30C0
	call	l2_draw_horz_line
test5: ;	Horizontal from to
	ld 		bc, $101F
	ld		de, $F0B6
	call	l2_draw_horz_line_to
	ld 		bc, $12F0
	ld		de, $1FB7
	call	l2_draw_horz_line_to