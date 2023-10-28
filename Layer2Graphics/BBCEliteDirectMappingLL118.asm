                IFDEF DEBUG_LL122_DIRECT
                        ; (Y X) = (S R) * Q 
                        ; yxregpair = (20 * 140)/256 = 16d 10h
Debug_LL122_6502:       ld      hl, 20      :ld      (SRvarPair),hl
                        ld      a,  140     :ld      (Qvar),a
                        call    LL122_6502  ; -10                               >> PASS
                        ;break
                        ; yxregpair = 20 * 140 = 17d 11h
                        ld      hl, 20      :ld      (SRvarPair),hl
                        ld      a,  230     :ld      (Qvar),a
                        call    LL122_6502  ; -17                               >> PASS
                        break
                        ret
                ENDIF

;--  The following calculates: (Y X) = (S R) / Q using the same shift-and-subtract algorithm that's documented in TIS2

                IFDEF DEBUG_LL121_DIRECT
                        ; (Y X) = (S R) / Q
                        ; yxregpair = 20 / 140 = 20*256 / 140 = 36d, 24h
Debug_LL121_6502:       ld      hl, 20      :ld      (SRvarPair),hl            
                        ld      a,  140     :ld      (Qvar),a
                        call    LL121_6502  ; -36                               >> PASS
                        ;break
                        ; yxregpair =  20 / 140 = 20*256 / 230 = 22d, 11h                        
                        ld      hl, 20      :ld      (SRvarPair),hl
                        ld      a,  230     :ld      (Qvar),a
                        call    LL121_6502  ; -22                               >> PASS
                        ;break
                        ret
                ENDIF
                
                IFDEF DEBUG_LL129_DIRECT
Debug_LL129_6502:       ld      hl,-20      :ld     (SRvarPair),hl
                        ld      a, 0        :ld     (XX12p3),a
                        ld      a, 10       :ld     (XX12p2),a
                        call    LL129_6502  ; expect q = 10, a = $FF SR = 20    >> PASS
                        ;break
                        ld      hl,20       :ld     (SRvarPair),hl
                        ld      a, 0        :ld     (XX12p3),a
                        ld      a, 40       :ld     (XX12p2),a
                        call    LL129_6502  ; expect q = 40, a = 00 SR = 20     >> PASS
                        ;break
                        ld      hl,40       :ld     (SRvarPair),hl
                        ld      a, $FF      :ld     (XX12p3),a
                        ld      a, 40       :ld     (XX12p2),a
                        call    LL129_6502  ; expect q = 40, a = $FF SR = 40    >> PASS
                        ;break
                        ld      hl,-40      :ld     (SRvarPair),hl
                        ld      a, $FF      :ld     (XX12p3),a
                        ld      a, 40       :ld     (XX12p2),a
                        call    LL129_6502  ; expect q = 40, a = 00 SR = 40     >> PASS
                        ;break
                        ret
                ENDIF
         
                IFDEF DEBUG_LL120_DIRECT
Debug_LL120_6502:       ld      a,0         :ld      (Tvar),a                  ; SLOPE 0 so calcualte YX = S X1lo * XX12+2
                        ld      hl,20       :ld a,h: ld (Svar),a : ld a,l: ld (XX1510),a  ; S x1lo = 20
                        ld      a,140       :ld      (XX12p2),a                ; XX12+2  140, gradient 0.546875
                        ld      a,0         :ld      (XX12p3),a                ; SLOPE DIRECTION so -ve result
                        ; post LL129 Q = 140 a = 00  SR YX = (20 * 140) /256 * -1 = -10 
                        call    LL120_6502  ; Expect mulitply so (Y X) -10      >> PASS
                        ;break
                        ld      a,0         :ld      (Tvar),a                  ; SLOPE 0 so calcualte YX = S X1lo * XX12+2
                        ld      hl,20       :ld a,h: ld (Svar),a : ld a,l: ld (XX1510),a  ; S x1lo = 20
                        ld      a,140       :ld      (XX12p2),a                ; XX12+2 140, gradient 0.546875
                        ld      a,$FF       :ld      (XX12p3),a                ; sLOPE DIRECTION so +ve result
                        ; post LL129 Q = 140 a = FF  SR = 20  YX = (20 * 140) /256 = 10 
                        call    LL120_6502  ; Expect / so (Y X)10                   >> PASS
                        ;break
                        ld      a,$FF       :ld      (Tvar),a                  ; SLOPE <> 0 so calcualte YX = S X1lo / XX12+2
                        ld      hl,20       :ld a,h: ld (Svar),a : ld a,l: ld (XX1510),a  ; S x1lo = 20
                        ld      a,140       :ld      (XX12p2),a                ; XX12+2 140, gradient 0.546875
                        ld      a,$00       :ld      (XX12p3),a                ; sLOPE DIRECTION  so -ve result
                        ; post LL129 Q = 140 a = 00  SR = 20  YX = (20 *256 / 140) = -36  
                        call    LL120_6502  ; Expect / so (Y X)-36
                        ld      a,$FF       :ld      (Tvar),a                  ; SLOPE <> 0 so calcualte YX = S X1lo / XX12+2
                        ld      hl,20       :ld a,h: ld (Svar),a : ld a,l: ld (XX1510),a  ; S x1lo = 20
                        ld      a,140       :ld      (XX12p2),a                ; XX12+2 140, gradient 0.546875
                        ld      a,$FF       :ld      (XX12p3),a                ; sLOPE DIRECTION  so +ve result
                        ; post LL129 Q = 140 a = 00 SR = 20 YX = (20 *256 / 140) = 36  
                        call    LL120_6502  ; Expect / so (Y X)  36                   >> PASS
                        ret
                ENDIF
;----------------------------------------------------------------------------------------------------------------------------
;-- Calculate the following:
;--         * If T = 0, this is a shallow slope, so calculate (Y X) = (S R) / XX12+2
;--         * If T <> 0, this is a steep slope, so calculate (Y X) = (S R) * XX12+2
;--             giving (Y X) the opposite sign to the slope direction in XX12+3.
                IFDEF DEBUG_LL123_DIRECT
Debug_LL123_6502:       ld      a,$00       :ld      (Tvar),a                  ; SLOPE 0 (Y X) = (S R) / XX12+2
                        ld      hl,20       :ld      (SRvarPair),hl
                        ld      a,140       :ld      (XX12p2),a                ; XX12+2 gradient 0.546875
                        ld      a,0         :ld      (XX12p3),a                ; sLOPE DIRECTION
                        call    LL123_6502  ; Expect * so (Y X)-36 = (20 / 140 ) * 256 * -1 PASS
                        ;break
                        ld      a,$00       :ld      (Tvar),a                  ; SLOPE 0 (Y X) = (S R) / XX12+2
                        ld      hl,20       :ld      (SRvarPair),hl
                        ld      a,140       :ld      (XX12p2),a                ; XX12+2 gradient 0.546875
                        ld      a,$FF       :ld      (XX12p3),a                ; sLOPE DIRECTION
                        call    LL123_6502  ; Expect * so (Y X)36 = (20 / 140 ) * 256  PASS
                        ;break
                        ld      a,$FF       :ld      (Tvar),a                  ; SLOPE <> 0 (Y X) = (S R) * XX12+2
                        ld      hl,20       :ld      (SRvarPair),hl
                        ld      a,140       :ld      (XX12p2),a                ; XX12+2 gradient 0.546875
                        ld      a,$00       :ld      (XX12p3),a                ; sLOPE DIRECTION
                        call    LL123_6502  ; Expect / so (Y X)-10 (20 * 140 ) / 256 * -1 PASS
                        ld      a,$FF       :ld      (Tvar),a                  ; SLOPE <> 0 (Y X) = (S R) * XX12+2
                        ld      hl,20       :ld      (SRvarPair),hl
                        ld      a,140       :ld      (XX12p2),a                ; XX12+2 gradient 0.546875
                        ld      a,$FF       :ld      (XX12p3),a                ; sLOPE DIRECTION
                        call    LL123_6502  ; Expect / so (Y X) 10 (20 * 140 ) / 256  PASS
                        ret
                ENDIF
                
                IFDEF DEBUG_LL118_DIRECT
