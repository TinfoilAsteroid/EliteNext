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
Gradient                DB      0
; for start and end y. bit7 of lower determines its not been setup yet

;--------------------------------------------------------------------------------------
        IFNDEF       CLIPVersion3
ClipLine:               ld      bc,(UbnkPreClipY1)          ; bc - XX15(2,3) Y1
                        ld      ix,(UbnkPreClipY2)          ; ix - XX12(0,1) Y2
                        ld      hl,(UbnkPreClipX1)          ; hl - XX15(0,1) X1
                        ld      de,(UbnkPreClipX2)          ; de - XX15(4,5) X2
                        xor     a
                        ld      (SWAP),a                    ; SWAP = 0
                        ld      a,d                         ; A = X2Hi
.LL147:                 ld      iyh,$BF                     ; we need to be 191 as its 128 + another bit set from 0 to 6, we are using iyh as regX (128 will actually do)
                        or      ixh                         ; if (X2Hi L-OR Y2 Hi <> 0) goto LL107             -- X2Y2 off screen
                        jr      nz, .LL107
                        ld      a,ixl
                        test    $80                         ; if screen hight < y2 lo, i.e y2 lo >127 goto LL107,
                        jr      nz,.LL107
                        ld      iyh, 0                      ; else iyh = regX = 0                                                                        -- X2Y2 on screen                                
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
.PointsOutofBounds:     SetCarryFlag                        ; LL109 (ClipFailed) carry flag set as not visible
                        ret      
.LL108:                 ld      a,iyh
                        or      a
                        rra
                        ld      iyh,a                       ; (X2Y2 Off Screen)         XX13 = 95 (i.e. divide it by 2)                                                 -- X1Y1 on screen X2Y2 off screen
.LL83:                  ld      a,iyh                       ; (Line On screen Test)      if XX13 < 128 then only 1 point is on screen so goto LL115                      -- We only need to deal with X2Y2                                
                        test    $80                         ; 
                        jr      z, .LL115                   ;
;                       Check for X1 and X2 negative                         
                        ld      a,h                         ; If both x1_hi and x2_hi have bit 7 set, jump to LL109  to return from the subroutine with the C flag set, as the entire line is above the top of the screen
                        and     d
                        JumpIfNegative  .PointsOutofBounds
;                       Check for Y1 and Y2 negative                         
                        ld      a,b                         ; If both y1_hi and y2_hi have bit 7 set, jump to LL109  to return from the subroutine with the C flag set, as the entire line is above the top of the screen
                        and     ixh
                        JumpIfNegative  .PointsOutofBounds
;                       Check for X1 and X2 both > 255
                        ld      a,h                         ; If neither (x1_hi - 1) or (x2_hi - 1) have bit 7 set, jump to LL109 to return from the subroutine with the C  flag set, as the line doesn't fit on-screen
                        dec     a
                        ld      iyl,a                       ; using iyl as XX12+2 var
                        ld      a,d                         ; a = x2 hi
                        dec     a
                        or      iyl                         ; (x2 hi -1 ) or (x1 hi -1)
                        JumpIfPositive .PointsOutofBounds   ; if both x1 and x2hi were > 0 then subtracting 1 would result in 0..254 so either being negative means it was 0 before
; by here we have eliminated -ve Y1 bounds so can just test for positive high and bit 7 of lo
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
                        ld      (clipDx),hl
                        ld      a,h
                        ld      (clipDxHighNonABS),a
.CalcDy:                ClearCarryFlag
                        ld      hl,ix
                        sbc     hl,bc
                        ld      de,hl           ;;OPTIMISATION 6/11/21
                        ld      (clipDy),hl     ;OPTIMISATION 6/11/21 commented out
.CalcQuadrant:          ld      a,h                         
                        ld      (clipDyHigh),a              ; so A = sign of deltay in effect
