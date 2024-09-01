
BCDIVDE_MACRO:      MACRO 
                    rla
                    adc	    hl,hl
                    add	    hl,de
                    jr	    c,.NoSubtract
                    sbc	    hl,de
.NoSubtract:				    
                    ENDM

HLDIVC_MACRO: 	    MACRO
                    add	    hl,hl		; unroll 16 times
                    rla				; ...
                    jr      c,      .DoSubInc
                    cp	    c			; ...
                    jr      c,      .NoSubInc
.DoSubInc:          sub	c			; ...			
                    inc	l			; ...
.NoSubInc:                    
                    ENDM
                        
DDIVIDEE_MACRO:     MACRO
                    rl      e
                    rla
                    sub     c
                    jr      nc,.NoAdd
                    add     a,c
.NoAdd:        
                    ENDM                             

; TO ADD

; Perform BHL = BHL/CDE generally the result will be 0HL but we have to provision for extreme results
; the division will at most be 16/16 but optimised for 16/8 and 8/8. If we get 8/16 that is always 0
BHLequBHLdivCDEu:        
; Check for divide by 0
.checkDiv0:         ld      a,c
                    or      d
                    or      e
                    jp      z,.divideByZero
                    ld      iyl,0           ; set up counter in iyl
                    ld      a,l
; Check for 0 divided by value
.check0Div:         ld      a,b
                    or      h
                    or      l
                    jp      z,.resultIsZero
; Bit shift to retain accuracy at this point we are gauranteed that BHL and CDE are both != 0 so we don't have to worry about infinite shifts
.ShiftLoop:         ld      a,b
                    or      c
                    and     %01000000       ; once we get to 7th bit of B then we are good
                    jp      nz,.DoneShift
                    ShiftBHLLeft1
                    ShiftCDELeft1
                    inc     iyl
                    jp      .ShiftLoop
.DoneShift:                    
.CheckFor8BitDivide:ld      a,h             ; if H and D are zero then we can just do 8 bit divide
                    or      c
                    jp      z, SetupDdivE
.CheckFor16Div8:    ld      a,c             ; now at least one of H and D are non zero so can we do 16 bit divide 8 bit
                    and     a
                    jp      z, SetupHLDivC
.CheckFor8Div16:    ld      a,h             ; so if we are divding 8 bit by 16 bit its always 0
                    and     a               ; we we set it to 0x00.0x01 or 0.00390625 
                    jp      nz, SetupBCdivDE; so its definitly 16/16 divide
.ResultIsTooLow:    ZeroA                   ; clears carry flag and makes loading b quicker
                    ld      b,a             ; load bhl with 0x00001 in 16 t states
                    ld      h,a             ;
                    ld      l,a             ;
                    inc     l               ;
                    ret
.divideByZero:      ZeroA                   ; Sets carry to mark failure
                    dec     a
                    ld      b,a             ; load bhl with 0xFFFFFF in 16 t states
                    ld      h,a             ;
                    ld      l,a             ;
                    SetCarryFlag
                    ret
.resultIsZero:      ZeroA 
                    ld      b,a             ; load bhl with 0x00001 in 16 t states
                    ld      h,a             ;
                    ld      l,a             ;
                    ret                   
; now we have interested values in BH and CD so move them into BC and DE                    
SetupBCdivDE:       ld      e,d             ; set up DE by moving CD there
                    ld      d,c             ; .
                    ld      c,h             ; b is already set so just do C to get BC
; BE = BC = BC / DE. HL = remainder fast divide with unrolled loop"
BHLequBCdivDE:      ZeroA
                    ld      h,a
                    ld      l,a
                    sub     e
                    ld      e,a
                    sbc     a,a
                    sub     d
                    ld      d,a
                    ld      a,b
counter = 0
                WHILE counter < 8 , 8
                    BCDIVDE_MACRO
counter = counter + 1  
                ENDW                    
                    rla
                    ld      b,a
                    ld      a,c
counter = 0
                WHILE counter < 8 , 8
                    BCDIVDE_MACRO
counter = counter + 1  
                ENDW 
                    rla
                    ld      l,a             ; now load into BHL
                    ld      h,b             ;
                    ld      b,0             ;
                    ClearCarryFlag
                    ret	                    
; bc and de hold values to move into correct registers so we need to move to hl and c to optimise loops           
SetupHLDivC:        ld      hl,bc
                    ld      c,e
BHLEquHLdivC:       ZeroA
counter=0
                WHILE counter < 16 , 16
                    HLDIVC_MACRO
counter = counter + 1                    
                ENDW
                    ld      b,0             ; now we have BHL as result
                    ClearCarryFlag
                    ret
SetupDdivE:        
; Performs BC = D / E, B will always be zero we don't care about remainder
; we have BC/DE prepped so we can just move tehm
BCequDdivE:         ZeroA
                    ld      h,a             ; bh is always 0
                    ld      b,a             ;
counter = 0
                WHILE counter < 16 , 16
                    DDIVIDEE_MACRO
counter = counter + 1  
                ENDW
                    ld      a,e             ; e = result, so *2 and compliment to get actual result
                    rla
                    cpl
                    ld      l,a             ; sets up bhl to return
                    ClearCarryFlag                    
                    ret

