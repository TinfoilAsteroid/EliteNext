; unsigned division dehl = dehl / dehl' dehl' = remainder carry clear,  div  by 0 = carry set everyhthing else untouched

; ahl  = EHL/DBC CARRY OVERFLOW FLAG
; dehl = dehl / dehjl'

divu32smallloop         MACRO
        
                        exx
                        rl      c                 ; bcbc << 1
                        rl      b
                        exx
                        rl      c
                        rla
    
                        exx
                        adc     hl,hl            ; hlhl << 1
                        exx 
                        adc     hl,hl
    
                        exx
                        sbc     hl,de            ; if hlhl > dede
                        exx 
                        sbc     hl,de
                        jr nc,  .skip_loop        ;   hlhl -= dede
                        
                        exx                  ;   
                        add     hl,de
                        exx 
                        adc     hl,de
.skip_loop:             ccf
                        ENDM


;INPUTS: ahl = dividend cde = divisor
;OUTPUTS: cde = quotient ahl = remainder
    DISPLAY "Needs ficxing for proper S15.8"
Div24by24:              push    de
                        push    hl
                        push    bc
                        exx
                        pop     de
                        ld      d,0
                        pop     hl
                        exx
                        pop     hl
                        ld      d,0
                        ld      e,0
                        jp      divs32
                        
        
; dehl = dehl' / dehl in our case it will be S78.0/ 0S78.0 to give us 0S78.0
divs32swap:             exx                     ;
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
; dehl = dehl' / dehl in our case it will be 78.80 / 078.8 to give us 078.8
divu32:                 ld a,d
                        or e
                        or h
                        or l
                        jp z, divide_by_zero
   ; try to reduce the division
begin:
                        xor     a
                        push    hl
                        exx
                        ld      bc,hl
                        pop     hl
                        push    de
                        ex      de,hl
                        ld      l,a
                        ld      h,a
                        exx
                        pop     bc
                        ld      l,a
                        ld      h,a
    
l1_small_divu_32_32x32: ; dede' = 32-bit divisor, bcbc' = 32-bit dividend, hlhl' = 0
                        ld      a,b
                        .32 divu32smallloop
                        
                        exx
                        rl c
                        rl b
                        exx
                        rl c
                        rla

   ; quotient  = acbc'
   ; remainder = hlhl'
   
                        push    hl
                        exx
                        pop     de
                        push    bc
                        exx
                        pop     hl
                        ld      e,c
                        ld      d,a
                        
                        ret

Amul256DivQ:            ld      hl,varQ                 ; CMP Q                  \ If A >= Q, then the answer will not fit in one byte,
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


divide_by_zero:
   
                    SetCarryFlag
                    ret

