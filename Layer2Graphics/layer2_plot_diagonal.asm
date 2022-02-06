
l2_draw_box_to:
; ">l2_draw_box_to bc=rowcol, de=torowcol a=color"
; ">NOT IMPLEMENTED YET"
	ret
	
;; Note l2stepx is done via self modifying code rather than an if for speed
;; l2stepx1 and l2stepx2 are the addresses to stick the inc or dec in
l2decbstep	EQU $05
l2incbstep	EQU	$04
l2deccstep	EQU $0D
l2inccstep	EQU	$0C
		; l2 deltas are signed 
l2deltaY	DW	0
l2deltaX	DW	0
l2deltaYsq	db	0
l2deltaXsq	db	0
l2deltaYn	db	0
l2deltaXn	db	0
l2deltaYsqn	db	0
l2deltaXsqn	db	0
l2linecolor	db	0
l2fraction	dw	0
l2e2		dw	0
l2way		db	0
l2targetPtr	dw	0
;; These arrays should be 192 but if we use 256 then getting array2 value is just inc h rather than indexing again.
l2targetArray1 ds	256
l2targetArray2 ds	256
;; Using Bresenham Algorithm draw a diagonal line top to bottom. First we must sort of course
;;plotLine(int x0, int y0, int x1, int y1)
;;    dx =  abs(x1-x0);
;;    sx = x0<x1 ? 1 : -1;
;;    dy = -abs(y1-y0);
;;    sy = y0<y1 ? 1 : -1;
;;    err = dx+dy;  /* error value e_xy */
;;    while (true)   /* loop */
;;        plot(x0, y0);
;;        if (x0==x1 && y0==y1) break;
;;        e2 = 2*err;
;;        if (e2 >= dy) /* e_xy+e_x > 0 */
;;            err += dy;
;;            x0 += sx;
;;        end if
;;        if (e2 <= dx) /* e_xy+e_y < 0 */
;;            err += dx;
;;            y0 += sy;
;;        end if
;;    end while
; ">l2_draw_diagonal_save, bc = y0,x0 de=y1,x1,a=array nbr ESOURCE LL30 or LION"
; ">hl will be either l2targetArray1 or 2"	
; NOTE IF WE INTERLEAVE THESE TWO TABLES WE COUDL READ BOTH X POS as a 16 bit read
l2_draw_diagonal_save:  cp		1
                        jr		z,l2S_ItsArray1
                        ld		hl,l2targetArray2
                        jp		l2S_setTarget
l2S_ItsArray1:	        ld		hl,l2targetArray1
l2S_setTarget:	        ld		(l2targetPtr),hl
; ">l2_draw_diagonal, bc = y0,x0 de=y1,x1,a=color) Thsi version performs a pre sort based on y axis"
                        ld		(l2linecolor),a					;save colour for later
                        ld		hl,0                            ;
                        ld		(l2deltaX),hl                   ;
                        ld		(l2deltaY),hl                   ; initlaise deltas as we will only be loading 8 bit in there but workign in 16 bit later
