AequAdivDmul96Unsg:     JumpIfAGTENusng d, .Unity    			; if A >= Q then return with a 1 (unity i.e. 96)
                        ld          b,%11111111                 ; Loop through 8 bits
.DivLoop:               sla         a                           ; shift a left
                        JumpIfALTNusng d, .skipSubtract         ; if a < q skip the following
                        sub         d
.skipSubtract:          FlipCarryFlag
                        rl          b
                        jr          c,.DivLoop
                        ld          a,b
                        srl         a                  			; t = t /4
                        srl			a							; result / 8
                        ld          b,a
                        srl         a
                        add			a,b							; result /8 + result /4
                        ret
.Unity:                 ld			a,$60	    				; unity
                        ret
	
    
HLequSRmulQdiv256:      ;X.Y=x1lo.S*M/256  	\ where M/256 is gradient
                        ld  hl,(varRS)
                        ld  a,(varQ)
HLeqyHLmulAdiv256:      push    bc,,de
                        ld  de,0        ; de = XY
                        ld  b,a         ; b = Q
                        ShiftHLRight1
                        sla b
                        jr  nc,.LL126
.LL125:                 ex de,hl
                        add hl,de       
                        ex  de,hl       ; de = de + rs
.LL126:                 ShiftHLRight1
                        sla b
                        jr      c,.LL125
                        jr      nz,.LL126
                        ex      de,hl   ; hl = result
                        pop     bc,,de                        
                        ret

; FMLTU - A = A * Q / 256    
AequAmulQdiv256usgn:    ld      d,a
                        ld      a,(varQ)
                        ld      e,a
asm_defmutl:
; "ASM_FMUTKL .FMLTU	\ -> &2847  \ A=D*E/256unsg  Fast multiply"
AequDmulEdiv256usgn:    mul     de
                        ld	a,d				; we get only the high byte which is like doing a /256 if we think of a as low
                        ret

    
; muliptiply S7d ny S7e signed
; used A and B registers
; result in DE
mulDbyESigned:          ld      a,d
                        xor     e
                        and     SignOnly8Bit
                        ld      b,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a
                        ld      a,e
                        and     SignMask8Bit
                        ld      e,a
                        mul     de
                        ld      a,d
                        or      b
                        ld      d,a
                        ret
                       


MacroDEEquQmulASigned:  MACRO
                        ld      d,a                         ; save a into d
                        ld      a,(varQ)
                        ld      e,a
                        xor     d                           ; a = a xor var Q
                        and     SignOnly8Bit
                        ld      b,a                         ; b = sign of a xor q
                        ld      a,d                         ; d = abs d (or a reg)
                        and     SignMask8Bit 
                        ld      d,a                     
                        ld      a,e                         ; e = abs e (or varQ)
                        and     SignMask8Bit
                        ld      e,a 
                        mul                                 ; de = a * Q
                        ld      a,d
                        or      b                           ; de = a * Q leading sign bit 
                        ld      d,a
                        ENDM

                        

                   ; .MAD	\ -> &22AD  \ Multiply and Add  (DE also) X.A(Lo.Hi) = Q*A + R.S (Lo.Hi)
madXAequQmulAaddRS:     MacroDEEquQmulASigned
                        ld		hl,(varR)
                        call	madXAAddHLDESigned
                        ex      de,hl                       ; de = R.S + DE
                        ClearCarryFlag
                        ld      ixl,e
                        ld      a,d
                        ret

madDEequQmulAaddRS:     MacroDEEquQmulASigned
                        ld		hl,(varR)
                        call	madXAAddHLDESigned
                        ex      de,hl                       ; de = R.S + DE
                        ClearCarryFlag
                        ret

madXAAddHLDESigned:     ld      a,h
                        and     SignOnly8Bit
                        ld      b,a                         ;save sign bit in b
                        xor     d                           ;if h sign and d sign were different then bit 7 of a will be 1 which means 
                        JumpIfNegative .ADDHLDEOppSGN        ;Signs are opposite there fore we can subtract to get difference
.ADDHLDESameSigns:       ld      a,b
                        or      d
                        JumpIfNegative .ADDHLDESameNeg       ; optimisation so we can just do simple add if both positive
                        add     hl,de
                        ret
