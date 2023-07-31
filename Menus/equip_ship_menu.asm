eqshp_prices_page_marker  DB "EquipShipPG63"    
eqshp_boiler_text		DW $0250,eqship_title
						DW $0220,name_expanded
                        DW $B008,eqship_cash
                        
eqship_title            DB "Equip Ship",0
eqship_cash				DB "Cash : ",0

txt_eqshp_amount	    DB "00.0",0
txt_eqshp_quantity      DB "999",0
txt_eqshp_cargo         DB "999",0
eqshp_cursor			DW  $0000
eqshp_position			equ $1808
eqshp_uom				equ	$68
eqshp_price 			equ $88
eqshp_Quantity			equ	$B0
eqshp_Cargo             equ $E0
eqshp_UomOffset		    equ 46
eqshp_blank_line        DB "                                ",0

eqshp_item_price        DS 20

eqshp_cash_position     equ $B048
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
eqshp_highlight_row:    ld      a,(eqshp_selected_row)
                        add     a,3
                        ld      d,a
                        ld      e,L1InvHighlight
                        MMUSelectLayer1
                        call    l1_hilight_row
                        ret
;----------------------------------------------------------------------------------------------------------------------------------	
eqshp_lowlight_row      ld      a,(eqshp_selected_row)
                        add     a,3
                        ld      d,a
                        ld      e,L1InvLowlight
                        MMUSelectLayer1
                        call    l1_hilight_row
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
EQSHP_DispAtoDE:          ld h,0
                        ld l,a
                        jp EQSHP_DispHLtoDE
;----------------------------------------------------------------------------------------------------------------------------------	
EQSHP_DispPriceAtoDE:     ld h,0
                        ld l,a
                        ld	bc,-100
                        call	.NumLeadBlank1
                        ld	c,-10
                        call	EQSHP_Num1
                        ld		a,'.'					; we could assume preformat but
                        ld		(de),a					; we can optimse that later TODO
                        inc		de						; with just an inc De
                        ld	c,-1
                        jr		EQSHP_Num1
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
EQSHP_DispQtyAtoDE:      cp	0
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
                        jr		EQSHP_Num1
.NotHundredsZero:       ld	c,-10
                        call	EQSHP_Num1
                        ld	c,-1
                        jr		EQSHP_Num1
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
EQSHP_print_boiler_text:  INCLUDE "Menus/print_boiler_text_inlineInclude.asm"
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
                        ld		hl,eqshp_cash_amount
                        ld      de,eqshp_cash_position
                        MMUSelectLayer1   
                        call	l1_print_at   
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
                        ;push    de
                        ;pop     ix
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
                        

draw_eqship_items:      MMUSelectLayer1
                        call    l1_cls
                        ld		b,3
                        ld		hl,eqshp_boiler_text
                        call	EQSHP_print_boiler_text
                        call    eqshp_DisplayCash                                                
                        ld      a,(eqshp_current_topItem)
                        ld      d,eqship_buffer_row_len
                        ld      e,a
                        mul
                        ld      hl,eqship_display_buffer
                        add     hl,de
                        ld      a,(eqshp_current_topItem)
                        ld      b,a
                        ld      a,(eqshp_current_end)
                        sub     b
                        JumpIfALTNusng  18, .FillScreen
.JustWindowing:         ld      b,18
                        jr      .ReadyToPrint
.FillScreen:            ld      b,a         ; the mumber of rows to display
.ReadyToPrint:          ld      de,eqshp_position
.DrawARow:              push    de,,hl,,bc                  ; "l1 PrintAt, pixel row, whole char col, DE = yx, HL = message Addr"
                        call    l1_print_at:
                        pop     hl,,bc                      ; get mesage addr back and move down one line
                        ld      de,eqship_buffer_row_len
                        add     hl,de
                        pop     de                          ; get output row back
                        ld      a,8
                        add     a,d
                        ld      d,a
                        djnz    .DrawARow
                        ret

draw_eqshp_menu:        InitNoDoubleBuffer
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
.Drawbox:               ld		bc,$0101
                        ld		de,$BEFD
                        ld		a,$C0
                        MMUSelectLayer2
                        call	l2_draw_box
                        ld		bc,$0A01
                        ld		de,$FEC0
                        call	l2_draw_horz_line                        
.StaticText:	        ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        ld		a,25
                        call	expandTokenToString
                        call	GetDigramGalaxySeed
                        call    draw_eqship_items
.InitialHighlight:      xor     a
                        ld      (eqshp_selected_row),a        ; assume on row zero
                        call    eqshp_highlight_row
.DisCash:               call    eqshp_DisplayCash
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
.RedrawList:            call    eqshp_highlight_row
                        call    draw_eqship_items
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