;--------------------------------------------------------------------------------------------------------------------

clipDx                  DB      0           ; also XX12+2
clipDxHigh              DB      0           ; also XX12+3
clipDxHighNonABS        DB      0           ; also XX12+3
clipDy                  DB      0           ; also XX12+4
clipDyHigh              DB      0           ; also XX12+5
clipGradient            DB      0
clipDxySign             DB      0
varX12p3                equ     clipDxySign
clipXGTY                DB      0
clipFlags               DB      0
SWAP                    DB      0
varYX                   DW      0
;varRegX                 DB      0
;varXX12p2               DB      0
clipXX13                 DB      0


; bounds check and the start to avoid dxy calcs if off screen, eliminating off screens first saves a lot of uncessary mul/div
;ClipXX15XX12Line:
ClipLine:               ld      bc,(UbnkPreClipY1)          ; bc - XX15(2,3)
                        ld      ix,(UbnkPreClipY2)          ; ix - XX12(0,1)
                        ld      hl,(UbnkPreClipX1)          ; hl - XX15(0,1)
                        ld      de,(UbnkPreClipX2)          ; de - XX15(4,5)
                        xor     a
                        ld      (SWAP),a                    ; SWAP = 0
                        ld      a,d                         ; A = X2Hi
.LL147:                 ld      iyh,$BF                     ; we need to be 191 as its 128 + another bit set from 0 to 6, we are using iyh as regX
                        ;       push    af
                        ;       ld      a,iyh
                        ;       ld      (regX),a
                        ;       pop     af
                        or      ixh                         ; if (X2Hi L-OR Y2 Hi <> 0) goto LL107             -- X2Y2 off screen
                        jr      nz, .LL107
                        ld      a,ixl
                        test    $80                         ; if screen hight < y2 lo, i.e y2 lo >127 goto LL107,
                        jr      nz,.LL107
                        ld      iyh, 0                      ; else iyh = regX = 0                                                                        -- X2Y2 on screen                                
                        ;        push    af
                        ;        ld      a,iyh
                        ;        ld      (regX),a
                        ;        pop     af
; XX13 = regX (i.e. iyh)      ( if XX13 = XX13 is 191 if (x2, y2) is off-screen else 0) we bin XX13 as not needed
; so XX13 = 0 if x2_hi = y2_hi = 0, y2_lo is on-screen,  XX13 = 191 if x2_hi or y2_hi are non-zero or y2_lo is off the bottom of the screen                       
.LL107                  ld      a,iyh
                        ld      (clipXX13),a                ; debug copy iyh to xx13
                        ld      a,h                         ; If (X1 hi L-OR Y1) hi  goto LL83                   -- X1Y1 off screen and maybe X2Y2
                        or      b                           ;
                        jr      nz,.LL83                    ;
                        ld      a,c                         ; or (y1 lo > bottom of screen)
                        test    $80                         ; i.e  screen height < y1)
                        jr      nz,.LL83
; If we get here, (x1, y1) is on-screen
                        ld      a,iyh                       ; iyh = xx13 at this point if  XX13 <> 0 goto LL108                                                        -- X1Y1 on screen, if we flagged X2Y2 off screen goto LL108 
                        cp      0
                        jr      nz, .LL108
; Finished clipping exit point ----------------------------------------------------------------------------------------
.ClipDone:              ld      a,c                         ; LL146 (Clip Done)               Y1 = y1 lo, x2 = x2 lo, x1 = x1 lo y1 = y1 lo                                   -- Nothing off screen
                        ld      (UBnkNewY1),a
                        ld      a,ixl
                        ld      (UBnkNewY2),a
                        ld      a,l
                        ld      (UBnkNewX1),a
                        ld      a,e
                        ld      (UBnkNewX2),a
                        ClearCarryFlag                      ; carry is clear so valid to plot is in XX15(0to3)
                        ret                                 ; 2nd pro different, it swops based on swop flag around here.                       
; Finished out of bounds exit point -----------------------------------------------------------------------------------
.PointsOutofBounds:     scf                                 ; LL109 (ClipFailed) carry flag set as not visible
                        ret      
