;INPUTS: ahl = dividend cde = divisor
;OUTPUTS: cde = quotient ahl = remainder
Div24by24:              ld b,a   
                        push hl   
                        pop ix
                        ld l,24
                        push hl
                        xor a
                        ld h,a
                        ld l,a
.Div24by24loop:         add ix,ix
                        rl b
                        adc hl,hl
                        rla
                        cp c
                        jr c,.Div24by24skip
                        jr nz,.Div24by24setbit
                        sbc hl,de
                        add hl,de
                        jr c,.Div24by24skip
.Div24by24setbit:       sbc hl,de
                        sbc a,c
                        inc ix
.Div24by24skip:         ex (sp),hl
                        dec l
                        ex (sp),hl
                        jr nz,.Div24by24loop
                        pop de
                        ld c,b
                        push ix
                        pop de
                        ret
    IFDEF Div24by24ASigned_USED
Div24by24ASigned:       ld      iyh,a
                        and     SignMask8Bit
                        call    Div24by24
                        push    af
                        ld      a,iyh
                        and     SignOnly8Bit
                        or      c
                        ld      c,a
                        pop     af
                        ret
    ENDIF              
    IFDEF Div24by24LeadSign_USED

                        ; CDE = AHL/CDE, AHL = remainder
Div24by24LeadSign:      ld      iyh,a           ; Preserve signed in IYL
                        xor     c               ; flip sign if negative
                        and     SignOnly8Bit    ; .
                        ld      iyl,a           ; .
                        ld      a,c             ; make both values ABS
                        and     SignMask8Bit    ; .
                        ld      c,a             ; .
                        ld      a,iyh           ; .
                        and     SignMask8Bit    ; .
                        call    Div24by24       ; do abs divide
                        or      iyl             ; bring in sign bit
                        ld      iyh,a           ; save a
                        ld      a,c             ; sort sign for c
                        or      iyl             ; 
                        ld      c,a             ; 
                        ld      a,iyh           ; sort sign of a
                        ret
    ENDIF          
; --------------------------------------------------------------
;divdide by 16 using undocumented instrunctions
;Input: BC = Dividend, DE = Divisor, HL = 0
;Output: BC = Quotient, HL = Remainder
PROJ256mulAdivQ:        ld      b,a
                        ld      c,0
                        ld      d,0
                        ld      a,(varQ)
                        ld      e,a
PROJDIV16UNDOC:         ld      hl,0
                        ld      a,b 
                        ld      b,16
PROJDIV16UNDOCLOOP:     sll     c       ; unroll 16 times
                        rla             ; ...
                        adc     hl,hl       ; ...
                        sbc     hl,de       ; ...
                        jr      nc,PROJDIV16UNDOCSKIP       ; ...
                        add     hl,de       ; ...
                        dec     c       ; ...
PROJDIV16UNDOCSKIP:     djnz    PROJDIV16UNDOCLOOP
                        ld      a,c
                        ld      (varR),a
                        ret



                        