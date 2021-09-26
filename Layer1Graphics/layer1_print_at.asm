; "l1 print char a = character, de = Ypixel Xchar of print"
l1_print_char:          push	de,,hl	
                        pixelad								; hl = address of de
                        push	hl							; save hl for loop
                        ld		h,0
                        ld		l,a
                        add		hl,hl						; * 2
                        add		hl,hl						; * 4
                        add		hl,hl						; * 8 to get byte address
                        add		hl,charactersetaddr			; hl = address of rom char
                        ex		de,hl						; save address into de
                        pop		hl							; get back hl for loop 
                        ld		b,8							; do 8 rows
.PrintCharLoop:         ld		a,(de)						; row byte
                        inc		de							; next byte
                        ld		(hl),a						; poke to screen
                        pixeldn								; Down 1 row
                        djnz	.PrintCharLoop				; loop for 8 bytes
                        pop		de,,hl					    ; restore hl
                        ret

; "l1 PrintAt, pixel row, whole char col, DE = yx, HL = message Addr"
; now skips ascii code < 32 but moves on cursor by 1 char
l1_print_at:            
.PrintLoop:             ld		a,(hl)
                        cp		0
                        ret		z
                        CallIfAGTENusng " ", l1_print_char
                        inc		hl							; move 1 message character right
                        ld		a,e
                        add		a,8
                        ld		e,a							; move 1 screen character right
                        jr		.PrintLoop
.Clearstackandfinish:   ;pop		de                      ; TODO LOOOKS TO BE A ROGUE POPDE
                        ret

;l1_print_at_wrap:
;; "l1 PrintAt, pixel row, whole char col, DE = yx, HL = message Addr"
;	ld      iyh,e
;.PrintLoop:
;	ld		a,(hl)
;	cp		0
;	ret		z
;.CountWordCharLen
;; Need to change to word wrap, so it will loop through string as before
;; but read up until a null or space, take the character count * 8 for pixels
;; if that is > 238 then force a premature line wrap
;
;    
;    push    iy
;    call	l1_print_char
;    pop     iy
;	inc		hl							; move 1 message character right
;	ld		a,e
;    cp      238
;    jr      nc,.NextLine
;	add		a,8
;	ld		e,a							; move 1 screen character right
;	jr		.PrintLoop
;.Clearstackandfinish:
;	pop		de
;	ret    
;.NextLine:
;    ld      a,(hl)
;    cp      " "
;    ld      e,iyh
;    ld      a,d
;    add     a,8
;    ld      d,a
;    jr		.PrintLoop
     
; Counts next word at hl, uses e and forces a wrap if it would over flow puts value in c
L1LenWordAtHL:          push    hl
                        push    de
.CountLoop:             ld      a,(hl)
                        cp      0
                        jr      z,.CountDone
                        cp      32
                        jr      z,.CountDone
                        ld      a,e
                        add     a,8
                        ld      e,a
                        cp      238
                        jr      nc,.TooLong
                        inc     hl
                        jr      .CountLoop
.CountDone:             pop     de
                        pop     hl
                        xor     a
                        ret
.TooLong                pop     de                        
                        pop     hl
                        ld      a,$FF
                        ret
                        
L1PrintWordAtHL:        ld      a,(hl)
                        cp      0
                        ret     z
                        cp      32
                        jr      z,.ItsASpace
                        push    iy
                        call	l1_print_char
                        pop     iy
                        ld      a,e
                        add     a,8
                        ld      e,a
                        inc     hl
                        jp      L1PrintWordAtHL
.ItsASpace:             inc     hl      ;  Just a bodge for now
                        ld      a,e
                        add     a,8
                        ld      e,a
                        ret
                               
                    
; "l1 PrintAt, pixel row, whole char col, DE = yx, HL = message Addr"
; Now has full word level wrapping
l1_print_at_wrap:       ld      iyh,e
.PrintLoop:             ld		a,(hl)
                        cp		0
                        ret		z
.CountWordCharLen:      call    L1LenWordAtHL
                        cp      $FF
                        jr      z,.WrapNextLine
.NotTooLong:            call    L1PrintWordAtHL                     
; Need to change to word wrap, so it will loop through string as before
; but read up until a null or space, take the character count * 8 for pixels
; if that is > 238 then force a premature line wrap
                        jr		.PrintLoop
.Clearstackandfinish:   ;op		de
                        ret
.WrapNextLine:           
.NextLine:              ld      e,iyh
                        ld      a,d
                        add     a,8
                        ld      d,a
                        jr		.PrintLoop
          
    