.LL108:                 ld      a,iyh
                        or      a
                        rra
                        ld      iyh,a                       ; (X2Y2 Off Screen)         XX13 = 95 (i.e. divide it by 2)                                                 -- X1Y1 on screen X2Y2 off screen
                        ;        push    af                  ;OPTIMISATION 6/11/21 commented out
                        ;        ld      a,iyh               ;OPTIMISATION 6/11/21 commented out
                        ;        ld      (regX),a            ;OPTIMISATION 6/11/21 commented out
                        ;        pop     af                  ;OPTIMISATION 6/11/21 commented out
.LL83:                  ld      a,iyh                       ; (Line On screen Test)      if XX13 < 128 then only 1 point is on screen so goto LL115                      -- We only need to deal with X2Y2                                
                        test    $80                         ;
                        jr      z, .LL115                   ;
                        ld      a,h                         ; If both x1_hi and x2_hi have bit 7 set, jump to LL109  to return from the subroutine with the C flag set, as the entire line is above the top of the screen
                        and     d
                        JumpIfNegative  .PointsOutofBounds
                        ld      a,b                         ; If both y1_hi and y2_hi have bit 7 set, jump to LL109  to return from the subroutine with the C flag set, as the entire line is above the top of the screen
                        and     ixh
                        JumpIfNegative  .PointsOutofBounds
                        ld      a,h                         ; If neither (x1_hi - 1) or (x2_hi - 1) have bit 7 set, jump to LL109 to return from the subroutine with the C  flag set, as the line doesn't fit on-screen
                        dec     a
                        ld      iyl,a                       ; using iyl as XX12+2 var
                        ;        push    af                 ;OPTIMISATION 6/11/21 commented out
                        ;        ld      a,iyl              ;OPTIMISATION 6/11/21 commented out
                        ;        ld      (varXX12p2),a      ;OPTIMISATION 6/11/21 commented out
                        ;        pop     af                 ;OPTIMISATION 6/11/21 commented out      
                        ld      a,d                         ; a = x2 hi
                        dec     a
                        or      iyl                         ; (x2 hi -1 ) or (x1 hi -1)
                        JumpIfPositive .PointsOutofBounds   ; if both x1 and x2hi were > 0 then subtracting 1 would result in 0..254 so either being negative means it was 0 before
;by here we have eliminated -ve Y1 bounds so can just test for positive high and bit 7 of lo
                        ld      a,ixh
                        dec     a
                        ld      iyl,a
                        ld      a,b
                        dec     a
                        or      iyl
                        JumpIfPositive .PointsOutofBounds   ; if both x1 and x2hi were > 0 then subtracting 1 would result in 0..254 so either being negative means it was 0 before                        
                        ld      a,c
                        and     ixl
                        JumpIfNegative .PointsOutofBounds   ; really if both are > 127
; Clip line: calulate the line's gradient                   
; here as an optimisation we make sure X1 is always < X2  later on  
.LL115:                 ClearCarryFlag
.CalcDX:                push    hl,,de
                        ex      hl,de                       ; so hl is x2 and de = x1
                        sbc     hl,de
                       ; pop     de                          ; we need de back
                        ld      (clipDx),hl
                        ld      a,h
                        ld      (clipDxHighNonABS),a
                       ; ld      a,e                         ;a = x2 lo
                       ; sbc     a,l                         ;a= a - x1
                       ; ld      (clipDx),a
                       ; ld      a,d
                       ; sbc     a,h
                       ; ld      (clipDxHigh),a                ; later we will just move to sub hl,de
                       ; ld      (clipDxHighNonABS),a          ; it looks liek we need this later post scale loop
.CalcDy:                ClearCarryFlag
                        ld      hl,ix
                        sbc     hl,bc
                        ld      de,hl           ;;OPTIMISATION 6/11/21
                        ld      (clipDy),hl     ;OPTIMISATION 6/11/21 commented out
.CalcQuadrant:          ld      a,h                         
                       ; ld      a,ixl
                       ; sbc     c
                       ; ld      (clipDy),a
                       ; ld      a,ixh
                       ; sbc     a,b
                       ; ld      (clipDyHigh),a              ; so A = sign of deltay in effect
                       ; pop     hl

;So we now have delta_x in XX12(3 2), delta_y in XX12(5 4)  where the delta is (x1, y1) - (x2, y2))
                      ;  push    hl                          ; Set S = the sign of delta_x * the sign of delta_y, so if bit 7 of S is set, the deltas have different signs
                        ld      hl,clipDxHigh
                        xor     (hl)                        ; now a = sign dx xor sign dy
                        ld      (varS),a                    ; DEBGU putting it in var S too for now
                        ld      (clipDxySign),a
