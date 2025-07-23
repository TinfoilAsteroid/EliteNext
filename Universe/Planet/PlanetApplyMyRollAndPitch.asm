
;----------------------------------------------------------------------------------------------------------------------------------
; Planet version of pitch and roll is a 24 bit calculation 1 bit sign + 23 bit value
; Need to write a test routine for roll and pitchs

;----------------------------------------------------------------------------------------------------------------------------------
; Sun version of pitch and roll is a 24 bit calculation 1 bit sign + 23 bit value
; Need to write a test routine for roll and pitchs

; Gets values backwards, is it 24 bit safe?

PlanetApplyMyRollAndPitch: 	ld      ix,P_BnKxlo                  ; base location of position as 24 bit
                            MMUSelectMathsBankedFns
                            call    ApplyMyRollAndPitchIX
                            call    Normalise24IX
                            call    UpdateCompassIX
							ret
