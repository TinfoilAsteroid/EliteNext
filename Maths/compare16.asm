; Input:
;       HL = 1st value
;       DE = 2nd value
; Output:
;       CF, ZF = results of comparison:
;
;               CF      ZF      Result
;               -----------------------------------
;               0       0       HL > DE
;               0       1       HL == DE
;               1       0       HL < DE
;               1       1       Impossible
;

compare16HLDE:      push    hl
                    and     a
                    sbc     hl,de
                    pop     hl
                    ret

; With compare signed we do ABS comparison
; this is used for view ports as we just want to know if its +/- out side of 90 degrees

compare16HLDEABS:   push    hl,,de
                    ld      a,h                                     ; Quick pass see of both the same sign
                    and     SignMask8Bit
                    ld      h,a
                    ld      a,d                                     ; Quick pass see of both the same sign
                    and     SignMask8Bit
                    ld      d,a
                    and     a
                    sbc     hl,de
                    pop     hl,,de
                    ret
                    
                   