; MVT6

APPequXPosPlusAPP:      push    bc
                        ld      c,a                         ; save original value of a into c
                        ld      a,(UBnKxsgn)
                        ld      b,a
                        ld      a,c
                        xor     b                           ; a = a xor x postition sign
                        jp      m,.MV50                     ; if the sign is negative then A and X are both opposite signs
; Signs are the same to we just add and take which ever sign 
                        ld      de,(varP1)                  ; Note we take p+2,p+1 we we did a previous 24 bit mulitple
                        ld      hl,(UBnKxlo)
                        add     hl,de
                        ld      (varP1),hl                  ; now we have P1 and p2 with lo hi and
                        ld      a,c                         ; and a = original sign as they were both the same
                        pop     bc
                        ret
; Signs are opposite so we subtract
.MV50:                  ld      de,(varP1)
                        ld      hl,(UbnKxlo)
                        or      a
                        sbc     hl,de
                        jr      c,.MV51                     ; if the result was negative then negate result
                        ld      a,6
                        ld      (varP1),hl                  ; save result
                        xor     SignOnly8Bit                ; flip sign and exit
                        pop     bc
                        ret
.MV51:                  NegHL
                        ld      (varP1),hl
                        ld      a,c                         ; the original sign will still be good
                        pop     bc
                        ret
                        
;Set (A P+2 P+1) = (y_sign y_hi y_lo) + (A P+2 P+1)  = y - x * alpha / 256
;also(A H L) is the result too
APPequYPosPlusAPP:      push    bc
                        ld      c,a                         ; save original value of a into c
                        ld      a,(UBnKysgn)
                        ld      b,a
                        ld      a,c
                        xor     b                           ; a = a xor x postition sign
                        jp      m,.MV50                     ; if the sign is negative then A and X are both opposite signs
; Signs are the same to we just add and take which ever sign 
                        ld      de,(varP1)                  ; Note we take p+2,p+1 we we did a previous 24 bit mulitple
                        ld      hl,(UBnKylo)
                        add     hl,de
                        ld      (varP1),hl                  ; now we have P1 and p2 with lo hi and
                        ld      a,c                         ; and a = original sign as they were both the same
                        pop     bc
                        ret
; Signs are opposite so we subtract
.MV50:                  ld      de,(varP1)
                        ld      hl,(UbnKylo)
                        or      a
                        sbc     hl,de
                        jr      c,.MV51                     ; if the result was negative then negate result
                        ld      a,6
                        ld      (varP1),hl                  ; save result
                        xor     SignOnly8Bit                ; flip sign and exit
                        pop     bc
                        ret
.MV51:                  NegHL
                        ld      (varP1),hl
                        ld      a,c                         ; the original sign will still be good
                        pop     bc
                        ret
                        
                        
APPequZPosPlusAPP:      push    bc
                        ld      c,a                         ; save original value of a into c
                        ld      a,(UBnKzsgn)
                        ld      b,a
                        ld      a,c
                        xor     b                           ; a = a xor x postition sign
                        jp      m,.MV50                     ; if the sign is negative then A and X are both opposite signs
; Signs are the same to we just add and take which ever sign 
                        ld      de,(varP1)                  ; Note we take p+2,p+1 we we did a previous 24 bit mulitple
                        ld      hl,(UBnKzlo)
                        add     hl,de
                        ld      (varP1),hl                  ; now we have P1 and p2 with lo hi and
                        ld      a,c                         ; and a = original sign as they were both the same
                        pop     bc
                        ret
; Signs are opposite so we subtract
.MV50:                  ld      de,(varP1)
                        ld      hl,(UbnKzlo)
                        or      a
                        sbc     hl,de
                        jr      c,.MV51                     ; if the result was negative then negate result
                        ld      a,6
                        ld      (varP1),hl                  ; save result
                        xor     SignOnly8Bit                ; flip sign and exit
                        pop     bc
                        ret
.MV51:                  NegHL
                        ld      (varP1),hl
                        ld      a,c                         ; the original sign will still be good
                        pop     bc
                        ret
                                               



;;;; This code all looks wrong 
;;;PlanetP12addInwkX:
;;;MVT6:										; Planet P(1,2) += inwk,x for planet (Asg is protected but with new sign)
;;;	ld		c,a								; Yreg = sg
;;;	ld		hl,UBnKxsgn						;
;;;	ex		af,af'                          ; Save a for next bit
;;;	ld		a,(regX)                        ;
;;;	add		hl,a                            ;
;;;	ex		af,af'							; hl = INWK+2[x]
;;;	xor		(hl)							; INWK+2,X
;;;	bit		7,a
;;;	jr		nz,.MV50						; sg -ve
;;;	ld		a,(varPhi)						; P+1
;;;	dec		hl
;;;	dec		hl								; hl now is INWK[x]
;;;	adc		a,(hl)							; add lo INWK,X
;;;	ld		(varPhi),a						;  P+1
;;;	ld		a,(varPhi2)						; P+2	\ add hi
;;;	inc		hl								; hl now in INWK+1[x]
;;;	adc		a,(hl)							; INWK+1,X
;;;	ld		(varPhi2),a						;  P+2
;;;	ld		a,c								;  restore old sg ok
;;;	ret
;;;.MV50:										; .MV50	\ sg -ve
;;;	ld		hl,UBnKxlo						;
;;;	ex		af,af'                          ; Save a for next bit
;;;	ld		a,(regX)                        ;
;;;	add		hl,a                            ;
;;;	ex		af,af'							; hl = INWK+0[x]
;;;	scf
;;;	ld		a,(hl)							; a = INWK+0[x]
;;;	scf										; sub lo
;;;    ex      de,hl
;;;    ld      hl,varPhi
;;;	sbc		a,(hl)		    				; P+1
;;;	ld		(hl),a	    					; P+1
;;;    ex      de,hl
;;;	inc		hl								;  hl now is INWK+1,X
;;;	ld		a,(hl)							; a= INWK+1[x]
;;;    ex      de,hl
;;;    ld      hl,varPhi2
;;;	sbc		a,(hl)						    ; P+2 \ sub hi
;;;	ld		(hl),a						    ; P+2
;;;    ex      de,hl
;;;	jr		nc,.MV51						; fix -ve
;;;	ld		a,c
;;;	xor		$80								; restore Asg  but flip sign
;;;	ret
;;;.MV51:										; fix -ve
;;;	ld		a,1								; carry was clear
;;;    ld      hl,varPhi
;;;	sbc		a,(hl)						    ; P+1
;;;	ld		(hl),a						    ; P+1
;;;	xor		a								; sub hi
;;;    inc     hl
;;;	sbc		a,(hl)						    ; P+2
;;;	ld		(hl),a						    ; P+2
;;;	ld		a,c							   	; old Asg ok
;;;	ret										; done
