; AHL = BHL + CDE, 24 bit lead sign (S15.8: bit 7 of B/C is the sign, the other 23 bits the magnitude).
; Same signs add the magnitudes (the sign in bit 7 of B carries through), opposite signs subtract the smaller
; magnitude from the larger and take that operand's sign. Never returns -0, overflow is not detected.
; Destroys C and DE.
AHLequBHLplusCDE:       ld      a,b
                        xor     c
                        jp      m,.Opposite
.SameSign:              add     hl,de                   ; |B| + |C| + carry, B keeps the common sign in bit 7
                        res     7,c
                        ld      a,b
                        adc     a,c
                        ret
.Opposite:              res     7,c                     ; c = |C|
                        ld      a,b
                        and     $7F                     ; a = |B|, and clears carry for the subtract
                        sbc     hl,de                   ; |BHL| - |CDE|
                        sbc     a,c
                        jr      c,.Flip                 ; |CDE| was the larger
                        ld      c,a                     ; |BHL| >= |CDE|: result takes B's sign unless it is 0
                        or      h
                        or      l
                        ld      a,c
                        ret     z
                        bit     7,b
                        ret     z
                        or      $80
                        ret
.Flip:                  ld      c,a                     ; negate the 24 bit borrow, result takes C's sign (not B's)
                        xor     a
                        sub     l
                        ld      l,a
                        ld      a,0
                        sbc     a,h
                        ld      h,a
                        ld      a,0
                        sbc     a,c
                        bit     7,b
                        ret     nz
                        or      $80
                        ret

; HL = HL + DE, S7.8 lead sign. Same signs add the magnitudes, opposite signs subtract the smaller from the larger.
; Never returns -0, overflow is not detected. Destroys A and DE.
HLequHLplusDE:          ld      a,h
                        xor     d
                        jp      m,.Opposite
.SameSign:              res     7,d                     ; h keeps the common sign in bit 7
                        add     hl,de
                        ret
.Opposite:              ld      a,h                     ; a keeps HL's sign
                        res     7,h
                        res     7,d
                        or      a
                        sbc     hl,de                   ; |HL| - |DE|
                        jr      c,.Flip
                        ret     z                       ; equal magnitudes give +0
                        and     $80
                        or      h
                        ld      h,a
                        ret
.Flip:                  ex      de,hl                   ; |DE| - |HL| = 0 - (|HL| - |DE|)
                        ld      hl,0
                        ccf                             ; carry is set from the borrow
                        sbc     hl,de
                        xor     $80                     ; result takes DE's sign
                        and     $80
                        or      h
                        ld      h,a
                        ret

; HL = HL - DE, S7.8 lead sign: flip the sign of DE and add
HLequHLminusDE:         ld      a,d
                        xor     $80
                        ld      d,a
                        jp      HLequHLplusDE

;;-;-- Addition---------------------------------------------------
;;-; BAHL = BHL+CDE Lead Sign bit - If overflows AHL then carry will be set resulting in B holding sign and rest of value, else AHL holds value
;;-; in reality will we aim for all values being S14.8 so bit 15 is always clear for overflow
;;-AHLequBHLplusCDEX:       ld      a,b                          ; if b sign and c sign were different then bit 7 of a will be 1 which means
;;-                        and     $80                          ; Signs are opposite there fore we can subtract to get difference
;;-                        xor     c                            ;
;;-                        JumpIfNegative .OppositeSigns        ;
;;-.SameSigns:             ld      a,b                          ; if they are both negative
;;-                        or      c                            ; then we can do an add but also set the sign bit
;;-                        JumpIfNegative .BothNegative         ; optimisation so we can just do simple add if both positive
;;-                        ;-------Perform Both Positive Add ----
;;-.BothPositive:          adc     hl,de                        ; both positive so a will already be zero, OR will hnave cleared carry
;;-                        ld      a,b                          ; a = b + c + an carry from HL + DE
;;-                        adc     c                            ;
;;-                        ret     nc                           ; if there was no carry then we are good
;;-                        ;-------Done Both Positive Add -------
;;-.OverFlowPositive:      ld      b,1                          ; if we overflow from +BHL +  +CDE then we already have sign cleared in A and only 1 bit to roll into B + no sign bit
;;-                        ret
;;-                        ;-------Perform Both Negative Add ----
;;-.BothNegative:          res     7,b                          ; clear sign bits for both values
;;-                        res     7,c                          ; .
;;-                        adc     hl,de                        ; now behave like they are both positive
;;-                        ld      a,b
;;-                        adc     c
;;-                        jp      c,.OverFlowNegative          ; if there was carry we need to overflow into b
;;-                        or      %10000000                    ; set bit 7 of A for negative
;;-                        ret
;;-                        ;-------Done Both Negative Add -------
;;-.OverFlowNegative:      ld      b,%10000001                  ; carry over the bit but also set the sign bit
;;-                        ret
;;-.OppositeSigns:         bit     7,b                          ; if BHL was negative then CDE is positive
;;-                        jp      nz,.CDEMinusBHL              ; so perform CDE - BHL
;;-                        ;-------Prep BHL - CDE (CDE -ve)------
;;-.BHLMinusCDE:           res     7,c                          ; we have just one subtract routine 
;;-                        ex      hl,de                        ; so we swap registers and just treat it as CDE-BHL
;;-                        ld      a,b                          ; and we have to use a when swapping b and c
;;-                        ld      b,c                          ; .
;;-                        ld      c,a                          ; .
;;-                        ;-------Perform CDE - BHL (BHL -ve)---
;;-.CDEMinusBHL:           res     7,b                          ; B is now ABS (B) 
;;-                        ClearCarryFlag                       ; now its just common CDE-BHL
;;-                        ex      hl,de                        ; hl = de-hl by swapping them round
;;-                        sbc     hl,de                        ; 
;;-                        ld      a,c                          ; a= c - b
;;-                        sbc     b                            ; now AHL is result
;;-                        ret     nc                           ; if there was no carry then we are good and it didn't end up 2's c
;;-.CDEFlipSign:           NegAHL                               ; as CDE-BHL became negative we make result lead sign negativce
;;-                        or      %10000000                    ; flip the lead bit of A
;;-                        ret