l2S_preSort:            ld		a,b								;
                        JumpIfALTNusng	d,l2S_noYSort			; we must have Y1 < Y2 (if eqyal then verical line picked up earlier
l2S_SortBasedOnY:	    ldhlbc									;
                        ex		de,hl                           ;
                        ldbchl									; swap over bc and de using hl as an intermediate
l2S_noYSort:		    ld		ixh,d							; ixh now holds target Y coord post sorting
                        ld		ixl,e							; ixl now holds target X coord post sorting
l2S_setXLen:            ld		a,c                             ;
                        JumpIfALTNusng e,l2S_PosXLen			; if x1 < x2 then we have a positive increment
l2S_NegXLen:            ld		a,c                             ; 
                        sub     e                               ; 
                        ld		(l2deltaX),a					; As x1 > x2 we do deltaX = X1 - X2
                        ld		a,l2deccstep					; and set the value for inc dec self modifying to Dec
                        jr		l2S_XINCDEC
l2S_PosXLen:	        ld		a,e                             ; 
                        sub		c                               ; 
                        ld 		(l2deltaX),a                    ; As x1 < x2 we do deltaX = X2 - X1
                        ld		a,l2inccstep                    ; and set the value for inc dec self modifying to Inc
l2S_XINCDEC:	
	ld		(l2S_adjustCol),a				;
	ld		(l2S_adjustCol2),a				; update self modifying code for X update with inc or dec from above
l2S_setYLen						
	ld		a,d							 	; presorted on Y so it is now always positive
	sub		b
	ld 		(l2deltaY),a					; DeltaY = Y2 - Y1
l2S_setErr:									;  LD H  := (D'-E')/2    round up if +ve or down if -ve
ldS_FracDYltDX:								; 
	ld		hl,(l2deltaY)					; Fraction = dY - dX
	ld		de,(l2deltaX)
	ClearCarryFlag	
	sbc		hl,de							; sbc does not have an SBC IY so need to do this in HL
	ex		de,hl
	ld		iyh,d							; we will use IY reg for fractions
	ld		iyl,e	
	jp		p,l2S_fracIsPositive
l2S_fracIsNegative:
	NegIY
	ShiftIYRight1
	NegIY
	jp		l2S_SkipCalcInc					; so we have a negative frac
l2S_fracIsPositive:
	ShiftIYRight1
l2S_SkipCalcInc:	
l2S_Loop:									; As we loop, bc = to plot current XY
	ld		hl,(l2targetPtr)				; Insert into respective array
	ld		a,b
	add		hl,a
	ld		(hl),c
l2S_CheckIfEnd:	
	ld		a,ixh
	JumpIfAGTENusng	  b,l2S_CheckXPos		; if Y1 < Y2 then continue regardless, when it hits Y2 then we must check X1 and X2
	jp		l2S_Continue
l2S_CheckXPos:
	ld		a,c
	ReturnIfAGTENusng ixl					; if X1 has reached or exceeded X2 then we are done
l2S_Continue:
l2S_HNegative:					
	ld		a,iyh
	bit		7,a								; if its negative then we need to deal with delta Y, there is no bit n,iyh instrunction
	jr		z,l2S_ErrNotNegative			;
l2S_ErrNegative:								; if its a negative error update X
	ld		a,(l2deltaY)
	ld		d,0
	ld		e,a
	add		iy,de							; add deltaY(unsinged) to l2fraction
l2S_adjustCol:
	nop										; this is our inc/dec of X
	jr		l2S_Loop							; repeat loop
l2S_ErrNotNegative:
	ld		a,iyh
	or		iyl
	JumpIfAIsZero l2S_ErrZero					; if there is no error then goto zeroerror
l2S_ErrPositive:								; if its a positive error then we update Y
	lddeiy
	ex		de,hl
	ld		d,0
	ld		a,(l2deltaX)
	ld		e,a
	ClearCarryFlag
	sbc		hl,de
	ex		de,hl
	ldiyde
l2S_adjustRow:									; move Y down by one
	inc		b
	jr		l2S_Loop
l2S_ErrZero:
	ld		hl,(l2deltaX)
	ex		de,hl
	ld		hl,(l2deltaY)
	ClearCarryFlag
	sbc		hl,de
	ex		de,hl
	ldiyde
l2S_adjustCol2:
	nop										; update X and Y
	inc		b
	jr		l2S_Loop	

; ">l2_draw_diagonal, bc = y0,x0 de=y1,x1,a=color) Thsi version performs a pre sort based on y axis"
l2_draw_diagonal:       ld		(l2linecolor),a					;save colour for later
                        ld		hl,0                            ;
                        ld		(l2deltaX),hl                   ;
                        ld		(l2deltaY),hl                   ; initlaise deltas as we will only be loading 8 bit in there but workign in 16 bit later
l2D_preSort:            ld		a,b								;
                        JumpIfALTNusng	d,l2D_noYSort			; we must have Y1 < Y2 (if eqyal then verical line picked up earlier
l2D_SortBasedOnY:	    ldhlbc									;
                        ex		de,hl                           ;
                        ldbchl									; swap over bc and de using hl as an intermediate
l2D_noYSort:		    ld		ixh,d							; ixh now holds target Y coord post sorting
                        ld		ixl,e							; ixl now holds target X coord post sorting
l2D_setXLen:            ld		a,c                             ;
                        JumpIfALTNusng e,l2D_PosXLen			; if x1 < x2 then we have a positive increment
l2D_NegXLen:            ld		a,c                             ; 
                        sub     e                               ; 
                        ld		(l2deltaX),a					; As x1 > x2 we do deltaX = X1 - X2
                        ld		a,l2deccstep					; and set the value for inc dec self modifying to Dec
                        jr		l2D_XINCDEC
l2D_PosXLen:	        ld		a,e                             ; 
                        sub		c                               ; 
                        ld 		(l2deltaX),a                    ; As x1 < x2 we do deltaX = X2 - X1
                        ld		a,l2inccstep                    ; and set the value for inc dec self modifying to Inc
l2D_XINCDEC:	        ld		(l2D_adjustCol),a				;
                        ld		(l2D_adjustCol2),a				; update self modifying code for X update with inc or dec from above
l2D_setYLen				ld		a,d							 	; presorted on Y so it is now always positive
                        sub		b
                        ld 		(l2deltaY),a					; DeltaY = Y2 - Y1
l2D_setErr:									;  LD H  := (D'-E')/2    round up if +ve or down if -ve
ldD_FracDYltDX:			ld		hl,(l2deltaY)					; Fraction = dY - dX
                        ld		de,(l2deltaX)
                        ClearCarryFlag	
                        sbc		hl,de							; sbc does not have an SBC IY so need to do this in HL
                        ex		de,hl
                        ld		iyh,d							; we will use IY reg for fractions
                        ld		iyl,e	
                        jp		p,l2D_fracIsPositive
l2D_fracIsNegative:     NegIY
                        ShiftIYRight1
                        NegIY
                        jp		l2D_SkipCalcInc					; so we have a negative frac
l2D_fracIsPositive:     ShiftIYRight1
l2D_SkipCalcInc:	    
l2D_Loop:				push	bc,,de                 			; l2DeltaY and l2DeltaX are set
                        ld		a,(l2linecolor)     			; 
                        call	l2_plot_pixel       			; Plot Pixel
                        pop     bc,,de
l2D_CheckIfEnd:	        ld		a,ixh
                        JumpIfAGTENusng	  b,l2D_CheckXPos		; if Y1 < Y2 then continue regardless, when it hits Y2 then we must check X1 and X2
                        jp		l2D_Continue
l2D_CheckXPos:          ld		a,c
                        ReturnIfAEqNusng ixl					; if X1 has reached or exceeded X2 then we are done
l2D_Continue:
l2D_HNegative:			ld		a,iyh
                        bit		7,a								; if its negative then we need to deal with delta Y, there is no bit n,iyh instrunction
                        jr		z,l2D_ErrNotNegative			;
l2D_ErrNegative:		ld		a,(l2deltaY)
                        ld		d,0
                        ld		e,a
                        add		iy,de							; add deltaY(unsinged) to l2fraction
l2D_adjustCol:          nop										; this is our inc/dec of X
                        jr		l2D_Loop							; repeat loop
l2D_ErrNotNegative:     ld		a,iyh
                        or		iyl
                        JumpIfAIsZero l2D_ErrZero					; if there is no error then goto zeroerror
l2D_ErrPositive:		lddeiy
                        ex		de,hl
                        ld		d,0
                        ld		a,(l2deltaX)
                        ld		e,a
                        ClearCarryFlag
                        sbc		hl,de
                        ex		de,hl
                        ldiyde
l2D_adjustRow:			inc		b
                        jr		l2D_Loop
l2D_ErrZero:            ld		hl,(l2deltaX)
                        ex		de,hl
                        ld		hl,(l2deltaY)
                        ClearCarryFlag
                        sbc		hl,de
                        ex		de,hl
                        ldiyde
l2D_adjustCol2:         nop										; update X and Y
                        inc		b
                        jr		l2D_Loop
;----------------------------------------------------------------------------------------------------------------------------------

	


;Loin:				; BBC version of line draw
;; ">l2_draw_diagonal, bc = y0,x0 de=y1,x1,a=color)"
;	ld		(l2linecolor),a					; save colour as a reg gets used alot, coudl move this into interrupt flag and disable interrups
;	ld		ixh,0							; ixh = s
;	ld		iyh,0							; iyh = swap
;	ld		l,0								; l will hold delta sign flags
;LoinCalcDeltaX:	
;	ld		a,e
;	sub		c								; a = deltaX
;	JumpIfPositive LoinPosDx
;LoinNegDx:
;	neg										; carry flag will indicate deltaX was negative
;	ld		l,$80							; set bit 7 of l for negative
;LoinPosDx:
;	ld		ixl,a							; ixl = varP = deltaX
;LoinCalcDeltaY:
;	ld		a,d
;	sub		b								; a= deltaY
;	JumpIfPositive LoinPosDy
;LoinNegDy:
;	neg
;	set		6,l								; set bit 6 of l for negative deltaY
;LoinPosDy:
;	ld		iyl,a							; iyl = varQ = deltaY
;	JumpIfAGTENusng ixl, LoinSTPy			; if deltaY >= DeltaX then step along Y
;LoinSTPx:									; step along X
;	JumpOnBitClear l,7						; if l flags were clear then X2 < X2
;LoinSTPxSwapCoords:
;	dec		iyh								; swap flag now becomes FF
;	ld		a,l								; save l flags
;	ex		de,hl							; save de to hl
;	lddebc									; Point2 = point1
;	ldbchl									; Point1 = point2 that was saved
;	ld		l,a								; get back l flags
;LoinSTPxCorrectOrder:	
;	l2_point_pixel_y_safe					; call plot pixel preseving bc hl
;	ld		a,iyl							; get delta Y back
;	ld		iy1,$FE							; roll counter
;LionSTPxRollQ:
;	sla		a								; highest bit of delta-Y
;	jp		c,LoinSTPxSteep
;	cp		ixl								; compare with DeltaX
;	jp		cs,LoinSTPxShallow
;LoinSTPxSteep:								;; LI4
;	sbc		a,ixl							; deltaYwork -= (deltaX+1)
;	scf										; force carry flag set
;LoinSTPxShallow:							;; LI5
;	rl		iyl								; rotate iyl which started as FE
;	jp		c,LionSTPxRollQ					; so we are doing a 6 bit loop
;	inc		ihl								; DeltaX += 1
;LoinSTPxYDirection:							; change this to self modifying code
;	ld		a,d
;	JumpIfAGTEn	b,LionDOWN:
;	ld		a,iyh							; swap flag
;	JumpIfANotZero	X1Inc  					; if swap flag was not set then no need to update R
;LoinSTPxX1Dec:
;	dec		c								; move left 1 pixel as we sawped
;LoinSTPxXCounter:							;; LIL2
;	sub		b
;	if
;
;85 82                   STA &82	   \ R	\ mask byte
;A5 81                   LDA &81	   \ Q	\ delta-Y
;A2 FE                   LDX #&FE	\ roll counter
;86 81                   STX &81		\ Q
;.LIL1	\ roll Q
;0A                      ASL A		\ highest bit of delta-Y
;B0 04                   BCS LI4		\ steep
;C5 1B                   CMP &1B	   \ P	\ delta-X
;90 03                   BCC LI5		\ shallow
;.LI4	\ steep
;E5 1B                   SBC &1B		\ P
;38                      SEC 
;.LI5	\ shallow
;26 81                   ROL &81	   \ Q	\ #&FE
;B0 F2                   BCS LIL1 	\ loop Q, end with some low bits in Q
;A6 1B                   LDX &1B		\ P
;E8                      INX 		\ Xreg is width
;A5 37                   LDA &37		\ Y2
;E5 35                   SBC &35		\ Y1
;B0 2C                   BCS DOWN	\ draw line to the right and down
;A5 90                   LDA &90		\ SWAP
;D0 07                   BNE LI6		\ else Xreg was correct after all, no need to update R
;CA                      DEX 
;.LIL2	\ counter X width
;A5 82                   LDA &82	   \ R	\ mask byte
;51 07                   EOR (&07),Y	\ (SC),Y
;91 07                   STA (&07),Y	\ (SC),Y
;.LI6	\ Xreg correct
;46 82                   LSR &82	   \ R	\ mask byte
;90 08                   BCC LI7   	\ else moving to next column to right. Bring carry in back
;66 82                   ROR &82		\ R
;A5 07                   LDA &07		\ SC
;69 08                   ADC #8		\ next column
;85 07                   STA &07		\ SC
;.LI7	\ S += Q. this is like an overflow monitor to update Y
;A5 83                   LDA &83		\ S
;65 81                   ADC &81	   \ Q	\ some low bits
;85 83                   STA &83		\ S
;90 07                   BCC LIC2	\ skip Y adjustment
;88                      DEY 
;10 04                   BPL LIC2	\ skip Y adjustment
;C6 08                   DEC &08		\ SC+1
;A0 07                   LDY #7
;.LIC2	\ skip Y adjustment
;CA                      DEX 
;D0 DC                   BNE LIL2	\ loop X width
;A4 85                   LDY &85	 \ YSAV \ restore Yreg
;60                      RTS 
;
;.DOWN	\ Line is going to the right and down
;A5 90                   LDA &90		\ SWAP
;F0 07                   BEQ LI9		\ no swap
;CA                      DEX 
;.LIL3	\ counter X width
;A5 82                   LDA &82	    \ R \ mask byte
;51 07                   EOR (&07),Y	\ (SC),Y
;91 07                   STA (&07),Y	\ (SC),Y
;.LI9	\ no swap
;46 82                   LSR &82		\ R
;90 08                   BCC LI10	\ still in correct column, hop
;66 82                   ROR &82		\ R
;A5 07                   LDA &07		\ SC
;69 08                   ADC #8		\ next column
;85 07                   STA &07		\ SC
;.LI10	\ this is like an overflow monitor to update Y
;A5 83                   LDA &83		\ S
;65 81                   ADC &81		\ Q
;85 83                   STA &83		\ S
;90 09                   BCC LIC3	\ skip Y adjustment
;C8                      INY 
;C0 08                   CPY #8
;D0 04                   BNE LIC3	\ have not reached bottom byte of char, hop
;E6 08                   INC &08		\ SC+1
;A0 00                   LDY #0
;.LIC3	\ skipped Y adjustment
;CA                      DEX 
;D0 DA                   BNE LIL3	\ loop X width
;A4 85                   LDY &85	 \ YSAV \ restore Yreg
;60                      RTS 
;
;.STPY	\ -> &1797 \ Step along y for line, goes down and to right
;A4 35                   LDY &35		\ Y1
;98                      TYA 
;A6 34                   LDX &34		\ X1
;C4 37                   CPY &37		\ Y2
;B0 10                   BCS LI15	\ skip swap if Y1 >= Y2
;C6 90                   DEC &90		\ SWAP
;A5 36                   LDA &36		\ X2
;85 34                   STA &34		\ X1
;86 36                   STX &36		\ X2
;AA                      TAX 
;A5 37                   LDA &37		\ Y2
;85 35                   STA &35		\ Y1
;84 37                   STY &37		\ Y2
;A8                      TAY 
;.LI15	\ Y1 Y2 order is now correct
;4A                      LSR A
;4A                      LSR A
;4A                      LSR A
;09 60                   ORA #&60
;85 08                   STA &08	 \ SC+1	\ screen hi
;8A                      TXA 		\ X1
;29 F8                   AND #&F8
;85 07                   STA &07	  \ SC	\ screen lo
;8A                      TXA 
;29 07                   AND #7		\ mask index
;AA                      TAX 
;BD AF 16                LDA &16AF,X \ TWOS,X \ Mode4 single pixel
;85 82                   STA &82	    \ R	\ mask
;A5 35                   LDA &35		\ Y1
;29 07                   AND #7
;A8                      TAY 
;A5 1B                   LDA &1B	    \ P	\ delta-X
;A2 01                   LDX #1		\ roll counter
;86 1B                   STX &1B	    	\ P
;.LIL4	\ roll P
;0A                      ASL A
;B0 04                   BCS LI13	\ do subtraction
;C5 81                   CMP &81	    \ Q	\ delta-Y
;90 03                   BCC LI14	\ less than Q
;.LI13	\ do subtraction
;E5 81                   SBC &81		\ Q
;38                      SEC 
;.LI14	\ less than Q
;26 1B                   ROL &1B		\ P
;90 F2                   BCC LIL4	\ loop P, end with some low bits in P
;A6 81                   LDX &81		\ Q
;E8                      INX 		\ adjust height
;A5 36                   LDA &36		\ X2
;E5 34                   SBC &34		\ X1
;90 2D                   BCC LFT		\ if C cleared then line moving to the left - hop down
;18                      CLC 
;A5 90                   LDA &90		\ SWAP
;F0 07                   BEQ LI17 	\ skip first point
;CA                      DEX 
;.LIL5	\ skipped first point, counter X
;A5 82                   LDA &82	    \ R \ mask byte
;51 07                   EOR (&07),Y	\ (SC),Y
;91 07                   STA (&07),Y	\ (SC),Y
;.LI17	\ skipped first point
;88                      DEY 
;10 04                   BPL LI16	\ skip hi adjust
;C6 08                   DEC &08		\ SC+1
;A0 07                   LDY #7		\ new char
;	.LI16	\ skipped hi adjust
;A5 83                   LDA &83		\ S
;65 1B                   ADC &1B		\ P
;85 83                   STA &83		\ S
;90 0C                   BCC LIC5	\ skip, still in same column
;46 82                   LSR &82	  \ R	\ mask
;90 08                   BCC LIC5  	\ no mask bit hop
;66 82                   ROR &82   \ R	\ else moved over to next column, reset mask
;A5 07                   LDA &07	  \ SC  \ screen lo
;69 08                   ADC #8		\ next char below
;85 07                   STA &07		\ SC
;.LIC5	\ same column
;CA                      DEX 
;D0 DC                   BNE LIL5	\ loop X height
;A4 85                   LDY &85	 \ YSAV	\ restore Yreg 
;60                      RTS 
;
;.LFT	\ going left
;A5 90                   LDA &90		\ SWAP
;F0 07                   BEQ LI18	\ skip first point
;CA                      DEX 		\ reduce height
;.LIL6	\ counter X height
;A5 82                   LDA &82	   \ R	\ mask byte
;51 07                   EOR (&07),Y	\ (SC),Y
;91 07                   STA (&07),Y	\ (SC),Y
;.LI18
;88                      DEY 
;10 04                   BPL LI19	\ skip hi adjust
;C6 08                   DEC &08		\ SC+1
;A0 07                   LDY #7		\ rest char row
;.LI19	\ skipped hi adjust
;A5 83                   LDA &83		\ S
;65 1B                   ADC &1B	    \ P \ some low bits
;85 83                   STA &83		\ S
;90 0D                   BCC LIC6	\ no overflow
;06 82                   ASL &82	    \ R \ else move byte mask to the left
;90 09                   BCC LIC6	\ no overflow
;26 82                   ROL &82		\ R
;A5 07                   LDA &07		\ SC
;E9 07                   SBC #7		\ down 1 char
;85 07                   STA &07		\ SC
;18                      CLC
;.LIC6	\ no overflow 
;CA                      DEX 		\ height
;D0 DB                   BNE LIL6	\ loop X
;A4 85                   LDY &85	 \ YSAV	\ restore Yreg 
;.HL6
;60                      RTS 		\ end Line drawing


;;l2_draw_diagonalopt:
	; ">TODO l2_draw_diagonalopt fast horz vert optmisation"
;;	push	af
;;	ld		a,b
;;	cp		d
;;	jr		z,.RegularDiagnonal
;;.CheckHorz:
;;	ld		a,c
;;	cp		e
;;	jr		z,.horizontalLine
;;.RegularDiagnonal:
;;	pop		af
;;	call diag


;;l2_signed_mul2a:
;;; ">l2_signed_mul2a - Signed a = a * 2 using shift)"
;;	TEST	$80
;;	jr		nz, .negativecalc
;;.positivecalc:
;;	ccf
;;	rla
;;	ret
;;.negativecalc:
;;	neg
;;	ccf
;;	rla
;;	neg
;;	ret
;;	
;;l2_signed_mul2atohl:
;;; ">l2_signed_mul2ahl - Signed hl = a * 2 using shift)"
;;	TEST	$80
;;	jr		nz, .negativecalc
;;.positivecalc:
;;	ld		hl,0
;;	ld		l,a
;;	add		hl,a
;;	ret
;;.negativecalc:
;;	neg
;;	ld		hl,0
;;	ld		l,a
;;	neghl
;;	ret
;;	
;;l2_e2fractionby2:
;;	ld 		hl,(l2fraction)
;;	push	de
;;	ld		d,h
;;	ld		e,l
;;	add		hl,de
;;	pop		de
;;	ld		(l2e2),hl
;;	ret


	


;;//	ld		(l2linecolor),a   			; could do an ex but it will be needed multiple times between many uses of a reg
;;//.catchLoop:
;;//	jp .catchLoop	
;;//.continue:	
;;//    ld      A,D
;;//    sub     H
;;//    jr      NC,.DXpositive    ;delta_x > 0
;;//.DXNegative:
;;//    neg
;;//.DXPositive:
;;//    ld      B,A              ;B <- |delta_x|
;;//    ld      A,E
;;//    sub     L
;;//    jr      NC,.DYpositive    ;delta_y > 0
;;//.DYNegative:
;;//    neg
;;//.DYPositive:                
;;//    sub     B               ;|delta_y|
;;//	push	af
;;//	jr		c,.DeltaX
;;//.DeltaY
;;//	ld      A,H             			;if |delta_x| < |delta_y| then
;;//    ld      H,L             			;then values x and y are swapped
;;//    ld      L,A             			;so the loop will always be performed on the
;;//    ld      A,D             			;x value. A flag must be set to 
;;//    ld      D,E             			;remind that data must be drawn (y,x) 
;;//    ld      E,A             			;instead of (x,y)
;;//.DeltaX:
;;//	ld		a,d
;;//	sub		h
;;//	jr		nc,.TestDY					; x1 < x2
;;//.TestDX:
;;//	ex		de,hl
;;//.TestDY:
;;//	ld		a,e
;;//	sub		l
;;//    ld      A,$01
;;//    jr      NC,.StoreA
;;//    neg                     ;y1 > y2 : in case2 the 'y' variable
;;//.StoreA:
;;//        ld      (l2way),A
;;//.InitLine:       
;;//        ld      B,H
;;//        ld      C,L
;;//        ld      A,E
;;//        sub     L
;;//        jr      NC,.EndInit
;;//        ld      A,L
;;//        ld      L,E
;;//        ld      E,A
;;//.EndInit:
;;//        ld      A,E      
;;//        sub     L
;;//        rla
;;//        ld      L,A             ;value to add in case1 (d < 0)
;;//        add     A,H
;;//        sub     D
;;//        ld      E,A             ;'d' variable is initialised
;;//        add     A,H
;;//        sub     D
;;//        ld      H,A             ;value to add in case2 (d >= 0)
;;//.Loop:
;;//        ld      A,B
;;//        sub     D
;;//        jr      NC,.EndLine       ;the line is completely drawn.
;;//        pop     AF
;;//        bit     7,A
;;//        push    AF
;;//        push    AF
;;//        push    BC
;;//        jr      Z,.DrawPoint
;;//        ld      A,B
;;//        ld      B,C
;;//        ld      C,A
;;//.DrawPoint:     
;;//		push	hl
;;//		pushbcdeaf
;;//		ld		b,e
;;//		ld		c,d
;;//	ld 		a,(l2linecolor)
;;//	call	l2_plot_pixel
;;//		popafdebc
;;//		pop		hl
;;//        pop     BC
;;//        pop     AF
;;//.TestD:
;;//        bit     7,E
;;//        jr      NZ,.Case1
;;//.Case2:                          ;d >= 0 
;;//        ld      A,E
;;//        add     A,H
;;//        ld      E,A
;;//        ld      A,(l2way)
;;//        add     A,C
;;//        ld      C,A
;;//        jr      .EndLoop
;;//.Case1:                          ;d < 0
;;//        ld      A,E
;;//        add     A,L
;;//        ld      E,A
;;//.EndLoop:
;;//        inc     B
;;//        jr      .Loop
;;//.EndLine:
;;//        pop     AF              ;MUST NOT BE REMOVED
;;//        pop     HL              ;can be removed
;;//        pop     DE              ;can be removed
;;//        ret	
 	
;;	ld		(.l2yadjust),a	
;;	call	calcdeltax:
;;	ld		(.l2xadjust),a	
;;.calcfraction:							; err(or fraction) = dx+dy;
;;	push	hl
;;	push	de
;;	ld		hl,(l2deltaX)
;;	ld		de,(l2deltaY)
;;	add		hl,de
;;	ld		(l2fraction),hl
;;	pop		de
;;	pop		hl
;;.mainloop:
;;	push	bc
;;	push	de
;;	ld 		a,(l2linecolor)
;;	call	l2_plot_pixel
;;	pop		de
;;	pop		bc
;;.arewefinishedtest
;;	ld		a,b
;;	cp		d
;;	jr		nz,.notthereyet
;;	ld		a,c
;;	cp		e
;;	ret		z
;;.notthereyet:
;;	push	de
;;	call	l2_e2fractionby2			; e2 = 2*err;
;;	pop		de
;;.e2dytest:								; if (e2 >= dy) /* e_xy+e_x > 0 */  then S and P/V are the same
;;	push	de							; so if m & pe  or p & po calc (m = sign set p = 0)
;;	ld		de,(l2deltaY)				;    if m & po  or p & pe skip  (pe = pv set po = pv 0)
;;	or		a							;
;;	sbc		hl,de						;
;;	pop		de
;;	jr		z,  .dodycalc				; if equal then calc
;;	jp		p,	.dodycalc				; sign clear to H>D even with negtives
;;	jr		.skipdycalc         		; sign = 0     so  skip as pe
;;.dodycalc:
;;	ld		hl,(l2fraction)
;;	push	de
;;	ld		de,(l2deltaY)
;;	add		hl,de
;;	ld		(l2fraction),de
;;	pop		de
;;.l2yadjust:
;;	nop	
;;.skipdycalc:
;;.e2dxtest:								;  if (e2 <= dx) /* e_xy+e_y < 0 */ then S and P/V are different.
;;	ld		hl,(l2e2)
;;	push	de							;
;;	ld		de,(l2deltaX)				;
;;	or		a							; clear carry flag
;;	sbc		hl,de						; hl = hl - de is if de > hl will get pv and signed different?
;;	pop		de
;;	jr		z,.dodxcalc					; e2 == dx so do calc
;;	jp		m,.dodxcalc					; was sign bit set
;;	jr		.skipdxcalc         	    ; diff so skip ; pvclear = po        pvset = pe
;;.dodxcalc:
;;	ld		hl,(l2fraction)
;;	push	de
;;	ld		de,(l2deltaX)
;;	add		hl,de
;;	ld		(l2fraction),de
;;	pop		de
;;.l2xadjust:
;;	nop
;;.skipdxcalc:
;;	jr 		.mainloop


;;/l2_draw_diagonalold:
;;/MESSAGE ">l2_draw_diagonal, bc = y0,x0 de=y1,x1,a=color)"
;;/	ld		(l2linecolor),a   			; could do an ex but it will be needed multiple times between many uses of a reg
;;/.sortycoords:
;;/	ld		a,b							; Sort to Y0 is always > y1 so we don't have to deal with step y and only step x
;;/	cp		d
;;/	jr		nc, .nocoordswap
;;/.swapcoords:
;;/	ex		de,hl						; save de to hl ! effective code line 98 after macros
;;/	lddebc
;;/	ldbchl
;;/.nocoordswap:
;;/	ld		a,d							; l2_dy = -ABS(l2_vy1 - l2_vy0)
;;/	sub		b							; we have already sorted  so y1 > y0
;;/	ld		(l2deltaY),a
;;/	neg									; DEBUG
;;/	ld		(l2deltaYn),a				; DEBUG
;;/	neg									; DEBUG
;;/.deltaxequABSx0Minusx1:						; we need to set l2dx to abs x1-x0 and set
;;/    ld		a,c
;;/	cp		e
;;/	jr		c, .x1GTx0
;;/.x1LTx0
;;/	ld		a,c
;;/	sub		e
;;/	ld		(l2deltaX),a				; just 8 bit for now should it be 16?	
;;/	neg									; DEBUG
;;/	ld		(l2deltaXn),a				; DEBUG
;;/	neg									; DEBUG
;;/	ld		a,l2incbstep
;;/	jr		.setlayershift0
;;/.x1GTx0:
;;/	ld		a,e
;;/	sub		c
;;/	ld		(l2deltaX),a					; just 8 bit for now should it be 16?	
;;/	neg									; DEBUG
;;/	ld		(l2deltaXn),a				; DEBUG
;;/	neg									; DEBUG
;;/	ld		a,l2decbstep
;;/.setlayershift0:
;;/	ld		a,0
;;/	pushbcde
;;/	call	asm_l2_bank_n_select		; l2_layer_shift = 0 and bank 0 selected
;;/	popdebc
;;/; so now we have set inc or dec instruction, l2dy, l2dx and on bank 0, 
;;/.dymuliplyby2:
;;/	ld		a, (l2deltaY)				; dy *= 2
;;/	call	l2_signed_mul2a
;;/	ld		(l2deltaYsq),a
;;/	neg									; DEBUG
;;/	ld		(l2deltaYsqn),a				; DEBUG
;;/	neg									; DEBUG	
;;/.dxmuliplyby2:
;;/	ld		a, (l2deltaX)				; dx *= 2
;;/	call	l2_signed_mul2a
;;/	ld		(l2deltaXsq),a
;;/	neg									; DEBUG
;;/	ld		(l2deltaXsqn),a				; DEBUG
;;/	neg									; DEBUG	
;;/.plotfirstpixel:
;;/	pushbcde
;;/	ld a,(l2linecolor)
;;/	call	l2_plot_pixel
;;/	popdebc
;;/.mainloop:								; if (l2_dx > l2_dy) signed
;;/	ld		a,(l2deltaX)				;If A < N, then S and P/V are different.
;;/	ld		hl,l2deltaY					;A >= N, then S and P/V are the same
;;/	cp		(hl)
;;/	jp		m,	.signset
;;/.signclear:
;;/	jp		pe,	.dxLTEdybranch
;;/	jr		.dxGTdybranch
;;/.signset:
;;/	jp		po,	.dxLTEdybranch
;;/.dxGTdybranch:
;;/	ld		a,(l2deltaYsq)
;;/	ld		hl,l2deltaX
;;/	sub		(hl)
;;/	ld		(l2fraction),a				; faction = dy - 1/2 dx
;;/.BranchAwhile							; while (l2_vx0 != l2_vx1)
;;/	ld		a,c
;;/	cp		e
;;/	ret		z							; if x0 = x1 then done
;;/.BranchAtestfraction:					; if (l2_fraction >= 0)
;;/	ld		a,(l2fraction)
;;/	TEST	$80
;;/	jr		nz,.BranchAskipYstep
;;/	inc		b							; 		++l2_vy0;
;;/	ld		hl,l2deltaXsq
;;/	sub		(hl)						; 		l2_fraction -= l2_dx;
;;/	ld		(l2fraction),a
;;/.BranchAskipYstep:
;;/.l2stepx1:
;;/	inc		b							; this is self modifying code point 1 l2_vx0 += l2_stepx
;;/	ld		a,(l2fraction)				; l2_fraction += l2_dy can optimise later as a already has this?
;;/	ld		hl,l2deltaYsq
;;/	add		a,(hl)
;;/	ld		(l2fraction),a
;;/.BranchAplotBCColA:						; l2_plot_pixel(l2_vx0,l2_vy0,color);
;;/	pushbcde
;;/	ld a,(l2linecolor)
;;/	call	l2_plot_pixel
;;/	popdebc
;;/.BranchAloop:
;;/	jr		.BranchAwhile
;;/.dxLTEdybranch:
;;/	ld		a,(l2deltaXsq)				; l2_fraction = l2_dx - (l2_dy >> 1);
;;/	ld		hl, l2deltaY
;;/	sub		(hl)
;;/	ld		(l2fraction),a				; faction = dy - 1/2 d
;;/.BranchBwhile:							; while (l2_vy0 != l2_vy1)
;;/	ld		a,b
;;/	cp		d
;;/	ret		z							; if x0 = x1 then done
;;/.BranchBtestfraction:					; if (l2_fraction >= 0)
;;/	ld		a,(l2fraction)
;;/	TEST	$80
;;/	jr		nz,.BranchBskipYstep
;;/.l2stepx2
;;/	inc		b							; l2_vx0 += l2_stepx; this is self modifying code point 2
;;/	ld		a,(l2fraction)				; l2_fraction -= l2_dy
;;/	ld		hl,l2deltaYsq
;;/	sub		(hl)
;;/	ld		(l2fraction),a
;;/.BranchBskipYstep:
;;/	ld		hl, l2deltaYsq
;;/	add		a,(hl)
;;/	ld		(l2fraction),a
;;/	inc		b							; ++l2_vy0;
;;/.BranchBplotBCColA:
;;/	pushbcde
;;/	ld a,(l2linecolor)
;;/	call	l2_plot_pixel
;;/	popdebc
;;/.BranchBloop:
;;/	jr		.BranchBwhile	
