ScaleXX16Matrix197:     
        IFDEF LOGMATHS
                        ld		b,9                 ; Interate though all 9 matrix elements
                        ld		hl,UBnkTransmatSidev ; within XX16 (transmat)
                        MMUSelectMathsTables
.ScaleXX16Loop:         ld		e,(hl)              ; set DE = matrix value              ;
                        inc		hl                  ;
                        ld		a,(hl)              ;
                        ld		d,a                 ;
                        and     SignOnly8Bit        ; A holds high still to we can strip out sign bit
                        ld		ixl,a				; retain for sign bit
                        ShiftDELeft1				; carry now holds sign bit and DE = De * 2, this will in effect strip off the sign bit automatically
                        ld      a,d                 ; a = high byte after x 2
                        push	bc                  ; save BC  counter and constant 197
                        push	hl                  ; save HL
                        call    AEquAmul256Div197Log;
                        pop		hl
                        dec     hl                  ; move back to low byte
                        ld      (hl),a              ; save result in low byte as we want to preserve high byte sign    
                        inc     hl                  ; move back to high byte  
                        ld      a,ixl
                        ld      (hl),a              ; write back just sign bit
                        pop		bc                  ; retrieve both counter and constant 197
                        inc     hl                  ; no to next vertex value
                        djnz	.ScaleXX16Loop
                        MMUSelectROM0
                        ret
        ELSE       
                        ld		b,9                 ; Interate though all 9 matrix elements
                        ld		c,ConstNorm         ; c = 197
                        ld		hl,UBnkTransmatSidev ; within XX16 (transmat)
.ScaleXX16Loop:         ld		a,(hl)              ; set DE = matrix value
                        ld		e,a                 ;
                        inc		hl                  ;
                        ld		a,(hl)              ;
                        ld		d,a                 ;
                        and     SignOnly8Bit        ; A holds high still to we can strip out sign bit
                        ld		ixl,a				; retain for sign bit
                        ShiftDELeft1				; carry now holds sign bit and DE = De * 2, this will in effect strip off the sign bit automatically
                        ld      a,d                 ; a = high byte after x 2
                        push	bc                  ; save BC  counter and constant 197
                        push	hl                  ; save HL
                        call	DIV16Amul256dCUNDOC; AEquAmul256DivD; DIV16Amul256dCUNDOC	; result in BC = A*256 / 197 or D *512 / 197 = 2.6 * vector element, effectivley the result will always be in c
                        pop		hl
                        dec     hl                  ; move back to low byte
                        ld      (hl),c              ; save result in low byte as we want to preserve high byte sign    
                        inc     hl                  ; move back to high byte  
                    ;    ld      a,(hl)
                    ;    and     $80
                        ld      a,ixl
                        ld      (hl),a              ; write back just sign bit
                        pop		bc                  ; retrieve both counter and constant 197
                        inc     hl                  ; no to next vertex value
                        djnz	.ScaleXX16Loop
                        ret
        ENDIF