; First off basic off screen clip tests
; Sort points in Y ascending order
; Detect if flat top    -> l2_fillTopFlatTriangle
; Detect if flat bottom ->l2_fillBottomFlatTriangle
; else
; Calc X2-X1 = delta X
; calc Y2-Y1 = partialY
; calc Y3-Y1 = fullY
; X2partial = X1 + (deltaX * (partialY/fullY) - Can be done by line algorithim variant?
; l2_fillBottomFlatTriangle (X1Y1, X2parialY2, X2Y2)
; l2_fillTopFlatTriangle(X2partialY2, X2Y2, X3Y3)
; done
;
; Sorts    Y1   Y2    Y3    
;          1    2     3     Y1 < Y2 no      Y1 < Y3 no      Y2 < Y3 no
;          1    3     2     Y1 < Y2 no      Y1 < Y3 no      Y2 > Y3 1 2<=>3 
;          2    1     3     Y1 < Y2 1<=>2 3 Y1 < Y3 no      Y2 < Y3 no
;          2    3     1     Y1 < Y2 no      Y1 < Y3 1  2  3 Y2 < Y3 no
;          3    1     2     Y1 < Y2 1<=>3 2 Y1 < Y3 no      Y2 < Y3 1 2 3
;          3    2     1     Y1 < Y2 2<->3 1 Y1 < Y2 1  2  3 Y2 < Y2 no


; X1  IY +0
; Y1  IY +2
; X2  IY +4
; Y2  IY +6
; X3  IY +8
; Y3  IY +10
;;;
;;;compareCoordsSwap:      MACRO   OffsetX1, OffsetX2
;;;                        ld      hl,(IY+(OffsetX1+2))                       ; Y1
;;;                        ld      de,(IY+(OffsetX2+2))                       ; Y2
;;;                        cpHLDELeadSign
;;;                        ret     nc
;;;                        ld      hl,(IY+OffsetX1)   ; swap X1 and X2
;;;                        ld      de,(IY+OffsetX2)   ;
;;;                        ld      hl,(IY+OffsetX2)   ;
;;;                        ld      de,(IY+OffsetX1)   ;
;;;                        ld      hl,(IY+(OffsetX1+2))   ; swap Y1 and Y2
;;;                        ld      de,(IY+(OffsetX2+2))   ;
;;;                        ld      hl,(IY+(OffsetX2+2))   ;
;;;                        ld      de,(IY+(OffsetX1+2))
;;;                        ENDM    
;;;; points in in IY = address of all 3 points in S15,S15 format
;;;l_fillTriangle:         ; Do initial off screen clip tests
;;;                        ; sortpoints Y ascending
;;;                        compareCoordsSwap 0, 4
;;;                        compareCoordsSwap 0, 8
;;;                        compareCoordsSwap 4, 8
;;;                        ld      hl,(IY+2)                ; if Y1 and Y2 are the same then its a flat top
;;;                        ld      de,(IY+6)                ; (in these routines it santity checks its not a flat line)
;;;                        cpHLEquDE
;;;                        jp      z,.PrepareFlatTopTriangle
;;;                        ld      hl,(IY+8)               ; if Y1 and Y2 are the same then its a flat bottom
;;;                        cpHLEquDE                       ;
;;;                        jp      z,.PrepareFlatBottomTriagle
;;;.SplitTriangleInTwo     ; Y2 will always be <= Y3
;;;                        ; calculate line X1Y1 to X3Y3 until y row = Y2, result is XTemp, 
;;;                        ; drawflat bottomed X1Y1, X2Y2, XTempY2
;;;                        ; drawflat topped   X2Y2, XTempY2, X3Y3
;;;                   
;;;                        
;;;
;;;
;;;; Calc X2-X1 = delta X  
;;;                        ; calc Y2-Y1 = partialY
;;;                        ; calc Y3-Y1 = fullY
;;;                        ; X2partial = X1 + (deltaX * (partialY/fullY) - Can be done by line algorithim variant?
;;;                        ; l2_fillBottomFlatTriangle (X1Y1, X2parialY2, X2Y2)
;;;                        ; l2_fillTopFlatTriangle(X2partialY2, X2Y2, X3Y3)
;;;
;;;                           X1   H           X2 H
;;;                                Y0
;; bc = x0y0, de=x1y1 hl=x2y2 a = colour
;Now Works
l2_fillAnyTriangle:     ld      a,b
                        JumpIfALTNusng   d, .noSwapY0Y1
.SwapY0Y1:              push    bc
                        ld      bc,de
                        pop     de
.noSwapY0Y1:            ld      a,b
                        JumpIfALTNusng   h, .noSwapY0Y2
.SwapY0Y2:              push    bc
                        ld      bc,hl
                        pop     hl
.noSwapY0Y2:            ld      a,d
                        JumpIfALTNusng   h, .noSwapY1Y2
.SwapY1Y2:              ex      de,hl
.noSwapY1Y2:          
.DoneYAscending:        ld      a,b
                        cp      d
                        jp      z,.PrepFlatTopTriangle
                        ld      a,d
                        cp      h
                        jp      z,.PrepFlatBottomTriangle
; Now we know we have a triangle that needs to split at point X?Y1 where X? is between X0 and X2
; Simplified expensive version for now, just call l2_draw_diagonal_save until we hit Y1 and then check for X pixel adjust
; better later to do a quick Deltaxy calc but for now we are testing
; acutallty diagnoal save will be better to do as we can calculate the line from X0 to X2 up front and save having to do that calc
; again in the top to bottom or bottom to top, we can refine it with an overshoot variable so it precalcs upto Y1 + 1 to make sure x? is correct
.SplitTriangleInTwo:    push	hl,,de,,bc                      ; save for now. bc is already X0Y0
                        ex      de,hl                           ; quick load of de with X2Y2
                        ld		a,1
                        break
                        call	l2_draw_diagonal_save           ;now we don't know if x? is going to be > x1 or no
.CheckX1:               pop     bc
                        pop     de
                        ld      hl,l2targetArray1
                        ld      a,d
                        add     hl,a
                        ld      a,(hl)                          ; now we have x?
                        pop     hl                              ; now we have bc=x0y0, de=x1y1, hl=x2y2 a = x?
; We will optimise that we ahve already calcualteed a diagnoal later
                        push    hl,,de,,bc,,af                  ; bc already = y0x0;
                        ld      h,d                             ; h = y common whch is y1
                        ld      d,e                             ; d = x1
                        ld      e,a                             ; e = x2
                        break
                        call    l2_fillBottomFlatTriangle       ;>l2_fillBottomFlatTriangle BC y0x0 DE x1x2, H YCommon, L Colour"
                        pop     hl,,de,,bc,,af
                        ld      bc,hl                           ; bc = common bottom x2y2
                        ld      h,d                             ; h = common y for flat top
                        ld      d,a                             ; d = X?, e is already x1
                        call    l2_fillTopFlatTriangle          ;>l2_fillTopFlatTriangle BC y2x2 DE x0x1, H YCommon, L Colour"    
                        ret
;; bc = x0y0, de=x1y1 hl=x2y2 a = colour
.PrepFlatTopTriangle:   ld      d,c
                        ld      bc,hl
                        call    l2_fillTopFlatTriangle          ;>l2_fillTopFlatTriangle BC y2x2 DE x0x1, H YCommon, L Colour"    
                        ret
.PrepFlatBottomTriangle:ld      d,h
                        ld      h,l
                        call    l2_fillBottomFlatTriangle       ;>l2_fillBottomFlatTriangle BC y0x0 DE x1x2, H YCommon, L Colour"
                        ret
;;;.SplitTriangleInTwo     ; Y2 will always be <= Y3
;;;                        ; calculate line X1Y1 to X3Y3 until y row = Y2, result is XTemp, 
;;;                        ; drawflat bottomed X1Y1, X2Y2, XTempY2
;;;                        ; drawflat topped   X2Y2, XTempY2, X3Y3


                        
                       ; call    l2_fillTopFlatTriangle

;; ">l2_fillTopFlatTriangle BC y2x2 DE x0x1, H YCommon, L Colour"                            X1YC            X2YC
;; b = bottomxy, de = to x1 x2, h =common top y
l2_fillTopFlatTriangle: break
                        ld		a,e                             ; check x0 x1 to make sure lines draw left to right
                        JumpIfAGTENusng d, .x2gtex1
;                        cp		e
;                        jr		nc, .x2gtex1                    ; make sureline is alwasy left to right so +ve direction
.x1ltx2:                ld		ixh,1                           ; list 1 holds x0 down to x2
                        ld		ixl,2                           ; list 2 hols  x1 down to x2
                        jr		.storepoints
.x2gtex1:               ld		ixh,2
                        ld		ixl,1
.storepoints:           push    ix
                        push	bc,,de,,hl
                        ld      a,c                             ; save    c x2
                        ld      c,d                             ; now c = d = x0
                        ld      e,a                             ; e = a = old c = x2
                        ld      d,b                             ; d = b = y2
                        ld      b,h                             ; b = h = y common
                        ld      a,ixh
                        push    hl; temp fix
                        call	l2_draw_diagonal_save			;l2_store_diagonal(x0,y0,x1,ycommon,l2_LineMinX);
                        pop     iy ;tempfix to hold y common
                        pop		bc,,de,,hl
                        pop     ix
                        push	bc,,de,,hl; of course it always assumes ?
                        ld      a,c                             ; save    c x2
                        ld      c,e                             ; now c = d = x1
                        ld      e,a                             ; e = a = old c = x2
                        ld      d,b                             ; d = b = y2
                        ld      b,iyh ;tempfix                            ; b = h = y common 
                        ld		a,ixl
                        call	l2_draw_diagonal_save			;l2_store_diagonal(x0,y0,x2,ycommon,l2_LineMaxX);
                        pop		bc,,de,,hl
                        break                                   ; so now we have two arrays loaded h = start b = end
                        ld      a,b
                        ld		b,h                             ; and set up working values as we share
                        ld		h,a								; the flat bottom code here
                        break
.OldSave:               ld		d,b
                        ld		e,h								; save loop counters
.SaveForLoop:           push	de								; de = y0ycommon
.GetFirstHorizontalRow:	ld		hl,l2targetArray1               ; get first row for loop
                        ld		a,b
                        add		hl,a							; hl = l2targetArray1 row b
                        ld		a,(hl)							;
                        ld		c,a								; c = col1 i.e. l2targetarray1[b]
                        ld      hl,l2targetArray2
                        ld      a,b
                        add     hl,a
;                        inc		h								; hl = l2targetArray2 row b if we interleave
                        ld		a,(hl)							
                        ld		d,a								; d = col2 i.e. l2targetarray2[b]
.SetColour:             ld		a,(l2linecolor)
                        ld		e,a								; de = to colour
.SavePoints:            push	bc								; bc = rowcol			
                        dec		h
                        push	hl								; hl = l2targetArray1[b]
.DoLine:	            call	l2_draw_horz_line_to
                        pop		hl
                        pop		bc
                        inc		b								; down a rowc
                        pop		de								; de = from to (and b also = current)
                        inc		d
                        ld		a,e								; while e >= d
                        cp		d
                        jr 		nc,.SaveForLoop					; Is this the right point??
                        ret

; Calulate 

; ">l2_fillBottomFlatTriangle BC y0x0 DE x1x2, H YCommon, L Colour"
; "note >l2_draw_diagonal_save, bc = y0,x0 de=y1,x1,a=array nbr ESOURCE LL30 or LION"
; "note line to   bc = left side row,col, d right pixel, l = color"
l2_fillBottomFlatTriangle:;break
                        ld      a,e
                        JumpIfAGTENusng d, .x2gtex1                       
;                        ld		a,d                             ; if x0 < x2 goto x2<x1
;                        cp		e                               ;      list 1 holds x1 down to x0
;                        ld		ixl,2                           ;      list 2 hols  x2 down to x0
;                        jr		nc, .x2gtex1                    ; 
.x1ltx2:                ld		ixh,1                           ; else list 1 holds x0 down to x1
                        ld		ixl,2                           ;      list 2 hols  x0 down to x2
                        jr		.storepoints                    ;
.x2gtex1:               ld		ixh,2                           ;
                        ld		ixl,1                           ;
.storepoints:           push    ix
                        push	bc,,de,,hl                      ; save working variables
                        ld		a,ixh
                        ld		e,d                             ; we alreay have bc so its now bc -> hd
                        ld		d,h
                        call	l2_draw_diagonal_save			;l2_store_diagonal(x0,y0,x1,ycommon,l2_LineMinX);
                        pop		bc,,de,,hl
                        pop     ix
                        push	bc,,hl
                        ld		d,h                             ; now its bc -> he
                        ld		a,ixl
                        call	l2_draw_diagonal_save			;l2_store_diagonal(x0,y0,x2,ycommon,l2_LineMaxX);
                        pop		bc,,hl
.OldSaveForLoop:           ld		d,b
                        ld		e,h								; save loop counters
.SaveForLoop:                        push	de								; de = y0ycommon
.GetFirstHorizontalRow:	ld		hl,l2targetArray1               ; get first row for loop
                        ld		a,b
                        add		hl,a							; hl = l2targetArray1 row b
                        ld		a,(hl)							;
                        ld		c,a								; c = col1 i.e. l2targetarray1[b]
                        ld      hl,l2targetArray2
                        ld      a,b
                        add     hl,a
;                        inc		h								; hl = l2targetArray2 row b if we interleave
                        ld		a,(hl)							
                        ld		d,a								; d = col2 i.e. l2targetarray2[b]
.SetColour:             ld		a,(l2linecolor)
                        ld		e,a								; de = to colour
.SavePoints:            push	bc								; bc = rowcol			
                        dec		h
                        push	hl								; hl = l2targetArray1[b]
.DoLine:	            call	l2_draw_horz_line_to
                        pop		hl
                        pop		bc
                        inc		b								; down a rowc
                        pop		de								; de = from to (and b also = current)
                        inc		d
                        ld		a,e								; while e >= d
                        cp		d
                        jr 		nc,.SaveForLoop					; Is this the right point??
                        ret

l2_fill_BoundsTest:     ld      a,ixh
                        xor     b
                        and     $80
                        jr      nz,.Y0Y1SpanScreen              ; they are opposite signs
                        ld      a,b
                        and     $80
                        jr      z,.NotOnScreen                  ; both negative if at least one is negative
                        ld      a,ixl                           ; so to get here, both must be positive
                        and     c
                        and     $80
                        jr      nz,.NotOnScreen                 ; if both ahave bit 7 set of low they are both > 127
                        ld      a,ixh
                        and     a
                        jr      z,.Y0Y1SpanScreen               ; so if Y0 is low byte only then its between 0 and 127
                        ld      a,b
                        and     a
                        jr      z,.Y0Y1SpanScreen               ; so if YCommon is low byte only then its between 0 and 127
.NotOnScreen:           SetCarryFlag
                        ret
.Y0Y1SpanScreen:         ret


;16 bit soli l2_fill16BottomFlatTriangle BC y0x0 DE x1x2, H YCommon, L Colour"
;IY Offsets IY=X0 IX=Y0 HL=X1 DE=X2 BC=YCommon A= Colour
l2_fill16BottomFlatTriangle:;break
                        ; test if Y0 and YCommon on screen 
.TestY0YCommon          ld      (l2_Y0),ix
                        ld      (l2_Y1),hl


                        ld      a,ixh
                        xor     b
                        and     $80
                        jr      nz,.Y0Y1SpanScreen              ; they are opposite signs
                        ld      a,b
                        and     $80
                        ret     z                               ; both negative if at least one is negative
                        ld      a,ixl                           ; so to get here, both must be positive
                        and     c
                        and     $80
                        ret     nz                              ; if both ahave bit 7 set of low they are both > 127
                        ld      a,ixh
                        and     a
                        jr      z,.Y0Y1SpanScreen               ; so if Y0 is low byte only then its between 0 and 127
                        ld      a,b
                        and     a
                        jr      z,.Y0Y1SpanScreen               ; so if YCommon is low byte only then its between 0 and 127
                        ret                                     ; 
.Y0Y1SpanScreen:        ret
                        
                        ld      (l2linecolor),a                 ; Set Colour
                        ;CompareHLDE
                        
                        ld      a,e
                        JumpIfAGTENusng d, .x2gtex1                       
;                        ld		a,d                             ; if x0 < x2 goto x2<x1
;                        cp		e                               ;      list 1 holds x1 down to x0
;                        ld		ixl,2                           ;      list 2 hols  x2 down to x0
;                        jr		nc, .x2gtex1                    ; 
.x1ltx2:                ld		ixh,1                           ; else list 1 holds x0 down to x1
                        ld		ixl,2                           ;      list 2 hols  x0 down to x2
                        jr		.storepoints                    ;
.x2gtex1:               ld		ixh,2                           ;
                        ld		ixl,1                           ;
.storepoints:           push    ix
                        push	bc,,de,,hl                      ; save working variables
                        ld		a,ixh
                        ld		e,d                             ; we alreay have bc so its now bc -> hd
                        ld		d,h
                        call	l2_draw_diagonal_save			;l2_store_diagonal(x0,y0,x1,ycommon,l2_LineMinX);
                        pop		bc,,de,,hl
                        pop     ix
                        push	bc,,hl
                        ld		d,h                             ; now its bc -> he
                        ld		a,ixl
                        call	l2_draw_diagonal_save			;l2_store_diagonal(x0,y0,x2,ycommon,l2_LineMaxX);
                        pop		bc,,hl
.OldSaveForLoop:           ld		d,b
                        ld		e,h								; save loop counters
.SaveForLoop:                        push	de								; de = y0ycommon
.GetFirstHorizontalRow:	ld		hl,l2targetArray1               ; get first row for loop
                        ld		a,b
                        add		hl,a							; hl = l2targetArray1 row b
                        ld		a,(hl)							;
                        ld		c,a								; c = col1 i.e. l2targetarray1[b]
                        ld      hl,l2targetArray2
                        ld      a,b
                        add     hl,a
;                        inc		h								; hl = l2targetArray2 row b if we interleave
                        ld		a,(hl)							
                        ld		d,a								; d = col2 i.e. l2targetarray2[b]
.SetColour:             ld		a,(l2linecolor)
                        ld		e,a								; de = to colour
.SavePoints:            push	bc								; bc = rowcol			
                        dec		h
                        push	hl								; hl = l2targetArray1[b]
.DoLine:	            call	l2_draw_horz_line_to
                        pop		hl
                        pop		bc
                        inc		b								; down a rowc
                        pop		de								; de = from to (and b also = current)
                        inc		d
                        ld		a,e								; while e >= d
                        cp		d
                        jr 		nc,.SaveForLoop					; Is this the right point??
                        ret


;;;;fnCompareHLDELeadSign:  cpHLDELeadSign
;;;;                        ret
;;;;                        
;;;;l2_bottomX              DW 0
;;;;l2_bottomY              DW 0
;;;;l2_leftX                DW 0
;;;;l2_rightX               DW 0
;;;;l2_commonTopY           DW 0
;;;;l2_fillTopY             DB 0
;;;;l2_fillBottomY          DB 0
;;;;;; l2_fillTopFlatTriangleSigned IY[01] bottomX[23] bottom Y [45]X1 [67]X2 [89]Common Top Y
;;;;;; Note values must be 2's c not lead sign
;;;;l2_fillTopFlatTriangleSigned: break
;;;;                        ld      hl,iy                          ; transfer to local copy off IY tables
;;;;                        ld      b,10                            ;
;;;;                        ld      de,l2_commonY                  ;
;;;;                        ldir                                   ;
;;;;                        ld      hl,(l2_leftX)
;;;;                        ld      de,(l2_rightX)
;;;;                        call    fnCompareHLDELeadSign
;;;;                        jr      c,.x1LTX2
;;;;                        ld      (l2_leftX),de                   ; swap them over to simplify later code
;;;;                        ld      (l2_rightX),hl
;;;;.x1ltx2:                call    l2_save_diagnonal_signed_1      ; will also set the fillTopX and bottomY, if Y top & bottom off screen will set Carry flag
;;;;                        ret     c
;;;;                        call    l2_save_diagnonal_signed_2
;;;;.DrawLines:             ld      a,(l2_fillTopY)
;;;;                        ld		d,a
;;;;                        ld      a,(l2_fillBottomY)              ; will always draw to 
;;;;                        ld      e,a
;;;;.SaveForLoop:           push	de								; de = y0ycommon
;;;;.GetFirstHorizontalRow:	ld		hl,l2targetArray1               ; get first row for loop
;;;;                        ld		a,b
;;;;                        add		hl,a							; hl = l2targetArray1 row b
;;;;                        ld		a,(hl)							;
;;;;                        ld		c,a								; c = col1 i.e. l2targetarray1[b]
;;;;                        ld      hl,l2targetArray2
;;;;                        ld      a,b
;;;;                        add     hl,a
;;;;;                        inc		h								; hl = l2targetArray2 row b if we interleave
;;;;                        ld		a,(hl)							
;;;;                        ld		d,a								; d = col2 i.e. l2targetarray2[b]
;;;;.SetColour:             ld		a,(l2linecolor)
;;;;                        ld		e,a								; de = to colour
;;;;.SavePoints:            push	bc								; bc = rowcol			
;;;;                        dec		h
;;;;                        push	hl								; hl = l2targetArray1[b]
;;;;.DoLine:	            call	l2_draw_horz_line_to
;;;;                        pop		hl
;;;;                        pop		bc
;;;;                        inc		b								; down a rowc
;;;;                        pop		de								; de = from to (and b also = current)
;;;;                        inc		d
;;;;                        ld		a,e								; while e >= d
;;;;                        cp		d
;;;;                        jr 		nc,.SaveForLoop					; Is this the right point??
;;;;                        ret
