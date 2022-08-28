l2_plot_macro:          MACRO
                        ld      a,b
                        JumpIfAGTENusng 192 ,.NoPlot
                        ld      l,c
                        call    asm_l2_row_bank_select
                        ld      h,a
                        ld      a,(line_gfx_colour)
                        ld      (hl),a
.NoPlot:                        
                        ENDM
                        
                        
; ">l2_plot_pixel b= row number, c = column number, a = pixel col"
l2_plot_pixel:          push    af
                        ld      a,b
l2_pp_row_valid:        JumpIfAGTENusng ScreenHeight,l2_pp_dont_plot
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
l2_pp_dont_plot:        pop     af
                        ret

; y aixs bounds check must have been done before calling this                        
l2_plot_pixel_no_check: push    af
                        push    bc								; bank select destroys bc so need to save it
                        ld      a,b                             ; determine target bank
                        call    asm_l2_row_bank_select
                        pop     bc
                        ld      b,a                             ; b now adjusted for bank, c = column
                        ld      hl,bc                           ; hl now holds ram address after bank select
                        pop     af								; a = colour to plott
                        ld      (hl),a                          ; poke to ram
                        ret              
	
; ">l2_plot_pixel_no_bank b= row number, c = column number, a = pixel col"
; This version assues pixel is in the same bank as previously plotted ones. optimised for horizontal lines
l2_plot_pixel_no_bank:  push 	hl
                        ld 		h,b								; hl now holds ram address after bank select
                        ld 		l,c
                        ld 		(hl),a
                        pop		hl
                        ret

ShipPixel:              push    af
                        ld      a,b
                        cp      127
                        ret     nc
                        pop     af
                        jr      l2_plot_pixel_no_check
                        ;***Implicit ret due to jr

; in bc = yx iyl = colour
DebrisPixel:            ld      a,b
                        cp      127
                        ret     nc
                        ld      a, iyl
                        jr      l2_plot_pixel_no_check
                        ;***Implicit ret due to jr

l2_plot_pixel_y_test:   push	af
                        ld		a,b
                        cp		192
                        jr		nc,.clearup
                        pop		af
                        jr		l2_plot_pixel
.clearup:               pop		af
                        ret
	
l2_point_pixel_y_safe:	MACRO
						push	hl
						push	bc
						call	l2_plot_pixel
						pop		bc
						pop		hl
						ENDM
						