.ADDHLDESameNeg:         ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit
                        and     SignMask8Bit                ; we could check the value of b for optimisation
                        ld      h,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a
                        add     hl,de
                        ld      a,SignOnly8Bit
                        or      h                           ; now set bit for negative value, we won't bother with overflow for now TODO
                        ld      h,a
                        ret
.ADDHLDEOppSGN:          ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit                     ; here HL and DE are opposite 
                        and     SignMask8Bit                ; we could check the value of b for optimisation
                        ld      h,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a
                        or      a
                        sbc     hl,de
                        jr      c,.ADDHLDEOppInvert
.ADDHLDEOppSGNNoCarry:   ld      a,b                         ; we got here so hl > de therefore we can just take hl's previous sign bit
                        or      h
                        ld      h,a                         ; set the previou sign value
                        ret
.ADDHLDEOppInvert:       NegHL                                                   ; we need to flip the sign and 2'c the Hl result
                        ld      a,b
                        xor     SignOnly8Bit                ; flip sign bit
                        or      h
                        ld      h,a                         ; recover sign
                        ret 

   
    ; multiplication of 16-bit number and 8-bit number into a 24-bit product
    ;
    ; enter : hl = 16-bit multiplier   = x
    ;          e =  8-bit multiplicand = y
    ;
    ; exit  : ahl = 24-bit product
    ;         carry reset
    ;
    ; uses  : af, de, hl
AHLequHLmulE:           ld d,h                      ; xh
                        ld h,e                      ; yl
                        mul de                      ; xh*yl
                        ex de,hl
                        mul de                      ; yl*xl, hl = xh*yl
                    
                        ld  a,d                     ; sum products
                        add a,l
                        ld  d,a
                        ex de,hl
                    
                        ld  a,d
                        adc a,0
                        ret

HLE0quH0mulE:           ld      d,h                 ; .
                        ld      h,e                 ; .
                        mul     de                  ; de = xh * yl
                        ex      de,hl
                        ret

   ; multiplication of two 16-bit numbers into a 32-bit product
   ;
   ; enter : de = 16-bit multiplicand = y
   ;         hl = 16-bit multiplicand = x
   ;
   ; exit  : dehl = 32-bit product
   ;         carry reset
   ;
   ; uses  : af, bc, de, hl
   
   

DEHLequDEmulHL:         ld b,l                      ; x0
                        ld c,e                      ; y0
                        ld e,l                      ; x0
                        ld l,d
                        push hl                     ; x1 y1
                        ld l,c                      ; y0
; bc = x0 y0, de = y1 x0,  hl = x1 y0,  stack = x1 y1
                        mul de                      ; y1*x0
                        ex de,hl
                        mul de                      ; x1*y0
                        
                        xor a                       ; zero A
                        add hl,de                   ; sum cross products p2 p1
                        adc a,a                     ; capture carry p3
                        
                        ld e,c                      ; x0
                        ld d,b                      ; y0
                        mul de                      ; y0*x0
                        
                        ld b,a                      ; carry from cross products
                        ld c,h                      ; LSB of MSW from cross products
                        
                        ld a,d
                        add a,l
                        ld h,a
                        ld l,e                      ; LSW in HL p1 p0
                        
                        pop de
                        mul de                      ; x1*y1
                        
                        ex de,hl
                        adc hl,bc
                        ex de,hl                    ; de = final MSW
                        
                        ret
   
; multiplication of two 16-bit numbers into a 16-bit product
; enter : de = 16-bit multiplicand
;         hl = 16-bit multiplicand
; exit  : hl = 16-bit product
;         carry reset
; maths is 
;        hl = y , de= x
;        hl = xhi,ylo + (yhigh * xlow)
;        hl = yhih & xlo + x
;
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

; multiplication of 16-bit numbers by 8-bit product
; enter : de = 16-bit multiplicand
;          l = 8-bit multiplicand
; exit  : hl = 16-bit product
;         carry reset
; maths is 
;        hl = y , de= x
;        hl = xhi,ylo + (yhigh * xlow)
;        hl = yhih & xlo + x
;
;
; uses  : af, bc, de, hl	
mulDEbyLSigned:         push    bc,,hl,,de
                        ld a,d                      ; a = xh
                        ld d,0                      ; d = yh = 0
                        ld h,a                      ; h = xh
                        ld c,e                      ; c = xl
                        ld b,l                      ; b = yl
