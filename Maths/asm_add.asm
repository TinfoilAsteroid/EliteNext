;; calcs BHB + CDE where B and C are signs and may be 24 bit
;; result HL with A as sign
;; special handling if result is zero forcign sign bit to be zero

;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLSAHLEquBHLaddCDE:        ld      a,b
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        xor     c
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        and     SignOnly8Bit
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        JumpIfNegative   .OppositeSigns
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS.SameSigns:             ld      ixh,b                      ; ixh = b
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        ClearSignBit b                     ; b = ABS b
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        add     hl,de                      ; hl = hl + de
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        ld      a,b                        ; a = b + c + carry
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        adc     c                          ; 
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        ld      b,a                        ; 
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        ld      a,ixh                      ; 
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        SignBitOnlyA                       ; 
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        or      b                          ; 
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        ret                                ; 
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS.OppositeSigns:         ld      ixh,b                      ; save signed into ixh and ixl
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        ld      ixl,c                      ; .
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        ClearSignBit c                     ; c = ABS C
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        ld      a,b                        ; a = abs b
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        ClearSignBitA                      ; .
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        sbc     c                          ; a = a - c
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        JumpIfNegative  .OppositeCDEgtBHL  ; if c is positive
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        push    hl
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        sbc     hl,de                      ; then subtract de from hl
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        JumpIfNegative  .HLDEWasNegative   ; if sub was positive
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        pop     de                         ; at this stage the stack is just junk
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        ld      b,a                        ; then copy results to AHL
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        ld      a,ixh                      ; by just handling sign 
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        SignBitOnlyA                       ; .
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        or      b                          ; .
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        ret                                ; .
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS.OppositeCDEgtBHL:      ex      de,hl                      ; save hl
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        ld      c,ixh                      ; swap signs over
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        ld      b,ixl                      ;
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        jp      .OppositeSigns             ; and do calc again
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS.HLDEWasNegative:       pop     hl                         ; get back hl swap values and try again
;DOES NOT WORK IF SIGNED RPLACE WITH ADDBCHTODELSIGNED CALLS                        jp      .OppositeCDEgtBHL
; example
; bhl - 00 00 06 CDE - 80 00 0B so equates to 000006 + (-00000B) or -000005 or 800005
                        
ADDHLDESignBC:          ld      a,b
                        and     SignOnly8Bit
                        xor     c                           ;if b sign and c sign were different then bit 7 of a will be 1 which means 
                        JumpIfNegative ADDHLDEsBCOppSGN     ;Signs are opposite there fore we can subtract to get difference
ADDHLDEsBCSameSigns:    ld      a,b
                        or      c
                        JumpIfNegative ADDHLDEsBCSameNeg    ; optimisation so we can just do simple add if both positive
                        add     hl,de                       ; both positive so a will already be zero
                        ret
ADDHLDEsBCSameNeg:      add     hl,de
                        ld      a,b
                        or      c                           ; now set bit for negative value, we won't bother with overflow for now TODO
                        ret
ADDHLDEsBCOppSGN:       ClearCarryFlag
                        sbc     hl,de
                        jr      c,ADDHLDEsBCOppInvert
ADDHLDEsBCOppSGNNoCarry:ld      a,b                         ; we got here so hl > de therefore we can just take hl's previous sign bit
                        ret
ADDHLDEsBCOppInvert:    NegHL                               ; if result was zero then set sign to zero (which doing h or l will give us for free)
                        ld      a,b
                        xor     SignOnly8Bit                ; flip sign bit
                        ret   

ADDHLDESignedV4:        ld      a,h
                        and     SignOnly8Bit
                        ld      b,a                         ;save sign bit in b
                        xor     d                           ;if h sign and d sign were different then bit 7 of a will be 1 which means 
                        JumpIfNegative .ADDHLDEOppSGN       ;Signs are opposite there fore we can subtract to get difference
.ADDHLDESameSigns:      ld      a,b
                        or      d
                        JumpIfNegative .ADDHLDESameNeg      ; optimisation so we can just do simple add if both positive
                        add     hl,de
                        ret
.ADDHLDESameNeg:        ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit
                        and     SignMask8Bit                ; we could check the value of b for optimisation
                        ld      h,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a
                        add     hl,de
                        ld      a,SignOnly8Bit
                        or      h                           ; now set bit for negative value, we won't bother with overflow for now TODO
                        ld      h,a
                        ret
.ADDHLDEOppSGN:         ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit                     ; here HL and DE are opposite 
                        and     SignMask8Bit                ; we could check the value of b for optimisation
                        ld      h,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a
                        ClearCarryFlag
                        sbc     hl,de
                        jr      c,.ADDHLDEOppInvert
.ADDHLDEOppSGNNoCarry:  ld      a,b                         ; we got here so hl > de therefore we can just take hl's previous sign bit
                        or      h
                        ld      h,a                         ; set the previou sign value
                        ret
.ADDHLDEOppInvert:      NegHL                                                   ; we need to flip the sign and 2'c the Hl result
                        ld      a,b
                        xor     SignOnly8Bit                ; flip sign bit
                        or      h
                        ld      h,a                         ; recover sign
                        ret 
                        
