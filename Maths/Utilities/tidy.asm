;rotmap0xLo: DB	0				; INWK +9
;rotmap0xHi: DB	0				; INWK +10
;rotmat0yLo: DB	0				; INWK +11
;rotmat0yHi: DB	0				; INWK +12			
;rotmat0zLo:	DB 	0				; INWK +13
;rotmat0zHi:	DB 	0				; INWK +14
;rotmap1xLo: DB	0				; INWK +15
;rotmap1xHi:	DB	0				; INWK +16
;rotmat1yLo:	DB	0				; INWK +17			
;rotmat1yHi:	DB	0				; INWK +18
;rotmat1zLo:	DB	0				; INWK +19
;rotmat1zHi:	DB	0				; INWK +20			
;rotmat2xLo: DB	0				; INWK +21
;rotmat2xHi:	DB	0				; INWK +22
;rotmat2yLo:	DB	0				; INWK +23			
;rotmat2yHi:	DB	0				; INWK +24
;rotmat2zLo:	DB	0				; INWK +25
;rotmat2zHi:	DB	0				; INWK +26
;
;rotmatFx	equ	rotmat0xHi
;rotmatFy	equ	rotmat0yHi
;rotmatFz	equ	rotmat0zHi
;rotmatUx	equ	rotmat1xHi
;rotmatUy	equ	rotmat1yHi
;rotmatUz	equ	rotmat1zHi
;
;inwkarray			equ		INWK+10

    include "./Universe/Ships/CopyRotMattoXX15.asm"
    
    include "./Universe/Ships/CopyXX15toRotMat.asm"

TidySub1:									;.TIS1	\ -> &293B  \ Tidy subroutine 1  X.A =  (-X*A  + (R.S))/96
		; b = regX on entry
TIS1Prep:									;.TIS1	\ -> &293B  \ Tidy subroutine 1 using B register = X
		ex		af,af'
		ld		a,b
		ld		(varQ),a
		ex		af,af'
		xor		$80							;	 flip sign of Acc
		call	madXAequQmulAaddRS			; \ MAD \ multiply and add (X,A) =  -X*A  + (R,S)
; USES 				A BC E
; DOES NOT USE		D HL
Tis1Div96:							   		; .DVID96	\ Their comment A=A/96: answer is A*255/96
		ld		c,a							; Store sign bit in  ct (we use e reg for that)
		and		SignOnly8Bit						; ..
		ld		e,a							; ..
		ld		a,c							; a = high byte again with sign bit cleared
		and		SignMask8Bit							; ..
		ld		b,$FE						; slide counter T1
TIS1RollTLoop								; roll T1  clamp Acc to #96 for rotation matrix unity
		sla		a
		JumpIfALTNusng $60, TIS1SkipSub
		sbc		a,$60							; subtract 96
		scf
		rl		b							;  T1
		jr		c,TIS1RollTLoop
TIS1KIPCont:		
		ld		a,b							;   T1
		or		e							;   restore T sign
		ret		
TIS1SkipSub:
	or			a
	rl			b							; T rolled left to push bit out the end
	jr			c,TIS1RollTLoop				; if we still have not hit the empty marker continue
	jp			TIS1KIPCont
	
;.TIDY	\ -> &4679 \ Orthogonalize rotation matrix that uses 0x60 as unity returns INWK(16,18,20) = INWK(12*18+14*20, 10*16+14*20, 10*16+12*18) / INWK(10,12,14)
; Ux,Uy,Uz = -(FyUy+FzUz, FxUx+FzUz, FxUx+FyUy)/ Fx,Fy,Fz




TidyRotYSmall:
		call	CalcRoofvZ
		ld		(UBnkrotmatRoofvZ+1),a			; set roofvy hi?? Says roofz TODO
		jp		NormaliseRoofV
		
