
line_gfx_colour db $DF

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

; ">l2_plot_pixel d= row number, hl = column number, e = pixel col"
l2_plot_pixel_320:      ld      a,h
.checkXlt256:           and     a                               ; if h = 0 then must be < 256 so OK
                        jp      z,.DoneCheck
.checkXgt320:           cp      1                               ; if h <> 1 then must be > 320
                        jr      nz,.DontPlot                    ; 
                        ld      a,l                             ; so now its >= 256
.checkXlt320:           and     %11000000                       ; if its 7 or 6 set then > 319
                        jr      nz,.DontPlot
.DoneCheck:             call    asm_l2_320_col_bank_select      ; adjust hl for hl address which is now in l only
                        ld      l,d                             ; low byte is row from d
                        ld      a,e                             ; a= color
                        ld      (hl),a
.DontPlot:              ret

; ">l2_plot_pixel d= row number, hl = column number"
; as per plot but just selects address and adjusts hl to target address column in h
l2_target_address_320:  ld      a,h
                        and     a                               ; if h = 0 then must be < 256 so OK
                        jp      z,.DoneCheck
                        cp      1                               ; if h <> 1 then must be > 320
                        jr      nz,.DontPlot                    ; 
                        ld      a,l                             ; so now its >= 256
                        and     %11000000                       ; if its 7 or 6 set then > 319
                        jr      nz,.DontPlot
.DoneCheck:             call    asm_l2_320_col_bank_select      ; adjust hl for hl address which is now in l only
                        ld      l,d                             ; low byte is row from d
.DontPlot:              ret

l2_plot_pixel_320_no_check:   call    asm_l2_320_col_bank_select      ; adjust hl for column > h 
                        ld      l,d                             ; as they are horizontal now
                        ld      a,e
                        ld      (hl),a
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
                        
; ">l2_plot_pixel_no_bank d= row number, h = column number, a = pixel col"
; This version assues pixel is in the same bank as previously plotted ones. optimised for horizontal lines
l2_plot_pixel_320_no_bank:  
                        ld 		l,d
                        ld 		(hl),a
                        ret
; The more simpler h col l row is just ld (hl),a so no need for a function
                        

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
						