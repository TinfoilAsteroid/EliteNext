; We enter here with hl pointing at XX16 and bc = XX15 value
; so xx12 = XX15 * XX16 row
XX12ProcessOneRow:
XX12CalcXCell:
        ld		bc,(UBnkXScaled)
		ld		e,(hl)								    ; get orientation ZX
		inc		hl
		ld		d,(hl)                                  ; so now e = xx16 value d = xx16 sign
		ld		a,d
        xor     b
		and		SignOnly8Bit                            ; a = XX 16 sign
		ld		ixh,a								    ; orientation sign to ixh  
		ld		a,b                                     ; now make bc abs bc
		and		SignMask8Bit
		ld		b,a                                     ; bc = abs(bc) now
		push	hl
        ld      d,0                                     ; d = value
		ld		h,b
		ld		l,c
		call	mulDEbyHL							    ; hl = |orientation| * |x pos)
		ld		(XX12PVarResult1),hl				    ; T = 16 bit result, we only want to use high byte later
		ld		a,ixh
		ld		(XX12PVarSign1),a					    ; S = sign  not sign 1 and 2 are reversed in memory so that fetchign back will put 1 in high byte 2 in low byte
		pop		hl
XX12CalcYCell:
        ld		bc,(UBnkYScaled)
		inc		hl
		ld		e,(hl)							    	; get orientation ZX
		inc		hl
		ld		d,(hl)
		ld		a,d
        xor     b
		and		SignOnly8Bit
		ld		ixh,a								    ; XX16 orientation sign to ixh
		ld		a,b                                     ; now make bc abs bc
		and		SignMask8Bit
		ld		b,a                                     ; bc = abs(bc) now
		push	hl
        ld      d,0                                     ; d = value
		ld		h,b
		ld		l,c
		call	mulDEbyHL							    ; hl = |orientation| * |x pos)
		ld		(XX12PVarResult2),hl				    ; T = 16 bit result
		ld		a,ixh
		ld		(XX12PVarSign2),a					    ; S = sign
		pop		hl
XX12CalcZCell:
        ld		bc,(UBnkZScaled)
		inc		hl
		ld		e,(hl)								    ; get orientation ZX
		inc		hl
		ld		d,(hl)
		ld		a,d
        xor     b
		and		SignOnly8Bit
		ld		ixh,a								    ; orientation sign to ixh
		ld		a,b                                     ; now make bc abs bc
		and		SignMask8Bit
		ld		b,a                                     ; bc = abs(bc) now
        ld      d,0                                     ; d = value
		ld		h,b
		ld		l,c
		call	mulDEbyHL							    ; hl = |orientation| * |x pos)
		ld		(XX12PVarResult3),hl				    ; T = 16 bit result
		ld		a,ixh
		ld		(XX12PVarSign3),a					    ; S = sign
XX12CalcCellResult:
		ld		hl,(XX12PVarResult1)				    ; X Cell Result
		ld		de,(XX12PVarResult2)				    ; Y Cell Result
		ld		bc,(XX12PVarSign2)					    ; b = var 1 result sign c = var 2 result signs
XX12MSBOnly:
		ld		l,h									    ; now move results into lower byte so / 256
		ld		e,d									    ; for both results
		xor		a									    ;
		ld		h,a									    ;
		ld		d,a									    ; so set high byte to 0
		call	ADDHLDESignBC                           ;  XX12ProcessCalcHLPlusDESignBC		; returns with HL = result1 + result 2 signed in a 
		ld		b,a									    ; move sign into b ready for next calc
		ld		a,(XX12PVarSign3)					    ; result of the calcZ cell
		ld		c,a									    ; goes into c to align with DE
		ld		de,(XX12PVarResult3)				    ; now add result to Result 3
		ld		e,d                                     ; d = result /256
		ld		d,0									    ; and only us high byte
		call	ADDHLDESignBC; XX12ProcessCalcHLPlusDESignBC		; returns with HL = result and a = sign
		ret											    ; hl = result, a = sign
								    ; hl = result, a = sign

