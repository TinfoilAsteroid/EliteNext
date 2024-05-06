
l2_cls_byte	            DB 0
; ">DMA Command BLOCK"

l2_fill                 DB DMA_DISABLE,  DMA_RESET, DMA_RESET_PORT_A_TIMING, DMA_RESET_PORT_B_TIMING ,DMA_WRO_BLOCK_PORTA_A2B_XFR
l2_fill_astrt           DW l2_cls_byte
l2_fill_length          DB $00,$40
                        DB DMA_WR1_P1FIXED_MEMORY ,DMA_WR2_P2INC_MEMORY ,DMA_WR4_CONT_MODE 
l2_fill_bstrt           DB $00,$00
                        DB DMA_STOP_AT_END, DMA_LOAD, DMA_FORCE_READY, DMA_ENABLE
l2_fill_cmd_len	        EQU $ - l2_fill

l2_fill_burst           DB DMA_DISABLE,  DMA_RESET, DMA_RESET_PORT_A_TIMING, DMA_RESET_PORT_B_TIMING ,DMA_WRO_BLOCK_PORTA_A2B_XFR
.l2_fill_astrt          DW l2_cls_byte
.l2_fill_length         DB $00,$40
                        DB DMA_WR1_P1FIXED_MEMORY ,DMA_WR2_P2INC_MEMORY ,DMA_WR4_BURST_MODE 
.l2_fill_bstrt          DB $00,$00
                        DB DMA_STOP_AT_END, DMA_LOAD, DMA_FORCE_READY, DMA_ENABLE
l2_fill_burst_cmd_len   EQU $ - l2_fill_burst

; ">l2_cls_dma_bank sets a bank to"  
l2_cls_dma_bank:        
.set_colour:            ld (l2_cls_byte),a
.write_dma:             ld hl, l2_fill
                        ld b, l2_fill_cmd_len
                        ld	c,IO_DATAGEAR_DMA_PORT
                        otir
                        ret

; ">l2_cls_dma_bank sets a bank to"  
l2_cls_dma_bank_burst:  
.set_colour:            ld (l2_cls_byte),a
.write_dma:             ld hl, l2_fill_burst
                        ld b, l2_fill_burst_cmd_len
                        ld	c,IO_DATAGEAR_DMA_PORT
                        otir
                        ret

l2_set_color_upper2:    ld      a,0
                        call asm_l2_row_bank_select
                        ld      a,(l2_cls_byte)
                        call l2_cls_dma_bank
                        ld a,64								; pretend we are plotting pixel on row 64 to force mid selection
                        call asm_l2_row_bank_select
                        ld      a,(l2_cls_byte)
                        call l2_cls_dma_bank
                        ret


l2_cls_upper_two_thirds:;ld a,0								; pretend we are plotting pixel on row 0 to force top selection
                        asm_l2_bank_0_macro ; call asm_l2_row_bank_select
                        ld 	a,COLOUR_TRANSPARENT
                        call l2_cls_dma_bank
                        ;ld a,64								; pretend we are plotting pixel on row 64 to force mid selection
                        asm_l2_bank_1_macro ;call asm_l2_row_bank_select
                        ld 	a,COLOUR_TRANSPARENT
                        call l2_cls_dma_bank
                        ret

l2_cls_upper_two_thirds_burst:;ld a,0								; pretend we are plotting pixel on row 0 to force top selection
                        asm_l2_bank_0_macro ; call asm_l2_row_bank_select
                        ld 	a,COLOUR_TRANSPARENT
                        call l2_cls_dma_bank_burst
                        ;ld a,64								; pretend we are plotting pixel on row 64 to force mid selection
                        asm_l2_bank_1_macro ;call asm_l2_row_bank_select
                        ld 	a,COLOUR_TRANSPARENT
                        call l2_cls_dma_bank_burst
                        ret

l2_cls_lower_third:     ;ld a,128							; pretend we are plotting pixel on row 64 to force mid selection
                        asm_l2_bank_2_macro; call asm_l2_row_bank_select
                        ld 	a,COLOUR_TRANSPARENT
                        call l2_cls_dma_bank
                        ret

l2_cls_lower_third_burst:asm_l2_bank_2_macro; call asm_l2_row_bank_select
                        ld 	a,COLOUR_TRANSPARENT
                        call l2_cls_dma_bank_burst
                        ret
                                                       
                        
l2_cls_burst:           call l2_cls_upper_two_thirds_burst
                        jp   l2_cls_lower_third_burst


l2_cls:                 call l2_cls_upper_two_thirds
                        jp   l2_cls_lower_third
	    IFDEF L2_640_SUPPORT
l2_640_cls:             
        ENDIF
l2_320_cls:             call l2_cls_upper_two_thirds
                        call   l2_cls_lower_third
                        ; need to clear banks 4 and 5 via normal paging, say into C000 with interrupts disabled
                        asm_l2_bank_3_macro
                        ld 	a,COLOUR_TRANSPARENT
                        call l2_cls_dma_bank
                        asm_l2_bank_4_macro
                        ld 	a,COLOUR_TRANSPARENT
                        call l2_cls_dma_bank

                        ret