;                        mul                         ; yh * xl which will always be 0
                        ex de,hl                    ; de = xh yl
                        mul                         ; xh * yl
                        ex de,hl                    ; hl = xh * yl
;                        add hl,de                   ; add cross products
                        ld e,c                      ; de = yl xl
                        ld d,b                      ; .
                        mul                         ; yl * xl
                        ld a,l                      ; cross products lsb
                        add a,d                     ; add to msb final
                        ld h,a
                        ld l,e                      ; hl = final
                        xor a                       ; reset carry
                        pop     bc                  ; get de for sign
                        ld      a,b
                        pop     bc                  ; get hl for sign
                        xor     b
                        and     $80                 ; so we now have the sign bit
                        or      h                   ; so set the sign
                        ld      h,a                 ; .
                        pop     bc                  ; clear up stack
                        ret

    DISPLAY "TODO: TEST"
mulDEbyHLSigned:        ld  a,d                     ; de = abs de
                        ld  b,a                     ;
                        and     $7F                 ; .
                        ld  d,a                     ; .
                        ld  a,h                     ; hl = abs hl
                        ld  c,a                     ; .
                        and     $7F                 ; . 
                        ld      h,a                 ; .
                        ld      a,c                 ; ixl = target sign of de * hl
                        xor     d                   ;
                        and     $80                 ;
                        ld      ixl,a               ;
                        call    mulDEbyHL           ; calculate ABS(DE) * ABS(HL)
                        ld      a,h                 ; recover sign bit
                        or      ixl
                        ld      h,a
                        ret

; CHL = multiplicand D = multiplier
; DCHL = CHL * D
mulCHLbyDSigned:        ld      a,d                 ; get sign from d
                        xor     h                   ; xor with h to get resultant sign
                        and     SignOnly8Bit        ; .
                        ld      iyh,a               ; iyh = copy of sign
                        ld      a,c                 ; now CHL = ABS (CHL)
                        and     SignMask8Bit        ; .
                        ld      c,a                 ; .
                        ld      a,d                 ; d = ABS D
                        and     SignMask8Bit        ; .
; At this point CHL = ABS (HLE), A = ABS(D)                        
.mul1:                  ld      d,a                 ; first do D * L
                        ld      e,l                 ; .
                        mul     de                  ; DE = L * D
                        ex      af,af'              ; save multiplier
                        ld      l,e                 ; L = p0
                        ld      a,d                 ; carry byte
                        ex      af,af'              ; retrieve muliplier and save carry byte along with flags
.mul2:                  ld      e,h                 ; byte 2 of multiplicand
                        ld      d,a                 ; and multiplier
                        mul     de                  ; now its D & L
                        ex      af,af'              ; get back carry byte with flags
.carrybyte1:            add     a,e                 ; add low byte carry to result and retain carry too through next instructions
                        ld      h,a                 ; h = P1
                        ld      a,d                 ; a = carry byte
                        ex      af,af'              ; save carry byte and get back multiplier with flags
.mul3:                  ld      e,c                 ; byte 3 of multiplicand
                        ld      d,a                 ; 
                        mul     de                  ;
                        ex      af,af'              ; get back carry byte and carry prior to first add
                        adc     a,e                 ;
                        or      iyh                 ; recover saved resultant sign
                        ld      c,a                 ; c byte 3. Note the value range allowed can never cause a byte 3 carry
                        ret

;  CHL = 53456 D = 1E
;  56 * 1E = A14 L = 14 carry = 0A
;  34 * 1E = 618 H = 18 +A = 22 carry = 6
;  5  * 1E = 096 C = 96 + 6 = 9C
;  CHL = 9C2214
;mult3
; DELC = HLE * D, uses HL, DE, C , A , IYH
; HLE = multiplicand D = multiplier
; tested by mathstestsun.asm all passed
; Algorithm
; AC =  E * D   (save carry)         H    L    E
; DE =  L * D                                  D
;  L =  A + E + carry                         E*D (lo)
; DE =  H * D                             L*D+ ^ (hi)
;  E =  A + E + carry                H*D (lo) + carry
;                                
;
mulHLbyDE2sc:           ld      a,d
                        xor     h
                        and     SignOnly8Bit
                        ld      iyh,a               ; save sign bit for result
                        ld      a,h
                        and     SignOnly8Bit
                        jr      z,.HLPositive
.HLNegative:            NegHL
.HLPositive:            ld      a,d
                        and     SignOnly8Bit
                        jr      z,.DEPositive
