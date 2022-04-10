
; HL(2sc) = HL (signed) + A (unsigned), uses HL, DE, A
HL2cEquHLSgnPlusAusgn:  ld      d,0
                        ld      e,a                         ; set up DE = A
                        ld      a,h
                        and     SignMask8Bit
                        jr      z,.HLPositive               ; if HL is negative then do HL - A
.HLNegative:            ld      h,a                         ; hl = ABS (HL)
                        NegHL                               ; hl = - hl
.HLPositive:            ClearCarryFlag                      ; now do adc hl,de
                        adc     hl,de                       ; aftert his hl will be 2's c
                        ret

HLEquHLSgnPlusAusgn:    ld      e,a
                        ld      a,h
                        and     SignMask8Bit
                        jr      nz,.HLNegative              ; if HL is negative then do HL - A
.HLPositive:            ld      a,e                         ; else its HL + A
                        add     hl,a
                        ret
.HLNegative:            ClearSignBit    h                   ; Clear sign of HL
                        NegHL                               ; and convert to 2's C
                        ld      d,0
                        ClearCarryFlag
                        sbc     hl,de                       ; now add a to -ve HL , add does not do 2's c
                        jp      m,.FlipResult               ; if it was negative then its really positive
                        SetSignBit      h
                        ret
.FlipResult:            NegHL                               ; so if -hl + A => HL - A => HL - DE is negative then the actual result is +ve
                        ret
                        
                        

; HL = HL (signed) + A (unsigned), uses HL, DE, A
AddAusngToHLsng:        ld      d,a
                        ld      e,h
                        ld      a,h
                        and     SignMask8Bit
                        ld      h,a
                        ld      a,d
                        add     hl,a
                        ld      a,e
                        and     SignOnly8Bit
                        or      h
                        ret
; HL = A (unsigned) - HL (signed), uses HL, DE, BC, A
HLEequAusngMinusHLsng:  ld      b,h
                        ld      c,a
                        ld      a,b
                        and     SignOnly8Bit
                        jr      nz,.DoAdd
.DoSubtract:            ex      de,hl               ; move hl into de
                        ld      h,0                 ; hl = a
                        ld      l,c
                        ClearCarryFlag
                        sbc     hl,de               ; hl = a - hl
                        ret
.DoAdd:                 ld      a,c
                        add hl,a
                        ret 
;tested mathstestsun2
; DEL = DEL + BCH signed, uses BC, DE, HL, IY, A
AddBCHtoDELsigned:      ld      a,b                 ; Are the values both the same sign?
                        xor     d                   ; .
                        and     SignOnly8Bit        ; .
                        jr      nz,.SignDifferent   ; .
.SignSame:              ld      a,b                 ; if they are then we only need 1 signe
                        and     SignOnly8Bit        ; so store it in iyh
                        ld      iyh,a               ;
                        ld      a,b                 ; bch = abs bch
                        and     SignMask8Bit        ; .
                        ld      b,a                 ; .
                        ld      a,d                 ; del = abs del
                        and     SignMask8Bit        ; .
                        ld      d,a                 ; .
                        ld      a,h                 ; l = h + l
                        add     l                   ; .
                        ld      l,a                 ; . 
                        ld      a,c                 ; e = e + c + carry
                        adc     e                   ; .
                        ld      e,a                 ; .
                        ld      a,b                 ; d = b + d + carry (signed)
                        adc     d                   ; 
                        or      iyh                 ; d = or back in sign bit
                        ld      d,a                 ; 
                        ret                         ; done
.SignDifferent:         ld      a,b                 ; bch = abs bch
                        ld      iyh,a               ; iyh = b sign
                        and     SignMask8Bit        ; .
                        ld      b,a                 ; .
                        ld      a,d                 ; del = abs del
                        ld      iyl,a               ; iyl = d sign
                        and     SignMask8Bit        ; .
                        ld      d,a                 ; .
                        push    hl                  ; hl = bc - de
                        ld      hl,bc               ; if bc < de then there is a carry
                        sbc     hl,de               ;
                        pop     hl                  ;
                        jr      c,.BCHltDEL
                        jr      nz,.DELltBCH        ; if the result was not zero then DEL > BCH
.BCeqDE:                ld      a,h                 ; if the result was zero then check lowest bits
                        JumpIfALTNusng l,.BCHltDEL
                        jr      nz,.DELltBCH
; The same so its just zero
.BCHeqDEL:              xor     a                  ; its just zero
                        ld      d,a                ; .
                        ld      e,a                ; .
                        ld      l,a                ; .
                        ret                        ; .
;BCH is less than DEL so its DEL - BCH the sort out sign
.BCHltDEL:              ld      a,l                ; l = l - h                      ; ex
                        sub     h                  ; .                              ;   01D70F DEL
                        ld      l,a                ; .                              ;  -000028 BCH
                        ld      a,e                ; e = e - c - carry              ;1. 
                        sbc     c                  ; .                              ;
                        ld      e,a                ; .                              ;
                        ld      a,d                ; d = d - b - carry              ;
                        sbc     b                  ; .                              ;
                        ld      d,a                ; .                              ;
                        ld      a,iyl              ; as d was larger, take d sign
                        and     SignOnly8Bit       ;
                        or      d                  ;
                        ld      d,a                ;
                        ret
