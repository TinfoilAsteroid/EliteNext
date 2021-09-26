ivnentory_page_marker   DB "Inventory   PG52"  
inventory_boiler_text	DW $0248,INM_inventory
						DW $0B08,INM_fuel
						DW $1308,INM_cash

INM_inventory 			DB "INVENTORY",0
INM_fuel				DB "Fuel:",0
INM_cash				DB "Cash:",0

txt_inventory_amount	DB "00000",0
inventory_cursor		DW $0000
inv_fuel_position		equ	$0B30
inv_cash_position		equ	$1330

inventory_position		equ $2008
inventory_amount		equ $80
inventory_uom			equ	$B0
inv_selected_row        DB 0

INM_cash_amount			DS 10
INM_cash_UoM            DB " Cr",0

INM_DispAtoDE:          ld h,0
                        ld l,a
                        ld	bc,-10000
                        call	.Num1
                        ld	bc,-1000
                        call	.Num1
                        ld	bc,-100
                        call	.Num1
                        ld	c,-10
                        call	.Num1
                        ld	c,-1
.Num1:	                ld	a,'0'-1
.Num2:	                inc	a
                        add	hl,bc
                        jr	c,.Num2
                        sbc	hl,bc
                        ld	(de),a
                        inc	de
                        ret 

INM_print_boiler_text:  INCLUDE "Menus/print_boiler_text_inlineInclude.asm"

INM_DispDEIXtoIY:       ld (.inmclcn32z),ix
                        ld (.inmclcn32zIX),de
                        ld ix,.inmclcn32t+36
                        ld b,9
                        ld c,0
.inmclcn321:            ld a,'0'
                        or a
.inmclcn322:            ld e,(ix+0)
                        ld d,(ix+1)
                        ld hl,(.inmclcn32z)
                        sbc hl,de
                        ld (.inmclcn32z),hl
                        ld e,(ix+2)
                        ld d,(ix+3)
                        ld hl,(.inmclcn32zIX)
                        sbc hl,de
                        ld (.inmclcn32zIX),hl
                        jr c,.inmclcn325
                        inc c
                        inc a
                        jr .inmclcn322
.inmclcn325:            ld e,(ix+0)
                        ld d,(ix+1)
                        ld hl,(.inmclcn32z)
                        add hl,de
                        ld (.inmclcn32z),hl
                        ld e,(ix+2)
                        ld d,(ix+3)
                        ld hl,(.inmclcn32zIX)
                        adc hl,de
                        ld (.inmclcn32zIX),hl
                        ld de,-4
                        add ix,de
                        inc c
                        dec c
                        jr z,.inmclcn323
                        ld (iy+0),a
                        inc iy
.inmclcn323:            djnz .inmclcn321
                        ld a,(.inmclcn32z)
                        add A,'0'
                        ld (iy+0),a
                        ld (iy+2),0
                        ld      a,(IY+0)
                        ld      (IY+1),a
                        ld      a,"."
                        ld      (IY+0),a
                        inc     IY
                        inc     IY
                        ret
.inmclcn32t             dw 1,0,     10,0,     100,0,     1000,0,       10000,0
                        dw $86a0,1, $4240,$0f, $9680,$98, $e100,$05f5, $ca00,$3b9a
.inmclcn32z             ds 2
.inmclcn32zIX           ds 2

INM_GetFuelLevel:       INCLUDE "Menus/get_fuel_level_inlineinclude.asm"

; "A = stock item number"
;----------------------------------------------------------------------------------------------------------------------------------
PrintInvItem:           ld		b,a
                        ld		hl,CargoTonnes
                        add		hl,a
                        ld		a,(hl)
                        ld		c,a
                        cp		0
                        ret		z
                        ld		a,b
                        push	bc						; push item nbr + quantity
                        MMUSelectStockTable
                        ld		hl, StockItemTable
                        call	getTableText
.ItemItemName           ld		a,(hl)
                        ld		hl, WordIdx
                        call	getTableText
                        ld		de,(inventory_cursor)
                        MMUSelectLayer1	
                        call	l1_print_at
.ItemAmount:            pop		bc						; b = item number, c = quantity
                        push	bc
                        ld		a,c
                        ld		de,txt_inventory_amount
                        call	INM_DispAtoDE
                        ld		hl,txt_inventory_amount
                        push	hl
.ZeroLoop:              ld		a,(hl)
                        cp		'0'
                        jr		nz,.NotZero
.ZeroDigit:             ld		(hl),' '
                        inc		hl
                        jr		.ZeroLoop
.NotZero:               ld		de,(inventory_cursor)
                        pop		hl
                        ld		e,inventory_amount
                        MMUSelectLayer1
                        call	l1_print_at
.ItemMeasure:	        MMUSelectStockTable
                        ld		hl, StockItemTable
                        pop		bc
                        ld		a,b
                        call	getTableText
                        add		hl,7
                        ld		a,(hl)
                        ld		hl,WordIdx
                        call	getTableText
                        ld		de,(inventory_cursor)
                        ld		e,inventory_uom
                        MMUSelectLayer1	
                        call	l1_print_at
                        ld 		a,(inventory_cursor+1)
                        add		a,8
                        ld 		(inventory_cursor+1),a
                        ret	
;----------------------------------------------------------------------------------------------------------------------------------
INM_GetCash:            ld		hl,(Cash+2)
                        ex      de,hl
                        ld      ix,(Cash)
                        ld		iy,INM_cash_amount
                        call 	INM_DispDEIXtoIY
                        push    IY
                        pop     de
                        ld      hl,INM_cash_UoM
                        ld      bc,4
                        ldir
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
draw_inventory_menu:    INCLUDE "Menus/clear_screen_inline_no_double_buffer.asm"	
                        ld      a,$08
                        ld      (MenuIdMax),a
                        MMUSelectSpriteBank    
                        call        sprite_cls_cursors  
.Drawbox:               ld		bc,$0101
                        ld		de,$BEFD
                        ld		a,$C0
                        MMUSelectLayer2
                        call	l2_draw_box
                        ld		bc,$0A01
                        ld		de,$FEC0
                        call	l2_draw_horz_line
.StaticText:	        ld		b,3
                        ld		hl,inventory_boiler_text
                        call	INM_print_boiler_text
.DisplayFuel:           call	INM_GetFuelLevel
                        ld		hl, txt_fuel_level
                        ld		a,(hl)
                        cp		'0'
                        jr		nz,.PrintFuel
.SkipLeadingZero:	    inc		hl
.PrintFuel:             ld		e,txt_status_colour
                        ld		bc,inv_fuel_position
                        MMUSelectLayer2	
                        call	l2_print_at
.DisplayCash:           call	INM_GetCash
                        ld		hl,INM_cash_amount
                        ld		e,txt_status_colour
                        ld		bc,inv_cash_position
                        MMUSelectLayer2	
                        call	l2_print_at						; now we have the correct integer
                        ld		bc,inv_cash_position
                        ld		hl,INM_cash_amount
.DisplayInventory:      ld		a,0
                        ld		hl,inventory_position
                        ld		(inventory_cursor),hl
.InvLoop:	            push	af
                        call	PrintInvItem
                        pop		af
                        inc		a
                        cp		17
                        jr		c,.InvLoop
                        ret

