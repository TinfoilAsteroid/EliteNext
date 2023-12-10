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

    IFDEF USE_NORMALISE_IX

; d = vector 1 e = vector 2 h = vector3 l = vector 4 b = vector 5
; performs (d*e + h*l) / b and puts the result in de where e is 0
TidyCalc:       push    bc
                call    mulDbyESigned           ; de = vector 1 * vector 2
                ex      hl,de                   ; get hl into de and save result of de
                call    mulDbyESigned           ; de = vector 2 * vector 3
                call    AddDEtoHLSigned         ; BC = HL = HL + DE
                pop     de                      ; DE = BC saved from earlier
                ld      a,h                     ; check for result 0
                or      l                       ; .
                jp      z,.ZeroResult           ; .
                ld      bc,hl                   ; .
                ld      a,d                     ; check for divide by zero
                and     a                       ; .
                jp      z,.MaxedResult          ; .
                ld      e,d                     ; now de = 0b (i.e. b register not hex value)
                ld      d,0                     ;
                call    Floor_DivQSigned        ; TO BE TESTED should do BC = BC / DE
                ld      a,b                     ; sign bit from b
                and     $80                     ; .
                or      c                       ; bring in the value
                ld      d,a                     ; de = c0 (i.e. c register not hex value)
                ld      e,0                     ; .
                ret
.MaxedResult:   ld      a,b                     ; make result signed unity (i.e. 1 or 96 in our case)
                xor     $80
                or      $60
                ld      d,a
                ld      e,0
                ret
.ZeroResult:    ld      de,0
                ret
; as per tidy calc except
; d = vector 1 e = vector 2 h = vector3 l = vector 4
; performs (d*e - h*l) / 96 and puts the result in de where e is 0

TidySide:       call    mulDbyESigned           ; de = vector 1 * vector 2
                ex      de,hl                   ; get hl = vector 1 * vector 2
                call    mulDbyESigned           ; de = vector 2 * vector 3
                call    SubDEfromHLSigned       ; BC = HL = HL - DE
                ld      bc,hl                   ; .
                ld      de,$60                  ; now de = 96
                call    Floor_DivQSigned        ; TO BE TESTED should do BC = BC / DE
                ld      a,b                     ; sign bit from b
                and     $80                     ; .
                or      c                       ; bring in the value
                ld      d,a                     ; de = c0 (i.e. c register not hex value)
                ld      e,0                     ; .
                ret

;; orthonormalise vector for UBnK ship vector uses IX IT
TidyVectorsIX:  break
                ld      ix,UBnkrotmatNosevX
                call    NormaliseIXVector       ; initially we normalise the nose vector
.CheckNoseXSize:ld      a,(UBnkrotmatNosevX+1)  ; a = nose x
                and     %00110000                ; if bits 7 and 6 are clear the work with nosey
                jp      z, .NoseXSmall
;-- When nosex is large ------------------------  roofv_x =-(nosev_y * roofv_y + nosev_z * roofv_z) / nosev_x        
.NoseXLarge:    ld      a,(UBnkrotmatNosevY+1)  ; a = nose x
                ld      d,a
                ld      a,(UBnkrotmatRoofvY+1)  ; hl = nosev_y * roofv_y
                ld      e,a                     ; we already have d so only need roofY
                ld      a,(UBnkrotmatNosevZ+1)  ; de = nosev_z * roofv_z
                ld      h,a                     ; .
                ld      a,(UBnkrotmatRoofvZ+1)  ; .
                ld      l,a                     ; .
                ld      a,(UBnkrotmatNosevX+1)
                ld      b,a
                call    TidyCalc
                ld      a,d
                or      e
                jp      z,.NoRoofXFlip
                ld      a,$80                   ; flip sign bit if not zero
                xor     d
                ld      d,a
.NoRoofXFlip:   ld      (UBnkrotmatRoofvX),de   ; write roofvx
                jp      .NormaliseRoofv
