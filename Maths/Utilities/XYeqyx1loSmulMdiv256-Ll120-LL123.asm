; Pile of crap doesn't do S properly
XYeqyx1loSmulMdiv256:					
LL120:										;X.Y=x1lo.S*M/256  	\ where M/256 is gradient
		ldCopyByte UBnKx1Lo,varR			; XX15+0	\ x1 lo to varR
; TODO note that the next call does things with delta etc not just as the title says		
		call		RSequABSrs				;LL129	\ RS = abs(x1=RS) and return with 
		push		af						; store Acc = hsb x1 EOR quadrant_info, Q = (1/)gradient
; Do some caching of varQ, VarR, VarS
        ld          a,(varQ)
		ld			h,0
        ld          l,a                     ; use D to hold working value of Q
		ld			de,(varR)				; load DE with varS.varR (r low s hi)
; See if T is a steep toggle or not
		ldIXLaFromN varT					; ixl = a = T steep toggle = 0 or FF for steep/shallow down
		IfANotZeroGoto DownSteepLL121	    ; LL121 down Steep
ShallowLL122:
LL122:										; else Shallow return step, also arrive from LL123 for steep stepX
; here we calulate YX = SR * Q
; so we have already loaded DE with S.R and HL with 0.Q
		call		mulDEbyHL				; hl = SR & Q
		pop			af						; restore quadrant info
		JumpOnBitSet	a,7,LL126NoFlipNeeded     ; flip XY sign only if needs be, this should have been written as bit set in the previous code version
LL126FlipXY:
        call        negate16hl				; Flip HL and transfer to bc and ixl iyl
LL126NoFlipNeeded:								; just transfer teh result into bc and ixl iyl
		push		hl
		pop			bc
        ld          ixl,c
        ld          iyl,b  		
		ret
;--------------------------------------------        
; TODO CLEAR UP THIS AS ITS OVER COMPLEX
XYeqyRSmulMdiv256:
LL123:										; X.Y=R.S*256/M (M=grad.)	\ where 256/M is gradient
		call		RSequABSrs				; LL129	\ RS = abs(y1=RS) and return with
		push		af						; store  Acc = hsb x1 EOR hi, Q = (1/)gradient
        ld			bc,(varR)               ; load BC with varS.varR (r low s hi)
		ld			a,(varT)				; T	\ steep toggle = 0 or FF for steep/shallow up
		ld			ixl,a					; x = t
		IfAIsZeroGoto ShallowLL122			; up Shallow
DownSteepLL121:
		ld          a,(varQ)
		ld			d,0
        ld          e,a                     ; DE = Gradient Q
		call		DIV16BCDivDEUNDOC		; bc = s.r * Q as we pulled in bc earlier
        pop         af                      ; restore quadrant info
		JumpOnBitSet a,7,LL133oFlipNeeded	; just exit if a was negativ
L1133:
L1133FlipNeede:        
		NegBC
LL133oFlipNeeded:
        ld          ixl,c
        ld          iyl,b                   ; get 
		ret									; else done
		
