market_prices_page_marker  DB "MarketPricesPG54"    
market_boiler_text		DW $0250,TextBuffer
						DW $0220,name_expanded
						DW $0B80,WordUnit
						DW $0BB0,WordQuantity
						DW $1308,WordProduct
						DW $1360,WordUoM
						DW $1380,WordPrice
						DW $13B0,WordStock
						DW $13E0,WordInv
						
;char name[16];
;current_quantity;
;current_price;
;base_price;
;eco_adjust;
;base_quantity;
;mask;
;units;


txt_market_amount	    DB "00.0",0
txt_market_quantity     DB "999",0
txt_market_cargo        DB "999",0
market_cursor			DW  $0000
market_position			equ $2008
market_uom				equ	$68
market_price 			equ $88
market_Quantity			equ	$B0
market_Cargo            equ $E0
market_UomOffset		equ 46
market_blank_line       DB "                                ",0
mkt_hold_level          DB "Cargo: ",0
mkt_cash				DB "Cash : ",0
mkt_selected_row        db  0

mkt_cash_position       equ $B048
mkt_cash_amount			DS 20
mkt_cash_UoM            DB " Cr       ",0
mkt_cargo_position      equ $A848
mkt_cargo_amount		DS 20
mkt_cargo_UoM           DB " Tonnes   ",0
;                           12345678901

;----------------------------------------------------------------------------------------------------------------------------------	
mkt_highlight_row:      ld      a,(mkt_selected_row)
                        add     a,4
                        ld      d,a
                        ld      e,L1InvHighlight
                        MMUSelectLayer1
                        call    l1_hilight_row
                        ret
;----------------------------------------------------------------------------------------------------------------------------------	
mkt_lowlight_row        ld      a,(mkt_selected_row)
                        add     a,4
                        ld      d,a
                        ld      e,L1InvLowlight
                        MMUSelectLayer1
                        call    l1_hilight_row
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
MPM_print_boiler_text:  INCLUDE "Menus/print_boiler_text_inlineInclude.asm"
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
                        ld		hl,mkt_cargo_amount
                        ld      de,mkt_cargo_position
                        MMUSelectLayer1   
                        call	l1_print_at   
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
MKT_DisplayCash:        call	MKT_GetCash
                        ld		hl,mkt_cash_amount
                        ld      de,mkt_cash_position
                        MMUSelectLayer1   
                        call	l1_print_at   
                        ret
;----------------------------------------------------------------------------------------------------------------------------------	
; "A = stock item number"
PrintMarketItem:        push     af
                        ld      hl,market_position  ; hl = base cursor position + row number * 8 
                        ld      d,a                 ; .
                        ld      e,8                 ; . 
                        mul                         ; .
                        ld      d,e                 ; .
                        ld      e,0                 ; .
                        add     hl,de               ; .
                        ld      (market_cursor),hl  ; save in market cursor and copy to de
                        ex      hl,de               ; .
                        ld      hl,market_blank_line; hl = blank line text 
                        MMUSelectLayer1             ; print blank line (hl) and position DE
                        call	l1_print_at         ; .
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
                        ld		a,(ix+0)
                        ld		hl,WordIdx
                        call	getTableText
                        ld		de,(market_cursor)
                        MMUSelectLayer1   
                        call	l1_print_at
.GetUom                 MMUSelectStockTable   
                        ld		a,(ix+7)
                        add		a,market_UomOffset
                        ld		hl,WordIdx
                        call	getTableText
                        ld		de,(market_cursor)
                        ld		e,market_uom
                        MMUSelectLayer1    
                        call	l1_print_at
.GetPrice:              MMUSelectStockTable   
                        ld		a,(ix+2)
                        ld		de,txt_market_amount  
                        call	MPM_DispPriceAtoDE
                        ld		hl,txt_market_amount
                        ld		de,(market_cursor)
                        ld		e,market_price
                        MMUSelectLayer1    
                        call	l1_print_at	
