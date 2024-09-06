                              ;0123456780ABCDEF
market_prices_page_marker  DB "MarketPricesPG54"
 
draw_mkt_data:          ld      a,0
                        jp      MPM_draw_market_prices_menu
draw_mkt_dataRO:        ld      a,$FF
                        jp      MPM_draw_market_prices_menu

close_mkt_data:         ret

update_mkt_data:        ld      a,(mkt_read_only_mode)
                        and     a
                        ret     nz
                        jp loop_market_menu

;----------------------------------------------------------------------------------------------------------------------------------
mkt_highlight_row:      ld      a,(mkt_selected_row)
                        ld      hl,MPM_market_data01
                        ld      d,a
                        ld      e,6
                        mul     de
                        add     hl,de
                        ld      ix,hl
                        ld      (ix+3),$BC 
                        ld		b,1
                        call	MPM_print_boiler_text
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
mkt_lowlight_row        ld      a,(mkt_selected_row)
                        ld      hl,MPM_market_data01
                        ld      d,a
                        ld      e,6
                        mul     de
                        add     hl,de
                        ld      ix,hl
                        ld      (ix+3),$FF 
                        ld		b,1
                        call	MPM_print_boiler_text
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
;---------------------------------------------------------------------------------------------------------------------------------
; prints text based on message data
MPM_print_boiler_text:      
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
                        ;inc     de
                        ;ld      hl,mkt_cargo_UoM
                        ;ld      bc,11
                       ; ldir
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; re-display market data line from boiler text with selected colour
; b holds row, c holds colour

;----------------------------------------------------------------------------------------------------------------------------------
; move quanity on line and redisplay, moves from stock to cargo (+) or from cargo to stock (-)
; b holds adjustment signed value, c holds colour to re-draw

;----------------------------------------------------------------------------------------------------------------------------------
MPM_shift_de_a_chars:   ex      de,hl               ; now adjust 
                        add     hl,a
                        ex      de,hl
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
MPM_Clear_Boiler:       ld      hl,MPM_market_txt01
DEFECTIUVE
                        ld      c,17
.WriteLoopOuter:        ld      b,36
.WriteLoopInner:        ld      d," "
                        ld      (hl),d
                        inc     hl
                        djnz    .WriteLoopInner
                        ld      b,12
                        ld      d,0
.WriteLoopInner0:       ld      (hl),d
                        inc     hl
                        djnz    .WriteLoopInner0
                        dec     c
                        jp      nz,.WriteLoopOuter
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
MPM_getCargoQtyIY:      ld		a,(iy)
                        call	Stock_DispQtyAtoDE
                        ret                             
;----------------------------------------------------------------------------------------------------------------------------------
; loads market data to boiler text
MPM_Market_To_Boiler:   ;break
                        call    MPM_Clear_Boiler
                        ld      de,MPM_market_txt01
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
                        call    MPM_shift_de_a_chars
                        push    de
                        call    copyStockStockUoMIXDE
                        pop     de
.GetPrice:              ld      a,10
                        call    MPM_shift_de_a_chars
                        push    de
                        call    getStockPriceIXtoDE
                        pop     de
                        ld      a,6
                        call    MPM_shift_de_a_chars
                        push    de
                        call    getStockQtyIX
                        pop     de
                        ld      a,4
                        call    MPM_shift_de_a_chars
                        call    MPM_getCargoQtyIY
.NextStockRow:          ld      de,8
                        add     ix,de
                        inc     iy
                        pop     de
                        ld      a,MPM_market_row_len
                        call    MPM_shift_de_a_chars
                        pop     bc
                        djnz    .readItemsLoop
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; a = buffer line to update
mkt_update_line:        ld      hl,CargoTonnes                  ; prep index to cargo hold values
                        add     hl,a
                        ld      iy,hl
                        ld      d,MPM_market_row_len            ; output bufffer for lines
                        ld      e,a
                        mul     de
                        push    af                              ; save a for later
                        ld      hl,MPM_market_txt01
                        add     hl,de
                        ld      a,29
                        add     hl,a
                        push    hl
                        ex      de,hl
                        call    getStockQtyIX
                        pop     hl
                        ld      a,4
                        add     hl,a
                        ex      de,hl
                        call    MPM_getCargoQtyIY
                        pop     af                              ; get row number back
                        ld      d,8
                        ld      e,a
                        mul     de
                        call    mkt_highlight_row
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
MPM_draw_market_prices_menu:
                        ;break
                        ld      (mkt_read_only_mode),a
                        MMUSelectLayer1
                        call	l1_cls
                        ld		a,7
                        call	l1_attr_cls_to_a
                        MMUSelectLayer2
                        call    asm_l2_double_buffer_off
                        call    l2_320_initialise
                        call    l2_320_cls
                        MMUSelectSpriteBank
                        call    sprite_cls_all
                        MMUSelectLayer2
.Drawbox:               call    l2_draw_menu_border
.StaticText:	        ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        ld		a,25
                        call	expandTokenToString
                        call	GetDigramGalaxySeed
                        ld      de,MPM_system_title
                        call    MPM_copy_str_hl_to_de
                        call    MPM_Market_To_Boiler
.DisCargo:              call    MKT_GetCargo
.DisCash:               call    MKT_GetCash
                        ld		b,23
                        ld		ix,MPM_boiler_text
                        ;break
                        call	MPM_print_boiler_text
                        ld      a,(mkt_read_only_mode)
                        and     a
                        ret     nz
