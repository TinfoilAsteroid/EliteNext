
XX12DefineMacro:    MACRO   p?

;p?_XX1576                     DW  0
p?_XX1210                     EQU p?_XX1576
p?_XX12p1                     EQU p?_XX1210+1
;p?_XX12                       EQU p?_XX1210

;-- transmat0 --------------------------------------------------------------------------------------------------------------------------")
; Note XX12 comes after as some logic in normal processing uses XX15 and XX12 combines")
p?_BnkXX12xLo                 DB  0               ; XX12+0
p?_BnkXX12xSign               DB  0               ; XX12+1
p?_BnkXX12yLo                 DB  0               ; XX12+2
p?_BnkXX12ySign               DB  0               ; XX12+3
p?_BnkXX12zLo                 DB  0               ; XX12+4
p?_BnkXX12zSign               DB  0               ; XX12+5
p?_XX12Save                   DS  6
p?_XX12Save2                  DS  6
p?_XX12                       equ p?_BnkXX12xLo
p?_varXX12                    equ p?_BnkXX12xLo
; Repurposed XX12 when plotting lines")
p?_BnkY2                      equ p?_XX12+0
p?_Bnky2Lo                    equ p?_XX12+0
p?_BnkY2Hi                    equ p?_XX12+1
p?_BnkDeltaXLo                equ p?_XX12+2
p?_BnkDeltaXHi                equ p?_XX12+3
p?_BnkDeltaYLo                equ p?_XX12+4
p?_BnkDeltaYHi                equ p?_XX12+5
p?_BnkGradient                equ p?_XX12+2
p?_BnkTemp1                   equ p?_XX12+2
p?_BnkTemp1Lo                 equ p?_XX12+2
p?_BnkTemp1Hi                 equ p?_XX12+3
p?_BnkTemp2                   equ p?_XX12+3
p?_BnkTemp2Lo                 equ p?_XX12+3
p?_BnkTemp2Hi                 equ p?_XX12+4
                                    ENDM

XX12DotOneRowMacro:                 MACRO p?
p?_XX12DotOneRow:
p?_XX12CalcX:                 N0equN1byN2div256 varT, (hl), (p?_BnkXScaled)        ; T = (hl) * regXX15fx /256 
                                    inc     hl                                                  ; move to sign byte
.XX12CalcXSign:                     AequN1xorN2 p?_BnkXScaledSign,(hl)           ;
                                    ld      (varS),a                                            ; Set S to the sign of x_sign * sidev_x
                                    inc     hl
.XX12CalcY:                         N0equN1byN2div256 varQ, (hl),(p?_BnkYScaled)          ; Q = XX16 * XX15 /256 using varQ to hold regXX15fx
                                    ldCopyByte varT,varR                                        ; R = T =  |sidev_x| * x_lo / 256
                                    inc     hl
                                    AequN1xorN2 p?_BnkYScaledSign,(hl)                          ; Set A to the sign of y_sign * sidev_y
; (S)A = |sidev_x| * x_lo / 256  = |sidev_x| * x_lo + |sidev_y| * y_lo
.STequSRplusAQ                       push    hl
                                    call    baddll38                                            ; JSR &4812 \ LL38   \ BADD(S)A=R+Q(SA) \ 1byte add (subtract)
                                    pop     hl
                                    ld      (varT),a                                            ; T = |sidev_x| * x_lo + |sidev_y| * y_lo
                                    inc     hl
.XX12CalcZ:                         N0equN1byN2div256 varQ,(hl),(p?_BnkZScaled)           ; Q = |sidev_z| * z_lo / 256
                                    ldCopyByte varT,varR                                        ; R = |sidev_x| * x_lo + |sidev_y| * y_lo
                                    inc     hl
                                    AequN1xorN2 p?_BnkZScaledSign,(hl)                    ; A = sign of z_sign * sidev_z
; (S)A= |sidev_x| * x_lo + |sidev_y| * y_lo + |sidev_z| * z_lo        
                                    call    baddll38                                            ; JSR &4812 \ LL38   \ BADD(S)A=R+Q(SA)   \ 1byte add (subtract)