.GetQty:                MMUSelectStockTable    
                        ld		a,(ix+1)
                        ld		de,txt_market_quantity  
                        call	MPM_DispQtyAtoDE
                        ld		hl,txt_market_quantity
                        ld		de,(market_cursor)
                        ld		e,market_Quantity
                        MMUSelectLayer1    	
                        call	l1_print_at	
.GetCargoQty:           ld      a,(iy+0)
                        ld      de,txt_market_cargo
                        call	MPM_DispQtyAtoDE
                        ld      hl,txt_market_cargo
                        ld      de,(market_cursor)
                        ld      e,market_Cargo
                        MMUSelectLayer1    	
                        call	l1_print_at	
                        ret

draw_market_prices_menu:InitNoDoubleBuffer
                        ld      a,$20
                        ld      (MenuIdMax),a
.Drawbox:               ld		bc,$0101
                        ld		de,$BEFD
                        ld		a,$C0
                        MMUSelectLayer2
                        call	l2_draw_box
                        ld		bc,$0A01
                        ld		de,$FEC0
                        call	l2_draw_horz_line                        
.DrawProductLine        ld		bc,$1A08
                        ld		de,$50C0
                        call	l2_draw_horz_line
.DrawUoMLine:           ld		bc,$1A60
                        ld		de,$18C0
                        call	l2_draw_horz_line
.DrawPriceLine:         ld		bc,$1A80
                        ld		de,$28C0
                        call	l2_draw_horz_line
.DrawStockLine:         ld		bc,$1AB0
                        ld		de,$28C0
                        call	l2_draw_horz_line
.DrawInvLine:           ld		bc,$1AE0
                        ld		de,$18C0
                        call	l2_draw_horz_line
.StaticText:	        ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        ld		a,25
                        call	expandTokenToString
                        call	GetDigramGalaxySeed
                        ld		b,9
                        ld		hl,market_boiler_text
                        call	MPM_print_boiler_text
; Generate the market list on screen                        
.DisplayPrices:         ld		a,0
                        ld		hl,market_position          ; set current cursor position on screen
                        ld		(market_cursor),hl          ; .
MarketLoop:	            push	af
                        call	PrintMarketItem             ; display a single market item
                        pop		af
                        inc		a
                        cp		17
                        jr		nz,MarketLoop
.InitialHighlight:      xor     a
                        ld      (mkt_selected_row),a        ; assume on row zero
                        call    mkt_highlight_row
.DisCargo:              ld      hl,mkt_hold_level
                        ld      de,$A810
                        MMUSelectLayer1
                        call	l1_print_at
                        call    MKT_DisplayCargo
.DisCash:               ld      hl,mkt_cash
                        ld      de,$B010
                        MMUSelectLayer1
                        call	l1_print_at
                        call    MKT_DisplayCash
                        ret


;----------------------------------------------------------------------------------------------------------------------------------
; Handles all the input whilst in the market menu
loop_market_menu:       ld      a,c_Pressed_CursorUp  
                        call    is_key_pressed
                        call    z,mkt_UpPressed
                        ld      a,c_Pressed_CursorDown
                        call    is_key_pressed
                        call    z,mkt_DownPressed
                        ld      a,c_Pressed_RollLeft
                        call    is_key_pressed
                        call    z,mkt_LeftPressed
                        ld      a,c_Pressed_RollRight
                        call    is_key_pressed
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
                        call    get_key_a_state
                        cp      1
                        jr      z,.ItsOK
.ItsOK:                 ld      a,(mkt_selected_row)
                        cp      16
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
.CheckCash:             ld      hl,(Cash+2)
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
                        ld      b,a
                        cp      48
                        jr      nz,.UnderOneTonne
                        ld      a,b
                        ld      hl,CargoRunningLoad
                        inc     (hl)                          
.UnderOneTonne:         ld      a,(ix+2)
                        ld      d,0
                        ld      e,a
                        call    subDEfromCash
                        ld      a,(mkt_selected_row)
                        call    PrintMarketItem
                        call    MKT_DisplayCargo
                        call    MKT_DisplayCash
                        ret