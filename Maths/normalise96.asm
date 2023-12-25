; a equal a / d * 96
; Tested and works with signed numbers
NormaliseIXVector:      ld		a,(ix+1)			; Vector X high
                        and		SignMask8Bit        ; a = abs X high
                        ld      d,a                 ; hl = abs X ^ 2
                        ld      e,a                 ; .
                        mul     de                  ; .
                        ex      de,hl               ; .
                        ld		a,(ix+3)			; vector = Y high
                        and		SignMask8Bit        ; unsigned
                        ld      d,a                 ; de = abs Y ^ 2
                        ld      e,a                 ; .
                        mul     de                  ; .
                        add     hl,de               ; hl = x^2 + y ^2
                        ld		a,(ix+5)			; vector = Z high
                        and		SignMask8Bit        ; unsigned
                        ld      d,a                 ; de = abs Z ^ 2
                        ld      e,a                 ; .
                        mul     de                  ; .
                        add     hl,de               ; de = x^2 + y ^2 + z ^ 2
                        ex      de,hl               ; .
.n96SQRT:               call	asm_sqrt			; hl = sqrt de
.n96NORMX:              ld		a,(ix+1)            
                        ld		d,l					; Q(i.e. l) => D, later we can just pop into de
                        call	AequAdivDmul96Q8    ; does not use HL so we can retain it
                        ld		b,a				    ; Sort out restoring sign bit
                        ld      c,0                 ; .
                        ld		(ix+0),bc           ; .
.n96NORMY:              ld		a,(ix+3)            
                        ld		d,l					; Q(i.e. l) => D, later we can just pop into de
                        call	AequAdivDmul96Q8	; does not use HL so we can retain it
                        ld		b,a				    ; Sort out restoring sign bit
                        ld      c,0                 ; .
                        ld		(ix+2),bc           ; .
.n96NORMZ:              ld		a,(ix+5)            
                        ld		d,l					; Q(i.e. l) => D, later we can just pop into de
                        call	AequAdivDmul96Q8 	; does not use HL so we can retain it
                        ld		b,a				    ; Sort out restoring sign bit
                        ld      c,0                 ; .
                        ld		(ix+4),bc           ; .
                        ret                      

; .NORM	\ -> &3BD6 \ Normalize 3-vector length of XX15
normaliseXX1596S7:      ld		a,(XX15VecX)	    ; XX15+0
                        ld		ixh,a               ; ixh = signed x component
                        and		SignMask8Bit        ; a = unsigned version
.n96SQX:	            inline_squde				; Use inline square for speed	objective is SQUA \ P.A =A7*A7 x^2
                        ld		h,d					; h == varR d = varO e= varA
                        ld		l,e					; l == varQ  															:: so HL = XX15[x]^2
.n96SQY:                ld		a,(XX15VecY)			
                        ld		ixl,a               ; ixl = signed y componet
                        and		SignMask8Bit                 ; = abs 
                        inline_squde				; Use inline square for speed	objective is SQUA \ P.A =A7*A7 x^2		:: so DE = XX15[y]^2
                        add		hl,de				; hl = XX15[x]^2 + XX15[y]^2
.n96SQZ:                ld		a,(XX15VecZ)			; Note comments say \ ZZ15+2  should be \ XX15+2 as per code
                        ld		iyh,a               ; iyh = signed
                        and		SignMask8Bit                 ; unsigned
                        inline_squde				; Use inline square for speed	objective is SQUA \ P.A =A7*A7 x^2		:: so DE = XX15[z]^2
.n96SQADD:              add		hl,de				; hl = XX15[x]^2 + XX15[y]^2 + XX15[z]^2
                        ex		de,hl				; hl => de ready for square root
.n96SQRT:               call	asm_sqrt			; hl = de = sqrt(XX15[x]^2 + XX15[y]^2 + XX15[z]^2), we just are interested in l which is the new Q
.n96NORMX:              ld		a,(XX15VecX)
                        and		SignMask8Bit
                        ld		c,a
                        ld		d,l					; Q(i.e. l) => D, later we can just pop into de
                        call	AequAdivDmul967Bit	; does not use HL so we can retain it
                        ld		b,a				    ;++SGN
                        ld		a,ixh			    ;++SGN
                        and		$80				    ;++SGN
                        or		b				    ;++SGN
                        ld		(XX15VecX),a
.n96NORMY:              ld		a,(XX15VecY)
                        and		SignMask8Bit
                        ld		c,a
                        ld		d,l					; Q(i.e. l) => D, later we can just pop into de
                        call	AequAdivDmul967Bit     	; does not use HL so we can retain it
                        ld		b,a				    ;++SGN
                        ld		a,ixl			    ;++SGN
                        and		$80				    ;++SGN
                        or		b				    ;++SGN
                        ld		(XX15VecY),a