; So we now have delta_x in XX12(3 2), delta_y in XX12(5 4)  where the delta is (x1, y1) - (x2, y2))
                        ld      hl,clipDxHigh
                        xor     (hl)                        ; now a = sign dx xor sign dy
                        ld      (varS),a                    ; DEBGU putting it in var S too for now
                        ld      (clipDxySign),a
.AbsDy:                 ld      a,(clipDyHigh)
                        test    $80
                        jr      z,.LL110                    ; If delta_y_hi is positive, jump down to LL110 to skip the following
                        ld      de,(clipDy)                 ;OPTIMISATION 6/11/21 commented out
                        macronegate16de                     ; Otherwise flip the sign of delta_y to make it  positive, starting with the low bytes
                        ld      (clipDy),de                 ;OPTIMISATION 6/11/21 commented out
.LL110:                 ld      hl,(clipDx)
                        ld      a,(clipDxHigh)
                        test    $80                         ; is it a negative X
                        jr      z,.LL111                    ; If delta_x_hi is positive, jump down to LL110 to skip the following
                        ;ld      hl,(clipDx)                 ;OPTIMISATION 6/11/21 commented out
                        macronegate16hl                     ; Otherwise flip the sign of delta_y to make it  positive, starting with the low bytes
.LL111:               
.ScaleLoop:             ld      a,h                         ; At this point DX and DY are ABS values
                        or      d
                        jr      z,.CalculateDelta
                        ShiftDERight1
                        ShiftHLRight1
                        jr      .ScaleLoop                  ; scaled down Dx and Dy to 8 bit, Dy may have been negative
.CalculateDelta:        
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
                        add     hl,bc                       ; y1 = y1 + varYX
                        ld      bc,hl
                        ld      hl,0                        ; Set x1 = 0
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
                        ld      hl,(varYX)
                        add     hl,bc                        ;OPTIMISATION 6/11/21 simplfied post debug
                        ld      bc,hl                        ;OPTIMISATION 6/11/21 simplfied post debug
                        ld      hl,255                      ; Set x1 = 255
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
        ENDIF

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
                        jp      nz, .LL121
; The following calculates:  (Y X) = (S R) * Q using the same shift-and-add algorithm that's documented in MULT1
.LL122:                  ld      a,(clipGradient)
                        ld      (varQ),a; optimise
                        call    HLequSRmulQdiv256
                        ld      (varYX),hl
                        pop     af
                        test    $80
                        jp      z,.LL133
                        ret
.LL121:                  ld      de,$FFFE                    ; set XY to &FFFE at start, de holds XY                        
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
.LL133:                 ld      hl,(varYX)      ; may not actually need this?
                        NegHL
                        ld      (varYX),hl
.LL128:                 ret

                        
                        
                        
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
                        jp      nz, .LL122
; The following calculates: (Y X) = (S R) / Q using the same shift-and-subtract algorithm that's documented in TIS2, its actually X.Y=R.S*256/Q
.LL121:                 ld      de,$FFFE                    ; set XY to &FFFE at start, de holds XY                        
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
.LL133:                 ld      hl,(varYX)      ; may not actually need this?
                        NegHL
                        ld      (varYX),hl
.LL128:                 ret
; The following calculates:  (Y X) = (S R) * Q using the same shift-and-add algorithm that's documented in MULT1
.LL122:                 ld      a,(clipGradient)
                        ld      (varQ),a; optimise
                        call    HLequSRmulQdiv256
                        ld      (varYX),hl
                        pop     af
                        test    $80
                        jp      z,.LL133
                        ret

; Do the following, in this order:  Q = XX12+2
;                                   A = S EOR XX12+3
;                                   (S R) = |S R|
; This sets up the variables required above to calculate (S R) / XX12+2 and give the result the opposite sign to XX13+3.
LL129:                  ld      a,(clipGradient)
                        ld      (varQ),a                    ; Set Q = XX12+2
                        ld      a,(varS)                    ; If S is positive, jump to LL127
                        push    hl,,af                      ; else
                        test    $80                         ;   if bit 7 is clear
                        jr      z,.LL127                    ;      RS = ABS RS
                        ld      hl,(varRS)                  ;      .
                        NegHL                               ;      .
                        ld      (varRS),hl                  ;      .
