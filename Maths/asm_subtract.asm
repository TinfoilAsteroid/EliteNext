;...subtract routines
; we could cheat, flip the sign of DE and just add but its not very optimised
SUBHLDESigned:          ld      a,h
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
        
;;WordSignedSubtract:         MACRO   x1,x1sgn, x2, x2sgn, resultx, resultsgn, completionexit
;;                            ld      a,(x1sgn)
;;                            ld      b,a
;;                            ld      hl,x2sgn
;;                            xor     (hl)
;;                            and     $80
;;                            jr      nz,.xSignsDifferent
;;.xSignsSame:                ld      hl,(x1)
;;                            ld      de,(x2)
;;                            sbc     hl,de
;;                            jp      p,.xSameDone
;;.xSameNeg:                  NegHL
;;                            ld      a,$80
;;                            xor     b
;;                            ld      b,a
;;.xSameDone:                 ld      (resultx),hl
;;                            ld      a,b
;;                            ld      (resultsgn),a
;;                            jp      completionexit
;;.xSignsDifferent:           ld      hl,(x1)
;;                            ld      de,(x2)
;;                            add     hl,de
;;                            ld      (resultx),hl
;;                            ld      a,b
;;                            ld      (resultsgn),a
;;                            ENDM
;;
;;; HL(2sc) = HL (signed) - A (unsigned), uses HL, DE, A
;;HL2cEquHLSgnPMinusAusgn:ld      d,0
;;                        ld      e,a                         ; set up DE = A
;;                        ld      a,h
;;                        and     SignMask8Bit
;;                        jr      z,.HLPositive               ; if HL is negative then do HL - A
;;.HLNegative:            ld      h,a                         ; hl = ABS (HL)
;;                        NegHL                               ; hl = - hl
;;.HLPositive:            ClearCarryFlag                      ; now do adc hl,de
;;                        sbc     hl,de                       ; aftert his hl will be 2's c
;;                        ret
;;
;;; HL = HL (signed) - A (unsigned), uses HL, DE, A
;;SubAusngFromHLsng:      ld      d,a
;;                        ld      e,h
;;                        ld      a,h
;;                        and     SignMask8Bit
;;                        ld      h,a
;;                        ld      a,d
;;                        add     hl,a
;;                        ld      a,e
;;                        and     SignOnly8Bit
;;                        or      h
;;                        ret
;;; HL = A (unsigned) - HL (signed), uses HL, DE, BC, A
;;HLEequAusngMinusHLsng:  ld      b,h
;;                        ld      c,a
;;                        ld      a,b
;;                        and     SignOnly8Bit
;;                        jr      nz,.DoAdd
;;.DoSubtract:            ex      de,hl               ; move hl into de
;;                        ld      h,0                 ; hl = a
;;                        ld      l,c
;;                        ClearCarryFlag
;;                        sbc     hl,de               ; hl = a - hl
;;                        ret
;;.DoAdd:                 ld      a,c
;;                        add hl,a
;;                        ret 
;;
;;
;;TacticsPosMinusTarget:      WordSignedSubtract UBnKxlo, UBnkxsgn, CurrentTargetXpos, CurrentTargetXsgn, .ProcessY
;;.ProcessY:                  WordSignedSubtract UBnKylo, UBnkysgn, CurrentTargetYpos, CurrentTargetYsgn, .ProcessZ
;;.ProcessZ:                  WordSignedSubtract UBnKzlo, UBnkzsgn, CurrentTargetZpos, CurrentTargetZsgn, .ProcessDone
;;.ProcessDone                ret
;;                            
                           