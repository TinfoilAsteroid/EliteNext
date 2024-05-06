market_prices_page_marker  DB "MarketPricesPG54"

mkt_boiler_unit_col     equ $80
mkt_boiler_qty_col      equ $D0
mkt_boiler_product_col  equ $08
mkt_boiler_uom_col      equ $70
mkt_boiler_price_col    equ $C0
mkt_boiler_stock_col    equ $F0
mkt_boiler_inv_col      equ $0120

mkt_cash_pos_row        equ $D0
mkt_cargo_pos_row       equ $C0
market_cash_pos_row     equ $D0
market_cargo_pos_row    equ $C0
market_top_row          equ $20

mkt_cash_pos_col        equ $0010
mkt_cargo_pos_col       equ $0010                        
market_cash_pos_col     equ $0048
market_cargo_pos_col    equ $0048
market_uom_col			equ	mkt_boiler_uom_col
market_price_col        equ mkt_boiler_price_col + 8
market_quantity_col 	equ	mkt_boiler_stock_col + $10
market_cargo_col        equ mkt_boiler_inv_col

market_boiler_text		DW $0050                 : DB $02               : DW TextBuffer
						DW $0020                 : DB $02               : DW name_expanded					
						DW mkt_boiler_product_col: DB $13               : DW WordProduct
						DW mkt_boiler_uom_col    : DB $13               : DW WordUoM
						DW mkt_boiler_price_col  : DB $13               : DW WordPrice
						DW mkt_boiler_stock_col  : DB $13               : DW WordStock
						DW mkt_boiler_inv_col    : DB $13               : DW WordInv
                        DW mkt_cargo_pos_col     : DB mkt_cargo_pos_row : DW mkt_hold_level
                        DW mkt_cash_pos_col      : DB mkt_cash_pos_row  : DW mkt_cash



txt_market_amount	    DB "00.0",0
txt_market_quantity     DB "999",0
txt_market_cargo        DB "999",0
market_cursor			DB  $00
market_position			equ $2008

;market_UomOffset		equ 46
market_blank_line       DB "                                      ",0
mkt_hold_level          DB "Cargo: ",0
mkt_cash				DB "Cash : ",0
mkt_selected_row        db  0

mkt_cash_amount			DS 20
mkt_cash_UoM            DB " Cr       ",0
mkt_cargo_position      equ $A848
mkt_cargo_amount		DS 20
mkt_cargo_UoM           DB " Tonnes   ",0
;                           12345678901

;----------------------------------------------------------------------------------------------------------------------------------
mkt_highlight_row:      ld      a,(mkt_selected_row)
                        call    PrintMartetItemHigh
                        ret



;----------------------------------------------------------------------------------------------------------------------------------
mkt_lowlight_row        ld      a,(mkt_selected_row)
                        call    PrintMarketItemDefault
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
MKT_DispDEIXtoIY1DP:    call    MKT_DispDEIXtoIY
                        ld (iy+2),0
                        ld      a,(IY+0)
                        ld      (IY+1),a
                        ld      a,"."
                        ld      (IY+0),a
                        inc     IY
                        inc     IY
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
MKT_DispDEIXtoIY:       ld (.MKTclcn32z),ix
                        ld (.MKTclcn32zIX),de
                        ld ix,.MKTclcn32t+36
                        ld b,9
                        ld c,0
.MKTclcn321:            ld a,'0'
                        or a
.MKTclcn322:            ld e,(ix+0)
                        ld d,(ix+1)
                        ld hl,(.MKTclcn32z)
                        sbc hl,de
                        ld (.MKTclcn32z),hl
                        ld e,(ix+2)
                        ld d,(ix+3)
                        ld hl,(.MKTclcn32zIX)
                        sbc hl,de
                        ld (.MKTclcn32zIX),hl
                        jr c,.MKTclcn325
                        inc c
                        inc a
                        jr .MKTclcn322
