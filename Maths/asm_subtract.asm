;...subtract routines

WordSignedSubtract:         MACRO   x1,x1sgn, x2, x2sgn, resultx, resultsgn, completionexit
                            ld      a,(x1sgn)
                            ld      b,a
                            ld      hl,x2sgn
                            xor     (hl)
                            and     $80
                            jr      nz,.xSignsDifferent
.xSignsSame:                ld      hl,(x1)
                            ld      de,(x2)
                            sbc     hl,de
                            jp      p,.xSameDone
.xSameNeg:                  NegHL
                            ld      a,$80
                            xor     b
                            ld      b,a
.xSameDone:                 ld      (resultx),hl
                            ld      a,b
                            ld      (resultsgn),a
                            jp      completionexit
.xSignsDifferent:           ld      hl,(x1)
                            ld      de,(x2)
                            add     hl,de
                            ld      (resultx),hl
                            ld      a,b
                            ld      (resultsgn),a
                            ENDM




TacticsPosMinusTarget:      WordSignedSubtract UBnKxlo, UBnkxsgn, CurrentTargetXpos, CurrentTargetXsgn, .ProcessY
.ProcessY:                  WordSignedSubtract UBnKylo, UBnkysgn, CurrentTargetYpos, CurrentTargetYsgn, .ProcessZ
.ProcessZ:                  WordSignedSubtract UBnKzlo, UBnkzsgn, CurrentTargetZpos, CurrentTargetZsgn, .ProcessDone
.ProcessDone                ret
                            
                           