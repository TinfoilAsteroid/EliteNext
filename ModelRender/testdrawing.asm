
; Test of render
;  Generate a memory bank for a ship using univ_ship_data to create a block in bank 6
;  need to clear page 70
;  swap in to bank 7
;  use UBnKxlo as INWK 0 (we will add an equ so that its moved over)
;  x cobraMk3 data to map data
;  Use ShipModelTable table indexed by cobraMk3 ship number (CobraTablePointer)
;  Pull ship model table into bank 6
;  use dma transfer to copy data from bank 6 to bank 7
;
ScaleRotationMatrix197:
	ld		b,9
	ld		hl,UBnkTransmatSidev
ScaleRotationLoop:
	ld		a,(hl)
	ld		e,a
	inc		hl                  ; move to hi byte
	ld		a,(hl)
	ld		d,a
    and     SignOnly8Bit        ; strip out sign bit
	ld		ixl,a				; retain for sign bit
	ShiftDELeft1				; carry now holds sign bit and DE = De * 2
    ld      a,d
	ld		c,ConstNorm
	ld		a,d					; a = D Hi* 2
	push	bc
	push	hl
	call	DIV16Amul256dCUNDOC	; result in BC
	pop		hl
	ld		a,b
    or      ixl                 ; bring back sign bit
    ld      (hl),a
    dec     hl
    ld      (hl),c
    inc     hl
	pop		bc
    inc     hl                  ; no to next vertex value
	djnz	ScaleRotationLoop
	ret

GetXX18Scale:
    ld      a,(QAddr)
    ld      ixl,a                 ; save Scale in C
    ld      bc,(UBnkDrawCam0xLo)
    ld      de,(UBnkDrawCam0yLo)
    ld      hl,(UBnkDrawCam0zLo)
ScalePos:
    ld      a,b
    or      d
    or      h
    jp      z,ScalePosDone
    inc     ixl
    ShiftBCRight1
    ShiftDERight1
    ShiftHLRight1
    jp      ScalePos
ScalePosDone:
    ld      a,ixl
    ld      (XX17),a
    ret


ScaleOrientationXX16:
ScaleRotationMatrix:
    MODULE  ScaleRotationMatrix
	ld		b,9
	ld		hl,UbnkTransInvRow0x0
	ld		a,(XX17)
	cp		0
	ret		z									; no mulitplier then bail out early
	ld		ixl,a								; master copy of 2^multiplier
ScaleRotationLoop:
	ld		e,(hl)
	inc		hl
	ld		d,(hl)
	ld		a,d
	and		$80
	ld		ixh,a								; make a copy for sign purposes
	ld		a,d									; we need it back now to strip sign
	and		SignMask8Bit
	ld		d,a
	ld		c,ixl								; get master copy of multiplier
ScaleLoop:
	ShiftDELeft1
	dec		c
	jr		nz,ScaleLoop						; loop until 0
.NoMultiply:
	ld		a,d
	or		ixh									; bring sign bit back in to a and
	ld		(hl),a								; we don;t need to go though d reg as an optimisation
	dec		hl
	ld		(hl),e								; written back DE now
	inc		hl
	inc		hl									; on to next byte now
	djnz	ScaleRotationLoop
	ret
    ENDMODULE 


varR16			DW	0

TestProjectNodeToScreen:
	ld			bc,(UBnkZScaled)					; BC = Z Cordinate. By here it MUST be positive as its clamped to 4 min
	ld			a,c                                 ;  so no need for a negative check
	ld			(varQ),a		                    ; VarQ = z
    ld          a,(UBnkXScaled)                     ; XX15	\ rolled x lo which is signed
	call		DIV16Amul256dCUNDOC					; result in BC which is 16 bit TODO Move to 16 bit below not just C reg
;	ld			(varR16),bc							; store result in R for now TODO move to say D reg
    ld          a,(UBnkXScaledSign)                 ; XX15+2 \ sign of X dist
    JumpOnBitSet a,7,TestNegativeXPoint             ; LL62 up, -ve Xdist, RU screen onto XX3 heap
TestPositiveXPoint:									; x was positive result
;	ld			bc,(varR16)							; calculated X positision
    ld          l,ScreenCenterX						; 
    ld          h,0
    add         hl,bc								; hl = Screen Centre + X
    jp          TestStoreXPoint
