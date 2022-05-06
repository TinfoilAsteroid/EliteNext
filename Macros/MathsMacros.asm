
DEEquSquareA:           MACRO
                        ld  d,a
                        ld  e,a
                        mul de
                        ENDM

ApplyMyRollToVector:    MACRO angle, vectorX, vectorY
                        ldCopyByte angle,varQ               ; Set Q = a = alpha (the roll angle to rotate through)
                        ldCopy2Byte vectorY, varR           ; RS =  nosev_y
                        ldCopyByte  vectorX, varP           ; set P to nosevX lo (may be redundant)
                        ld a,(vectorX+1)                    ; Set A = -nosev_x_hi
                        xor $80                             ;
                        call  madXAequQmulAaddRS            ; Set (A X) = Q * A + (S R) = = alpha * -nosev_x_hi + nosev_y
                        ld  (vectorY),de                    ; nosev_y = nosev_y - alpha * nosev_x_hi
                        ldCopy2Byte vectorX, varR           ; Set (S R) = nosev_x
                        ld  a,(vectorY+1)                   ;  Set A = nosev_y_hi
                        call madXAequQmulAaddRS             ; Set (A X) = Q * A + (S R)
                        ld  (vectorX),de                    ; nosev_x = nosev_x + alpha * nosev_y_hi
                        ENDM

SignedHLTo2C:           MACRO
                        bit     7,h
                        jr      z,.Done2c
                        ld      a,h
                        and     SignMask8Bit
                        ld      h,a
                        NegHL
.Done2c:                                        
                        ENDM

MemSignedTo2C:          MACRO   memfrom
                        ld      hl,(memfrom)
                        bit     7,h
                        jr      z,.Done2c
                        ld      a,h
                        and     SignMask8Bit
                        ld      h,a
.Done2c:                ld      (memfrom),hl
                        ENDM
                        
                        
    ;returns result in H
EDiv10Inline:           MACRO
                        ld      d,0
                        ld      hl,de 
                        add     hl,hl
                        add     hl,de
                        add     hl,hl
                        add     hl,hl
                        add     hl,de
                        add     hl,hl
                        ENDM
                        
cpHLDE:                 MACRO
                        push    hl
                        and     a
                        sbc     hl,de
                        pop     hl
                        ENDM

;Unsigned
;If HL == DE, then Z flag is set.
;If HL != DE, then Z flag is reset.
;If HL <  DE, then C flag is set.
;If HL >= DE, then C flag is reset.
;
;Signed
;If HL == DE, then Z flag is set.
;If HL != DE, then Z flag is reset.
;If HL <  DE, then S and P/V are different.
;If HL >= DE, then S and P/V are the same.