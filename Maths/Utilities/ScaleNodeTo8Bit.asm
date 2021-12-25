ScaleNodeTo8Bit:								; TODO make signed
	ld			bc,(UBnkZScaled)
	ld			hl,(UBnkXScaled)
	ld			de,(UBnkYScaled)		
SetABSbc:
	ld			a,b
	ld			ixh,a
	and			SignMask8Bit
	ld			b,a									; bc = ABS bc
SetABShl:
	ld			a,h
	ld			ixl,a
	and			SignMask8Bit
	ld			h,a									; hl = ABS hl
SetABSde:
	ld			a,d
	ld			iyh,a
	and			SignMask8Bit
	ld			d,a									; de = ABS de
ScaleNodeTo8BitLoop:
    ld          a,b		                            ; U	\ z hi
	or			h                                   ; XX15+1	\ x hi
	or			d                                   ; XX15+4	\ y hi
    jr          z,ScaleNodeDone                   ; if X, Y, Z = 0  exit loop down once hi U rolled to 0
    ShiftHLRight1
    ShiftDERight1
	ShiftBCRight1
    jp          ScaleNodeTo8BitLoop
ScaleNodeDone:										; now we have scaled values we have to deal with sign
	ld			a,ixh								; get sign bit and or with b
	and			SignOnly8Bit
	or			b
	ld			b,a
SignforHL:
	ld			a,ixl								; get sign bit and or with b
	and			SignOnly8Bit
	or			h
	ld			h,a
SignforDE:
	ld			a,iyh								; get sign bit and or with b
	and			SignOnly8Bit
	or			d
	ld			d,a
SignsDoneSaveResult:	
	ld			(UBnkZScaled),bc
	ld			(UBnkXScaled),hl
	ld			(UBnkYScaled),de
	ld			a,b
	ld			(varU),a
	ld			a,c
	ld			(varT),a
	ret
