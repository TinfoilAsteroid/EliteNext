PlanetP12addInwkX:
MVT6:										; Planet P(1,2) += inwk,x for planet (Asg is protected but with new sign)
	ld		c,a								; Yreg = sg
	ld		hl,UBnKxsgn						;
	ex		af,af'                          ; Save a for next bit
	ld		a,(regX)                        ;
	add		hl,a                            ;
	ex		af,af'							; hl = INWK+2[x]
	xor		(hl)							; INWK+2,X
	bit		7,a
	jr		nz,.MV50						; sg -ve
	ld		a,(varPhi)						; P+1
	dec		hl
	dec		hl								; hl now is INWK[x]
	adc		a,(hl)							; add lo INWK,X
	ld		(varPhi),a						;  P+1
	ld		a,(varPhi2)						; P+2	\ add hi
	inc		hl								; hl now in INWK+1[x]
	adc		a,(hl)							; INWK+1,X
	ld		(varPhi2),a						;  P+2
	ld		a,c								;  restore old sg ok
	ret
.MV50:										; .MV50	\ sg -ve
	ld		hl,UBnKxlo						;
	ex		af,af'                          ; Save a for next bit
	ld		a,(regX)                        ;
	add		hl,a                            ;
	ex		af,af'							; hl = INWK+0[x]
	scf
	ld		a,(hl)							; a = INWK+0[x]
	scf										; sub lo
    ex      de,hl
    ld      hl,varPhi
	sbc		a,(hl)		    				; P+1
	ld		(hl),a	    					; P+1
    ex      de,hl
	inc		hl								;  hl now is INWK+1,X
	ld		a,(hl)							; a= INWK+1[x]
    ex      de,hl
    ld      hl,varPhi2
	sbc		a,(hl)						    ; P+2 \ sub hi
	ld		(hl),a						    ; P+2
    ex      de,hl
	jr		nc,.MV51						; fix -ve
	ld		a,c
	xor		$80								; restore Asg  but flip sign
	ret
.MV51:										; fix -ve
	ld		a,1								; carry was clear
    ld      hl,varPhi
	sbc		a,(hl)						    ; P+1
	ld		(hl),a						    ; P+1
	xor		a								; sub hi
    inc     hl
	sbc		a,(hl)						    ; P+2
	ld		(hl),a						    ; P+2
	ld		a,c							   	; old Asg ok
	ret										; done
