;;;;;;&0311,X \ FRIN,X \ the Type for each of the 12 ships allowed
;;;;;;
;;;;;;FLFLLS:
;;;;;;	.FLFLLS	\ -> &360A \ New Flood-filled Sun, ends with Acc=0
;;;;;;A0 BF                   LDY #191 	     \ #2*Y-1 is top of Yscreen
;;;;;;A9 00                   LDA #0	  	     \ clear each line
;;;;;;	.SAL6	\ counter Y
;;;;;;99 00 0E                STA &0E00,Y  \ LSO,Y \ line buffer solar
;;;;;;88                      DEY 		     \ fill next line with zeros
;;;;;;D0 FA                   BNE SAL6	     \ loop Y
;;;;;;88                      DEY 		     \ Yreg = #&FF
;;;;;;8C 00 0E                STY &0E00    \ LSX   \ overlaps with LSO vector 
;;;;;;60                      RTS 

WipeScanner:								; WPSHPS	\ -> &35D8  \ Wipe Ships on scanner
; "Wipe Scanner"
	ld		b,0
	ld		hl, FRIN
.OuterLoop:
	ld		a,(hl)
	cp		0
	jr		z,.NothingInLocation			; in original it assumed free list shuffles, we won't and hard clear
	bit     7,a
	jr		nz,.LoopAlsoPlanetOrSun
	ld		(TYPE),a
.SelectUnivBank:
	ld		a,b
	add		UniverseBasePage
	nMMUSelectUniverseA			            ; select correct universeobject page
	ld		c,31
; We won't copy as the bank holds a local copy of data all the time	
	ld		de,UBnkexplDsp					; start with INWK+31
;we don;t need to copy into inwk as we can work from univ object data as we don;t have 6502 zero page on z80
	ld		(XSAV),b						; get scanner updated based on b
	call	SCAN							; draw ship b (XSAV holds a copy) on scanner
	ld		b,(XSAV)
	ld		a,(UBnkexplDsp)
	and		$A7								; clear bits 6,4,3 (explode,invisible,dot)
	ld		(UBnkexplDsp),a					; and keep bits 7,5,2,1,0 (kill,exploding,missiles)
.LoopAlsoPlanetOrSun:						; loop and skip if planet or sun
	inc		b
	cp		FreeListSize
	jr		nz,.OuterLoop
.ClearLineBuffers:
	ld		a,$FF
	ld		(LSX2),a						; Lines x2 and y2
	ld		(LSY2),a                        ; Lines x2 and y2
.FloodFills
; "TODO call	FLFLLS"
	ret
InitialilseUniverseBanks:                   ; Interrupts must be disabled before calling this
    MMUSelectUniverseN 70                   ; Select Primary ship register
    ld      c,71
    ld      b,12
.InitLoop:    
    push    bc
    ld      a,c                             ; copy to bank 71 onwards
    MMUSelectCpySrcA
    ld      hl,dmaCopySrcAddr
    ld      de,UniverseBankAddr
    ld      bc,$2000                        ; just blanket copy all 78K for now
    call    memfill_dma
    pop     bc
    inc     c
    djnz    .InitLoop
    ret

ZeroData:


game_reset:									;.RESET	\ -> &3682 \ New player ship, called by TITLE 
; "TODO call	zero_data	"		;ZERO   \ zero-out &311-&34B, does this leave a as 0 -> Yes
	xor		a
	ld		b,7
	ld		hl, BETA
.ClearBetaLoop:								; Clears out BETA, BET1, XC, YC, both HyperCount, ECMActive
	ld		(hl),a							; These must be defined continguous
	inc		hl
	djnz	.ClearBetaLoop
	ld		a,PlayerDocked					; Set up in dock which happens to be also $FF
	ld		(DockedFlag),a
	ld		hl, PlayerForwardSheild0		; Load player field 0 to 2 with FF
	ld		(hl),a
	inc		hl
	ld		(hl),a
	inc		hl
	ld		(hl),a
	; Now fall into Reset2
Reset2:										; .RES2	\ -> &3697  \ Reset2
	ld		a,MaxNumberOfStars				; Init star count to 18
	ld		(NumberofStars),a
	ld		a,$FF							; bline buffers cleared, 78 bytes.
	ld		(LSX2),a
	ld		(LSY2),a
	ld		(MSTG),a                     	; missile has no target
	ld		a,$80							; center joysticks position
    xor			a                          ; for next 0 = center
	ld		(JSTY),a						; joystick Y
	ld		(JSTX),a						; joystick X
	ld		(ALP2),a  						; ALP2   \ roll sign
	ld		(BET2),a						; BET2   \ pitch sign 
	xor		a								;  = 0
	ld		(ALP2FLIP),a                    ; negated roll sign
	ld		(BET2FLIP),a                    ; negated pitch sign
	ld		(MCNT),a                        ; move count
	ld		(OuterHyperCount),a				; Reset Hyperspace Jump
	ld		(InnerHyperCount),a				; Reset HyperspaceJump
	ld		a,3                             ; keep ship distance fixed on title screen
	ld		(DELTA),a                       ; bpl -2 inserted here to stall from title code if byte check fails
	ld		(ALPHA),a                       ;  \ gentle roll to player for ship on title screen
	ld		(ALP2),a                        ;  roll magnitude