Debug_LL118_6502:       ld      a,$FF       :ld      (Tvar),a                  ; SLOPE FF so steep
                        ld      hl,-20      :ld      (XX1510),hl               ; x1 = -20
                        ld      hl,-20      :ld      (XX1532),hl               ; y1 = -20
                        ld      a,120       :ld      (XX12p2),a                ; XX12+2 = 120 (120/256) = 0.46875   
                        ld      a,0         :ld      (XX12p3),a                ; Slope Direction so TL to BR
                        ; -20, -20 steep TL>BR, gradient 120/256: Dir -1 so 
                        call    LL118_6502  ; Expect * so x = 0 y =  -20 + (-20/(120/256)) = 22, x1 = 0 so stop there PASS
                        ;break

                        ld      a,$FF       :ld      (Tvar),a                  ; SLOPE FF so steep
                        ld      hl,-30      :ld      (XX1510),hl               ; x1 = -20
                        ld      hl,-20      :ld      (XX1532),hl               ; y1 = -20
                        ld      a,60        :ld      (XX12p2),a                ; XX12+2 = 120 (120/256) = 0.46875   
                        ld      a,0         :ld      (XX12p3),a                ; Slope Direction so TL to BR
                        ; -20, -20 steep TL>BR, gradient 120/256: Dir -1 so 
                        call    LL118_6502  ; Expect * so 108,0  PASS (fixed carry flag issue in LL121 and re-tested LL121)
                        ;break                        

                        ld      a,$0        :ld      (Tvar),a                  ; SLOPE FF so steep
                        ld      hl,-20      :ld      (XX1510),hl               ; x1 = -20
                        ld      hl,-20      :ld      (XX1532),hl               ; y1 = -20
                        ld      a,60        :ld      (XX12p2),a                ; XX12+2 = 120 (120/256) = 0.46875   
                        ld      a,0         :ld      (XX12p3),a                ; Slope Direction so TL to BR
                        ; -20, -20 steep TL>BR, gradient 120/256: Dir -1 so 
                        call    LL118_6502  ; Expect * so 108,0  PASS (fixed carry flag issue in LL121 and re-tested LL121)
                        ;break                        
                        ret

                ENDIF
               
                IFDEF DEBUG_LL28_6502
Debug_LL28_6502:        ld      a,27        :ld     (Qvar),a
                        ld      a,76
                        call    LL28_6502   ; Expect $FF carry
                        ;break                        
                        ld      a,76        :ld     (Qvar),a
                        ld      a,27        ; Expect 2
                        call    LL28_6502
                        ;break                
                        ld      a,200        :ld     (Qvar),a
                        ld      a,50
                        call    LL28_6502   ; Expect 4
                        ;break
                        ld      a,97        :ld     (Qvar),a
                        ld      a,76
                        call    LL28_6502   ; Expect 1
                        ;break
                        ld      a,$20       :ld     (Qvar),a
                        ld      a,$10
                        call    LL28_6502   ; Expect 1
                        ;break
                        ld      d,27
                        ld      a,76
                        call    AEquAmul256DivD
                        ;break
                        ld      d,76
                        ld      a,27
                        call    AEquAmul256DivD
                        ;break
                        ld      d,200
                        ld      a,50
                        call    AEquAmul256DivD
                        ;break
                        ld      d,$20
                        ld      a,$10
                        call    AEquAmul256DivD
                        ;break
                        ret
                ENDIF
                
                
                IFDEF DEBUG_LL145_6502
Debug_LL145_6502:       ; ld  a,1      : ld  (UbnkLineArrayLen),a
                        ; ld  hl,$0116 : ld  (UbnkLineArray),hl
                        ; ld  hl,$004B : ld  (UbnkLineArray+2),hl
                        ; ld  hl,$00F8 : ld  (UbnkLineArray+4),hl
                        ; ld  hl,$002F : ld  (UbnkLineArray+6),hl
                        ; call    DrawLinesLateClipping : ;break
                        ; ld  a,1      : ld  (UbnkLineArrayLen),a
                        ; ld  hl,$0033 : ld  (UbnkLineArray),hl
                        ; ld  hl,$0016 : ld  (UbnkLineArray+2),hl
                        ; ld  hl,$001D : ld  (UbnkLineArray+4),hl
                        ; ld  hl,$FFBE : ld  (UbnkLineArray+6),hl
                        ; call    DrawLinesLateClipping : ;break
                        ; ld  a,1      : ld  (UbnkLineArrayLen),a
                        ; ld  hl,$0055 : ld  (UbnkLineArray),hl
                        ; ld  hl,$FF83 : ld  (UbnkLineArray+2),hl
                        ; ld  hl,$0033 : ld  (UbnkLineArray+4),hl
                        ; ld  hl,$0016 : ld  (UbnkLineArray+6),hl
                        ; call    DrawLinesLateClipping :  ;break
                        
                        ;ld  a,1      : ld  (UbnkLineArrayLen),a
                        ;ld  hl,$00B3 : ld  (UbnkLineArray),hl
                        ;ld  hl,$0054 : ld  (UbnkLineArray+2),hl
                        ;ld  hl,$005d : ld  (UbnkLineArray+4),hl
                        ;ld  hl,$ffd5 : ld  (UbnkLineArray+6),hl
                        ;call    DrawLinesLateClipping :  ;break
                        ;
                        ;ld  a,1      : ld  (UbnkLineArrayLen),a
                        ;ld  hl,$005d : ld  (UbnkLineArray),hl
                        ;ld  hl,$ffd5 : ld  (UbnkLineArray+2),hl
                        ;ld  hl,$00b9 : ld  (UbnkLineArray+4),hl
                        ;ld  hl,$0028 : ld  (UbnkLineArray+6),hl
                        ;call    DrawLinesLateClipping :  ;break

                        ld  a,1      : ld  (UbnkLineArrayLen),a
                        ld  hl,$ffc7 : ld  (UbnkLineArray),hl
                        ld  hl,$001a : ld  (UbnkLineArray+2),hl
                        ld  hl,$005d : ld  (UbnkLineArray+4),hl
                        ld  hl,$ffd5 : ld  (UbnkLineArray+6),hl
                        call    DrawLinesLateClipping :  ;break
                       
                        ;ld  a,1      : ld  (UbnkLineArrayLen),a
                        ;ld  hl,$0089 : ld  (UbnkLineArray),hl
                        ;ld  hl,$00e2 : ld  (UbnkLineArray+2),hl
                        ;ld  hl,$fff3 : ld  (UbnkLineArray+4),hl
                        ;ld  hl,$00b9 : ld  (UbnkLineArray+6),hl
                        ;call    DrawLinesLateClipping :  ;break

                        ret
                ENDIF
        DEFINE DEBUG_6502_LINE_CLIPPING             
        IFDEF DEBUG_6502_LINE_CLIPPING
                        
