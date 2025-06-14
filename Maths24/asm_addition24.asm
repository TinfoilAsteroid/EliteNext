; Addition---------------------------------------------------
; BAHL = BHL+CDE Lead Sign bit - If overflows AHL then carry will be set resulting in B holding sign and rest of value, else AHL holds value
; in reality will we aim for all values being S14.8 so bit 15 is always clear for overflow
AHLequBHLplusCDE:       ld      a,b                          ; if b sign and c sign were different then bit 7 of a will be 1 which means
                        and     $80                          ; Signs are opposite there fore we can subtract to get difference
                        xor     c                            ;
                        JumpIfNegative .OppositeSigns        ;
.SameSigns:             ld      a,b                          ; if they are both negative
                        or      c                            ; then we can do an add but also set the sign bit
                        JumpIfNegative .BothNegative         ; optimisation so we can just do simple add if both positive
.BothPositive:          adc     hl,de                        ; both positive so a will already be zero
                        ld      a,b                          ; a = b + c + an carry from HL + DE
                        adc     c                            ;
                        ret     nc                           ; fi there was no carry then we are good
.OverFlowPositive:      ld      b,1                          ; if we overflow from +BHL +  +CDE then we already have sign cleared in A and only 1 bit to roll into B + no sign bit
                        ret
.BothNegative:          res     7,b                          ; clear sign bits for both values
                        res     7,c                          ; .
                        adc     hl,de                        ; now behave like they are both positive
                        ld      a,b
                        adc     c
                        jp      c,.OverFlowNegative          ; if there was carry we need to overflow into b
                        or      %10000000                    ; set bit 7 of A for negative
                        ret
.OverFlowNegative:      ld      b,%10000001                  ; carry over the bit but also set the sign bit
                        ret
.OppositeSigns:         bit     7,b                         ; if BHL was negative then
                        jp      nz,.CDEMinusBHL             ; its CDE - BHL
.BHLMinusCDE:           res     7,c
                        ex      hl,de                       ; it must be BHL - CDE  so we swap registers and just treat it as CDE-BHL
                        ld      a,b                         ; and we have to use a when swapping b and c
                        ld      b,c                         ; .
                        ld      c,a                         ; .
.CDEMinusBHL:           res     7,b
                        ClearCarryFlag                      ; now its just common CDE-BHL
                        ld      a,c                         ; a= c - b
                        sbc     b
                        ex      hl,de                       ; hl = DE-hl by swapping them round
                        sbc     hl,de                       ; now AHL is result
                        ret     nc                          ; if there was no carry then we are good
.CDEFlipSign:           NegAHL                              ; as CDE-BHL became negative we make result lead sign negativce
                        or      %10000000                   ; flip the lead bit of A
                        ret
SwapViaA:               MACRO   r1, r2
                        ld      a,r1
                        ld      r1,r2
                        ld      r2,a
                        ENDM
AHLequHLAddCarryAViaDE: MACRO
                        ld      d,0                         ; de = P1 carry
                        ld      e,a                         ; .
                        xor     a                           ; Clear carry and prep a for P2 carry
                        add     hl,de                       ; .
                        adc     a,a                         ; .
                        ENDM
; variants on AHLequBHLplusCDE
; AHL = BHL+DEC Lead Sign bit
AHLequBHLplusDEC:       ld      a,d                         ; d = e (saving d)
                        ld      d,e                         ; .
                        ld      e,c                         ; e = c
                        ld      c,a                         ; c = d (orginal value)
                        jp      AHLequBHLplusCDE
                        
; AHL = BHL-CDE Lead Sign bit
AHLequBHLminusCDE:      ld      a,c
                        xor     %10000000
                        ld      c,a
                        jp      AHLequBHLplusCDE
 
; variant on above for simplifying post multiply           ; d = e (saving d)
AHLequBHLminusDEC:      ld      a,d                        ; .
                        or      %10000000                  ; but we also flip the sign on the saved D
                        ld      d,e                        ; .
                        ld      e,c                        ; e = c
                        ld      c,a                        ; c = d (orginal value)
                        jp      AHLequBHLplusCDE
                        