.DELltBCH:              ld      a,h                ; l = h - l
                        sub     l                  ;
                        ld      l,a                ;
                        ld      a,c                ; e = c - e - carry
                        sbc     e                  ;
                        ld      e,a                ;
                        ld      a,b                ; d = b - d - carry
                        sbc     d                  ;
                        ld      d,a                ;
                        ld      a,iyh              ; as b was larger, take b sign into d
                        and     SignOnly8Bit       ;
                        or      d                  ;
                        ld      d,a                ;
                        ret

                        
;BHL = AHL + DE where AHL = 16 bit + A sign and DE = 15 bit signed    
AddAHLtoDEsigned:       ld      b,a                     ; B = A , C = D (save sign bytes)
                        ld      c,d                     ; .
                        xor     c                       ; A = A xor C
                        res     7,d                     ; clear sign bit of D
                        jr nz,  .OppositeSigns          ; if A xor C is opposite signs job to A0A1
                        add     hl,de                   ; HL = HL + DE
                        ret                             ; return 
.OppositeSigns:         sbc     hl,de                   ; HL = HL -DE
                        ret     nc                      ; if no carry return
                        add     hl,de                   ; else HL = HL + DE
                        ex      de,hl                   ;      swap HL and DE
                        and     a                       ;      reset carry
                        sbc     hl,de                   ;      HL = DE - HL (as they were swapped)
                        ld      b,c                     ;      B = sign of C
                        ret                             ;      ret



; a = value to add
; b = offset (equivalent to regX)
; returns INWK [x] set to new value
addINWKbasigned:
		ld 		hl,UBnKxlo                  ; hl = INWK 0
		ld      c,a                         ; preserve a
		ld		a,b
		add		hl,a                        ; hl = INWK[x]
        ld      a,c                         ; get back a value
        and     $80                         ; get sign bit from a
        ld      b,a                         ; now b = sign bit of a
        ld      a,c                         ; a = original value
        and     SignMask8Bit                ; a = unsigned version of original value
; hl = unsigned version of INWK0[b]
; a = value to add, also in c which will optimise later code
; b = sign bit of a ( in old code was varT)
addhlcsigned:                              
        ld      e,(hl)                      ; de = INKK value
        inc     hl
        ld      d,(hl)
        inc     hl                          ; now pointing a sign
        ld      a,(hl)                      ; a = sign bit
        ex      de,hl                       ; hl = value now and de = pointer to sign
        xor     b                           ; a = resultant sign
        bit     7,a                         ; is it negative?
        jr      z,.postivecalc              
.negativecalc:        
        ld      a,h
        and     SignMask8Bit
        ld      h,a                         ; strip high bit
        ld      ixl,b                       ; save sign bit from b into d
        ld      b,0                         ; c = value to subtract so now bc = value to subtract
        sbc     hl,bc     
        ld      b,ixl                       ; get sign back
        ex      de,hl                       ; de = value hl = pointer to sign
        ld      a,(hl)                      ;
        and     SignMask8Bit
        sbc     a,0                         ; subtract carry which could flip sign bit
        or      $80                         ; set bit 0
        xor     b                           ; flip bit on sign (var T)
        ld      (hl),a
        dec     hl
        ld      (hl),d
        dec     hl
        ld      (hl),e                      ; write out DE to INKW[x]0,1
        ex      de,hl                       ; hl = value de = pointer to start if INKW[x]
        ret     c                           ; if carry was set then we can exit now
.nocarry:        
        call    negate16hl                  ; get hl back to positive, a is still inkw+2
        or      b                           ; b is still varT
        ex      de,hl                       ; de = value hl = pointer to start if INKW[x]
        ld      (hl),e
        inc     hl
        ld      (hl),d
        inc     hl
        ld      (hl),a                      ; set sign bit in INKK[x]+2
        ex      de,hl                       ; hl = value de = pointer to sign
        ret
.postivecalc:
        ld      ixl,b
        ld      b,0
        add     hl,de
        ex      de,hl
        or      ixl                         ; we don;t need to recover b here
        ld      (hl),a                      ; push sign into INWK[x]
        dec     hl
        ld      (hl),d
        dec     hl
        ld      (hl),e
        ret
        
;a = a AND 80 (i.e. bit 7) =>carry       so value is -
;MVT1
;    S = bits 6 to 0 of A
;    A = sign bit => T
;    xor sign bit with ink[x] Sign
;    if negative thn its not an add
;
;        and h, 7F
;        b = 0
;        c = varS
;        subtract INW[X]hilo, bc
;        retain carry
;        get INKW[x]Sign
;        and 7F
;        subtract carry (so will go negtive if negative)
;        xor bit 7 of h with T to flip bit
;        write to INKW[x]Sign
;
;    else
;MV10.
;        add INWK[x]hi,lo, varS
;        or      sign bit
        
