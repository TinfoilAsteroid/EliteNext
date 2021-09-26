
l2_print_chr_at:
; "l2_print_chr_at, bc = col,row, d= character, e = colour"
; "Need a version that also prints absence of character"
	ld		a,d
	cp		32
	jr		c,.InvalidCharacter		; Must be between 32 and 127
	cp		127
	jr		nc,.InvalidCharacter
.ValidCharater:
	ld		h,0
	ld		l,d
	add		hl,hl						; * 2
	add		hl,hl						; * 4
	add		hl,hl						; * 8 to get byte address
	add		hl,charactersetaddr			; hl = address of rom char
	inc		b							; start + 1 pixel x and y as we only print 7x7
	inc		hl							; skip first byte
	ld		d,7	
.PrintCharLoop:
	push	de
	ld		a,(hl)
	cp		0
	jr		z,.NextRowNoBCPop
.PrintARow:
	push	bc							; save row col
	ld		d,7							; d is loop row number now
.PrintPixelLoop:	
	inc		c							; we start at col 1 not 0 so can move inc here
.PrintTheRow:
	sla		a							; scroll char 1 pixel as we read from bit 7
	push	af							; save character byte
	bit		7,a							; If left most pixel set then plot
	jr		nz,.PixelToPrint
.NoPixelToPrint:
	ld		a,$E3
	jr		.HaveSetPixelColour
.PixelToPrint:
	ld		a,e							; Get Colour
.HaveSetPixelColour		
	push	hl
;	push	bc							; at the moment we don't do paging on first plot so need to preserve BC
.BankOnFirstOnly:
	push	af
	ld		a,d
	cp		7
	jr		z,.PlotWithBank
.PlotNoBank:
	pop		af
	ld 		h,b								; hl now holds ram address after bank select
	ld 		l,c
	ld 		(hl),a
.IterateLoop:	
;	pop		bc
	pop		hl
	pop		af							; a= current byte shifted
	dec		d						 	; do dec after inc as we amy 
	jr		nz,.PrintPixelLoop
.NextRow:
	pop		bc							; Current Col Row
.NextRowNoBCPop:	
	pop		de							; d= row loop
	inc		b							; Down 1 row
	inc		hl							; Next character byte
	dec		d							; 1 done now
	jr		nz,.PrintCharLoop
.InvalidCharacter:
	ret
.PlotWithBank:
	pop		af
	call	l2_plot_pixel				; This will shift bc to poke row
	jr		.IterateLoop

l2_print_at:
; "l2_print_at bc= colrow, hl = addr of message, e = colour"
; "No error trapping, if there is no null is will just cycle on the line"
	ld	a,(hl)							; Return if empty string
	cp	0
	ret	z
	push	hl
	push	de
	push	bc
	ld		d,a							; bc = pos, de = char and colour
	call 	l2_print_chr_at
	pop		bc
	pop		de
	pop		hl
.Move8Pixlestoright:	
	ex		af,af'
	ld		a,c
	add		8
	ld		c,a
	ex		af,af'
	inc		hl
	jr		l2_print_at					; Just loop until 0 found
	

; "l2_print_chr_at, bc = col,row, d= character, e = colour"
; "Need a version that also prints absence of character"
; removed blank line optimisation as we need spaces printed
l2_print_7chr_at:       ld		a,d
                        cp		31
                        jr		c,.InvalidCharacter		; Must be between 32 and 127
                        cp		127
                        jr		nc,.InvalidCharacter
.ValidCharater:         ld		h,0
                        ld		l,d
                        add		hl,hl						; * 2
                        add		hl,hl						; * 4
                        add		hl,hl						; * 8 to get byte address
                        add		hl,charactersetaddr			; hl = address of rom char
                        inc		b							; start + 1 pixel x and y as we only print 7x7
                        inc		hl							; skip first byte
                        ld		d,7	
.PrintCharLoop:         push	de
                        ld		a,(hl)
                        ;cp		0
                        ;jr		z,.NextRowNoBCPop
.PrintARow:             push	bc							; save row col
                        ld		d,6							; d is loop row number now
.PrintPixelLoop:        inc		c							; we start at col 1 not 0 so can move inc here
                        jr		z,.NextRow
                        sla		a							; scroll char 1 pixel as we read from bit 7
                        push	af							; save character byte
                        bit		7,a							; If left most pixel set then plot
                        jr		nz,.PixelToPrint
.NoPixelToPrint:        ld		a,$E3
                        jr		.HaveSetPixelColour
.PixelToPrint:          ld		a,e							; Get Colour
.HaveSetPixelColour		push	hl
                        ;	push	bc							; at the moment we don't do paging on first plot so need to preserve BC
.BankOnFirstOnly:       push	af
                        ld		a,d
                        cp		6
                        jr		z,.PlotWithBank
.PlotNoBank:            pop		af
                        ld 		h,b								; hl now holds ram address after bank select
                        ld 		l,c
                        ld 		(hl),a
.IterateLoop:	        ;	pop		bc
                        pop		hl
                        pop		af							; a= current byte shifted
                        dec		d						 	; do dec after inc as we amy 
                        jr		nz,.PrintPixelLoop
.NextRow:               pop		bc							; Current Col Row
.NextRowNoBCPop:	    pop		de							; d= row loop
                        inc		b							; Down 1 row
                        inc		hl							; Next character byte
                        dec		d							; 1 done now
                        jr		nz,.PrintCharLoop
.InvalidCharacter:      ret
.PlotWithBank:          pop		af
                        call	l2_plot_pixel				; This will shift bc to poke row
                        jr		.IterateLoop
	
; "l2_print_7at bc= colrow, hl = addr of message, e = colour"
; "No error trapping, if there is no null is will just cycle on the line"
l2_print_7at:           ld	a,(hl)							; Return if empty string
                        cp	0
                        ret	z
                        push	hl
                        push	de
                        push	bc
                        ld		d,a							; bc = pos, de = char and colour
                        call 	l2_print_7chr_at
                        pop		bc
                        pop		de
                        pop		hl
.Move7Pixlestoright:	ex		af,af'
                        ld		a,c
                        add		7
                        ld		c,a
                        ex		af,af'
                        inc		hl
                        jr		l2_print_7at					; Just loop until 0 found
	
