arctan:										; .ARCTAN	\ -> &2A3C  \ A=TAN-1(P/Q) \ A=arctan (P/Q)  called from block E
		ld		a,(varP)					; a = var P
		ld		hl,varQ
		xor		(hl)						; a = var p XOR varQ
		ld		a,(varT1)					; \ T1	 \ quadrant info
		ld		c,a							; c = copy of T1
		ld		a,(hl)						; Q
		cp		0
		jr		z,.AR2						;  Q=0 so set angle to 63, pi/2
		ld		(varQ),a					; Q move to reg B?
		ld		d,a							; copy to reg d
		sla		a							; drop sign
		ld		a,(varP)					; P
		ld		e,a							; copy to reg e
		sla		a							; drop sign
		cp		d							; compare with b (unsigned varQ * 2)
		jr		nc, .ars1					; if q >  p then adjust  swop A and Q as A >= Q
		call	ars1						; \ ARS1 \ get Angle for A*32/Q from table.
		scf									; set carry flag 
.ar4:										; sub o.k
		bit 	7,c							; is T1 (also in c) negative?
		jr		nz,.ar3						;  -ve quadrant
		ret
.ar1:										; swop A and Q entering here d = q and e = P
		ld		a,d							; a = varQ
		ld		d,e							; varQ = varP
		ld		e,a							; swap D and E around
		ld		(varP),a					; write to actual variables
		ld		a,d
		ld		(varQ),a					; write to actual variables
		call	.ars1
		ld		(varT),b
		ld		b,a							; B = T = angle
		ld		a,64						; next range of angle, pi/4 to pi/2
		sub		a,b							; a = 64 - T (or b)
		jr		nc,.ar4						;  sub o.k
.ar2:										; .AR2	\ set angle to 90 degrees
		ld 		a,&3F						;  #63
		ret
.ar3:										;.AR3	\ -ve quadrant
		ld		b,a							; b = T	= \ angle
		ld		a,ConstPi					; a = Pi
		sub		b,a							; A = 128-T, so now covering range pi/2 to pi correctly
		ret
.ars1:										; .ARS1	\ -> &2A75  \ get Angle for A*32/Q from table.
		call	RequAmul256divQ				;  LL28 \ BFRDIV R=A*256/Q
		ld		a,(regA)
		srl		a
		srl		a
		srl		a							;  31 max.
		ld		hl, ArcTanTable				; root of index into table at end of words data
		add		hl,a						; now at real data
		ld		a,(hl)						; a =  ACT[a]
.arsr:										; rts used by laser lines below (will not in later code)
		ret



