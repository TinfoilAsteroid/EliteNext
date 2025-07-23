; "l1 print char a = character, de = Ypixel Xpxiel rounded to char of print"
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
l1_print_at_char     :  sla     d       ; Convert D from char to pixel
                        sla     d       ; by muliplying by 8
                        sla     d       ; 
                        sla     e       ; Convert E from char to pixel
                        sla     e
                        sla     e
l1_print_at:                            ; print string at hl to pixel address DE (YX)
.PrintLoop:             ld		a,(hl)
                        cp		0
                        ret		z
                        CallIfAGTENusng " ", l1_print_char  ; all characters space and upwards
                        inc		hl							; move 1 message character right
                        ld		a,e
                        add		a,8
                        ld		e,a							; move 1 screen character right
                        jr		.PrintLoop
                                        DISPLAY "TODO: looks liek rogue popde"
.Clearstackandfinish:   ;pop		de                      ; TODO LOOOKS TO BE A ROGUE POPDE
                        ret
                     


HexU8Char:       DB "00",0
HexU16Char:      DB "0000",0
HexS8Char:       DB "+00",0
HexS16Char:      DB "+0000",0
HexS24Char:      DB "+0000.00",0
HexU8NaN:        DB "**",0
Bin8Bit:         DB "00000000",0
; prints + sign for bit 7 clear in a else - sign for bit 7 set, Load to buffer location in ix
l1_buffer_sign_at_ix:   bit     7,a
                        jp      z,.PrintPlus
.PrintMinus:            ld      a,"-"
                        ld      (ix+0),a
                        ret
.PrintPlus:             ld      a,"+"
                        ld      (ix+0),a
                        ret

HexMapping:     DB "0123456789ABCDEF"
; writes hex 8 bit to ix buffer position
l1_buffer_hex_8_at_ix:  push    bc,,hl
                        ld      b,a
                        swapnib
                        and     $0F
                        ld      hl,HexMapping
                        add     hl,a
                        ld      a,(hl)
                        ld      (ix+0),a
                        ld      hl,HexMapping
                        ld      a,b
                        and     $0F
                        add     hl,a
                        ld      a,(hl)
                        ld      (ix+1),a
                        pop     bc,,hl
                        ret
l1_print_bin8_at_char:    push  af,,bc,,de,,hl
                          ld    ix,Bin8Bit
                          ld    b,8
.WriteLoop:               sla   a
                          jr    c,.ItsaOne
.ItsAZero:                ld    c,'0'
                          jp    .DoWrite
.ItsaOne:                 ld    c,'1'
.DoWrite:                 ld    (ix+0),c
                          inc   ix
                          djnz  .WriteLoop
                          pop   af,,bc,,de,,hl
                          ld    hl,Bin8Bit
                          call  l1_print_at_char
                          ret

l1_print_bin8_r2l_at_char:push  af,,bc,,de,,hl
                          ld    ix,Bin8Bit
                          ld    b,8
.WriteLoop:               srl   a
                          jr    c,.ItsaOne
.ItsAZero:                ld    c,'0'
                          jp    .DoWrite
.ItsaOne:                 ld    c,'1'
.DoWrite:                 ld    (ix+0),c
                          inc   ix
                          djnz  .WriteLoop
                          pop   af,,bc,,de,,hl
                          ld    hl,Bin8Bit
                          call  l1_print_at_char
                          ret
                          
l1_print_bin8_l2r_at_char:push  af,,bc,,de,,hl
                          ld    ix,Bin8Bit
                          ld    b,8
.WriteLoop:               sla   a
                          jr    c,.ItsaOne
.ItsAZero:                ld    c,'0'
                          jp    .DoWrite
.ItsaOne:                 ld    c,'1'
.DoWrite:                 ld    (ix+0),c
                          inc   ix
                          djnz  .WriteLoop
                          pop   af,,bc,,de,,hl
                          ld    hl,Bin8Bit
                          call  l1_print_at_char
                          ret

; prints 16 bit lead sign hex value in HLA at char pos DE
l1_print_s24_hex_at_char: push  af                      ; first off do sign
                          ld    ix,HexS24Char
                          ld    a,h
                          call  l1_buffer_sign_at_ix
                          pop   af                      ; now do hl as an unsigned by clearing bit 7
                          inc   ix                      ; move to actual digits
                          push  af
                          ld    a,h
                          res   7,a                     ; clear sign bit regardless
                          call  l1_buffer_hex_8_at_ix
                          inc   ix
                          inc   ix
                          ld    a,l
                          call  l1_buffer_hex_8_at_ix
                          inc   ix
                          inc   ix                      
                          inc   ix                      ; also skip decimal point
                          pop   af
                          call  l1_buffer_hex_8_at_ix
                          ld    hl,HexS24Char           ; by here de is still unaffected
                          call  l1_print_at_char
                          ret