.DENegative:            NegDE
.DEPositive:            call    mulDEbyHL           ; now do calc
                        ld      a,iyh
                        and     a                   ; if its 0 then we are good
                        ret     z
                        

; Mulitply HLE by D leading Sign
; used IY A BC
; result it loaded to DELC
mulHLEbyDSigned:        ld      a,d                 ; get sign from d
                        xor     h                   ; xor with h to get resultant sign
                        and     SignOnly8Bit        ; .
                        ld      iyh,a               ; iyh = copy of sign
                        ld      a,h                 ; now HLE = ABS (HLE)
                        and     SignMask8Bit        ; .
                        ld      h,a                 ; .
                        ld      a,d                 ; d = ABS D
                        and     SignMask8Bit        ; .
                        ld      d,a                 ; .
.testEitherSideZero:    or      a
                        jr      z,.ResultZero
                        ld      a,h
                        or      l
                        or      e
                        jr      z,.ResultZero
; At this point HLE = ABS (HLE), A = ABS(D) 
                        ld      b,d                 ; save Quotient
.mul1:                  mul     de                  ; C = E * D             
                        ld      c,e                 ; C = p0
                        ld      iyl,d               ; save carry (p1)
.mul2:                  ld      e,l                 ; L = L * D
                        ld      d,b                 ; .
                        mul     de                  ; .
                        ld      a,iyl               ; get back p1
.carrybyte1:            add     a,e                 ; L = L + E
                        ld      l,a                 ; .
                        ld      iyl,d               ; save new carry byte
.mul3:                  ld      e,h                 ; E = H * D
                        ld      d,b                 ; .
                        mul     de                  ; .
                        ld      a,iyl
                        adc     a,e                 ; .
                        ld      e,a                 ; .
.ItsNotZero:            ld      a,d                 ;
                        adc     a,0                 ; final carry bit
                        or      iyh                 ; bring back sign
                        ld      d,a                 ; s = sign
                        ret
.ResultZero:            ld      de,0
                        ZeroA
                        ld      c,a
                        ld      l,a
                        ret

;;;
;;;
;;;mulHLEbyDSigned:        ld      a,d                 ; get sign from d
;;;                        xor     h                   ; xor with h to get resultant sign
;;;                        and     SignOnly8Bit        ; .
;;;                        ld      iyh,a               ; iyh = copy of sign
;;;                        ld      a,h                 ; now HLE = ABS (HLE)
;;;                        and     SignMask8Bit        ; .
;;;                        ld      h,a                 ; .
;;;                        ld      a,d                 ; d = ABS D
;;;                        and     SignMask8Bit        ; .
;;;                        ld      d,a                 ; .
;;;.testEitherSideZero:    or      a
;;;                        jr      z,.ResultZero
;;;                        ld      a,h
;;;                        or      l
;;;                        or      e
;;;                        jr      z,.ResultZero
;;;; At this point HLE = ABS (HLE), A = ABS(D)                        
;;;.mul1:                  mul     de                  ; C = E * D             
;;;                        ex      af,af'              ; save mulitplier
;;;                        ld      c,e                 ; C = p0
;;;                        ld      a,d                 ; save carry (p1)
;;;                        ex      af,af'              ; .
;;;.mul2:                  ld      e,l                 ; L = L * D
;;;                        ld      d,a                 ; .
;;;                        mul     de                  ; .
;;;                        ex      af,af'              ; .
;;;.carrybyte1:            add     a,e                 ; L = L + E
;;;                        ld      l,a                 ; .
;;;                        ld      a,d
;;;                        ex      af,af'              ; save new carry byte
;;;.mul3:                  ld      e,h                 ; E = H * D
;;;                        ld      d,a                 ; .
;;;                        mul     de                  ; .
;;;                        ex      af,af'              ; .
;;;                        adc     a,e                 ; .
;;;                        ld      e,a                 ; .
;;;.ItsNotZero:            ld      a,d                 ;
;;;                        adc     a,0                 ; final carry bit
;;;                        or      iyh                 ; bring back sign
;;;                        ld      d,a                 ; s = sign
;;;                        ret
;;;.ResultZero:            ld      de,0
;;;                        ZeroA
;;;                        ld      c,a
;;;                        ld      l,a
;;;                        ret
 
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
.Negateghl: 			xor 	a
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
	    
