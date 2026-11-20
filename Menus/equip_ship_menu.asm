eqshp_prices_page_marker  DB "EquipShipPG63"
; 320 x 256 single buffered, as the other menus (it was 256 x 192 with Layer 1 text and attribute highlights).
; Boiler text: row, column (16 bit), colour, message (as the market screen's MPM_boiler_text)
eqshp_TextColour        equ $FF
eqshp_HighColour        equ $BC                     ; the selected row (as the market)
eqshp_TextCol           equ 8
eqshp_ListTop           equ 24                      ; pixel row of the first list row
eqshp_ListRows          equ 18
eqshp_CashRow           equ 180
eqshp_CashCol           equ 72
eqshp_boiler_text       DB 2,             low 8,   high 8,   eqshp_TextColour, low eqship_title,   high eqship_title
                        DB 2,             low 120, high 120, eqshp_TextColour, low name_expanded,  high name_expanded
                        DB eqshp_CashRow, low 8,   high 8,   eqshp_TextColour, low eqship_cash,    high eqship_cash
eqshp_boiler_count      equ 3

eqship_title            DB "Equip Ship",0
eqship_cash				DB "Cash : ",0


txt_eqshp_amount	    DB "00.0",0
txt_eqshp_quantity      DB "999",0
txt_eqshp_cargo         DB "999",0
eqshp_cursor			DW  $0000
eqshp_blank_line        DB "                                ",0

eqshp_item_price        DS 20

eqshp_cash_amount		DS 20
eqshp_cash_UoM          DB " Cr       ",0

eqshp_selected_row      DB 0
eqshp_current_topItem   DB 0
eqshp_current_end       DB 0
eqship_buffer_rows      EQU     128
eqship_buffer_row_len   EQU      32
eqship_display_buff_len EQU     eqship_buffer_rows *   eqship_buffer_row_len
eqship_display_buffer:  DS      eqship_display_buff_len                     ; maxium of 128 items can be coded for
eqship_buyable_buffer:  DS      128
eqship_buffer_cash_col: EQU     21
eqship_fitted_module:   EQU     29
;----------------------------------------------------------------------------------------------------------------------------------
; the selected row redrawn in the highlight colour, or back in the text colour
eqshp_highlight_row:    ld      a,(eqshp_selected_row)
                        ld      c,eqshp_HighColour
                        jp      eqshp_print_row
;----------------------------------------------------------------------------------------------------------------------------------
eqshp_lowlight_row      ld      a,(eqshp_selected_row)
                        ld      c,eqshp_TextColour
                        jp      eqshp_print_row
;----------------------------------------------------------------------------------------------------------------------------------
; a = screen row (0 to eqshp_ListRows - 1), c = colour: print the list item there (eqshp_current_topItem + a), or a blank
; line past the end of the list so a shorter list leaves nothing behind. 320 x 256, characters are opaque
eqshp_print_row:        push    af
                        ld      d,a                     ; b = pixel row = top + a * 8
                        ld      e,8
                        mul     de
                        ld      a,e
                        add     a,eqshp_ListTop
                        ld      b,a
                        pop     af
                        ld      hl,eqshp_current_topItem
                        add     a,(hl)                  ; a = list item
                        ld      hl,eqshp_current_end
                        cp      (hl)
                        ld      de,eqshp_blank_line
                        jr      nc,.Print               ; past the end
                        ld      d,eqship_buffer_row_len
                        ld      e,a
                        mul     de
                        ld      hl,eqship_display_buffer
                        add     hl,de
                        ex      de,hl
.Print:                 ld      hl,eqshp_TextCol
                        MMUSelectLayer2
                        call    l2_print_at_320         ; b = row, hl = col, de = message, c = colour
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
eqshp_DispDEIXtoIY1DP:  call    eqshp_DispDEIXtoIY
                        ld      (iy+2),0
                        ld      a,(IY+0)
                        ld      (IY+1),a
                        ld      a,"."
                        ld      (IY+0),a
                        inc     IY
                        inc     IY
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
eqshp_DispDEIXtoIY:     ld (.EQSHPclcn32z),ix
                        ld (.EQSHPclcn32zIX),de
                        ld ix,.EQSHPclcn32t+36
                        ld b,9
                        ld c,0
.EQSHPclcn321:            ld a,'0'
                        or a
.EQSHPclcn322:            ld e,(ix+0)
                        ld d,(ix+1)
                        ld hl,(.EQSHPclcn32z)
                        sbc hl,de
                        ld (.EQSHPclcn32z),hl
                        ld e,(ix+2)
                        ld d,(ix+3)
                        ld hl,(.EQSHPclcn32zIX)
                        sbc hl,de
                        ld (.EQSHPclcn32zIX),hl
                        jr c,.EQSHPclcn325
                        inc c
                        inc a
                        jr .EQSHPclcn322
.EQSHPclcn325:            ld e,(ix+0)
                        ld d,(ix+1)
                        ld hl,(.EQSHPclcn32z)
                        add hl,de
                        ld (.EQSHPclcn32z),hl
                        ld e,(ix+2)
                        ld d,(ix+3)
                        ld hl,(.EQSHPclcn32zIX)
                        adc hl,de
                        ld (.EQSHPclcn32zIX),hl
                        ld de,-4
                        add ix,de
                        inc c
                        dec c
                        jr z,.EQSHPclcn323
                        ld (iy+0),a
                        inc iy
.EQSHPclcn323:            djnz .EQSHPclcn321
                        ld a,(.EQSHPclcn32z)
                        add A,'0'
                        ld (iy+0),a
                        ret
.EQSHPclcn32t             dw 1,0,     10,0,     100,0,     1000,0,       10000,0
                        dw $86a0,1, $4240,$0f, $9680,$98, $e100,$05f5, $ca00,$3b9a
.EQSHPclcn32z             ds 2
.EQSHPclcn32zIX           ds 2
;----------------------------------------------------------------------------------------------------------------------------------
; "DispHL, writes HL to DE address"
EQSHP_DispHLtoDE:         ld	bc,-10000
                        call	EQSHP_Num1
                        ld	bc,-1000
                        call	EQSHP_Num1
                        ld	bc,-100
                        call	EQSHP_Num1
                        ld	c,-10
                        call	EQSHP_Num1
                        ld	c,-1
EQSHP_Num1:	            ld	a,'0'-1
.Num2:	                inc	a
                        add	hl,bc
                        jr	c,.Num2
                        sbc	hl,bc
                        ld	(de),a
                        inc	de
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; ix = boiler text, b = lines (row, column, colour, message each)
EQSHP_print_boiler_text:push    bc
                        ld      b,(ix+0)
                        ld      l,(ix+1)
                        ld      h,(ix+2)
                        ld      c,(ix+3)
                        ld      e,(ix+4)
                        ld      d,(ix+5)
                        push    ix
                        MMUSelectLayer2
                        call    l2_print_at_320
                        pop     ix
                        ld      de,6
                        add     ix,de
                        pop     bc
                        djnz    EQSHP_print_boiler_text
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
eqshp_GetCash:          ld		hl,(Cash+2)
                        ex      de,hl
                        ld      ix,(Cash)
                        ld		iy,eqshp_cash_amount
                        call 	eqshp_DispDEIXtoIY1DP
                        push    IY
                        pop     de
                        ld      hl,eqshp_cash_UoM
                        ld      bc,11
                        ldir
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
eqshp_DisplayCash:      call	eqshp_GetCash
                        ld      b,eqshp_CashRow
                        ld      hl,eqshp_CashCol
                        ld      c,eqshp_TextColour
                        ld		de,eqshp_cash_amount
                        MMUSelectLayer2
                        call	l2_print_at_320
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
eqshp_expand_word:      ld      a,(hl)
                        cp      0
                        ret     z
                        ld      (de),a
                        inc     hl
                        inc     de
                        jr      eqshp_expand_word

; hl = list of words
; de = adress to expand to
eqshp_expand_name:      ld      a,(hl)
                        ld      b,a
                        inc     hl
                        ld      a,(hl)              ; its a 16 bit
                        dec     hl                  ; move back one for now, need to optimise laters
                        or      b
                        jr      nz,.MoreToDo
;                        ld      (de),a we dont want the null marker now
                        ret
.MoreToDo:              push    hl,,de
                        ld      a,(hl)              ; bodge for now no optimise
                        ld      e,a
                        inc     hl
                        ld      a,(hl)
                        ld      d,a
                        ex      hl,de               ; hl is now Word... address
                        pop     de                  ; de back to pointer to buffer
.ProcessWord:           call    eqshp_expand_word
                        ld      a," "               ; speculative space
                        ld      (de),a
                        inc     de
                        pop     hl                  ; get string pointer back
                        inc     hl
                        inc     hl                  ; on to next word
                        jr      eqshp_expand_name

eqshp_buffer_list:      ld      hl,eqship_display_buffer                    ; hl - target buffer
                        ld      a,1                                         ; so it will still skip them on printing
                        ld      de, eqship_display_buff_len
                        call    memfill_dma                                 ; full buffer with ASCII 1 (unprintable character)
                        ld      hl,eqship_display_buffer+eqship_buffer_row_len-1
                        ld      de,eqship_buffer_row_len
                        ld      b,ShipEquipTableSize
                        xor     a
.EoLLoop:               ld      (hl),a                                      ; fix all buffer lines with a null
                        add     hl,de
                        djnz    .EoLLoop
                        ld      b,ShipEquipTableSize                        ; CurrentGameMaxEquipment
                        ld      ix,ShipEquipmentList                        ; ix = equipment master table
                        ld      iy,eqship_display_buffer                    ; iy = target buffer
                        ld      c,0                                         ; Current Row
.ProcessRow:            ld      a,(ix+1)                                    ; get can buy
                        cp      $FF                                         ; if its $FF then do not display
                        jp      nz,.BufferItem
.DoNotDisplay:          ld      de,ShipEquipTableRowLen                     ; mov eto next equipment list, 7 =  row length
                        add     ix,de
                        djnz    .ProcessRow
                        jp      .DoneProcess
.BufferItem:            push    iy,,ix,,bc
                        ld      a,(ix+0)                                    ; get can buy
                        ld      hl,eqship_buyable_buffer                    ;
                        ld      e,c
                        ld      d,0                                         ;
                        add     hl,de                                       ;
                        ld      (hl),a                                      ; set buyable to 0
                        ld      hl,ShipEquipNameTable                       ; look up equipment name
                        ld      d,EquipNameTableRowLen                       ; ship equip name row length
                        ld      e,c
                        mul
                        add     hl,de                                       ; hl = dword list of work pointers
                        ld      de,iy                                       ; de = 0 column at current display buffer row
                        push    bc
                        call    eqshp_expand_name                           ; expand name
                        pop     bc
                        ld      de,eqship_buffer_cash_col                   ; move buffer column to 20
                        add     iy,de
                        push    iy
                        ld      a,(ix+4)
                        ld      e,a
                        ld      a,(ix+5)
                        ld      d,a                                         ; de = price
                        ld      ix,de
                        ld      de,0                                        ; deix = price
                        call    eqshp_DispDEIXtoIY                          ; print it to pos IY
                        ld      a," "
                        ld      (IY+0),a
                        ld      (IY+1),a
                        ld      (IY+2),a
                        pop     iy
                        call    .RightJustify
                        pop     iy,,ix,,bc
.CheckFitted:           ld      a,(ix+7)
                        ld      (iy+eqship_fitted_module),a
                        ld      de,eqship_buffer_row_len
                        add     iy,de                                       ; now iy = start of next column
                        ld      de,ShipEquipTableRowLen
                        add     ix,de
                        inc     c
                        djnz    .ProcessRow
.DoneProcess:           ld      a,c
                        ld      (eqshp_current_end),a
                        ret
.RightJustify:          call    .RightJustify2
.RightJustify2:         call    .RightJustify3
.RightJustify3:         ld      a,(iy+3)
                        cp      " "
                        call    z,.ShuffleRight
                        ret
.ShuffleRight:          push    iy
                        pop     hl
                        ld      a,3
                        add     hl,a
                        ld      a,(iy+2)
                        ld      (hl),a
                        dec     hl
                        ld      a,(iy+1)
                        ld      (hl),a
                        dec     hl
                        ld      a,(iy+0)
                        ld      (hl),a
                        dec     hl
                        ld      a," "
                        ld      (hl),a
                        ret


; the list, eqshp_ListRows rows from eqshp_current_topItem (the selected one highlighted), and the cash
draw_eqship_items:      ld      b,0
.Row:                   push    bc
                        ld      a,b
                        ld      c,eqshp_TextColour
                        ld      hl,eqshp_selected_row
                        cp      (hl)
                        jr      nz,.Draw
                        ld      c,eqshp_HighColour
.Draw:                  call    eqshp_print_row
                        pop     bc
                        inc     b
                        ld      a,b
                        cp      eqshp_ListRows
                        jr      c,.Row
                        call    eqshp_DisplayCash
                        ret

draw_eqshp_menu:        MMUSelectLayer1                     ; 320 x 256 single buffered, as the other menus
                        call    l1_cls
                        ld      a,7
                        call    l1_attr_cls_to_a
                        MMUSelectLayer2
                        call    asm_l2_double_buffer_off
                        call    l2_320_initialise
                        call    l2_320_cls
                        MMUSelectSpriteBank
                        call    sprite_cls_all
                        ld      a,$20
                        ld      (MenuIdMax),a
.SetData:               ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        call    galaxy_planet_data
                        call    galaxy_equip_market
                        ld      bc,(PresentSystemX)
                        call    galaxy_name_at_bc
                        call    galaxy_planet_data
                        xor     a
                        ld      (eqshp_current_topItem),a
                        call    eqshp_buffer_list
.Drawbox:               MMUSelectLayer2
                        call    l2_draw_menu_border
.StaticText:	        ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        ld		a,25
                        call	expandTokenToString
                        call	GetDigramGalaxySeed
                        ld      ix,eqshp_boiler_text                ; title, system name, "Cash :"
                        ld      b,eqshp_boiler_count
                        call    EQSHP_print_boiler_text
.InitialHighlight:      xor     a
                        ld      (eqshp_selected_row),a        ; assume on row zero
                        call    draw_eqship_items             ; (the list, the highlighted row and the cash)
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
eqip_refesh_buffer:     call    eqshp_buffer_list
                        ld      a,(eqshp_selected_row)              ; get revised list length
                        ld      b,a
                        ld      a,(eqshp_current_topItem)           ; get current top of screen
                        ld      c,a
                        add     b                                   ; a = top + selected row
                        ld      hl,eqshp_current_end
                        CallIfAGTENusng (hl), .NewListShorter       ; if a > new list len then rebuild
                        jp      .RedrawList
.NewListShorter:        push    bc
                        call    eqshp_lowlight_row
                        pop     bc
                        ld      a,(eqshp_current_end)               ; b = end of list
                        sub     c                                   ; minus current top
                        ld      (eqshp_selected_row),a
.RedrawList:            call    draw_eqship_items                   ; (highlights the selected row)
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
; Handles all the input whilst in the market menu
loop_eqshp_menu:        MacroIsKeyPressed c_Pressed_CursorUp
                        call    z,eqshp_UpPressed
                        MacroIsKeyPressed c_Pressed_CursorDown
                        call    z,eqshp_DownPressed
                        MacroIsKeyPressed c_Pressed_RollLeft
                        call    z,eqshp_LeftPressed
                        MacroIsKeyPressed c_Pressed_RollRight
                        call    z,eqshp_RightPressed
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
eqshp_UpPressed:        ld      a,(eqshp_selected_row)
                        cp      0
                        jr      z,.check_scroll_up
                        call    eqshp_lowlight_row
                        ld      hl,eqshp_selected_row
                        dec     (hl)
                        call    eqshp_highlight_row
                        ret
.check_scroll_up:       ld      a,(eqshp_current_topItem)
                        cp      0
                        ret     z
                        dec     a           ; chjange later to buffering step back 1
                        ld      (eqshp_current_topItem),a
                        call    draw_eqship_items
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
eqshp_DownPressed:      ld      a,(eqshp_current_end)
                        ld      b,a                             ; This check is if the current list is < one screen
                        dec     b
                        ld      a,(eqshp_selected_row)
                        cp      b
                        ret     z
                        cp      17
                        jr      z, .check_scroll_down
                        call    eqshp_lowlight_row
                        ld      hl,eqshp_selected_row
                        inc     (hl)
                        call    eqshp_highlight_row
                        ret
.check_scroll_down:     ld      b,a
                        ld      a,(eqshp_current_topItem)
                        add     b
                        inc     a
                        ld      hl,eqshp_current_end
                        ReturnIfAGTEusng      (hl)
.can_scroll_down:       ld      hl,eqshp_current_topItem
                        inc     (hl)
                        call    draw_eqship_items
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
eqshp_LeftPressed:      ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        ld      ix,ShipEquipmentList
.IsItFuel:              ld      a,(eqshp_current_topItem)   ; Can't refund fuel
                        ld      b,a
                        ld      a,(eqshp_selected_row)
                        add     b
                        cp      0
                        ret     z
.FuelNotSelected:       ld      c,a
.FindInTable:           ld      d,ShipEquipTableRowLen
                        ld      e,a
                        mul
                        add     ix,de
                        ld      a,(ix+7)
                        cp      "-"
                        ret     z
.CheckIfMissle:         ld      a,c
                        cp      EQ_MISSILE
                        jr      z,.RefundMissle
.RefundItemCash:        ld      e,(ix+4)
                        ld      d,(ix+5)
                        push    hl,,bc
                        call    addDEtoCash         ; refund laser value
                        pop     hl,,bc
                        ld      a,"-"
                        ld      (ix+7),a
                        ld      hl,EquipmentFitted
                        ld      a,c                 ; get back current laser ref
                        add     hl,a
                        ld      (hl),EquipmentItemNotFitted; remove laser from equipment
                        call    eqip_refesh_buffer
                        ld      a,(ix+8)
                        cp      $FF
                        ret     z
.ItsALaser              ld      hl,LaserType        ; clear out respective current laser
                        ld      b,a
                        ld      a,(ix+9)
                        add     hl,a
                        ld      (hl),$FF            ; $FF = not fitted
                        ret
.RefundMissle           ld      e,(ix+4)
                        ld      d,(ix+5)
                        push    hl,,bc
                        call    addDEtoCash         ; refund laser value
                        pop     hl,,bc
                        ld      a,(ix+7)
                        dec     a
                        cp      "0"
                        jr      nz,.NotAllSold
.AllSold:               ld      a,"-"
.NotAllSold:            ld      (ix+7),a
                        call    eqip_refesh_buffer
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
eqshp_RightPressed:     ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        ld      ix,ShipEquipmentList
                        ld      a,(eqshp_current_topItem)
                        ld      b,a
                        ld      a,(eqshp_selected_row)
                        add     a,b
                        cp      EQ_MISSILE
                        jr      nz,.NotAMissileBuy
.ItsAMissile:           ex      af,af'
                        ld      a,"4"
                        ld      (.CompareCheck+1),a
                        ex      af,af'
                        jp      .FindInTable
.NotAMissileBuy:        ex      af,af'
                        ld      a,"*"
                        ld      (.CompareCheck+1),a
                        ex      af,af'
.FindInTable:           ld      d,ShipEquipTableRowLen
                        ld      e,a
                        mul
                        add     ix,de
                        ld      a,(ix+7)
.CompareCheck:          cp      "*"; not true for missles astyou can buy 1 to 4
                        ret     z
.Purchasable:           ld      b,a
                        ld      a,(ix+6)
                        cp      EQ_MISSILE
                        jr      nz,.NotMissleMax
.MissleQuanity:         ld      hl,NbrMissiles
                        ld      a,b
                        cp      (hl)
                        ret     z
.NotMissleMax:          ld      c,a
                        ld      a,(ix+1)
                        cp      $FF
                        ret     z
.CheckCash:             JumpIfMemIsNotZero  Cash+2 , .MoreThanRequired      ; Nothing in game > 65535CR
                        ld      hl,(Cash)                                   ; hl = lower 16 bits of cash
                        ld      e,(ix+4)
                        ld      d,(ix+5)
                        call	compare16HLDE
                        ret     c                                           ; Insufficient Funds
.MoreThanRequired:      ld      a,(ix+6)
                        cp      0
                        jr      z,.MaxFuelOut
                        cp      1
                        jr      z,.AddMissle
                        JumpIfAGTENusng  EQ_FRONT_PULSE,.AddLaser
.AddNormalItem:         ld      hl,EquipmentFitted
                        add     hl,a
                        ld      (hl),EquipmentItemFitted
                        ld      a,"*"
                        jp      .AddedItem
.MaxFuelOut:            MaxFuelMacro
                        ld      a,"*"
                        jp      .AddedItem
.AddMissle:             ld      hl,NbrMissiles
                        inc     (hl)
                        ld      a,(hl)
                        add     "0"
                        jp      .AddedItem
.AddLaser:              ld      a,(ix+8)            ; Get if its a laser, $FF = no laser
                        cp      $FF
                        jr      nz,.BuyLaser
.LargeCargoBay: ;TODO
.RefundExistingLaser:   ld      c,a                 ; retain current laser nbr
                        ld      hl,ShipEquipmentList
                        ld      d,ShipEquipTableRowLen
                        ld      e,a
                        mul
                        add     hl,de               ; now we have the row for the current laser
                        ld      a,4
                        add     hl,a
                        ld      a,(hl)
                        ld      e,a
                        inc     hl
                        ld      a,(hl)
                        ld      d,a
                        push    hl,,bc
                        call    addDEtoCash         ; refund laser value
                        pop     hl,,bc
                        ld      a,2
                        add     hl,a
                        ld      a,"-"
                        ld      (hl),a              ; clear on ship equipment
                        ld      hl,EquipmentFitted
                        ld      a,c                 ; get back current laser ref
                        add     hl,a
                        ld      (hl),EquipmentItemNotFitted  ; remove laser from equipment
.BuyLaser:              ld      hl,EquipmentFitted
                        ld      a,(ix+6)
                        add     hl,a
                        ld      (hl),EquipmentItemFitted
                        ld      a,(ix+9)            ; get laser position
                        ld      hl,LaserType
                        add     hl,a
                        ld      a,(ix+8)            ; get type
                        ld      (hl),a
                        ld      a,"*"
.AddedItem              ld      (ix+7),a
                        ld      e,(ix+4)
                        ld      d,(ix+5)
                        call    subDEfromCash
                        call    eqip_refesh_buffer
                        ret