
l2_graphic_mode         DW          0

l2_initialise:          nextreg     LAYER_2_CONTROL_REGISTER,           %00000000               ; 256x192x8bpp
                        nextreg     CLIP_WINDOW_CONTROL_REGISTER,       0
                        nextreg     CLIP_WINDOW_LAYER2_REGISTER,        0
                        nextreg     CLIP_WINDOW_LAYER2_REGISTER,        255
                        nextreg     CLIP_WINDOW_LAYER2_REGISTER,        0
                        nextreg     CLIP_WINDOW_LAYER2_REGISTER,        192
                        nextreg		LAYER2_RAM_PAGE_REGISTER,          	LAYER2_SCREEN_BANK1
                        nextreg		LAYER2_RAM_SHADOW_REGISTER,     	LAYER2_SHADOW_BANK1
                        nextreg		TRANSPARENCY_COLOUR_REGISTER, 		COLOUR_TRANSPARENT
                        ZeroA
                        ld          (l2_graphic_mode),a
                        DoubleBufferIfPossible
                        DoubleBufferIfPossible
                        call        asm_l2_row_bank_select
                        ret


l2_320_initialise:      nextreg     LAYER_2_CONTROL_REGISTER,           %00010000               ; 320x256x8bpp
                        nextreg     CLIP_WINDOW_CONTROL_REGISTER,       0
                        nextreg     CLIP_WINDOW_LAYER2_REGISTER,        0
                        nextreg     CLIP_WINDOW_LAYER2_REGISTER,        159
                        nextreg     CLIP_WINDOW_LAYER2_REGISTER,        0
                        nextreg     CLIP_WINDOW_LAYER2_REGISTER,        255
                        nextreg		LAYER2_RAM_PAGE_REGISTER,          	LAYER2_SCREEN_BANK1
                        nextreg		LAYER2_RAM_SHADOW_REGISTER,     	LAYER2_SHADOW_BANK1
                        nextreg		TRANSPARENCY_COLOUR_REGISTER, 		COLOUR_TRANSPARENT
                        ret
                        ld          a,1
                        ld          (l2_graphic_mode),a
                        DoubleBuffer320IfPossible
                        DoubleBuffer320IfPossible
                        ret
    IFDEF L2_640_SUPPORT
l2_640_initialise:      nextreg     LAYER_2_CONTROL_REGISTER,           %00100000               ; 320x256x8bpp
                        nextreg     CLIP_WINDOW_CONTROL_REGISTER,       0
                        nextreg     CLIP_WINDOW_LAYER2_REGISTER,        0
                        nextreg     CLIP_WINDOW_LAYER2_REGISTER,        159
                        nextreg     CLIP_WINDOW_LAYER2_REGISTER,        0
                        nextreg     CLIP_WINDOW_LAYER2_REGISTER,        255
                        nextreg		LAYER2_RAM_PAGE_REGISTER,          	LAYER2_SCREEN_BANK1
                        nextreg		LAYER2_RAM_SHADOW_REGISTER,     	LAYER2_SHADOW_BANK1
                        nextreg		TRANSPARENCY_COLOUR_REGISTER, 		COLOUR_TRANSPARENT
                        ld          a,2
                        ld          (l2_graphic_mode),a
                        DoubleBuffer640IfPossible
                        DoubleBuffer640IfPossible
                        call        asm_l2_640_col_bank_select
                        ret
    ENDIF