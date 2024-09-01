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
CompareDEHLunsigned:ex      de,hl
                    push    hl
                    and     a
                    sbc     hl,de
                    pop     hl
                    ex      de,hl
                    ret
CompareHLDEunsigned:push    hl
                    and     a
                    sbc     hl,de
                    pop     hl
                    ret
                    
CompareBCDESigned:  push    hl
                    and     a
                    ld      hl,bc
                    sbc     hl,de
                    pop     hl
                    ret

CompareDEBCSigned:  push    hl
                    and     a
                    ld      hl,de
                    sbc     hl,bc
                    pop     hl
                    ret                    


;### CMPGTE -> test if A>=B
;### Input      HL=A, DE=B if hl=> de no carry else de > hl and set carry
CompareHLDESgn:     ld a,h
                    xor d
                    jp m, .cmpgte2
                    sbc hl,de
                    jr nc, .cmpgte3
.cmpgte1            add hl,de
                    SetCarryFlag
                    ret
.cmpgte2            bit 7,d
                    jr z,.cmpgte4
.cmpgte5:           ClearCarryFlag
                    ret                    
.cmpgte3            add hl,de
                    ClearCarryFlag
                    ret
.cmpgte4:           SetCarryFlag
                    ret                 

; Compares HL and DE sets z flag if same, else nz
CompareHLDESame:    ld  a,h
                    cp  d
                    ret nz
                    ld  a,l
                    cp  e
                    ret

                    

CompareHLBCSgn:     ld a,h
                    xor b
                    jp m, .cmpgte2
                    sbc hl,bc
                    jr nc, .cmpgte3
.cmpgte1            SetCarryFlag
                    ret
.cmpgte2            bit 7,b
                    jr z,.cmpgte1
.cmpgte3            ClearCarryFlag
                    ret

CompareHLDESigned:
compare16HLDE:      push    hl
                    and     a
                    sbc     hl,de
                    pop     hl
                    ret
CompareHLBCSigned:
CompareHLBC:        push    hl
                    and     a
                    sbc     hl,bc
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
                    
                   