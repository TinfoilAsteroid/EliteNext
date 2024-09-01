
    
FP88DIVITER:        MACRO
                    rla
                    adc hl,hl
                    add hl,de
                    jr c,.NoSubtract
                    sbc hl,de
.NoSubtract:        
                    ENDM
;HL = DE/BC as S7.8 Fixed Point maths, when doing 24 bit maths scale down to 8.8 as its accurate enough
;AHL = BHL/CDE, performed by scaling down BHL and CDE into two S8.8 values then calling fixedS7_8
fixedS23_8_divs:    ld      a,b               ; prep by saving off sign bit before shifting
                    xor     c
                    and     $80
                    ld      iyl,a
                    res     7,b                ; clear sign bits of and a
                    res     7,c                ;                    
.shiftRight24Loop:  ld      a,b                ; scaled down BHL and CDE to just HL and DE
                    or      c                  ;
                    jp      z,.ShiftRight16    ; if b and c are clear then we can just do 16 bit shift
                    ShiftBHLRight1             ;
                    ShiftCDERight1             ;
                    jp      .shiftRight24Loop  ;
.ShiftRight16Loop:  ld      a,h                ; scale now just HL and DE
                    or      d                  ; .
                    and     $80                ; .
                    jp      z,.ShiftComplete   ; .
                    ShiftHLRight1              ; .
                    ShiftDERight1              ; .
                    jp       ShiftRight16Loop  ; . 
.ShiftComplete:     set     0,c                ; fast way to ensure BC is at least not zero, in this case 0.0039 which means we can never have divide by 0
.checkZeroDivide:   ld      a,h                ; use the result is zero from below to save some code space
                    or      a                  ; .
                    jp      z,BC_Div_DE_88.resultIsZero
                    jp      BC_Div_DE_88NegateDE ; now we can just fall into a fixed S7.8 but after all the inital checks have been done

                    
;HL = DE/BC as S7.8 Fixed Point maths, when doing 24 bit maths scale down to 8.8 as its accurate enough
fixedS7_8_divs:     ld      bc,hl
BC_Div_DE_88:       
.checkSigns:        ld      a,b
                    xor     d
                    and     $80
                    ld      iyl,a               ; sign bit is the result sign bit held in iy as we want to optimise                    
.forcePositiveOnly: res     7,b                ; bc = abs b
.checkZeroDivide:   or      c                   ; optimisation, if bc was zero then result will be zero
                    jr      z,.resultIsZero     ; .
.forceNegativeDW:   res     7,d                 ; first force it positive 
.checkDivideZero:   ld      a,d
                    or      e                   ; as we are going to wipe a, do the divide by zero check here as an optimisation
                    jr      z,.divideOverflow    ; .
.NegateDE:          ZeroA                       ; now negate DE
                    sub     e                   ; .
                    ld 		e,a                 ; .
                    sbc 	a,a                 ; .
                    sub 	d                   ; .
                    ld 		d,a                 ; .
.overflowCheck:     ld      h,0                 ; prepare h = 0 for a slight optimise
                    ld      a,b                 ; if B+DE>=0, then we'll have overflow
                    add     e                   ; .
                    ld      a,d                 ; .
                    adc     a,0                 ; .
                    ld a,b
                    add a,e
                    ld a,d
                    adc a,h
                    jr c,.divideOverflow
.prepRemainder:     ld      l,b                 ; h is already 0 from overflow Check so now hl = 0b
                    ld      a,c                 ; and a = c
                    call div_S88_sub
                    ld      c,a
                    ld      a,b      ;A is now 0
                    call div_S88_sub
.CheckRounding:     add     hl,hl; if 2HL+DE>=0, increment result to round.
                    add     hl,de
                    ld      h,c
                    ld      l,a
                    jr      nc,.NoIncrementNeeded
                    inc     hl
.NoIncrementNeeded: bit 7,h                     ; Now check if H is overflowed
                    jr nz,.divideOverflow
                    ld      a,iyl               ; get back sign bit
                    or      h
                    ld      h,a                 ; now set h to correct sign
                    ClearCarryFlag              ; and we have a success
                    ret
.divideOverflow:    ld      l,$FF               ; hl = +/-128.255 signed
                    ld      a,iyl               ; .
                    or      $7F                 ; .
                    ld      h,a 
                    SetCarryFlag
                    ret
.resultIsZero       ZeroA                       ; doign it this way saves a couple of clock cycles as we get the carry clear for free even if setting hl takes an extra 2 cycles
                    ld      h,a
                    ld      l,a
                    ret    
div_S88_sub:        FP88DIVITER
                    FP88DIVITER
                    FP88DIVITER
                    FP88DIVITER
                    FP88DIVITER
                    FP88DIVITER
                    FP88DIVITER
                    FP88DIVITER
                    adc a,a
                    ret
                    