.LL127:                 ld      hl,clipDxySign              ;   hl = dxy sign
                        pop     af                          ;
                        xor     (hl)                        ; a = S XOR clipDxySign
                        pop     hl
                        ret

;--------------------------------------------------------------------------------------
; Thow away out of bounds by more than 250
ClipLineV3:             ;break
        IFDEF       CLIPVersion3
;My logic version
.CheckYorder:                     
                        ld      hl,(UbnkPreClipY1)
                        ld      de,(UbnkPreClipY2)
                        call    CompareHLDESgn
                        jr      c,.LineP1toP2                          ; if Y1 < Y2 then we can use the points as is else we have to swap
.LineP2toP1:            ld      bc,(UbnkPreClipY2)                      ; fetch and write out in reverse
                        ld      ix,(UbnkPreClipY1)
                        ld      de,(UbnkPreClipX1)
                        ld      hl,(UbnkPreClipX2)
                        ld      (UbnkPreClipY1),bc                      ; bc - XX15(2,3) Y1
                        ld      (UbnkPreClipY2),ix                      ; ix - XX12(0,1) Y2
                        ld      (UbnkPreClipX1),hl                      ; hl - XX15(0,1) X1 
                        ld      (UbnkPreClipX2),de                      ;  de - XX15(4,5) X2
                        jp      .CheckNoClip
.LineP1toP2             ld      bc,(UbnkPreClipY1)                      ; bc - XX15(2,3) Y1
                        ld      ix,(UbnkPreClipY2)                      ; ix - XX12(0,1) Y2
                        ld      hl,(UbnkPreClipX1)                      ; hl - XX15(0,1) X1 
                        ld      de,(UbnkPreClipX2)                      ; de - XX15(4,5) X2
.CheckNoClip:           ld      a,b                                 
                        or      d
                        or      h
                        or      ixh
                        jp      nz,.CheckXOffScreen                 ; if both Y1 and y2 have bit 7 set
                        ld      a,c                                 ; then we clip
                        and     ixl
                        test    $80
                        jp      z, .ClipComplete
;if either x1hi x2hi are 0 then we clip. if both <> 0and both same sign exit
.CheckXOffScreen:       ld      a,h
                        xor     d
                        test    $80                                 ; non descructive test of bit 7 is set
                        jp      nz,.X1X2OppositeSign                ; if bit 7 was set then x1 and x2 must be opposite signs so its on screen
.X1X2SameSigns:         ld      a,h                                 ; so to get there h and d must be the same sign
                        test    $80                                 ; if they are the same sign and at x1 is negative then x2 must be negative so off screen
                        JumpIfAIsZero .X1X2CheckIfBothRight
.X1X2BothNegative:      SetCarryFlag                                ; to get to here x1 and x2 must be high and off the same sign so its not to draw
                        ret                                
.X1X2CheckIfBothRight:  and     a                                   ; we have h in a already
                        jr      z,.X1OnScreen
                        ld      a,d
                        and     a
                        jr      z,.X2OnScreen                                             
.X1X2OffRightSide:      SetCarryFlag                                ; to get to here x1 and x2 must be high and off the same sign so its not to draw
                        ret
;                       to get to here x1 and x2 either span -ve to +ve or from on screen to off screen                        
.X1OnScreen:
.X2OnScreen:
.X1X2OppositeSign:
;                       Now check to see if Y is off screen
.CheckYOffScreen:       ld      a,b                                     ; Check if y1 and y2 are opposite signs, fi so it spans screen so we are good
.CheckBothYNegative:    xor     ixh
                        test    $80                                     ; if bit 7 is set then opposite signs
                        jp      nz,.Y1Y2OppositeSign                    ; if y1 and y2 are opposite signs its on screen and spans at least one side
.Y1Y2SameSign:          ld      a,b                                     ; if they are the same sign then if one is negative, so is the other so off screen
                        test    $80
                        jp      z,.Y1Y2Positive
