; ">l2_draw_vert_segment"
; ">hl = bank adjusted pixel poke address d = length, e = color"
; ">will always clip once h = 64 even if length > 64 destroys a and hl, d = resudual length not plotted"
l2_draw_vert_segment:   ld		a,d
.emptylinecheck:	    cp 		0
                        ret		z
.justonepixel	        cp		1
                        jr		nz, .multiplepixelsLoop
                        ld		(hl),e
                        ret
.multiplepixelsLoop:	
.endofbankcheck:        ld   	a,h
                        cp   	64
                        ret		nc							; check before we poke data if we have hit a boundary
.canplotapixel:         ld   	(hl),e						; set colour
                        inc 	h							; we don't check here else we would need a dec d on ret could do for optimisation of loop though
                        dec		d
                        ret		z
                        jr		.multiplepixelsLoop
	
; ">l2_draw_vert_line"
; ">bc = row col d = length, e = color"
l2_draw_vert_line:      ld 		a,b
.offscreencheck:        cp 		SCREEN_HEIGHT
                        ret 	nc							; can't start off the screen
.emptylinecheck:        ld		a,d
                        cp		0
                        ret		z
                        cp		1
                        jr		nz,.multiplepixels
.itsonepixel:           call	l2_plot_pixel
                        ret
.multiplepixels:						; so now we have at least 2 pixels to plot
.clipto192:             ld		a,d							; get length
                        add		a,b							; a= row + length
                        jr		c,.needtoclip				; if it was > 255 then there is a definite need
                        cp		SCREEN_HEIGHT
                        jr		c, .noclipneeded
.needtoclip             ld		a,b
                        add		a,d
                        sub		SCREEN_HEIGHT
                        ld		h,a							; use h as a temp holding for (row + length) - 192
                        ld		a,d
                        sub		h
                        ld		d,a							; d = length - ((row + length) - 192)
; so now BC = row col, d = length clipped, e = color
.noclipneeded:          ld		a,b
                        push	bc,,de
                        call 	asm_l2_row_bank_select:	 	; we now have poke address and a variable holding current bank number
                        pop		bc,,de
                        ld		h,a							; b now tolds target pixel for first plot
                        ld		l,c  						; and c holds pixel column for plotting
                        call 	l2_draw_vert_segment		; draw seg, d = pixels remaining
                        ld		a,d							; a and d = nbr pixels remaining
                        cp		0
                        jr		z, .doneplotting
.anotherbank:           ld		a, (varL2_BANK_SELECTED)
                        inc		a
                        ld		b,0
                        push	bc,,de
                        call 	asm_l2_bank_n_select
                        pop     bc,,de
                        ld		h,b							; b now tolds target pixel for first plot
                        ld		l,c  						; and c holds pixel column for plotting
                        call	l2_draw_vert_segment
                        ld		a,d
                        cp		0
                        jr		z,.doneplotting
.yetanotherbank:        ld		a, (varL2_BANK_SELECTED)
                        inc		a
                        ld		b,0
                        push	bc,,de
                        call 	asm_l2_bank_n_select
                        pop		de
                        pop		hl							; hl = bc
                        call	l2_draw_vert_segment		; we have now hit 192 pixels so done
.doneplotting:	        ret 

; ">l2_draw_vert_line_to"
; ">bc = row col d = to position, e = color"
l2_draw_vert_line_to:   ld		a,b
                        cp		d
                        jr		c, .noyswap
.yswap:                 ld		b,d			; Swap round row numbers so we are always incrementing
                        ld		d,a			; now we have a top to bottom to we we can calc length from bc
.noyswap:               ld		a,d 		; we still may have d in a but only if it was bottom to top
                        sub		b
                        inc		a			; so now its length not offset
                        ld		d,a
                        jr		l2_draw_vert_line	; we can hijack its clipping, 0 check and return logic
                        ; no return needed
	