TestNegativeXPoint:                                 ; x < 0 so need to subtract from the screen centre position
;	ld			bc,(varR16
    ld          l,ScreenCenterX                     
    ld          h,0
;	ld			c,a
;    ld          b,0
    ClearCarryFlag
    sbc         hl,bc                               ; hl = Screen Centre - X
TestStoreXPoint:                                    ; also from LL62, XX3 node heap has xscreen node so far.
    ex          de,hl
    ld          (iy+0),e                            ; Update X Point TODO this bit is 16 bit aware just need to fix above bit
    ld          (iy+1),d                            ; Update X Point
TestProcessYPoint:
	ld			bc,(UBnkZScaled)					; Now process Y co-ordinate
	ld			a,c
	ld			(varQ),a
;    ldCopyByte  varT,varQ                          ; T =>  Q	\ zdist lo
    ld          a,(UBnkYScaled)                     ; XX15	\ rolled x lo
	call		DIV16Amul256dCUNDOC	                ; a = Y scaled * 256 / zscaled
;	ld			a,c
	;ld			(varR),a
    ld          a,(UBnkYScaledSign)                 ; XX15+2 \ sign of X dist
    JumpOnBitSet a,7,TestNegativeYPoint             ; LL62 up, -ve Xdist, RU screen onto XX3 heap top of screen is Y = 0
TestPositiveYPoint:									; Y is positive so above the centre line
;	ld			a,(varR)							; in fact this code is already 16 bit aware 
    ld          l,ScreenCenterY
;	ld			c,a									; TODO DEBUG just added for testing to force 8 bit
;	ld			b,0
    ClearCarryFlag
    sbc         hl,bc  							 	; hl = ScreenCentreY - Y coord (as screen is 0 at top)
    jp          TestStoreYPoint
TestNegativeYPoint:									; this bit is only 8 bit aware TODO FIX
;	ld			a,(varR)
    ld          l,ScreenCenterY						
    ld          h,0
    add         hl,bc								; hl = ScreenCenterY + Y as negative is below the center of screen
TestStoreYPoint:                                    ; also from LL62, XX3 node heap has xscreen node so far.
    ex          de,hl
    ld          (iy+2),e                            ; Update Y Point
    ld          (iy+3),d                            ; Update Y Point
    ret



; copy from wiring addhlde un iniv ship data
XX12ProcessCalcHLPlusDESignBC:							
; Combinations validated in ClacHLDEsignedBE.asm
; calcs HLB + DEC where B and C are signs
		ld		a,b										; get HL sign byte
		bit		7,a										; is high bit set?
		jr		nz,XX12AddHLNegative					; if it is then the HL is negative
XX12AddHLPositive:										; At here HL is positive
		ld		a,c										; so we check DE as well
		bit		7,a
		jr		nz,XX12HLPosDENeg						; here if HL is negative jump
XX12HLPosDEPos:											; so here we have +HL + +DE
		add		hl,de									; which is HL+DE
		xor		a										; and will always return a + sign
		ret
XX12HLPosDENeg:											; here we have +HL + -DE
		ClearCarryFlag									;
		sbc		hl,de									; so we do HL - DE
		bit		7,h										
		jp		nz,XX12Pt1FixNegResult					; if the result was negative we need a correction
		xor		a										; else sign is +ve
		ret
XX12AddHLNegative:										; here we enter with -HL
		ld		a,c
		bit		7,a
		jr		nz,XX12HLNegDENeg						; and now do we have DE as negative
XX12HLNegDEPos:											; here we have -HL + +DE
		ex		de,hl									; so to simplify concept swap DE and HL
		ClearCarryFlag									; to make the calc
		sbc		hl,de									; DE - HL
		bit		7,h										; was the result negative
		jp		nz,XX12Pt1FixNegResult					; if so deal with it
		xor 	a										; else it is positive
		ret
XX12HLNegDENeg:											; now we have -HL + -DE
		add		hl,de									; which we can translate to (HL + DE) * -1
		ld		a,$80									; this sets the sign i.e. * -1
		ret
XX12Pt1FixNegResult:	 								; the result of HLcalcDE was negative
		NegHL											; so we 2's compliment it back to an absolute value
		ld		a,$80									; and set the sign to a negative
		ret

                        include "./Maths/Utilities/XX12EquNodeDotOrientation.asm"

TransposeXX12ByShipToXX15:
        ld		hl,(UBnkXX12xLo)					; get X into HL
		ld		a,h			                        ; get XX12 Sign						
		and		$80									; check sign bit on high byte
		ld		b,a									; and put it in of 12xlo in b
        ;110921 debugld      h,0
        ld      a,h
        and     $7F
        ld      h,a
        ;110921 debugld      h,0
		ld		de,(UBnKxlo)						;
		ld		a,(UBnKxsgn)						; get Ship Pos (low,high,sign)
		and		$80									; make sure we only have bit 7
		ld		c,a									; and put sign of unkxsgn c
		call 	ADDHLDESignBC; XX12ProcessCalcHLPlusDESignBC		; this will result in HL = result and A = sign
		or		h									; combine sign in A with H to give 15 bit signed (*NOT* 2's c)
		ld		h,a
		ld		(UBnkXScaled),hl					; now write it out to XX15 X pos
; ..................................
		ld		hl,(UBnkXX12yLo)					; Repeat above for Y coordinate
		ld		a,h
		and		$80
		ld		b,a
        ;110921 debugld      h,0
        ld      a,h
        and     $7F
        ld      h,a
        ;110921 debugld      h,0
		ld		de,(UBnKylo)
		ld		a,(UBnKysgn)
		and		$80									; make sure we only have bit 7
		ld		c,a
		call 	ADDHLDESignBC; XX12ProcessCalcHLPlusDESignBC
		or		h									; combine sign in A with H
		ld		h,a
		ld		(UBnkYScaled),hl
; ..................................
		ld		hl,(UBnkXX12zLo)					; and now repeat for Z cooord
		ld		a,h
		and		$80
		ld		b,a
        ;110921 debugld      h,0
        ld      a,h
        and     $7F
        ld      h,a
        ;110921 debugld      h,0
		ld		de,(UBnKzlo)
		ld		a,(UBnKzsgn)
		and		$80									; make sure we only have bit 7
		ld		c,a
		call 	ADDHLDESignBC; XX12ProcessCalcHLPlusDESignBC
		or		h									; combine sign in A with H
		ld		h,a
		bit		7,h                                 ; if sign if positive then we don't need to do the clamp so we ony jump 
		jr		nz,ClampZto4                        ; result was negative so we need to clamp to 4
        and     $7F                                 ; a = value unsigned
        jr      nz,NoClampZto4                      ; if high byte was 0 then we could need to clamp still by this stage its +v but and will set z flag if high byte is zero
        ld      a,l                                 ; get low byte now
		JumpIfALTNusng 4,ClampZto4					; if its < 4 then fix at 4
NoClampZto4:
		ld		(UBnkZScaled),hl					; hl = signed calculation and > 4
		ld		a,l									; in addition write out the z cooord to UT for now for backwards compat (DEBUG TODO remove later)
        ld      (varT),a
		ld		a,h
        ld      (varU),a
		ret
ClampZto4:											; This is where we limit 4 to a minimum of 4
		ld		hl,4
		ld		(UBnkZScaled),hl; BODGE FOR NOW
		ld		a,l
        ld      (varT),a                            ;                                                                           ;;;
		ld		a,h
        ld      (varU),a 						; compatibility for now
		ret


RescaleXXValue:
		ld		e,(hl)
		inc		hl
		ld		d,(hl)
		ld		a,d
		and		$80
		ld		b,a
		ld		a,d
		and		$7F
		ld		c,a
		ld		a,e
		bit		7,a
		jp		z,XX15XLT128
XX15XGT128:
		inc		c
XX15XLT128:
		ld		e,c
		ld		d,b
		ld		(hl),d
		dec		hl
		ld		(hl),e
		inc		hl
		inc		hl
		ret		


NegZeroBodge:
    ld     hl,UBnkrotmatNosevX
    ld     b,9
NegBodgeLoop:    
    ld      a,(hl)
    inc     hl
    cp      0
    jr      nz,NegBodgeSkip1
    ld      a,(hl)
    cp      $80
    jr      nz,NegBodgeSkip1
    xor     a
    ld      (hl),a
NegBodgeSkip1:
    inc     hl
    djnz    NegBodgeLoop
    ret
    
RollLoop: DB $B0
    
TestRender:
	;include "Tests/PlotTest2.asm"
; Initialise banks is include in main initialise subrotines now
; Prototype for .TITLE
TestLines:
;include "Tests/LineHLtoDETest.asm"
TestCalcs:

;include "Tests/CalcHLDEsignedBE.asm"


	ld	a,90
	ld	c,a
	ld	d,108
	call AequAdivDmul96

	ld	a,90
	ld	b,108
	ld	hl,$2400
	ld	(varR),hl
	call	TidySub1
	
	;.TIS1	\ -> &293B  \ Tidy subroutine 1  X.A =  (-X*A  + (R.S))/96

TestTIDY:
	ld	hl,$0000
	ld	(UBnkrotmatNosevX),hl
	ld	hl,$8D00
	ld	(UBnkrotmatNosevY),hl
	ld	hl,$E000
	ld	(UBnkrotmatNosevZ),hl

	ld	hl,$0000
	ld	(UBnkrotmatRoofvX),hl
	ld	hl,$B400
	ld	(UBnkrotmatRoofvY),hl
	ld	hl,$CF00
	ld	(UBnkrotmatRoofvZ),hl

	ld	hl,$2800	
	ld	(UBnkrotmatSidevX),hl
	ld	hl,$0000
	ld	(UBnkrotmatSidevY),hl
	ld	hl,$0000
	ld	(UBnkrotmatSidevZ),hl
	call	TestPitchPos
;	call	TestRollPos
;	call	TIDY


	ld	hl,$0
	ld	(UBnkrotmatNosevX),hl
	ld	hl,$63CE
	ld	(UBnkrotmatNosevY),hl
	ld	hl,$1DC6
	ld	(UBnkrotmatNosevZ),hl

	ld	hl,$0
	ld	(UBnkrotmatRoofvX),hl
	ld	hl,$647D
	ld	(UBnkrotmatRoofvY),hl
	ld	hl,$239B
	ld	(UBnkrotmatRoofvZ),hl

	ld	hl,$6000
	ld	(UBnkrotmatSidevX),hl
	ld	hl,$0
	ld	(UBnkrotmatSidevY),hl
	ld	hl,$0
	ld	(UBnkrotmatSidevZ),hl
	call	TIDY


TestRollLoop:
    ld      a,(RollLoop)
    dec     a
    JumpIfALTNusng $40 , ItsRoll
    ld      (RollLoop),a
  	call	TestPitchPos
    jp     SkipTidyUp
ItsRoll;    
    cp      0
    jr      nz,DontReset
    ld      a,$60    
    ld      (RollLoop),a
    call    TestRollPos
    jp      SkipTidyUp
DontReset
    ld      (RollLoop),a
    call    TestRollPos
    ret

SkipTidyUp:

    

DebugPoint: DW 0    
    
SubColor1:
	ld		a,h
	sub		$1F
	ld		h,a
	ret
SubColor2:
	ld		a,h
	sub		$2F
	ld		h,a
	ret
    
    ; V1 /512 => Part 1 = V1 - (1 /512) ; Oart 2 = V2 / 16 Answer = p1 + p2
    
SetupShip:
    ld  b,a
    bit  0,a
    jr   z,ShipRoot
    cp  5
    jr  z,ShipUp
    cp  3
    jr  z,ShipSide:
    jr  ShipNose
    ret
    
ShipRoot:
    ld hl,0
    ld (UBnkXScaled),hl
    ld (UBnkYScaled),hl
    ld (UBnkZScaled),hl
    ret

ShipUp: 
    ld hl,0
    ld (UBnkXScaled),hl
    ld hl,20
    ld (UBnkYScaled),hl
    ld hl,0
    ld (UBnkZScaled),hl
    ret

ShipSide:
    ld hl,20
    ld (UBnkXScaled),hl
    ld hl,0
    ld (UBnkYScaled),hl
    ld (UBnkZScaled),hl
    ret

ShipNose:
    ld hl,0
    ld (UBnkXScaled),hl
    ld (UBnkYScaled),hl
    ld hl,20
    ld (UBnkZScaled),hl
    ret   
		  		  
TestRollPos:
	ld	hl,UBnkrotmatSidevX	
	ld	(varAxis1),hl
	ld	hl,UBnkrotmatSidevY
	ld	(varAxis2),hl
	xor	a
	ld	(varRAT2),a
	call MVS5XRotateXAxis
	ld	hl,UBnkrotmatRoofvX	
	ld	(varAxis1),hl
	ld	hl,UBnkrotmatRoofvY	
	ld	(varAxis2),hl
	xor	a
	ld	(varRAT2),a
	call MVS5XRotateXAxis
	ld	hl,UBnkrotmatNosevX	
	ld	(varAxis1),hl
	ld	hl,UBnkrotmatNosevY	
	ld	(varAxis2),hl
	xor	a
	ld	(varRAT2),a
	call MVS5XRotateXAxis
	ret

;   Axis1 = Axis1 * (1 - 1/512)  + Axis2 / 16
;   Axis2 = Axis2 * (1 - 1/512)  - Axis1 / 16

TestPitchPos:
    ld	hl,UBnkrotmatSidevY
    ld	(varAxis1),hl
    ld	hl,UBnkrotmatSidevZ	
    ld	(varAxis2),hl
    xor	a
    ld	(varRAT2),a
    call MVS5XRotateXAxis
; Do Y
	ld	hl,UBnkrotmatRoofvY	
	ld	(varAxis1),hl
	ld	hl,UBnkrotmatRoofvZ	
	ld	(varAxis2),hl
	xor	a
	ld	(varRAT2),a
	call MVS5XRotateXAxis
; Do Z
	ld	hl,UBnkrotmatNosevY	
	ld	(varAxis1),hl
	ld	hl,UBnkrotmatNosevZ	
	ld	(varAxis2),hl
	xor	a
	ld	(varRAT2),a
	call MVS5XRotateXAxis
	ret
				  
				  
TestReplot:
    ld      a,(VertexCtX6Addr)                  ; get Hull byte#8 = number of vertices *6                                   ;;;
    ld      c,a									; XX20 also c = number of vertices * 6 (or XX20)
    ld      d,6
    call    asm_div8                            ; asm_div8 C_Div_D - C is the numerator, D is the denominator, A is the remainder, B is 0, C is the result of C/D,D,E,H,L are not changed"
    ld      b,c									; c = number of vertices
	ld		iy,UBnkNodeArray
RePointLoop:	
	push	bc
	push	iy
	ld		a,(iy+0)
	ld		c,a
	ld		a,(iy+2)
	ld		b,a
	ld 		h,$DF 
	ld		a,(iy+1)
	ld		d,a
	ld		a,(iy+3)
	ld		e,a
	or		d
	jr		z,RePlotAsIs
	ld 		a,d
	cp		0
	call	nz,SubColor1
	ld 		a,d
	cp		0
	call	nz,SubColor1
RePlotAsIs:	
	ld		a,h
	MMUSelectLayer2
	call    l2_plot_pixel 
	pop		hl
	ld		a,4
	add		hl,a
	push	hl
	pop		iy								; this is very expensive need to optimise TODO
	pop		bc
	djnz	RePointLoop
	ret
    
    ;ProcessFaceNormDebug:
;    push    hl
;    push    bc
;    push    de
;    push    ix
;    push    iy
;    ld      hl,UBnkHullNormals
;    call    CopyFaceToXX12
;    call    CopyXX15ToXX15Save
;    call    CopyXX12ToXX15
;    call    RotateXX15ByTransMatXX16
;    call    CopyXX15ToXX12
;    call    CopyXX15SaveToXX15
;    call    DotproductXX12XX15
;    ld      a,(varS)
;    JumpOnBitClear a,7,ItsGreen
;
;    ld      a,193
;    jp      DoPlotNorm
;ItsGreen:
;	ld		a,28  
;DoPlotNorm:
;    pop     iy
;    pop     ix
;    pop     de
;    pop     bc
;    pop     hl
;    ret
;
;ProcessNormalLine:
;    push    hl
;    push    bc
;    push    de
;    push    ix
;    push    iy
;;    call    CopyXX15ToXX15Save                                      ; save current XX15
;    ld      hl,UBnkHullNormals
;    call    CopyFaceToXX15                                          ;        Get Face data into XX12
;  ;  call    CopyXX12ToXX15
;  ; ld      a,(QAddr)
;  ;  xor       a
;  ;  ld      (XX17),a
;  ;  call    ScaleNormal
;	ld		a,(UBnkXScaledSign)    
;	call    XX12EquNodeDotOrientation
;    ld      a,(UBnkXX12zSign)
;    ld      (VarBackface),a
;    call    CopyXX12ToXX12Save
;	call    TransposeXX12ByShipToXX15
;    call    ScaleNodeTo8Bit
;    call    CopyXX15ToXX12
;    call    CopyXX12ToXX12Save2
;    call    CopyXX15SaveToXX15 ; Copy from previous
;    call    CopyXX12SaveToXX12
;    ld      a,1
;    ld      (XX17),a
;    call    ScaleNormal     
;   ; call    DotproductXX12XX15
;    ld      a,(VarBackface)
;    JumpOnBitClear a,7,PlotRed
;    JumpIfALTNUsng 51,PlotRed
;PlotGreen:    
;    ld      a,$7C
;    jp      ReadyToDrawLine
;PlotRed:
;    ld      a,$E0
;ReadyToDrawLine:  
;    ld      (line_gfx_colour),a
;    call    CopyXX12Save2ToXX12
;    call    CopyXX12ToXX15   
;    ld		iy,UBnkNodeArray2
;    call    TestProjectNodeToScreen
;    ld		a,(iy+0)
;	ld		e,a
;	ld		a,(iy+2)
;	ld		d,a
;    ld      hl,(DebugPoint)
;	MMUSelectLayer2
;
;	call    LineHLtoDE
;    
;Skipit:
;    pop     iy
;
;    pop     ix
;    pop     de
;    pop     bc
;    pop     hl
;    ret
