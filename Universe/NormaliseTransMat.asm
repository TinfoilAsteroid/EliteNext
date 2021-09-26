;divdide by 16 using undocumented instrunctions
Norm256mulAdivQ:
    ld      b,a
    ld      c,0
    ld      d,0
    ld      a,(varQ)
    ld      e,a
;Input: BC = Dividend, DE = Divisor, HL = 0
;Output: BC = Quotient, HL = Remainder
NormDIV16UNDOC:
    ld      hl,0
    ld      a,b 
    ld      b,16
NormDIV16UNDOCLOOP:
	sll	    c		; unroll 16 times
	rla	    		; ...
	adc	    hl,hl		; ...
	sbc	    hl,de		; ...
	jr	    nc,NormDIV16UNDOCSKIP		; ...
	add	    hl,de		; ...
	dec	    c		; ...
NormDIV16UNDOCSKIP:
    djnz    NormDIV16UNDOCLOOP
    ld      a,c
    ld      (varR),a
    ret

; Tested OK
NormaliseTransMat:
;LL21        
        ld      hl,UBnkTransmatNosevZ+1         ; initialise loop
        ld      c,ConstNorm                 ; c = Q = norm = 197
        ld      a,c
        ld      (varQ),a                    ; set up varQ
        ld      b,9                         ; total of 9 elements to transform
LL21Loop:
        ld      d,(hl)
        dec     hl
        ld      e,(hl)                      ; de = hilo now   hl now = pointer to low byte
        ShiftDELeft1                        ; De = DE * 2
        ld      a,d                         ; a = hi byte after shifting
		push	hl
		push	bc
        call    Norm256mulAdivQ
		;===call    RequAmul256divC				; R = (2(hi).0)/ConstNorm - LL28 Optimised BFRDIV R=A*256/Q = delta_y / delta_x Use Y/X grad. as not steep
        ld      a,c                         ; BFRDIV returns R also in l reg
		pop		bc
		pop		hl							; bc gets wrecked by BFRDIV
        ld      (hl),a                      ; write low result to low byte so zlo = (zhl *2)/197, we keep hi byte in tact as we need the sign bit
        dec     hl                          ; now hl = hi byte of pre val e.g z->y->x
        djnz    LL21Loop                    ; loop from 2zLo through to 0xLo
        ret
		