         
; Adds DE to HL, in form S15 result will also be S15 rather than 2's C                
AddDEtoHLSigned:        ld      a,h                         ; extract h sign to b
                        and     $80                         ; hl = abs (hl)
                        ld      b,a
                        ld      a,h
                        and     $7F
                        ld      h,a
                        ld      a,d                         ; extract d sign to c
                        and     $80                         ; de = abs (de)
                        ld      c,a
                        ld      a,d
                        and     $7F
                        ld      d,a
                        ld      a,b
                        xor     c
                        jp      nz,.OppositeSigns
.SameSigns              add     hl,de                       ; same signs so just add
                        ld      a,b                         ; and bring in the sign from b
                        or      h                           ; note this has to be 15 bit result
                        ld      h,a                         ; but we can assume that
                        ret
.OppositeSigns:         ClearCarryFlag
                        sbc     hl,de
                        jr      c,.OppsiteSignInvert
.OppositeSignNoInvert:  ld      a,b                         ; we got here so hl > de therefore we can just take hl's previous sign bit
                        or      h
                        ld      h,a                         ; set the previou sign value
                        ret
.OppsiteSignInvert:     NegHL                              ; we need to flip the sign and 2'c the Hl result
                        ld      a,b
                        xor     SignOnly8Bit               ; flip sign bit
                        or      h
                        ld      h,a                         ; recover sign
                        ret 
                        
ADDHLDESignBC:          ld      a,b
                        and     SignOnly8Bit
                        xor     c                           ;if b sign and c sign were different then bit 7 of a will be 1 which means 
                        JumpIfNegative .ADDHLDEsBCOppSGN     ;Signs are opposite there fore we can subtract to get difference
.ADDHLDEsBCSameSigns:   ld      a,b
                        or      c
                        JumpIfNegative .ADDHLDEsBCSameNeg    ; optimisation so we can just do simple add if both positive
                        add     hl,de                       ; both positive so a will already be zero
                        ret
.ADDHLDEsBCSameNeg:      add     hl,de
                        ld      a,b
                        DISPLAY "TODO: don't bother with overflow for now"
                        or      c                           ; now set bit for negative value, we won't bother with overflow for now TODO
                        ret
.ADDHLDEsBCOppSGN:       ClearCarryFlag
                        sbc     hl,de
                        jr      c,.ADDHLDEsBCOppInvert
.ADDHLDEsBCOppSGNNoCarry:ld      a,b                         ; we got here so hl > de therefore we can just take hl's previous sign bit
                        ret
.ADDHLDEsBCOppInvert:   NegHL                               ; if result was zero then set sign to zero (which doing h or l will give us for free)
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
                        DISPLAY "TODO:  dont bother with overflow for now"
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
 
; extension to AddBCHtoDELsigned
; takes ix as the address of the values to load into BCH
;       iy as the address of the values to load into DEL
AddAtIXtoAtIY24Signed:  ld      h,(ix+0)
                        ld      l,(ix+1)
                        ld      b,(ix+2)
                        ld      d,(iy+0)
                        ld      e,(iy+1)
                        ld      l,(iy+2)
                        push    iy
                        call    AddBCHtoDELsigned
                        pop     iy
                        ld      (iy+0),d
                        ld      (iy+1),e
                        ld      (iy+2),l
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

        
