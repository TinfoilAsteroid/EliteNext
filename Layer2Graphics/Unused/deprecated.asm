;----------------------------------------------------------------------------------------------------------------------------------
; deprecated.asm: Layer 2 routines nothing in the game calls, moved out of the built Layer2Graphics files.
; Not assembled (eliteNext.asm doesn't include it): kept for reference. Each section says where it came from.
;----------------------------------------------------------------------------------------------------------------------------------

;=== from Layer2Graphics/layer2_bank_select.asm ===============================================================
; takes current bank saved in varL2_BANK_SELECTED, increments it cycling around and selects
; note this is for a temp bank switch e.g. printing a character so does not load the varL2 values
asm_l2_320_next_bank_noSv:  ld      a,(varL2_BANK_SELECTED)
                            inc     a
                            cp      5
                            jp      nz,.bankSelected
.cycleToZero:               ZeroA
.bankSelected:              and     a
                            jp      z,.Bank1
.testBank2:                 dec     a
                            jp      z,.Bank2
.testBank3:                 dec     a
                            jp      z,.Bank3
.testBank4:                 dec     a
                            jp      z,.Bank4
.testBank5:                 dec     a
.Bank5:                     ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_BOTTOM
                            ld 		bc, IO_LAYER2_PORT
                            out 	(c),a
                            ld      a,%00010010
                            out 	(c),a
                            ld      a,4						; set a to 0
                            ret
.Bank1:                     ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_TOP
                            ld 		bc, IO_LAYER2_PORT
                            out 	(c),a
                            ld      a,%00010000
                            out 	(c),a
                            ret
.Bank2:                     ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_MIDDLE
                            ld 		bc, IO_LAYER2_PORT
                            out 	(c),a
                            ld      a,%00010000
                            out 	(c),a
                            ret  
.Bank3:                     ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_BOTTOM
                            ld 		bc, IO_LAYER2_PORT
                            out 	(c),a
                            ld      a,%00010000
                            out 	(c),a            
                            ret             
.Bank4:                     ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_BOTTOM
                            ld 		bc, IO_LAYER2_PORT                       
                            out 	(c),a
                            ld      a,%00010001
                            out 	(c),a          
                            ret           


;=== from Layer2Graphics/layer2_plot_pixel.asm ================================================================
l2_plot_pixel_320_no_check:   call    asm_l2_320_col_bank_select      ; adjust hl for column > h 
                        ld      l,d                             ; as they are horizontal now
                        ld      a,e
                        ld      (hl),a
                        ret