.MKTclcn325:            ld e,(ix+0)
                        ld d,(ix+1)
                        ld hl,(.MKTclcn32z)
                        add hl,de
                        ld (.MKTclcn32z),hl
                        ld e,(ix+2)
                        ld d,(ix+3)
                        ld hl,(.MKTclcn32zIX)
                        adc hl,de
                        ld (.MKTclcn32zIX),hl
                        ld de,-4
                        add ix,de
                        inc c
                        dec c
                        jr z,.MKTclcn323
                        ld (iy+0),a
                        inc iy
.MKTclcn323:            djnz .MKTclcn321
                        ld a,(.MKTclcn32z)
                        add A,'0'
                        ld (iy+0),a
                        ld (iy+1),0
                        ret
.MKTclcn32t             dw 1,0,     10,0,     100,0,     1000,0,       10000,0
                        dw $86a0,1, $4240,$0f, $9680,$98, $e100,$05f5, $ca00,$3b9a
.MKTclcn32z             ds 2
.MKTclcn32zIX           ds 2
;----------------------------------------------------------------------------------------------------------------------------------
; "DispHL, writes HL to DE address"
MPM_DispHLtoDE:         ld	bc,-10000
                        call	MPM_Num1
                        ld	bc,-1000
                        call	MPM_Num1
                        ld	bc,-100
                        call	MPM_Num1
                        ld	c,-10
                        call	MPM_Num1
                        ld	c,-1
MPM_Num1:	            ld	a,'0'-1
.Num2:	                inc	a
                        add	hl,bc
                        jr	c,.Num2
                        sbc	hl,bc
                        ld	(de),a
                        inc	de
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
MPM_DispAtoDE:          ld h,0
                        ld l,a
                        jp MPM_DispHLtoDE
;----------------------------------------------------------------------------------------------------------------------------------
MPM_DispPriceAtoDE:     ld h,0
                        ld l,a
                        ld	bc,-100
                        call	.NumLeadBlank1
                        ld	c,-10
                        call	MPM_Num1
                        ld		a,'.'					; we could assume preformat but
                                    DISPLAY "TODO: optimise"
                        ld		(de),a					; we can optimse that later TODO
                        inc		de						; with just an inc De
                        ld	c,-1
                        jr		MPM_Num1
.NumLeadBlank1:	        ld	a,'0'-1
.NumLeadBlank2:	        inc	a
                        add	hl,bc
                        jr	c,.NumLeadBlank2
                        cp	'0'
                        jr	nz,.DontBlank
.Blank:                 ld	a,' '
.DontBlank:	            sbc	hl,bc
                        ld	(de),a
                        inc	de
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
MPM_DispQtyAtoDE:       cp	0
                        jr	z,.NoStock
                        ld h,0
                        ld l,a
                        ld	bc,-100
                        call	.NumLeadBlank1
.WasLead0:              cp      ' '
                        jr      nz,.NotHundredsZero
                        ld	c,-10
                        call	.NumLeadBlank1
                        ld	c,-1
                        jr		MPM_Num1
.NotHundredsZero:       ld	c,-10
                        call	MPM_Num1
                        ld	c,-1
                        jr		MPM_Num1
.NumLeadBlank1:	        ld	a,'0'-1
.NumLeadBlank2:	        inc	a
                        add	hl,bc
                        jr	c,.NumLeadBlank2
                        cp	'0'
                        jr	nz,.DontBlank
.Blank:                 ld	a,' '
.DontBlank:	            sbc	hl,bc
                        ld	(de),a
                        inc	de
                        ret
.NoStock:               ld	a,' '
                        ld	(de),a
                        inc	de
                        ld	(de),a
                        inc	de
                        ld	a,'-'
                        ld	(de),a
                        inc de
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
MPM_print_boiler_text:  ld		b,9
                        ld		ix,market_boiler_text