; Now we exit with A = result S = Sign        
                                    ret
                                    ENDM
                            
                            
CopyXX12ScaledToXX18Macro:      MACRO    p?
p?_CopyXX12ScaledToXX18:      
p?_CopyResultToDrawCam:       ld      hl, p?_XX12
                                    ld      de, p?_XX18
                                    ldi    ; X12+0 => XX18+0  Set XX18(2 0) = dot_sidev
                                    inc de ; skip to XX18+2 as it will be on XX18+1
                                    ldi    ; XX12+1 => XX18+2
                                    ldi    ; XX12+2 => XX18+3 Set XX12+1 => XX18+2
                                    inc de ; skip to XX18+5 as it will be on XX18+4
                                    ldi    ; XX12+3 => XX18+5
                                    ldi    ; XX12+4 => XX18+6 Set XX18(8 6) = dot_nosev
                                    inc de ; skip to XX18+8 as it will be on XX18+7
                                    ldi    ; XX12+5 => XX18+8
                                    ret
                                ENDM        
                            
;OLD VERSION?CopyXX12ScaledToXX18Macro:          MACRO p?
;OLD VERSION?p?_CopyXX12ScaledToXX18:
;OLD VERSION?p?_CopyResultToDrawCam:
;OLD VERSION?                                    ldCopyByte p?_XX12         ,p?_XX18             ; XX12+0 => XX18+0  Set XX18(2 0) = dot_sidev
;OLD VERSION?                                    ldCopyByte p?_XX12+1       ,p?_XX18+2           ; XX12+1 => XX18+2
;OLD VERSION?                                    ldCopyByte p?_XX12+2       ,p?_XX18+3           ; XX12+2 => XX18+3  Set XX12+1 => XX18+2
;OLD VERSION?                                    ldCopyByte p?_XX12+3       ,p?_XX18+5           ; XX12+3 => XX18+5
;OLD VERSION?                                    ldCopyByte p?_XX12+4       ,p?_XX18+6           ; XX12+4 => XX18+6  Set XX18(8 6) = dot_nosev
;OLD VERSION?                                    ldCopyByte p?_XX12+5       ,p?_XX18+8           ; XX12+5 => XX18+8
;OLD VERSION?                                    ret
;OLD VERSION?                                    ENDM

XX12EquXX15DotProductXX16Macro:     MACRO p?
p?_XX12EquXX15DotProductXX16: ld      bc,0                                ; LDX, LDY 0
                                    ld      hl,p?_BnkTransmatSidevX     
                                    call    p?_XX12DotOneRow
                                    ld      (p?_BnkXX12xLo),a
                                    ld      a,(varS)
                                    ld      (p?_BnkXX12xSign),a
                                    ld      hl,p?_BnkTransmatRoofvX     
                                    call    p?_XX12DotOneRow
                                    ld      (p?_BnkXX12yLo),a
                                    ld      a,(varS)
                                    ld      (p?_BnkXX12ySign),a
                                    ld      hl,p?_BnkTransmatNosevX     
                                    call    p?_XX12DotOneRow
                                    ld      (p?_BnkXX12zLo),a
                                    ld      a,(varS)
                                    ld      (p?_BnkXX12zSign),a
                                    ret
                                    ENDM

CopyXX12toXX15Macro:                MACRO p?
p?_CopyXX12toXX15:            ldCopyByte  p?_BnkXX12xLo     ,p?_BnkXScaled        ; xlo
                                    ldCopyByte  p?_BnkXX12xSign   ,p?_BnkXScaledSign    ; xsg
                                    ldCopyByte  p?_BnkXX12yLo     ,p?_BnkYScaled        ; xlo
                                    ldCopyByte  p?_BnkXX12ySign   ,p?_BnkYScaledSign    ; xsg
                                    ldCopyByte  p?_BnkXX12zLo     ,p?_BnkZScaled        ; xlo
                                    ldCopyByte  p?_BnkXX12zSign   ,p?_BnkZScaledSign    ; xsg
                                    ret
                                    ENDM