.n96NORMZ:              ld		a,(XX15VecZ)
                        and		SignMask8Bit
                        ld		c,a
                        ld		d,l				; Q(i.e. l) => D, later we can just pop into de
                        call	AequAdivDmul967Bit;AequAdivDmul96	; does not use HL so we can retain it
                        ld		b,a				    ;++SGN
                        ld		a,iyh			    ;++SGN
                        and		$80				    ;++SGN
                        or		b				    ;++SGN
                        ld		(XX15VecZ),a
                        ret

; Normalise vector
; scale Q = Sqrt (X^2 + Y^2 + Z^2)
; X = X / Q with 96 = 1 , i.e X = X / Q * 3/8
; Y = Y / Q with 96 = 1 , i.e Y = Y / Q * 3/8
; Z = Z / Q with 96 = 1 , i.e Z = Z / Q * 3/8

        IFNDEF DEBUG_NO_TACTICS_CODE
;------------------------------------------------------------
; To normalise the 24 bit version, bring out sign into TargetVectorxsgn
; and make UBnKTargetXpos = abs (UBnKTargetXPos)
; set up UBnKTarget[XYZ]Pos with 7 bit version of vector normalised
; set up UBnKTargetpXYZ]Sgn with the sign bit
NormalseUnivTarget:     ld      a,(UBnKTargetXPos+2)
                        ld      b,a
                        and     $80
                        ld      (UBnKTargetXPosSgn),a        ; Split out the sign into byte 3
                        ld      a,b
                        and     $7F
                        ld      (UBnKTargetXPos+2),a  
.ABSYComponenet:        ld      a,(UBnKTargetYPos+2)
                        ld      b,a
                        and     $80
                        ld      (UBnKTargetYPosSgn),a        ; Split out the sign into byte 3
                        ld      a,b
                        and     $7F
                        ld      (UBnKTargetYPos+2),a                          
.ABSXZomponenet:        ld      a,(UBnKTargetZPos+2)
                        ld      b,a
                        and     $80
                        ld      (UBnKTargetZPosSgn),a        ; Split out the sign into byte 3
                        ld      a,b
                        and     $7F
                        ld      (UBnKTargetZPos+2),a                          
;.. When we hit here the UBnKTargetX,Y and Z are 24 bit abs values to simplify scaling                        
.Scale:                 ld      hl, (TacticsVectorX)        ; pull 24 bit into registers
                        ld      a,(TacticsVectorX+2)        ; h l ixH = X
                        ld      ixh,a                       ;
                        ld      de, (TacticsVectorY)        ; d e iyH = Y
                        ld      a,(TacticsVectorY+2)        ;
                        ld      iyh,a                       ;
                        ld      bc, (TacticsVectorZ)        ; b c iyL = Y
                        ld      a,(TacticsVectorZ+2)        ;
                        ld      iyl,a                       ;
.ScaleLoop1:            ld      a,ixh                       ; first pass get to 16 bit
                        or      iyh
                        or      iyl
                        or      iyh
                        jp      z,.DoneScaling1
                        ShiftIXhHLRight1
                        ShiftIYhDERight1
                        ShiftIYlBCRight1
.DoneScaling1:          ;-- Now we have got here hl = X, de = Y, bc = Z
                        ;-- we cal just jump into the Normalize Tactics code
.ScaleLoop2:            ld      a,h
                        or      d
                        or      b
                        jr      z,.DoneScaling2
                        ShiftHLRight1
                        ShiftDERight1
                        ShiftBCRight1
                        jp      .ScaleLoop2
;-- Now we are down to 8 bit values, so we need to scale again to get S7         
.DoneScaling2:          ShiftHLRight1
                        ShiftDERight1
                        ShiftBCRight1
.CalculateLength:       push    hl,,de,,bc                  ; save vecrtor x y and z nwo they are scaled to 1 byte
                        ld      d,e                         ; hl = y ^ 2
                        mul     de                          ; .
                        ex      de,hl                       ; .
                        ld      d,e                         ; de = x ^ 2
                        mul     de                          ; .
                        add     hl,de                       ; hl = y^ 2 + x ^ 2
                        ld      d,c
                        ld      e,c
                        mul     de
                        add     hl,de                       ; hl =  y^ 2 + x ^ 2 + z ^ 2
                        ex      de,hl                       ; fix as hl was holding square
                        call    asm_sqrt                    ; hl = sqrt (de) = sqrt (x ^ 2 + y ^ 2 + z ^ 2)
                        ; add in logic if h is low then use lower bytes for all 
