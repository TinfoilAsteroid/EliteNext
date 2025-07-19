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
; AHL = AHL/CDE
    DISPLAY "Needs ficxing for proper S15.8 result"
divs24:                 ld      b,a             ; preserve dividend sign
                        xor     c               ; now a holds sign bit
                        and     $80             ; 
                        ex      af,af'          ; save sign bit
                        res     7,b             ; now force an ABS divide
                        res     7,c
                        push    bc,,de          ; save divisor
.prepdivisor:           ld      d,b             ; prep DEHL'
                        ld      e,h             ; which trashes divisor
                        ld      h,l             ; .
                        ld      l,0             ; .
                        exx                     ; now save it over into dehl;
                        pop     de,,hl          ; force 0cde into dehl
                        ld      d,0
                        call    divu32          ; bcde.hl = dehl' / dehl
                        ex      af,af'          ; get sign back
                        or      d               ; set de.h to signed divide
                        ret
        
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


divide_by_zero:
   
                    SetCarryFlag
                    ret

