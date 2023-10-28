;...subtract routines
; we could cheat, flip the sign of DE and just add but its not very optimised
subHLDES15:             ld      a,h
                        and     SignOnly8Bit
                        ld      b,a                         ;save sign bit in b
                        xor     d                           ;if h sign and d sign were different then bit 7 of a will be 1 which means 
                        JumpIfNegative .SUBHLDEOppSGN        ;Signs are opposite therefore we can add
.SUBHLDESameSigns:      ld      a,b
                        or      d
                        JumpIfNegative .SUBHLDESameNeg       ; optimisation so we can just do simple add if both positive
                        ClearCarryFlag
                        sbc     hl,de
                        JumpIfNegative .SUBHLDESameOvrFlw            
                        ret
.SUBHLDESameNeg:        ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit
                        and     SignMask8Bit                ; we could check the value of b for optimisation
                        ld      h,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a
                        ClearCarryFlag
                        sbc     hl,de
                        JumpIfNegative .SUBHLDESameOvrFlw            
                                            DISPLAY "TODO:  don't bother with overflow for now"
                        ld      a,h                         ; now set bit for negative value, we won't bother with overflow for now TODO
                        or      SignOnly8Bit
                        ld      h,a
                        ret
.SUBHLDESameOvrFlw:     NegHL
                        ld      a,b
                        xor     SignOnly8Bit                ; flip sign bit
                        or      h
                        ld      h,a                         ; recover sign
                        ret         
.SUBHLDEOppSGN:         or      a
                        ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit
                        and     SignMask8Bit                ; we could check the value of b for optimisation
                        ld      h,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a     
                        add     hl,de
                        ld      a,b                         ; we got here so hl > de therefore we can just take hl's previous sign bit
                        or      h
                        ld      h,a                         ; set the previou sign value
                        ret
        
                      