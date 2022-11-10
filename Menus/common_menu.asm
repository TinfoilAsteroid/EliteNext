txt_commander 			DB "COMMANDER",0
txt_inventory 			DB "INVENTORY",0
txt_present_system		DB "Present System   :",0
txt_hyperspace_system	DB "Hyperspace System:",0
txt_condition			DB "Condition   :",0
txt_fuel				DB "Fuel        :",0
txt_cash				DB "Cash        :",0
txt_legal_status		DB "Legal Status:",0
txt_rating				DB "Rating      :",0
txt_equipment			DB "EQUIPMENT:",0

txt_fuel_level			DB "00.0 Light Years",0
txt_cash_amount			DB "XXXXXXXXXX",0
txt_cash_decimal        DB "."
txt_cash_fraction       DB "X Cr",0

txt_status_colour		equ $FF

;;DEFUNCTprint_boiler_text_l2:
;;DEFUNCT; ">print_boilder_text hl = text structure, b = message count"
;;DEFUNCTBoilerTextLoop:
;;DEFUNCT	push		bc			; Save Message Count loop value
;;DEFUNCT	ld			c,(hl)		; Get Row into b
;;DEFUNCT	inc			hl
;;DEFUNCT	ld			b,(hl)		; Get Col into b
;;DEFUNCT	inc			hl
;;DEFUNCT	ld			e,(hl)		; Get text address Lo into E
;;DEFUNCT	inc			hl
;;DEFUNCT	ld			d,(hl)		; Get text address Hi into E
;;DEFUNCT	inc			hl
;;DEFUNCT	push		hl			; Save present HL to stack as this is the address for the next message
;;DEFUNCT	ex			de,hl		; now hl = address of text data
;;DEFUNCT	ld			e,txt_status_colour
;;DEFUNCT    MMUSelectLayer2
;;DEFUNCT	call		l1_print_at
;;DEFUNCT	pop			hl
;;DEFUNCT	pop			bc
;;DEFUNCT	djnz		BoilerTextLoop
;;DEFUNCT	ret


;:DEFUNCT print_boiler_text:
;:DEFUNCT ; ">print_boilder_text hl = text structure, b = message count"
;:DEFUNCT .BoilerTextLoop:
;:DEFUNCT 	push		bc			; Save Message Count loop value
;:DEFUNCT 	ld			c,(hl)		; Get Row into b
;:DEFUNCT 	inc			hl
;:DEFUNCT 	ld			b,(hl)		; Get Col into b
;:DEFUNCT 	inc			hl
;:DEFUNCT 	ld			e,(hl)		; Get text address Lo into E
;:DEFUNCT 	inc			hl
;:DEFUNCT 	ld			d,(hl)		; Get text address Hi into E
;:DEFUNCT 	inc			hl
;:DEFUNCT 	push		hl			; Save present HL to stack as this is the address for the next message
;:DEFUNCT 	ex			de,hl		; now hl = address of text data
;:DEFUNCT 	ld			e,txt_status_colour
;:DEFUNCT 	push		bc
;:DEFUNCT 	pop			de
;:DEFUNCT 	call		l1_print_at
;:DEFUNCT 	pop			hl
;:DEFUNCT 	pop			bc
;:DEFUNCT 	djnz		.BoilerTextLoop
;:DEFUNCT 	ret
	
;;DEFUNCTGetFuelLevel:           INCLUDE "Menus/get_fuel_level_inlineinclude.asm"

;;DEFUNCTGetCash:                ld      hl,(Cash)
;;DEFUNCT                        ex      de,hl
;;DEFUNCT                        ld      ix,(Cash+2)
;;DEFUNCT                        ld		iy,txt_cash_amount
;;DEFUNCT                        call 	DispDEIXtoIY	; This will write out with 0 termination after last digit
;;DEFUNCT.ShiftDecimalDigit:     ld		a,(IY+0)				;Push last digit to post decimal
;;DEFUNCT                        ld		(txt_cash_fraction),a
;;DEFUNCT.UpdateInteger:         ld		hl,txt_cash_amount+1	; Now was there only 1 digit
;;DEFUNCT                        ld		a,(hl)					; if so we leave it alone so its "0.0"
;;DEFUNCT                        cp		0
;;DEFUNCT                        ret		z
;;DEFUNCT                        ld		(IY),0					; Else we erase last digit as it went to fraction
;;DEFUNCT                        ret
	