CopyXX12ToScaledMacro:              MACRO p?
p?_CopyXX12ToScaled:
p?_CopyResultToScaled:        ldCopyByte  p?_XX12+0,p?_BnkXScaled      ; xnormal lo
                                    ldCopyByte  p?_XX12+2,p?_BnkYScaled      ; ynormal lo
                                    ldCopyByte  p?_XX12+4,p?_BnkZScaled      ; znormal lo and leaves a holding zscaled normal
                                    ret
                                    ENDM

CopyFaceToXX12Macro:                MACRO p?
p?_CopyFaceToXX12:            ld      a,(hl)                      ; get Normal byte 0                                                                    ;;;     if visibility (bits 4 to 0 of byte 0) > XX4
                                    ld      b,a                         ; save sign bits to b
                                    and     SignOnly8Bit
                                    ld      (p?_BnkXX12xSign),a           ; write Sign bits to x sign                                                            ;;;
                                    ld      a,b
                                    sla     a                           ; move y sign to bit 7                                                                 ;;;   copy sign bits to XX12
                                    ld      b,a        
                                    and     SignOnly8Bit
                                    ld      (p?_BnkXX12ySign),a           ;                                                                                      ;;;
                                    ld      a,b
                                    sla     a                           ; move y sign to bit 7                                                                 ;;;   copy sign bits to XX12
                                    and     SignOnly8Bit
                                    ld      (p?_BnkXX12zSign),a           ;                                                                                      ;;;
                                    inc     hl                          ; move to X ccord
                                    ld      a,(hl)                      ;                                                                                      ;;;   XX12 x,y,z lo = Normal[loop].x,y,z
                                    ld      (p?_BnkXX12xLo),a                                                                                                    ;;;
                                    inc     hl                                                                                                                 ;;;
                                    ld      a,(hl)                      ;                                                                                      ;;;
                                    ld      (p?_BnkXX12yLo),a                                                                                                    ;;;
                                    inc     hl                                                                                                                 ;;;
                                    ld      a,(hl)                      ;                                                                                      ;;;
                                    ld      (p?_BnkXX12zLo),a     
                                    ret
                                    ENDM
		
CopyXX12toXX18Macro:                MACRO    p?     
p?_CopyXX12toXX18:            ld      hl, p?_BnkXX12xLo
                                    ld      de, p?_XX18
                                    ldi      ; xlo
                                    ldi      ; xsg
                                    ldi      ; xlo
                                    ldi      ; xsg
                                    ldi      ; xlo
                                    ldi      ; xsg
                                    ret
                                    ENDM        

DotProductXX12XX15Macro:            MACRO  p?
p?_DotProductXX12XX15:        ld          a,(p?_BnkXX12xLo)         ; Use e as var Q for xnormal lo
                                    JumpIfAIsZero .dotxskipzero
                                    ld          e,a
                                    ld          a,(p?_BnkXScaled)         ; use d as XX12 world xform x, e = norm x
                                    ld          d,a                     ; de = xx12 x signed 
                                    JumpIfAIsZero .dotxskipzero
                                    mul
                                    ld          b,d                     ; b = result
                                    ld          a,(p?_BnkXX12xSign)
                                    ld          hl,p?_BnkXScaledSign
                                    xor         (hl)
                                    and         $80                     ; so sign bit only
                                    ld          iyh ,a                   ; we actually need to preserve sign in iyh here
                                    jp          .dotmuly
.dotxskipzero:                      xor         a
                                    ld          b,a
                                    ld          iyh,a
; now we have b = XX12 x &d  norm x signed  
.dotmuly:                           ld          a,(p?_BnkXX12yLo)
                                    JumpIfAIsZero .dotyskipzero
                                    ld          e,a
                                    ld          a,(p?_BnkYScaled)         ; XX15+2
                                    JumpIfAIsZero .dotyskipzero
                                    ld          d,a                     ; de = xx12 x signed 
                                    mul         
                                    ld          c,d                     ; c = result
                                    ld          ixl,c
                                    ld          a,(p?_BnkXX12ySign)       ; A = ysg
                                    ld          hl, p?_BnkYScaledSign     ; a= y sign XOR Y scaled sign
                                    xor         (hl)                    ; XX15+3
                                    and         $80                     ; do b = x mul c = y mul, iyh = sign for b and a = sign for c
                                    ld          ixh,a
                                    jp          .dotaddxy
