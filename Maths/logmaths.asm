logmaths_page_marker    DB "LogMaths   PG99"

AntiLogHL:              ex      de,hl
                        ld      hl,LogReverseHighByte
                        ld      bc,LogReverseTableLen
                        ld      a,d
.SearchLoop:            cpi                                     ; first pass index into high byte
                        jr      z,.FoundHighByte
                        inc     hl
                        jr      .SearchLoop
.FoundHighByte:         inc     hl                              ; now we have high double it for table of words
                        ld      a,(hl)                          ; .
                        ld      hl,LogTable                     ; .
                        add     hl,a                            ; .
                        add     hl,a                            ; .
.LookForLowByteLoop:    ld      a,d                             ; search for low byte or change in high byte
                        cp      (hl)
                        jr      nz,.SkippedPastHigh
                        inc     hl
                        ld      a,e
                        JumpIfAGTENusng (hl), .SkippedPastLow
                        jp      .LookForLowByteLoop

.SkippedPastHigh:       dec     hl                              ; for high we are on next word
.SkippedPastLow:        dec     hl                              ; for low we are no next byte
                        ex      de,hl                           ; move address to de for subtract
                        ld      hl,LogTable                     ; subtract from log table address
                        ClearCarryFlag
                        sbc     hl,de                           ; so nwo we have nbr of words, i.e anito log * 2
                        ShiftHLRight1                           ; now must be >= 255
                        ld      a,l
                        ret

; calculates R = 256 * A / Q
Requ256mulAdivQ_Log:    JumpIfAGTEMemusng varQ, LL2             ; If A >= Q, then the answer will not fit in one byte, return 255
                        ld      iyl,a                           ; STA widget             \ Store A in widget, so now widget = argument A
                        ld      ixh,a                           ; TAX                    \ Transfer A into X, so now X = argument A
                        JumpIfAIsZero LLfix                     ; If A = 0, jump to LLfix to return a result of 0
; calculate log(A) - log(Q), first adding the low bytes (from the logL table), and then the high bytes (from the log table)
; this determins if we branch to antilog or antilogodd for negative value
.GetLogA:               ld      hl,LogTable                     ; LDA logL,X             \ e = low byte of log(X)
                        add     hl,a                            ; have to add twice as ist 8 bit so cant shift
                        add     hl,a                            ;
                        ld      e,(hl)                          ;
                        inc     hl                              ;
                        ld      d,(hl)                          ; de = logH[X] logL[X]
                        ld      hl,LogTable                     ;
                        ld      a,(varQ)                        ;
                        add     hl,a                            ;
                        add     hl,a                            ;
                        ld      c,(hl)                          ;
                        inc     hl                              ;
                        ld      b,(hl)                          ; bc = logH[X] logL[X]
                        ld      a,e                             ; SBC logL,X             \       = low byte of log(A) - low byte of log(Q)
                        ClearCarryFlag                          ; .
                        sbc     a,c                             ; .
                        jp      nc,NoCarryBranch
CarryBranch:            jp      m,.noddlog                     ; BMI noddlog            \ If the subtraction is negative, jump to noddlog
                        ld      e,a                             ; save logL[A] - logL[Q] in e, probabyl dont need this
                        ld      a,d                             ; a = logH(a)
.CarryFlagPoint1:       SetCarryFlag
                        sbc     a,b                             ; a = high byte of logH[A] - logH[Q] note carry is not affected from prev sbc
                        jp      nc,LL2                          ; If the subtraction fitted into one byte and didn't underflow, then log(A) - log(Q) < 256, so we jump to LL2 return a result of 255
                        ld      hl,AntiLogTable                 ; TAX                    \ Otherwise we return the A-th entry from the antilog
                        add     hl,a                            ; LDA antilog,X          \ table
                        ld      a,(hl)
                        ld      (varR),a                        ; STA R                  \ Set the result in R to the value of A
                        ret                                     ; RTS                    \ Return from the subroutine
.noddlog:               ld      a,d                             ; LDX widget             \ Set d = high byte of log(A) - high byte of log(Q)
.CarryFlagPoint2:       SetCarryFlag
                        sbc     a,b
                        jp      nc,LL2                          ; BCS LL2                \ If the subtraction fitted into one byte and didn't underflow, then log(A) - log(Q) < 256, so we jump to LL2 to return a result of 255
                        ld      hl, AnitLogODDTable             ; TAX                    \ Otherwise we return the A-th entry from the antilogODD
                        add     hl,a                            ; LDA antilogODD,X       \ table
                        ld      a,(hl)
                        ld      (varR),a                        ; STA R                  \ Set the result in R to the value of A
                        ret                                     ; RTS                    \ Return from the subroutine
NoCarryBranch:          jp      m,.noddlog                     ; BMI noddlog            \ If the subtraction is negative, jump to noddlog
                        ld      e,a                             ; save logL[A] - logL[Q] in e, probabyl dont need this
                        ld      a,d                             ; a = logH(a)
.CarryFlagPoint1:       ClearCarryFlag
                        sbc     a,b                             ; a = high byte of logH[A] - logH[Q] note carry is not affected from prev sbc
                        jp      nc,LL2                          ; If the subtraction fitted into one byte and didn't underflow, then log(A) - log(Q) < 256, so we jump to LL2 return a result of 255
                        ld      hl,AntiLogTable                 ; TAX                    \ Otherwise we return the A-th entry from the antilog
                        add     hl,a                            ; LDA antilog,X          \ table
                        ld      a,(hl)
                        ld      (varR),a                        ; STA R                  \ Set the result in R to the value of A
                        ret                                     ; RTS                    \ Return from the subroutine
