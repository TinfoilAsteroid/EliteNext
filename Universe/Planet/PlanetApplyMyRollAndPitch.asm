
;----------------------------------------------------------------------------------------------------------------------------------
; Planet version of pitch and roll is a 24 bit calculation 1 bit sign + 23 bit value
; Need to write a test routine for roll and pitchs
PlanetAlphaMulX            DB $00,$00, $00, $00
PlanetAlphaMulY            DB $00,$00, $00, $00
PlanetAlphaMulZ            DB $00,$00, $00, $00
PlanetBetaMulZ             DB $00,$00, $00, $00
PlanetBetaMulY             DB $00,$00, $00, $00
PlanetK2                   DS 3

;----------------------------------------------------------------------------------------------------------------------------------
; Sun version of pitch and roll is a 24 bit calculation 1 bit sign + 23 bit value
; Need to write a test routine for roll and pitchs

; Gets values backwards, is it 24 bit safe?

PlanetApplyMyRollAndPitch: 	ld      a,(ALPHA)                   ; no roll or pitch, no calc needed
.CheckForRoll:              and		a
							call	nz,Planet_Roll
.CheckForPitch:				ld		a,(BETA)
							and		a
							call	nz,Planet_Pitch
.ApplySpeed:            	ld      a,(DELTA)                   ; BCH = - Delta
							ReturnIfAIsZero
							ld      c,0                         ;
							ld      h,a                         ; 
							ld      b,$80                       ;
							ld      de,(P_BnKzhi)                ; DEL = z position
							ld      a,(P_BnKzlo)                 ; .
							ld      l,a                         ; .
							call    AddBCHtoDELsigned           ; update speed
							ld      (P_BnKzhi),DE                ; write back to zpos
							ld      a,l
							ld      (P_BnKzlo),a                ;
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
Planet_Roll:				ld      a,(ALPHA)                   ; get roll value
							and 	$7F
							ld      d,a                         ; .
							ld      a,(P_BnKylo)                ; HLE = x sgn, hi, lo
							ld      e,a                         ; .
							ld      hl,(P_BnKyhi)               ; .
							call    DELCequHLEmulDs; replaces mulHLEbyDSigned             ; DELC = x * alpha, so DEL = X * -alpha / 256 
							ld		a,l
							ld		(PlanetAlphaMulY),a			; save result
							ld		(PlanetAlphaMulY+1),de		; save result
							ld      a,(ALPHA)                   ; get roll value
							and 	$7F
							ld      d,a                         ; .
							ld      a,(P_BnKxlo)                ; HLE = x sgn, hi, lo
							ld      e,a                         ; .
							ld      hl,(P_BnKxhi)               ; .
							call    DELCequHLEmulDs; replaces mulHLEbyDSigned             ; DELC = x * alpha, so DEL = X * -alpha / 256 
							ld		a,l
							ld		(PlanetAlphaMulX),a			; save result
							ld		(PlanetAlphaMulX+1),de		; save result							
							ld		a,(ALPHA)
							and		$80
							jp		z,.RollingRight
.RollingLeft:				ld		ix,P_BnKxlo
							ld		iy,PlanetAlphaMulY
							call	AddAtIXtoAtIY24Signed
							ld		ix,P_BnKylo
							ld		iy,PlanetAlphaMulX
							call	SubAtIXtoAtIY24Signed
							ret
.RollingRight:				ld		ix,P_BnKxlo
							ld		iy,PlanetAlphaMulY
							call	SubAtIXtoAtIY24Signed
							ld		ix,P_BnKylo
							ld		iy,PlanetAlphaMulX
							call	AddAtIXtoAtIY24Signed
							ret

Planet_Pitch:				ld      a,(BETA)                   ; get roll value
							and 	$7F
							ld      d,a                         ; .
							ld      a,(P_BnKylo)                ; HLE = x sgn, hi, lo
							ld      e,a                         ; .
							ld      hl,(P_BnKyhi)               ; .
							call    DELCequHLEmulDs; replaces mulHLEbyDSigned             ; DELC = x * alpha, so DEL = X * -alpha / 256 
							ld		a,l
							ld		(PlanetBetaMulY),a			; save result
							ld		(PlanetBetaMulY+1),de		; save result
							ld      a,(BETA)                   ; get roll value
							and 	$7F
							ld      d,a                         ; .
							ld      a,(P_BnKzlo)                ; HLE = x sgn, hi, lo
							ld      e,a                         ; .
							ld      hl,(P_BnKzhi)               ; .
							call    DELCequHLEmulDs; replaces mulHLEbyDSigned             ; DELC = x * alpha, so DEL = X * -alpha / 256 
							ld		a,l
							ld		(PlanetBetaMulZ),a			; save result
							ld		(PlanetBetaMulZ+1),de		; save result							
							ld		a,(BETA)
							and		$80
							jp		z,.Climbing
.Diving:					ld		ix,P_BnKylo
							ld		iy,PlanetBetaMulZ
							call	AddAtIXtoAtIY24Signed
							ld		ix,P_BnKzlo
							ld		iy,PlanetBetaMulY
							call	SubAtIXtoAtIY24Signed
							ret
.Climbing:		     		ld		ix,P_BnKylo
							ld		iy,PlanetBetaMulZ
							call	SubAtIXtoAtIY24Signed
							ld		ix,P_BnKzlo
							ld		iy,PlanetBetaMulY
							call	AddAtIXtoAtIY24Signed	
							ret