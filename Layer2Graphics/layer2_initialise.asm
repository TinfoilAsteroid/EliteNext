
l2_initialise:
; ">l2_initialise"
	nextreg		LAYER2_RAM_PAGE_REGISTER,          	LAYER2_SCREEN_BANK1
	nextreg		LAYER2_RAM_SHADOW_REGISTER,     	LAYER2_SHADOW_BANK1
	nextreg		TRANSPARENCY_COLOUR_REGISTER, 		COLOUR_TRANSPARENT
 ;   nextreg     LAYER_2_ACCESS_PORT,                l2_buffer_state
	ret


l2_flip_buffers:
    GetNextReg LAYER2_RAM_PAGE_REGISTER
    ld      d,a
    GetNextReg LAYER2_RAM_SHADOW_REGISTER
    ld      e,a
    nextreg LAYER2_RAM_PAGE_REGISTER, a
    ld      a,d
    nextreg LAYER2_RAM_SHADOW_REGISTER, a
	ret
    