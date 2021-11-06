
LL28Amul256DivD:        JumpIfAGTENusng  d, .Ll28Exit255
                        ld      e,%11111110                 ; Set R to have bits 1-7 set, so we can rotate through 7
.LL31:                  sla     a                        
                        jr      c,.LL29
                        JumpIfALTNusng  d, .SkipSub         ; will jump if carry set, so we need to reset on the rol
                        sub     d
                        ClearCarryFlag                      ; reset clarry as it will be complimented for rotate as 6502 does carry flags inverted
.SkipSub:               ccf                                 ; if we did the subtract the carry will be clear so we need to invert to roll in.
                        rl      e
                        jr      c,.LL31
                        ld      a,e
                        ret
.LL29:                  sub     d                           ; A >= Q, so set A = A - Q
                        scf                                 ; Set the C flag to rotate into the result in R
                        rl      e                           ; rotate counter e left
                        jr      c,.LL31                     ; if a bit was spat off teh end then loop
                        ld      a,e                         ; stick result in a
                        ret
.Ll28Exit255:           ld  a,255                           ; Fail with FF as result
                        ret