; AHL = BHL-CDE Lead Sign bit
AHLequBHLminusCDE:      ld      a,c
                        xor     %10000000
                        ld      c,a
                        jp      AHLequBHLplusCDE
 
subHLDES15:             bit     7,h                         ; for lead sign subtract
                        jp      z,.doneHL                   ; we convert to 2s compliment
                        res     7,h
                        NegHL                               ; .               
.doneHL:                bit     7,d                         ; .
                        jp      z,.doneDE                   ; .
                        res     7,d
                        NegDE                               ; .
.doneDE:                ClearCarryFlag                      ; then perform a regular subtract
                        sbc     hl,de                       ; .
                        bit     7,h                         ; and finish off with converting to lead sign if needed
                        ret     z                           ; .
                        NegHL                               ; .
                        set     7,h                         ; .
                        ret

addHLDES15:             bit     7,h                         ; for lead sign subtract
                        jp      z,.doneHL                   ; we convert to 2s compliment
                        res     7,h
                        NegHL                               ; .               
.doneHL:                bit     7,d                         ; .
                        jp      z,.doneDE                   ; .
                        res     7,d
                        NegDE                               ; .
.doneDE:                ClearCarryFlag                      ; then perform a regular subtract
                        add     hl,de                       ; .
                        bit     7,h                         ; and finish off with converting to lead sign if needed
                        ret     z                           ; .
                        NegHL                               ; .
                        set     7,h                         ; .
                        ret
 
;------------------------------------------------------------
; extension to AddBCHtoDELsigned
; takes ix as the address of the values to load into DEL
;       iy as the address of the values to load into BCH
AddAtIXtoAtIY24Signed:  ld      l,(ix+0)            ; del = ix (sign hi lo)
                        ld      e,(ix+1)            ; .
                        ld      d,(ix+2)            ; .
                        ld      h,(iy+0)            ; bch = iy (sign, hi, lo)
                        ld      c,(iy+1)            ; .
                        ld      b,(iy+2)            ; .
                        push    iy                  ; save iy as add function changes is
                        call    AddBCHtoDELsigned   ; Perform del += bch
                        pop     iy                  ; get iy back
                        ld      (ix+0),l            ; put result into (ix)
                        ld      (ix+1),e            ; .
                        ld      (ix+2),d            ; .
                        ret                       
;------------------------------------------------------------
; extension to AddBCHtoDELsigned
; takes ix as the address of the values to load into DEL
;       iy as the address of the values to load into BCH
; subtracts iy from ix leaving result in del
SubDELequAtIXMinusAtIY24Signed:
                        ld      l,(ix+0)            ; del = ix (sign hi lo)
                        ld      e,(ix+1)            ; .
                        ld      d,(ix+2)            ; .
                        ld      h,(iy+0)            ; bch = -iy (sign, hi, lo)
                        ld      c,(iy+1)            ; .
                        ld      a,(iy+2)            ; .
                        xor     SignOnly8Bit        ; . this is where we flip sign to make add subtract
                        ld      b,a                 ; .
                        push    iy                  ; save iy as add function changes is
                        call    AddBCHtoDELsigned   ; perform del += bch which as we flipped bch sign means (ix [210] -= iy [210])
                        pop     iy                  ; get iy back
                        ret