XX12EquNodeDotTransMat:							    ; .LL51	\ -> &4832 \ XX12=XX15.XX16  each vector is 16-bit x,y,z **** ACTUALLY XX16 is value in low sign bit in high
;...X cell
		ld		hl,UbnkTransInvRow0x0     			; process orientation matrix row 0
        call    XX12ProcessOneRow                   ; hl = result, a = sign
		ld		b,a                                 ; b = sign
		ld		a,h                                 ; a = high byte
		or		b
		ld		(UBnkXX12xSign),a					; a = result with sign in bit 7
		ld		a,l                                 ; the result will be in the lower byte now
        ld      (UBnkXX12xLo),a						; that is result done for
;...Y cell
		ld		hl,UbnkTransInvRow1y0     			; process orientation matrix row 1
        call    XX12ProcessOneRow
		ld		b,a
		ld		a,h
;		ld		a,l
		or		b
		ld		(UBnkXX12ySign),a					; a = result with sign in bit 7
		ld		a,l                                 ; the result will be in the lower byte now
        ld      (UBnkXX12yLo),a						; that is result done for
;...Z cell
		ld		hl,UbnkTransInvRow2z0     			; process orientation matrix row 1
        call    XX12ProcessOneRow
		ld		b,a
        ld		a,h
;		ld		a,l
		or		b
		ld		(UBnkXX12zSign),a					; a = result with sign in bit 7
		ld		a,l                                 ; the result will be in the lower byte now
        ld      (UBnkXX12zLo),a						; that is result done for
        ret

XX12EquNodeDotOrientation:							; .LL51	\ -> &4832 \ XX12=XX15.XX16  each vector is 16-bit x,y,z **** ACTUALLY XX16 is value in low sign bit in high
;...X cell
		ld		hl,UbnkTransInvRow0x0     			; process orientation matrix row 0
        call    XX12ProcessOneRow                   ; hl = result, a = sign
		ld		b,a                                 ; b = sign
		ld		a,h                                 ; a = high byte
		or		b
		ld		(UBnkXX12xSign),a					; a = result with sign in bit 7
		ld		a,l                                 ; the result will be in the lower byte now
        ld      (UBnkXX12xLo),a						; that is result done for
;...Y cell
		ld		hl,UbnkTransInvRow1y0     			; process orientation matrix row 1
        call    XX12ProcessOneRow
		ld		b,a
		ld		a,h
;		ld		a,l
		or		b
		ld		(UBnkXX12ySign),a					; a = result with sign in bit 7
		ld		a,l                                 ; the result will be in the lower byte now
        ld      (UBnkXX12yLo),a						; that is result done for
;...Z cell
		ld		hl,UbnkTransInvRow2z0     			; process orientation matrix row 1
        call    XX12ProcessOneRow
		ld		b,a
        ld		a,h
;		ld		a,l
		or		b
		ld		(UBnkXX12zSign),a					; a = result with sign in bit 7
		ld		a,l                                 ; the result will be in the lower byte now
        ld      (UBnkXX12zLo),a						; that is result done for
        ret

XX12EquNodeDotXX16:					         		; .LL51	\ -> &4832 \ XX12=XX15.XX16  each vector is 16-bit x,y,z **** ACTUALLY XX16 is value in low sign bit in high
;...X cell
		ld		hl,UBnkTransmatSidevX     			; process orientation matrix row 0
        call    XX12ProcessOneRow                   ; hl = result, a = sign
		ld		b,a                                 ; b = sign
		ld		a,h                                 ; a = high byte
		or		b
		ld		(UBnkXX12xSign),a					; a = result with sign in bit 7
		ld		a,l                                 ; the result will be in the lower byte now
        ld      (UBnkXX12xLo),a						; that is result done for
;...Y cell
		ld		hl,UBnkTransmatRoofvX     			; process orientation matrix row 1
        call    XX12ProcessOneRow
		ld		b,a
		ld		a,h
;		ld		a,l
		or		b
		ld		(UBnkXX12ySign),a					; a = result with sign in bit 7
		ld		a,l                                 ; the result will be in the lower byte now
        ld      (UBnkXX12yLo),a						; that is result done for
;...Z cell
		ld		hl,UBnkTransmatNosevX     			; process orientation matrix row 1
        call    XX12ProcessOneRow
		ld		b,a
        ld		a,h
;		ld		a,l
		or		b
		ld		(UBnkXX12zSign),a					; a = result with sign in bit 7
		ld		a,l                                 ; the result will be in the lower byte now
        ld      (UBnkXX12zLo),a						; that is result done for
        ret       