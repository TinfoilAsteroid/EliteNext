
; "l2_print_chr_at, bc = col,row, d= character, e = colour"
; "Need a version that also prints absence of character"

; Counts next word at de, uses hl for current pixel col and counting characters
; b = returned number of characters for word
L2LenWordAtDE:          push    de
                        ld      b,0
.preCheck               ld      a,(de)                  ; check for null
                        and     a
                        jp      z,.CountDone
                        cp      ' '                     ; check if its just one space
                        jp      z,.WhiteSpaceOnly
.CountLoop:             inc     b                       ; ok we can move on 1 character
.OKLength:              inc     de
                        ld      a,(de)                  ; get next character
                        cp      0                       ; on first pass we will have done this
                        jr      z,.CountDone
                        cp      ' '
                        jr      z,.CountDone            ; If its whitespace we can also just exit
                        jr      .CountLoop
.WhiteSpaceOnly:        inc     b                       ; set b to 1 as it was 0 before this call
.CountDone:             pop     de
                        ret


l2_print_chr_at:        ld		a,d
                        cp		32
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
                        cp		0
                        jr		z,.NextRowNoBCPop
.PrintARow:             push	bc							; save row col
                        ld		d,7							; d is loop row number now
.PrintPixelLoop:	    inc		c							; we start at col 1 not 0 so can move inc here
.PrintTheRow:           sla		a							; scroll char 1 pixel as we read from bit 7
                        push	af							; save character byte
                        bit		7,a							; If left most pixel set then plot
                        jr		nz,.PixelToPrint
.NoPixelToPrint:        ld		a,$E3
                        jr		.HaveSetPixelColour
.PixelToPrint:          ld		a,e							; Get Colour
.HaveSetPixelColour		push	hl
;	push	bc						; at the moment we don't do paging on first plot so need to preserve BC
.BankOnFirstOnly:       push	af
                        ld		a,d
                        cp		7
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

; "l2_print_at bc= colrow, hl = addr of message, e = colour"
; "No error trapping, if there is no null is will just cycle on the line"
l2_print_at:            ld	a,(hl)							; Return if empty string
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
.Move8Pixlestoright:	ex		af,af'
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


; "l2_print_7at b= row, hl = col de = addr of message, c = colour"
; "No error trapping, if there is no null is will just cycle on the line"

l2_print_7at_320:       ld	a,(de)							; Return if empty string
                        cp	0
                        ret	z
                        push	hl,,de,,bc
                        ld		d,a							; bc = pos, de = char and colour
                        ;TODOcallcall 	l2_print_7chr_at_320
                        pop		hl,,de,,bc
.Move7Pixlestoright:	ex		af,af'
                        ld		a,c
                        add		7
                        ld		c,a
                        ex		af,af'
                        inc		hl
                        jr		l2_print_7at_320		    ; Just loop until 0 found

l2_print_blank_at_320:  ld      d,b                         ; d = row
                        call    l2_target_address_320       ;
;... so now we have hl = address of 8 bytes of character, iyl = d = row , iyh = c = color, ixh = off colour, stack = column, b = 8
.PrintCharPrep:         ld      b,8                         ;
.PrintCharLoop:         push    hl                          ; save row col address
                        ZeroA
.LineUnwarped:          ld      (hl),a                      ; write to screen                       
                        inc     h                           ; next colum = + 256
                        ld      (hl),a                      ; write to screen                       
                        inc     h                           ; next colum = + 256
                        ld      (hl),a                      ; write to screen                       
                        inc     h                           ; next colum = + 256
                        ld      (hl),a                      ; write to screen                       
                        inc     h                           ; next colum = + 256
                        ld      (hl),a                      ; write to screen                       
                        inc     h                           ; next colum = + 256
                        ld      (hl),a                      ; write to screen                       
                        inc     h                           ; next colum = + 256
                        ld      (hl),a                      ; write to screen                       
                        inc     h                           ; next colum = + 256
                        ld      (hl),a                      ; write to screen                       
                        inc     h                           ; next colum = + 256
.DoneLine:              pop     hl                          ; get back row col
                        inc     hl                          ; move down 1 pixel row
                        djnz    .PrintCharLoop
                        ret
; l2_print_char_at_320, b = row, hl = col, a = code for charater, c = color
l2_print_char_at_320:   cp		32
                        jr		nc,.LowerValid          	; Must be between 32 and 127
                        ld      a,32                        ; else we set it to space
                        jp      .ValidCharacter             ; .
.LowerValid:            cp		127                         ; .
                        jr		c,.ValidCharacter           ; .