; prints 16 bit lead sign hex value in HL at char pos DE
l1_print_s16_hex_at_char: ld    ix,HexS16Char
                          ld    a,h
                          call  l1_buffer_sign_at_ix
                          inc   ix                      ; move to actual digits
                          ld    a,h
                          res   7,a
                          call  l1_buffer_hex_8_at_ix
                          inc   ix
                          inc   ix
                          ld    a,l
                          call  l1_buffer_hex_8_at_ix
                          ld    hl,HexS16Char           ; by here de is still unaffected
                          call  l1_print_at_char
                          ret
; prints 16 bit unsigned hext value in HL at char pos DE
l1_print_u16_hex_at_char: ld    ix,HexU16Char
                          ld    a,h
                          call  l1_buffer_hex_8_at_ix
                          inc   ix
                          inc   ix
                          ld    a,l
                          call  l1_buffer_hex_8_at_ix
                          ld    hl,HexU16Char           ; by here de is still unaffected
                          call  l1_print_at_char
                          ret
; prints 8 bit signed hext value in a at char pos DE
l1_print_s8_hex_at_char:  ld    ix,HexS8Char
                          ld    h,a                     ; save a into h
                          call  l1_buffer_sign_at_ix
                          inc   ix                      ; move to actual digits
                          ld    a,h                     ; get a back
                          res   7,a                     ; clear sign bit regardless                          
                          call  l1_buffer_hex_8_at_ix
                          ld    hl,HexS8Char           ; by here de is still unaffected
                          call  l1_print_at_char
                          ret
; prints 8 bit 2s compliment value in a at char pos DE
l1_print_82c_hex_at_char: ld    ix,HexS8Char
                          ld    h,a                     ; save a into h
                          call  l1_buffer_sign_at_ix
                          inc   ix                      ; move to actual digits
                          ld    a,h                     ; get a back
                          bit   7,a
                          jp    z,.NoNeg
                          neg
.NoNeg:                   call  l1_buffer_hex_8_at_ix
                          ld    hl,HexS8Char           ; by here de is still unaffected
                          call  l1_print_at_char
                          ret
; prints 8 bit 2s compliment value in hl at char pos DE
l1_print_162c_hex_at_char:ld    ix,HexS16Char
                          ld    a,h                     ; check sign bit
                          call  l1_buffer_sign_at_ix
                          inc   ix                      ; move to actual digits
                          ld    a,h                     ; get a back
                          bit   7,a                     ; and negate if negative
                          jp    z,.NoNeg
                          NegHL
                          ld    a,h
.NoNeg:                   call  l1_buffer_hex_8_at_ix
                          inc   ix
                          inc   ix
                          ld    a,l
                          call  l1_buffer_hex_8_at_ix
                          ld    hl,HexS16Char          ; by here de is still unaffected
                          call  l1_print_at_char
                          ret

; prints Lead Sign byte 8 bit signed hex value in hl at char pos DE, reuse HexS8Char buffer
l1_print_s08_hex_at_char: ld    ix,HexS8Char
                          call  l1_buffer_sign_at_ix    ; h holds sign bit
                          inc   ix                      ; move to actual digits
                          ld    a,l                     ; l holds value
                          call  l1_buffer_hex_8_at_ix
                          ld    hl,HexS8Char           ; by here de is still unaffected
                          call  l1_print_at_char
                          ret
; prints 8 bit signed hext value in a at char pos DE
l1_print_u8_hex_at_char:  ld    ix,HexU8Char
                          call  l1_buffer_hex_8_at_ix
                          ld    hl,HexU8Char           ; by here de is still unaffected
                          call  l1_print_at_char
                          ret
l1_PlusSign:              DB      "+",0
l1_MinusSign:             DB      "-",0
l1_ClearSign:             DB      " ",0
; Displays sign byte in A at DE
l1_printSignByte:         cp      $80
                          jp      nz,.DisplayPlus
                          cp      1
                          jp      nz,.DisplayMinus
.DisplayClear:            ld      hl,l1_ClearSign
                          call    l1_print_at_char      
                          ret                     
.DisplayMinus             ld      hl,l1_MinusSign
                          call    l1_print_at_char      
                          ret
.DisplayPlus:             ld      hl,l1_PlusSign
                          call    l1_print_at_char
                          ret

l1_print_u8_nan_at_char:  ld    hl,HexU8NaN
                          call  l1_print_at_char
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
                               
                    
; print at based whole character positions DE=yx, HL = message Addr
; 
l1_print_at_char_wrap:  sla     d       ; Convert D from char to pixel
                        sla     d       ; by muliplying by 8
                        sla     d       ; 
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
          
    