; If it will fit
;  HLBC = BHL * CDE  Lead Sign bit, carry Clear
; else
;  AHLBC = BHL * CDE Lead sign bit , carry set
; performs p0 = x0*y0                               L*E
;          p1 = x1*y0 + x0*y1 + p0 carry            H*E + D*L
;          p2 = x2*y0 + x0*y2 + x1*y1 + p1 carry    B*E + L*C + H*D
;          p3 = x2*y1 + x1 * y2 + p2 carry          B*D + H*C
;          p4 = x2* y2                              B*C
; reverse order for stack retrival                                                                                              B H L  C D E
; performs p4 = x2* y2                              B*C                B*C                     leave as is           BHL*CDE   020305 01040A 0201            02                  P4 = 2
;          p3 = x2*y1 + x1 * y2 + p2 carry          B*D + H*C          Swap B<>E and C<>L      E*D + H * L           EHC*LDB    E H C  L D B 0204 0301       08+03 = 0B          P3 = B
;          p2 = x2*y0 + x0*y2 + x1*y1 + p1 carry    E*B + C*L + H*D    Swap B<>D and C<>H      E*D + H * L + C * B   ECH*LBD    E C H  L B D 020A 0501 0304  14+05+0C=25         P2 = 25
;          p1 = x1*y0 + x0*y1                       C*D + H*B          Swap C<>E and L<>B      E*D + H * L           CEH*BLD    C E H  B L D 030A 0504       1E+14 = 32          P1 = 32 carry = 0
;          p0 = x0*y0                               C*B                Swap E,H, ex hl,de in calc                    CHE*BDL                 050A            32                  P0 = 32 Carry = 0
HLBCequBHLmulCDE:       ld      a,b                         ; multiply is simpler as same signs is always positive
                        xor     c                           ; opposite is always negative
                        and     $80                         ; .
.SaveSign:              push    af                          ; save a to the stack that will now hold 0 or $80,
.ClearSignBits:         res     7,b
                        res     7,c
.PrepP4:                push    bc                          ; save registers for p4 = x2*y2 p3 carry > BC = x0 y0
.PrepP3:                SwapViaA b,e                        ; save registers for p3  = x2*y1 + x1*y2 + p2 carry
                        SwapViaA c,l
                        push    de,,hl                      ; DE = X2 Y1 HL = X1 Y2
.PrepP2:                SwapViaA d,b                         ; save registers for p2  = x2*y0 + x0*y2 + x1*y1 + p1 carry
                        SwapViaA c,h
                        push    de,,hl,,bc                  ; save registers for p1 = x1*y0 + x0*y1 + p0 carry
.PrepP1:                SwapViaA c,e
                        SwapViaA l,b
                        push    de,,hl
.PrepP0:                SwapViaA e,h                        ; we don't care about original values now as they are on the stack
.CalcP0:                mul     de                          ; de = x0 * y0 no need for carry logic as even FF*FF = FE01
                        ld      bc,de                       ; so b = P0 carry,c = P0
.CalcP1:                pop     de                          ; get P1 components off stack
                        mul     de                          ; hl = x1*y0
                        ex      de,hl                       ; so de = P1c P1 b =P0c P0
.AddP0Carry:            xor     a                           ; hl = x1*y0 + P0 carry
                        ld      d,0                         ; .
                        ld      e,b                         ; .
                        add     hl,de                       ; .
                        adc     a,a                         ; a = carry
                        pop     de
                        mul     de                          ; de = x0*y1
                        and     a                           ; clear carry flag whilst retaining a
                        add     hl,de                       ; hl = x1*y0 + x0*y1
.CalcP1Carry:           adc     a,0                         ;
                        add     h                           ; a = P1 carry
                        ld      b,l                         ; A = P1 carry bc = P1 P0
.CalcP2:                pop     de                          ; we pull in bc later directly into de
                        mul     de                          ; hl = x2*y0
                        ex      hl,de                       ; .
.AddP1Carry:            AHLequHLAddCarryAViaDE
.CalcP2Pt2:             pop     de                          ; de = x0*y2
                        mul     de                          ; .
                        and     a                           ; Clear carry preserve a
                        add     hl,de                       ; hl = x2*y0 + x0*y2
                        adc     a,a                         ; a = new carry
.CalcP2Pt3:             pop     de                          ; de = x1*y1
                        mul     de                          ; .
                        and     a                           ; hl = x2*y0 + x0*y2 + x1*y1, preserve carry flag
                        add     hl,de                       ; so we have hl = P2c P2 BC = P1P1
