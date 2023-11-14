
; K3(1 0) = (Y A) + K3(1 0) = 222 * roofv_x / z + x-coordinate of planet centre
CalcCraterCenterX:      ld      l,a                         ; set HL to Y A
                        ld      a,(regY)                    ;
                        ld      h,a                         ;
                        ld      de,(varK3)                  ; de = K3 [ 1 0 ]
                        ClearCarryFlag
                        adc     hl,de
                        ld      (varK3),hl                  ; K3[1 0] = hl + de
                        ret

; K4(1 0) = (Y A) - K4(1 0) = 222 * roofv_x / z + x-coordinate of planet centre
CalcCraterCenterY:      ld      l,a                         ; set HL to Y A
                        ld      a,(regY)                    ;
                        ld      h,a                         ;
                        ld      de,(varK4)                  ; de = K4 [ 1 0 ]
                        ClearCarryFlag
                        sbc     hl,de
                        ld      (varK4),hl                  ; K4[1 0] = hl + de
                        ret

TwosCompToLeadingSign:  bit     7,h
                        ret     z
                        macronegate16hl
                        ld      a,h
                        or      $80
                        ld      h,a
                        ret
                        
LeadingSignToTwosComp:  bit     7,h
                        ret     z
                        ld      a,h
                        and     $7F
                        ld      h,a
                        macronegate16hl
                        ret

;PLS2                                                   Test
; K[10] = radius                                        $0000?
; k3[10], K4[10] X, y pixel of centre
; (XX16, K2), (XX16+1,K2+1) u_x , u_y                   $1F80  $FE80    
; (XX16+2, K2+2), (XX16+3,K2+3) z_x , z_y               $0000  $0000
; TGT - target segment count                            $00
; CNT2 - starting segment                               $0D
; Now uses (Word) P_BnkCx, Cy, (Byte) Ux, Uy, Vx, Vy

                        DISPLAY "TODO move code back in that was pulled outof BLINE"
DrawMeridian:           ld      a,63                        ; Set TGT = 31, so we only draw half an ellipse
                        ld      (P_BnkTGT),a                ; and fall into DrawElipse
                        DISPLAY "TODO DEBUG STP Default of 1"
                        ld      a,1
                        ld      (P_BnkSTP),a
;PLS22
                        DISPLAY "TODO: Sort out sign byte for uxuy vxvy in calling code"
; Set counter to 0 and reset flags--------------------------
DrawElipse:
.Initialise:            ZeroA
                        ld      (P_BnkCNT),a                ; Set CNT = 0
                        ld      (P_BnkSinCNT2Sign),a
                        ld      (P_BnkCosCNT2Sign),a
                        ld      (P_BnkUxCosSign),a          ; for debugging later we will just use the cos and sin signs above
                        ld      (P_BnkUyCosSign),a          ; .
                        ld      (P_BnkUxUyCosSign),a        ; .
                        ld      (P_BnkVxSinSign),a          ; .
                        ld      (P_BnkVySinSign),a          ; .
                        ld      (P_BnkVxVySinSign),a        ; .
                        dec     a
                        ld      (P_BnkFlag),a               ; Set FLAG = &FF to reset the ball line heap in the call to the BLINE routine below
.PLL4:                  ;break
.GetSinAngle:           ld      a,(P_BnkCNT2)               ; Set angle = CNT2 mod 32 (was regX)
                        and     31                          ; 
; Caclulate Sin(CNT2)---------------------------------------;                        
                        ld      (P_BnkAngle),a              ; save for debugging So P_BnkAngle is the starting segment, reduced to the range 0 to 32, so as there are 64 segments in the circle, this
.CalculateSinCNT2:      call    LookupSineA                 ; Set Q = sin(angle)  = sin(CNT2 mod 32) = |sin(CNT2)|
                        ld      (varQ),a                    ; .
                        ld      (P_BnkSinCNT2),a            ; for debugging
; calculate BnKVxSin = VX*Sin(CNT2)-------------------------;
.GetVxSin:              ld      a,(P_BnkVx)                 ; Set A = K2+2 = |v_x|
                        call    AequAmulQdiv256usgn         ; R = A * Q / 256 = |v_x| * |sin(CNT2)|
                        ld      (P_BnkVxSin),a              ; now varR = vx*sin(CNT2)
