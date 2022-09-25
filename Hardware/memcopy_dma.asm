
memcopy        		DB DMA_DISABLE,  DMA_RESET, DMA_RESET_PORT_A_TIMING, DMA_RESET_PORT_B_TIMING ,DMA_WRO_BLOCK_PORTA_A2B_XFR
memcopy_astrt  		DB $00,$00
memcopy_length 		DB $00,$40
					DB DMA_WR1_P1INC_MEMORY ,DMA_WR2_P2INC_MEMORY ,DMA_WR4_BURST_MODE;DMA_WR4_CONT_MODE 
memcopy_bstrt  		DB $00,$00
					DB DMA_STOP_AT_END, DMA_LOAD, DMA_FORCE_READY, DMA_ENABLE
memcopy_cmd_len	  	equ $ - memcopy

memcopy_dma:
; "memcopy_dma, hl = target address de = source address to copy, bc = length"
.set_target:
	ld		(memcopy_bstrt),hl
.set_source:
	ld		(memcopy_astrt),de
.set_length:
	ld		(memcopy_length),bc
.write_dma:
	ld 		hl, memcopy
	ld 		b, memcopy_cmd_len
	ld		c,IO_DATAGEAR_DMA_PORT
	otir
	ret