.UpperInvalid:          ld      a,32                        ; .
; now translate row in b and col in hl to a valid address, in 320 mode high byte
.ValidCharacter:        cp      32                          ; now a holds valid ascii
                        jp      z,l2_print_blank_at_320     ; Optimisation for space character to just write blanks
                        ; Implicit return on jp z
; calcualte target address and bring in correct bank hl = col, d = row
.CaclulateWriteAddr:    ld      d,b                         ; d = row
                        ld      ixl,0                       ; pixel off
                        ld      ixh,c                       ; pixel on
                        ex      af,af'                      ; save a holding charachter code
                        call    l2_target_address_320       ;
                        ex      af,af'
                        push    hl                          ; save target address
.CalculateCharacterAddr:ld      e,8                         ; de = offset address for character set
                        ld      d,a                         ; d = ascii code so *8 gives de = offset in char set
                        mul     de                          ;
                        ld		hl,charactersetaddr			; hl = address of rom char,
                        add     hl,de                       ; hl = address of rom character bytes
                        pop     de                          ; de = screen address
;... so now we have hl = address of 8 bytes of character, iyl = d = row , iyh = c = color, ixh = off colour, stack = column, b = 8
.PrintCharPrep:         ld      b,8                         ;
.PrintCharLoop:         push    bc
                        ld      a,(hl)                      ; a= byte to write
                        ld      b,8                         ; 8 pixels across
                        push    de                          ; save row col address
.LineLoop:              sla      a
                        jr      c,.plotPixel
.PlotSpace:             ex      af,af'                      ; save current byte
                        ld      a,ixl                       ; write 0
                        jp      .WritePixel                 ; 
.plotPixel:             ex      af,af'                      ; save currenty byte
                        ld      a,ixh                       ; write color
.WritePixel:            ld      (de),a                      ; write to screen
                        ex      af,af'                      ; retrieve current byte
                        inc     d                           ; next colum = + 256
                        djnz    .LineLoop
.DoneLine:              pop     de                          ; get back row col
                        inc     de                          ; move down 1 pixel row
                        pop     bc
                        inc     hl                          ; move to next byte
                        djnz    .PrintCharLoop
                        ret
; l2_print_char_at_320, b = row, hl = col, a = code for charater, c = color
; checks bank on every column
l2_print_char_at_320_precise:
                        cp		32
                        jr		nc,.LowerValid          	; Must be between 32 and 127
                        ld      a,32                        ; else we set it to space
                        jp      .ValidCharacter             ; .
.LowerValid:            cp		127                         ; .
                        jr		c,.ValidCharacter           ; .
.UpperInvalid:          ld      a,32                        ; .
; now translate row in b and col in hl to a valid address, in 320 mode high byte
.ValidCharacter:        cp      32                          ; now a holds valid ascii
                        jp      z,l2_print_blank_at_320     ; Optimisation for space character to just write blanks
                        ; Implicit return on jp z
; calcualte target address and bring in correct bank hl = col, d = row
.CaclulateWriteAddr:    ld      d,b                         ; d = row
                        ld      ixl,0                       ; pixel off
                        ld      ixh,c                       ; pixel on
                        ex      af,af'                      ; save a holding charachter code
                        call    l2_target_address_320       ;
                        ex      af,af'
                        push    hl                          ; save target address
.CalculateCharacterAddr:ld      e,8                         ; de = offset address for character set
                        ld      d,a                         ; d = ascii code so *8 gives de = offset in char set
                        mul     de                          ;
                        ld		hl,charactersetaddr			; hl = address of rom char,
                        add     hl,de                       ; hl = address of rom character bytes
                        pop     de                          ; de = screen address
;... so now we have hl = address of 8 bytes of character, iyl = d = row , iyh = c = color, ixh = off colour, stack = column, b = 8
.PrintCharPrep:         ld      b,8                         ;
.PrintCharLoop:         push    bc
                        ld      a,(hl)                      ; a= byte to write
                        ld      b,8                         ; 8 pixels across
                        push    de                          ; save row col address
.LineLoop:              sla      a
                        jr      c,.plotPixel
.PlotSpace:             ex      af,af'                      ; save current byte
                        ld      a,ixl                       ; write 0
                        jp      .WritePixel                 ; 
.plotPixel:             ex      af,af'                      ; save currenty byte
                        ld      a,ixh                       ; write color
.WritePixel:            ld      (de),a                      ; write to screen
                        inc     d                           ; next colum = + 256
                        ld      a,d
                        JumpIfALTNusng 64, .NoBankSwitch 
.NextBank:              push    bc
                        call    asm_l2_320_next_bank_noSv
                        pop     bc
                        ld      d,0                         ; as we have moved on reset address column
