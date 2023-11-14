; Note comparing hl vs iY, you need at least 3 incs or decs for hl to be slower
; it may be faster though if we can use hl to avoid memory actions if needed
; need to optimise mad as push hl pop hl and use de doesn't really improve speed


moveship4Yreg:
		ld		a,(regY)
		ld		b,a
moveship4breg:
		; b = Y index, 9 = nosev, 15 = roofv 21 = sidev 
MVS4PitchAlphaRollBeta:
MVS4:										;.MVS4	\ -> &52A1 \ Moveship4, Y is matrix row, pitch&roll update to coordinates
		ld		a,(ALPHA)					;  ALPHA	
		ld		(varQ),a					; player ship's roll Q = Alpha
		ld		hl,UBnkxsgn
		ld		a,b							; from 
		add		hl,a						
		ld		a,(hl)						; INWK+2,Y
		ld		(varR),a					; R  \ lo
		inc		hl
		ld		a,(hl)						; INWK+3,Y
		ld		(varS),a					; S  \ hi		SR = nosev_y (or axis y)
		dec		hl
		dec		hl
		dec		hl							;
		ld		a,(hl)						; INWK+0,Y
		ld		(varP),a					; P  \ over-written	 P = nosevx lo
		inc		hl
		ld		a,(hl)						; INWK+1,Y
		xor		$80							; flip sign  AP = nosevx * - 1
		call	madXAequQmulAaddRS			; MAD	\ DE = X.A = alpha*INWK+1,Y + INWK+2to3,Y
        inc     hl
        inc     hl
        ld      (hl),a                      ; INWK+3,Y \ hi
        dec     hl
        ld      a,(regX)
        ld      (hl),a                      ; INWK+2,Y \ Y=Y-aX   \ their comment
        ld      (varP),a                    ;  P
        dec     hl
        dec     hl
        ld      a,(hl)                      ; INWK+0,Y
        ld      (varR),a                    ;  R	\ lo
        inc     hl
        ld      a,(hl)                      ;  INWK+1,Y
        ld      (varS),a                    ; S	\ hi
        inc     hl
        inc     hl
        ld      a,(hl)                      ; INWK+3,Y
        call    madXAequQmulAaddRS          ; MAD	\ X.A = alpha*INWK+3,Y + INWK+0to1,Y
        dec     hl
        dec     hl
        ld      (hl),a                      ; INWK+1,Y  \ hi
        ld      a,(regX)
        dec     hl
        ld      (hl),a                      ; INWK+0,Y  \ X=X+aY   \ their comment
        ld      (varP),a                    ; P
        ld      a,(BETA)                    ; BETA	
        ld      (varQ),a                    ; Q	\ player ship's pitch
        inc     hl
        inc     hl
        ld      a,(hl)                      ; INWK+2,Y
        ld      (varR),a                    ; R	\ lo
        inc     hl
        ld      a,(hl)                      ; INWK+3,Y	
        ld      (varS),a                    ; S	\ hi
        inc     hl
        ld      a,(hl)                      ; INWK+4,Y
        ld      (varP),a                    ; P	\ lo
        inc     hl
        ld      a,(hl)                      ; INWK+5,Y
        xor     $80                         ; flip sign hi
        call    madXAequQmulAaddRS          ; MAD	\ X.A =-beta*INWK+5,Y + INWK+2to3,Y
        dec     hl
        dec     hl
        ld      (hl),a                      ; INWK+3,Y \ hi
        ld      a,(regX)
        dec     hl
        ld      (hl),a                      ; INWK+2,Y \ Y=Y-bZ  \ their comment
        ld      (varP),a                    ; P
        inc     hl
        inc     hl
        ld      a,(hl)                      ; INWK+4,Y
        ld      (varR),a                    ; R	\ lo
        inc     hl
        ld      a,(hl)                      ; INWK+5,Y
        ld      (varS),a                    ; S	\ hi
        dec     hl
        dec     hl
        ld      a,(hl)                      ; INWK+3,Y
        call    madXAequQmulAaddRS          ; MAD	\ X.A = beta*INWK+3,Y + INWK+4,5,Y
        inc     hl
        inc     hl
        ld      (hl),a                      ; INWK+5,Y \ hi
        ld      a,(regX)
        dec     hl
        ld      (hl),a                      ; INWK+4,Y \ Z=Z+bY   \ their comment
        ret


