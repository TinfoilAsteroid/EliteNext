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

print_boiler_text_l2:
; ">print_boilder_text hl = text structure, b = message count"
BoilerTextLoop:
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
	ld			e,txt_status_colour
    MMUSelectLayer2
	call		l1_print_at
	pop			hl
	pop			bc
	djnz		BoilerTextLoop
	ret


print_boiler_text:
; ">print_boilder_text hl = text structure, b = message count"
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
	ld			e,txt_status_colour
	push		bc
	pop			de
	call		l1_print_at
	pop			hl
	pop			bc
	djnz		.BoilerTextLoop
	ret
	
GetFuelLevel:           INCLUDE "Menus/get_fuel_level_inlineinclude.asm"

GetCash:                ld      hl,(Cash)
                        ex      de,hl
                        ld      ix,(Cash+2)
                        ld		iy,txt_cash_amount
                        call 	DispDEIXtoIY	; This will write out with 0 termination after last digit
.ShiftDecimalDigit:     ld		a,(IY+0)				;Push last digit to post decimal
                        ld		(txt_cash_fraction),a
.UpdateInteger:         ld		hl,txt_cash_amount+1	; Now was there only 1 digit
                        ld		a,(hl)					; if so we leave it alone so its "0.0"
                        cp		0
                        ret		z
                        ld		(IY),0					; Else we erase last digit as it went to fraction
                        ret
	