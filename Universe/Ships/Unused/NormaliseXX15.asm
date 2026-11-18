; Tested OK
;LL21        


NormaliseTactics:   ld      hl, (TacticsVectorX)        ; pull XX15 into registers
                    ld      de, (TacticsVectorY)        ; .
                    ld      bc, (TacticsVectorZ)        ; .
                    ld      a,(TacticsVectorX+2)        ; .
                    ld      iyh,a                       ; iyh = X sign
                    ld      a,(TacticsVectorY+2)        ; .
                    ld      iyl,a                       ; iyl = Y sign
                    ld      a,(TacticsVectorZ+2)        ; .
                    ld      ixh,a                       ; ixh = z sign
.ScaleLoop:         or      iyh                         ; now check if upper has value
                    or      iyl                         ; .
                    ClearSignBitA                       ;  exluding sign bit
                    jr      z,.DoneScaling              ; and exit loop if upper byte is only sign component
.ScaledDownBy2:     ld      a,iyh
                    sra     a
                    ld      iyh,a                       ; actually we can keep sign bit so just sr then rr
                    rr      h                           ; Deal with X
                    rr      l                           ;
                    ld      a,iyl
                    sra     a                           ; actually we can keep sign bit so just sr then rr
                    ld      iyl,a
                    rr      d                           ; Deal with Y
                    rr      e                           ;
                    ld      a, ixl                      ; actually we can keep sign bit so just sr then rr
                    sra     a
                    ld      ixl,a
                    rr      b                           ; Deal with Z
                    rr      c                           ;
                    jp      .ScaleLoop
.DoneScaling:       ld      a,h
                    or      d
                    or      b
                    SignBitOnlyA                        ; check if new sign bit has a value rotated in, 
                    jr      z,.OKToNormalise
.ShiftTo15Bit:      ShiftHLRight1                       ; one last shift to 15 bit we don't need
                    ShiftDERight1                       ; to do sign bytes 
                    ShiftBCRight1                       ; as value must be 0
.OKToNormalise:     ld      a,h                         ; iyh now can only hold sign 
                    or      iyh                         ; so by the end of here
                    ld      h,a                         ;   hl = x
                    ld      a,d                         ;   de = y
                    or      iyl                         ;   bc = z
                    ld      d,a                         ; all scaled to 15 bit + sign
                    ld      a,b                         ;
                    or      ixh                         ;
                    ld      b,a                         ;
                    ld      (TacticsNormX),hl
                    ld      (TacticsNormY),hl
                    ld      (TacticsNormZ),hl
        IFDEF LOGMATHS
                    ld      hl,TacticsNormZ+1           ; initialise loop
                    ld      b,3                         ; total of 3 elements to transform
                    MMUSelectMathsTables
.LL21Loop:          ld      d,(hl)
                    dec     hl
                    ld      e,(hl)                      ; de = hilo now   hl now = pointer to low byte
                    ShiftDELeft1                        ; De = DE * 2
                    ld      a,d                         ; a = hi byte after shifting
                    push	hl
                    push	bc
                    call    AEquAmul256Div197Log        ; R = (2(hi).0)/ConstNorm - LL28 Optimised BFRDIV R=A*256/Q = delta_y / delta_x Use Y/X grad. as not steep
                    ;ld      a,c                         ; BFRDIV returns R also in l reg
                    pop		bc
                    pop		hl							; bc gets wrecked by BFRDIV
                    ld      (hl),a                      ; write low result to low byte so zlo = (zhl *2)/197, we keep hi byte in tact as we need the sign bit
                    dec     hl                          ; now hl = hi byte of pre val e.g z->y->x
                    djnz    .LL21Loop                   ; loop from 2zLo through to 0xLo
                    MMUSelectROM0
                    ret
        ELSE
                    ld      hl,TacticsNormZ+1           ; initialise loop
                    ld      c,ConstNorm                 ; c = Q = norm = 197
                    ld      a,c
                    ld      (varQ),a                    ; set up varQ
                    ld      b,3                         ; total of 9 elements to transform
LL21Loop:           ld      d,(hl)
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
        ENDIF