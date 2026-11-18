; Moved out of Layer2Graphics/layer2_plot_diagonal.asm as nothing in the eliteNext.asm build uses it
; (unreferenced routines, and IFDEF blocks whose flag is never defined). Not included in the game build.

l2_draw_box_to:
; ">l2_draw_box_to bc=rowcol, de=torowcol a=color"
; ">NOT IMPLEMENTED YET"
	ret

l2targetPtr	dw	0

;; These arrays should be 192 but if we use 256 then getting array2 value is just inc h rather than indexing again.
l2targetArray1 ds	256

l2targetArray2 ds	256

        IFDEF L2_DIAGONAL_SAVE
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
; we set comparison                        
l2S_PosXLen:	        ld		a,e                             ; 
                        sub		c                               ; 
                        ld 		(l2deltaX),a                    ; As x1 < x2 we do deltaX = X2 - X1
                        ld		a,l2inccstep                    ; and set the value for inc dec self modifying to Inc
; also need to fix the comparison, if its +x then compare with 
l2S_XINCDEC:	        ld		(l2S_adjustCol),a				;
                        ld		(l2S_adjustCol2),a				; update self modifying code for X update with inc or dec from above
l2S_setYLen:            ld		a,d							 	; presorted on Y so it is now always positive
                        sub		b
                        ld 		(l2deltaY),a					; DeltaY = Y2 - Y1
l2S_setErr:									;  LD H  := (D'-E')/2    round up if +ve or down if -ve
ldS_FracDYltDX:         ld		hl,(l2deltaY)					; Fraction = dY - dX
                        ld		de,(l2deltaX)
                        ClearCarryFlag	
                        sbc		hl,de							; sbc does not have an SBC IY so need to do this in HL
                        ex		de,hl
                        ld		iyh,d							; we will use IY reg for fractions
                        ld		iyl,e	
                        jp		p,l2S_fracIsPositive
l2S_fracIsNegative:     NegIY
                        ShiftIYRight1
                        NegIY
                        jp		l2S_SkipCalcInc					; so we have a negative frac
l2S_fracIsPositive:     ShiftIYRight1
l2S_SkipCalcInc:		                        				; As we loop, bc = to plot current XY
l2S_Loop:			    ld		hl,(l2targetPtr)				; Insert into respective array
                        ld		a,b
                        add		hl,a
                        ld		(hl),c
l2S_CheckIfEnd:	        ld		a,ixh
                        JumpIfAGTENusng	  b,l2S_CheckXPos		; if Y1 < Y2 then continue regardless, when it hits Y2 then we must check X1 and X2
                        jp		l2S_Continue
l2S_CheckXPos:          ld      a,(l2S_adjustCol)
                        cp      l2inccstep; if we self modified to inc the we can do a cp e else its cp c
                        jr      z,.IncCP
.DecCP:                 ld      a,c
                        ReturnIfALTNusng ixl
                        ReturnIfAEqNusng ixl
                        jp      l2S_Continue
.IncCP:                 ld		a,c
                        ReturnIfAGTENusng ixl					; if X1 has reached or exceeded X2 then we are done
l2S_Continue:
l2S_HNegative:			ld		a,iyh
                        bit		7,a								; if its negative then we need to deal with delta Y, there is no bit n,iyh instrunction
                        jr		z,l2S_ErrNotNegative			;
l2S_ErrNegative:		ld		a,(l2deltaY)					; if its a negative error update X
                        ld		d,0
                        ld		e,a
                        add		iy,de							; add deltaY(unsinged) to l2fraction
l2S_adjustCol:          nop										; this is our inc/dec of X
                        jr		l2S_Loop							; repeat loop
l2S_ErrNotNegative:     ld		a,iyh
                        or		iyl
                        JumpIfAIsZero l2S_ErrZero					; if there is no error then goto zeroerror
l2S_ErrPositive:        ld      de,iy;  lddeiy								; if its a positive error then we update Y
                        ex		de,hl
                        ld		d,0
                        ld		a,(l2deltaX)
                        ld		e,a
                        ClearCarryFlag
                        sbc		hl,de
                        ex		de,hl
                        ld      iy,de;ldiyde
l2S_adjustRow:          inc		b								; move Y down by one
                        jr		l2S_Loop
l2S_ErrZero:            ld		hl,(l2deltaX)
                        ex		de,hl
                        ld		hl,(l2deltaY)
                        ClearCarryFlag
                        sbc		hl,de
                        ex		de,hl
                        ld      iy,de; ldiyde
l2S_adjustCol2:         nop										; update X and Y
                        inc		b
                        jr		l2S_Loop	
        ENDIF
