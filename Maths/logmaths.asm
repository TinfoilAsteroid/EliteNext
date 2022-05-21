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