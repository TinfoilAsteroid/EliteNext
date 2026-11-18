; Routines moved out of Maths24/asm_rollpitch24_origin.asm as nothing in the eliteNext.asm build references them.
; Not included in the game build; INCLUDE this after asm_rollpitch24_origin.asm to use them again.

SetCDEtoDelta:              MACRO
                            ld      a,(DeltaDecimal+2)      ; set BHL to Beta
                            ld      b,a                     ;
                            ld      hl,(DeltaDecimal)       ;
                            ENDM
                                
                              
                                DISPLAY "Later oprimise to do decimal calc in main loop"
                                DISPLAY "Also update compasses"