.MaxedRoofX:    ld      de,$E000                ; TEST if sign is correct for all of these if was divide by zero make it -1
                ld      (UBnkrotmatRoofvX),de   ; write roofvx
                jp      .NormaliseRoofv
;-- When noseX is small ------------------------ determine if we are doign roofz or roof y
.NoseXSmall:    ld      a,(UBnkrotmatNosevY)
                and     %01100000
                jp      z,.NoseYSmall
;-- When noseY is large ------------------------ roofv_z = -(nosev_x * roofv_x + nosev_y * roofv_y) / nosev_z
.NoseYLarge:    ld      a,(UBnkrotmatNosevX+1)  
                ld      d,a
                ld      a,(UBnkrotmatRoofvX+1)  
                ld      e,a                     
                ld      a,(UBnkrotmatNosevY+1)  
                ld      h,a                     
                ld      a,(UBnkrotmatRoofvY+1)  
                ld      l,a                     
                ld      a,(UBnkrotmatNosevZ+1)
                ld      b,a
                call    TidyCalc
                ld      a,d
                or      e
                jp      z,.NoRoofZFlip
                ld      a,$80                   ; flip sign bit if not zero
                xor     d
                ld      d,a
                ld      a,$80                   ; flip sign bit
                xor     d
                ld      d,a
.NoRoofZFlip:   ld      (UBnkrotmatRoofvZ),de   ; write roofvz
                jp      .NormaliseRoofv             
;-- When noseY is large ------------------------ roofv_y = -(nosev_x * roofv_x + nosev_z * roofv_z) / nosev_y
.NoseYSmall:    ld      a,(UBnkrotmatNosevX+1)  
                ld      d,a
                ld      a,(UBnkrotmatRoofvX+1)  
                ld      e,a                     
                ld      a,(UBnkrotmatNosevZ+1)  
                ld      h,a                     
                ld      a,(UBnkrotmatRoofvZ+1)  
                ld      l,a                     
                ld      a,(UBnkrotmatNosevY+1)
                ld      b,a
                call    TidyCalc
                ld      a,d
                or      e
                jp      z,.NoRoofYFlip
                ld      a,$80                   ; flip sign bit if not zero
                xor     d
                ld      d,a
                ld      a,$80                   ; flip sign bit
                xor     d
                ld      d,a
.NoRoofYFlip:   ld      (UBnkrotmatRoofvY),de   ; write roofvy
.NormaliseRoofv:ld      ix,UBnkrotmatRoofvX     ; now normalise roofv
                call    NormaliseIXVector
; -- sidev_x = (nosev_z * roofv_y - nosev_y * roofv_z) / 96                
.CalcSidevX:    ld      a,(UBnkrotmatNosevZ+1)  
                ld      d,a
                ld      a,(UBnkrotmatRoofvY+1)  
                ld      e,a                     
                ld      a,(UBnkrotmatNosevY+1)  
                ld      h,a                     
                ld      a,(UBnkrotmatRoofvZ+1)  
                ld      l,a                     
                call    TidySide
                ld      (UBnkrotmatSidevX),de   ; write sidevX
; -- sidev_y = (nosev_x * roofv_z - nosev_z * roofv_x) / 96              
.CalcSidevY:    ld      a,(UBnkrotmatNosevX+1)  
                ld      d,a
                ld      a,(UBnkrotmatRoofvZ+1)  
                ld      e,a                     
                ld      a,(UBnkrotmatNosevZ+1)  
                ld      h,a                     
                ld      a,(UBnkrotmatRoofvX+1)  
                ld      l,a                     
                call    TidySide
                ld      (UBnkrotmatSidevY),de   ; write sidevX
; -- sidev_z = (nosev_y * roofv_x - nosev_x * roofv_y) / 96            
.CalcSidevZ:    ld      a,(UBnkrotmatNosevY+1)  
                ld      d,a
                ld      a,(UBnkrotmatRoofvX+1)  
                ld      e,a                     
                ld      a,(UBnkrotmatNosevX+1)  
                ld      h,a                     
                ld      a,(UBnkrotmatRoofvY+1)  
                ld      l,a                     
                call    TidySide
                ld      (UBnkrotmatSidevZ),de   ; write sidevX
                ret
    ELSE                
