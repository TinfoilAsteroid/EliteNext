
madXAequQmulAaddRS:                     ; .MAD	\ -> &22AD  \ Multiply and Add  (DE also) X.A(Lo.Hi) = Q*A + R.S (Lo.Hi)
    ld      ixh,a
	and		$7F
	ld      e,a
    ld      a,(varQ)
	ld		ixl,a
	and		$7F
    ld      d,a
madDEequDmulA
    mul                                 ;de = d * e
	ld		a,ixh
	xor		ixl
	and		$80
	or		d
	ld		d,a
madDEaddRS:
	ld		hl,(varR)
    ;ld      a,(varR)
    ;ld      l,a
    ;ld      a,(varS)
    ;ld      h,a
	call	ADDHLDESignedv3
;
;   add     hl,de                       ; hl = R.S + DE
    ex      de,hl                       ; de = R.S + DE
    ClearCarryFlag
    ld      ixl,e
    ld      a,d
    ret

; multiplication of two 16-bit numbers into a 16-bit product
; enter : de = 16-bit multiplicand
;         hl = 16-bit multiplicand
; exit  : hl = 16-bit product
;         carry reset
;
; uses  : af, bc, de, hl	
mulDEbyHL:              push    bc
                        ld a,d                      ; a = xh
                        ld d,h                      ; d = yh
                        ld h,a                      ; h = xh
                        ld c,e                      ; c = xl
                        ld b,l                      ; b = yl
                        mul                         ; yh * yl
                        ex de,hl
                        mul                         ; xh * yl
                        add hl,de                   ; add cross products
                        ld e,c
                        ld d,b
                        mul                         ; yl * xl
                        ld a,l                      ; cross products lsb
                        add a,d                     ; add to msb final
                        ld h,a
                        ld l,e                      ; hl = final
                        ; 83 cycles, 19 bytes
                        xor a                       ; reset carry
                        pop     bc
                        ret
; multiplication of two S156-bit numbers into a 16-bit 2'd compliment product
; enter : de = 16-bit multiplicand
;         hl = 16-bit multiplicand
; exit  : hl = 16-bit product
;         carry reset
;
; uses  : af, bc, de, hl	
mulDEbyHLSignByte       DB      0
mulDEbyHLSgnTo2c:       xor     a
                        ld      (mulDEbyHLSignByte),a 
.SignDE:                ld      a,d
                        test    $80
                        jr      z,.SignHL
.NegativeDE:            and     $7F
                        ld      d,a
                        ld      a,$80
                        ld      (mulDEbyHLSignByte),a
.SignHL:                ld      a,h
                        test    $80
                        jr      z,.AbsoluteMultiply
.NegativeHL:            and     $7F
                        ld      h,a
                        ld      a,(mulDEbyHLSignByte)
                        xor     $80
                        ld      (mulDEbyHLSignByte),a
.AbsoluteMultiply:      call    mulDEbyHL
.RecoverSign:           ld      a,(mulDEbyHLSignByte)
                        test    $80
                        ret     z
.Negateghl: 				xor 	a
                        sub 	l
                        ld 		l,a
                        sbc 	a,a
                        sub 	h
                        ld 		h,a
                        ret
                        
mulDESgnbyHLUnsgnTo2c:  xor     a
                        ld      (mulDEbyHLSignByte),a 
.SignDE:                ld      a,d
                        test    $80
                        jr      z,.AbsoluteMultiply
.NegativeDE:            and     $7F
                        ld      d,a
                        ld      a,$80
                        ld      (mulDEbyHLSignByte),a
.AbsoluteMultiply:      call    mulDEbyHL
.RecoverSign:           ld      a,(mulDEbyHLSignByte)
                        test    $80
                        ret     z
.Negateghl:             xor 	a
                        sub 	l
                        ld 		l,a
                        sbc 	a,a
                        sub 	h
                        ld 		h,a
                        ret                        
	    
