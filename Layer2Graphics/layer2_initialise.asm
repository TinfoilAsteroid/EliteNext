
l2_initialise:          nextreg		LAYER2_RAM_PAGE_REGISTER,          	LAYER2_SCREEN_BANK1
                        nextreg		LAYER2_RAM_SHADOW_REGISTER,     	LAYER2_SHADOW_BANK1
                        nextreg		TRANSPARENCY_COLOUR_REGISTER, 		COLOUR_TRANSPARENT
                        ZeroA
                        DoubleBufferIfPossible
                        DoubleBufferIfPossible
                        call        asm_l2_row_bank_select
                        ret

