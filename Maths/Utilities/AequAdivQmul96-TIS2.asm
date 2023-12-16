AequAdivQmul96ABS:      JumpIfAGTENusng d, .TIS2AccGTEQ			; if A >= Q then return with a 1 (unity i.e. 96) with the correct sign
                        ld			b,$FE						; division roll (replaced varT)
.TIS2RollTLoop:			sla			a		
                        JumpIfALTNusng d,.TIS2SkipSub           ; a < d so don;t subtract
                        sbc			a,d							; do subtraction with carry
                        scf
                        rl			b							; T rolled left to push bit out the end
                        jr			c,.TIS2RollTLoop				; if we still have not hit the empty marker continue
.TIS2SKIPCont:	        ld			a,b							; T
                        srl			a							; result / 2
                        srl			a							; result / 4
                        ld			b,a							; t = t /4
                        srl			a							; result / 8
                        add			a,b							; result /8 + result /4
                        ret
.TIS2AccGTEQ:           ld			a,$60							; unity
                        ret
.TIS2SkipSub:           or			a
                        rl			b							; T rolled left to push bit out the end
                        jr			c,.TIS2RollTLoop				; if we still have not hit the empty marker continue
                        jp			.TIS2SKIPCont
	
    
; USES 			A DE BC
; DOES NOT USE 	HL
TIS2962C:		; two's compliment entry point, exits not 2's compliment
	bit			        7,a
	jr			        z,AequAdivQmul96
	neg			        							; revers 2s'c and just set neg bit
	set			        7,a
; Note negative numbers are bit 7 set not 2's compliment
AequAdivQmul96:								; TIS296:			; .tis2 A = A /Q *96 (or A = A * 3/8 * Q) Reduce Acc in NORM routine i.e. *96/Q clamps at +- 96
TIS2:
                        ld			c,a							; copy of Acc
                        ld			a,(varQ)
                        ld			d,a							; d = varQ
                        ld			a,c							; recover a
AequAdivDmul967Bit:     ld          c,a
                        ld          a,d 
                        sla         a       ; wipe sign bit
                        ret         z       ; quick exit if dividing 0 as a will have the result of 0
                        jr          nc, .OKToDivide
.ScaleDown:             or          a       ; clear carry bit
                        srl         d       ; d >> 1 to get back to 7 bit value
                        ld          a,c
                        and         SignMask8Bit
                        srl         a
                        ld          b,a
                        ld          a,c
                        and         $80
                        or          b
                        jp          AequAdivDmul96
.OKToDivide:            ld          a,c
AequAdivDmul96:         ld			c,a							; copy of Acc as we need the sign, alternate entry point assuming D preloaded, wastes an "ld c,a" but simplifies code
                        and			SignMask8Bit				; ignore sign
                        JumpIfAGTENusng d, .TIS2AccGTEQ			; if A >= Q then return with a 1 (unity i.e. 96) with the correct sign
                        ld			b,$FE						; division roll (replaced varT)
.TIS2RollTLoop:									; .TIL2	; roll T
                        sla			a		
                        JumpIfALTNusng d,.TIS2SkipSub           ; a < d so don;t subtract
                        sbc			a,d							; do subtraction with carry
                        scf                                     ; set carrry to roll into b
                        rl			b							; T rolled left to push bit out the end
                        jr			c,.TIS2RollTLoop			; if we still have not hit the empty marker continue
.TIS2SKIPCont:	        ld			a,b							; A = T = 4 / 4
                        srl			a							; .
                        srl			a							; .
                        ld			b,a							; .
                        srl			a							; A = A / 2 (i.e. T /8)
                        add			a,b							; A = T/8 + T/4 (3T/8)
                        ld			b,a							; b = 3/8*Acc (max = 96)
                        ld			a,c							; copy of Acc to look at sign bit
                        and			$80							; recover sign only
                        or			b							; now put b back in so we have a leading sign bit (note not 2's compliment)
                        ret
;TI4:										;\ clean to +/- unity
.TIS2AccGTEQ:           ld			a,c
                        and			$80							; copy of Acc
                        or			$60							; unity
                        ret
.TIS2SkipSub:           ClearCarryFlag                          ; Clear carry as it needs to be empty to roll in 0
                        rl			b							; T rolled left to push bit out the end
                        jr			c,.TIS2RollTLoop			; if we still have not hit the empty marker continue
                        jp			.TIS2SKIPCont



; as per AequAdivDmul967Bit but Q is an 8 bit unsigned 
; a = a(S7)/Q(8u)*96
AequAdivDmul96Q8:       ld          c,a                         ; c = a
.CheckDivide0:          ld          a,d                         ; check if its a / 0
                        and         a                           ; .
                        jp          z,.TIS2AccGTEQ              ; .
.NotDivide0:            ld          a,c                         ; get back value of A
                        and         SignMask8Bit                ; and make it abs, so a = abs(a) c = original a
                        JumpIfAGTENusng d, .TIS2AccGTEQ			; if A >= Q then return with a 1 (unity i.e. 96) with the correct sign
                        ld			b,$FE						; division roll (replaced varT)
.TIS2RollTLoop:									; .TIL2	; roll T
                        sla			a		
                        JumpIfALTNusng d,.TIS2SkipSub           ; a < d so don;t subtract
                        sbc			a,d							; do subtraction with carry
                        scf                                     ; set carrry to roll into b
                        rl			b							; T rolled left to push bit out the end
                        jr			c,.TIS2RollTLoop			; if we still have not hit the empty marker continue
.TIS2SKIPCont:	        ld			a,b							; A = T = 4 / 4
                        srl			a							; .
                        srl			a							; .
                        ld			b,a							; .
                        srl			a							; A = A / 2 (i.e. T /8)
                        add			a,b							; A = T/8 + T/4 (3T/8)
                        ld			b,a							; b = 3/8*Acc (max = 96)
                        ld			a,c							; copy of Acc to look at sign bit
                        and			SignOnly8Bit    			; recover sign only
                        or			b							; now put b back in so we have a leading sign bit (note not 2's compliment)
                        ret
;TI4:										;\ clean to +/- unity
.TIS2AccGTEQ:           ld			a,c
                        and			$80							; copy of Acc
                        or			$60							; unity
                        ret
.TIS2SkipSub:           ClearCarryFlag                          ; Clear carry as it needs to be empty to roll in 0
                        rl			b							; T rolled left to push bit out the end
                        jr			c,.TIS2RollTLoop			; if we still have not hit the empty marker continue
                        jp			.TIS2SKIPCont
                            
		