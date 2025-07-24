
; Full version
; 1. K2 = y - alpha * x
; 2. z = z + beta * K2
; 3. y = K2 - beta * z
; 4. x = x + alpha * y

ShipApplyMyRollAndPitch:    ld      ix,UBnKxlo                  ; base location of position as 24 bit
                            MMUSelectMathsBankedFns
                            call    ApplyMyRollAndPitchIX
                            call    Normalise24IX
                            call    UpdateCompassIX
							ret