.Y1Y2Negative:          SetCarryFlag
                        ret
.Y1Y2Positive:          ld      a,c                                     ; if its the same sign y1 or y2 could be 0 and if they are 
                        and     $80                                     ; this will test to see if b >0 or c > 127
                        or      b                                       ;
                        jp      z,.Y1OnScreen
                        ld      a,ixl
                        and     $80
                        or      ixh
                        jp      z,.Y2OnScreen
.Y1Y2OffBottomSide:     SetCarryFlag
                        ret
.Y1OnScreen:
.Y2OnScreen:
.Y1Y2OppositeSign:      
.StartProcessing:       ld      hl,(UbnkPreClipX1)                      ; Now we can test and Clip 
                        ld      de,(UbnkPreClipX2)                      ; de - XX15(4,5)
                        ld      iyh,0                                   ; set iyh flags to 0
; if x1hi or y1 high <> 0 or y1 > 127 then set bit 1 of clipcoord       ; we can optimise this later
                        ld      a,h
                        or      b
                        jr      z,.CheckP1Ylo
;                       iyh     bit 0 - P1 Needs Clipping
;                               bit 1 - P2 Needs Clipping
;                               bit 2 - x1 >= x2 (left to right)                        
;                               bit 3 - y1 >= y2 (top to bottom)
;                               bit 4 -  DY/DX (steep)
.P1OffScreen:           ld      iyh,1                                   ; if either p1 x or y was off screen set bit 0 to 1
                        jp      .CheckP2OffScreen                       ; .     
.CheckP1Ylo:            ld      a,c                                     ; .
                        and     $80                                     ; .
                        jr      z,.CheckP2OffScreen                     ; .
                        ld      iyh,1                                   ; .
.CheckP2OffScreen:      ld      a,d                                     ; if x2hi or y2 off screen then set bit 2 of clipcoord to 1
                        or      ixh                                     ; .
                        jr      z,.CheckP2Ylo                           ; .
.P2OffScreen:           ld      a,iyh                                   ; .
                        or      2                                       ; .
                        ld      iyh,a                                   ; .
                        jp      .CheckXDirection                        ; .
.CheckP2Ylo:            ld      a,ixl                                   ; .
                        and     $80                                     ; .
                        jr      z,.CheckXDirection                      ; .
                        ld      a,iyh                                   ; .
                        or      2                                       ; .
                        ld      iyh,a                                   ; .
.CheckXDirection:       push    de,,hl
                        call    CompareHLDESgn                          ; IF HL equals DE, Z=1,C=0, IF HL is less than DE, Z=0,C=1, IF HL is more than DE, Z=0,C=0
                        pop     de,,hl
                        jp      c,.CalculateDx                          ; 
.X1gteX2:               ld      a,iyh                                   ; if x1 >= x2 then set bit 3 to denote -ve x direction, note we will eliminate horziontal / vertical early as an optimisation
                        or      4                                       ; .
                        ld      iyh,a                                   ; .
                        ; Y Direction is now always top to bottom
.CalculateDx:           ClearCarryFlag                                  ;                       calculate DX
                        sbc     hl,de                                   ; .
.ABSDX:                 ld      a,h                                     ; HL = | HL - DE |
                        test    $80                                     ; .
                        jr      z,.DXPositive                           ; .
                        macronegate16hl                                 ; .
.DXPositive:            ex      de,hl                                   ; de = abs delta x
.CalculateDy:           ClearCarryFlag                                  ; hl = Y2 -Y1 as its pre sorted its always positive if on screen
                        ld      hl,ix                                   ; iy = hl = Y2 - Y1
                        sbc     hl,bc                                   ; .
.DYPositive:            ; Scale DX and DY to 8 bit, by here hl = abs dy, de = abs dx
;calculate DY
.ScaleLoop:             ld      a,h                                     ; At this point DX and DY are ABS values
                        or      d                                       ; .
                        jr      z,.ScaleDone                            ; .
                        ShiftDERight1                                   ; .
                        ShiftHLRight1                                   ; .
                        jr      .ScaleLoop                              ; scaled down Dx and Dy to 8 bit, Dy may have been;;                                                                                               negative