.AbsDy:                 ld      a,(clipDyHigh)
                        test    $80
                        jr      z,.LL110                    ; If delta_y_hi is positive, jump down to LL110 to skip the following
                        ld      hl,(clipDy)                 ;OPTIMISATION 6/11/21 commented out
                        macronegate16de                     ; Otherwise flip the sign of delta_y to make it  positive, starting with the low bytes
                        ld      (clipDy),hl                 ;OPTIMISATION 6/11/21 commented out
.LL110:                 ld      hl,(clipDx)
                        ld      a,(clipDxHigh)
                        test    $80                         ; is it a negative X
                        jr      z,.LL111                    ; If delta_x_hi is positive, jump down to LL110 to skip the following
                        ;ld      hl,(clipDx)                 ;OPTIMISATION 6/11/21 commented out
                        macronegate16hl                     ; Otherwise flip the sign of delta_y to make it  positive, starting with the low bytes
                       ; ld      (clipDx),hl                 ;OPTIMISATION 6/11/21 commented out; we still retain the old sign in NonABS version
.LL111:               ;  push    de
                       ; ld      hl,(clipDx)                 ;OPTIMISATION 6/11/21 commented out
                       ; ld      de,(clipDy)                 ;OPTIMISATION 6/11/21 commented out
.ScaleLoop:             ld      a,h                         ; At this point DX and DY are ABS values
                        or      d
                        jr      z,.CalculateDelta:
                        ShiftDERight1
                        ShiftHLRight1
                        jr      .ScaleLoop                  ; scaled down Dx and Dy to 8 bit, Dy may have been negative
.CalculateDelta:        ;ld      (clipDx),hl                ;OPTIMISATION 6/11/21 commented out
                        ;ld      (clipDy),de                ;OPTIMISATION 6/11/21 commented out
; By now, the high bytes of both |delta_x| and |delta_y| are zero We know that h and d are both = 0 as that's what we tested with a BEQ
.LL113:                 xor     a
                        ld      (varT),a                    ; t = 0
                        ld      a,l                         ; If delta_x_lo < delta_y_lo, so our line is more vertical than horizontal, jump to LL114
                        JumpIfALTNusng  e, .LL114           ;
; Here Dx >= Dy sp calculate Delta Y / delta X
.DxGTEDy:               ld      (varQ),a                    ; Set Q = delta_x_lo
                        ld      d,a                         ; d = also Q for calc
                        ld      a,e                         ; Set A = delta_y_lo
                        call    AEquAmul256DivD; LL28Amul256DivD             ; Call LL28 to calculate:  R (actually a reg) = 256 * A / Q   = 256 * delta_y_lo / delta_x_lo
                        ld      (varR),a                    ;
                        jr      .LL116                      ; Jump to LL116, as we now have the line's gradient in R
; Here Delta Y > Delta X so calulate delta X / delta Y
.LL114:                 ld      a,e                         ; Set Q = delta_y_lo
                        ld      d,a
                        ld      (varQ),a
                        ld      a,l                         ; Set A = delta_x_lo
                        call    AEquAmul256DivD; LL28Amul256DivD             ; Call LL28 to calculate: R = 256 * A / Q  = 256 * delta_x_lo / delta_y_lo
                        ld      (varR),a                    ;
                        ld      hl,varT                     ; T was set to 0 above, so this sets T = &FF
                        dec     (hl)
.LL116:                 pop     de                          ; get back X2
                        pop     hl                          ; get back X1 into hl,
                        ld      a,(varR)                    ; Store the gradient in XX12+2 this can be optimised later
                        ld      (clipGradient),a
                        ld      iyl,a   
                        ;       push    af                   ;OPTIMISATION 6/11/21 commented out
                        ;       ld      a,iyl                ;OPTIMISATION 6/11/21 commented out
                        ;       ld      (varXX12p2),a        ;OPTIMISATION 6/11/21 commented out
                        ;       pop     af                   ;OPTIMISATION 6/11/21 commented out
                        ld      a,(varS)
                        ld      (clipDxySign),a             ;  Store the type of slope in XX12+3, bit 7 clear means ?Not needed as clipDxySign is used for varS earlier?
                                                            ; top left to bottom right, bit 7 set means top right to bottom left **CODE IS WRONG HERE A TEST IS BL to TR
                        ld      a,iyh                       ; iyh was XX13 from earlier 
                        cp      0                           ; If XX13 = 0, skip the following instruction
                        jr      z,.LL138                    ;
                        test    $80                         ; If XX13 is positive, it must be 95. This means (x1, y1) is on-screen but (x2, y2) isn't, so we jump to LLX117 to swap the (x1, y1) and (x2, y2)                       
                        jr      z,.LLX117                   ; coordinates around before doing the actual clipping, because we need to clip (x2, y2) but the clipping routine at LL118 only clips (x1, y1)