.dotyskipzero:                      xor         a
                                    ld          c,a
                                    ld          ixh,a
; Optimise later as this is 16 bit
.dotaddxy:                          ld          h,0                     ;
                                    ld          l,b                     ; hl = xlo + x scaled
                                    ld          d,0                     ;
                                    ld          e,c                     ; de = ylo + yscaled
                                    ld          b,iyh                   ; b = sign of xlo + xscaled
                                    ld          c,a                     ; c = sign of ylo + yscaled
                                    MMUSelectMathsBankedFns
                                    call ADDHLDESignBC                  ; so now hl = result so will push sign to h
                                    ld          b,a                     ; b = resultant sign , hl = add so far
                                    ld          a,(p?_BnkXX12zLo)         ; 
                                    JumpIfAIsZero .dotzskipzero
                                    ld          e,a                     ; 
                                    ld          a,(p?_BnkZScaled)         ;
                                    JumpIfAIsZero .dotzskipzero
                                    ld          d,a
                                    mul
                                    push        hl                      ; save prev result
                                    ld          a,(p?_BnkZScaledSign)
                                    ld          hl, p?_BnkXX12zSign       ; XX15+5
                                    xor         (hl)                    ; hi sign
                                    and         $80                     ; a = sign of multiply
                                    ld          c,a                     ; c = sign of z lo & z scaled
                                    pop         hl
                                    ld          e,d
                                    ld          d,0
                                    MMUSelectMathsBankedFns
                                    call ADDHLDESignBC
                                    ld          (varS),a
                                    ld          a,l
                                    ret                                 ; returns with A = value, varS = sign
; if we got here then z was zero so no component so just tidy up from last add
.dotzskipzero:                      ld          a,b
                                    ld          (varS),a
                                    ld          a,l
                                    ret
                                    ENDM

