;Calculate A = arctan(P / Q)
; This finds the angle in the right-angled triangle where the opposite side to angle A is length P and the adjacent side to angle A has
; length Q, so:  tan(A) = P / Q
;
; The result in A is an integer representing the angle in radians. The routine returns values in the range 0 to 128,  (or 0 to PI radians).
ARCTAN:                 ld      a,(varP)                    ; LDA P                  \ Set T1 = P EOR Q, which will have the sign of P * Q
                        ld      hl,varQ                     ; EOR Q
                        xor     (hl)                        ; .
                        ld      (varT1),a                   ; STA T1
                        ld      a,(varQ)                    ; LDA Q                  \ If Q = 0, jump to AR2 to return a right angle
                        and     a                           ; BEQ AR2
                        jp      z, .AR2                     ; .
                        sla     a                           ; ASL A                  \ Set Q = |Q| * 2 (this is a quick way of clearing the
                        ld      (varQ),a                    ; STA Q                  \ sign bit, and we don't need to shift right again as we only ever use this value in the division with |P| * 2, which we set next)
                        ld      a,(varP)                    ; LDA P                  \ Set A = |P| * 2
                        sla     a                           ; ASL A
                        ld      (varP),a
                        ld      hl,varQ
                        cp      (hl)                        ; CMP Q                  \ If A >= Q, i.e. |P| > |Q|, jump to AR1 to swap P
                        jp      nc, .AR1                    ; BCS AR1                \ and Q around, so we can still use the lookup table
                        call    ARS1                        ; JSR ARS1               \ Call ARS1 to set the following from the lookup table:  A = arctan(A / Q)  = arctan(|P / Q|)
                        ClearCarryFlag                      ; SEC                    \ Set the C flag so the SBC instruction in AR3 will be correct, should we jump there
.AR4:                   ld      c,a                         ; as we have to use a we use c as a temp, we can't push af as we would loose flags on pop
                        ld      a,(varT1)                   ; LDX T1                 \ If T1 is negative, i.e. P and Q have different signs,
                        ld      b,a                         ; .
                        and     a                           ; BMI AR3                \ jump down to AR3 to return arctan(-|P / Q|)
                        ld      a,c                         ; .                      \ we need to get a back before jump
                        jp      m, .AR3                     ; .
                        ret                                 ; RTS                    \ Otherwise P and Q have the same sign, so our result is correct and we can return from the subroutine
; We want to calculate arctan(t) where |t| > 1, so we can use the calculation described in the documentation for the ACT table, i.e. 64 - arctan(1 / t)
; In the 6502 verion it works with A already being P but we will fetch it
.AR1:                   ld      a,(varQ)                    ; LDX Q                  \ Swap the values in Q and P, using the fact that we
                        ld      b,a                         ; .
                        ld      a,(varP)                    ; STA Q                  \ called AR1 with A = P
                        ld      (varQ),a                    ; .
                        ld      a,b                         ; TXA                    \ This also sets A = P (which now contains the original argument |Q|)
                        ld      (varP),a                    ; STX P                  \ 
                        call    ARS1                        ; JSR ARS1               \ Call ARS1 to set the following from the lookup table: A = arctan(A / Q) = arctan(|Q / P|) = arctan(1 / |P / Q|)
                        ld      (varT),a                    ; STA T                  \ Set T = 64 - T, we use B as T (its not really that)
                        ld      b,a                         ; its actually t = a, a = 64-a
                        ld      a,64                        ; LDA #64 What is going on here is t = result
                        ClearCarryFlag                      ; SBC T                            a = 64- result
                        sbc     a,b                         ; .
                        jp      .AR4                        ; BCS AR4                \ Jump to AR4 to continue the calculation (this BCS is effectively a JMP as the subtraction will never underflow, as ARS1 returns values in the range 0-31)
; If we get here then Q = 0, so tan(A) = infinity and A is a right angle, or 0.25 of a circle. We allocate 255 to a full circle, so we should return 63 for a right angle
.AR2:                   ld      a,63                        ; LDA #63                \ Set A to 63, to represent a right angle
                        ret                                 ; RTS                    \ Return from the subroutine
; A contains arctan(|P / Q|) but P and Q have different signs, so we need to return arctan(-|P / Q|), using the calculation described in the documentation for the ACT table, i.e. 128 - A
.AR3:                   ld      (varT),a
                        ld      b,a                         ; STA T                  \ Set A = 128 - A, we use b as T
                        ld      a,128                       ; LDA #128               \
                        ClearCarryFlag                      ; SBC T                  \ The subtraction will work because we did a SEC before calling AR3
                        sbc     a,b
                        ret                                 ; RTS                    \ Return from the subroutine
; This routine fetches arctan(A / Q) from the ACT table, so A will be set to an integer in the range 0 to 31 that represents an angle from 0 to 45 degrees (or 0 to \ PI / 4 radians)
ARS1:                   call    LL28Amul256DivQ_6502        ; JSR LL28               \ Call LL28 to calculate: R = 256 * A / Q
                        ld      a,(varR)                    ; LDA R                  \ Set X = R / 8
                        srl     a                           ; LSR A                  \       = 32 * A / Q
                        srl     a                           ; LSR A                  \ 
                        srl     a                           ; LSR A                  \ so X has the value t * 32 where t = A / Q, which is
                        ld      hl,ACT                      ; TAX                    \ what we need to look up values in the ACT table
                        add     hl,a                        ; LDA ACT,X              \ Fetch ACT+X from the ACT table into A, so now:
                        ld      a,(hl)                      ;                        \   A = value in ACT + X = value in ACT + (32 * A / Q)= arctan(A / Q)
                        ret                                 ; RTS                    \ Return from the subroutine
 
;;;arctan:										; .ARCTAN	\ -> &2A3C  \ A=TAN-1(P/Q) \ A=arctan (P/Q)  called from block E
;;;		ld		a,(varP)					; a = var P
;;;		ld		hl,varQ
;;;		xor		(hl)						; a = var p XOR varQ
;;;		ld		a,(varT1)					; \ T1	 \ quadrant info
;;;		ld		c,a							; c = copy of T1
;;;		ld		a,(hl)						; Q
;;;		cp		0
;;;		jr		z,.AR2						;  Q=0 so set angle to 63, pi/2
;;;		ld		(varQ),a					; Q move to reg B?
;;;		ld		d,a							; copy to reg d
;;;		sla		a							; drop sign
;;;		ld		a,(varP)					; P
;;;		ld		e,a							; copy to reg e
;;;		sla		a							; drop sign
;;;		cp		d							; compare with b (unsigned varQ * 2)
;;;		jr		nc, .ars1					; if q >  p then adjust  swop A and Q as A >= Q
;;;		call	ars1						; \ ARS1 \ get Angle for A*32/Q from table.
;;;		scf									; set carry flag 
;;;.ar4:										; sub o.k
;;;		bit 	7,c							; is T1 (also in c) negative?
;;;		jr		nz,.ar3						;  -ve quadrant
;;;		ret
;;;.ar1:										; swop A and Q entering here d = q and e = P
;;;		ld		a,d							; a = varQ
;;;		ld		d,e							; varQ = varP
;;;		ld		e,a							; swap D and E around
;;;		ld		(varP),a					; write to actual variables
;;;		ld		a,d
;;;		ld		(varQ),a					; write to actual variables
;;;		call	.ars1
;;;		ld		(varT),b
;;;		ld		b,a							; B = T = angle
;;;		ld		a,64						; next range of angle, pi/4 to pi/2
;;;		sub		a,b							; a = 64 - T (or b)
;;;		jr		nc,.ar4						;  sub o.k
;;;.ar2:										; .AR2	\ set angle to 90 degrees
;;;		ld 		a,&3F						;  #63
;;;		ret
;;;.ar3:										;.AR3	\ -ve quadrant
;;;		ld		b,a							; b = T	= \ angle
;;;		ld		a,ConstPi					; a = Pi
;;;		sub		b,a							; A = 128-T, so now covering range pi/2 to pi correctly
;;;		ret
;;;.ars1:										; .ARS1	\ -> &2A75  \ get Angle for A*32/Q from table.
;;;		call	RequAmul256divQ				;  LL28 \ BFRDIV R=A*256/Q
;;;		ld		a,(regA)
;;;		srl		a
;;;		srl		a
;;;		srl		a							;  31 max.
;;;		ld		hl, ArcTanTable				; root of index into table at end of words data
;;;		add		hl,a						; now at real data
;;;		ld		a,(hl)						; a =  ACT[a]
;;;.arsr:										; rts used by laser lines below (will not in later code)
;;;		ret