xX13        DB 0
XX1510      DW 0    ; x1 as a 16-bit coordinate (x1_hi x1_lo)
XX1532      DW 0    ; y1 as a 16-bit coordinate (y1_hi y1_lo)
XX1554      DW 0    ; x2
XX1554p1    EQU XX1554+1
XX1576      DW 0    ; y2
XX1210      EQU XX1576
XX12p1      EQU XX1210+1
XX15X1lo    EQU XX1510
XX15X1hi    EQU XX1510+1
XX15Y1lo    EQU XX1532
XX15Y1hi    EQU XX1532+1
XX15X2lo    EQU XX1554
XX15X2hi    EQU XX1554+1
XX15Y2lo    EQU XX1210
XX15Y2hi    EQU XX1210+1

XX12p2      DB 0    ; The line's gradient * 256 (so 1.0 = 256)
XX12p3      DB 0    ; The direction of slope ; + LT to BR; - TR to BL
XX12p4      DB 0
XX12p5      DB 0
Delta_x     EQU XX12p2
Delta_y     EQU XX12p4
Tvar        DB 0    ; The gradient of slope ; 0 if it's a shallow slope (DX > DY) ; &FF if it's a steep slope (DY > DX)
                    ; Returns:  XX15        m         x1 as an 8-bit coordinate XX15+2               y1 as an 8-bit coordinate
Qvar        DB 0
Rvar        DB 0    ; general purpose for calcs  Paired with S must be done this way round for SUBHeightFromY1 etc to work
Svar        DB 0    ; sign variable    
SRvarPair   EQU Rvar                
Xreg        DB 0 
Yreg        DB 0
YXregPair   EQU Xreg

;-- Name: LL28 Calculate R = 256 * A / Q
;-- LL28+4              Skips the A >= Q check and always returns with C flag cleared, so this can be called if we know the division will work
;-- LL31                Skips the A >= Q check and does not set the R counter, so this can be used for jumping straight into the division loop if R is already set to 254 and we know the division will work
;   Reg mapping 6502  Z80
;               a     a
;               b     x
;               c     q
;               d     r
;               
LL28_6502:          ld      hl,Qvar                 ; CMP Q                  \ If A >= Q, then the answer will not fit in one byte,
                    ld      c,(hl)                  ; using c as Q var
                    cp      c
                    FlipCarryFlag
                    jp      c, LL2_6502             ; BCS LL2                \ so jump to LL2 to return 255
                    ld      b,$FE                   ; LDX #%11111110         \ Set R to have bits 1-7 set, so we can rotate through 7 loop iterations, getting a 1 each time, and then we use b as Rvar
LL31_6502:          sla     a                       ; ASL A                  \ Shift A to the left
                    jp      c,LL29_6502             ; BCS LL29               \ If bit 7 of A was set, then jump straight to the subtraction
                    FlipCarryFlag                   ;                          If A < N, then C flag is set.
                    JumpIfALTNusng c, LL31_SKIPSUB_6502 ; CMP Q              \ If A < Q, skip the following subtraction
                                                    ; BCC P%+4
                    sub     c                       ; SBC Q                  \ A >= Q, so set A = A - Q
                    ClearCarryFlag