;;;NOT USED addhldesigned:          bit     7,h
;;;NOT USED                         jr      nz,.noneghl
;;;NOT USED                         call    negate16hl
;;;NOT USED .noneghl:               bit     7,d
;;;NOT USED                         jr      nz,.nonegde
;;;NOT USED                         call    negate16de
;;;NOT USED .nonegde:               add     hl,de                       ; do 2'd c add      
;;;NOT USED                         xor     a                           ; assume positive
;;;NOT USED                         bit     7,h
;;;NOT USED                         ret     z                           ; if not set then can exit early
;;;NOT USED                         call    negate16hl
;;;NOT USED                         ld      a,$FF
;;;NOT USED                         ret


;; NOT USED MAY WORK ? ; HL(2sc) = HL (signed) + A (unsigned), uses HL, DE, A
;; NOT USED MAY WORK ? ; 06 06 2022 not used
;; NOT USED MAY WORK ? HL2cEquHLSgnPlusAusgn:  ld      d,0
;; NOT USED MAY WORK ?                         ld      e,a                         ; set up DE = A
;; NOT USED MAY WORK ?                         ld      a,h
;; NOT USED MAY WORK ?                         and     SignMask8Bit
;; NOT USED MAY WORK ?                         jr      z,.HLPositive               ; if HL is negative then do HL - A
;; NOT USED MAY WORK ? .HLNegative:            ld      h,a                         ; hl = ABS (HL)
;; NOT USED MAY WORK ?                         NegHL                               ; hl = - hl
;; NOT USED MAY WORK ? .HLPositive:            ClearCarryFlag                      ; now do adc hl,de
;; NOT USED MAY WORK ?                         adc     hl,de                       ; aftert his hl will be 2's c
;; NOT USED MAY WORK ?                         ret
;; NOT USED MAY WORK ? ; 06 06 2022 not used
;; NOT USED MAY WORK ? HLEquHLSgnPlusAusgn:    ld      e,a
;; NOT USED MAY WORK ?                         ld      a,h
;; NOT USED MAY WORK ?                         and     SignMask8Bit
;; NOT USED MAY WORK ?                         jr      nz,.HLNegative              ; if HL is negative then do HL - A
;; NOT USED MAY WORK ? .HLPositive:            ld      a,e                         ; else its HL + A
;; NOT USED MAY WORK ?                         add     hl,a
;; NOT USED MAY WORK ?                         ret
;; NOT USED MAY WORK ? .HLNegative:            ClearSignBit    h                   ; Clear sign of HL
;; NOT USED MAY WORK ?                         NegHL                               ; and convert to 2's C
;; NOT USED MAY WORK ?                         ld      d,0
;; NOT USED MAY WORK ?                         ClearCarryFlag
;; NOT USED MAY WORK ?                         sbc     hl,de                       ; now add a to -ve HL , add does not do 2's c
;; NOT USED MAY WORK ?                         jp      m,.FlipResult               ; if it was negative then its really positive
;; NOT USED MAY WORK ?                         SetSignBit      h
;; NOT USED MAY WORK ?                         ret
;; NOT USED MAY WORK ? .FlipResult:            NegHL                               ; so if -hl + A => HL - A => HL - DE is negative then the actual result is +ve
;; NOT USED MAY WORK ?                         ret
                        
                        
; 06 06 2022 not used
; HL = HL (signed) + A (unsigned), uses HL, DE, A
AddAusngToHLsng:        ld      d,a
                        ld      e,h
                        ld      a,h
                        and     SignMask8Bit
                        ld      h,a
                        ld      a,d
                        add     hl,a
                        ld      a,e
                        and     SignOnly8Bit
                        or      h
                        ret
; 06 06 2022 not used
; HL = A (unsigned) - HL (signed), uses HL, DE, BC, A
HLEequAusngMinusHLsng:  ld      b,h
                        ld      c,a
                        ld      a,b
                        and     SignOnly8Bit
                        jr      nz,.DoAdd
.DoSubtract:            ex      de,hl               ; move hl into de
                        ld      h,0                 ; hl = a
                        ld      l,c
                        ClearCarryFlag
                        sbc     hl,de               ; hl = a - hl
                        ret
.DoAdd:                 ld      a,c
                        add hl,a
                        ret 
;tested mathstestsun2
; DEL = DEL + BCH signed, uses BC, DE, HL, IY, A
AddBCHtoDELsigned:      ld      a,b                 ; Are the values both the same sign?
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

; 06 06 2022 not used                       
;BHL = AHL + DE where AHL = 16 bit + A sign and DE = 15 bit signed    
AddAHLtoDEsigned:       ld      b,a                     ; B = A , C = D (save sign bytes)
                        ld      c,d                     ; .
                        xor     c                       ; A = A xor C
                        res     7,d                     ; clear sign bit of D
                        jr nz,  .OppositeSigns          ; if A xor C is opposite signs job to A0A1
                        add     hl,de                   ; HL = HL + DE
                        ret                             ; return 
