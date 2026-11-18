; Moved out of Layer2Graphics/layer2_plot_pixel.asm as nothing in the eliteNext.asm build uses it
; (unreferenced routines, and IFDEF blocks whose flag is never defined). Not included in the game build.

; ">l2_plot_pixel_no_bank b= row number, c = column number, a = pixel col"
; This version assues pixel is in the same bank as previously plotted ones. optimised for horizontal lines
l2_plot_pixel_no_bank:  push 	hl
                        ld 		h,b								; hl now holds ram address after bank select
                        ld 		l,c
                        ld 		(hl),a
                        pop		hl
                        ret

; ">l2_plot_pixel_no_bank d= row number, h = column number, a = pixel col"
; This version assues pixel is in the same bank as previously plotted ones. optimised for horizontal lines
l2_plot_pixel_320_no_bank:  
                        ld 		l,d
                        ld 		(hl),a
                        ret

l2_point_pixel_y_safe:	MACRO
						push	hl
						push	bc
						call	l2_plot_pixel
						pop		bc
						pop		hl
						ENDM