TidyRotXSmall:
		xor		a
		ld		b,a
		ld		a,(UBnkrotmatNosevY+1)			; nosev_y
		and		%01100000
		jp		z,TidyRotYSmall
		ld		a,(UBnkrotmatNosevZ+1)			; nosev z
		ld		b,a							; b = regX for now
		ld		a,(UBnkrotmatRoofvY+1)			; roofv y
		call	CalcRoofvY					; Set (roofvy= (nosev_x * roofv_x + nosev_z * roofv_z) / nosev_y, Q -= nosev_z
		ld		(UBnkrotmatRoofvY+1),a			; set roofvy hi
		jp		NormaliseRoofV
; TIDY is broken
TIDY:
        break
ORTHOGALISE:
;-- NormaliseNosev
		call	CopyRotMatNoseVtoXX15		
		call	normaliseXX1596fast			; normalise z hi, its really TIS3
		call	CopyXX15toRotMatNoseV
.CheckNXSmall:
		ld		a,(UBnkrotmatNosevX+1)
		and		%01100000					; check top two magnitude bits
		jp		z,TidyRotXSmall
.RotXIsBig:
        call	CalcRoofvX
		ld		(UBnkrotmatRoofvX+1),a    	; set roofvx hi
NormaliseRoofV:		
		call	CopyRotMatRoofVtoXX15		; xx15 = roofv
		call	normaliseXX1596fast			; normalise roof
;calc sidev x
		call	CopyXX15toRotMatRoofV		; get back normalised version
		ld		a,(UBnkrotmatNosevX+1)
		ld		(varQ),a					; q = nosev_y
		ld		a,(UBnkrotmatRoofvZ+1)	     ;roov z
		call	RSequQmulA
		ld		a,(UBnkrotmatNosevZ+1)		; nosev z
		ld		b,a							; b = regX for now
		ld		a,(UBnkrotmatRoofvY+1)	    ; roofv y
		call	TidySub1					; Set (A ?)= (-nosev_z * roofv_y + nosev_y * roofv_z) / 96, Q -= nosev_z
        IfAIsZeroGoto NormSideXNoNeg
		xor		$80							; flip a to get -sidev_x
NormSideXNoNeg:        
		ld		(UBnkrotmatSidevX+1),a
;calc sidev y
		ld		a,(UBnkrotmatNosevZ+1)			; nosev z
		ld		(varQ),a
		ld		a,(UBnkrotmatRoofvX+1)			; roofv x
		call	RSequQmulA
		ld		a,(UBnkrotmatNosevX+1)			        ; nosev x
		ld		b,a							; b = regX for now
		ld		a,(UBnkrotmatRoofvZ+1)			; roofv z
		call	TidySub1					; Set (A ?)= (-nosev_z * roofv_y + nosev_y * roofv_z) / 96, Q -= nosev_z
        IfAIsZeroGoto NormSideYNoNeg
		xor		$80							; flip a to get -sidev_y
NormSideYNoNeg:        
		ld		(UBnkrotmatNosevY+1),a
;calc sidev z
		ld		a,(UBnkrotmatNosevX+1)			; nosev x
		ld		(varQ),a
		ld		a,(UBnkrotmatRoofvY+1)			; roofv y
		call	RSequQmulA
		ld		a,(UBnkrotmatNosevY+1)			; nosev y
		ld		b,a							; b = regX for now
		ld		a,(UBnkrotmatRoofvX+1)			; roofv x
		call	TidySub1					; Set (A ?)= (-nosev_z * roofv_y + nosev_y * roofv_z) / 96, Q -= nosev_z
        IfAIsZeroGoto NormSideZNoNeg
		xor		$80							; flip a to get -sidev_y
NormSideZNoNeg:
		ld		(UBnkrotmatSidevY+1),a ;TODO SHoudl this be Y??
.ClearLoBytes:		
		ld		hl,UBnkrotmatNosevX
		ld		b,9
        xor     a
.ClearLoLoop:		
		ld		(hl),a						; zero out lo bytes
		inc		hl
		inc		hl
		djnz	.ClearLoLoop  
		call	CopyRotMatSideVtoXX15		; xx15 = roofv
		call	normaliseXX1596fast			; normalise roof
;calc sidev x
		call	CopyXX15toRotMatSideV		; get back normalised version
        
		ret	
		
		
		
;;;;;;;;.CheckNYSmall:
;;;;;;;;		ld		a,(XX15+2)					; first check z zero, if so we have to do Y
;;;;;;;;		and		$7F
;;;;;;;;		cp		0
;;;;;;;;		jp		z,Tidy1RZ
;;;;;;;;		ld		a,(XX15+1)					; now we can do a realistic check of RY
;;;;;;;;		cp 		0							; we can't end up with divide by 0 for RY
;;;;;;;;		jp		z,Tidy1RZ					; We can't have all values of vector 0 so we must do RZ
;;;;;;;;		and		%01100000					; check top two magnitude bits
;;;;;;;;		jp		z,Tidy1RY					; and tidy based on roofy
;;;;;;;;.DoNZ:
;;;;;;;;		jp		Tidy1RZ						; else we tidy based on roofz
;;;;;;;;;---RE ENTRY POINT -------------------------------------		
;;;;;;;;NormaliseRoofv:
;;;;;;;;		call	CopyRotMatRoofVtoXX15		; xx15 = roofv
;;;;;;;;		push	bc
;;;;;;;;		call	normaliseXX1596fast			; normalise 
;;;;;;;;		pop		bc
;;;;;;;;		call	CopyXX15toRotMatRoofV		; get back normalised version
;;;;;;;;ProcessSidev:
;;;;;;;;; -- SIDEV X
;;;;;;;;		ldCopyByte	nosev_z+1, varQ         ; use ixh as Q later
;;;;;;;;		ld		a,(UBnkrotmatRoofvY+1)				; a = roofv_hi
;;;;;;;;		push	bc
;;;;;;;;		call	RSequQmulA					; RS = Q * A MULT12
;;;;;;;;		pop		bc
;;;;;;;;		ld		a,(UBnkrotmatNosevY+1)
;;;;;;;;		ld		b,a							; set x (b) to value of nosev_z
;;;;;;;;		ld		a,(UBnkrotmatRoofvZ+1)				; a = roofv_y hi
;;;;;;;;		push	bc
;;;;;;;;		call	TidySub1					; set A (-nosev_z * roofv_y + nosev_y * roofv_z) / 96, This also sets Q = nosev_z TIS1
;;;;;;;;		pop		bc
;;;;;;;;		ld		(UBnkrotmatSidevX+1),a				; sidev_x = = (nosev_z * roofv_y - nosev_y * roofv_z) / 96
;;;;;;;;; -- SIDEV Y
;;;;;;;;		ldCopyByte	UBnkrotmatNosevX+1, varQ         ; use ixh as Q later		
;;;;;;;;		ld		a,(UBnkrotmatRoofvZ+1)				;
;;;;;;;;		push	bc
;;;;;;;;		call	RSequQmulA					; RS = Q * A MULT12 MULT12
;;;;;;;;		pop		bc
;;;;;;;;		ld		a,(UBnkrotmatNosevZ+1)
;;;;;;;;		ld		b,a
;;;;;;;;		ld		a,(UBnkrotmatRoofvX+1)
;;;;;;;;		push	bc
;;;;;;;;		call	TidySub1						; set A (-nosev_z * roofv_y + nosev_y * roofv_z) / 96, This also sets Q = nosev_z
;;;;;;;;		pop		bc
;;;;;;;;		ld		(sidev_y+1),a				; sidev_y  = (nosev_x * roofv_z - nosev_z * roofv_x) / 96
;;;;;;;;		ld		a,(UBnkrotmatRoofvY+1)
;;;;;;;;		push	bc
;;;;;;;;; -- SIDEV Z
;;;;;;;;		ldCopyByte	UBnkrotmatNosevY+1, varQ         ; use ixh as Q later		
;;;;;;;;		ld		a,(UBnkrotmatRoofvX+1)				;
;;;;;;;;		call	RSequQmulA					; RS = Q * A MULT12
;;;;;;;;		pop		bc
;;;;;;;;		ld		a,(UBnkrotmatNosevX+1)
;;;;;;;;		ld		b,a
;;;;;;;;		ld		a,(UBnkrotmatRoofvY+1)
;;;;;;;;		push	bc
;;;;;;;;		call	TidySub1						; set A (-nosev_z * roofv_y + nosev_y * roofv_z) / 96, This also sets Q = nosev_z
;;;;;;;;		pop		bc
;;;;;;;;		ld		(sidev_z+1),a
;;;;;;;;		xor		a							; set a = 0 so we can clear orientation low bytes
;;;;;;;;		ld		hl,sidev_z
;;;;;;;;		ld		b,9							; only on 6 cells (3 x row 0 and row 1)
;;;;;;;;		ld		hl,UBnkrotmatNosevX
;;;;;;;;NormaliseSideV:
;;;;;;;;		call	CopyRotMatSideVtoXX15		; xx15 = roofv
;;;;;;;;		push	bc
;;;;;;;;		call	normaliseXX1596fast			; normalise 
;;;;;;;;		pop		bc
;;;;;;;;		call	CopyXX15toRotMatSideV		; get back normalised version
;;;;;;;;		


CalcRoofvX:
Tidy1RX:										; roofv_x´ = -(nosev_y´ * roofv_y + nosev_z´ * roofv_z) / nosev_x´
		ldCopyByte UBnkrotmatNosevZ+1,varQ
		ld		a,(UBnkrotmatRoofvZ+1)
		call	RSequQmulA						; rs = nosez hi * roofz hi
		ldCopyByte UBnkrotmatNosevY+1,varQ
		ld		a,(UBnkrotmatRoofvY+1)
		call	madXAequQmulAaddRS				; DE = nosey hi * roofy hi + rs
		ld		a,d
		and 	$80
		ld		iyh,a
;DEBUG		ld		c,a
		ld		a,(UBnkrotmatNosevX+1)					; get nosev x sign		
		ld		c,a								; temp save
		and		$80
		xor		iyh								; flip from saved multiply sign result
		ld		iyh,a							; save nosesev sign to iyh
		ld		a,c								; recover a
		and		$7F								; a is unsigned nosev x
		ld		b,d
		ld		c,e								; bc = nosev_y´ * roofv_y + nosev_z´ * roofv_z
		ld		d,a								; de = nosev x hi
		ld		e,0
		call	BC_Div_DE
		ld		a,iyh							; get back sign from nosevx
		xor		$80								; flip sign
		and		$80								; keep sign bit only
		or		b					
		ret

		
CalcRoofvY:
Tidy1RY:										; roofv_y´ = -(nosev_x´ * roofv_x + nosev_z´ * roofv_z) / nosev_y´
		ldCopyByte UBnkrotmatNosevZ+1,varQ				;                  A        Q              RS
		ld		a,(UBnkrotmatRoofvZ+1)
		call	RSequQmulA
		ldCopyByte UBnkrotmatNosevX+1,varQ
		ld		a,(UBnkrotmatRoofvX+1)
		call	madXAequQmulAaddRS
		ld		a,d
		and 	$80
		ld		iyh,a
		ld		a,(UBnkrotmatNosevY+1)					; get nosev x sign		
		ld		c,a								; temp save
		and		$80
		xor		iyh								; flip from saved multiply sign result
		ld		iyh,a							; save nosesev sign to iyh
		ld		a,c								; recover a
		and		$7F								; a is unsigned nosev x
		ld		b,d
		ld		c,e								; bc = nosev_y´ * roofv_y + nosev_z´ * roofv_z
		ld		d,a								; de = nosev x hi
		ld		e,0
		call	BC_Div_DE
		ld		a,iyh
		xor		$80
		and		$80
		or		b
		ret
		
CalcRoofvZ:
Tidy1RZ:										; roofv_z´ = -(nosev_x´ * roofv_x + nosev_y´ * roofv_y) / nosev_z´
		ldCopyByte UBnkrotmatNosevY+1,varQ			
		ld		a,(UBnkrotmatRoofvY+1)
		call	RSequQmulA						; rs = NOSEy * ROOFy
		ldCopyByte UBnkrotmatNosevX+1,varQ
		ld		a,(UBnkrotmatRoofvX+1)					
		call	madXAequQmulAaddRS				; de (A,ixl) = NOSEx * ROOFx + RS
		ld		a,d
		and 	$80
		ld		iyh,a
		ld		a,(UBnkrotmatNosevZ+1)					; get nosev x sign		
		ld		c,a								; temp save
		and		$80
		xor		iyh								; flip from saved multiply sign result
		ld		iyh,a							; save nosesev sign to iyh
		ld		a,c								; recover a
		and		$7F								; a is unsigned nosev x
		ld		b,d
		ld		c,e								; bc = nosev_y´ * roofv_y + nosev_z´ * roofv_z
		ld		d,a								; de = nosev x hi
		ld		e,0
		call	BC_Div_DE
		ld		a,iyh
		xor		$80
		and		$80
		or		b
		ret
		


;;ProcessSidev:
;;		ldCopyByte	UBnkrotmatNosevZ+1, varQ         ; use ixh as Q later
;;		ld		a,(UBnkrotmatRoofvY+1)				; a = roofv_hi
;;		push	bc
;;		call	RSequQmulA					; RS = Q * A MULT12
;;		pop		bc
;;		ld		a,(UBnkrotmatNosevY+1)
;;		ld		b,a							; set x (b) to value of nosev_z
;;		ld		a,(UBnkrotmatRoofvZ+1)				; a = roofv_y hi
;;		push	bc
;;		call	TidySub1					; set A (-nosev_z * roofv_y + nosev_y * roofv_z) / 96, This also sets Q = nosev_z TIS1
;;		pop		bc
;;		xor		$80							; sidev_x = -a by flipping sign bit
;;		ld		(UBnkrotmatSidevX+1),a				; sidev_x = = (nosev_z * roofv_y - nosev_y * roofv_z) / 96
;;		ldCopyByte	UBnkrotmatNosevX+1, varQ         ; use ixh as Q later		
;;		ld		a,(UBnkrotmatRoofvZ+1)				;
;;		push	bc
;;		call	RSequQmulA					; RS = Q * A MULT12 MULT12
;;		pop		bc
;;		ld		a,(UBnkrotmatNosevZ+1)
;;		ld		b,a
;;		ld		a,(UBnkrotmatNosevY+1)
;;		push	bc
;;		call	TidySub1						; set A (-nosev_z * roofv_y + nosev_y * roofv_z) / 96, This also sets Q = nosev_z
;;		pop		bc
;;		xor		$80							; a *= -1
;;		ld		(UBnkrotmatSidevY+1),a				; sidev_y  = (nosev_x * roofv_z - nosev_z * roofv_x) / 96
;;		ld		a,(UBnkrotmatRoofvY+1)
;;		push	bc
;;		ldCopyByte	UBnkrotmatNosevY+1, varQ         ; use ixh as Q later		
;;		ld		a,(UBnkrotmatRoofvX+1)				;
;;		call	RSequQmulA					; RS = Q * A MULT12
;;		pop		bc
;;		ld		a,(UBnkrotmatNosevX+1)
;;		ld		b,a
;;		ld		a,(UBnkrotmatRoofvY+1)
;;		push	bc
;;		call	TidySub1						; set A (-nosev_z * roofv_y + nosev_y * roofv_z) / 96, This also sets Q = nosev_z
;;		pop		bc
;;		xor		$80
;;		ld		(UBnkrotmatSidevZ+1),a
;;		xor		a							; set a = 0 so we can clear orientation low bytes
;;		ld		hl,UBnkrotmatSidevZ
;;		ld		b,9							; only on 6 cells (3 x row 0 and row 1)
;;		ld		hl,UBnkrotmatNosevX





		
;;;;;;;;;-- Check to see if the top two magnitude bits are clear in nosev_x, if so jump to TI1
;;;;;;;;.ProcessRoofv:
;;;;;;;;		call	CopyRotMatRoofVtoXX15		; xx15 = roofv
;;;;;;;;		push	bc
;;;;;;;;		call	normaliseXX1596fast			; normalise roof
;;;;;;;;		pop		bc
;;;;;;;;		call	CopyXX15toRotMatRoofV		; get back normalised version
;;;;;;;;.ProcessSidev:
;;;;;;;;		call	CopyRotMatSideVtoXX15		; xx15 = roofv
;;;;;;;;		push	bc
;;;;;;;;		call	normaliseXX1596fast			; normalise roof
;;;;;;;;		pop		bc
;;;;;;;;		call	CopyXX15toRotMatSideV		; get back normalised version
