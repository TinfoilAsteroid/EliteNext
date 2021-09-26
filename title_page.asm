
titleToken	DB 	0


QQ17 		DB	0 				; first token Uppercase

DETOK:
; ">DETOK : TODO"
	ret

Title:
; ">Title: Display Title and rotating ship home page"
	ld		(titleToken),a				; save incomming token
	ld		a, TitleShip				; TYPE  \ of ship to display
	call	TotalReset					; \ Total reset, New ship. 
	ld		a,1							; menu id QQ11 will be set to #1
	call	BoxBorder
	ld		hl,varQQ1					; \ menu id = #0
	dec		(hl)
	ld		a,RotationUnity				; $60 or also 96 dec
	ld		(rotmat0zhi),accepted		; INWK+14
	ld		a,(Point)				
	cp		DBCheckCode					;  \ POINT \ compass target in Elite-A
	jr		z,.skipStall				;  if POint = DB hop over stall
	
;; Sees tp ne self modifying code to cause loop to hand by infinite loop on a BPL 
;; goodness knows if its anyting more than copyright protection?
;A5 9F                   LDA &9F   \ POINT \ compass target in Elite-A
;C9 DB                   CMP #&DB	  \ looking for DB check code?
;F0 0A                   BEQ tiwe          \ matched, hop over stall
;A9 10                   LDA #&10	  \ OpCode  BPL
;8D B8 36                STA &36B8         \ replace STA DELTA
;A9 FE                   LDA #&FE	  \ branch -2
;8D B9 36                STA &36B9	  \ with BPL -2 to stall code


.skipStall:
	ld		(INWKzhi),a						;	INWK+7 \ INWKzhi set to #&DB
	ld		hl,$7F7F					; No  damping of rotation
	ld		(rotXCounter),hl			; set both rotx and rotz to 7F
	ld		(rotXCounter),
	inc		l							; lreg = #&80
	ld		(QQ17),l					; first token Uppercase
	ld		a,TitleShip					; TYPE  \ of ship
	call	SpawnNewShip				; NWSHP \ new ship
	ld		a,6
	ld		(XC),6						; Position for Text
	ld		a,EliteToken
	call	TT27						; token = ---- E L I T E ---- plf  \ TT27 text token followed by rtn
	ld		a,7
	ld		(XC),6
	ld		hl,YC
	inc		(hl)						; At some point in reset this must have been pre -set up
	ld		a,(PATG)					; PATG  \ toggle startup message display WTF is PATG?
	cp		0
	jr		z,.skipCredits				; skip credits is PATG is 0
	ld		a,$BrabenBellToken
	call	DETOK						; DETOK \ use TKN1 docked token to detokenise
.skipCredits:							; skipped credits no need to do the break flag logic for BBC break key (awe & awl)
	call	CLYNS						; CLYNS \ clear some screen lines, Yreg set to 0.#
	ld		a,0							
	ld	    (DELTA),a					; DELTA = 0
	ld		(JSTK),a					;  Joystick not active need logic for joystick input
	ld		a,(titleToken)				; get saved token
	call	DETOK						; last token that was sent to TITLE DETOK \ use TKN1 docked token
	ld		a,7
	ld		(XC),accepted				; Indent 7
	ld		a,AcornToken				; token = (C) ACORNSOFT 1984
	call	DETOK						;
; ">REPLACE DETOK with a = token, bc = yx position to print at"
.KeyScanLoop:
	ld		a, (INWKzhi)
	cp		1							; ship is now z distance 1 which is close enough
	jr		z,	.shipCloseEnough		; Close enough so don't move z any more, just spin
	dec		a
	ld		(INWKzhi),a					
.shipCloseEnough:			
	call	MVEIT						; MVEIT \ move it
	ld		a,$80						; half hi (i.e. 0.5)
	ld		(INWKzlo),a					; INWK+6 \ zlo
	xor		a							; in 6502 was ASL A, as prev value was $80 Acc = 0 for center of screen
	ld		(INWKxlo),a					; INWK+0 \ xlo = 0
	ld		(INWKyLo),a					; INWK+3 \ ylo  = 0
	call	DisplayObject				; object entry .LL9 in original
	ld		hl, MCNT					; MCNT  \ move count
	dec		(hl)
	call	GetJoystickFireButtonState	; replaces call to VIA output register b in 6502, returns result in a, 0 pressed else not pressed
	jr		z,.FirePressed
.FireNotPressed:
	call	RdContinueKey				; Scan Keyboard for the "Press key to continue key press"
; ">TODO WRITE RdContinueKey to repalce scan for Delete a = 0 key presed, else not"
	ret		z							; Until key read
	jr		.KeyScanLoop
	ld		hl,JSTK
	dec		(hl)						; set JSTK to FF to say its been detected and active
	ret
