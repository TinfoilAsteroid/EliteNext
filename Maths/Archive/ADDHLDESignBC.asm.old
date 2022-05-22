;; calcs HLB + DEC where B and C are signs
;; result HL with A as sign
;; special handling if result is zero forcign sign bit to be zero
ADDHLDESignBC:          ld      a,b
                        and     SignOnly8Bit
                        xor     c                           ;if b sign and c sign were different then bit 7 of a will be 1 which means 
                        JumpIfNegative ADDHLDEsBCOppSGN     ;Signs are opposite there fore we can subtract to get difference
ADDHLDEsBCSameSigns:    ld      a,b
                        or      c
                        JumpIfNegative ADDHLDEsBCSameNeg        ; optimisation so we can just do simple add if both positive
                        add     hl,de                       ; both positive so a will already be zero
                        ret
ADDHLDEsBCSameNeg:      add     hl,de
                        ld      a,b
                        or      c                           ; now set bit for negative value, we won't bother with overflow for now TODO
                        ret
ADDHLDEsBCOppSGN:       or      a
                        sbc     hl,de
                        jr      c,ADDHLDEsBCOppInvert
ADDHLDEsBCOppSGNNoCarry: ld      a,b                                               ; we got here so hl > de therefore we can just take hl's previous sign bit
                        ret
ADDHLDEsBCOppInvert:    NegHL                         ; if result was zero then set sign to zero (which doing h or l will give us for free)
                        ld      a,b
                        xor     SignOnly8Bit                ; flip sign bit
                        ret   
                        