;------------------------------------------------------------
;tested mathstestsun2
; DEL = DEL - BCH signed, uses BC, DE, HL, A (IY kept)
; Just flips sign on b then performs add
SubBCHfromDELsigned:    ld      a,b
                        xor     SignOnly8Bit
                        ld      b,a
; DEL = DEL + BCH signed, uses BC, DE, HL, A; IY is kept. It used IYH and IYL for the signs, and ApplyShipSpeed (and
; CalcLaunchOffset) keep the speed in IYL across it: with the x position and movement of opposite signs the y and z
; steps then used the position's sign byte as the speed, so ships stopped on y and z or, with bit 7 set, jumped
; (Tools/test_docking.py test_ship_speed_moves_every_axis)
AddBCHtoDELsigned:      push    iy
                        call    AddBCHtoDELsignedIY
                        pop     iy
                        ret
AddBCHtoDELsignedIY:    ld      a,b                 ; Are the values both the same sign?
                        xor     d                   ; .
                        and     SignOnly8Bit        ; .
                        jr      nz,.SignDifferent   ; .
.SignSame:              ld      a,b                 ; if they are then we only need 1 signe
                        and     SignOnly8Bit        ; so store it in iyh
                        ld      iyh,a               ;
                        ld      a,b                 ; bch = abs bch
                        and     SignMask8Bit        ; .
                        ld      b,a                 ; .
                        ld      a,d                 ; del = abs del
                        and     SignMask8Bit        ; .
                        ld      d,a                 ; .
                        ld      a,h                 ; l = h + l
                        add     l                   ; .
                        ld      l,a                 ; . 
                        ld      a,c                 ; e = e + c + carry
                        adc     e                   ; .
                        ld      e,a                 ; .
                        ld      a,b                 ; d = b + d + carry (signed)
                        adc     d                   ; 
                        or      iyh                 ; d = or back in sign bit
                        ld      d,a                 ; 
                        ret                         ; done
.SignDifferent:         ld      a,b                 ; bch = abs bch
                        ld      iyh,a               ; iyh = b sign
                        and     SignMask8Bit        ; .
                        ld      b,a                 ; .
                        ld      a,d                 ; del = abs del
                        ld      iyl,a               ; iyl = d sign
                        and     SignMask8Bit        ; .
                        ld      d,a                 ; .
                        push    hl                  ; save hl
                        ld      hl,bc               ; hl = bc - de, if bc < de then there is a carry
                        sbc     hl,de               ;
                        pop     hl                  ;
                        jr      c,.BCHltDEL
                        jr      nz,.DELltBCH        ; if the result was not zero then DEL > BCH
.BCeqDE:                ld      a,h                 ; if the result was zero then check lowest bits
                        JumpIfALTNusng l,.BCHltDEL
                        jr      nz,.DELltBCH
; The same so its just zero
.BCHeqDEL:              xor     a                  ; its just zero
                        ld      d,a                ; .
                        ld      e,a                ; .
                        ld      l,a                ; .
                        ret                        ; .
;BCH is less than DEL so its DEL - BCH the sort out sign
.BCHltDEL:              ld      a,l                ; l = l - h                      ; ex
                        sub     h                  ; .                              ;   01D70F DEL
                        ld      l,a                ; .                              ;  -000028 BCH
                        ld      a,e                ; e = e - c - carry              ;1. 
                        sbc     c                  ; .                              ;
                        ld      e,a                ; .                              ;
                        ld      a,d                ; d = d - b - carry              ;
                        sbc     b                  ; .                              ;
                        ld      d,a                ; .                              ;
                        ld      a,iyl              ; as d was larger, take d sign
                        and     SignOnly8Bit       ;
                        or      d                  ;
                        ld      d,a                ;
                        ret
.DELltBCH:              ld      a,h                ; l = h - l
                        sub     l                  ;
                        ld      l,a                ;
                        ld      a,c                ; e = c - e - carry
                        sbc     e                  ;
                        ld      e,a                ;
                        ld      a,b                ; d = b - d - carry
                        sbc     d                  ;
                        ld      d,a                ;
                        ld      a,iyh              ; as b was larger, take b sign into d
                        and     SignOnly8Bit       ;
                        or      d                  ;
                        ld      d,a                ;
                        ret 