
;">print_boilder_text hl = text structure, b = message count"
.BoilerTextLoop:
	push		bc			; Save Message Count loop value
	ld			c,(hl)		; Get Row into b
	inc			hl
	ld			b,(hl)		; Get Col into b
	inc			hl
	ld			e,(hl)		; Get text address Lo into E
	inc			hl
	ld			d,(hl)		; Get text address Hi into E
	inc			hl
	push		hl			; Save present HL to stack as this is the address for the next message
	ex			de,hl		; now hl = address of text data
    MMUSelectLayer2
    ld      e,txt_status_colour
    call    l2_print_at
	pop			hl
	pop			bc
	djnz		.BoilerTextLoop
	ret
	