.ScaleDone:             ; hl = ABS DY, DE = ABS DX,  bc = Y1, ix = Y2,   note H and D will be zero    
; if Dx = 0 then horizontal line and clip X1 & X2 only then exit
; if Dy = 0 then vertical line and clip Y1 & Y2 only then exit

; if DX < DY  gradient = 256 * delta_x_lo / delta_y_lo
;        else gradient = 256 * delta_y_lo / delta_x_lo, set bit 5 of clipcord
.CalculateDelta:        ld      a,e                                     ; if DX < DY goto DX/DY 
                        JumpIfALTNusng l,.DXdivDY                       ; else do DY/DX
.DYdivDX:               ld      a,l                                     ;    A = DY
                        ld      d,e                                     ;    D = DX
                        call    AEquAmul256DivD                         ;    A = R = 256 * DY / DX
.SaveGradientDYDX:      ld      (Gradient),a
                        ld      a,iyh                                   ;    bit 5 of iyh denotes that its a DX/DY (steep), if its clear its DY/DX (shallow)
                        or      16                                      ;    .
                        ld      iyh,a                                   ;    .
                        jp      .ClipP1                                 ;    .
.DXdivDY:               ld      a,e                                     ;    A = DX
                        ld      d,l                                     ;    D = DY
                        call    AEquAmul256DivD                         ;    A = R = 256 * DX / DY
.SaveGradientDXDY:      ld      (Gradient),a
; if bit 1 of clipccord is set call    LL118
.ClipP1:                ld      a,iyh                                   ; if bit 1 is clear to say no need to clip pont 1 we just jump to point 2
                        test    1                                       ; .
                        jp      z,.ClipP2                               ; .
                        call    LL118v3                                 ; else clip P1 first
                        ld      a,b                                     ;      and if b or h have a value its failed to totally clip  as it may be only in bounds on just x or y
                        or      h                                       ;      .
                        jr      z, .P1Ygt127Check                       ;      .
.P1HighOutofBounds:     SetCarryFlag                                    ;      .
                        ret                                             ;      .
.P1Ygt127Check:         ld      a,c                                     ;      or if y > 127 its failed to totally clip
                        test    $80                                     ;      .
                        SetCarryFlag                                    ;      .
                        ret     nz                                      ;      .
                        ld      (UbnkPreClipY1), bc                     ;      else its valid and clipped point 1 so save ti back
                        ld      (UbnkPreClipX1), hl
; if bit 2 of clipcoord is set
;        swap x1y1 with x2y2
;        call    LL118
.ClipP2:                ld      a,iyh                                   ; so now repeat all that for point 2
                        and     2
                        jp      z,.ClipComplete
                        call    LL118v3PreSwap                          ; now clip p2
                        ld      a,b                                     ; if either high is set then it failed to properly clip
                        or      h                                       ; .
                        jr      z, .P2Ygt127Check                       ; .
.P2HighOutofBounds:     SetCarryFlag                                    ; .
                        ret                                             ; .
.P2Ygt127Check:         ld      a,c                                     ; if c > 127 then it also failed to clip
                        test    $80                                     ; .
                        SetCarryFlag                                    ; .
                        ret     nz                                      ; .
                        ld      (UbnkPreClipY2), bc                     ; bc - XX15(2,3);;
                        ld      (UbnkPreClipX2), hl
;clip compelte exit    
.ClipComplete:          ld      bc,(UbnkPreClipY1)                      ; bc - XX15(2,3);;
                        ld      hl,(UbnkPreClipX1)                        
                        ld      ix,(UbnkPreClipY2)                      ; bc - XX15(2,3);;
                        ld      de,(UbnkPreClipX2)