.SpaceStationSetup:	
	ld		a,(SpaceStationPresent)			; \ space station present, 0 is SUN.
	cp		0
	call	nz,.SpaceStationBulb			;  SPBLB  \ space station bulb
	ld		a,(ECMActive)					;  E.C.M. active
	cp		0
	call	nz,.NoResetECMSound				; call sound reset if needed
.ResetScanner:
; "TODO call	WipeScanner"						; WPSHPS \ wipe ships on scanner
; "TODO call	ZeroData"						; zero-out &311-&34B
	ld		hl,ShipLineStackPointer
	ld		(hl),ShipLineStackTop			; Set stack, this will likley be removed by local page index lists of lines to draw
; "TODO call	UpdateDials"						; DIALS  \ update flight console
; "TODO call	ClearKeyboard"					;  \ Uperc  \ clear keyboard logger
; "TODO call	MissileBlobs"					; .msblob	\ -> &3F3B \ update Missile blocks on console
.ZeroInformation:							;.ZINF	\ -> &36D8 \ Zero Information, ends with Acc = #&E0
; "TODO Clear Rotation Matrix"
; "TODO Initialise universe ship banks"
    
;;;;;;	ld		TODO DEAL with Matrix
;;;;;;A0 24                   LDY #36  	    \ #NI%-1 = NI%=37 is size of inner working space 
;;;;;;A9 00                   LDA #0
;;;;;;	.ZI1	\ counter Y
;;;;;;99 46 00                STA &0046,Y	    \ INWK,Y
;;;;;;*** MAY NOT NEED SHIP LEVEL ROTAION MATRIX MAY ONLY NEED 1 GLOBAL
;;;;;;88                      DEY 
;;;;;;10 FA                   BPL ZI1		    \ loop Y
;;;;;;A9 60                   LDA #&60	    \ unity in rotation matrix
;;;;;;85 58                   STA &58	 \ INWK+18  \ rotmat1y hi
;;;;;;85 5C                   STA &5C  \ INWK+22  \ rotmat2x hi
;;;;;;09 80                   ORA #&80	    \ -ve unity = #&E0
;;;;;;85 54                   STA &54  \ INWK+14  \ rotmat0z hi = -1
;;;;;;60                      RTS 
;;;;;;--- IN FLIGHT VERSION TO MERGE ---
;;;;;;A9 60                   LDA #&60	    \ unity in rotation matrix
;;;;;;85 58                   STA &58   \ INWK+18 \ rotmat1y hi
;;;;;;85 5C                   STA &5C	  \ INWK+22 \ rotmat2x hi
;;;;;;09 80                   ORA #&80 	    \ -ve unity = #&E0
;;;;;;85 54                   STA &54	  \ INWK+14 \ rotmat0z hi = -1

	ret

HexMap			DB "0123456789ABCDEF"

ShipFile		macro filename
				dw	Filesize(filename)
				db	\0
				db	0
				; "file='",\0,"'  size=",Filesize(\0)
				endm

; Initially will just hold ship 0 but updated in loop, this used as all files must be same size
loadShipName	ShipFile		"ships\Ship01.Shp"

load_ships:				; sod selective load from disk, get them all in
	xor			a
	ld			(varGPLoopA),a
	ld			a, ShipDataBasePage
	push		af
.SelectPageInBankLoop:	
	MMUSelectShipModelA
.Cleardownpage:
	ld			hl, ShipmodelbankAddr   	; Zap memory bank 6 now its selected
	ld			de, membanksize
	xor			a
	call		memfill_dma
.SetFilename:
	pop			af							; get page id and save again
	push		af
	ld			b,a							; save for 2nd char
	and			$F0							; top 4 bits
	swapnib									; move to lower 4 bits
	ld			hl,Hexmap
	add			hl,a
	ld			a,(hl)						; now we have hex as ascii
	ld			(loadShipName + 10),a		; set high digit of name
	ld			a,b							; get a value back
	and			$0F							; lower bits
	ld			hl,Hexmap
	add			hl,a
	ld			a,(hl)						; now we have hex as ascii
	ld			(loadShipName + 11),a		; set low digit of name
.ReadInFile:
	ld			hl, ShipFile
	ld			ix, ShipmodelbankAddr
	call		FileLoad
	MESSAGE 	"For now sod error handling, if data is garbage tough :) "
.RepeatLoop:
	ld			a,(varGPLoopA)
	inc			a
	cp			ShipCountMax
	jr			c,.AllLoaded
	ld			(varGPLoopA),a
	pop			af
	jr			.SelectPageInBankLoop
.AllLoaded:
	ret

reset_ships:
	call		load_ships                  ; LSHIPS \ Load ship(s) files
	call		game_reset                  ; RESET  \ new player ship, controls, dust field.
	ld			a,PlayerDocked              ; Docked flag set
	ld			(DockedFlag),a              ; QQ12
	ld			(MenuIdMax),a               ; QQ11  \ menu id max
	ld			a,KeyForwardsView           ; red key #f0, forward view. 
	ret			
	; NOTE IN ORIGINAL THIS WOUDL BE DONE: 	jp			force_keyboard_entry		; FRCE  \ forced entry into keyboard main loop

