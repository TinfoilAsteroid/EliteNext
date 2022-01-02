

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
                        