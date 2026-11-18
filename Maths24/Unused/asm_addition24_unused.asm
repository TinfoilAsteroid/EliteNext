; Routines moved out of Maths24/asm_addition24.asm as nothing in the eliteNext.asm build references them.
; Not included in the game build; INCLUDE this after asm_addition24.asm to use them again.

; 
HLequHLplusBC:          ld      a,h                             ; if BHL is negative
                        bit     7,h                            ; then 
                        jp      z,.CheckBC                  ;
.NegHL:                 res     7,h
                        NegHL                                  ;
.CheckBC                bit     7,b                           ; if CDE is negative
                        jp      z,.PerformAdd                   ;
.NegBC:                 res     7,b
                        NegBC                                  ; in DE
.PerformAdd:            ClearCarryFlag
                        adc     hl,bc
                        bit     7,h
                        ret     z
                        NegHL
                        set     7,h
                        ret

; variant on above for simplifying post multiply           ; d = e (saving d)
AHLequBHLminusDEC:      ld      a,d                        ; .
                        or      %10000000                  ; but we also flip the sign on the saved D
                        ld      d,e                        ; .
                        ld      e,c                        ; e = c
                        ld      c,a                        ; c = d (orginal value)
                        jp      AHLequBHLplusCDE

ResultIsZero:           pop     af                          ; get rid of unwanted sign bits
                        ld      c,e                         ; CDE = EHL as remainder
                        ex      hl,de
                        xor     a                           ; result AHL = $0
                        ld      h,a
                        ld      l,a                         ; .
                        ret

DivideByZero:           pop     af                          ; get rid of unwanted sign bits
                        ld      c,e                         ; CDE = EHL as remainder
                        ex      hl,de
                        ld      a,$FF                       ; result AHL = $FFFFFF
                        ld      hl,$FFFF                    ; .
                        SetCarryFlag                        ; and carry set
                        ret