.NoBankSwitch:          ex      af,af'                      ; retrieve current byte
                        djnz    .LineLoop
.DoneLine:              call    asm_l2_reselect_saved_bank
                        pop     de                          ; get back row col
                        inc     de                          ; move down 1 pixel row
                        pop     bc
                        inc     hl                          ; move to next byte
                        djnz    .PrintCharLoop
                        ret
 	
; l2_print_at_320, b = row, hl = col, de = addr of message, c = color
; non optimised bank switching as it will do it for each character
; assumes each character is aligned to a bank so will only bank switch on new character cell
l2_print_at_320:        ld      a,(de)                      ; return if empty message
                        and     a
                        ret     z
                        push    bc,,de,,hl
                        ld      a,(de)
                        call 	l2_print_char_at_320        ; l2_print_char_at_320, b = row, hl = col, a = code for chrater, c = color
                        pop     bc,,de,,hl
                        ld      a,8
                        add     hl,a
                        inc     de
                        jp      l2_print_at_320

;l2_print_at_320_precise, b = row, hl = col, de = addr of message, c = color
; This version bank switch checks on every column, needs to be checked if optimisation of bank swtiching can be done
; assumes each character is aligned to a bank so will only bank switch on new character cell
l2_print_at_320_precise:ld      a,(de)                      ; return if empty message
                        and     a
                        ret     z
                        push    bc,,de,,hl
                        ld      a,(de)
                        call 	l2_print_char_at_320_precise       ; l2_print_char_at_320, b = row, hl = col, a = code for chrater, c = color
                        pop     bc,,de,,hl
                        ld      a,8
                        add     hl,a
                        inc     de
                        jp      l2_print_at_320_precise


; l2_print_at_320, b = row, hl = col, de = addr of message, c = color, iyl = rowlength
; loops printing line at a time wraps at colum 38
; current col = start col
; while char at ptr <> 0
;  if char at ptr = white space
;     word length = 8
;  else
;      get legnth of work at ptr
;  end if
;  if current col + word length > 310
;     current col = start col
;     currnet row += 8
;   end if
;   print word
;   current col += word length
; loop
; Not for optimisation always works in 8 pixel alignment
l2_print_at_wrap_320:   
.PrintPrep:             ld      a,(de)                  ; intial trap null char at ptr <> 0
                        and     a                       ; .
                        ret     z                       ; .
                        ld      iyl,c                   ; iyl = color
                        push    hl                      ; save pixel column address
                        ex      de,hl                   ; hl = hl / 8
                        ld      iyh,b                   ; save b register
                        ld      b,3                     ; .
                        bsrl    de,b                    ; .
                        ex      de,hl                   ; .
                        ld      c,l                     ; c = current column in characters rather than pixels
                        ld      ixl,c                   ; ixl = colum in characters for new line
                        pop     hl                      ; get back pixel column address
.PrintLoop:             ld      a,(de)                  ; while char at ptr <> 0
                        and     a                       ; .
                        ret     z   
                        call    L2LenWordAtDE           ; b = length of string
                        ld      ixh,b                   ; save string length
                        ld      a,c                     ; a= total character length
                        add     a,b                     ; a= projected end character position of string
                        ld      c,a                     ; c=total character length (needed to keep track of string length so far
                        ld      b,iyh                   ; restore b saved in iyh above for row 
                        JumpIfALTNusng 38,.printWord    ; if calcualted length > 38 chars then word wrap
.wrapText:              ld      c,ixl                   ; start column
                        ex      de,hl                   ; update hl to be pixel start column
                        ld      d,ixl                   ;
                        ld      e,8                     ;
                        mul     de                      ;
                        ex      de,hl                   ;
                        ld      a,8                     ; down one row
                        add     a,b                     ; .
                        ld      b,a                     ; .
                        ld      iyh,a                   ; update iyh copy of b
; now bc = pxiel row, character column after string printed, de = start of string, hl = pixel col, iyl = color, ixl = column for start of line, iyh = original pixel row
.printWord:             push    bc,,de,,hl,,ix          ; stack all registgers
                        break
.CalculateColum:        ld      a,(de)                  ; get ascii code
                        ld      c,iyl                   ; get colour back
                        call    l2_print_char_at_320    ; b = row, hl = col, a = code for charater, c = color
                        pop     bc,,de,,hl,,ix          ;
                        inc     de                      ; move to next character
                        ld      a,8                     ; move column 8 pixles
                        add     hl,a                    ; loop until we get a space
                        dec     ixh
                        ld      a,ixh
                        and     a
                        jp      nz,.printWord
                        jp      .PrintLoop


                        