; calculate BnkVySin = Vy*Sin(CNT2)-------------------------;
.GetVySin:              ld      a,(P_BnkVy)                 ; Set A = K2+3 = |v_y|
                        call    AequAmulQdiv256usgn         ; Set varK = A * Q / 256 = |v_y| * |sin(CNT2)|
                        ld      (P_BnkVySin),a              ; 
; Now work sign of vx and vy * sin -------------------------; In 6502 below, in z80 C flag is reversed
.CalcVxVyMulSinSign:    ld      a,(P_BnkCNT2)               ; If CNT2 >= 33 then this sets the C flag, else clear : C is clear if the segment starts in the first half of the circle, 0 to 180 degrees
                        cp      33                          ;                                                       C is set if the segment starts in the second half of the circle, 180 to 360 degrees
                        jp      c,.NoSignChangeSin          ; in z80 c means < 33 so we don't do sign flip
                        ld      a,$80
                        ld      (P_BnkSinCNT2Sign),a        ; save sign of sin CNT2 for debugging
                        ld      (P_BnkVxSinSign),a          ; |v_x| * |sin(CNT2)|
                        ld      (P_BnkVySinSign),a          ; |v_y| * |sin(CNT2)|
                        ld      (P_BnkVxVySinSign),a        ; |v_x/y| * |sin(CNT2)|
.NoSignChangeSin:      
; calculate cos(CNT2)---------------------------------------;
.CalculateCosCNT2:      ld      a,(P_BnkCNT2)               ; Set X = (CNT2 + 16) mod 32
                        add     a, 16                       ; .
                        and     31                          ; .
                        ld      (P_BnkAngle),a              ; save for debugging So we can use X as a lookup index into the SNE table to get the cosine (as there are 16 segments in a  quarter-circle)
                        call    LookupSineA                 ; Set Q = sin(X)  = sin((CNT2 + 16) mod 32) = |cos(CNT2)|
                        ld      (varQ),a                    ; .
                        ld      (P_BnkCosCNT2),a            ; for debugging                        
; calculate Uy*Cos(CNT2)------------------------------------;
.GetUyCos:              ld      a,(P_BnkUy)                 ; Set A = K2+1 = |u_y|
                        call    AequAmulQdiv256usgn         ; Set P_BnkUyCos(wasK+2) = A * Q / 256 = |u_y| * |cos(CNT2)|
                        ld      (P_BnkUyCos),a              ; .
; calculate Ux*Cos(CNT2)------------------------------------;
.GetUxCos:              ld      a,(P_BnkUx)                 ; Set A = K2 = |u_x|
                        call    AequAmulQdiv256usgn         ; Set P_BnkUxCos(wasP) = A * Q / 256 = |u_x| * |cos(CNT2)| also sets the C flag, so in the following, ADC #15 adds 16 rather than 15 (use use non carry add)
                        ld      (P_BnkUxCos),a              ; .
; now work out sign for cos CNT2----------------------------;
.CalcUxUyMulCosSign:    ld      a,(P_BnkCNT2)               ; If (CNT2 + 16) mod 64 >= 33 then this sets the C flag,
                        add     a,16                        ; otherwise it's clear, so this means that:
                        and     63                          ; .
                        cp      33                          ; c is clear if the segment is 0 to 90 or 270 to 360, we need 
                        jp      c,.NoSignChangeCos          ; in z80 c means < 33 so we don't do sign flip
                        ld      a,$80
                        ld      (P_BnkCosCNT2Sign),a        ; save sign of sin CNT2 for debugging
                        ld      (P_BnkUxCosSign),a          ; add XX16+5 as the high byte to give us (XX16+5 K) = |v_y| * sin(CNT2) &  (XX16+5 R) = |v_x| * sin(CNT2)
                        ld      (P_BnkUyCosSign),a          ; add XX16+5 as the high byte to give us (XX16+5 K) = |v_y| * sin(CNT2) &  (XX16+5 R) = |v_x| * sin(CNT2)
                        ld      (P_BnkUxUyCosSign),a        ; add XX16+5 as the high byte to give us (XX16+5 K) = |v_y| * sin(CNT2) &  (XX16+5 R) = |v_x| * sin(CNT2)
.NoSignChangeCos:      
; calculate Ux*cos + vx*sin---------------------------------;
.CalcSignOfVxMulSin:    ld      a,(P_BnkSinCNT2Sign)        ; Set S = the sign of XX16+2 * XX16+5
                        ld      hl,P_BnkVxSign              ; = the sign of v_x * XX16+5
                        xor     (hl)                        ; .
                        and     $80                         ; so a is only sign bit now
                        ld      (P_BnkVxSinSign),a          ; P_BnkVxSin (was SR) = v_x * sin(CNT2)