; performsn BHL/CDE signed, in which case we take signs, load then into iy do unsigned divide and recover sign                    
BHLequBHLdivCDEs:   ld      a,b
                    xor     c
                    and     $80
                    ld      iyl,a           ; save resultant sign
                    call    BHLequBHLdivCDEu
                    ld      a,b
                    or      iyl
                    ld      b,a             ; now bhl = S15.8 value
                    ret

; performs (256*B)/C i.e. HL/C or B0/C unsigned
BHLequ256mulBdivCu: ld      h,b             ; now hl = B*256 or B0
                    ld      l,0             ; as c is already loaded we can just jp to divide
                    jp      BHLEquHLdivC    ; b will always result in 0
                    
                    
                    
                    

   ; unsigned division of 24-bit number by 16-bit number
   ;
   ; enter : ehl = 24-bit dividend
   ;          bc = 16-bit divisor
   ;
   ; exit  : success
   ;
   ;            ahl = ehl / bc
   ;             de = ehl % bc
   ;            carry reset
   ;
   ;         divide by zero
   ;
   ;            ahl = $fffff = UINT_MAX
   ;            cde = dividend
   ;            carry set, errno = EDOM
   ;
   ; uses  : af, bc, de, hl

   ; test for divide by zero will be doen outside the call
; to get to here it must be 24x16 
l_fast_divu_24_24x16:
   ; ehl >= $ 01 00 00 bc >= $    01 00
   ;
   ; this means the results of the first eight iterations of the division loop are known
   ;
   ; inside the loop the computation is ac[b] / de, hl = remainder so initialize as if eight iterations done
                        ld d,b
                        ld a,e
                        ld e,c
                        ld c,l
                        ld l,a
                        ld a,h
                        ld h,0            
                        ; unroll divide eight times

                        ld b,2
                        ; eliminating leading zeroes

                        rl c
                        rla
                        adc hl,hl
                        inc h
                        dec h
                        jp nz, loop2416_00
                        
                        rl c
                        inc c
                        rla
                        adc hl,hl
                        inc h
                        dec h
                        jp nz, loop2416_11
                        
                        rl c
                        inc c
                        rla
                        adc hl,hl
                        inc h
                        dec h
                        jp nz, loop2416_22
                        
                        rl c
                        inc c
                        rla
                        adc hl,hl
                        inc h
                        dec h
                        jp nz, loop2416_33
                        
                        rl c
                        inc c
                        rla
                        adc hl,hl
                        inc h
                        dec h
                        jp nz, loop2416_44
                        
                        rl c
                        inc c
                        rla
                        adc hl,hl
                        inc h
                        dec h
                        jp nz, loop2416_55   
                        
                        rl c
                        inc c
                        rla
                        adc hl,hl
                        inc h
                        dec h
                        jp nz, loop2416_66
                        
                        scf
                        jp loop2416_7
                        ; general divide loop
loop2416_0:                 rl c
                        rla
                        adc hl,hl
                        jr c, loop2416_000

loop2416_00:                sbc hl,de
                        jr nc, loop2416_1
                        add hl,de

loop2416_1:                 rl c
                        rla
                        adc hl,hl
                        jr c, loop2416_111

loop2416_11:            sbc hl,de
                        jr nc, loop2416_2
                        add hl,de

loop2416_2:                 rl c
                        rla
                        adc hl,hl
                        jr c, loop2416_222

loop2416_22:                sbc hl,de
                        jr nc, loop2416_3
                        add hl,de

loop2416_3:                 rl c
                        rla
                        adc hl,hl
                        jr c, loop2416_333

loop2416_33:                sbc hl,de
                        jr nc, loop2416_4
                        add hl,de

loop2416_4:                 rl c
                        rla
                        adc hl,hl
                        jr c, loop2416_444

loop2416_44:                sbc hl,de
                        jr nc, loop2416_5
                        add hl,de

loop2416_5:                 rl c
                        rla
                        adc hl,hl
                        jr c, loop2416_555

loop2416_55:                sbc hl,de
                        jr nc, loop2416_6
                        add hl,de

loop2416_6:                 rl c
                        rla
                        adc hl,hl
                        jr c, loop2416_666

loop2416_66:                sbc hl,de
                        jr nc, loop2416_7
                        add hl,de

loop2416_7:                 rl c
                        rla
                        adc hl,hl
                        jr c, loop2416_777

loop2416_77:                sbc hl,de
                        jr nc, loop2416_8
                        add hl,de

loop2416_8:                 djnz loop2416_0
   
exit_loop:              rl c
                        rla
                        ; ac = ~quotient, hl = remainder
                        ex de,hl
                        cpl
                        ld h,a
                        ld a,c
                        cpl
                        xor a
                        ret
loop2416_000:               or a
                        sbc hl,de
                        or a
                        jp loop2416_1
loop2416_111:               or a
                        sbc hl,de
                        or a
                        jp loop2416_2
loop2416_222:               or a
                        sbc hl,de
                        or a
                        jp loop2416_3
loop2416_333:               or a
                        sbc hl,de
                        or a
                        jp loop2416_4
loop2416_444:               or a
                        sbc hl,de
                        or a
                        jp loop2416_5
loop2416_555:               or a
                        sbc hl,de
                        or a
                        jp loop2416_6
loop2416_666:               or a
                        sbc hl,de
                        or a
                        jp loop2416_7
loop2416_777:               or a
                        sbc hl,de
                        or a
                        jp loop2416_8
;