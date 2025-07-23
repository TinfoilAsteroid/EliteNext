
; Full version
; 1. K2 = y - alpha * x
; 2. z = z + beta * K2
; 3. y = K2 - beta * z
; 4. x = x + alpha * y



; SunrollWork holds Alpha intermidate results              
;  1. K2 = y - alpha * x
;  2. z = z + beta * K2
;  3. y = K2 - beta * z
;  4. x = x + alpha * y
;.... or
;  2. z = z + (beta * (y - alpha * x))
;  3. y = (y - alpha * x) - (beta * z)
;  4. x = x + (alpha * y)


;----------------------------------------------------------------------------------------------------------------------------------
; Sun version of pitch and roll is a 24 bit calculation 1 bit sign + 23 bit value
; Need to write a test routine for roll and pitchs
; Minsky Roll       Minsky Pitch
;  y -= alpha * x    y -= beta * z          
;  x += alpha * y    z += beta * y
; or once combined
;   1. K2 = y - alpha * x
;   2. z = z + beta * K2
;   3. y = K2 - beta * z
;   4. x = x + alpha * y
;------------------------------------------------------------------------------------------------------
;	alpha = flight_roll / 256.0;
;	beta = flight_climb / 256.0;
;    k2 = y - alpha * x;
;	z = z + beta * k2;
;	y = k2 - z * beta;
;	x = x + alpha * y;
;divs32   dehl = dehl' / dehl in our case it will be S78.0/ 0S78.0 to give us 0S78.0
; Performs minsky rotation based on play. As sun is a ball no local rotation is needed
SunApplyMyRollAndPitch:     ld      ix,SBnKxlo                  ; base location of position as 24 bit
                            MMUSelectMathsBankedFns
                            call    ApplyMyRollAndPitchIX
                            call    Normalise24IX
                            call    UpdateCompassIX
							ret
