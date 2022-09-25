
l2_cls_byte	            DB 0
; ">DMA Command BLOCK"

l2_fill                 DB DMA_DISABLE,  DMA_RESET, DMA_RESET_PORT_A_TIMING, DMA_RESET_PORT_B_TIMING ,DMA_WRO_BLOCK_PORTA_A2B_XFR
l2_fill_astrt           DW l2_cls_byte
l2_fill_length          DB $00,$40
                        DB DMA_WR1_P1FIXED_MEMORY ,DMA_WR2_P2INC_MEMORY ,DMA_WR4_CONT_MODE 
l2_fill_bstrt           DB $00,$00
                        DB DMA_STOP_AT_END, DMA_LOAD, DMA_FORCE_READY, DMA_ENABLE
l2_fill_cmd_len	        EQU $ - l2_fill

l2_cls_dma_bank:
; ">l2_cls_dma_bank"
; ">sets a bank to"  
.set_colour:            ld (l2_cls_byte),a
.write_dma:             ld hl, l2_fill
                        ld b, l2_fill_cmd_len
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
                        di
                        asm_l2_bank_0_macro ; call asm_l2_row_bank_select
                        ld 	a,COLOUR_TRANSPARENT
                        call l2_cls_dma_bank
                        ;ld a,64								; pretend we are plotting pixel on row 64 to force mid selection
                        asm_l2_bank_1_macro ;call asm_l2_row_bank_select
                        ld 	a,COLOUR_TRANSPARENT
                        call l2_cls_dma_bank
                        ei
                        ret

l2_cls_lower_third:     ;ld a,128							; pretend we are plotting pixel on row 64 to force mid selection
                        di
                        asm_l2_bank_2_macro; call asm_l2_row_bank_select
                        ld 	a,COLOUR_TRANSPARENT
                        call l2_cls_dma_bank
                        ei
                        ret
	 
l2_cls:                 call l2_cls_upper_two_thirds
                        jp   l2_cls_lower_third
	