



;...subtract routines
; we could cheat, flip the sign of DE and just add but its not very optimised
; DEPRECATED subHLDES15Old:             ld      a,h                         ; set b to sign HL
; DEPRECATED                         and     SignOnly8Bit                ; .
; DEPRECATED                         ld      b,a                         ; .
; DEPRECATED                         xor     d                           ; if h sign and d sign were different then bit 7 of a will be 1 which means 
; DEPRECATED                         JumpIfNegative .SUBHLDEOppSGN       ; Signs are opposite therefore we can add and take the sign of hl as the resujlt
; DEPRECATED                         ; when theyh are both the same sign, subtract HL = |HL| - |DE|, if result is negative flip its sign 
; DEPRECATED .SUBHLDESameSigns:      ld      a,b
; DEPRECATED                         or      d
; DEPRECATED                         JumpIfNegative .SUBHLDESameNeg       ; optimisation so we can just do simple add if both positive
; DEPRECATED                         ClearCarryFlag
; DEPRECATED                         sbc     hl,de
; DEPRECATED                         JumpIfNegative .SUBHLDESameOvrFlw            
; DEPRECATED                         ret
; DEPRECATED .SUBHLDESameNeg:        ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit
; DEPRECATED                         and     SignMask8Bit                ; we could check the value of b for optimisation
; DEPRECATED                         ld      h,a
; DEPRECATED                         ld      a,d
; DEPRECATED                         and     SignMask8Bit
; DEPRECATED                         ld      d,a
; DEPRECATED                         ClearCarryFlag
; DEPRECATED                         sbc     hl,de
; DEPRECATED                         JumpIfNegative .SUBHLDESameOvrFlw            
; DEPRECATED                                             DISPLAY "TODO:  don't bother with overflow for now"
; DEPRECATED                         ld      a,h                         ; now set bit for negative value, we won't bother with overflow for now TODO
; DEPRECATED                         or      SignOnly8Bit
; DEPRECATED                         ld      h,a
; DEPRECATED                         ret
; DEPRECATED .SUBHLDESameOvrFlw:     NegHL
; DEPRECATED                         ld      a,b
; DEPRECATED                         xor     SignOnly8Bit                ; flip sign bit
; DEPRECATED                         or      h
; DEPRECATED                         ld      h,a                         ; recover sign
                        ret         
                        ; if we have opposite signs we can do an abs add and take the sign on hl
.SUBHLDEOppSGN:         res     7,h                         ; clear hl sign bit
                        res     7.d                         ; clear de sign bit
                        add     hl,de
                        ld      a,b                         ; now set lead sign of hl to the saved sign in b
                        or      h                           ; .
                        ld      h,a                         ; and after that we are done
                        ret
        
                      