.CalcP2Carry:           adc     a,0                         ; A = calc carry + P2 carry in h
                        add     a,h                         ; l = P2 bc = P1 P0
                        ld      e,l                         ; ixl = l (via e as you can't do hl to ix direct)
.SaveP2:                ld      ixl,e                       ; a = P2 carry ixl:bc = P2 P1 P0
.CalcP3                 pop     de                          ; hl = x2*y1
                        mul     de                          ; .
                        ex      de,hl                       ; .
.AddP2Carry:            AHLequHLAddCarryAViaDE
.CalcP3Pt2:             pop     de                          ; de =  x1*y2
                        mul     de                          ; .
                        and     a                           ; Clear carry preserve a
                        add     hl,de                       ; hl = x2*y1 + x1*y2
                        adc     a,0                         ; a = new carry for P3, l = p3
                        add     a,h                         ; .
.SaveP3:                ld      e,l                         ; load ixh via e
                        ld      ixh,e                       ; so we now have a = P3 carry ix P3P2 bc = P1P0
.CalcP4:                pop     de                          ; de = x2* y2 + P3 carry
                        mul     de                          ; .
                        ex      de,hl                       ;
.AddP3Carry:            AHLequHLAddCarryAViaDE              ; hl ix bc = P5P4 P3P2 P1P0
.RecoverSignBit:        ld      a,l                         ; Is P4 populated,
                        and     a
                        jp      z,.P3toP0                   ; if not then we have result P3P2P1P0
.P4toP0:                pop     af                          ; else return with AHLBC
                        or      l
                        ld      hl,ix
                        ret
.P3toP0:                pop     af
                        ld      hl,ix                       ; move P2P2 into hl
                        or      h
                        ld      h,a
                        xor     a                           ; return result in hlbc with CarryClear
                        ret

ResultIsZero:           pop     af                          ; get rid of unwanted sign bits
                        ld      c,e                         ; CDE = EHL as remainder
                        ex      hl,de
                        xor     a                           ; result AHL = $0
                        ld      h,a
                        ld      l,a                         ; .
                        ret

DivideByZero:           pop     af                          ; get rid of unwanted sign bits
                        ld      c,e                         ; CDE = EHL as remainder
                        ex      hl,de
                        ld      a,$FF                       ; result AHL = $FFFFFF
                        ld      hl,$FFFF                    ; .
                        SetCarryFlag                        ; and carry set
                        ret


; AHL = EHL / DBC  Lead Sign bit; CDE = remainder carry clear, divide by 0 gives AHL $FFFFFF, carry set
AHLequEHLdivDBC:        ld      a,e                         ; divide is simpler as same signs is always positive
                        xor     d                           ; opposite is always negative
                        and     $80                         ; .
.SaveSign:              push    af                          ; save a to the stack that will now hold 0 or $80,
.ClearSignBits:         res     7,e
                        res     7,d
.CheckDivideByZero:     ld      a,d
                        or      b
                        or      c
                        jr      z,DivideByZero
                        ;DEBUG jp      Perform_24x24   ; forece 24 bit
; Now determine the scale down, e.g. can we do smaller divides than just 24x24
; Patterns              24x24 OK                         1C
;                       24x16 OK                         1E
;                       24x8  OK                         1F
;                       16x24 0                          1I
;                       16x16 OK                         1J
;                       16x8  OK                         1L
;                       8x24  0                          1N
;                       8x16  0                          1N
;                       8x8   OK                         1O
; flow is               check if its 24 / ?              1A
;                       Y > test 24/24                   1B
;                           Y > Perform 24x24            1C
;                           N > Check   24x16            1D
;                               Y > Perform 24x16        1E
;                               N > Perform 24x8         1F
;                       N > test 16/ ?                   1G
;                           Y > Check 16/24              1H
;                               Y > Result 0             1I
;                               N > Check 16/16          1J
;                                   Y > Perform 16/16    1K
;                                   N > Perform 16/8     1L
;                           N > Check 08/24 or 08/16     1M
;                               Y > Result is 0          1N
;                               N > Perform 8/8          1O
.ValidDivide:           inc     e
                        dec     e
                        jr      nz,Try_24xAnything         ; its at least ehl / something
.Test_16x:              inc     h
                        dec     h
                        jr      nz, .Try_16xAnything        ; its at least hl / something
.Try_8xAnything:        inc     d
                        dec     d
                        jp      nz, ResultIsZero            ; its l / dbc which is always zero
                        dec     b
                        inc     b
                        jp      nz, ResultIsZero            ; its l / bc which is always zero
                        jp      Perform_8x8:                ; its l/b
.Try_16xAnything:       inc     d
                        dec     d
                        jp      nz, ResultIsZero            ; its hl / dbc which is always zero
                        dec     b
                        inc     b
                        jp      nz, Perform_16x16           ; its hl/bc
                        jp      Perform_16x8                ; so it must be hl/c
;--------------------------------------------------------------------------------------------------
; Div 24x24 iteration

;--------------------------------------------------------------------------------------------------
; AHL = EHL/DBC, EHL > DBC both >= 01 00 00
    DISPLAY "24x24 Actual internal result currently is 0L.D so need to rationalise it to AHL"
    DISPLAY "Working on one 24x24 only"
    DISPLAY "In effect 24x24 where E and D are both > 0 means e/d"
Try_24xAnything:        ;inc     d
                        ;dec     d
                        ;jp      nz,Perform_24x24           ; if d was not zero then its ehl/dbc
                        ;ld      a,b
                        ;and     $80
                        ;dec     b
                        ;inc     b
                        ;jp      z,Perform_24x8              ; if b was zero then its ehl/00c
                        ;jp      Perform_24x16               ; else it leaves us with ehl/0bc
; {er
Perform_24x24:          ld      a,e                         ; EHL => HLE  AHL
                        ld      e,l                         ;             AHE
                        ld      l,h                         ;             ALE
                        ld      h,a                         ;             HLE
                        xor     a                           ;             A = 0 Celar carry flag
.eliminateLeadingZeros:
.loop_00:               rl e                                ; HLE << 1
                        adc hl,hl                           ;
                        jr c, .loop_10                      ; if HLE bit 7 was set prior to shift goto loop_10  HLE was %1XXXXXXX XXXXXXXX XXXXXXX
                        rl e                                ; (HLE << 1) + 1
                        inc e                               ;
                        adc hl,hl                           ;
                        jr c, .loop_20                      ; if HLE bit 6 was set prior to shift goto loop_20  HLE was %01XXXXXX XXXXXXXX XXXXXXX
                        rl e                                ; (HLE << 1) + 1
                        inc e                               ;
                        adc hl,hl                           ;
                        jr c, .loop_30                      ; if HLE bit 5 was set prior to shift goto loop_30  HLE was %001XXXXX XXXXXXXX XXXXXXX
                        rl e                                ; (HLE << 1) + 1
                        inc e                               ;
                        adc hl,hl                           ;
                        jr c, .loop_40                      ; if HLE bit 4 was set prior to shift goto loop_40  HLE was %0001XXXX XXXXXXXX XXXXXXX
                        rl e                                ; (HLE << 1) + 1
                        inc e                               ;
                        adc hl,hl                           ;
                        jr c, .loop_50                      ; if HLE bit 3 was set prior to shift goto loop_50  HLE was %00001XXX XXXXXXXX XXXXXXX
                        rl e                                ; (HLE << 1) + 1
                        inc e                               ;
                        adc hl,hl                           ;
                        jr c, .loop_60                      ; if HLE bit 2 was set prior to shift goto loop_50  HLE was %000001XX XXXXXXXX XXXXXXX
                        rl e                                ; (HLE << 1) + 1
                        inc e                               ;
                        adc hl,hl                           ;
                        jr c, .loop_70                      ; if HLE bit 1 was set prior to shift goto loop_50  HLE was %0000001X XXXXXXXX XXXXXXX
                        scf                                 ; set carry and jump to loop 7 as bit 0 of HLE must have been set
                        rl e                                ; (HLE << 1) + 1
                        inc e                               ;
                        adc hl,hl                           ;
                        jr c, .loop_80                      ; if HLE bit 0 was set prior to shift goto loop_50  HLE was %0000001X XXXXXXXX XXXXXXX
                        scf                                 ; set carry and jump to loop 7 as bit 0 of HLE must have been set
                        jp .loop_7
.loop_10:               rla                                 ; A = A *2 + carry from  HLE * 2 (on first pass A = 0)
                        sbc hl,bc                           ; AHL = AHL - DBC
                        sbc a,d                             ;
                        jr nc, .loop_1                      ; if AHL is negative
                        add hl,bc                           ;   revert AHL back to prior value
                        adc a,d                             ;   .
.loop_1:                rl e                                ; else
                        adc hl,hl                           ;   HLE = HLE * 2
.loop_20:               rla                                 ; A = carry from  HLE * 2
                        sbc hl,bc                           ; AHL = AHL - DBC
                        sbc a,d                             ;
                        jr nc, .loop_2                       ; if AHL is negative
                        add hl,bc                           ;   revert AHL back to prior value
                        adc a,d                             ;   .
.loop_2:                rl e                                ; else
                        adc hl,hl                           ;   AHL = HLE = HLE * 2
.loop_30:               rla                                 ;   . (also AHL = HLE = HLE * 2 from entry point above if skipping lead zeros)
                        sbc hl,bc                           ; AHL = AHL - DBC
                        sbc a,d                             ;
                        jr nc, .loop_3                       ; if AHL is negative
                        add hl,bc                           ;   revert AHL back to prior value
                        adc a,d                             ;   .
.loop_3:                rl e                                ; else
                        adc hl,hl                           ;   AHL = HLE = HLE * 2
.loop_40:               rla                                 ;   . (also AHL = HLE = HLE * 2 from entry point above if skipping lead zeros)
                        sbc hl,bc                           ; AHL = AHL - DBC
                        sbc a,d                             ;
                        jr nc, .loop_4                       ; if AHL is negative
                        add hl,bc                           ;   revert AHL back to prior value
                        adc a,d                             ;   .
.loop_4:                rl e                                ; else
                        adc hl,hl                           ;   AHL = HLE = HLE * 2
.loop_50:               rla                                 ;   . (also AHL = HLE = HLE * 2 from entry point above if skipping lead zeros)
                        sbc hl,bc                           ; AHL = AHL - DBC
                        sbc a,d                             ;
                        jr nc, .loop_5                       ; if AHL is negative
                        add hl,bc                           ;   revert AHL back to prior value
                        adc a,d                             ;   .
.loop_5:                rl e                                ; else
                        adc hl,hl                           ;   AHL = HLE = HLE * 2
.loop_60:               rla                                 ;   . (also AHL = HLE = HLE * 2 from entry point above if skipping lead zeros)
                        sbc hl,bc                           ; AHL = AHL - DBC
                        sbc a,d                             ;
                        jr nc, .loop_6                       ; if AHL is negative
                        add hl,bc                           ;   revert AHL back to prior value
                        adc a,d                             ;   .
.loop_6:                rl e                                ; else
                        adc hl,hl                           ;   AHL = HLE = HLE * 2
.loop_70:               rla                                 ;   . (also AHL = HLE = HLE * 2 from entry point above if skipping lead zeros)
                        sbc hl,bc                           ; AHL = AHL - DBC
                        sbc a,d                             ;
                        jr nc, .loop_7                       ; if AHL is negative
                        add hl,bc                           ;   revert AHL back to prior value
                        adc a,d                             ;   .
.loop_7:                rl e                                ; else
                        adc hl,hl                           ;   AHL = HLE = HLE * 2
.loop_80:               rla                                 ;   . (also AHL = HLE = HLE * 2 from entry point above if skipping lead zeros)
                        sbc hl,bc                           ; AHL = AHL - DBC
                        sbc a,d                             ;
                        jr nc, .loop_8                       ; if AHL is negative
                        add hl,bc                           ;   revert AHL back to prior value
                        adc a,d                             ;   .
.loop_8:                rl e                                ; else
                        adc hl,hl                           ;   AHL = HLE = HLE * 2



                        rla                                 ;   . (also AHL = HLE = HLE * 2 from entry point above if skipping lead zeros)
                        sbc hl,bc                           ; AHL = AHL - DBC
                        sbc a,d                             ;
                        jr nc, .exit_loop                    ; if AHL is negative
                        add hl,bc                           ;   revert AHL back to prior value
                        adc a,d                             ;   .
; quotient  = ~e[hl'] remainder =  ahl  one more shift left on quotient
.exit_loop:             ex de,hl                            ; ADE = AHL  HL = DE
                        ld c,a                              ; CDE = ADE
                        ld a,l                              ; L = (L*2) * -1 (as we reach here via jr nc then carry is 0
                        rla                                 ; .
                        cpl                                 ; .
                        ld l,a                              ; .
                        xor a                               ; h = 0
                        ld h,a
                        jp      HandleSign
;-----------------------------------------------------------------------------------------------------
; AHL = HLE/BC, where A is always 0 return EHL > DBC EHL >= 01 00 00 DBC >= 00 01 00
; inside loop computation is ehl / c  hl = remainder
Perform_24x16:          ld      d,b                         ; HLE/BC => HLE/DC
                        ld      a,e                         ;           HLA/DC
                        ld      e,c                         ;           HLA/DE
                        ld      c,l                         ;           HCA/DE
                        ld      l,a                         ;           HCL/DE
                        ld      a,h                         ;           ACL/DE
                        ld      h,0                         ;           ACL/DE
                        ld      b,2                         ;           ACB/DE (B = 2)
.eliminateLeadingZeros: rl c
                        rla
                        adc hl,hl
                        inc h
                        dec h
                        jr nz, .loop_00
                        rl c
                        inc c
                        rla
                        adc hl,hl
                        inc h
                        dec h
                        jr nz, .loop_11
                        rl c
                        inc c
                        rla
                        adc hl,hl
                        inc h
                        dec h
                        jr nz, .loop_22
                        rl c
                        inc c
                        rla
                        adc hl,hl
                        inc h
                        dec h
                        jr nz, .loop_33
                        rl c
                        inc c
                        rla
                        adc hl,hl
                        inc h
                        dec h
                        jr nz, .loop_44
                        rl c
                        inc c
                        rla
                        adc hl,hl
                        inc h
                        dec h
                        jr nz, .loop_55
                        rl c
                        inc c
                        rla
                        adc hl,hl
                        inc h
                        dec h
                        jr nz, .loop_66
                        scf
                        jp .loop_7
.loop_0:                rl c
                        rla
                        adc hl,hl
                        jr c, .loop_000
.loop_00:               sbc hl,de
                        jr nc, .loop_1
                        add hl,de
.loop_1:                rl c
                        rla
                        adc hl,hl
                        jr c, .loop_111
.loop_11:               sbc hl,de
                        jr nc, .loop_2
                        add hl,de
.loop_2:                rl c
                        rla
                        adc hl,hl
                        jr c, .loop_222
.loop_22:               sbc hl,de
                        jr nc, .loop_3
                        add hl,de
.loop_3:                rl c
                        rla
                        adc hl,hl
                        jr c, .loop_333
.loop_33:               sbc hl,de
                        jr nc, .loop_4
                        add hl,de
.loop_4:                rl c
                        rla
                        adc hl,hl
                        jr c, .loop_444
.loop_44:               sbc hl,de
                        jr nc, .loop_5
                        add hl,de
.loop_5:                rl c
                        rla
                        adc hl,hl
                        jr c, .loop_555
.loop_55:               sbc hl,de
                        jr nc, .loop_6
                        add hl,de
.loop_6:                rl c
                        rla
                        adc hl,hl
                        jr c, .loop_666
.loop_66:               sbc hl,de
                        jr nc, .loop_7
                        add hl,de
.loop_7:                rl c
                        rla
                        adc hl,hl
                        jr c, .loop_777
.loop_77:               sbc hl,de
                        jr nc, .loop_8
                        add hl,de
.loop_8:                djnz .loop_0
.exit_loop:             rl c
                        rla
                        ; ac = ~quotient, hl = remainder
                        ex de,hl
                        cpl
                        ld h,a
                        ld a,c
                        cpl
                        ld l,a
                        xor a
                        jp      HandleSign
.loop_000:              or a
                        sbc hl,de
                        or a
                        jp .loop_1
.loop_111:              or a
                        sbc hl,de
                        or a
                        jp .loop_2
.loop_222:              or a
                        sbc hl,de
                        or a
                        jp .loop_3
.loop_333:              or a
                        sbc hl,de
                        or a
                        jp .loop_4
.loop_444:              or a
                        sbc hl,de
                        or a
                        jp .loop_5
.loop_555:              or a
                        sbc hl,de
                        or a
                        jp .loop_6
.loop_666:              or a
                        sbc hl,de
                        or a
                        jp .loop_7
.loop_777:              or a
                        sbc hl,de
                        or a
                        jp .loop_8
;-----------------------------------------------------------------------------------------------------
; AHL = HLE/BC, where A is always 0 return EHL > DBC EHL >= 01 00 00 DBC >= 00 00 01
; inside loop computation is abc/de, hl = remainder
; EHL: = EHL/C
;so currerntly thsi can't hadnle c > 127 so need to understand lead sign at lower bit levels on c
;so could just do 24 bit and process lead zeros in h and hope that is enough? or have a special case
;for collapsing lead zeros in dbc too
Perform_24x8:           ld      a,c
                        and     $80
                        jp      z,Perform_24x7
                        ld      ixh,24              ; from ehl/c to ABC/E
                        ld      a,e
                        ld      b,h
                        ld      d,c
                        ld      c,l
                        ld      e,d                        
                        ld      d,0
                        ld      hl,0                ;
                        ; with c being 8 bit we need to do
.loop1:                 sla     c                   ; unroll 24 times
                        rl      b                   ; ...
                        rla                         ; ...
                        adc     hl,hl               ; ...
                        sbc     hl,de               ; ...
                        jr      nc,.Skip1           ; ...
                        add     hl,de               ; ...
                        dec     c                   ; ...
.Skip1:                 dec     ixh
                        break
                        jp      nz,.loop1
                        break
                        jp      HandleSign
Perform_24x7:           ld b,24
                        xor a
.loop1:                 add hl,hl
                        rl e
                        rla
                        ;rl d
                        ;rla
                        cp c
                        jr c, .Skip1
                        sub c
                        inc l
.Skip1:                 djnz .loop1
                        break
                        jp      HandleSign

   ;   a = remainder
   ; ehl = quotient

   ld c,a
   ld a,e
   ld e,c
   ld d,b
   
   or a
   ret
 
                           
;.slow32x8:              ld      d,h ; do dehl / c
;                        ld      e,l
;                        ld      h,e
;                        ld      l,0
;                        xor     a
;.looping:               ld b,2
;.loop_11:               add hl,hl
;                        rl e
;                        rl d
;.loop_01:               rla
;                        jr c, .loop_02
;                        cp c
;                        jr c, .loop_03
;.loop_02:               sub c
;                        inc l
;.loop_03:               djnz .loop_11
                        or a
; result dehl = 32-bit quotient
;.slow:                  ld      b,24
;.loop_11:               add     hl,hl
;                        rl      e
;.loop_01:               rla
;                        jr      c, .loop_02
;                        cp      c
;                        jr      c, .loop_03
;.loop_02:               sub 01010c
;                        inc 01010l
;.loop_03:               djnz .loop_11
;                        ld c,a
;                        ld a,e
;                        ld e,c
;                        ld d,b
;                        or a
                        jp      HandleSign

DEBUG:                        xor     a                           ;             A = 0 Clear carry flag
                        ld b,3
.eliminateLeadingZeros:
.loop_00:               add hl,hl
                        rl e
                        jr c, .loop_10
                        add hl,hl
                        rl e
                        jr c, .loop_20
                        add hl,hl
                        rl e
                        jr c, .loop_30
                        add hl,hl
                        rl e
                        jr c, .loop_40
                        add hl,hl
                        rl e
                        jr c, .loop_50
                        add hl,hl
                        rl e
                        jr c, .loop_60
                        add hl,hl
                        rl e
                        jr c, .loop_70
                        add hl,hl
                        rl e
                        rla
                        cp c
                        jr c, .loop_80
                        sub c
                        inc l
.loop_80:               dec b
   ; general divide loop
.loop_0:                add     hl,hl
                        rl      e
.loop_10:               rla
                        jr      c, .loop_101
                        cp      c
                        jr      c, .loop_1
.loop_101:              sub     c
                        inc     l
.loop_1:                add     hl,hl
                        rl      e
.loop_20:               rla
                        jr      c, .loop_201
                        cp      c
                        jr      c, .loop_2
.loop_201:              sub     c
                        inc     l
.loop_2:                add     hl,hl
                        rl      e
.loop_30:               rla
                        jr      c, .loop_301
                        cp      c
                        jr      c, .loop_3
.loop_301:              sub     c
                        inc     l
.loop_3:                add     hl,hl
                        rl      e
.loop_40:               rla
                        jr      c, .loop_401
                        cp      c
                        jr      c, .loop_4
.loop_401:              sub     c
                        inc     l
.loop_4:                add     hl,hl
                        rl      e
.loop_50:               rla
                        jr      c, .loop_501
                        cp      c
                        jr      c, .loop_5
.loop_501:              sub     c
                        inc     l
.loop_5:                add     hl,hl
                        rl      e
.loop_60:               rla
                        jr      c, .loop_601
                        cp      c
                        jr      c, .loop_6
.loop_601:              sub     c
                        inc     l
.loop_6:                add     hl,hl
                        rl      e
.loop_70:               rla
                        jr      c, .loop_701
                        cp      c
                        jr      c, .loop_7
.loop_701:              sub     c
                        inc     l
.loop_7:                add     hl,hl
                        rl      e
                        rla
                        jr      c, .loop_801
                        cp      c
                        jr      c, .loop_8
.loop_801:              sub     c
                        inc     l
.loop_8:                djnz    .loop_0
.exit_loop:             ld      c,a
                        ld      a,e
                        ld      e,c
                        ld      d,b
                        or      a
HandleSign:             ld      b,a ; save the a value      ; now deal with prior sign
                        pop     af
                        or      b                           ; now a holds saved sign and b result so now lead sign S15.8
                        ret
;-----------------------------------------------------------------------------------------------------
; AHL = HL/BC, EHL > DBC both >= 00 01 00
Perform_16x16:          ld      de,bc                       ; get to AHL= 0HL/0BC
                        ld      a,l                         ;hl >= $1000 de >= $1000 so max quotient is 255
                        ld      l,h                         ; which means the loop computation is a[c] / de hl = remainder
                        ld      h,0                         ; so we can initialise as if 8 iterations are done
; unrolling divide 8 time, eliminating leading zeros is only marginal gain
.loop_0:                rla
                        adc     hl,hl
.loop_00:               sbc     hl,de
                        jr      nc, .loop_1
                        add     hl,de
.loop_1:                rla
                        adc     hl,hl
.loop_11:               sbc     hl,de
                        jr      nc, .loop_2
                        add     hl,de
.loop_2:                rla
                        adc     hl,hl
.loop_22:               sbc     hl,de
                        jr      nc, .loop_3
                        add     hl,de
.loop_3:                rla
                        adc     hl,hl
.loop_33:               sbc     hl,de
                        jr      nc, .loop_4
                        add     hl,de
.loop_4:                rla
                        adc     hl,hl
.loop_44:               sbc     hl,de
                        jr      nc, .loop_5
                        add     hl,de
.loop_5:
                        rla
                        adc     hl,hl
.loop_55:
                        sbc     hl,de
                        jr      nc, .loop_6
                        add     hl,de
.loop_6:
                        rla
                        adc     hl,hl
.loop_66:
                        sbc     hl,de
                        jr      nc, .loop_7
                        add     hl,de
.loop_7:
                        rla
                        adc     hl,hl
.loop_77:               sbc     hl,de
                        jr      nc, .exit_loop
                        add     hl,de
.exit_loop:             rla                ; a = ~quotient, hl = remainder
                        cpl
                        ld      e,a
                        xor     a
                        ld      d,a
                        ex      de,hl
                        jp      HandleSign
;-----------------------------------------------------------------------------------------------------
; AHL = HL/C, where A is always 0 return EHL > DBC both >= 00 01 00, internally does HL/E
Perform_16x8:           ld      e,c                          ; get to AHL= 0HL/00C
                        xor a
                        ld      d,a
                        ld      b,2
.loop_00:               add     hl,hl                       ; eliminate leading zeroes
                        jr      c, .loop_10
                        add     hl,hl
                        jr      c, .loop_20
                        add     hl,hl
                        jr      c, .loop_30
                        add     hl,hl
                        jr      c, .loop_40
                        add     hl,hl
                        jr      c, .loop_50
                        add     hl,hl
                        jr      c, .loop_60
                        add     hl,hl
                        jr      c, .loop_70
                        add     hl,hl
                        rla
                        cp      e
                        jr      c, .loop_80
                        sub     e
                        inc     l
.loop_80:               dec     b
.loop_0:                add     hl,hl
.loop_10:               rla
                        jr      c, .loop_101
                        cp      e
                        jr      c, .loop_1
.loop_101:              sub     e
                        inc     l
.loop_1:                add     hl,hl
.loop_20:               rla
                        jr      c, .loop_201
                        cp      e
                        jr      c, .loop_2
.loop_201:              sub     e
                        inc     l
.loop_2:                add     hl,hl
.loop_30:               rla
                        jr      c, .loop_301
                        cp      e
                        jr      c, .loop_3
.loop_301:              sub     e
                        inc     l
.loop_3:                add     hl,hl
.loop_40:               rla
                        jr      c, .loop_401
                        cp      e
                        jr      c, .loop_4
.loop_401:              sub     e
                        inc     l
.loop_4:                add     hl,hl
.loop_50:               rla
                        jr      c, .loop_501
                        cp      e
                        jr      c, .loop_5
.loop_501:               sub     e
                        inc     l
.loop_5:                 add     hl,hl
.loop_60:                rla
                        jr      c, .loop_601
                        cp      e
                        jr      c, .loop_6
.loop_601:               sub     e
                        inc     l
.loop_6:                 add     hl,hl
.loop_70:                rla
                        jr      c, .loop_701
                        cp      e
                        jr      c, .loop_7
.loop_701:               sub     e
                        inc     l
.loop_7:                 add     hl,hl
                        rla
                        jr      c, .loop_801
                        cp      e
                        jr      c, .loop_8
.loop_801:               sub     e
                        inc     l
.loop_8:                 djnz    .loop_0
.exit_loop:              ;AHL = quotient CDE = remainder
                        ld e,a
                        xor a
                        jp      HandleSign
;-----------------------------------------------------------------------------------------------------
; AHL = L/C, where A is always 0 return EHL > DBC both >= 00 01 00, internally does L/E
Perform_8x8:            xor     a
                        ld      d,a
                        ld      h,a
                        ld      e,c
.loop_00:               sla     l
                        jr      c, .loop_10
                        sla     l
                        jr      c, .loop_20
                        sla     l
                        jr      c, .loop_30
                        sla     l
                        jr      c, .loop_40
                        sla     l
                        jr      c, .loop_50
                        sla     l
                        jr      c, .loop_60
                        sla     l
                        jr      c, .loop_70
                        jp      .loop_17
.loop_10:               rla
                        cp      e
                        jr      c, .loop_11
                        sub     e
                        inc     l
.loop_11:               sla     l
.loop_20:               rla
                        cp      e
                        jr      c, .loop_12
                        sub     e
                        inc     l
.loop_12:               sla     l
.loop_30:               rla
                        cp      e
                        jr      c, .loop_13
                        sub     e
                        inc     l
.loop_13:               sla     l
.loop_40:               rla
                        cp      e
                        jr      c, .loop_14
                        sub     e
                        inc     l
.loop_14:               sla     l
.loop_50:               rla
                        cp      e
                        jr      c, .loop_15
                        sub     e
                        inc     l
.loop_15:               sla     l
.loop_60:               rla
                        cp      e
                        jr      c, .loop_16
                        sub     e
                        inc     l
.loop_16:               sla     l
.loop_70:               rla
                        cp      e
                        jr      c, .loop_17
                        sub     e
                        inc     l
.loop_17:               sla     l
                        rla
                        cp      e
                        jr      c, .exit_loop
                        sub     e
                        inc     l
.exit_loop:
                        ; a = remainder
                        ; l = quotient
                        ld      e,a
                        xor     a
                        jp      HandleSign

;
; AHL = 24bit at IX + 24 bit at IY

; AHL = 24bit at IX - 24 bit at IY

; BAHL = 24bit at IX * 24 bit at IY  Lead Sign bit

; AHL = 24bit at IX / 24 bit at IY  Lead Sign bit
