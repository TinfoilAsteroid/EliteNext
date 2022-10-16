
l2_initialise:          nextreg     LAYER_2_CONTROL_REGISTER,           %00000000               ; 256x192x8bpp
                        nextreg		LAYER2_RAM_PAGE_REGISTER,          	LAYER2_SCREEN_BANK1
                        nextreg		LAYER2_RAM_SHADOW_REGISTER,     	LAYER2_SHADOW_BANK1
                        nextreg		TRANSPARENCY_COLOUR_REGISTER, 		COLOUR_TRANSPARENT
                        ZeroA
                        DoubleBufferIfPossible
                        DoubleBufferIfPossible
                        call        asm_l2_row_bank_select
                        ret

l2_320_initialise:      nextreg     LAYER_2_CONTROL_REGISTER,           %00010000               ; 320x256x8bpp
                        nextreg		LAYER2_RAM_PAGE_REGISTER,          	LAYER2_SCREEN_BANK1
                        nextreg		LAYER2_RAM_SHADOW_REGISTER,     	LAYER2_SHADOW_BANK1
                        nextreg		TRANSPARENCY_COLOUR_REGISTER, 		COLOUR_TRANSPARENT
                        ZeroA
                        DoubleBuffer320IfPossible
                        DoubleBuffer320IfPossible
                        call        asm_l2_320_col_bank_select
                        ret
                        
;l2_640_initialise:      nextreg     LAYER_2_CONTROL_REGISTER,           %00100000               ; 320x256x8bpp
;                        nextreg		LAYER2_RAM_PAGE_REGISTER,          	LAYER2_SCREEN_BANK1
;                        nextreg		LAYER2_RAM_SHADOW_REGISTER,     	LAYER2_SHADOW_BANK1
;                        nextreg		TRANSPARENCY_COLOUR_REGISTER, 		COLOUR_TRANSPARENT
;                        ZeroA
;                        DoubleBuffer640IfPossible
;                        DoubleBuffer640IfPossible
;                        call        asm_l2_640_col_bank_select
;                        ret