.OppositeSigns:         sbc     hl,de                   ; HL = HL -DE
                        ret     nc                      ; if no carry return
                        add     hl,de                   ; else HL = HL + DE
                        ex      de,hl                   ;      swap HL and DE
                        and     a                       ;      reset carry
                        sbc     hl,de                   ;      HL = DE - HL (as they were swapped)
                        ld      b,c                     ;      B = sign of C
                        ret                             ;      ret


; 06 06 2022 not used   
; a = value to add
; b = offset (equivalent to regX)
; returns INWK [x] set to new value
; NOT USED addINWKbasigned:
; NOT USED 		ld 		hl,UBnKxlo                  ; hl = INWK 0
; NOT USED 		ld      c,a                         ; preserve a
; NOT USED 		ld		a,b
; NOT USED 		add		hl,a                        ; hl = INWK[x]
; NOT USED         ld      a,c                         ; get back a value
; NOT USED         and     $80                         ; get sign bit from a
; NOT USED         ld      b,a                         ; now b = sign bit of a
; NOT USED         ld      a,c                         ; a = original value
; NOT USED         and     SignMask8Bit                ; a = unsigned version of original value
; 06 06 2022 not used
; hl = unsigned version of INWK0[b]
; a = value to add, also in c which will optimise later code
; b = sign bit of a ( in old code was varT)
; NOTUSEDaddhlcsigned:                              
; NOTUSED        ld      e,(hl)                      ; de = INKK value
; NOTUSED        inc     hl
; NOTUSED        ld      d,(hl)
; NOTUSED        inc     hl                          ; now pointing a sign
; NOTUSED        ld      a,(hl)                      ; a = sign bit
; NOTUSED        ex      de,hl                       ; hl = value now and de = pointer to sign
; NOTUSED        xor     b                           ; a = resultant sign
; NOTUSED        bit     7,a                         ; is it negative?
; NOTUSED        jr      z,.postivecalc              
; NOTUSED.negativecalc:        
; NOTUSED        ld      a,h
; NOTUSED        and     SignMask8Bit
; NOTUSED        ld      h,a                         ; strip high bit
; NOTUSED        ld      ixl,b                       ; save sign bit from b into d
; NOTUSED        ld      b,0                         ; c = value to subtract so now bc = value to subtract
; NOTUSED        sbc     hl,bc     
; NOTUSED        ld      b,ixl                       ; get sign back
; NOTUSED        ex      de,hl                       ; de = value hl = pointer to sign
; NOTUSED        ld      a,(hl)                      ;
; NOTUSED        and     SignMask8Bit
; NOTUSED        sbc     a,0                         ; subtract carry which could flip sign bit
; NOTUSED        or      $80                         ; set bit 0
; NOTUSED        xor     b                           ; flip bit on sign (var T)
; NOTUSED        ld      (hl),a
; NOTUSED        dec     hl
; NOTUSED        ld      (hl),d
; NOTUSED        dec     hl
; NOTUSED        ld      (hl),e                      ; write out DE to INKW[x]0,1
; NOTUSED        ex      de,hl                       ; hl = value de = pointer to start if INKW[x]
; NOTUSED        ret     c                           ; if carry was set then we can exit now
; NOTUSED.nocarry:        
; NOTUSED        NegHL                               ; get hl back to positive, a is still inkw+2
; NOTUSED        or      b                           ; b is still varT
; NOTUSED        ex      de,hl                       ; de = value hl = pointer to start if INKW[x]
; NOTUSED        ld      (hl),e
; NOTUSED        inc     hl
; NOTUSED        ld      (hl),d
; NOTUSED        inc     hl
; NOTUSED        ld      (hl),a                      ; set sign bit in INKK[x]+2
; NOTUSED        ex      de,hl                       ; hl = value de = pointer to sign
; NOTUSED        ret
; NOTUSED.postivecalc:
; NOTUSED        ld      ixl,b
; NOTUSED        ld      b,0
; NOTUSED        add     hl,de
; NOTUSED        ex      de,hl
; NOTUSED        or      ixl                         ; we don;t need to recover b here
; NOTUSED        ld      (hl),a                      ; push sign into INWK[x]
; NOTUSED        dec     hl
; NOTUSED        ld      (hl),d
; NOTUSED        dec     hl
; NOTUSED        ld      (hl),e
; NOTUSED        ret
        
;a = a AND 80 (i.e. bit 7) =>carry       so value is -
;MVT1
;    S = bits 6 to 0 of A
;    A = sign bit => T
;    xor sign bit with ink[x] Sign
;    if negative thn its not an add
;
;        and h, 7F
;        b = 0
;        c = varS
;        subtract INW[X]hilo, bc
;        retain carry
;        get INKW[x]Sign
;        and 7F
;        subtract carry (so will go negtive if negative)
;        xor bit 7 of h with T to flip bit
;        write to INKW[x]Sign
;
;    else
;MV10.
;        add INWK[x]hi,lo, varS
;        or      sign bit
        
