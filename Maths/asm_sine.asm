;- MACROS
LookupSineAMacro:       MACRO
                        ld      hl,SNE                      ; Set Q = sin(X)  = sin(CNT2 mod 32) = |sin(CNT2)|
                        add     hl, a
                        ld      a,(hl)
                        ENDM
                        
; Gets the sine of A from the lookup table into A
LookupSineA:            LookupSineAMacro
                        ret
                        