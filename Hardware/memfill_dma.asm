
memfillvalue		DB 0
memfill        		DB DMA_DISABLE,  DMA_RESET, DMA_RESET_PORT_A_TIMING, DMA_RESET_PORT_B_TIMING ,DMA_WRO_BLOCK_PORTA_A2B_XFR
memfill_astrt  		DW memfillvalue
memfill_length 		DB $00,$40
					DB DMA_WR1_P1FIXED_MEMORY ,DMA_WR2_P2INC_MEMORY ,DMA_WR4_CONT_MODE 
memfill_bstrt  		DB $00,$00
					DB DMA_STOP_AT_END, DMA_LOAD, DMA_FORCE_READY, DMA_ENABLE
memfill_cmd_len	  	EQU $ - memfill

memfill_dma:
; "memfill_dma, hl = address to fill, a = value, de = length"
.set_fill_value:
	ld 		(memfillvalue),a
.set_target:
	ld		(memfill_bstrt),hl
.set_length:
	ld		(memfill_length),de
.write_dma:
	ld 		hl, memfill
	ld 		b, memfill_cmd_len
	ld		c,IO_DATAGEAR_DMA_PORT
	otir
	ret