.SaveClippedLine:       ld      a,c                                     ; Y1 = y1 lo, x2 = x2 lo, x1 = x1 lo y1 = y1 lo                                   -- Nothing off screen
                        ld      (UBnkNewY1),a
                        ld      a,ixl
                        ld      (UBnkNewY2),a
                        ld      a,l
                        ld      (UBnkNewX1),a
                        ld      a,e
                        ld      (UBnkNewX2),a
                        ClearCarryFlag                              ; we have a success so not carry
                        ret
;-----------------------------------------------------------------------------------------------------------------------------------
LL118v3PreSwap:         ld      bc,(UbnkPreClipY2)                  ; bc - XX15(2,3);;
                        ld      hl,(UbnkPreClipX2)
                        jp      LL118v3Fetched
;-----------------------------------------------------------------------------------------------------------------------------------
LL118v3:                ld      bc,(UbnkPreClipY1)                  ; bc - XX15(2,3);;
                        ld      hl,(UbnkPreClipX1)
;-----------------------------------------------------------------------------------------------------------------------------------
LL118v3Fetched:                                  
;                       At this point bc = y position, hl = x position both 16 bit
;                       if x < 0 then x = 0 
;                                     adjust = -x */ gradient depending on if its steep or shallow
;                                     y = y +- adjust depending on if we are going +ve direction or negative direction  (or simplify it, that it will always be + for x1y1 and - for x2y2 as we pre-sort)
;                       if x > 255 then x = 255
;                                     adjust = x-255 */ gradient
;                                     y = y +- adjust depending on if we are going +ve direction or negative direction  (or simplify it, that it will always be + for x1y1 and - for x2y2 as we pre-sort)
;                       if y < 0 then y = 0
;                                     adjust = -y */ gradient
;                                     x = x +- adjust depending on if we are going left to right or visa versa
;                       if y >127 then y = 127
;                                     adjust = y-127 */ gradient
;                                     x = x +- adjust depending on if we are going left to right or visa versa
;
;                       iyh     bit 0 - P1 Needs Clipping
;                               bit 1 - P2 Needs Clipping
;                               bit 2 - x1 >= x2 (left to right)                        
;                               bit 3 - y1 >= y2 (top to bottom)
;                               bit 4 -  DY/DX (steep)
; if X1 hi <> 0
LL118:                  ;break
                        ld      a,h                                     ; if x1 high is 0 then we don't need to clip x at all
                        and     a
                        jp      z,.X1NoClipNeeded
;                       if x1 hi bit 7 is set (so negative)
.CalcBlockX:            test    $80                                     ; if h is postiive then jump to the XPositive Calc block
                        jr      z,.CalcBlockXPositive
;                       if clipccord bit 5 is set Adjust = abs(X1) / Gradient (may need to swap bit check?)
.CalcBlockXNegative:    ld      a,iyh                                   ;
                        test    16                                      ; bit 5 of iyh denotes that its a DY/DX, if its clear its DX/DY
                        jr      nz,.CalcBlockXNegMulGrad
.CaclBlockXNegDivGrad:  macronegate16hl
                        ld      a,(Gradient)            
                        push    bc                                      ; abs(X1) / Gradient
                        ld      h,c                     ; move offset into high byte of h
                        ld      l,0
                        ld      c,a
                        call    div_hl_c                            
                        pop     bc
                        jp      .DoneXNegCalc
;                       else set Adjust = abs(X1) * Gradient
.CalcBlockXNegMulGrad:  push    bc                                      ; abs(X1) * Gradient
                        macronegate16hl     
                        ld      a,(Gradient)        
                        call    HLeqyHLmulAdiv256
                        pop     bc
;                       y1 += adjust * (-1 if bit 4 of clipcoord is set)
;                       x1 = 0 then call into DonrX1Calc
;                       we can skip the test for negative Y direection
.DoneXNegCalc:          macronegate16hl
.XNegSkipNegate:        ld      de,bc
                        ex      hl,de
                        add     hl,de
                        ld      bc,hl
                        ld      hl,0
                        jp      .DoneXCalc