; If we get here, XX13 = 0 or 191, so (x1, y1) is off-screen and needs clipping
.LL138                  call    ClipPointHLBC               ; Call LL118 to move (x1, y1) along the line onto the screen, i.e. clip the line at the (x1, y1) end
                        ld      a,iyh                       ; If XX13 = 0, i.e. (x2, y2) is on-screen, jump down to LL124 to return with a successfully clipped line
                        test    $80
                        jr      z,.LL124
; If we get here, XX13 = 191 (both coordinates are off-screen)
.LL117:                 ld      a,h                         ; If either of x1_hi or y1_hi are non-zero, jump to
                        or      b                           ; LL137 to return from the subroutine with the C flag
                        jp      nz, .PointsOutofBounds      ; set, as the line doesn't fit on-screen
                        or      c                           ; if x1 and y1 hi are both zero test bit 8 or Y1 to see if its > 128
                        jp      m, .PointsOutofBounds       ; set, as the line doesn't fit on-screen
; If we get here, XX13 = 95 or 191, and in both cases (x2, y2) is off-screen, so we now need to swap the (x1, y1) and (x2, y2) coordinates around before doing
; the actual clipping, because we need to clip (x2, y2) but the clipping routine at LL118 only clips (x1, y1)
.LLX117:                ex      de,hl                       ;  swap X1 and X2
                        push    ix                          ;  swap Y1 and Y2
                        push    bc
                        pop     ix
                        pop     bc
                        call    ClipPointHLBC               ;  Call LL118 to move (x1, y1) along the line onto the screen, i.e. clip the line at the (x1, y1) end
                        ld      a,(SWAP)
                        dec     a
                        ld      (SWAP),a                    ; Set SWAP = &FF to indicate that we just clipped the line at the (x2, y2) end by swapping the coordinates (the DEC does this as we set SWAP to 0 at the start of this subroutine)
.LL124:                 jp      .ClipDone                    ; now put points in place

; Move a point along a line until it is on-screen point is held in HL(X) BC(Y) LL118
; iyh still holds XX13 iyl still holds gradient
ClipPointHLBC:          ld      a,h                         ; If x1_hi is positive, jump down to LL119 to skip the following
                        test    $80
                        jr      z,.LL119
.X1isNegative:          ld      (varS),a                    ;  Otherwise x1_hi is negative, i.e. off the left of the screen, so set S = x1_hi
                        push    hl,,de,,bc
                        call    LL120                       ;  Call LL120 to calculate:   (Y X) = (S x1_lo) * XX12+2      if T = 0   = x1 * gradient
                                                            ;                             (Y X) = (S x1_lo) / XX12+2      if T <> 0  = x1 / gradient
                                                            ;  with the sign of (Y X) set to the opposite of the line's direction of slope
                        pop    hl,,de,,bc                   ;  get coordinates back
                        ld      hl,(varYX)
;                        ex      hl,de
                    ;    ld      hl,bc                       
                        add     hl,bc                       ; y1 = y1 + varYX
                        ld      bc,hl
                        ld      hl,0                        ; Set x1 = 0
 ;                       pop     de
                        jr      .LL134                      ; in BBC is set x to 0 to force jump, we will just jump
