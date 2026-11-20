; Not in the build: nothing called these. DEequDmulEs was in MathsFPS78/asm_multiply_S78.asm,
; ApplyMyAngleAToIXIY and ApplyRollAndPitchToIX (its only callers) in Maths/MathsBankedFns.asm.
; Roll and pitch are now done by Maths24/asm_rollpitch24_origin.asm.

; DE = D (S7) * E (S7), lead sign result, uses A and B
DEequDmulEs:        ld      a,d                     ; work out resultant sign and load into b
                    xor     e                       ; .
                    and     SignOnly8Bit            ; .
                    ld      b,a                     ; .
                    ld      a,d                     ; now clear d sign bit
                    and     SignMask8Bit            ; .
                    ld      d,a                     ; .
                    ld      a,e                     ; now clear e sign bit
                    and     SignMask8Bit            ; .
                    ld      e,a                     ; .
                    mul     de                      ; do mulitply
                    ld      a,d                     ; get sign bit from b and re0introduce it
                    or      b                       ; .
                    ld      d,a                     ; .
                    ret

;------------------------------------------------------------
; Note vectors are 2 byte lead sign, angle is 8 bit lead sign
ApplyMyAngleAToIXIY:    ;break
                        push    af                          ; save angle
; Calculate Angle * vector /256, i.e take angle and mutiple by high byte of vector
.processVector1:        ld      e,a                         ; e = angle
                        ld      d,(ix+1)                    ; d = vector 1 / 256
                        call    DEequDmulEs               ; calcualte DE = Vector * angle /256
                        ld      hl,(iy+0)                   ; hl = vector 2
                        call    SubDEfromHLSigned           ; hl = vector 2 - (vector 1 * angle / 256)
                        ld      (iy+0),hl                   ; .
.processVector2:        pop     af
                        ld      e,a                         ; e = angle
                        ld      d,(iy+1)                    ; d = vector 2 / 256
                        call    DEequDmulEs               ; de = vector 2 * angle /256
                        ld      hl,(ix+0)                   ; hl = vector 1
                        call    AddDEtoHLSigned             ; hl = hl + de
                        ld      (ix+0),hl                   ; .
                        ret
;------------------------------------------------------------
; Applies Roll Alpha and Pitch Beta to vector at IX
ApplyRollAndPitchToIX:
;-- y Vector = y - alpha * nosev_x_hi
                        ld      e,(ix+1)                    ; e = X component hi
                        ld      a,(ALPHA)                   ; alpha S7
                        ld      d,a
                        call    DEequDmulEs               ; d = X Vector * alpha / 256
                        ld      l,(ix+2)                    ; hl = Y Vector component
                        ld      h,(ix+3)                    ;
                        call    SubDEfromHLSigned           ; hl = Y - (alpha * nosev x hi)
                        ld      (ix+2),l                    ; dont round Y up yet
                        ld      (ix+3),h
;-- x Vector = x Vector + alpha * y_hi
                        ld      e,(ix+3)                    ; e = y component hi
                        ld      a,(ALPHA)                   ; alpha S7
                        ld      d,a
                        call    DEequDmulEs               ; d = y Vector * alpha / 256
                        ld      l,(ix+0)                    ; hl = x Vector component
                        ld      h,(ix+1)                    ;
                        call    AddDEtoHLSigned             ; hl = x + (alpha * nosev x hi)
                    IFDEF ROUND_ROLL_AND_PITCH
                        ld      l,0                         ; round up x
                    ENDIF
                        ld      (ix+0),l
                        ld      (ix+1),h
;-- nosev_y = nosev_y - beta * nosev_z_hi
                        ld      e,(ix+5)                    ; e = z component hi
                        ld      a,(BETA)                    ; beta S7
                        ld      d,a
                        call    DEequDmulEs               ; d = Z Vector * beta / 256
                        ld      l,(ix+2)                    ; hl = y Vector component
                        ld      h,(ix+3)                    ;
                        call    SubDEfromHLSigned           ; hl = Y - (beta * nosev z hi)
                    IFDEF ROUND_ROLL_AND_PITCH
                        ld      l,0                         ; round up Y
                    ENDIF
                        ld      (ix+2),l
                        ld      (ix+3),h
;-- nosev_z = nosev_z + beta * nosev_y_hi
                        ld      e,(ix+3)                    ; e = y component hi
                        ld      a,(BETA)                    ; beta S7
                        ld      d,a
                        call    DEequDmulEs               ; d = y Vector * beta / 256
                        ld      l,(ix+4)                    ; hl = z Vector component
                        ld      h,(ix+5)                    ;
                        call    AddDEtoHLSigned             ; hl = z + (beta * nosev z hi)
                    IFDEF ROUND_ROLL_AND_PITCH
                        ld      l,0                         ; round up zwd
                    ENDIF
                        ld      (ix+4),l
                        ld      (ix+5),h
                        ret
