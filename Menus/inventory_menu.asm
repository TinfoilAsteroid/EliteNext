ivnentory_page_marker   DB "Inventory   PG52"  

inv_pos_row		        equ	$08
inv_fuel_pos_row		equ	$1B
inv_cash_pos_row		equ	$23
inv_stock_pos_row    	equ $33

inv_pos_col   	        equ	$0080
inv_fuel_pos_col		equ	$0030
inv_cash_pos_col		equ	$0030
inv_stock_pos_col       equ $0008
inv_stock_amt_pos_col   equ $0080
inv_stock_uom_pos_col   equ $00E0

inventory_boiler_text	DW inv_pos_col : DB inv_pos_row:      DW INM_inventory
						DW $0008       : DB inv_fuel_pos_row: DW INM_fuel
						DW $0008       : DB inv_cash_pos_row: DW INM_cash

INM_inventory 			DB "INVENTORY",0
INM_fuel				DB "Fuel:",0
INM_cash				DB "Cash:",0

txt_inventory_amount	DB "00000",0

inventory_curr_row      DB  inv_stock_pos_row

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

INM_print_boiler_text:  ld		b,3
                        ld		ix,inventory_boiler_text
.BoilerTextLoop:        push	bc			; Save Message Count loop value
                        ld		l,(ix+0)	; Get col into hl
                        ld		h,(ix+1)	; 
                        ld		b,(ix+2)	; get row into b
                        ld		e,(ix+3)	; Get text address into hl
                        ld		d,(ix+4)	; .
                        push    ix          ; save ix and prep for add via hl
                        print_msg_at_de_at_b_hl_macro txt_status_colour
                        pop     hl          ; add 5 to ix
                        ld      a,5         ; .
                        add     hl,a        ; .
                        ld      ix,hl       ; .
                        pop		bc
                        djnz	.BoilerTextLoop
                        ret

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
PrintInvItem:           ld		b,a                                 ; look up item  amount
                        ld		hl,CargoTonnes                      ; .
                        add		hl,a                                ; .
                        ld		a,(hl)                              ; .
                        ld		c,a                                 ; c = cargo amount
                        cp		0                                   ; and return if cargo dont print the line
                        ret		z
                        ld		a,b                                 ; get back current stock item position
                        push	bc						            ; push item nbr + quantity
                        MMUSelectStockTable                         ; get ready to loop through stock table
;.......................get item name text...........................                        
.ItemItemName           ld      a,(iy+StockNameOffset)              ; get name code for item
                        ld		hl, WordIdxStock                    ; now get the word text into hl
                        call	getTableText
                        ex      de,hl                               ; put the word pointer in de
                        ld      a,(inventory_curr_row)              ; get current cursor
                        MMUSelectLayer2
                        print_msg_at_de_macro txt_status_colour,  a,  inv_stock_pos_col
;.......................get amount in the cargo hold.................        
.ItemAmount:            pop		bc						            ; b = item number, c = quantity
                        push	bc                                  ; save it
                        ld		a,c                                 ; a = qty
                        ld		de,txt_inventory_amount             ; load text of number into txt_inventory_amount
                        call	INM_DispAtoDE
                        ld		hl,txt_inventory_amount             ; now blank out empty stock
.ZeroLoop:              ld		a,(hl)                              ; .
                        cp		'0'                                 ; .
                        jr		nz,.NotZero                         ; .
.ZeroDigit:             ld		(hl),' '                            ; .
                        inc		hl                                  ; .
                        jr		.ZeroLoop                           ; .
.NotZero:               ld      a,(inventory_curr_row)
                        MMUSelectLayer2
                        print_msg_macro txt_status_colour,  a,  inv_stock_amt_pos_col, txt_inventory_amount
;.......................get the unit of measure......................                        
.ItemMeasure:	        MMUSelectStockTable                       
                        pop		bc                                  ; get item number
                        ld		a,b                                 ; get unit of measure
                        ld      a,(iy+StockUoMOffset)               ; UoM Position
                        ld		hl,WordIdxUoMFull                   ; .
                        call	getTableText                        ; .
                        ex      de,hl
                        ld      a,(inventory_curr_row)
                        MMUSelectLayer2
                        print_msg_at_de_macro txt_status_colour,  a,  inv_stock_uom_pos_col
                        ld 		a,(inventory_curr_row)
                        add		a,8
                        ld 		(inventory_curr_row),a
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
draw_inventory_menu:    MMUSelectLayer1
                        call	l1_cls
                        ld		a,7
                        call	l1_attr_cls_to_a
                        MMUSelectLayer2
                        call    asm_l2_double_buffer_off    
                        call    l2_320_initialise
                        call    l2_320_cls
                        MMUSelectSpriteBank
                        call    sprite_cls_cursors
                        MMUSelectLayer2
.Drawbox:               call    l2_draw_menu_border                        
                        ld      b,$17
                        ld      hl,1
                        ld      de,320-4
                        ld      c,$C0
                        call    l2_draw_horz_line_320           ;b = row; hl = col, de = length, c = color"
                        ld      b,$2F
                        ld      hl,1
                        ld      de,320-4
                        ld      c,$C0
                        call    l2_draw_horz_line_320           ;b = row; hl = col, de = length, c = color"                        
.StaticText:	        call	INM_print_boiler_text
.DisplayFuel:           call	INM_GetFuelLevel
                        ld		hl, txt_fuel_level
                        ld		a,(hl)
                        cp		'0'
                        jr		nz,.PrintFuel
.SkipLeadingZero:	    inc		hl
.PrintFuel:             ex      de,hl
                        MMUSelectLayer2
                        print_msg_at_de_macro txt_status_colour,  inv_fuel_pos_row,  inv_fuel_pos_col
.DisplayCash:           call	INM_GetCash
                        MMUSelectLayer2	
                        print_msg_macro txt_status_colour,  inv_cash_pos_row,  inv_cash_pos_col,  INM_cash_amount
                      ;  ld		bc,inv_cash_position
                       ; ld		hl,INM_cash_amount
.DisplayInventory:      ZeroA
                        ld      iy,StockFood                ; start of the table for data 
.InvLoop:	            push	af
                        call	PrintInvItem
                        ld      hl,iy                       ; move to next row
                        ld      a,StockRowWidth
                        add     hl,a
                        ld      iy,hl
                        pop		af
                        inc		a
                        cp		17
                        jr		nz,.InvLoop
                        ret