.noddlog:               ld      a,d                             ; LDX widget             \ Set d = high byte of log(A) - high byte of log(Q)
.CarryFlagPoint2:       ClearCarryFlag
                        sbc     a,b
                        jp      nc,LL2                          ; BCS LL2                \ If the subtraction fitted into one byte and didn't underflow, then log(A) - log(Q) < 256, so we jump to LL2 to return a result of 255
                        ld      hl, AnitLogODDTable             ; TAX                    \ Otherwise we return the A-th entry from the antilogODD
                        add     hl,a                            ; LDA antilogODD,X       \ table
                        ld      a,(hl)
                        ld      (varR),a                        ; STA R                  \ Set the result in R to the value of A
                        ret                                     ; RTS                    \ Return from the subroutine
LLfix:                  ld      (varR),a                        ; Set the result in R to the value of A
                        ret                                     ; RTS                    \ Return from the subroutine
LL2:                    ld      a,$FF
                        ld      (varR),a
                        ret


AEquAmul256DivBLogLT:   JumpIfAIsZero   .ResultIsZero
                        ld      hl,LogTable                     ; de = log a
                        add     hl,a                            ; .
                        add     hl,a                            ; .
                        ld      e,(hl)                          ; .
                        inc     hl                              ; .
                        ld      d,(hl)                          ; .
                        ld      hl,LogTable                     ; hl = log b
                        ld      a,b                             ; .
                        add     hl,a                            ; .
                        add     hl,a                            ; .
                        ld      a,(hl)                          ; .
                        inc     hl                              ; .
                        ld      h,(hl)                          ; .
                        ld      l,a                             ; .
                        ClearCarryFlag                          ;
                        ex      de,hl                           ; now hl = log a and de = log b
                        sbc     hl,de                           ; hl = log a - log b
                        ld      a,h                             ; .
                        ld      hl,AnitLogODDTable               ; hl = anti log (log a - log b)
                        add     hl,a                            ; which is also a / b
                        add     hl,a                            ; .
                        ld      a,(hl)                          ; .
                        ClearCarryFlag                          ;
                        ret
.ResultIsZero:          ClearCarryFlag
                        ZeroA
                        ret          
                        
AEquAmul256DivBLog:     JumpIfAIsZero   .ResultIsZero
                        JumpIfAGTENusng d, AEquAmul256DivBLogLT
                        ld      hl,LogTable                     ; de = log a
                        add     hl,a                            ; .
                        add     hl,a                            ; .
                        ld      e,(hl)                          ; .
                        inc     hl                              ; .
                        ld      d,(hl)                          ; .
                        ld      hl,LogTable                     ; hl = log b
                        ld      a,b                             ; .
                        add     hl,a                            ; .
                        add     hl,a                            ; .
                        ld      a,(hl)                          ; .
                        inc     hl                              ; .
                        ld      h,(hl)                          ; .
                        ld      l,a                             ; .
                        ClearCarryFlag                          ;
                        ex      de,hl                           ; now hl = log a and de = log b
                        sbc     hl,de                           ; hl = log a - log b
                        jr      c,.ResultIsOne                  ; .
                        ld      a,h                             ; .
                        ld      hl,AntiLogTable                 ; hl = anti log (log a - log b)
                        add     hl,a                            ; which is also a / b
                        add     hl,a                            ; .
                        ld      a,(hl)                          ; .
                        ClearCarryFlag                          ;
                        ret
.ResultIsOne:           ClearCarryFlag
                        ld      a,$FF
                        ret                        
.ResultIsInfinte:       SetCarryFlag
                        ld      a,$FF
                        ret
.ResultIsZero:          ClearCarryFlag
                        ret                        

AEquAmul256Div197LogLT: JumpIfAIsZero   .ResultIsZero
                        ld      hl,LogTable                     ; point to log a in LogTable
                        add     hl,a                            ; Note we can't sla in case a > 127
                        add     hl,a
                        ld      e,(hl)                          ; de = log a
                        inc     hl                              ; .
                        ld      d,(hl)                          ; .
                        ld      hl,$F3A9                        ; hl = $F3A9 = log 197
                        ClearCarryFlag
                        ex      hl,de                           ; hl = log a, de = log 197
                        sbc     hl,de
                        ld      a,h
                        ld      hl,AnitLogODDTable
                        add     hl,a
                        add     hl,a
                        ld      a,(hl)
                        ClearCarryFlag
                        ret
.ResultIsZero:          ClearCarryFlag
                        ZeroA
                        ret                        


AEquAmul256Div197Log:   JumpIfAIsZero   .ResultIsZero
                        JumpIfAGTENusng d, AEquAmul256Div197LogLT
                        ld      hl,LogTable                     ; point to log a in LogTable
                        add     hl,a                            ; Note we can't sla in case a > 127
                        add     hl,a
                        ld      e,(hl)                          ; de = log a
                        inc     hl                              ; .
                        ld      d,(hl)                          ; .
                        ld      hl,$F3A9                        ; hl = $F3A9 = log 197
                        ClearCarryFlag
                        ex      hl,de                           ; hl = log a, de = log 197
                        sbc     hl,de
                        jr      c,.ResultIsOne
                        ld      a,h
                        ld      hl,AntiLogTable
                        add     hl,a
                        add     hl,a
                        ld      a,(hl)
                        ClearCarryFlag
                        ret
.ResultIsOne:           ClearCarryFlag
                        ld      a,$FF
                        ret                        
.ResultIsZero:          ClearCarryFlag
                        ret

AEquAmul256Div197LogSignA:
                        ld      iyh,a
                        ClearSignBitA
                        call    AEquAmul256Div197Log
                        ld      b,a
                        ld      a,iyh
                        SignBitOnlyA
                        or      b
                        ret                            