LL31_SKIPSUB_6502:  FlipCarryFlag
                    rl      b                       ; ROL R                  \ Rotate the counter in R to the left, and catch the result bit into bit 0 (which will be a 0 if we didn't do the subtraction, or 1 if we did)
                    jp      c, LL31_6502            ; BCS LL31               \ If we still have set bits in R, loop back to LL31 to do the next iteration of 7
                    ld      a,b
                    ld      (Rvar),a
                    ret                             ; RTS                    \ R left with remainder of division
LL29_6502:          sub     c                       ; SBC Q                  \ A >= Q, so set A = A - Q
                    SetCarryFlag                    ; SEC                    \ Set the C flag to rotate into the result in R
                    rl      b                       ; ROL R                  \ Rotate the counter in R to the left, and catch the result bit into bit 0 (which will be a 0 if we didn't do the subtraction, or 1 if we did)
                    jp      c, LL31_6502            ; BCS LL31               \ If we still have set bits in R, loop back to LL31 to do the next iteration of 7
                    ld      a,b                     ; RTS                    \ Return from the subroutine with R containing the
                    ld      (Rvar),a                ; .
                    ret                             ; .                      \ remainder of the division
LL2_6502:           ld      a,$FF                   ; LDA #255               \ The division is very close to 1, so return the closest
                    ld      (Rvar),a                ; STA R                  \ possible answer to 256, i.e. R = 255
                    SetCarryFlag                    ; we failed so need carry flag set
                    ret                             ; RTS                    \ Return from the subroutine

ADDXRegtoY1:        ld      a,(Xreg)                ; Set y1 = y1 + (Y X)
                    ld      c,a
                    ld      b,0
                    ld      hl,(XX1532)
                    ClearCarryFlag                
                    adc     hl,bc
                    ld      (XX1532),hl
                    ret

ADDYXRegtoY1:       ld      bc,(YXregPair)          ; Set y1 = y1 + (Y X)
                    ld      hl,(XX1532)
                    ClearCarryFlag                
                    adc     hl,bc
                    ld      (XX1532),hl
                    ret

ADDYXRegtoX1:       ld      bc,(YXregPair)          ; Set x1 = x1 + (Y X)
                    ld      hl,(XX1510)
                    ClearCarryFlag                
                    adc     hl,bc
                    ld      (XX1510),hl
                    ret

SUBBCFromY1:        ld      hl,(XX1532)             ; Set (S R) = (y1_hi y1_lo) - BC where BC can be say screen height 
                    ClearCarryFlag                 
                    sbc     hl,bc
                    ld      (SRvarPair),hl
                    ret

AddSRToYX:          ld      hl,(YXregPair)
                    ld      de,(SRvarPair)
                    ClearCarryFlag
                    adc     hl,de
                    ld      (YXregPair),hl
                    ret



ClampX:             ld      a,h
                    and     a
                    ld      a,l
                    ret     z
                    jp      p,.Max255
.Min0:              ZeroA
                    ret
.Max255:            ld      a,$FF
                    ret

ClampY:             ld      a,h
                    and     a
                    jp      z,.ClampYlo
                    jp      p,.Max127
.Min0:              ZeroA
                    ret
.Max127:            ld      a,127
                    ret
.ClampYlo:          ld      a,l
                    and     a
                    ret     p
                    ld      a,127
                    ret
                    
;-- Rountes to code:
;-- LL118
;-- LL120   Done
;-- LL129   Done
;-- LL123   Done
                ; NOTE DOES ABS ONLY

                
                ;--- LL118 Move along a point until on screen
; In XX1510 x1 as a 16-bit coordinate (x1_hi x1_lo)
;    XX1532 y1 as a 16-bit coordinate (y1_hi y1_lo)
;    XX12p2 The line's gradient * 256 (so 1.0 = 256)
;    XX12p3 The direction of slope: * Positive = top left to bottom right * Negative (bit 7 set) = top right to bottom left
;    T      The gradient of slope:* 0 if it's a shallow slope * &FF if it's a steep slope
;  Out  XX150               x1 as an 8-bit coordinate
;       XX152               y1 as an 8-bit coordinate
;----------------------------------------------------------------------------------------------------------------

   
;---------------------------------------------------------------------------------------------------------------------
;--  Calculate the following:
;--   * If T = 0, this is a shallow slope, so calculate (Y X) = (S x1_lo) * XX12+2
;--   * If T <> 0, this is a steep slope, so calculate (Y X) = (S x1_lo) / XX12+2
;-- giving (Y X) the opposite sign to the slope direction in XX12+3.
;---------------------------------------------------------------------------------------------------------------------
LL120_6502:         ld      a,(XX1510)              ;LDA XX15               \ Set R = x1_lo
                    ld      (Rvar),a                ;STA R
                    call    LL129_6502              ;JSR LL129              \ Call LL129 to do the following:  Q = XX12+2 = line gradient, A = S EOR XX12+3 = S EOR slope direction  (S R) = |S R|
                    push    af                      ;PHA                    \ Store A on the stack so we can use it later
; DONT NEED PLUS MESSES UP FLAGS                    push    af                      ;LDX T                  \ If T is non-zero, then it's a steep slope, so jump
                    ld      a,(Tvar)                ; .
                    ld      (Xreg),a                ;. REDUNDANT REMOVE IN OPTIMISATION
                    and     a                       ;BNE LL121              \ down to LL121 to calculate this instead (Y X) = (S R) / Q
; DONT NEED PLUS MESSES UP FLAGS                    pop     af                      ;.                      (recover teh saved A before the cp)
                    jr      nz,LL121_6502           ;.
;..   (Y X) = (S R) * Q - must be ABS, sign determined by opposite of the sign of the value on top of stack
LL122_6502:         ZeroA                           ;LDA #0                 \ Set A = 0
            IFDEF DEBUG_LL122_DIRECT
                    DISPLAY "DIRECT CALL TO LL122 so dummy push a to stack with 0"
                    push    af
            ENDIF             
                    ld      (Xreg),a                ;TAX                    \ Set (Y X) = 0 so we can start building the answer here
                    ld      (Yreg),a                ;TAY
                    ld      hl,Svar
                    ld      bc,(SRvarPair)          ;LSR S                  \ Shift (S R) to the right, so we extract bit 0 of (S R)
                    ShiftBCRight1                   ;ROR R                  \ into the C flag
                    ld      (SRvarPair),bc
                    ld      hl, Qvar                ;ASL Q                  \ Shift Q to the left, catching bit 7 in the C flag
                    sla     (hl)                    ;.
                    jr      nc, LL126_6502          ;BCC LL126              \ If C (i.e. the next bit from Q) is clear, do not do
                                                    ;                         the addition for this bit of Q, and instead skip to LL126 to just do the shifts
LL125_6502:         call    AddSRToYX               ;TXA                    \ Set (Y X) = (Y X) + (S R)  starting with the low bytes And then doing the high bytes
LL126_6502:         ld      bc,(SRvarPair)          ;LSR S                  \ Shift (S R) to the right
                    ShiftBCRight1                   ;ROR R
                    ld      (SRvarPair),bc          ;.
                    ld      hl, Qvar                ;ASL Q                  \ Shift Q to the left, catching bit 7 in the C flag
                    sla     (hl)                    ;.
                    jr      c,LL125_6502            ;BCS LL125              \ If C (i.e. the next bit from Q) is set, loop back to LL125 to do the addition for this bit of Q
                    jr      nz,LL126_6502           ;BNE LL126              \ If Q has not yet run out of set bits, loop back to LL126 to do the "shift" part of shift-and-add until we have done additions for all the set bits in Q, to give us our multiplication result
                    pop     af                      ;PLA                    \ Restore A, which we calculated above, from the stack
                    and     a                       ;BPL LL133              \ If A is positive jump to LL133 to negate (Y X) and
                    jp      p,LL133_6502            ;.
;.. return from the subroutine using a tail call
                    ret                             ;RTS                    \ Return from the subroutine

;----------------------------------------------------------------------------------------------------------------------------
;-- Calculate the following:
;--         * If T = 0, this is a shallow slope, so calculate (Y X) = (S R) / XX12+2 (does not use X1lo but directly SR)
;--         * If T <> 0, this is a steep slope, so calculate (Y X) = (S R) * XX12+2  (does not use X1lo but directly SR)
;--             giving (Y X) the opposite sign to the slope direction in XX12+3.
LL123_6502:         call    LL129_6502              ;JSR LL129              \ Call LL129 to do the following   Q = XX12+2   = line gradient
                    push    af                      ;PHA                    \ Store A on the stack so we can use it later
; DONT NEED PLUS MESSES UP FLAGS                    push    af                      ;LDX T                  \ If T is non-zero, then it's a steep slope, so jump up
                    ld      a,(Tvar)                ; .
                    ld      (Xreg),a                ;BNE LL122              \ to LL122 to calculate this instead:
                    and     a                       ;.
;  DONT NEED PLUS MESSES UP FLAGS                    pop     af                      ;.
                    jr      nz,LL122_6502           ;.                  
;--  The following calculates: (Y X) = (S R) / Q using the same shift-and-subtract algorithm that's documented in TIS2
LL121_6502:         ld      a,$FF                   ;LDA #%11111111         \ Set Y = %11111111
                    ld      (Yreg),a                ;TAY
                    sla     a                       ;ASL A                  \ Set X = %11111110
                    ld      (Xreg),a                ;TAX
;--  This sets (Y X) = %1111111111111110, so we can rotate through 15 loop iterations, getting a 1 each time, and then getting a 0 on the 16th iteration... and we can also use it to catch our result bits into bit 0 each time
LL130_6502:         ld      bc,(SRvarPair)          ;ASL R                  \ Shift (S R) to the left
                    ShiftBCLeft1                    ;.
                    ld      (SRvarPair),bc          ;ROL S
                    ld      a,(Svar)                ;LDA S                  \ Set A = S
                    jr      c, LL131_6502           ;BCS LL131              \ If bit 7 of S was set, then jump straight to the subtraction
                    ld      hl,Qvar                 ;CMP Q                  \ If A < Q (i.e. S < Q), skip the following subtractions
                    cp      (hl)
                    FlipCarryFlag                   ; note flip carry flag here to simulate 6502 operation
                    jr      nc,LL132A_6502          ;BCC LL132  (NOTE Carry flag reversed in Z80 for CP)
LL131_6502:         FlipCarryFlag                   ;flip carry to make it act like a 6502 borrow
                    sbc     (hl)                    ;SBC Q                  \ A >= Q (i.e. S >= Q) so set:
                    ld      (Svar),a                ;STA S                  
                    ld      a,(Rvar)                ;LDA R                  \ And then doing the high bytes
                    ClearCarryFlag                  ;\   S = (A R) - Q  = (S R) - Q starting with the low bytes (we know the C flag is set so the subtraction will be correct)
                    sbc     0                       ;SBC #0
                    ld      (Rvar),a                ;STA R
                    SetCarryFlag                    ;SEC                    \ Set the C flag to rotate into the result in (Y X)
                    jp      LL132_6502              ;added so that we can do a 6502 style carry above
LL132A_6502:        nop; FlipCarryFlag
LL132_6502:         ld      bc,(YXregPair)          ; Rotate the counter in (Y X) to the left, and catch the 
                    RollBCLeft1                     ; ROL A                  \ result bit into bit 0 (which will be a 0 if we didn't
                    ld      (YXregPair),bc          ; TAX                    \ do the subtraction, or 1 if we did)
                    jr      c, LL130_6502           ; BCS LL130              \ If we still have set bits in (Y X), loop back to LL130 to do the next iteration of 15, until we have done the whole division
            IFDEF DEBUG_LL121_DIRECT
                    DISPLAY "DIRECT CALL TO LL121 so dummy push"
                    push    af
            ENDIF      
                    pop     af                      ; PLA                    \ Restore A, which we calculated above, from the stack
                    and     a                       ; BMI LL128              \ If A is negative jump to LL128 to return from the
                    jp      m, LL128_6502           ; .                      \ subroutine with (Y X) as is
LL133_6502:         ld      bc,(YXregPair)          ; TXA                    \ Otherwise negate (Y X) using two's complement by first
                    macronegate16bc                 ; EOR #%11111111         \ setting the low byte to ~X + 1
                    ld      (YXregPair),bc          ; ADC #1                 \ The addition works as we know the C flag is clear from\ when we passed through the BCS above
LL128_6502:         ret                             ; RTS                    \ Return from the subroutine
;------------------------------------------------------------------------------------------------------- 
;..  Do the following, in this order: Q = XX12+2 A = S EOR XX12+3 (S R) = |S R|
;..  This sets up the variables required above to calculate (S R) / XX12+2 and give the result the opposite sign to XX13+3.
LL129_6502:         push    af                      ;LDX XX12+2             \ Set Q = XX12+2
                    ld      a,(XX12p2)              ;.
                    ld      (Xreg),a                ;.
                    ld      (Qvar),a                ;STX Q
                    pop     af                      ;.
                    ld      a,(Svar)                ;LDA S                  \ If S is positive, jump to LL127
                    and     a                       ;BPL LL127
                    jp      p,LL127_6502            ;.
                    ZeroA                           ;.LDA #0                \ Otherwise set R = -R
                    ClearCarryFlag                  ;SEC
                    ld      hl, Rvar                ;SBC R
                    sbc     (hl)                    ;.
                    ld      (Rvar),a                ;STA R
                    ld      a,(Svar)                ;LDA S                  \ Push S onto the stack
                    push    af                      ;PHA
                    xor     $FF                     ;EOR #%11111111         \ Set S = ~S + 1 + C  ?? is this all just doing |Svar|?
                    adc     0                       ;ADC #0
                    ld      (Svar),a                ;STA S
                    pop     af                      ;PLA                    \ Pull the original, negative S from the stack into A
LL127_6502:         ld      hl,XX12p3               ;EOR XX12+3             \ Set A = original argument S EOR'd with XX12+3
                    xor     (hl)                    ;.
                    ret                             ;RTS                    \ Return from the subroutine                    
;----------------------------------------------------------------------------------------------------------------
;--- LL118 Move along a point until on screen
; In XX1510 x1 as a 16-bit coordinate (x1_hi x1_lo)
;    XX1532 y1 as a 16-bit coordinate (y1_hi y1_lo)
;    XX12p2 The line's gradient * 256 (so 1.0 = 256)
;    XX12p3 The direction of slope: * Positive = top left to bottom right * Negative (bit 7 set) = top right to bottom left
;    T      The gradient of slope:* 0 if it's a shallow slope * &FF if it's a steep slope
;  Out  XX150               x1 as an 8-bit coordinate
;       XX152               y1 as an 8-bit coordinate
;----------------------------------------------------------------------------------------------------------------

LL118_6502:         ld      a,(XX1510+1)            ; LDA XX15+1             \ If x1_hi is positive, jump down to LL119 to skip the
                    and     a                       ; BPL LL119              \ .
                    jp      p, LL119_6502           ;                        \ following
.X1Negative:        ld      (Svar),a                ; STA S                  \ Otherwise x1_hi is negative, i.e. off the left of the screen, so set S = x1_hi
                    call    LL120_6502              ; Call LL120 to calculate:  (Y X) = (S x1_lo) * XX12+2      if T = 0   = x1 * gradient
                                                    ;                            (Y X) = (S x1_lo) / XX12+2      if T <> 0  = x1 / gradient
                                                    ; with the sign of (Y X) set to the opposite of the line's direction of slope
                    call    ADDYXRegtoY1             ; Set y1 = y1 + (Y X)
                    ld      (XX1532),hl             ; .
                    ld      hl,0                    ; Set x1 = 0
                    ld      (XX1510),hl             ; .
                    ld      a,0                     ; set 0 up for replacemetn of the TAX and BEQ bit
                    ld      (Xreg),a                ; TAX                    \ Set X = 0 so the next BEQ becomes a jmp but we will do it anyway in next line
                    jp      LL134_6502              ; just do the jump to LL134 rather than setting to equal flag and then jumping
;-- Entering LL119 a will always be the value of X1 Hi byte
LL119_6502:         jp      z,LL134_6502            ; BEQ LL134              \ x1_hi = 0 then jump down to LL134 to skip the following, as the x-coordinate is already on-screen
                                                    ;                        \ (as 0 <= (x_hi x_lo) <= 255)
                    ld      (Svar),a                ; STA S                  \ Otherwise x1_hi is positive, i.e. x1 >= 256 and off
                    dec     a                       ; DEC S                  \ the right side of the screen, so set S = x1_hi - 1
                    ld      (Svar),a                ;
                    call    LL120_6502              ; JSR LL120              \ Call LL120 to calculate:  (Y X) = (S x1_lo) * XX12+2      if T = 0   = (x1 - 256) * gradient
                                                    ;                        \                           (Y X) = (S x1_lo) / XX12+2      if T <> 0 = (x1 - 256) / gradient
                                                    ;                        \ with the sign of (Y X) set to the opposite of the line's direction of slope
                    call    ADDYXRegtoY1             ; TXA                    \ Set y1 = y1 + (Y X)
                    ld      hl,255                  ; LDX #255               \ Set x1 = 255
                    ld      (XX1510),hl             ; STX XX15 ;INX; STX XX15+1
;--  We have moved the point so the x-coordinate is on  screen (i.e. in the range 0-255), so now for the  y-coordinate
LL134_6502:         ld      a,(XX1532+1)            ; LDA XX15+3             \ If y1_hi is positive, jump down to LL119 to skip
                    and     a                       ; BPL LL135              \ the following
                    jp      p, LL135_6502           ; .
                    ld      (Svar),a                ; STA S                  \ Otherwise y1_hi is negative, i.e. off the top of the screen, so set S = y1_hi
                    ld      a, (XX1532)             ; LDA XX15+2             \ Set R = y1_lo
                    ld      (Rvar),a                ; STA R
                    call    LL123_6502              ; JSR LL123              \ Call LL123 to calculate:  (Y X) = (S R) / XX12+2      if T = 0 = y1 / gradient
                                                    ;                        \                           (Y X) = (S R) * XX12+2      if T <> 0 = y1 * gradient
                                                    ;                         with the sign of (Y X) set to the opposite of the line's direction of slope
                    call    ADDYXRegtoX1            ; TXA                    \ Set x1 = x1 + (Y X)
                    ld      hl,0                    ; LDA #0                 \ Set y1 = 0
                    ld      (XX1532),hl             ; STA XX15+2, XX15+3
LL135_6502:         ld      bc,128                  ; LDA XX15+2             \ Set (S R) = (y1_hi y1_lo) - screen height
                    call    SUBBCFromY1             ; .                      \ .
                    jr      c, LL136_6502           ; BCC LL136              \ If the subtraction underflowed, i.e. if y1 < screen height, then y1 is already on-screen, so jump to LL136
                                                    ;                        \ to return from the subroutine, as we are done
;;-   If we get here then y1 >= screen height, i.e. off the bottom of the screen
LL139_6502:         call    LL123_6502              ; JSR LL123              \ Call LL123 to calculate:   (Y X) = (S R) / XX12+2      if T = 0  = (y1 - screen height) / gradient
                                                    ;                        \                            (Y X) = (S R) * XX12+2      if T <> 0 = (y1 - screen height) * gradient
                                                    ;                          with the sign of (Y X) set to the opposite of the line's direction of slope
                    call    ADDYXRegtoX1            ; TXA                    \ Set x1 = x1 + (Y X)
                    ld      hl, 127                 ; LDA #Y*2-1             \ Set y1 = 2 * #Y - 1. The constant #Y is 96, the y-coordinate of the mid-point of the space view (or in our case 127)
                    ld      (XX1532),hl             ; STA XX15+3             \ pixel row of the space view
LL136_6502:         ret                             ; RTS                    \ Return from the subroutine
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-- LL145 LINE CLIP
;-- OPTISIATIONS - VERTICAL HORZONTAL POINT |DX| = |DY| (and all the veriants for +/-)
;-- This routine clips the line from (x1, y1) to (x2, y2) so it fits on-screen, or returns an error if it can't be clipped to fit. The arguments are 16-bit coordinates, and the clipped line is returned using 8-bit screen coordinates.
;-- This part sets XX13 to reflect which of the two points are on-screen and off-screen.
;-- IN  : XX15(1 0) x1 XX15(3 2) y1 XX15(5 4) x2 XX12(1 0) y2
;-- OUT : (X1, Y1), (X2, Y2) Screen coordinate C flag  Clear if the clipped line fits on-screen, set if itdoesn't
;         XX13 The state of the original coordinates on-screen:* 0   = (x2, y2) on-screen* 95(64)  = (x1, y1) on-screen,  (x2, y2) off-screen* 191(128) = (x1, y1) off-screen, (x2, y2) off-screen
;              So XX13 is non-zero if the end of the line was clipped,meaning the next line sent to BLINE can't join onto the end but has to start a new segment
;         SWAP The swap status of the returned coordinates:* &FF if we swapped the values of (x1, y1) and(x2, y2) as part of the clipping process* 0 if the coordinates are still in the same order
                    DISPLAY "TODO: treat horz vert and sigle pixel as special cases"
; TODO treat horizonal/vert and single pixel as special cases
LL145_6502:         ZeroA                           ; LDA #0                 \ Set SWAP = 0
                    ld      (SWAP),a                ; STA SWAP
                    ld      a,(XX1554+1)            ; LDA XX15+5             \ Set A = x2_hi (use b as a substibute for a)
                    ld      b,a                     ; .
; Note that as we are interested in the sign of XX113 then this needs to be >= 128 or < 128 or 0, we will use 191 as per bbc for now
; for the screen coord we will use 127 though, we use c as a temporay X register
LL147_6502:         ld      a,191                   ; LDX #Y*2-1             \ Set X = #Y * 2 - 1. The constant #Y is 96, the y-coordinate of the mid-point of the space view, so this sets Y2 to 191, the y-coordinate of the bottom pixel row of the space view
                    ld      (Xreg),a                ; .
;                    ld      a,127
;                    ld      c,a
.CheckX2Y2High:     ld      a,b                     ; ORA XX12+1             \ If one or both of x2_hi and y2_hi are non-zero, jump
                    ld      hl,XX12p1               ; .
                    or      (hl)                    ; .
                    jp      nz,LL107_6502           ; BNE LL107              \ to LL107 to skip the following, leaving X at 191
.CheckY2Lo:         ld      a,127 ;,c               ; get back the temporary x reg from c
                    ld      hl,XX1210               ; CPX XX12               \ If y2_lo > the y-coordinate of the bottom of screen (a is being used as X at this point still)
                    cp      (hl)                    ; .
                    jp      c,LL107_6502            ; BCC LL107              \ then (x2, y2) is off the bottom of the screen, so skip the following instruction, leaving X at 127
                    ZeroA                           ; LDX #0                 \ Set X = 0
                    ld      (Xreg),a            
LL107_6502:         ld      a,(Xreg)                ; STX XX13               \ Set XX13 = X, so we have * XX13 = 0 if x2_hi = y2_hi = 0, y2_lo is on-screen* XX13 = 191 if x2_hi or y2_hi are non-zero or y2_lois off the bottom of the screen
                    ld      (XX13),a                ; now c is released as a temporary x reg
                    ld      a,(XX1510+1)            ; LDA XX15+1             \ If one or both of x1_hi and y1_hi are non-zero, jump
                    ld      hl,XX1532+1             ; ORA XX15+3             \ to LL83
                    or      (hl)                    ; .
                    jp      nz,LL83_6502            ; BNE LL83
; DEBUG SIMPLIFIED CODE, now we just compare y1 lo > 127
                    ld      a,(XX1532)              ; If y1_lo > the y-coordinate of the bottom of screen (If A >= N, then C flag is reset.) ;ld      a,127                   ; LDA #Y*2-1             \ If y1_lo > the y-coordinate of the bottom of screen (If A >= N, then C flag is reset.)
                    ld      h,127                   ; then (x1, y1) is off the bottom of the screen, so jump                                 ;ld      hl,XX1532               ; CMP XX15+2             \ then (x1, y1) is off the bottom of the screen, so jump
                    cp      h                       ; to LL83                                                                                ;cp      (hl)                    ; .                      \ to LL83
                    jp      nc, LL83_6502         ; BCC LL83               \ . (y1 > 127 jump, i.e. 127 <= y1 )
                    ld      a,(XX13)                ; LDA XX13               \ If we get here, (x1, y1) is on-screen. If XX13 is non-zero, i.e. (x2, y2) is off-screen, jump
                    and     a                       ; BNE LL108              \ to LL108 to halve it before continuing at LL83
                    jp      nz,LL108_6502               
; If we get here, the high bytes are all zero, which means the x-coordinates are < 256 and therefore fit on screen, and neither coordinate is off the bottom of the screen. That means both coordinates are already on
; screen, so we don't need to do any clipping, all weneed to do is move the low bytes into (X1, Y1) and X2, Y2) and return
; X1 = XX15 (10)  Y1 = XX15+1 X2 = XX15+2 Y2 = XX15+3 
    DEFINE CLAMPINGEXTREMES
LL146_6502: IFDEF CLAMPINGEXTREMES
                    ld      hl,(XX1510)             ;  Save X1 to XX1510
                    call    ClampX
                    ld      (XX1510),a
            ENDIF
                    ld      hl,(XX1532)             ;  hl = y1
                    call    ClampY
                    ld      (XX1510+1),a            ;  XX1510... = [X1][Y1]
                    
                    ld      hl,(XX1554)             ;  de = x2
                    call    ClampX
                    ld      (XX1510+2),a            ;  XX1510... = [X1][Y1][X2]
                    
                    ld      hl,(XX1576)             ;  bc = y2
                    call    ClampY
                    ld      (XX1510+3),a            ;  XX1510... = [X1][Y1][X2][Y2]
                    
                    ClearCarryFlag                  ; CLC                    \ Clear the C flag as the clipped line fits on-screen
                    ret                             ; RTS                    \ Return from the subroutine
LL109_6502:         SetCarryFlag                    ; SEC                    \ Set the C flag to indicate the clipped line does not fit on-screen
                    ret                             ; RTS                    \ Return from the subroutine
LL108_6502:         ld      hl,XX13                 ; LSR XX13               \ If we get here then (x2, y2) is off-screen and XX13 is
                    srl     (hl)                    ;                        \ 191, (128)  so shift XX13 right to halve it to 95 (64)
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-- LL145 (Part 2 of 4)                               
LL83_6502:          ld      a,(XX13)                ; LDA XX13               \ If XX13 < 128 then only one of the points is on-screen
                    and     a                       ; BPL LL115              \ so jump down to LL115 to skip the checks of whether
                    jp      p,LL115_6502            ;                        \ both points are in the strips to the right or bottom of the screen
;-- If we get here, both points are off-screen
                    ld      a,(XX1510+1)            ; LDA XX15+1             \ If both x1_hi and x2_hi have bit 7 set, jump to LL109
                    ld      hl,XX1554+1             ; AND XX15+5             \ to return from the subroutine with the C flag set, as
                    and     (hl)
                    jp      m, LL109_6502           ; BMI LL109              \ the entire line is above the top of the screen
                    ld      a,(XX1532+1)            ; LDA XX15+3             \ If both y1_hi and y2_hi have bit 7 set, jump to LL109
                    ld      hl,XX1576+1             ; AND XX12+1             \ to return from the subroutine with the C flag set, as
                    and     (hl)                    ; BMI LL109              \ the entire line is to the left of the screen
                    jp      m,LL109_6502            ; .
                    ld      a,(XX1510+1)            ; LDX XX15+1             \ Set A = X = x1_hi - 1
                    dec     a                       ; DEX
                    ld      (Xreg),a                ; TXA
                    push    af                      ; LDX XX15+5     SP+1    \ Set XX12+2 = x2_hi - 1, we need to save a register first
                    ld      a,(XX1554+1)            ; .
                    dec     a                       ; DEX
                    ld      (Xreg),a                ; STX XX12+2
                    pop     af                      ; .              SP+0    restore a register
                    ld      hl,XX1576+1             ; ORA XX12+2             \ If neither (x1_hi - 1) or (x2_hi - 1) have bit 7 set,
                    or      (hl)                    ; .
                    jp      p, LL109_6502           ; BPL LL109              \ jump to LL109 to return from the subroutine with the C flag set, as the line doesn't fit on-screen
; for this bit, while z80 uses carry the opposite way to 6502, 6502 uses borrow, in effect inverting the flip
;NOTEFOUND A PATH WHERE IT DOES NOT DO THIS CHECK e.g. 90 B2 8D A2
LL83_DEBUG:         ld      a,(XX1532)              ; LDA XX15+2             \ If y1_lo < y-coordinate of screen bottom, clear the C
                    cp      128                     ; CMP #Y*2               \ flag, otherwise set it (NOTE FLIPPED IN z80)                   
                    ld      a,(XX1532+1)            ; LDA XX15+3             \ Set XX12+2 = y1_hi - (1 - C), so:
;                    FlipCarryFlag                   ; as 6502 uses borrow in subtracts we flip for SBC as z80 CP does opposite too, if A < N carry set so flip
                    sbc     0                       ; SBC #0                 \ .
                    ld      (XX12p2),a              ; STA XX12+2             \  * Set XX12+2 = y1_hi - 1 if y1_lo is on-screen * Set XX12+2 = y1_hi  otherwise We do this subtraction because we are only interested
                    ld      a,(XX1576)              ; LDA XX12               \ If y2_lo < y-coordinate of screen bottom, clear the C
                    cp      128                     ; CMP #Y*2               \ flag, otherwise set it
                    ld      a,(XX1576+1)            ; LDA XX12+1             \ Set XX12+2 = y2_hi - (1 - C), so:
;                    FlipCarryFlag
                    sbc     0                       ; SBC #0                   * Set XX12+1 = y2_hi - 1 if y2_lo is on-screen  * Set XX12+1 = y2_hi     otherwise
                    ld      hl,XX12p2               ; ORA XX12+2             \ If neither XX12+1 or XX12+2 have bit 7 set, jump to
                    or      (hl)                    ; .
                    jp      p,LL109_6502            ; BPL LL109              \ LL109 to return from the subroutine with the C flag set, as the line doesn't fit on-screen
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-- LL145 (Part 3 of 4) Summary: Clip line: Calculate the line's gradient
LL115_6502:         ld      a,(Yreg)                ; TYA                    \ Store Y on the stack so we can preserve it through the call to this routine
                    push    af                      ; PHA            SP+1    \ call to this subroutine
                    ld      hl,(XX1554)             ; LDA XX15+4             \ Set XX12+2 = x2_lo - x1_lo
                    ld      de,(XX1510)             ; LDA XX15+5             \ Set XX12+3 = x2_hi - x1_hi
                    ClearCarryFlag                  ; SBC XX15+1
                    sbc     hl,de                   ; .
                    ld      (delta_x),hl            ; .
                    ld      hl,(XX1576)             ; LDA XX12               \ Set XX12+4 = y2_lo - y1_lo
                    ld      de,(XX1532)             ; 
                    ClearCarryFlag                  ; SBC XX15+2
                    sbc     hl,de                   ; .
                    ld      (delta_y),hl            ; .
; So we now have:  delta_x in XX12(3 2)  delta_y in XX12(5 4) where the delta is (x1, y1) - (x2, y2))
                    ld      a,(delta_y+1)           ; EOR XX12+3             \ Set S = the sign of delta_x * the sign of delta_y, so
                    ld      hl,delta_x+1
                    xor     (hl)
                    ld      (Svar),a                ; STA S                  \ if bit 7 of S is set, the deltas have different signs (perhaps we should do bit 7 mask ?????????
                    ld      hl,(delta_y)            ; LDA XX12+5             \ If delta_y_hi is positive, jump down to LL110 to skip
                    ld      a,h
                    and     a
                    jp      p, LL110_6502           ; BPL LL110              \ the following
                    NegHL                           ; LDA #0                 \ Otherwise flip the sign of delta_y to make it
                    ld      (delta_y),hl            ; positive, starting with the low bytes
LL110_6502:         ld      hl,(delta_x)            ; LDA XX12+3             \ If delta_x_hi is positive, jump down to LL111 to skip
                    ld      a,h                     ; BPL LL111              \ the following
                    and     a                       ; .
                    jp      p,LL111_6502            ; .
                    NegHL                           ; SEC                    \ Otherwise flip the sign of delta_x to make it
                    ld      (delta_x),hl            ; LDA #0                 \ positive, starting with the low bytes
;--  We now keep halving |delta_x| and |delta_y| until both of them have zero in their high bytes
LL111_6502:         ld      hl,(delta_x)
                    ld      de,(delta_y)
                    ld      a,h                     ; TAX                    \ If |delta_x_hi| is non-zero, skip the following
                    or      d                       ; BNE LL112
                    jp      z,LL113_6502            ; LDX XX12+5             \ If |delta_y_hi| = 0, jump down to LL113 (as both |delta_x_hi| and |delta_y_hi| are 0)
LL112_6502:         ShiftHLRight1                   ; LSR A                  \ Halve the value of delta_x in (A XX12+2)
                    ShiftDERight1                   ; LSR XX12+5             \ Halve the value of delta_y XX12(5 4)
                    ld      (delta_x),hl
                    ld      (delta_y),de            ; write them back so we don't end up in an infinite loop
                    jp  LL111_6502                  ; JMP LL111              \ Loop back to LL111
;-- By now, the high bytes of both |delta_x| and |delta_y| are zero
LL113_6502:         ZeroA                           ; STX T                  \ We know that X = 0 as that's what we tested with a BEQ  above, so this sets T = 0
                    ld  (Tvar),a
                    ld      a,(delta_x)             ; LDA XX12+2             \ If delta_x_lo < delta_y_lo, so our line is more
                    ld      hl,delta_y              ; CMP XX12+4             \ vertical than horizontal, jump to LL114
                    cp      (hl)
                    jp      c, LL114_6502           ; BCC LL114              ; if delta y > delta x then its a steep slope so we do 256*dy/dx
;-- If we get here then our line is more horizontal than vertical, so it is a shallow slope
                    ld      a,(delta_x)             ; STA Q                  \ Set Q = delta_x_lo
                    ld      (Qvar),a                ; .
                    ld      a,(delta_y)             ; LDA XX12+4             \ Set A = delta_y_lo
                    call    LL28_6502               ; JSR LL28               \ Call LL28 to calculate: R = 256 * A / Q = 256 * delta_y_lo / delta_x_lo
                    jp      LL116_6502              ; JMP LL116              \ Jump to LL116, as we now have the line's gradient in R
;-- If we get here then our line is more vertical than horizontal, so it is a steep slope
LL114_6502:         ld      a,(delta_y)             ; LDA XX12+4             \ Set Q = delta_y_lo
                    ld      (Qvar),a                ; STA Q
                    ld      a,(delta_x)             ; LDA XX12+2             \ Set A = delta_x_lo
                    call    LL28_6502               ; JSR LL28               \ Call LL28 to calculate: R = 256 * A / Q = 256 * delta_x_lo / delta_y_lo
                    ld      a,$FF                   ; DEC T                  \ T was set to 0 above, so this sets T = &FF when our
                    ld      (Tvar),a                ;                        \ line is steep
;----------------------------------------------------------------------------------------------------------------
;--- LL116 This part sets things up to call the routine in LL188, which does the actual clipping.
;--  If we get here, then R has been set to the gradient of the line (x1, y1) to(x2, y2), with T indicating the gradient of slope: * 0   = shallow slope (more horizontal than vertical)
;--                                                                                                                                * &FF = steep slope (more vertical than horizontal)
;-- XX13 has been set as follows: * 0   = (x1, y1) off-screen, (x2, y2) on-screen * 95(64)  = (x1, y1) on-screen,  (x2, y2) off-screen * 191(128) = (x1, y1) off-screen, (x2, y2) off-screen
LL116_6502:         ld      a,(Rvar)                ; LDA R                  \ Store the gradient in XX12+2
                    ld      (XX12p2),a              ; STA XX12+2
                    ld      a,(Svar)                ; LDA S                  \ Store the type of slope in XX12+3, bit 7 clear means
                    ld      (XX12p3),a              ; STA XX12+3             \ top left to bottom right, bit 7 set means top right to bottom left
                    ld      a,(XX13)                ; LDA XX13               \ If XX13 = 0, skip the following instruction
                    cp      0                       ; BEQ LL138
                    jp      z,LL138_6502            ; .
                    jp      p, LLX117_6502          ; If XX13 is positive, it must be 95 (64) as 128 would be negative). This means (x1, y1) is on-screen but (x2, y2) isn't, so we jump        
;-- If we get here, XX13 = 0 or 191, so (x1, y1) is off-screen and needs clipping
LL138_6502:         call    LL118_6502              ; JSR LL118              \ Call LL118 to move (x1, y1) along the line onto the screen, i.e. clip the line at the (x1, y1) end
                    ld      a,(XX13)                ; LDA XX13               \ If XX13 = 0, i.e. (x2, y2) is on-screen, jump down to
                    and     a
                    jp      p,LL124_6502            ; BPL LL124              \ LL124 to return with a successfully clipped line
;-- If we get here, XX13 = 191 (128) (both coordinates areoff-screen)
LL117_6502:         ld      a,(XX1510+1)            ; LDA XX15+1             \ If either of x1_hi or y1_hi are non-zero, jump to
                    ld      hl,XX1532+1             ; ORA XX15+3             \ LL137 to return from the subroutine with the C flag
                    or      (hl)
                    jp      nz, LL137_6502          ; BNE LL137              \ set, as the line doesn't fit on-screen
                    ld      a,(XX1532)              ; LDA XX15+2             \ If y1_lo > y-coordinate of the bottom of the screen
                    cp      128                     ; CMP #Y*2               \ jump to LL137 to return from the subroutine with the
                    jp      nc, LL137_6502          ; BCS LL137              \ C flag set, as the line doesn't fit on-screen
;-- If we get here, XX13 = 95 or 191, and in both cases (x2, y2) is off-screen, so we now need to swap the (x1, y1) and (x2, y2) coordinates around before doing the actual clipping, because we need to clip (x2, y2) but the clipping routine at LL118 only clips (x1, y1)
LLX117_6502:        ld      hl,(XX1510)             ; LDX XX15               \ Swap x1_lo = x2_lo
                    ld      de,(XX1554)
                    ld      (XX1510),de
                    ld      (XX1554),hl
                    ld      hl,(XX1532)             ; LDX XX15+2             \ Swap y1_lo = y2_lo
                    ld      de,(XX1576) 
                    ld      (XX1532),de
                    ld      (XX1576),hl
                    call    LL118_6502              ; JSR LL118              \ Call LL118 to move (x1, y1) along the line onto the screen, i.e. clip the line at the (x1, y1) end
                    ld      hl,SWAP
                    dec     (hl)                    ; DEC SWAP               \ Set SWAP = &FF to indicate that we just clipped the line at the (x2, y2) end by swapping the coordinates (the DEC does this as we set SWAP to 0 at the start of this subroutine)
LL124_6502:         pop     af                      ; PLA            SP+0    \ Restore Y from the stack so it gets preserved through
                    ld      (Yreg),a                ; TAY                    \ the call to this subroutine
                    call    LL146_6502              ; JMP LL146              \ Jump up to LL146 to move the low bytes of (x1, y1) and (x2, y2) into (X1, Y1) and (X2, Y2), and return from the subroutine with a successfully clipped line
                    ret                             ; then exit so we don't pop it twice
LL137_6502:         pop     af                      ; PLA            SP+0    \ Restore Y from the stack so it gets preserved through
                    ld      (Yreg),a                ; TAY                    \ the call to this subroutine
                    SetCarryFlag                    ; SEC                    \ Set the C flag to indicate the clipped line does not fit on-screen
                    ret                             ; RTS                    \ Return from the subroutine
        ENDIF