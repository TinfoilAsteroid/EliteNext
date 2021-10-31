
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
        
