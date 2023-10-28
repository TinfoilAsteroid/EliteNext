
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

;-- Name: LL28 Calculate R = 256 * A / Q
;-- LL28+4              Skips the A >= Q check and always returns with C flag cleared, so this can be called if we know the division will work
;-- LL31                Skips the A >= Q check and does not set the R counter, so this can be used for jumping straight into the division loop if R is already set to 254 and we know the division will work
;   Reg mapping 6502  Z80
;               a     a
;               b     x
;               c     q
;               d     r
;               
LL28Amul256DivD_6502:   ld      hl,Qvar                 ; CMP Q                  \ If A >= Q, then the answer will not fit in one byte,
                        ld      c,(hl)                  ; using c as Q var
                        cp      c
                        FlipCarryFlag
                        jp      c, .LL2_6502            ; BCS LL2                \ so jump to LL2 to return 255
                        ld      b,$FE                   ; LDX #%11111110         \ Set R to have bits 1-7 set, so we can rotate through 7 loop iterations, getting a 1 each time, and then we use b as Rvar
.LL31_6502:             sla     a                       ; ASL A                  \ Shift A to the left
                        jp      c,.LL29_6502            ; BCS LL29               \ If bit 7 of A was set, then jump straight to the subtraction
                        FlipCarryFlag                   ;                          If A < N, then C flag is set.
                        JumpIfALTNusng c, .LL31_SKIPSUB_6502 ; CMP Q              \ If A < Q, skip the following subtraction
                                                        ; BCC P%+4
                        sub     c                       ; SBC Q                  \ A >= Q, so set A = A - Q
                        ClearCarryFlag
.LL31_SKIPSUB_6502:     FlipCarryFlag
                        rl      b                       ; ROL R                  \ Rotate the counter in R to the left, and catch the result bit into bit 0 (which will be a 0 if we didn't do the subtraction, or 1 if we did)
                        jp      c, .LL31_6502           ; BCS LL31               \ If we still have set bits in R, loop back to LL31 to do the next iteration of 7
                        ld      a,b
                        ld      (Rvar),a
                        ret                             ; RTS                    \ R left with remainder of division
.LL29_6502:             sub     c                       ; SBC Q                  \ A >= Q, so set A = A - Q
                        SetCarryFlag                    ; SEC                    \ Set the C flag to rotate into the result in R
                        rl      b                       ; ROL R                  \ Rotate the counter in R to the left, and catch the result bit into bit 0 (which will be a 0 if we didn't do the subtraction, or 1 if we did)
                        jp      c, .LL31_6502           ; BCS LL31               \ If we still have set bits in R, loop back to LL31 to do the next iteration of 7
                        ld      a,b                     ; RTS                    \ Return from the subroutine with R containing the
                        ld      (Rvar),a                ; .
                        ret                             ; .                      \ remainder of the division
.LL2_6502:              ld      a,$FF                   ; LDA #255               \ The division is very close to 1, so return the closest
                        ld      (Rvar),a                ; STA R                  \ possible answer to 256, i.e. R = 255
                        SetCarryFlag                    ; we failed so need carry flag set
                        ret                             ; RTS                    \ Return from the subroutine


LL28Amul256DivQ_6502:   ld      hl,varQ                 ; CMP Q                  \ If A >= Q, then the answer will not fit in one byte,
                        ld      c,(hl)                  ; using c as Q var
                        cp      c
                        FlipCarryFlag
                        jp      c, .LL2_6502            ; BCS LL2                \ so jump to LL2 to return 255
                        ld      b,$FE                   ; LDX #%11111110         \ Set R to have bits 1-7 set, so we can rotate through 7 loop iterations, getting a 1 each time, and then we use b as Rvar
.LL31_6502:             sla     a                       ; ASL A                  \ Shift A to the left
                        jp      c,.LL29_6502            ; BCS LL29               \ If bit 7 of A was set, then jump straight to the subtraction
                        FlipCarryFlag                   ;                          If A < N, then C flag is set.
                        JumpIfALTNusng c, .LL31_SKIPSUB_6502 ; CMP Q              \ If A < Q, skip the following subtraction
                                                        ; BCC P%+4
                        sub     c                       ; SBC Q                  \ A >= Q, so set A = A - Q
                        ClearCarryFlag
.LL31_SKIPSUB_6502:     FlipCarryFlag
                        rl      b                       ; ROL R                  \ Rotate the counter in R to the left, and catch the result bit into bit 0 (which will be a 0 if we didn't do the subtraction, or 1 if we did)
                        jp      c, .LL31_6502           ; BCS LL31               \ If we still have set bits in R, loop back to LL31 to do the next iteration of 7
                        ld      a,b
                        ld      (varR),a
                        ret                             ; RTS                    \ R left with remainder of division
.LL29_6502:             sub     c                       ; SBC Q                  \ A >= Q, so set A = A - Q
                        SetCarryFlag                    ; SEC                    \ Set the C flag to rotate into the result in R
                        rl      b                       ; ROL R                  \ Rotate the counter in R to the left, and catch the result bit into bit 0 (which will be a 0 if we didn't do the subtraction, or 1 if we did)
                        jp      c, .LL31_6502           ; BCS LL31               \ If we still have set bits in R, loop back to LL31 to do the next iteration of 7
                        ld      a,b                     ; RTS                    \ Return from the subroutine with R containing the
                        ld      (varR),a                ; .
                        ret                             ; .                      \ remainder of the division
.LL2_6502:              ld      a,$FF                   ; LDA #255               \ The division is very close to 1, so return the closest
                        ld      (varR),a                ; STA R                  \ possible answer to 256, i.e. R = 255
                        SetCarryFlag                    ; we failed so need carry flag set
                        ret                             ; RTS                    \ Return from the subroutine