.LL119:                 cp      0
                        jr      z,.LL134                    ;  If x1_hi = 0 then jump down to LL134 to skip the following, as the x-coordinate is already on-screen (as 0 <= (x_hi x_lo) <= 255)
                        dec     a
                        ld      (varS),a                    ;  Otherwise x1_hi is positive, i.e. x1 >= 256 and off the right side of the screen, so set S = x1_hi - 1
                        push    hl,,de,,bc
                        call    LL120                      ;  Call LL120 to calculate: (Y X) = (S x1_lo) * XX12+2      if T = 0  = (x1 - 256) * gradient
                                                            ;                           (Y X) = (S x1_lo) / XX12+2      if T <> 0 = (x1 - 256) / gradient
                                                            ;  with the sign of (Y X) set to the opposite of theline's direction of slope
                        pop     hl,,de,,bc
                      ;  push    de                          ; Set y1 = y1 + (Y X)
                        ld      hl,(varYX)
                      ; ex      de,hl                       ;OPTIMISATION 6/11/21 commented out
                        add     hl,bc                        ;OPTIMISATION 6/11/21 simplfied post debug
                        ld      bc,hl                        ;OPTIMISATION 6/11/21 simplfied post debug
                      ; ex      hl,de                       ;OPTIMISATION 6/11/21 commented out
                      ; ld      hl,bc                       ;OPTIMISATION 6/11/21 commented out
                      ; add     hl,de                       ; y1 = y1 + varYX
                        ld      hl,255                      ; Set x1 = 255
                      ;  pop     de
; We have moved the point so the x-coordinate is on screen (i.e. in the range 0-255), so now for they-coordinate
.LL134:                 ld      a,b                         ; If y1_hi is positive, jump down to LL135  to skip the following
                        test    $80                         ; 
                        jr      z,.LL135                    ; 
                        ld      (varS),a                    ; Otherwise y1_hi is negative, i.e. off the top of the screen, so set S = y1_hi
                        ld      a,c                         ; Set R = y1_lo
                        ld      (varR),a                    ;
                        push    hl,,de,,bc
                        call    LL123                       ;  Call LL123 to calculate: (Y X) = (S R) / XX12+2      if T = 0  = y1 / gradient
                                                            ;                           (Y X) = (S R) * XX12+2      if T <> 0 = y1 * gradient
                                                            ;  with the sign of (Y X) set to the opposite of the line's direction of slope
                        pop     hl,,de,,bc
                        push    de                                    
                        ex      hl,de                       ; de = x1
                        ld      hl,(varYX)                  ; hl = varYX
                        add     hl,de                       ; we don't need to swap back as its an add, Set x1 = x1 + (Y X)
                        pop     de                          ; de = x2 again
                        ld      bc,0                        ; Set y1 = 0
.LL135:                 ld      a,c                         ; if bc < 128 then no work to do
                        and     $80
                        or      b                           ; here we see if c bit 8 is set or anything in b as we know if its 0 this would mean there is no need to clip
                        ret     z
                        push    hl                          
                        ld      hl,bc
                        ld      bc,128
                        or      a
                        sbc     hl,bc                       ; hl =  (S R) = (y1_hi y1_lo) - 128
                        ld      (varRS), hl                 ; and now RS (or SR)
                        ld      a,h
                        pop     hl
                        test    $80                         ; If the subtraction underflowed, i.e. if y1 < 192, then y1 is already on-screen, so jump to LL136 to return from the subroutine, as we are done
                        ret     nz
; If we get here then y1 >= 192, i.e. off the bottom of the screen 
.LL139:                 push    hl,,de,,bc
                        call    LL123                       ;  Call LL123 to calculate: (Y X) = (S R) / XX12+2      if T = 0  = y1 / gradient
                                                            ;                           (Y X) = (S R) * XX12+2      if T <> 0 = y1 * gradient
                                                            ;  with the sign of (Y X) set to the opposite of the line's direction of slope
                        pop     hl,,de,,bc
                        push    de
                        ex      hl,de
                        ld      hl,(varYX)
                        add     hl,de                       ; we don't need to swap back as its an add, Set x1 = x1 + (Y X)
                        ld      bc,127                      ; set bc to 127 bottom of screen
                        pop     de
.LL136:                 ret                                 ;  Return from the subroutine