;                       else x1 hi is positive
;                       if clipccord bit 5 is set Adjust = X1 lo / Gradient (may need to swap bit check?)
.CalcBlockXPositive:    ld      a,iyh
                        test    16
                        jr      nz,.CalcBlockXPosMulGrad
.CalcBlockXPosDivGrad:  ld      a,(Gradient)            ;Q = gradient
                        push    bc
                        ld      c,a
                        ld      de,255
                        sub     hl,de
                        ld      h,l
                        ld      l,0
                        call    div_hl_c                        
                        pop     bc
                        jp      .DoneX2Calc
;                                 else set Adjust = X1 lo * Gradient
.CalcBlockXPosMulGrad:  push    bc
                        ld      a,(Gradient)            ;Q = gradient
                        ld      de,255
                        sub     hl,de
                        call    HLeqyHLmulAdiv256       ; hl = YX = SR / Q
                        pop     bc
;                       y1 += adjust * (-1 if bit 4 of clipcoord is set)
;                       x1 = 255
;                       we can skip the test for negative Y direection
.DoneX2Calc:            macronegate16hl
.X2SkipNegate:          ex      de,hl
                        ld      hl,bc
                        add     hl,de
                        ld      bc,hl
                        ld      hl,255
;                       if Y1 hi <> 0 or Y1 low >= 128 then y coordinate is good
.DoneXCalc:             ld      a,b
                        and     a
                        jr      nz,.CalcBlockY1Test
                        ld      a,c
                        and     $80
                        ClearCarryFlag                  ; speculative clear of carry in case its good
                        ret     z
;                       if Y1 hi bit 7 is set
.X1NoClipNeeded:
.CalcBlockY1Test:       ld      a,b
                        test    $80
                        jr      z,.CalcBlockYPos       ; if Y is positive jump forward
;                       if clipccord bit 5 is set Adjust = abs(Y1) / Gradient (may need to swap bit check?)
                        break
.CalcBlockY1:           ld      a,iyh
                        test    16
                        jr      nz,.CalcBlockYNegMulGrad
.CalcBlockYNegDivGrad:  macronegate16bc
                        ld      a,(Gradient)            ;Q = gradient
                        push    hl
                        ld      h,c                     ; move offset into high byte of h
                        ld      l,0
                        ld      c,a
                        call    div_hl_c;LLHLdivC;div_hl_c                        
                        pop     de
                        ex      de,hl
                        jp      .DoneBlockY1
;                                 else set Adjust = abs(Y1) * Gradient
.CalcBlockYNegMulGrad:  macronegate16bc
                        push    hl
                        ld      hl,bc
                        ld      a,(Gradient)            ;Q = gradient
                        call    HLeqyHLmulAdiv256       ; hl = YX = SR / Q      
                        pop     de
                        ex      de,hl
;                       x1 += adjust * (-1 if bit 3 of clipcoord is set)
;                       y1 = 0
;                       ret
;                       now we have done the adjustment, if y or x are off screen then the line spans screen in only 1 dimension so doesn't get drawn
.DoneBlockY1:           ld      a,iyh
                        test    4
                        jr      z,.Y1SkipNegate
                        macronegate16de
.Y1SkipNegate:          add     hl,de
                        ld      bc,0
                        ret
;                       if clipccord bit 5 is set Adjust = Y1 lo / Gradient (may need to swap bit check?)
.CalcBlockYPos:         ld      a,iyh
                        test    16
                        jr      z,.CalcBlockYPosMulGrad                        
.CalcBlockYPosDivGrad:  ld      a,(Gradient)            ;Q = gradient
                        push    hl
                        ld      hl,bc
                        ld      de,127
                        sub     hl,de
                        ld      h,l
                        ld      l,0
                        ld      c,a
                        call    div_hl_c;LLHLdivC                        
                        pop     de
                        ex      de,hl
                        jp      .DoneBlockY2              
