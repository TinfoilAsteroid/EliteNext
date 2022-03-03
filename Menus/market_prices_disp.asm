mktdisp_prices_page_marker  DB "MarketPricesPG54"    
mktdisp_boiler_text		DW $0250,TextBuffer
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


txt_mktdisp_amount	    DB "00.0",0
txt_mktdisp_quantity    DB "999",0
txt_mktdisp_cargo       DB "999",0
mktdisp_cursor			DW  $0000
mktdisp_position		equ $2008
mktdisp_uom				equ	$68
mktdisp_price 			equ $88
mktdisp_Quantity		equ	$B0
mktdisp_Cargo           equ $E0
mktdisp_UomOffset		equ 46
mktdisp_blank_line      DB "                                ",0
mktdisp_hold_level      DB "Cargo: ",0
mktdisp_cash			DB "Cash : ",0
mktdisp_selected_row    db  0

mktdisp_cash_position   equ $B048
mktdisp_cash_amount		DS 20
mktdisp_cash_UoM        DB " Cr       ",0
mktdisp_cargo_position  equ $A848
mktdisp_cargo_amount	DS 20
mktdisp_cargo_UoM       DB " Tonnes   ",0
;                           12345678901

mktdisp_DispDEIXtoIY1DP:    call    mktdisp_DispDEIXtoIY
                        ld (iy+2),0
                        ld      a,(IY+0)
                        ld      (IY+1),a
                        ld      a,"."
                        ld      (IY+0),a
                        inc     IY
                        inc     IY
                        ret
;----------------------------------------------------------------------------------------------------------------------------------	
mktdisp_DispDEIXtoIY:       ld (.MKTclcn32z),ix
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
MPD_DispHLtoDE:         ld	bc,-10000
                        call	MPD_Num1
                        ld	bc,-1000
                        call	MPD_Num1
                        ld	bc,-100
                        call	MPD_Num1
                        ld	c,-10
                        call	MPD_Num1
                        ld	c,-1
MPD_Num1:	            ld	a,'0'-1
.Num2:	                inc	a
                        add	hl,bc
                        jr	c,.Num2
                        sbc	hl,bc
                        ld	(de),a
                        inc	de
                        ret 
;----------------------------------------------------------------------------------------------------------------------------------	
MPD_DispAtoDE:          ld h,0
                        ld l,a
                        jp MPD_DispHLtoDE
;----------------------------------------------------------------------------------------------------------------------------------	
MPD_DispPriceAtoDE:     ld h,0
                        ld l,a
                        ld	bc,-100
                        call	.NumLeadBlank1
                        ld	c,-10
                        call	MPD_Num1
                        ld		a,'.'					; we could assume preformat but
                        ld		(de),a					; we can optimse that later TODO
                        inc		de						; with just an inc De
                        ld	c,-1
                        jr		MPD_Num1
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
MPD_DispQtyAtoDE:       cp	0
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
                        jr		MPD_Num1
.NotHundredsZero:       ld	c,-10
                        call	MPD_Num1
                        ld	c,-1
                        jr		MPD_Num1
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
MPD_print_boiler_text:  INCLUDE "Menus/print_boiler_text_inlineInclude.asm"
;----------------------------------------------------------------------------------------------------------------------------------
mktdisp_GetCash:            ld		hl,(Cash+2)
                        ex      de,hl
                        ld      ix,(Cash)
                        ld		iy,mktdisp_cash_amount
                        call 	mktdisp_DispDEIXtoIY1DP
                        push    IY
                        pop     de
                        ld      hl,mktdisp_cash_UoM
                        ld      bc,11
                        ldir
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
mktdisp_GetCargo:   	ld      de,0
                        ld      ix,0
                        ld      a,(CargoRunningLoad)
                        ld      ixl,a
                        ld		iy,mktdisp_cargo_amount
                        call 	mktdisp_DispDEIXtoIY
                        push    IY
                        pop     de
                        inc     de
                        ld      hl,mktdisp_cargo_UoM
                        ld      bc,11
                        ldir
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
mktdisp_DisplayCargo:   call	mktdisp_GetCargo
                        ld		hl,mktdisp_cargo_amount
                        ld      de,mktdisp_cargo_position
                        MMUSelectLayer1   
                        call	l1_print_at   
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
mktdisp_DisplayCash:        call	mktdisp_GetCash
                        ld		hl,mktdisp_cash_amount
                        ld      de,mktdisp_cash_position
                        MMUSelectLayer1   
                        call	l1_print_at   
                        ret
;----------------------------------------------------------------------------------------------------------------------------------	
; "A = stock item number"
PrintMktDispItem:       push     af
                        ld      hl,mktdisp_position
                        ld      d,a
                        ld      e,8
                        mul
                        ld      d,e
                        ld      e,0
                        add     hl,de
                        ld      (mktdisp_cursor),hl
                        ex      hl,de
                        ld      hl,mktdisp_blank_line    
                        MMUSelectLayer1   
                        call	l1_print_at
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
                        ld		de,(mktdisp_cursor)
                        MMUSelectLayer1   
                        call	l1_print_at
.GetUom                 MMUSelectStockTable   
                        ld		a,(ix+7)
                        add		a,mktdisp_UomOffset
                        ld		hl,WordIdx
                        call	getTableText
                        ld		de,(mktdisp_cursor)
                        ld		e,mktdisp_uom
                        MMUSelectLayer1    
                        call	l1_print_at
.GetPrice:              MMUSelectStockTable   
                        ld		a,(ix+2)
                        ld		de,txt_mktdisp_amount  
                        call	MPD_DispPriceAtoDE
                        ld		hl,txt_mktdisp_amount
                        ld		de,(mktdisp_cursor)
                        ld		e,mktdisp_price
                        MMUSelectLayer1    
                        call	l1_print_at	
.GetQty:                MMUSelectStockTable    
                        ld		a,(ix+1)
                        ld		de,txt_mktdisp_quantity  
                        call	MPD_DispQtyAtoDE
                        ld		hl,txt_mktdisp_quantity
                        ld		de,(mktdisp_cursor)
                        ld		e,mktdisp_Quantity
                        MMUSelectLayer1    	
                        call	l1_print_at	
.GetCargoQty:           ld      a,(iy+0)
                        ld      de,txt_mktdisp_cargo
                        call	MPD_DispQtyAtoDE
                        ld      hl,txt_mktdisp_cargo
                        ld      de,(mktdisp_cursor)
                        ld      e,mktdisp_Cargo
                        MMUSelectLayer1    	
                        call	l1_print_at	
                        ret

draw_mktdisp_prices_menu:InitNoDoubleBuffer
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
                        ld		hl,mktdisp_boiler_text
                        call	MPD_print_boiler_text
.DisplayPrices:         ld		a,0
                        ld		hl,mktdisp_position
                        ld		(mktdisp_cursor),hl
.MarketLoop:	        push	af
                        call	PrintMktDispItem
                        pop		af
                        inc		a
                        cp		17
                        jr		nz,.MarketLoop
.DisCargo:              ld      hl,mktdisp_hold_level
                        ld      de,$A810
                        MMUSelectLayer1
                        call	l1_print_at
                        call    mktdisp_DisplayCargo
.DisCash:               ld      hl,mktdisp_cash
                        ld      de,$B010
                        MMUSelectLayer1
                        call	l1_print_at
                        call    mktdisp_DisplayCash
                        ret


