l2_plot_pixel:
; ">l2_plot_pixel b= row number, c = column number, a = pixel col"
	push    af
    ld      a,b
l2_pp_row_valid:
    JumpIfAGTENusng ScreenHeight,l2_pp_dont_plot
	push    bc								; bank select destroys bc so need to save it
;	ld      a,b
	call    asm_l2_row_bank_select
	pop     bc
	ld      b,a
	ld      h,b								; hl now holds ram address after bank select
	ld      l,c
	pop     af								; a = colour to plott
	ld      (hl),a
	ret
l2_pp_dont_plot:
    pop     af
    ret
	
l2_plot_pixel_no_bank:
; ">l2_plot_pixel_no_bank b= row number, c = column number, a = pixel col"
; This version assues pixel is in the same bank as previously plotted ones. optimised for horizontal lines
	push 	hl
	ld 		h,b								; hl now holds ram address after bank select
	ld 		l,c
	ld 		(hl),a
	pop		hl
	ret

l2_plot_pixel_y_test:
	push	af
	ld		a,b
	cp		192
	jr		nc,.clearup
	pop		af
	jr		l2_plot_pixel
.clearup:
	pop		af
	ret
	
l2_point_pixel_y_safe:	MACRO
						push	hl
						push	bc
						call	l2_plot_pixel
						pop		bc
						pop		hl
						ENDM
						