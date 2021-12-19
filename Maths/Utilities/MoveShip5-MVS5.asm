;			T = x hi usigned /2
;			RS =  inwkx    (strip sign)
;			so RS -= (xhi /2)
			;PA = unkxhi[y] (strip sign)
;			T = sign bit inkxhy[y]
			


MoveShip5:
	ld		bc,(regX)				; b = regY, c = regX
MoveShip5regBC:
MVS5:								; Moveship5, small rotation in matrix (1-1/2/256 = cos  1/16 = sine)
	ld		hl,UBnKxhi				; hl - INWK1
.IndexX:
	ld		a,c						;
	add		hl,a					;
	ld		a,(hl)					; INWK+1,X
	ld		e,a						; save a copy in e for later
	and		SignMask8Bit			; hi7
	srl		a						; hi7/2
	ld		d,a						; repurpose d as var
;	ld		(varT),a				; T repuposed d to hold sign bit
	dec		hl
	push	hl						; we will want this again right at the end
	ld		a,(hl)					; INWK+0,X
	scf								; lo
	sbc		a,d						; a = a - (varT + carry bit)
	ld		(varR),a				; R	\ Xindex one is 1-1/512
	ld		a,e						; restore copy of  INWK+1,X
	sbc		a,0						; hi
	ld		(varS),a				; S, TODO could we simplify this by loading xlohi into hl and subtracting 1?
	ld		hl,UBnKxlo				; hl = INWK+0
.IndexY:
	ld		a,b						;
	add		hl,a					;
	ld		a,(hl)					; INWK+0,Y
	ld		d,a						; use d as a working copy of p
	inc		hl						;
	ld		a,(hl)					; INWK+1,Y
	ld		e,a						; save a copy in e for later
	and		$80						; sign bit
	ld		(varT),a				; T
	ld		a,e						; restore copy of INWK+1,Y
	and		SignMask8Bit			; hi7 bits
	srl		a 						; hui7/2
	rr		d						; P local copy
	srl		a 						; hui7/2
	rr		d						; P local copy
	srl		a 						; hui7/2
	rr		d						; P local copy
	ld		(varP),a				; P is Yindex one divided by 16
	or		e						; or a with copy of T from e
	ld		e,a						; now we have done with T so can junk it
	ld		a,(RAT2)
	ld		d,a
	ld		a,e						; bit of juggling so a = varP or T d = RAT2
	xor		d						; a = varP or T xor RAT2
	push	hl						; save hl as INWK+1[y]
	push	bc						; save X and Y (we wont use Q)	\ protect Xindex
	call	XAequPAaddRSfast		; ADD	\ X.A = P.A + R.S
	ld		(varK),de				; as fast add also returns result in de we can just 16 bit load
	pop		bc						; restore Xindex (also Y index)
	pop		hl						; restore hl as INWK+1[y]
	ld		a,(hl)					; INWK+1,Y
	and		SignMask8Bit						;
	srl		a						; hi7/2
	ld		e,a						; use e as varT
	dec		hl
	ld		a,(hl)					; INWK+0,Y
	scf
	sbc		a,e						; a = a -t + 1 (t == reg e)
	ld		(varR),a				; R	\ Yindex one is 1-1/512
	dec		hl
	ld		a,(hl)					;  INWK+1,Y
	sbc		a,0						; subtract carry flag 
	ld		(varS),a				; S
	pop		hl						; get back INWK+0[x]
	ld		a,(hl)					; INWK+0,X
	push	bc						; we may need BC later
	ld		b,a						; save P to work with in b rather than memory for now
	inc		hl
	ld		a,(hl)					; INWK+1,X
	ld		e,a						; save it for a bit
	and		$80						; sign bit
	ld		d,a						; use d as varT
	ld		a,e						; restore INWK+1,X
	and		SignMask8Bit			; hi7
	srl		a
	rr		b
	srl		a
	rr		b
	srl		a
	rr		b						
	ex 		af,af'
	ld		a,b
	ld		(varP),a				; now commit P as p /16
	ex 		af,af'
	or		e 						;  T	\ sign bit
	xor		$80						; flip sign
	ld		hl,RAT2					
	xor		(hl)					;RAT2	\ rot sign
	call	XAequPAaddRSfast		; ADD	\ X.A = P.A + R.S, note we still have bc on stack
	pop		bc						; now we have x and y restored
	ld		hl,UBnKxhi				;
	ld		a,b
	add		hl,a					; hl = UBnKxhi[y]
	ld		(hl),d
	dec		hl						; hl = UBnKxhi[y]
	ld		(hl),e					; as XA is in DE also we can just write that Yindex one now updated by 1/16th of a radian rotation
	ld		hl,UBnKxhi
	ld		a,c
	add		hl,a					; hl = INKW+1[X]
	ld		de,varKp1				; de = variable k hi
	ex		de,hl					; swap
	ldi
	ldi								; load 2 bytes
	ret
	