XX12equXX15byXX16:                          ; note not dot product but multiply
XX12equXX15dotXX16:							; .LL51	\ -> &4832 \ XX12=XX15.XX16  each vector is 16-bit x,y,z
		ld		c,0				; LDX #0
		ld		b,0				; LDY #0
		ld		hl,XX16
.CalcLoop:									;	.ll51	\ counter X+=6 < 17  Y+=2
		ld		a,(	UBnkXScaled)				;LDA &34	  \ XX15+0 \ xmag
		ld		(varQ),a					; Q
		ld		a,(hl)						; LDA &09,X	   \ XX16,X
		call	FMLTU						; FMLTU  \ Acc= XX15 *XX16 /256 assume unsigned
		ld		(varT),a
		inc		hl							; move to sign byte
		
		ld		a,( UBnkXScaledSign)			;	XX15+1
		xor		(hl)						;	XX16+1,X
		ld		(varS),a					; S	   \ xsign
		inc		hl
		
		ld		a,(UBnkYScaled)				;LDA &36	  \ XX15+2 \ ymag
		ld		(varQ),a					; Q
		ld		a,(hl)						;LDA &0B,X	   \ XX16+2,X
		call	FMLTU						; FMLTU  \ Acc= XX15 *XX16 /256 assume unsigned
		ld		(varQ),a					; Q
		ld		a,(varT)
		ld		(varR),a					; \ R	   \ move T to R
		inc		hl
		
		ld		a,(UBnkYScaledSign)			; XX15+3 \ ysign
		xor		(hl)						; XX16+3
		call	BADDll38					; JSR &4812 \ LL38   \ BADD(S)A=R+Q(SA) \ 1byte add (subtract)
		ld		(varT),a
		inc		hl
		
		ld		a,(UBnkZScaled)				;LDA &38	  \ XX15+4 \ zmag
		ld		(varQ),a					;STA &81		   \ Q
		ld		a,(hl)
		call	FMLTU						; JSR &2847 \ FMLTU  \ Acc= XX15 *XX16 /256 assume unsigned
		ld		(varQ),a					; Q
		ld		a,(varT)					; LDA &D1		   \ T
		ld		(varR),a					; STA &82	   \ R	   \ move T to R
		inc		hl
		
		ld		a,(UBnkZScaledSign)
		xor		(hl)						; XX16+5,X
		call	BADDll38					; JSR &4812 \ LL38   \ BADD(S)A=R+Q(SA)   \ 1byte add (subtract)
		push	hl
		ld		hl,XX12						;  XX12,Y
		ld		d,0							; XX12,Y
		ld		e,b
		add		hl,de						; XX12,Y (in effect hl + b)
		ld		(hl),a						; XX12,Y
		ld		a,(varS)					; S	   \ result sign
		inc		hl
		ld		(hl),a						; XX12+1,Y
		inc		b							; Y + 2
		inc     b
		ld		a,c
		add		a,6
		ld		c,a						 	; X +=6
		cp		17							;  X finished?
		jr		nc,.CalcLoop
		ret									; loop for second half of matrix

