
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
;----------------------------------------------------------------------------------------------------------------------------------
; Based on non optimised version of Sun pitch and roll is a 24 bit calculation 1 bit sign + 23 bit value
; Now at least rolls the correct direction
SunAlphaMulX                DB $00,$00, $00, $00
SunAlphaMulY                DB $00,$00, $00, $00
SunAlphaMulZ                DB $00,$00, $00, $00
SunBetaMulZ                 DB $00,$00, $00, $00
SunBetaMulY                 DB $00,$00, $00, $00
SunK2                       DS 3

SunApplyMyRollAndPitch: 	ld      a,(ALPHA)                   ; no roll or pitch, no calc needed
.CheckForRoll:              and		a
							call	nz,Sun_Roll
.CheckForPitch:				ld		a,(BETA)
							and		a
							call	nz,Sun_Pitch
.ApplySpeed:            	ld      a,(DELTA)                   ; BCH = - Delta
							ReturnIfAIsZero
							ld      c,0                         ;
							ld      h,a                         ; 
							ld      b,$80                       ;
							ld      de,(SBnKzhi)                ; DEL = z position
							ld      a,(SBnKzlo)                 ; .
							ld      l,a                         ; .
							call    AddBCHtoDELsigned           ; update speed
							ld      (SBnKzhi),DE                ; write back to zpos
							ld      a,l
							ld      (SBnKzlo),a                ;
							ret
; Performs minsky rotation
; Joystick left          Joystick right
; ---------------------  ---------------------
; x :=  x      + y / 64  x :=  x -  y / 64  so rather than /64  is z * alpha / 256
; y :=  y      - x /64   y :=  y +  x / 64     
;
; Joystick down          Joystick up
; ---------------------  ---------------------
; y :=  y      + z / 64  y :=  y - z / 64
; z :=  z      - y / 64  z :=  z + y / 64      
; 
; get z, multiply by alpha, pick top 3 bytes with sign
; get x, multiply by alpha, pick top 3 bytes with sign
; if alpha +ve subtract x = x - z adj, z =z + x adj , else x += z adj z -= z adj 
Sun_Roll:				    ld      a,(ALPHA)                   ; get roll value
							and 	$7F
							ld      d,a                         ; .
							ld      a,(SBnKylo)                ; HLE = x sgn, hi, lo
							ld      e,a                         ; .
							ld      hl,(SBnKyhi)               ; .
							call    DELCequHLEmulDs; replaces mulHLEbyDSigned             ; DELC = x * alpha, so DEL = X * -alpha / 256 
							ld		a,l
							ld		(SunAlphaMulY),a			; save result
							ld		(SunAlphaMulY+1),de		; save result
							ld      a,(ALPHA)                   ; get roll value
							and 	$7F
							ld      d,a                         ; .
							ld      a,(SBnKxlo)                ; HLE = x sgn, hi, lo
							ld      e,a                         ; .
							ld      hl,(SBnKxhi)               ; .
							call     DELCequHLEmulDs; replaces mulHLEbyDSigned             ; DELC = x * alpha, so DEL = X * -alpha / 256 
							ld		a,l
							ld		(SunAlphaMulX),a			; save result
							ld		(SunAlphaMulX+1),de		; save result							
							ld		a,(ALPHA)
							and		$80
							jp		z,.RollingRight
.RollingLeft:				ld		ix,SBnKxlo
							ld		iy,SunAlphaMulY
							call	AddAtIXtoAtIY24Signed
							ld		ix,SBnKylo
							ld		iy,SunAlphaMulX
							call	SubAtIXtoAtIY24Signed
							ret
.RollingRight:				ld		ix,SBnKxlo
							ld		iy,SunAlphaMulY
							call	SubAtIXtoAtIY24Signed
							ld		ix,SBnKylo
							ld		iy,SunAlphaMulX
							call	AddAtIXtoAtIY24Signed
							ret

Sun_Pitch:				    ld      a,(BETA)                   ; get roll value
							and 	$7F
							ld      d,a                         ; .
							ld      a,(SBnKylo)                ; HLE = x sgn, hi, lo
							ld      e,a                         ; .
							ld      hl,(SBnKyhi)               ; .
							call     DELCequHLEmulDs; replaces mulHLEbyDSigned             ; DELC = x * alpha, so DEL = X * -alpha / 256 
							ld		a,l
							ld		(SunBetaMulY),a			; save result
							ld		(SunBetaMulY+1),de		; save result
							ld      a,(BETA)                   ; get roll value
							and 	$7F
							ld      d,a                         ; .
							ld      a,(SBnKzlo)                ; HLE = x sgn, hi, lo
							ld      e,a                         ; .
							ld      hl,(SBnKzhi)               ; .
							call     DELCequHLEmulDs; replaces mulHLEbyDSigned             ; DELC = x * alpha, so DEL = X * -alpha / 256 
							ld		a,l
							ld		(SunBetaMulZ),a			; save result
							ld		(SunBetaMulZ+1),de		; save result							
							ld		a,(BETA)
							and		$80
							jp		z,.Climbing
.Diving:					ld		ix,SBnKylo
							ld		iy,SunBetaMulZ
							call	AddAtIXtoAtIY24Signed
							ld		ix,SBnKzlo
							ld		iy,SunBetaMulY
							call	SubAtIXtoAtIY24Signed
							ret
.Climbing:		     		ld		ix,SBnKylo
							ld		iy,SunBetaMulZ
							call	SubAtIXtoAtIY24Signed
							ld		ix,SBnKzlo
							ld		iy,SunBetaMulY
							call	AddAtIXtoAtIY24Signed	
							ret