;                 
; Divide that sets value to FFFF if divide by 0 unless main value is 0, then 0

; (P+1 A) = (A P) / Q 
;  B A    = (A P) / Q 
; TESTED OK

                        
NormalizeXX15:          ld      hl, (XX15VecX)              ; h= VecX, l = VecY
                        ld      a,  (XX15VecZ)              ; a = VecZ, d we don't care
.ABSZ:                  and     SignMask8Bit
                        ld      iyh,a                       ; iyh = abs z
.ZSquared:              ld      d,a
                        ld      e,a
                        mul     de
                        ld      bc,de                       ; bc = z squared
.ABSX:                  ld      a,l
.XSquared:              and     SignMask8Bit
                        ld      ixh,a                       ; ixh = abs x
                        ld      d,a
                        ld      e,a
                        mul     de
                        ex      de,hl                       ; hl = x squared
.ABSY:                  ld      a,d                         ; as h was swapped into d 
                        and     SignMask8Bit
                        ld      ixl,a                       ; ixl = abs y
.YSquared:              ld      e,a
                        ld      d,a
                        mul     de                          ; de = y squared
                        add     hl,de                       ; hl = hl + de + bc
                        add     hl,bc                       ;
                        ex      de,hl
                        call    asm_sqrt                    ; d = iyl =hl = sqrt (de) = sqrt (x ^ 2 + y ^ 2 + z ^ 2)
                        ld      d,l
                        ld      iyl,d
.NormaliseX:            ld      a,ixh                       ; normalise x
                        call    AequAdivDmul96Q8
                        DISPLAY "TODO: ERROR if D is > 127 then it thinkgs its -ve number and falls appart"
                       ;TODO : Need a divison routine where D is unsigned as its sqare rooted so will always be positive
                        ld      d,a
                        ld      a,(XX15VecX)
                        and     SignOnly8Bit
                        or      d
                        ld      (XX15VecX),a
.NormaliseY:            ld      a,ixl                       ; normalise y
                        ld      d,l
                        call    AequAdivDmul96Q8
                        ld      d,a
                        ld      a,(XX15VecY)
                        and     SignOnly8Bit
                        or      d
                        ld      (XX15VecY),a
.NormaliseZ:            ld      a,iyh                       ; normalise z
                        ld      d,l
                        call    AequAdivDmul96Q8
                        ld      d,a
                        ld      a,(XX15VecZ)
                        and     SignOnly8Bit
                        or      d
                        ld      (XX15VecZ),a
                        ret

TidyNormaliseNoseV:     MACRO
                        call	CopyRotMatNoseVtoXX15	    ; copy over matrix row 3 (Nosev)	
                        call	NormalizeXX15			    ; normalise z hi, its really TIS3 and write back to matrix
                        call	CopyXX15toRotMatNoseV       ; .
                        ENDM
TidyNormaliseRoofV:     MACRO
                        call	CopyRotMatRoofVtoXX15		
                        call	NormalizeXX15			; normalise z hi, its really TIS3
                        call	CopyXX15toRotMatRoofV
                        ENDM


TidyUbnK:               ;break
                        TidyNormaliseNoseV
                        ld      a,(UBnkrotmatNosevX+1)      ; Now check and see which vector elemetn we are going to 
                        and     %01100000                   ; if X is not small then we go straigth to roofx
                        jp      nz,.ProcessRoofX            ; .
.TidyXIsSmall:          ld      a,(UBnkrotmatNosevY+1)      ; Else we test Y on to using 
                        and     %01100000                   ; if Y is not small we process roofz
                        jr      nz,.ProcessRoofZ            ; .
