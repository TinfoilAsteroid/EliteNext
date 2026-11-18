; Routines moved out of Maths24/asm_normalise24.asm as nothing in the eliteNext.asm build references them.
; Not included in the game build; INCLUDE this after asm_normalise24.asm to use them again.

PrepScale:              MACRO                       ;setg [A IYH] to or'ed all bytes of ABS X,Y,Z
                        ld      a,h                 
                        or      d
                        or      c
                        ld      iyh,a
                        ld      a,l
                        or      e
                        or      c
                        or      1                   ; we can never have a status where hl,de,bc are 0 but we will force bit 1 to be safe
                        ENDM

CalculateScale:         MACRO
                        ld      iyl,a
                        exx                         ; save off registers so we can use altgernates for barrel shift calc
                        ld      b,0             
                        ld      de,iy               ; moving iy to de for faster bit and shift operations
                        ; as we ABS then bit 7 can never have been set anmd we want to stop after setting bit 6 so max range is 16129 (127 ^ 2)
.ScaleLoop:             bit     6,d                 ; this loop will find the minium number of shifts requried
                        jp      nz,.DoneShift       ; if bit 6 is set then we have done enough shifts
                        ShiftDELeft1
                        inc     b
                        jp      .ScaleLoop
.DoneShift              ld      a,b                 ; b is all we are interestred in so save it in IYL
                        exx                         ; now we have the vector coords recovered
                        ENDM

SquareX:                MACRO
                        ex      de,hl
                        mul     de
                        ex      de,hl
                        ENDM

SquareY:                MACRO
                        mul     de
                        ENDM

SquareZ:                MACRO
                        ld      de,bc
                        mul     de                  ; d * e
                        ENDM