.BoilerTextLoop:        push	bc			; Save Message Count loop value
                        ld		l,(ix+0)	; Get col into hl
                        ld		h,(ix+1)	;
                        ld		b,(ix+2)	; get row into b
                        ld		e,(ix+3)	; Get text address into hl
                        ld		d,(ix+4)	; .
                        push    ix          ; save ix and prep for add via hl
                        MMUSelectLayer2
                        print_msg_at_de_at_b_hl_macro txt_status_colour
                        pop     hl          ; add 5 to ix
                        ld      a,5         ; .
                        add     hl,a        ; .
                        ld      ix,hl       ; .
                        pop		bc
                        djnz	.BoilerTextLoop
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
MKT_GetCash:            ld		hl,(Cash+2)
                        ex      de,hl
                        ld      ix,(Cash)
                        ld		iy,mkt_cash_amount
                        call 	MKT_DispDEIXtoIY1DP
                        push    IY
                        pop     de
                        ld      hl,mkt_cash_UoM
                        ld      bc,11
                        ldir
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
MKT_GetCargo:   	    ld      de,0
                        ld      ix,0
                        ld      a,(CargoRunningLoad)
                        ld      ixl,a
                        ld		iy,mkt_cargo_amount
                        call 	MKT_DispDEIXtoIY
                        push    IY
                        pop     de
                        inc     de
                        ld      hl,mkt_cargo_UoM
                        ld      bc,11
                        ldir
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
MKT_DisplayCargo:       call	MKT_GetCargo
                        MMUSelectLayer2
                        print_msg_macro txt_status_colour,  market_cargo_pos_row,  market_cargo_pos_col,  mkt_cargo_amount
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
MKT_DisplayCash:        call	MKT_GetCash
                        MMUSelectLayer2
                        print_msg_macro txt_status_colour,  market_cash_pos_row,  market_cash_pos_col,  mkt_cash_amount
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; "A = stock item number"
; These must be in this order so that the print macro can load into bc
PrintMarketColour:      DB 0
PrintMarketRow:         DB 0
PrintMartetItemHigh:    ex      af,af'
                        ld      a,txt_highlight_colour
                        ld      (PrintMarketColour),a
                        ex      af,af'
                        jp      PrintMarketItem
PrintMarketItemDefault: ex      af,af'
                        ld      a,txt_status_colour
                        ld      (PrintMarketColour),a
                        ex      af,af'
PrintMarketItem:        push    af
                        ld      d,a                 ; .
                        ld      e,8                 ; .
                        mul     de                  ; .   
                        ld      a,market_top_row   ; hl = base cursor position + row number * 8
                        add     a,e
                        ld      (PrintMarketRow),a
                        ld      bc,(PrintMarketColour)  ; loads b with row, c with color
                        MMUSelectLayer2
                        print_msg_ld_bc_macro $08, market_blank_line    ; Optimise later to have a specific blank line function
                        pop     af
                        ld		ix,StockFood		; start 8 bytes before index as first add will shift
                        ld      iy,CargoTonnes
                        ld		e,8
                        ld		d,a
                        mul
                        add		ix,de				; Move down a row ix += a * 8
                        ld      d,0
                        ld      e,a
                        add     iy,de                ; cargo table is just 1 byte per item
.GetName:               MMUSelectStockTable
                        ld		a,(ix+StockNameOffset)
                        ld		hl,WordIdxStock
                        call	getTableText
                        ex      de,hl
                        push    ix
                        ld      bc,(PrintMarketColour)  ; loads b with row, c with color
                        MMUSelectLayer2
                        print_msg_ld_bc_at_de_macro  $08
                        pop     ix
.GetUom                 MMUSelectStockTable
                        ld		a,(ix+StockUoMOffset)
                        ld		hl,WordIdxUoMFull
                        call	getTableText
                        ex      de,hl
                        push    ix
                        ld      bc,(PrintMarketColour)  ; loads b with row, c with color
                        MMUSelectLayer2
                        print_msg_ld_bc_at_de_macro market_uom_col
                        pop     ix