;...roofv_y´ = -(nosev_x´ * roofv_x + nosev_z´ * roofv_z) / nosev_y´      
.ProcessRoofY:          ld		a,(UBnkrotmatNosevX+1)
                        ld		(varQ),a					; q = nosev_y
                        ld		a,(UBnkrotmatRoofvX+1)	    ;roov z
                        call	RSequQmulA
                        ld		a,(UBnkrotmatNosevZ+1)		; nosev z
                        ld		(varQ),a					; b = regX for now
                        ld		a,(UBnkrotmatRoofvZ+1)	    ; roofv y
                        call	madDEequQmulAaddRS
                        ld      a,d                         ; flip sign bit
                        xor     SignOnly8Bit
                        ld      d,a                         
                        ld      a,(UBnkrotmatNosevY+1)
                        ld      (varQ),a
.YTest0Div:             ld      a,d
                        and     $7F
                        or      e
                        cp      0
                        jr      nz,.SkipYZeroTest
                        ZeroA
                        jp      .SetRoofZ
.YTestDiv0:             cp      0
                        jr      nz,.SkipYZeroTest
.YDivideByZero:         ld      a,96
                        or      d
                        jp      .SetRoofZ
.SkipYZeroTest:         ld      a,e
                        ld      (varP),a
                        ld      a,d
                        call    DVIDT
                        ld      a,b
.SetRoofY:              ld      (UBnkrotmatRoofvY+1),a
                        jp      .DoneRoof
;...roofv_z´ = -(nosev_x´ * roofv_x + nosev_y´ * roofv_y) / nosev_z´
.ProcessRoofZ:          ld		a,(UBnkrotmatNosevX+1)      ; Failing that we default to Z
                        ld		(varQ),a				    ; q = nosev_y
                        ld		a,(UBnkrotmatRoofvX+1)	    ;roov z
                        call	RSequQmulA  
                        ld		a,(UBnkrotmatNosevY+1)	    ; nosev z
                        ld		(varQ),a				    ; b = regX for now
                        ld		a,(UBnkrotmatRoofvY+1)	    ; roofv y
                        call	madDEequQmulAaddRS          
                        ld      a,d                         ; flip sign bit
                        xor     SignOnly8Bit
                        ld      d,a                         
                        ld      a,(UBnkrotmatNosevZ+1)
                        ld      (varQ),a
.ZTest0Div:             ld      a,d
                        and     $7F
                        or      e
                        cp      0
                        jr      nz,.SkipZZeroTest
                        ZeroA
                        jp      .SetRoofZ
.ZTestDiv0:             cp      0
                        jr      nz,.SkipZZeroTest
.ZDivideByZero:         ld      a,96
                        or      d
                        jp      .SetRoofZ
.SkipZZeroTest:         ld      a,e
                        ld      (varP),a
                        ld      a,d
                        call    DVIDT
                        ld      a,b
.SetRoofZ:              ld      (UBnkrotmatRoofvZ+1),a
                        jp      .DoneRoof
;...roofv_x´ = -(nosev_y´ * roofv_y + nosev_z´ * roofv_z) / nosev_x´
.ProcessRoofX:          ld		a,(UBnkrotmatNosevY+1)      ; so we set Q to Nose Y
                        ld		(varQ),a					; q = nosev_y
                        ld		a,(UBnkrotmatRoofvY+1)	    ; A = roofv Y
                        call	RSequQmulA                  ; RS = NoseY & RoofY
                        ld		a,(UBnkrotmatNosevZ+1)		; nosev z
                        ld		(varQ),a					; b = regX for now
                        ld		a,(UBnkrotmatRoofvZ+1)	    ; roofv y
                        call	madDEequQmulAaddRS
                        ld      a,d                         ; flip sign bit
                        xor     SignOnly8Bit
                        ld      d,a                         
                        ld      a,(UBnkrotmatNosevX+1)
                        ld      (varQ),a
.XTest0Div:             ld      a,d
                        and     $7F
                        or      e
                        cp      0
                        jr      nz,.SkipXZeroTest
                        ZeroA
                        jp      .SetRoofZ
