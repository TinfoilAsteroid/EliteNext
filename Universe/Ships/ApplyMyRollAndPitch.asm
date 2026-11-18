
; Full version
; 1. K2 = y - alpha * x
; 2. z = z + beta * K2
; 3. y = K2 - beta * z
; 4. x = x + alpha * y

ShipApplyMyRollAndPitch:    ld      ix,UBnKposition             ; base location of position as 24 bit
                            ld      iy,UBnKPosFrac              ; with a fraction byte per axis so small moves are kept
                            MMUSelectMathsBankedFns
                            call    ApplyMyRollAndPitchFracIX
                            call    UpdateCompassIX
                            ld      ix,UBnkrotmatNosev
                            call    ApplyMyRollAndPitchMatIX
                            ld      ix,UBnkrotmatRoofv
                            call    ApplyMyRollAndPitchMatIX
                            ld      ix,UBnkrotmatSidev
                            call    ApplyMyRollAndPitchMatIX
							ret


