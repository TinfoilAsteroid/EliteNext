l2_flip_buffers:        GetNextReg LAYER2_RAM_PAGE_REGISTER
                        ld      d,a
                        GetNextReg LAYER2_RAM_SHADOW_REGISTER
                        ld      e,a
                        nextreg LAYER2_RAM_PAGE_REGISTER, a
                        ld      a,d
                        nextreg LAYER2_RAM_SHADOW_REGISTER, a
                        ret
    