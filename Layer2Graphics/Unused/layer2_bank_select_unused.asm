; Moved out of Layer2Graphics/layer2_bank_select.asm as nothing in the eliteNext.asm build uses it
; (unreferenced routines, and IFDEF blocks whose flag is never defined). Not included in the game build.

asm_restore_l2_readwrite:   ld      a,(varL2_ACCESS_MODE)
                            and     LAYER2_READ_WRITE_MASK
                            ld      d,a
                            ld      bc, IO_LAYER2_PORT
                            in      (c)
                            ld      (varL2_ACCESS_MODE),a
                            and     d
                            out     (c),a
                            ret  

asm_enable_l2_readwrite:    ld      bc, IO_LAYER2_PORT
                            in      (c)
                            or      LAYER2_READ_WRITE_MASK
                            out     (c),a
                            ret                               

asm_l2_reselect_saved_bank: ld      a,(varL2_SAVED_SELECT)  ; recover selected option
                            ld 		bc, IO_LAYER2_PORT
                            out 	(c),a
                            ld      a,(varL2_SAVED_OFFSET)
                            out 	(c),a
                            ret