.XTestDiv0:             cp      0
                        jr      nz,.SkipXZeroTest
.XDivideByZero:         ld      a,96
                        or      d
                        jp      .SetRoofX
.SkipXZeroTest:         ld      a,e
                        ld      (varP),a
                        ld      a,d
                        call    DVIDT
                        ld      a,b
.SetRoofX:              ld      (UBnkrotmatRoofvX+1),a
.DoneRoof:              TidyNormaliseRoofV
;...sidex = ((nosez * roofy) - nosey * roofz) / 96
.DoSidevX:              ld		a,(UBnkrotmatNosevZ+1)      ;  -(-nosev_z * roofv_y + nosev_y * roofv_z) / 96
                        xor     SignOnly8Bit
                        ld		(varQ),a					; q = nosev_y
                        ld		a,(UBnkrotmatRoofvY+1)	     ;roov z
                        call	RSequQmulA
                        ld		a,(UBnkrotmatNosevY+1)		; nosev z
                        ld		(varQ),a							; b = regX for now
                        ld		a,(UBnkrotmatRoofvZ+1)	    ; roofv y
                        call	madDEequQmulAaddRS
                        call    BAequDEdiv96
                        ld      a,b
                        ld      (UBnkrotmatSidevX+1),a    
;...sidey = ((nosex * roofz) - nosez * roofx) / 96
.DoSidevY:              ld		a,(UBnkrotmatNosevX+1)      ; -(-nosev_x * roofv_z - nosev_z * roofv_x) / 96
                        xor     SignOnly8Bit
                        ld		(varQ),a					; q = nosev_y
                        ld		a,(UBnkrotmatRoofvZ+1)	    ; roov z
                        call	RSequQmulA                  ; rs = nosex * roofz
                        ld		a,(UBnkrotmatNosevZ+1)		; nosev z
                        ld		(varQ),a					; b = regX for now
                        ld		a,(UBnkrotmatRoofvZ+1)	    ; roofv y
                        call	madDEequQmulAaddRS          ; DE = noseyz* roofz + 
                        call    BAequDEdiv96
                        ld      a,b
                        ld      (UBnkrotmatSidevY+1),a         ;-(-nosev_y * roofv_x + nosev_x * roofv_y) / 96
;...sidez = ((nosey * roofx) - nosex * roofy) / 96
.DoSidevZ:              ld		a,(UBnkrotmatNosevY+1)      ; 
                        xor     SignOnly8Bit
                        ld		(varQ),a					; q = nosev_y
                        ld		a,(UBnkrotmatRoofvZ+1)	     ;roov z
                        call	RSequQmulA
                        ld		a,(UBnkrotmatNosevX+1)		; nosev z
                        ld		(varQ),a							; b = regX for now
                        ld		a,(UBnkrotmatRoofvY+1)	    ; roofv y
                        call	madDEequQmulAaddRS
                        call    BAequDEdiv96
                        ld      a,b
                        ld      (UBnkrotmatSidevZ+1),a
                        ZeroA
                        ld      (UBnkrotmatSidevX),a
                        ld      (UBnkrotmatSidevY),a
                        ld      (UBnkrotmatSidevZ),a
                        ret


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




            DISPLAY "TODO: look at note on TODO"
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

ORTHOGALISE:
;-- NormaliseNosev
		call	CopyRotMatNoseVtoXX15		
		call	normaliseXX1596S7			; normalise z hi, its really TIS3
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
		call	normaliseXX1596S7			; normalise roof
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
        JumpIfAIsZero NormSideXNoNeg
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
        JumpIfAIsZero NormSideYNoNeg
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
        JumpIfAIsZero NormSideZNoNeg
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
		call	normaliseXX1596S7			; normalise roof
;calc sidev x
		call	CopyXX15toRotMatSideV		; get back normalised version
        
		ret	
		
	
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
    ENDIF