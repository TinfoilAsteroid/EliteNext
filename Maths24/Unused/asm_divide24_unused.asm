; Routines moved out of Maths24/asm_divide24.asm as nothing in the eliteNext.asm build references them.
; Not included in the game build; INCLUDE this after asm_divide24.asm to use them again.

divs32swap:             exx                     ;

; dehl = dehl' / dehl in our case it will be S78.0/ 0S78.0 to give us 0S78.0
divs32:                 ld      a,e             ; get sign bit from divisor
                        exx                     ; swap to get dividend sign bit
                        xor     d               ; .
                        exx                     ; then swap back for normal compute
                        and     $80             ; but we can then save sign bit to stack
                        push    af              ; .
                        call    divu32          ; perform divide
                        pop     af              ; get sign bit
                        or      e               ; as result will be in ehl that we want
                        ld      e,a             ; we ignore d reg
                        ret

divu32swap:             exx
; NOTE: originally falls through into divu32 in asm_divide24.asm