.CalcSignOfUxMulCos:    ld      a,(P_BnkCosCNT2Sign)        ; Set A = the sign of XX16 * XX16+4
                        ld      hl,P_BnkUxSign              ; (i.e. sign of u_x * XX16_+4
                        xor     (hl)                        ; so (A P) = u_x * cos(CNT2)
                        and     $80                         ; so a is only sign bit now
                        ld      (P_BnkUxCosSign),a          ; now P_BnkUxCos
.AddUxCosVxSin:         ld      hl,(P_BnkUxCos)             ; Set (A X) = (A P) + (S R)  = u_x * cos(CNT2) + v_x * sin(CNT2) we could work with a but its simpler to jsut reload hl
                        ld      de,(P_BnkVxSin)             ; as R S are next to each other can load as one
                        MMUSelectMathsBankedFns
                        call    AddDEtoHLSigned             ; hl = u_x * cos(CNT2) + v_x * sin(CNT2) format S15 not 2'sc
.DoneAddUxCosVxSin:     ld      (P_BnkUxCosAddVxSin),hl     ; 
; calculate -(Uy*cos - vy*sin)------------------------------;
.CalcSignOfVyMulSin:    ld      a,(P_BnkSinCNT2Sign)        ; Set S = the sign of XX16+2 * XX16+5
                        ld      hl,P_BnkVySign              ; = the sign of v_x * XX16+5
                        xor     (hl)                        ; .
                        and     $80                         ; so a is only sign bit now                        
                        ld      (P_BnkVySinSign),a          ; P_BnkVxSin (was SR) = v_x * sin(CNT2)
.CalcSignOfUyMulCos:    ld      a,(P_BnkCosCNT2Sign)        ; Set A = the sign of XX16 * XX16+4
                        ld      hl,P_BnkUySign              ; (i.e. sign of u_x * XX16_+4
                        xor     (hl)                        ; so (A P) = u_x * cos(CNT2)
                        and     $80                         ; so a is only sign bit now                        
                        ld      (P_BnkUyCosSign),a          ; now P_BnkUxCos
.AddUyCosVySin:         ld      hl,(P_BnkUyCos)             ; Set (A X) = (A P) + (S R)  = u_x * cos(CNT2) + v_x * sin(CNT2) we could work with a but its simpler to jsut reload hl
                        ld      de,(P_BnkVySin)             ; as R S are next to each other can load as one
                        MMUSelectMathsBankedFns
                        call    AddDEtoHLSigned             ; hl = u_x * cos(CNT2) + v_x * sin(CNT2) format S15 not 2'sc
.DoneAddUyCosVySin:     ld      (P_BnkUyCosSubVySin),hl     ; 
; Calculate NewXPos = Centrey - Uy cos - vy cos (which we still have in hl)
.PL42:
.CalcNewYPos:           ld      de, (P_BnkCy)               ; Hl is already in HL so de =  Cx
                        ex      hl,de                       ; swap round so we can do hl + de where de is already negated to effect a subtract (probabyl don't don't need this)
                        ld      a,d
                        xor     $80                         ; now flip bit as its a subtract not add
                        ld      d,a
                        call    ScaleDE75pct
                        MMUSelectMathsBankedFns
                        call    AddDEtoHLSigned             ; hl = cy - ( uy Cos + vy sin)
                        ld      (P_NewYPos),hl              ; load to new Y Pos
.CalcNewXPos:           ld      hl,(P_BnkCx)
                        ld      de,(P_BnkUxCosAddVxSin)
                        call    ScaleDE75pct
                        MMUSelectMathsBankedFns
                        call    AddDEtoHLSigned             ; hl = cx - ( ux Cos + vx sin)
                        ld      (P_NewXPos),hl
.PL43:                  call    BLINE                       ; hl = TX  draw this segment, updates CNT in A
                        ReturnIfAGTEMemusng P_BnkTGT        ; If CNT > TGT then jump to PL40 to stop drawing the ellipse (which is how we draw half-ellipses)
                        ld      a,(P_BnkCNT2)               ; Set CNT2 = (CNT2 + STP) mod 64
                        ld      hl,P_BnkSTP                 ; .
                        add     a,(hl)                      ; .
                        ld      (P_BnkCNT2),a               ; .
                        jp      .PLL4                       ; Jump back to PLL4 to draw the next segment
.PL40:                  ret



ScaleDE75pct:           ex      de,hl
                        ld      a,h
                        and     a
                        push    af
                        jp      p,.PositiveHL
.NegativeHL:            and     $7F
                        ld      h,a
.PositiveHL:            push    de
                        ld      de,hl
                        add     hl,hl                       ; * 2
                        add     hl,de
                        pop     de
                        ShiftHLRight1
                        ShiftHLRight1
CheckSign:              ex      de,hl
                        pop     af
                        and     a
                        ret     p
                        ld      a,h
                        or      $80
                        ld      h,a
                        ret


;  Draw a single segment of a circle, adding the point to the ball line heap.
;  Arguments:
;   CNT                  The number of this segment
;   STP                  The step size for the circle
;   K6(1 0)              The x-coordinate of the new point on the circle, as a screen coordinate
;   P_New Pos-- (T X)                The y-coordinate of the new point on the circle, as an offset from the centre of the circle
;   FLAG                 Set to &FF for the first call, so it sets up the first point in the heap but waits until the second call before drawing anything (as we need two points, i.e. two calls, before we can draw a line)
;   -- Not UsedK                    The circle's radius
;   -- Not UsedK3(1 0)              Pixel x-coordinate of the centre of the circle
;   -- Not UsedK4(1 0)              Pixel y-coordinate of the centre of the circle
;   P_PrevXPos--K5(1 0)              Screen x-coordinate of the previous point added to the ball line heap (if this is not the first point)
;   P_PrevYPos--K5(3 2)              Screen y-coordinate of the previous point added to the ball line heap (if this is not the first point)
;   SWAP                 If non-zero, we swap (X1, Y1) and (X2, Y2)
; Returns:
;   CNT                  CNT is updated to CNT + STP
;   A                    The new value of CNT
;   P_PrevXPos --K5(1 0)              Screen x-coordinate of the point that we just added to the ball line heap
;   P_PrevYPos--K5(3 2)              Screen y-coordinate of the point that we just added to the ball line heap
;   FLAG                 Set to 0`
; ** THIS NEEDS CHANGING TO IMMEDIATE DRAW and retain last line end pos) ;
; Flow of code 
; Entry Bline, prepare T , X K4 etc
;       BL1        
PLINEx1                 DB 0
PLINEy1                 DB 0
PLINEx2                 DB 0
PLINEy2                 DB 0

                        IFDEF MERIDANLINEDEBUG
; Store X and Y on plot line (ball) heap, values bc = YX to save, a = offset
P_StoreXYOnHeap:        ld      hl,P_BnkPlotXHeap
                        ld      bc,(P_NewXPos)
                        ld      de,(P_NewYPos)      ; now save Y
                        ld      a,(P_BnkPlotIndex)  ; get off set
                        add     hl,a                ; now we have x heap target
                        ld      (hl),b
                        inc     hl
                        ld      (hl),c
                        ld      a, $80 - 1          ; note its 2 bytes per coord element, we have already incremeted by 1 byte
                        add     hl,a
                        ld      (hl),d
                        inc     hl
                        ld      (hl),e
                        ld      a,(P_BnkPlotIndex)  ; get index back
                        inc     a                   ; move on 2 bytes
                        inc     a                   ; .
                        ld      (P_BnkPlotIndex),a  ; and save it
                        ret
                        ENDIF

; We'll move the calculation of absolute screen pos outside of bline so we expect screen pixel coordinates
BLINE:                  ;ld      a,(P_Tvar)          ; entry point if we need to fetch TX
                        ;ld      h,a
                        ;ld      a,(P_Xreg)
                        ;ld      l,a
BLINE_HL:               ;ld      de,(P_varK4)        ; Set K6(3 2) = (T X) + K4(1 0) = y-coord of centre + y-coord of new point
                        ;ex      de,hl               ;not really needed
                        ;ClearCarryFlag              ; .
                        ;adc     hl,de               ; .
                        ;ld      a,h
                        ;ld      (P_varK6p2),hl      ; so K6(3 2) now contains the y-coordinate of the new point on the circle but as a screen coordinate, to go along with the screen y-coordinate in K6(1 0)
                        ld      a,(P_BnkFlag)       ; If FLAG = 0, jump down to BL1, else its FF so we save first point
                        and     a                   ; .
                        jp      z,.BL1              ; .
.FirstPlot:             
; This code now stores on line heap if debugging is enabled else it just stores in Prev X and Y for direct plotting                        
; First time in we are just establinshign first position point, then we can exit
.BL5:                   inc     a                   ; Flag is &FF so this is the first call to BLINE so increment FLAG to set it to 0
                        ld      (P_BnkFlag),a       ; so we just save the first point and don't plot it
                        DISPLAY "TODO, set up proper variables, hold variables for previous X Y, we don't need ball heap"
                        DISPLAY "TODO, created a plot xy heap to store for debugging purposes, delete once not needed"
                        DISPLAY "TODO, need flag for start which is probably CNT being 0?"
                        IFDEF   MERIDANLINEDEBUG
                        ZeroA
                        ld      (P_BnkPlotIndex),a  ; Initialise line list
                        ENDIF
; We don't need to copy to prev here as we do it in BL7                        
                        jp      .SkipFirstPlot      ; Jump to BL7 to tidy up and return from the subroutine
; This section performs teh clipping and draw of the line. it retrieves previous position and draws to new                        
.BL1:                   
; note we still need the unclipped points for the next segment as we have to clip again                         
                        ;ld      hl,(PLINEx1)        ; Otherwise the coordinates were swapped by the call to
                        ;ld      de,(PLINEx2)        ; LL145 above, so we swap (X1, Y1) and (X2, Y2) back
                        ;ld      (PLINEx1),de        ; again
                        ;ld      (PLINEx2),hl        ; .
.BL9:                   DISPLAY "TODO  Removed BnKLSP, check fine"
.BL8:                   DISPLAY "TODO  Removed BnKLSP, check fine"
                        ;ld      a,(P_BnkPlotIndex) ; Set Line Stack Pointer to be the same as Plot Index)
                        ;ld      (P_BnkLSP),a        
                        ld      hl,(P_PrevXPos)     ; set line X2 to PLINEx2
                        ld      (P_XX1510),hl
                        ld      hl,(P_PrevYPos)     ; set line X2 to PLINEx2
                        ld      (P_XX1532),hl
                        ld      hl,(P_NewXPos)      ; set line X2 to PLINEx2
                        ld      (P_XX1554),hl
                        ld      hl,(P_NewYPos)      ; set line X2 to PLINEx2
                        ld      (P_XX1210),hl
                        DISPLAY "TODO: P_XX1210 etc is all wrong as it should be used to hand off to ll145 code"
.CLipLine:              call    P_LL145_6502        ; Clip  line from (X1, Y1) to (X2, Y2), loads to X1,Y1,X2,Y2 P_XX1510 as bytes                        ld      bc,(XX1510)
                        jr      c,.LineTotallyClipped
                        DISPLAY "TODO what was the Ld de for?"
;                        ld      de,(XX1532)
                        DISPLAY "TODO SORT OUT PROPER PLANET COLOR"
.DrawLine:              ld      a,$CC               
                        ld      bc,(P_XX15PlotX1)
                        ld      de,(P_XX15PlotX2)
                        MMUSelectLayer2
                        call    l2_draw_any_line
                        DISPLAY "TODO removed check for starting line segments again as we draw direct"
;                        ld      a,(P_XX13)          ; If XX13 is non-zero, jump up to BL5 to add a &FF marker to the end of the line heap. XX13 is non-zero
;                        and     a                   ; after the call to the clipping routine LL145 above if the end of the line was clipped, meaning the next line
;                        jp      z,.BL5              ; sent to BLINE can't join onto the end but has to start a new segment, and that's what inserting the &FF marker does                        
; if line was totally clipped just store new x and y as previous and continue from there
.SkipFirstPlot:
.LineTotallyClipped:
.BL7:                   ld      hl,(P_NewXPos)        ; Copy the data for this step point from K6(3 2 1 0)
                        ld      de,(P_NewYPos)        ; into K5(3 2 1 0), for use in the next call to BLINE:
                        ld      (P_PrevXPos),hl
                        ld      (P_PrevYPos),de
                        IFDEF   MERIDANLINEDEBUG
                        call    P_StoreXYOnHeap
                        ENDIF
;                        ld      (P_varK5),hl        ; * K5(1 0)(3 2) = x, y of previous point
;                        ld      (P_varK5p2),de      ;
                        ld      a,(P_BnkCNT)         ; CNT = CNT + STP
                        ld      hl,P_BnkSTP
                        ClearCarryFlag
                        adc     a,(hl)
                        ld      (P_BnkCNT),a
                        ret