; Calculate the following:   * If T = 0  (more vertical than horizontal), (Y X) = (S x1_lo) * XX12+2
;                            * If T <> 0 (more horizontal than vertical), (Y X) = (S x1_lo) / XX12+2
;                              giving (Y X) the opposite sign to the slope direction in XX12+3.
; Other entry points        LL122                Calculate (Y X) = (S R) * Q and set the sign to the opposite of the top byte on the stack
LL120:                  ld      a,l                          ; Set R = x1_lo
                        ld      (varR),a
                        call    LL129                        ;  Call LL129 to do the following:  Q = XX12+2   = line gradient  A = S EOR XX12+3 = S EOR slope direction (S R) = |S R| So A contains the sign of S * slope direction
                        push    af                           ;  Store A on the stack so we can use it later
                        push    bc
                        ld      b,a
                        ld      a,(varT)                     ; instead : (Y X) = (S R ) / Q
                        cp      0
                        ld      a,b
                        pop     bc                           ; we can't use af as that would disrupt the flags
                        jr      nz, LL121
; The following calculates:  (Y X) = (S R) * Q using the same shift-and-add algorithm that's documented in MULT1
LL122:                  ld      a,(clipGradient)
                        ld      (varQ),a; optimise
                        call    HLequSRmulQdiv256
                        ld      (varYX),hl
                        pop     af
                        test    $80
                        jp      z,LL133
                        ret
; Calculate the following: * If T = 0,  calculate (Y X) = (S R) / XX12+2 (actually SR & XX12+2 /256)
;                          * If T <> 0, calculate (Y X) = (S R) * XX12+2
;                          giving (Y X) the opposite sign to the slope direction in XX12+3.
;
; Other entry points:      LL121                Calculate (Y X) = (S R) / Q and set the sign to the opposite of the top byte on the stack
;                          LL133                Negate (Y X) and return from the subroutine
;                          LL128                Contains an RTS
LL123:                  call    LL129                       ; Call LL129 to do the following: Q = XX12+2   = line gradient  A = S EOR XX12+3 = S EOR slope direction (S R) = |S R| So A contains the sign of S * slope direction
                        push    af                          ; Store A on the stack so we can use it later
                        push    bc                          ; If T is non-zero, so it's more horizontal than vertical, jump down to LL121 to calculate this
                        ld      b,a
                        ld      a,(varT)                    ; instead : (Y X) = (S R) * Q *** this looks to be the wrong way roudn for Y!!!!
                        cp      0
                        ld      a,b
                        pop     bc
                        jr      nz, LL122
; The following calculates: (Y X) = (S R) / Q using the same shift-and-subtract algorithm that's documented in TIS2, its actually X.Y=R.S*256/Q
LL121:                  ld      de,$FFFE                    ; set XY to &FFFE at start, de holds XY                        
                        ld      hl,(varRS)                  ; hl = RS
                        ld      a,(varQ)
                        ld      b,a                         ; b = q
.LL130:                 ShiftHLLeft1                        ; RS *= 2
                        ld      a,h
                        jr      c,.LL131                    ; if S overflowed skip Q test and do subtractions
                        JumpIfALTNusng b, .LL132            ; if S <  Q = 256/gradient skip subtractions
.LL131:                 ccf                                 ; compliment carry
                        sbc     a,b                         ; q
                        ld      h,a                         ; h (s)
                        ld      a,l                         ; r
                        sbc     a,0                         ; 0 - so in effect SR - Q*256
                        scf                                 ; set carry for next rolls
                        ccf
.LL132:                 RollDELeft1                         ; Rotate de bits left
                        jr      c,.LL130                    ; 
                        ld      (varYX),de
                        pop     af              ; get back sign
                        test    $80
                        ret     z               ; if negative then return with value as is reversed sign
LL133:                  ld      hl,(varYX)      ; may not actually need this?
                        NegHL
                        ld      (varYX),hl
LL128:                  ret
; Do the following, in this order:  Q = XX12+2
;                                   A = S EOR XX12+3
;                                   (S R) = |S R|
; This sets up the variables required above to calculate (S R) / XX12+2 and give the result the opposite sign to XX13+3.
LL129:                  ld      a,(clipGradient)
                        ld      (varQ),a                    ;Set Q = XX12+2
                        ld      a,(varS)                    ; If S is positive, jump to LL127
                        push    hl,,af
                        test    $80
                        jr      z,.LL127
                        ld      hl,(varRS)                  ; else SR = | SR|
                        NegHL
                        ld      (varRS),hl
.LL127:                 ld      hl,clipDxySign
                        pop     af
                        xor     (hl)                        ; a = S XOR clipDxySign
                        pop     hl
                        ret
