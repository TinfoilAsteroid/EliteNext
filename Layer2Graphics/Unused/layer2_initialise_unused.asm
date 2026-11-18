; Moved out of Layer2Graphics/layer2_initialise.asm as nothing in the eliteNext.asm build uses it
; (unreferenced routines, and IFDEF blocks whose flag is never defined). Not included in the game build.

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