.GetPrice:              MMUSelectStockTable
                        ld		a,(ix+StockPriceOffset)
                        ld		de,txt_market_amount
                        call	MPM_DispPriceAtoDE
                        push    ix
                        ld      bc,(PrintMarketColour)  ; loads b with row, c with color
                        MMUSelectLayer2
                        print_msg_ld_bc_macro market_price_col, txt_market_amount
                        pop     ix
.GetQty:                MMUSelectStockTable
                        ld		a,(ix+StockQtyOffset)
                        ld		de,txt_market_quantity
                        call	MPM_DispQtyAtoDE
                        ld      bc,(PrintMarketColour)  ; loads b with row, c with color
                        MMUSelectLayer2
                        print_msg_ld_bc_macro market_quantity_col, txt_market_quantity
.GetCargoQty:           ld      a,(iy+0)
                        ld      de,txt_market_cargo
                        call	MPM_DispQtyAtoDE
                        ld      bc,(PrintMarketColour)  ; loads b with row, c with color
                        MMUSelectLayer2
                        print_msg_ld_bc_macro market_cargo_col, txt_market_cargo                      
                        ret

draw_market_prices_menu:MMUSelectLayer1
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
                        ld		bc,$0AC0 
                        ld      hl,$0001
                        ld		de,320-4
                        call	l2_draw_horz_line_320       ;b = row; hl = col, de = length, c = color"
.DrawProductLine        ld		bc,$1DC0
                        ld      hl,mkt_boiler_product_col
                        ld		de,8*12
                        call	l2_draw_horz_line_320       ;b = row; hl = col, de = length, c = color"
.DrawUoMLine:           ld		bc,$1DC0
                        ld      hl,mkt_boiler_uom_col
                        ld		de,(8*9)-1
                        call	l2_draw_horz_line_320       ;b = row; hl = col, de = length, c = color"
.DrawPriceLine:         ld		bc,$1DC0
                        ld      hl,mkt_boiler_price_col
                        ld		de,8*5
                        call	l2_draw_horz_line_320       ;b = row; hl = col, de = length, c = color"
.DrawStockLine:         ld		bc,$1DC0
                        ld      hl,mkt_boiler_stock_col
                        ld		de,8*5
                        call	l2_draw_horz_line_320       ;b = row; hl = col, de = length, c = color"
.DrawInvLine:           ld		bc,$1DC0
                        ld      hl,mkt_boiler_inv_col
                        ld		de,8*3
                        call	l2_draw_horz_line_320       ;b = row; hl = col, de = length, c = color"
.StaticText:	        ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        ld		a,25
                        call	expandTokenToString
                        call	GetDigramGalaxySeed
                        call	MPM_print_boiler_text
; Generate the market list on screen
.DisplayPrices:         ZeroA
                        ld		hl,market_position          ; set current cursor position on screen
                        ld		(market_cursor),hl          ; .
MarketLoop:	            push	af
                        call	PrintMarketItemDefault     ; display a single market item
                        pop		af
                        inc		a
                        cp		StockTypeMax
                        jr		nz,MarketLoop
.InitialHighlight:      xor     a
                        ld      (mkt_selected_row),a        ; assume on row zero
                        call    mkt_highlight_row
.DisCargo:              call    MKT_DisplayCargo
.DisCash:               call    MKT_DisplayCash
                        ret


;----------------------------------------------------------------------------------------------------------------------------------
; Handles all the input whilst in the market menu
loop_market_menu:       MacroIsKeyPressed c_Pressed_CursorUp
                        call    z,mkt_UpPressed
                        MacroIsKeyPressed c_Pressed_CursorDown
                        call    z,mkt_DownPressed
                        MacroIsKeyPressed c_Pressed_RollLeft
                        call    z,mkt_LeftPressed
                        MacroIsKeyPressed c_Pressed_RollRight
                        call    z,mkt_RightPressed
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
mkt_UpPressed:          ld      a,(mkt_selected_row)
                        cp      0
                        ret     z
                        call    mkt_lowlight_row
                        ld      hl,mkt_selected_row
                        dec     (hl)
                        call    mkt_highlight_row
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
mkt_DownPressed:        ld      a,c_Pressed_CursorDown
                        MMUSelectKeyboard
                        call    get_key_a_state
                        cp      1
                        jr      z,.ItsOK
