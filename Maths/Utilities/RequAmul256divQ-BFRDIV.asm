;;;LL28:
;;;    ld      c,a                         ; 
;;;    ld      a,(varQ)                    ; 
;;;    ld      b,a                         ; 
;;;    ld      a,c                         ; Get varQ into b and retain c
;;;RequAmul256divB:                        ;
;;;LL28Breg:
;;;; "BFRDIV R = (A * 256 / Q)  byte from remainder of division, not signed a = a, b = q, c = r"
;;;	cp		b							; Check A >= Q
;;;	jr		nc, .AnswerTooBig			; A >= Q? yes too big
;;;.CalcRemainder:
;;;	ld		c, 	$FE						; set R to $FE
;;;.RollRemainder:
;;;	sla		a
;;;	jr		c,.Reduce					; if a >> generates carry reduce
;;;	cp		b							; a < q?
;;;	jr		nc,.DontSBC
;;;.DoSBC:									; a is < q 
;;;	sbc		a,b							; 	a -= q
;;;.DontSBC:	
;;;	rl		c							; r << 1									
;;;	jr		c, .RollRemainder			; if rol generated a carry, continue
;;;    ld      a,c
;;;    ld      (varR),a
;;;	ret									; R (c) left with remainder
;;;.Reduce:								; a geneated a carry
;;;	sbc		a,b							; a = a - (q +1)
;;;	scf									; set carry flag for rl
;;;	rl		c							; r << 1 briging in carry
;;;	jr		c,	.RollRemainder			; if a carry fell off bit 7 then repeat
;;;    ld      a,c
;;;    ld      (varR),a
;;;	ret
;;;.AnswerTooBig:
;;;	ld	    c,$FF							; arse its too big
;;;    ld      a,c
;;;    ld      (varR),a
;;;	ret
	
BCequAmul256DivC:
  ld    e,c
  ld    h,a
  ld    l,0
AdivEDivide:                             ; this routine performs the operation BC=HL/E
  ld a,e                                 ; checking the divisor; returning if it is zero
  or a                                   ; from this time on the carry is cleared
  ret z
  ld bc,-1                               ; BC is used to accumulate the result
  ld d,0                                 ; clearing D, so DE holds the divisor
AdivEDivLoop:                            ; subtracting DE from HL until the first overflow
  sbc hl,de                              ; since the carry is zero, SBC works as if it was a SUB
  inc bc                                 ;  note that this instruction does not alter the flags
  jr nc,AdivEDivLoop                     ; no carry means that there was no overflow
  ret
	
HL_Div_C:
; Integer divides HL by C
; Result in HL, remainder in A
; Clobbers F, B
        ld b,16
        xor a
HL_Div_C_Loop:        
        add hl,hl
        rla
        cp c
        jr c,HL_DivC_Skip
        sub c
        inc l
HL_DivC_Skip:        
        djnz HL_Div_C_Loop
        ld   a,l
        ld  (varR),a
        ret

LL28:
RequAmul256divQ:				; Entry point if varQ is populated with demoninator
BFRDIV:
		push	af
		ld		a,(varQ)
		ld		c,a
		pop		af
		cp		0
		jp		z, HLDIVC_0_BY	; fast exit if numerator is 0
RequAmul256divC:
		ld		l,0
		ld		h,a
HL_Div_Cold:						; fast entry point if C and HL are already set
		ld b,16
		xor a
LOOPPOINT:	   
		add hl,hl
		rla
		cp c
		jr c,SKIPINCSUB
		inc l
		sub c
SKIPINCSUB:
		djnz LOOPPOINT
		ld		a,l
		ld 		(varR),a
		ret
HLDIVC_0_BY:
		ld		(varR),a
		ret
;	push	af
;	ld		a,b
;	ld		(varQ),a
;	pop		af
;RequAmul256divQ:
;BFRDIV:									;BFRDIV R=A*256/Q   byte from remainder of division 
;	ld		hl,varQ
;	JumpIfAGTENusng	(hl),LL2			;  is A >=  Q ?, if yes, answer too big for 1 byte, R=#&FF
;	ld		b,$FE						; b = X 
;	ld		c,a							; c = R	div roll counter
;LL31:									; roll R
;	sla		a
;	jr		c,LL29						; hop to Reduce
;	JumpIfALTNusng (hl)					; Q skip sbc if a < Q
;	sbc		a,(hl)						; a = a - Q
;	rl		c							; rotate R left
;	jr		c,LL31						; loop if R poped out a carry bit
;	jr		LL2Good
;LL29:									; Reduce 
;	sbc		a,(hl)
;	scf
;	rl		c							; roll a carry flag into R
;	jr		c,LL31						;  loop R
;	jr		LL2Good
;LL2:
;	ld		c,$FF
;LL2Good:
;	ld		a,c
;	ld		(varR),a
;	ret
