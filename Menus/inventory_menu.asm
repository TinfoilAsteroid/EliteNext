ivnentory_page_marker   DB "Inventory   PG52"  

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
                        
;---------------------------------------------------------------------------------------------------------------------------------
; prints text based on message data
INM_print_boiler_text:      
.BoilerTextLoop:        push        bc          ; Save Message Count loop value
                        ld          b,(ix+0)    ; get row into b
                        ld          de,(ix+1)   ; get column into hl (as we can't load direct to hl from ix)
                        ex          de,hl       ;
                        ld          c,(ix+3)    ; c = colour
                        ld          de,(ix+4)   ; de = address of message
                        push        ix
                        MMUSelectLayer2
                        call        l2_print_at_320
                        pop         hl          ; move ix on to next string if needed
                        ld          a,6         ;
                        add         hl,a        ;
                        ld          ix,hl       ;
                        pop         bc          ; remainder of lines in loop
                        djnz        .BoilerTextLoop
                        ret
;---------------------------------------------------------------------------------------------------------------------------------
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
;----------------------------------------------------------------------------------------------------------------------------------
INM_GetFuelLevel:       ld		a,(Fuel)
                        ld		de,INM_fuel_level
                        ld	c, -100
                        call	.Num1
                        ld	c,-10
                        call	.Num1
                        ld	c,-1
.Num1:	                ld	b,'0'-1
.Num2:	                inc		b
                        add		a,c
                        jr		c,.Num2
                        sub 	c
                        push	bc
                        push	af
                        ld		a,c
                        cp		-1
                        call	z,.InsertDot
                        ld		a,b
                        ld		(de),a
                        inc		de
                        pop		af
                        pop		bc
                        ret 
.InsertDot:             ld		a,'.'
                        ld		(de),a
                        inc		de
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
INM_shift_de_a_chars:   ex      de,hl               ; now adjust 
                        add     hl,a
                        ex      de,hl
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
INM_Clear_Boiler:       ld      hl,INM_market_txt01
                        ld      c,17
.WriteLoopOuter:        ld      b,INM_market_txt_len -1
.WriteLoopInner:        ld      d," "
                        ld      (hl),d
                        inc     hl
                        djnz    .WriteLoopInner
                        ld      b,INM_market_txt_nulls+1
.WriteNullsLoop:        ld      d,0
                        ld      (hl),0
                        inc     hl
                        djnz    .WriteNullsLoop
                        dec     c
                        
                        jp      nz,.WriteLoopOuter
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
INM_getCargoQtyIY:      ld		a,(iy)
                        call	Stock_DispQtyAtoDE
                        ret   
;----------------------------------------------------------------------------------------------------------------------------------
; loads market data to boiler text
INM_Market_To_Boiler:   ld      de,INM_market_txt01
                        MMUSelectStockTable
                        ld		ix,StockFood		; start 8 bytes before index as first add will shift
                        ld      iy,CargoTonnes      ; amount in hold
                        ld      b,17
.readItemsLoop:         push    bc
.GetName:               MMUSelectStockTable
                        push    de,,de              ; save for outer loop too
                        call    copyStockItemNameIXDE
                        pop     de                        
.GetUoM:                ld      a,13
                        call    INM_shift_de_a_chars
                        push    de
                        call    copyStockStockUoMIXDE
                        pop     de
.GetPrice:              ld      a,10
                        call    INM_shift_de_a_chars
                        call    INM_getCargoQtyIY
.NextStockRow:          ld      de,8
                        add     ix,de
                        inc     iy
                        pop     de
                        ld      a,INM_market_row_len
                        call    INM_shift_de_a_chars
                        pop     bc
                        djnz    .readItemsLoop
                        ret
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
draw_inv_menu:
draw_inventory_menu:    MMUSelectLayer1
                        call	l1_cls
                        ld		a,7
                        call	l1_attr_cls_to_a
                        MMUSelectLayer2
                        call    asm_l2_double_buffer_off    
                        call    l2_320_initialise
                        call    l2_320_cls
                        MMUSelectSpriteBank
                        call    sprite_cls_all; sprite_cls_cursors
                        MMUSelectLayer2
.Drawbox:               call    l2_draw_menu_border                        
.DisplayFuel:           call	INM_GetFuelLevel
.DisplayCash:           call	INM_GetCash
.DisplayInventory:      call    INM_Market_To_Boiler
                        ld      b,3+17
                        ld      ix,inventory_boiler_text
.StaticText:	        call	INM_print_boiler_text
                        ret

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



txt_inventory_amount	DB "00000",0

inventory_curr_row      DB  inv_stock_pos_row

inventory_amount		equ $80
inventory_uom			equ	$B0
inv_selected_row        DB 0


inventory_boiler_text	DB 002, low $0080 , high $0080, $FF, low INM_inventory , high INM_inventory
						DB 012, low $0008 , high $0008, $FF, low INM_fuel      , high INM_fuel
						DB 020, low $0008 , high $0008, $FF, low INM_cash      , high INM_cash

INM_market_data01       DB 040, low 08  , high 08  , $FF, low INM_market_txt01 , high INM_market_txt01
INM_market_data02       DB 048, low 08  , high 08  , $FF, low INM_market_txt02 , high INM_market_txt02
INM_market_data03       DB 056, low 08  , high 08  , $FF, low INM_market_txt03 , high INM_market_txt03
INM_market_data04       DB 064, low 08  , high 08  , $FF, low INM_market_txt04 , high INM_market_txt04
INM_market_data05       DB 072, low 08  , high 08  , $FF, low INM_market_txt05 , high INM_market_txt05
INM_market_data06       DB 080, low 08  , high 08  , $FF, low INM_market_txt06 , high INM_market_txt06
INM_market_data07       DB 088, low 08  , high 08  , $FF, low INM_market_txt07 , high INM_market_txt07
INM_market_data08       DB 096, low 08  , high 08  , $FF, low INM_market_txt08 , high INM_market_txt08
INM_market_data09       DB 104, low 08  , high 08  , $FF, low INM_market_txt09 , high INM_market_txt09
INM_market_data10       DB 112, low 08  , high 08  , $FF, low INM_market_txt10 , high INM_market_txt10
INM_market_data11       DB 120, low 08  , high 08  , $FF, low INM_market_txt11 , high INM_market_txt11
INM_market_data12       DB 128, low 08  , high 08  , $FF, low INM_market_txt12 , high INM_market_txt12
INM_market_data13       DB 136, low 08  , high 08  , $FF, low INM_market_txt13 , high INM_market_txt13
INM_market_data14       DB 144, low 08  , high 08  , $FF, low INM_market_txt14 , high INM_market_txt14
INM_market_data15       DB 152, low 08  , high 08  , $FF, low INM_market_txt15 , high INM_market_txt15
INM_market_data16       DB 160, low 08  , high 08  , $FF, low INM_market_txt16 , high INM_market_txt16
INM_market_data17       DB 168, low 08  , high 08  , $FF, low INM_market_txt17 , high INM_market_txt17

INM_inventory 			DB "INVENTORY",0
INM_fuel				DB "Fuel:"
INM_fuel_level          DS 20,0
INM_cash				DB "Cash:"
INM_cash_amount			DS 10," "
INM_cash_UoM            DB " Cr",0

                           ;1234567890123456789012345678901234567  8 9 0 1 2 3 4 5 6 7 8
INM_market_txtblank:    DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
INM_market_txt01:       DB "                                     "
INM_market_txt_len      EQU $ - INM_market_txt01
INM_market_txt_null     DB 0,0,0,0,0,0,0,0,0,0,0
INM_market_txt_nulls    EQU $ - INM_market_txt_null  
INM_market_row_len      EQU $ - INM_market_txt01                                        
INM_market_txt02:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
INM_market_txt03:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
INM_market_txt04:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
INM_market_txt05:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
INM_market_txt06:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
INM_market_txt07:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
INM_market_txt08:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
INM_market_txt09:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
INM_market_txt10:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
INM_market_txt11:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
INM_market_txt12:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
INM_market_txt13:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
INM_market_txt14:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
INM_market_txt15:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
INM_market_txt16:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
INM_market_txt17:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
INV_market_sizeof:      EQU $ - INM_market_txt01