.ItsOK:                 ld      a,(mkt_selected_row)
                        cp      StockTypePenultimate
                        ret     z
                        call    mkt_lowlight_row
                        ld      hl,mkt_selected_row
                        inc     (hl)
                        call    mkt_highlight_row
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
mkt_LeftPressed:        ld      a,(mkt_selected_row)
                        ld      hl,CargoTonnes
                        add     hl,a
                        ld      a,(hl)
                        cp      0
                        ret     z
                        dec     (hl)
                        ld      ix,StockFood
                        ld      a,(mkt_selected_row)
                        ld      d,8
                        ld      e,a
                        mul
                        add     ix,de
                        MMUSelectStockTable
                        inc     (ix+1)
                        ld      a,(ix+7)
                        cp      48
                        jr      nz,.UnderATonne
                        ld      hl,CargoRunningLoad
                        dec     (hl)            ; We need to cosider UoM
.UnderATonne:           ld      a,(ix+2)
                        ld      d,0
                        ld      e,a
                        call    addDEtoCash
                        ; DO ADD CASH
                        ld      a,(mkt_selected_row)
                        call    PrintMarketItem
                        call    MKT_DisplayCargo
                        call    MKT_DisplayCash
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
mkt_RightPressed:       MMUSelectStockTable
                        ld      ix,StockFood
                        ld      a,(mkt_selected_row)
                        ld      d,8
                        ld      e,a
                        mul
                        add     ix,de
                        ld      c,a
                        ld      a,(ix+1)
                        cp      0
                        ret     z
.CheckUoM:              ld      a,(ix+7)
                        cp      48
                        jr      z,.CheckCargo                       ; cargo is in tonnes
.NotTonnage:            ld      a,(mkt_selected_row)
                        ld      hl,CargoTonnes
                        add     hl,a
                        ld      a,(hl)
                        cp      200
                        ret     z                                   ; else its a 200 UoM limit
                        jp      .CheckCash
.CheckCargo:            ld      hl,(CargoBaySize)                   ; = h = runningload l = cargo bay size
                        ld      a,h
                        cp      l
                        ret     z                                   ; return if we have already maxed out
.CheckCash:             ld      hl,(Cash+2)                         ; Check sufficient money
                        ld      a,h
                        or      l
                        jr      nz,.MoreThanRequired
                        ld      hl,(Cash)
                        ld      a,h
                        cp      0
                        jr      nz,.MoreThanRequired
                        ld      a,(ix+2)
                        cp      l
                        jr      nc,.MoreThanRequired
                        ret                         ; Insufficient Funds
.MoreThanRequired:      add     hl,de                               
                        ld      a,h
                        or      e
                        ; check cash can we buy, and cargo capacity
                        dec     (ix+1)
                        ld      a,(mkt_selected_row)
                        ld      hl,CargoTonnes
                        add     hl,a
                        inc     (hl)
                        ld      a,(ix+7)
.IsUoMTonnes:           and     a                                   ; tonnes is now UoM zero
                        jr      nz,.UnderOneTonne
                        ld      hl,CargoRunningLoad                 ; just update the current tonnage
                        inc     (hl)
.UnderOneTonne:         ld      a,(ix+2)                            ; if its under one tonne we can update
                        ld      d,0
                        ld      e,a
                        call    subDEfromCash
                        ld      a,(mkt_selected_row)
                        call    PrintMarketItem
                        call    MKT_DisplayCargo
                        call    MKT_DisplayCash
                        ret