;                                 else set Adjust = Y1 lo * Gradient
.CalcBlockYPosMulGrad:  push    hl
                        ld      hl,bc
                        ld      de,127
                        sub     hl,de
                        ld      a,(Gradient)
                        call    HLeqyHLmulAdiv256       ; hl = YX = SR / Q         
                        pop     de
                        ex      de,hl
;                x1 += adjust * (-1 if bit 3 of clipcoord is set)
;                y1 = 127
.DoneBlockY2:           ld      a,iyh
                        test    4
                        jr      nz,.Y2SkipNegate
                        macronegate16de
.Y2SkipNegate:          add     hl,de
                        ld      bc,127
                        ret
        ELSE
            ret
        ENDIF
; old code for on screen test
;;;;;;; if y1 > 127 and y2 > 127 then same sing and exit
;;;;;;
;;;;;;;if y1hi y2hi are <> 0 and both same sign exit
;;;;;;.CheckYOffScreen:       ld      a,b                                 ; y1 and y2 high tests
;;;;;;                        and     ixh
;;;;;;                        jp      .CheckYLow
;;;;;;                        ld      
;;;;;;                        and     a                                   ; if either is zero then we can check for > 127
;;;;;;                        jr      z,.YHighNegativeCheck               ;
;;;;;;                        ld      a,ixh                               ;
;;;;;;                        and     a                                   ;
;;;;;;                        ret     nz                                  ;
;;;;;;;if y1h bit 7 and y2h bit 7 set then exit as both -ve
;;;;;;                        ld      a,b                                 ;
;;;;;;                        and     ixh                                 ;
;;;;;;                        and     $80                                 ;
;;;;;;                        ret     z                                   ;
;;;;;;;if y1h > 0 and y2h > 0 then exit as both are +ve high
;;;;;;                        ld      a,b                                 ;
;;;;;;                        and     ixh                                 ;
;;;;;;                        ret     nz                                  ;
;;;;;;;if y1h or y2h is not 0 then proceed to clip
;;;;;;                        ld      a,b
;;;;;;                        or      ixh
;;;;;;                        jr      nz,.StartProcessing
;;;;;;;if (y1l bit 7 is set and y1h is clear ) or (y2l bit 7 is set and y2h is clear) the proceed to clip
;;;;;;                        ld      a,c
;;;;;;                        or      ixl
;;;;;;                        and     $80
;;;;;;                        jr      z,.StartProcessing
;;;;;;
;;;;;;.CheckYOffScreen:       ld      a,b                                 ;
;;;;;;                        cp      0                                   ;
;;;;;;                        jr      z,.Y1HighIsZero                     ; 
;;;;;;                        ld      a,ixh                               ; if we get here Y1 high <> 0
;;;;;;                        cp      0                                   ;
;;;;;;                        jr      z,.Y2HighIsZero                     ; if they are both non zero we can do a sign check                               
;;;;;;.CheckYSameSign:        ld      a,b                                 ; if we get here Y1 high and Y2 high are not zero
;;;;;;                        xor     ixh                                 ; so same sign then bail out if they are
;;;;;;                        and     $80                                 ;
;;;;;;                        ret     z                                   ;
;;;;;;;if we get here either y1hi or y2 hi are 0, now check and y1 low > 127 & y2 low > 127, exit
;;;;;;.Y1HighIsZero:          ld      a,ixh                               ; as y1h is zero, if y2h is zero we do y1 y2 test
;;;;;;                        cp      0                                   ;
;;;;;;                        jr      nz,.Startprocessing                 ;
;;;;;;                        ld      a,c                                 ; so by here y1h and y2h must be zero
;;;;;;                        and     ixl
;;;;;;                        
;;;;;;                        .CheckY2Lo                        ;
;;;;;;.CheckY1Lo:             ld      a,c
;;;;;;                        and     $80
;;;;;;                        jr      z,.StartProcessing
;;;;;;.CheckY2Lo:             ld      a,ixl
;;;;;;                        and     $80
;;;;;;                        ret     nz
;;;;;;;clip = 0                        