TransposeXX12ByShipToXX15Macro:     MACRO       p?
p?_TransposeXX12ByShipToXX15: ld  hl,(p?_BnkXX12xLo)					; get X into HL
                                    ld		a,h			                        ; get XX12 Sign						
                                    and		$80									; check sign bit on high byte
                                    ld		b,a									; and put it in of 12xlo in b
                                    ;110921 debugld      h,0
                                    ld      a,h
                                    and     $7F
                                    ld      h,a
                                    ;110921 debugld      h,0
                                    ld		de,(p?_Bnkxlo)						;
                                    ld		a,(p?_Bnkxsgn)						; get Ship Pos (low,high,sign)
                                    and		$80									; make sure we only have bit 7
                                    ld		c,a									; and put sign of unkxsgn c
                                    MMUSelectMathsBankedFns
                                    call 	ADDHLDESignBC; XX12ProcessCalcHLPlusDESignBC		; this will result in HL = result and A = sign
                                    or		h									; combine sign in A with H to give 15 bit signed (*NOT* 2's c)
                                    ld		h,a
                                    ld		(p?_BnkXScaled),hl					; now write it out to XX15 X pos
; ..................................
                                    ld		hl,(p?_BnkXX12yLo)					; Repeat above for Y coordinate
                                    ld		a,h
                                    and		$80
                                    ld		b,a
                                    ;110921 debugld      h,0
                                    ld      a,h
                                    and     $7F
                                    ld      h,a
                                    ;110921 debugld      h,0
                                    ld		de,(p?_Bnkylo)
                                    ld		a,(p?_Bnkysgn)
                                    and		$80									; make sure we only have bit 7
                                    ld		c,a
                                    MMUSelectMathsBankedFns
                                    call 	ADDHLDESignBC; XX12ProcessCalcHLPlusDESignBC
                                    or		h									; combine sign in A with H
                                    ld		h,a
                                    ld		(p?_BnkYScaled),hl
; ..................................
                                    ld		hl,(p?_BnkXX12zLo)					; and now repeat for Z cooord
                                    ld		a,h
                                    and		$80
                                    ld		b,a
                                    ;110921 debugld      h,0
                                    ld      a,h
                                    and     $7F
                                    ld      h,a
                                    ;110921 debugld      h,0
                                    ld		de,(p?_Bnkzlo)
                                    ld		a,(p?_Bnkzsgn)
                                    and		$80									; make sure we only have bit 7
                                    ld		c,a
                                    MMUSelectMathsBankedFns
                                    call 	ADDHLDESignBC; XX12ProcessCalcHLPlusDESignBC
                                    or		h									; combine sign in A with H
                                    ld		h,a
                                    bit		7,h                                 ; if sign if positive then we don't need to do the clamp so we ony jump 
                                    jr		nz,.ClampZto4                        ; result was negative so we need to clamp to 4
                                    and     $7F                                 ; a = value unsigned
                                    jr      nz,.NoClampZto4                      ; if high byte was 0 then we could need to clamp still by this stage its +v but and will set z flag if high byte is zero
                                    ld      a,l                                 ; get low byte now
                                    JumpIfALTNusng 4,.ClampZto4					; if its < 4 then fix at 4
.NoClampZto4:                       ld		(p?_BnkZScaled),hl					; hl = signed calculation and > 4
                                    ld		a,l									; in addition write out the z cooord to UT for now for backwards compat (DEBUG TODO remove later)
                                    ld      (varT),a
                                    ld		a,h
                                    ld      (varU),a
                                    ret
; This is where we limit 4 to a minimum of 4
.ClampZto4:		         		    ld		hl,4
                                    ld		(p?_BnkZScaled),hl; BODGE FOR NOW
                                    ld		a,l
                                    ld      (varT),a                            ;                                                                           ;;;
                                    ld		a,h
                                    ld      (varU),a 						; compatibility for now
                                    ret
                                    ENDM

TransposeXX12NodeToXX15Macro        MACRO p?
p?_TransposeXX12NodeToXX15:   ldCopyByte  p?_Bnkxsgn,p?_BnkXPointSign           ; p?_BnkXSgn => XX15+2 x sign
                                    ld          bc,(p?_BnkXX12xLo)                   ; c = lo, b = sign   XX12XLoSign
                                    xor         b                                   ; a = p?_BnkKxsgn (or XX15+2) here and b = XX12xsign,  XX12+1 \ rotated xnode h                                                                             ;;;           a = a XOR XX12+1                              XCALC
                                    jp          m,.NodeNegativeX                                                                                                                                                            ;;;           if sign is +ve                        ::LL52   XCALC
; XX15 [0,1] = INWK[0]+ XX12[0] + 256*INWK[1]                                                                                       ;;;          while any of x,y & z hi <> 0 
.NodeXPositiveX:                    ld          a,c                                 ; We picked up XX12+0 above in bc Xlo
                                    ld          b,0                                 ; but only want to work on xlo                                                           ;;;              XX15xHiLo = XX12HiLo + xpos lo             XCALC
                                    ld          hl,(p?_Bnkxlo)                       ; hl = XX1 p?_BnkxLo
                                    ld          h,0                                 ; but we don;t want the sign
                                    add         hl,bc                               ; its a 16 bit add
                                    ld          (p?_BnkXPoint),hl                    ; And written to XX15 0,1 
                                    xor         a                                   ; we want to write 0 as sign bit (not in original code)
                                    ld          (p?_BnkXPointSign),a
                                    jp          .FinishedThisNodeX
; If we get here then _sign and vertv_ have different signs so do subtract
.NodeNegativeX:                     
.LL52X:                             ld          hl,(p?_Bnkxlo)                       ; Coord
                                    ld          bc,(p?_BnkXX12xLo)                   ; XX12
                                    ld          b,0                                 ; XX12 lo byte only
                                    sbc         hl,bc                               ; hl = p?_Bnkx - p?_BnkXX12xLo
                                    jp          p,.SetAndMopX                       ; if result is positive skip to write back
; If we get here the result is 2'c compliment so we reverse it and flip sign
.NodeXNegSignChangeX:               call        negate16hl                          ; Convert back to positive and flip sign
                                    ld          a,(p?_BnkXPointSign)                 ; XX15+2
                                    xor         $80                                 ; Flip bit 7
                                    ld          (p?_BnkXPointSign),a                 ; XX15+2
.SetAndMopX:                        ld          (p?_Bnkxlo),hl                       ; XX15+0
.FinishedThisNodeX:
.LL53:                              ldCopyByte  p?_Bnkysgn,p?_BnkYPointSign           ; p?_BnkXSgn => XX15+2 x sign
                                    ld          bc,(p?_BnkXX12yLo)                   ; c = lo, b = sign   XX12XLoSign
                                    xor         b                                   ; a = p?_BnkKxsgn (or XX15+2) here and b = XX12xsign,  XX12+1 \ rotated xnode h                                                                             ;;;           a = a XOR XX12+1                              XCALC
                                    jp          m,.NodeNegativeY                                                                                                                                                            ;;;           if sign is +ve                        ::LL52   XCALC
; XX15 [0,1] = INWK[0]+ XX12[0] + 256*INWK[1]                                                                                       ;;;          while any of x,y & z hi <> 0 
.NodeXPositiveY:                    ld          a,c                                 ; We picked up XX12+0 above in bc Xlo
                                    ld          b,0                                 ; but only want to work on xlo                                                           ;;;              XX15xHiLo = XX12HiLo + xpos lo             XCALC
                                    ld          hl,(p?_Bnkylo)                       ; hl = XX1 p?_BnkxLo
                                    ld          h,0                                 ; but we don;t want the sign
                                    add         hl,bc                               ; its a 16 bit add
                                    ld          (p?_BnkYPoint),hl                    ; And written to XX15 0,1 
                                    xor         a                                   ; we want to write 0 as sign bit (not in original code)
                                    ld          (p?_BnkXPointSign),a
                                    jp          .FinishedThisNodeY
; If we get here then _sign and vertv_ have different signs so do subtract
.NodeNegativeY:        
.LL52Y:                             ld          hl,(p?_Bnkylo)                       ; Coord
                                    ld          bc,(p?_BnkXX12yLo)                   ; XX12
                                    ld          b,0                                 ; XX12 lo byte only
                                    sbc         hl,bc                               ; hl = p?_Bnkx - p?_BnkXX12xLo
                                    jp          p,.SetAndMopY                       ; if result is positive skip to write back
; If we get here the result is 2'c compliment so we reverse it and flip sign
.NodeXNegSignChangeY:               call        negate16hl                          ; Convert back to positive and flip sign
                                    ld          a,(p?_BnkYPointSign)                 ; XX15+2
                                    xor         $80                                 ; Flip bit 7
                                    ld          (p?_BnkYPointSign),a                 ; XX15+2
.SetAndMopY:                        ld          (p?_Bnkylo),hl                       ; XX15+0
.FinishedThisNodeY:                 
.TransposeZ:                                             ; Both y signs arrive here, Onto z                                          ;;;
.LL55:                              ld          a,(p?_BnkXX12zSign)                   ; XX12+5    \ rotated znode hi                                              ;;;
                                    JumpOnBitSet a,7,.NegativeNodeZ                    ; LL56 -ve Z node                                                           ;;;
                                    ld          a,(p?_BnkXX12zLo)                     ; XX12+4 \ rotated znode lo                                                 ;;;
                                    ld          hl,(p?_Bnkzlo)                        ; INWK+6    \ zorg lo                                                       ;;;
                                    add         hl,a                                ; hl = INWKZ + XX12z                                                        ;;;
                                    ld          a,l
                                    ld          (varT),a                            ;                                                                           ;;;
                                    ld          a,h
                                    ld          (varU),a                            ; now z = hl or U(hi).T(lo)                                                 ;;;
                                    ret                                             ; LL57  \ Node additions done, z = U.T                                      ;;;
; Doing additions and scalings for each visible node around here                                                                    ;;;
.NegativeNodeZ:                                          ; Enter XX12+5 -ve Z node case  from above                                  ;;;
.LL56:                              ld          hl,(p?_Bnkzlo)                        ; INWK+6 \ z org lo                                                         ;;;
                                    ld          bc,(p?_BnkXX12zLo)                    ; XX12+4    \ rotated z node lo                                                 ......................................................
                                    ld          b,0                                 ; upper byte will be garbage
                                    ClearCarryFlag
                                    sbc         hl,bc                               ; 6502 used carry flag compliment
                                    ld          a,l
                                    ld          (varT),a                            ; t = result low
                                    ld          a,h
                                    ld          (varU),a                            ; u = result high
                                    jp          po,.MakeNodeClose                   ; no overflow to parity would be clear
.LL56Overflow:                      cp          0                                   ; is varU 0?
                                    ret          nz; was jp nz which woudl have left stack with ret address,.NodeAdditionsDone               ; Enter Node additions done, UT=z
                                    ld          a,(varT)                            ; T \ restore z lo
                                    ReturnIfAGTENusng 4                              ; >= 4 ? zlo big enough, Enter Node additions done.
.MakeNodeClose: ; else make node close
.LL140:                             xor         a                                   ; hi This needs tuning to use a 16 bit variable
                                    ld          (varU),a                            ; U
                                    ld          a,4                                 ; lo
                                    ld          (varT),a                            ; T
                                    ret        
                                    ENDM
                                    
                                    
                                    
                                    ; We enter here with hl pointing at XX16 and bc = XX15 value
; so xx12 = XX15 * XX16 row
XX12NodeDotOrientationMacro:        MACRO       p?

p?_XX12ProcessOneRow:
p?_XX12CalcXCell:             ld		bc,(p?_BnkXScaled)
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
.XX12CalcYCell:                     ld		bc,(p?_BnkYScaled)
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
.XX12CalcZCell:                     ld		bc,(p?_BnkZScaled)
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
.XX12CalcCellResult:                ld		hl,(XX12PVarResult1)				    ; X Cell Result
                                    ld		de,(XX12PVarResult2)				    ; Y Cell Result
                                    ld		bc,(XX12PVarSign2)					    ; b = var 1 result sign c = var 2 result signs
.XX12MSBOnly:                       ld		l,h									    ; now move results into lower byte so / 256
                                    ld		e,d									    ; for both results
                                    xor		a									    ;
                                    ld		h,a									    ;
                                    ld		d,a									    ; so set high byte to 0
                                    MMUSelectMathsBankedFns
                                    call	ADDHLDESignBC                           ;  XX12ProcessCalcHLPlusDESignBC		; returns with HL = result1 + result 2 signed in a 
                                    ld		b,a									    ; move sign into b ready for next calc
                                    ld		a,(XX12PVarSign3)					    ; result of the calcZ cell
                                    ld		c,a									    ; goes into c to align with DE
                                    ld		de,(XX12PVarResult3)				    ; now add result to Result 3
                                    ld		e,d                                     ; d = result /256
                                    ld		d,0									    ; and only us high byte
                                    MMUSelectMathsBankedFns
                                    call	ADDHLDESignBC; XX12ProcessCalcHLPlusDESignBC		; returns with HL = result and a = sign
                                    ret											    ; hl = result, a = sign
								    ; hl = result, a = sign

; .LL51	\ -> &4832 \ XX12=XX15.XX16  each vector is 16-bit x,y,z **** ACTUALLY XX16 is value in low sign bit in high
;...X cell
p?_XX12EquNodeDotTransMat:    ld		hl,p?_BnkTransInvRow0x0     			; process orientation matrix row 0
                                    call    XX12ProcessOneRow                   ; hl = result, a = sign
                                    ld		b,a                                 ; b = sign
                                    ld		a,h                                 ; a = high byte
                                    or		b
                                    ld		(p?_BnkXX12xSign),a					; a = result with sign in bit 7
                                    ld		a,l                                 ; the result will be in the lower byte now
                                    ld      (p?_BnkXX12xLo),a						; that is result done for
;...Y cell
                                    ld		hl,p?_BnkTransInvRow1y0     			; process orientation matrix row 1
                                    call    XX12ProcessOneRow
                                    ld		b,a
                                    ld		a,h
;		ld		a,l
                                    or		b
                                    ld		(p?_BnkXX12ySign),a					; a = result with sign in bit 7
                                    ld		a,l                                 ; the result will be in the lower byte now
                                    ld      (p?_BnkXX12yLo),a						; that is result done for
;...Z cell
                                    ld		hl,p?_BnkTransInvRow2z0     			; process orientation matrix row 1
                                    call    XX12ProcessOneRow
                                    ld		b,a
                                    ld		a,h
;		ld		a,l
                                    or		b
                                    ld		(p?_BnkXX12zSign),a					; a = result with sign in bit 7
                                    ld		a,l                                 ; the result will be in the lower byte now
                                    ld      (p?_BnkXX12zLo),a						; that is result done for
                                    ret

; .LL51	\ -> &4832 \ XX12=XX15.XX16  each vector is 16-bit x,y,z **** ACTUALLY XX16 is value in low sign bit in high
p?_XX12EquNodeDotOrientation: ld		hl,p?_BnkTransInvRow0x0     			; process orientation matrix row 0
;...X cell
                                    call    p?_XX12ProcessOneRow                   ; hl = result, a = sign
                                    ld		b,a                                 ; b = sign
                                    ld		a,h                                 ; a = high byte
                                    or		b
                                    ld		(p?_BnkXX12xSign),a					; a = result with sign in bit 7
                                    ld		a,l                                 ; the result will be in the lower byte now
                                    ld      (p?_BnkXX12xLo),a						; that is result done for
;...Y cell
                                    ld		hl,p?_BnkTransInvRow1y0     			; process orientation matrix row 1
                                    call    p?_XX12ProcessOneRow
                                    ld		b,a
                                    ld		a,h
                        ;		ld		a,l
                                    or		b
                                    ld		(p?_BnkXX12ySign),a					; a = result with sign in bit 7
                                    ld		a,l                                 ; the result will be in the lower byte now
                                    ld      (p?_BnkXX12yLo),a						; that is result done for
                        ;...Z cell
                                    ld		hl,p?_BnkTransInvRow2z0     			; process orientation matrix row 1
                                    call    p?_XX12ProcessOneRow
                                    ld		b,a
                                    ld		a,h
                        ;		ld		a,l
                                    or		b
                                    ld		(p?_BnkXX12zSign),a					; a = result with sign in bit 7
                                    ld		a,l                                 ; the result will be in the lower byte now
                                    ld      (p?_BnkXX12zLo),a						; that is result done for
                                    ret

; .LL51	\ -> &4832 \ XX12=XX15.XX16  each vector is 16-bit x,y,z **** ACTUALLY XX16 is value in low sign bit in high
p?_XX12EquNodeDotXX16:
;...X cell                          
                                    ld		hl,p?_BnkTransmatSidevX     			; process orientation matrix row 0
                                    call    p?_XX12ProcessOneRow                   ; hl = result, a = sign
                                    ld		b,a                                 ; b = sign
                                    ld		a,h                                 ; a = high byte
                                    or		b
                                    ld		(p?_BnkXX12xSign),a					; a = result with sign in bit 7
                                    ld		a,l                                 ; the result will be in the lower byte now
                                    ld      (p?_BnkXX12xLo),a						; that is result done for
;...Y cell
                                    ld		hl,p?_BnkTransmatRoofvX     			; process orientation matrix row 1
                                    call    p?_XX12ProcessOneRow
                                    ld		b,a
                                    ld		a,h
;		ld		a,l
                                    or		b
                                    ld		(p?_BnkXX12ySign),a					; a = result with sign in bit 7
                                    ld		a,l                                 ; the result will be in the lower byte now
                                    ld      (p?_BnkXX12yLo),a						; that is result done for
;...Z cell
                                    ld		hl,p?_BnkTransmatNosevX     			; process orientation matrix row 1
                                    call    p?_XX12ProcessOneRow
                                    ld		b,a
                                    ld		a,h
;		ld		a,l
                                    or		b
                                    ld		(p?_BnkXX12zSign),a					; a = result with sign in bit 7
                                    ld		a,l                                 ; the result will be in the lower byte now
                                    ld      (p?_BnkXX12zLo),a						; that is result done for
                                    ret       
                                    ENDM
                                    