.InitialHighlight:      xor     a
                        ld      (mkt_selected_row),a        ; assume on row zero
                        call    mkt_highlight_row
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
MPM_copy_str_hl_to_de:  ld      a,(hl)
                        ld      (de),a
                        inc     hl
                        inc     de
                        and     a                               ; check if we wrote a \0 if so then done
                        jp      nz,SDM_copy_str_hl_to_de
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
                        cp      StockTypeMax
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
.IsUoMTonnes:           and     a                                   ; tonnes is now UoM zero
                        jr      nz,.UnderATonne
                        ld      hl,CargoRunningLoad
                        dec     (hl)            ; We need to cosider UoM
.UnderATonne:           ld      a,(ix+2)
                        ld      d,0
                        ld      e,a
                        call    addDEtoCash
                        ; DO ADD CASH
                        ld      a,(mkt_selected_row)
                        call    mkt_update_line
                        call    MKT_GetCash
                        call    MKT_GetCargo
                        ld      ix,MPM_market_cash
                        ld      b,2
                        call    MPM_print_boiler_text
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
                        call    mkt_update_line
                        call    MKT_GetCash
                        call    MKT_GetCargo
                        ld      ix,MPM_market_cash
                        ld      b,2
                        call    MPM_print_boiler_text
                        ret
                       
;----------------------------------------------------------------------------------------------------------------------------------
mkt_read_only_mode      DB  $00
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

MPM_boiler_text:        DB 002, low 08  , high 08  , $FF, low MPM_system_name  , high MPM_system_name    
                        DB 016, low 08  , high 08  , $FF, low MPM_header1      , high MPM_header1
                        DB 024, low 08  , high 08  , $FF, low MPM_header2      , high MPM_header2 
MPM_market_cash         DB 180, low 08  , high 08  , $FF, low mkt_cash ,         high mkt_cash
MPM_market_cargo        DB 180, low 160 , high 160 , $FF, low mkt_hold_level ,   high mkt_hold_level
MPM_market_data01       DB 040, low 08  , high 08  , $FF, low MPM_market_txt01 , high MPM_market_txt01
MPM_market_data02       DB 048, low 08  , high 08  , $FF, low MPM_market_txt02 , high MPM_market_txt02
MPM_market_data03       DB 056, low 08  , high 08  , $FF, low MPM_market_txt03 , high MPM_market_txt03
MPM_market_data04       DB 064, low 08  , high 08  , $FF, low MPM_market_txt04 , high MPM_market_txt04
MPM_market_data05       DB 072, low 08  , high 08  , $FF, low MPM_market_txt05 , high MPM_market_txt05
MPM_market_data06       DB 080, low 08  , high 08  , $FF, low MPM_market_txt06 , high MPM_market_txt06
MPM_market_data07       DB 088, low 08  , high 08  , $FF, low MPM_market_txt07 , high MPM_market_txt07
MPM_market_data08       DB 096, low 08  , high 08  , $FF, low MPM_market_txt08 , high MPM_market_txt08
MPM_market_data09       DB 104, low 08  , high 08  , $FF, low MPM_market_txt09 , high MPM_market_txt09
MPM_market_data10       DB 112, low 08  , high 08  , $FF, low MPM_market_txt10 , high MPM_market_txt10
MPM_market_data11       DB 120, low 08  , high 08  , $FF, low MPM_market_txt11 , high MPM_market_txt11
MPM_market_data12       DB 128, low 08  , high 08  , $FF, low MPM_market_txt12 , high MPM_market_txt12
MPM_market_data13       DB 136, low 08  , high 08  , $FF, low MPM_market_txt13 , high MPM_market_txt13
MPM_market_data14       DB 144, low 08  , high 08  , $FF, low MPM_market_txt14 , high MPM_market_txt14
MPM_market_data15       DB 152, low 08  , high 08  , $FF, low MPM_market_txt15 , high MPM_market_txt15
MPM_market_data16       DB 160, low 08  , high 08  , $FF, low MPM_market_txt16 , high MPM_market_txt16
MPM_market_data17       DB 168, low 08  , high 08  , $FF, low MPM_market_txt17 , high MPM_market_txt17

MPM_system_name         DB "Market Data : "
MPM_system_title        DB "                ",0
MPM_header1:            DB "                      UNIT  -QUANTITY-",0
MPM_header2:            DB "PRODUCT      UoM      PRICE SALE CARGO",0
                           ;0        1         2         3             4
                           ;1234567890123456789012345678901234567  8 9 0 1 2 3 4 5 6 7 8
MPM_market_txtblank:    DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
MPM_market_txt01:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
MPM_market_row_len      EQU $ - MPM_market_txt01                                        
MPM_market_txt02:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
MPM_market_txt03:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
MPM_market_txt04:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
MPM_market_txt05:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
MPM_market_txt06:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
MPM_market_txt07:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
MPM_market_txt08:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
MPM_market_txt09:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
MPM_market_txt10:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
MPM_market_txt11:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
MPM_market_txt12:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
MPM_market_txt13:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
MPM_market_txt14:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
MPM_market_txt15:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
MPM_market_txt16:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
MPM_market_txt17:       DB "                                     ",0,0,0,0,0,0,0,0,0,0,0
MPN_market_sizeof:      EQU $ - MPM_market_txt01
MPN_mark

txt_market_amount	    DB "00.0",0
txt_market_quantity     DB "999",0
txt_market_cargo        DB "999",0
market_cursor			DB  $00
market_position			equ $2008

;market_UomOffset		equ 46
market_blank_line       DB "                                      ",0
mkt_hold_level          DB "Cargo (Tonnes): "
mkt_cargo_amount		DS 20
mkt_cargo_EoL           DB 0

mkt_cash				DB "Cash : "
mkt_cash_amount			DS 20
mkt_cash_UoM            DB " Cr       ",0
mkt_selected_row        db  0

mkt_cargo_position      equ $A848
;                           12345678901
                        