.NormaliseZ:            ld      a,l                         ; save length into iyh
                        ld      iyh,a                       ; .
                        ld      d,a                         ;
                        pop     bc                          ; retrive z scaled
                        ld      a,c                         ; a = scaled byte
                        call    AequAdivDmul967Bit          
                        ld      (TacticsVectorZ),a          ; now Tactics Vector Z byte 1 is value
.NormaliseY:            pop     de
                        ld      a,e
                        ld      d,iyh                        
                        call    AequAdivDmul967Bit
                        ld      (TacticsVectorY),a
.NormaliseX:            pop     hl
                        ld      a,l
                        ld      d,iyh                        
                        call    AequAdivDmul967Bit
                        ld      (TacticsVectorX),a          ;
                        ret

            DISPLAY "TODO: Missle AI only works on S15 spread over 24 bits, i.e. ignores Sign byte 7 bits"
;-- This norallises the Tactics vector in memory as much as possible, uses 16 bits 
NormalizeTactics:       ld      hl, (TacticsVectorX)        ; pull XX15 into registers
                        ld      de, (TacticsVectorY)        ; .
                        ld      bc, (TacticsVectorZ)        ; .
.ScaleLoop:             ld      a,h
                        or      d
                        or      b
                        jr      z,.DoneScaling
                        ShiftHLRight1
                        ShiftDERight1
                        ShiftBCRight1
                        jp      .ScaleLoop
.DoneScaling:           ShiftHLRight1                       ; as the values now need to be sign magnitued
                        ShiftDERight1                       ; e.g. S + 7 bit we need an extra shift
                        ShiftBCRight1                       ; now values are in L E C
                        push    hl,,de,,bc                  ; save vecrtor x y and z nwo they are scaled to 1 byte
                        ld      d,e                         ; hl = y ^ 2
                        mul     de                          ; .
                        ex      de,hl                       ; .
                        ld      d,e                         ; de = x ^ 2
                        mul     de                          ; .
                        add     hl,de                       ; hl = y^ 2 + x ^ 2
                        ld      d,c
                        ld      e,c
                        mul     de
                        add     hl,de                       ; hl =  y^ 2 + x ^ 2 + z ^ 2
                        ex      de,hl                       ; fix as hl was holding square
                        call    asm_sqrt                    ; hl = sqrt (de) = sqrt (x ^ 2 + y ^ 2 + z ^ 2)
                        ; add in logic if h is low then use lower bytes for all 
                        ld      a,l
                        ld      iyh,a
                        ld      d,a
                        pop     bc                          ; retrive tacticsvectorz scaled
                        ld      a,c                         ; a = scaled byte
                        call    AequAdivDmul967Bit;AequAdivDmul96Unsg          ; This rountine I think is wrong and retuins bad values
                        ld      (TacticsVectorZ),a
                        pop     de
                        ld      a,e
                        ld      d,iyh                        
                        call    AequAdivDmul967Bit;AequAdivDmul96Unsg
                        ld      (TacticsVectorY),a
                        pop     hl
                        ld      a,l
                        ld      d,iyh                        
                        call    AequAdivDmul967Bit;AequAdivDmul96Unsg
                        ld      (TacticsVectorX),a
                        ; BODGE FOR NOW
                        ZeroA                              ;; added to help debugging
                        ld      (TacticsVectorX+1),a       ;; added to help debugging
                        ld      (TacticsVectorY+1),a       ;; added to help debugging
                        ld      (TacticsVectorZ+1),a       ;; added to help debugging
                        SignBitOnlyMem TacticsVectorX+2     ; now upper byte is sign only
                        SignBitOnlyMem TacticsVectorY+2     ; (could move it to lower perhaps later if 
                        SignBitOnlyMem TacticsVectorZ+2     ;  its worth it)
                      ;; oly using byte 2 for sign  ldCopyByte TacticsVectorX+2, TacticsVectorX+1
                      ;; oly using byte 2 for sign  ldCopyByte TacticsVectorY+2, TacticsVectorY+1
                      ;; oly using byte 2 for sign  ldCopyByte TacticsVectorZ+2, TacticsVectorZ+1
                      ;; oly using byte 2 for sign  SignBitOnlyMem TacticsVectorX+1     ; now upper byte is sign only
                      ;; oly using byte 2 for sign  SignBitOnlyMem TacticsVectorY+1     ; (could move it to lower perhaps later if 
                      ;; oly using byte 2 for sign  SignBitOnlyMem TacticsVectorZ+1     ;  its worth it)
                        ret
        ENDIF
