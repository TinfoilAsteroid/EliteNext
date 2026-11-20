CACHE_TAB_ID_OFFSET     EQU     0
CACHE_TAB_X1_OFFSET     EQU     2
CACHE_TAB_Y1_OFFSET     EQU     3
CACHE_TAB_X2_OFFSET     EQU     4
CACHE_TAB_Y2_OFFSET     EQU     5
CACHE_TAB_LR_OFFSET     EQU     6
CACHE_TAB_DX_OFFSET     EQU     7
CACHE_TAB_EXTRA_OFFSET  EQU     8
CACHE_TAB DY_OFFSET     EQU     9 
CACHE_TAB_BUFF_OFFSET   EQU     10
CACHE_TAB_BUFEND_OFFSET EQU     12
CACHE_TAB_PREV_BUFFEND_OFFSET EQU $FE                           ; -2


;de = X1, X2, b = Y1, c = Y2
PlotL2Line:             d


    5 MODE 0
   10 LET x1% = 200: LET x2% = 300: LET y1% = 10: LET y2% = 20 : LET startx1% = x1%: LET starty1% = y1% : LET lastx1% = x1%
   20 IF y1% > y2% THEN a% = x2%: x2%= x1%: x1%= a%: a% = y2%: y2%= y1%: y2 = a%
   30 IF x1% <0 OR x1% > 255 THEN REM X1 Clipped
   40 IF x2% <0 OR x2% > 255 THEN REM X2 Clipped
   50 IF y1% <0  THEN REM y1 clipped
   60 IF y2% < 0 THEN REM Y2 cliped
   70 REM draw line x1 y1 x2 y2
   80 DIM pointList%((y2%-y1%)+1,2): yidx% = 1
   90 IF x1% < x2% THEN PROC_LeftToRight ELSE dx% = x1% - x2%: PROC_RightToLeft
  990 PROC_Draw_CachedLine: STOP
  999 REM -------- Draw Left to Right ----------------------------------------------------------
 1000 DEF PROC_LeftToRight
 1010 dx% = x2% - x1% : REM dx = abs(x1 - x0)
 1020 dy% = y2% - y1% : REM calculate dy
 1030 error% = dx%+dy% : pixcnt% = 1: yidx% = 1  : PlotCNT% = 0
 1040 REM Plot loop
 1050 PLOT x1%,y1%: PlotCNT% = PlotCNT% + 1
 1060 LET e2% = 2 * error%
 1070 IF e2% >= dy% THEN
 1080   IF x1% = x2% THEN
 1090     PROC_Save_Point: GOTO 990
 1100   ELSE
 1110     error% = error% - dy%
 1120     x1% = x1% + 1: pixcnt% = pixcnt%+1
 1130   ENDIF
 1140 ENDIF
 1150 IF e2% <= dx% THEN
 1160   IF y1% = y2% THEN
 1170     PROC_Save_Point: GOTO 990
 1180   ELSE
 1190     error% = error% + dx% : PROC_Save_Point
 2000     y1% = y1% + 1
 2010   ENDIF
 2020 ENDIF
 2030 GOTO 1050
 2040 ENDPROC
 2500 DEF PROC_Draw_CachedLine
 2510 FOR i% = 1 TO 10: REM yidx%
 2520   a% = pointList%(i%,1): b% = pointList%(i%,2)
 2525   PRINT i%;"< ";a%;" > ";b%
 2530   FOR j% = 0 TO b%  -1
 2540     PLOT a% + j%, starty1%+i% + 50
 2550   NEXT j%
 2560 NEXT i%
 2570 END
 3000 DEF PROC_RightToLeft
 3010 dx% = x1% - x2% : REM dx = abs(x1 - x0)
 3020 dy% = y2% - y1% : REM calculate dy
 3030 error% = dx%+dy%
 3040 REM Plot loop
 3050 PLOT x1%,y1%
 3060 LET e2% = 2 * error%
 3070 IF e2% >= dy% THEN
 3080   IF x1% = x2% THEN
 3090     GOTO 990
 3100   ELSE
 3110     error% = error% - dy%
 3120     x1% = x1% - 1
 3130   ENDIF
 3140 ENDIF
 3150 IF e2% <= dx% THEN
 3160   IF y1% = y2% THEN
 3170     GOTO 990
 3180   ELSE
 3190     error% = error% + dx%
 3200     y1% = y1% + 1
 3210   ENDIF
 3220 ENDIF
 3270 GOTO 3050
 3280 ENDPROC
 3300 DEF PROC_Save_Point
 3310 pointList%(yidx%,1) = lastx1%
 3320 pointList%(yidx%,2) = pixcnt%
 3330 pixcnt% = 1
 3340 yidx% = yidx%+1
 3350 lastx1% = x1%
 3360 ENDPROC




; Line table consists of:
; ID <8 bit P1> <8 Bit P2>  (0,0 is end of list marker) 2 bytes  0,1
; Start <First Y coordinate for line>                   1 byte   2
; Start <First X coordinate for line>                   1 byte   3
; Start <Second Y coordinate for line>                  1 byte   4
; Start <Second X coordinate for line>                  1 byte   5
; left to right or right to left                        1 byte   6
; Len <Nbr of pixels in line> X                         1 byte   7
; len extra X pixel                                     1 byte   8
; Len <Nbr of pixels in line> Y                         1 byte   9  also = the number of byte pairs in buffer
; Addr <Pointer to line buffer>                         2 bytes  10,11
; Addr <Pointer to next line bufffer>                   2 bytes  12,13 (done to speed up cache generation)
;                                                     ---
;                                                       14 bytes 
; ---------------------------------
; The line buffer then contains all the X values for each pixel as a byte pair
;  X position, nbr of pixels along that line (in case there are 2 or more per Y)
; i.e. regardless of right to left or left to right its always top to bottom
; Input bc = PointA, PointB, always sorted Y1 to Y2
; hl = address to table entry and carry clear else carry set for no match


; Input hl = P1,P0 id, de = X1, X2, b = Y1, c = Y2, assumpt made that this line does not alredy exist in cache
; hl = address to table entry and carry clear else carry set for no match
; note for hl X1 will only ever occupy 1 byte as its the range 0 to 255
CacheLineIfNeeded:      push    hl,,de,,bc
                        call    IsLineCached
                        ret     nc
                        pop     hl,,de,,bc
                        call    CacheLine
                        ret


IsLineCached:           push    hl
                        ld      hl,L2LineCacheTable
.SearchLoop:            ld      de,(hl)
                        pop     hl
                        ld      a,d
                        or      e
                        jp      z,.NoMatch
                        ld      a,b
                        cp      d
                        jp      nz,.NotAtoB
                        ld      a,c
                        cp      e
                        jp      z,.FoundMatch
.NotAtoB:               ld      a,b
                        or      e
                        jp      nz,.NotMatchedYet
                        ld      a,c
                        or      d
                        jp      z,.FoundMatch
.NotMatchedYet:         ld      a, 10
                        add     hl,a
                        jp      .SearchLoop
.NoMatch:               SetCarryFlag
                        ret
.FoundMatch:            ClearCarryFlag
                        ret
                        
FindNextFreeCacheSlot:  ld      hl,L2LineCacheTable
.SearchLoop:            ld      de,(hl)
                        ld      a,d
                        or      e
                        ret     z
                        ld      a,8
                        add     hl,a
                        jp      .SearchLoop                      

OrderX1X2:              ld      a,d
                        cp      e
                        jp      c,.OKOrder
                        ld      d,e
                        ld      e,a
.OKOrder:                        
                        ENDM
                        
CACHE_TAB_ID_OFFSET     EQU     0
CACHE_TAB_X1_OFFSET     EQU     2
CACHE_TAB_Y1_OFFSET     EQU     3
CACHE_TAB_X2_OFFSET     EQU     4
CACHE_TAB_Y2_OFFSET     EQU     5
CACHE_TAB_LR_OFFSET     EQU     6
CACHE_TAB_DX_OFFSET     EQU     7
CACHE_TAB_EXTRA_OFFSET  EQU     8
CACHE_TAB DY_OFFSET     EQU     9 
CACHE_TAB_BUFF_OFFSET   EQU     10
CACHE_TAB_BUFEND_OFFSET EQU     12
CACHE_TAB_PREV_BUFFEND_OFFSET EQU $FE                           ; -2

LineCacheTableSize      EQU    
; Input hl = P1,P0 id, de = X1, X2, b = Y1, c = Y2, assumpt made that this line does not alredy exist in cache
; hl = address to table entry and carry clear else carry set for no match
; note for hl X1 will only ever occupy 1 byte as its the range 0 to 255
CacheLine:              push    hl,,de
.FindFreeSlot:          call    FindNextFreeCacheSlot           ; ix = next free slot
                        pop     hl,,de
                        ld      (ix+CACHE_TAB_ID_OFFSET),hl     ; ID <8 bit P1> <8 Bit P2>  (0,0 is end of list marker)
.SwapP1P2:              ld      a,d                             ; swap X1 X2
                        ld      d,e                             ; .
                        ld      e,a                             ; .
                        ld      a,b                             ; swap Y1 Y2
                        ld      b,c                             ; .
                        ld      c,a                             ; .
.YOrderOK:              push    de
.CheckforLine256Bytes:  OrderX1X2
.CheckForExtraByte:     ld      a,d                             ; if line is 0 to 255 then its 256 bytes so need to flag
                        and     a                               ; .
                        jp      nz,.Not256                      ; .
                        ld      a,e                             ; .
                        inc     a                               ; if e was 255 then +1 would make a = 0
                        jp      nz,.Not256                      ; .
.Is256:                 ld      a,255                           ; .
                        ld      (ix+CACHE_TAB_DX_OFFSET),a      ; .
                        ld      a,$FF                           ; .
                        ld      (ix+CACHE_TAB_EXTRA_OFFSET),a   ; .
                        jp      .RestoreX1X2
.Not256:                ld      a,e                             ; a= DX = abs X2-X1
                        sub     c                               ; .
.RestoreX1X2            pop     de
.CalcLRFlag:            ld      a,d
                        or      c
                        jr      nc,.WriteRLFlag
.WriteLRFlag:           ld      a,0
                        ld      (ix+CACHE_TAB_LR_OFFSET),a
                        jp      .CalcDY
.WriteRLFlag:           ld      a,$FF
                        ld      (ix+CACHE_TAB_LR_OFFSET),a
.CalcDY:                ld      a,b
                        sub     c
                        ld      (ix+CACHE_TAB_DY_OFFSET),a
.CacheeSlotHeader:      ld      (ix+CACHE_TAB_X1_OFFSET),d      ; Save X1,Y1
                        ld      (ix+CACHE_TAB_Y1_OFFSET),b      ; .
                        ld      (ix+CACHE_TAB_X2_OFFSET),e      ; Save X2,Y2
                        ld      (ix+CACHE_TAB_Y2_OFFSET),c      ; .
.CacheDataPointer:      ld      hl,(ix+CACHE_TAB_PREV_BUFFEND_OFFSET)            ; get previous table pointer
                        ld      (ix+CACHE_TAB_BUFF_OFFSET),hl   ; Addr <Pointer to line buffer>  also input hl for cache data
                     
                        ld      b,(ix+CACHE_TAB_DX_OFFSET)      ; b = line length (dx abs(x2-x1))
                        ld      c,(ix+CACHE_TAB_LR_OFFSET)      ; c = 0 for left to right or 1 for right to left, bit 7 set if its full 256
                        ld      d,(ix+CACHE_TAB_Y1_OFFSET)
                        ld      e,(ix+CACHE_TAB_DY_OFFSET)
                        ld      a,(ix+CACHE_TAB_X1_OFFSET)
                        call    CacheLineData           ; write out buffer
                        pop     ix
                        ld      (ix+CACHE_TAB_BUFEND_OFFSET),hl ; address of next free line buffer
                        ret
; Lookup table before entry will have loaded up the lookup table
; Resolution is 256x192 but we will in reality be using this over 256x128
; Cache Line
; Input: hl = pointer to line buffer
;        a = starting X1
;        b = line length (dx abs(x2-x1))
;        c = 0 for left to right or 1 for right to left, bit 7 set if its full 256
;        d = y1
;        e = Y Line length (dy y2-y1) 
; Output: hl = next free line cache location
;        (CacheLineStore) address = block of line entries 
; we have bit 7 becuase if b = 255 we wont on a djnz get 256 bytes, so if bit 7 is set, plot at the end
; as its caching and we alredy know the start we don't need the end point

ErrorMinusDY:           MACRO
                        ld      hl,(CacheError)         ; error = error - dy
                        ld      de,(CacheDY)
                        ClearCarryFlag                  ; .
                        sbc     hl,de                   ; .
                        ld      (CacheError),hl         ; .
                        ENDM

ErrorPlusDX:            MACRO
                        ld      hl,(CacheError)         ; error = error + dx
                        ld      de,(CacheDX)            ; .
                        add     hl,de                   ; .
                        ld      (CacheError),hl         ; .
                        ENDM
                        ENDM


IncrementX1Pos:         MACRO
                        ld      hl,(CacheX1)
                        inc     (hl)
                        ld      hl,(CacheXSegLength)
                        inc     (hl)
                        ld      hl,CacheXRemaining
                        dec     (hl)
                        ENDM
                        
IncrementY1Pos:         MACRO
                        ld      hl,(CacheY1)
                        inc     (hl)
                        ld      hl,CacheYRemaining
                        dec     (hl)
                        ENDM
                        
SetXSegToOne:           MACRO
                        ld      hl, (CacheXSegLength)
                        inc     (hl)
                        ld      a,(CacheX1)
                        ld      (CacheX1Current),a
                        ENDM

CacheXSegment:          MACRO
                        ld      de,(CacheXSegLength)    ; pulls in length and X1
                        ld      hl,CacheLineStore       ; save it
                        ld      (hl),de
                        ZeroA
                        ld      (CacheXSegLength),a     ; nwo reset segment
                        ld      a,(CacheX1)
                        ld      (CacheX1Current),a
                        inc     hl                      ; move on
                        ld      (CacheLineStore),hl     ; so hl = next free cache memory seg
                        ENDM

CacheX1:                DW 0
CacheXSegLength         DB 0
CacheX1Current          DB 0
CacheY1:                DB 0
CacheX2                 DW 0
CacheLineStore:         DW 0
CacheDX:                DW 0
CacheDY:                DW 0
CacheError:             DW 0
CacheE2:                DW 0
CacheXRemaining         DB 0
CacheYRemaining         DB 0
CacheXExtraPixel        DB 0
CacheX1Last             DB 0
; Note change here is that on Y increment we cache datq at the end
CacheLineData:          ld      (CacheLineStore),hl     ; Save pointer to data store
                        ld      (CacheX1),a             ; Save starting position X1 Y1
                        ld      a,d                     ; .
                        ld      (CacheY1),a             ; .
.CheckLeftToRight:      bit     0,e
                        jp      nz,CacheRightToLeft
                        ld      b,d                     ; b = nbr of pixels to draw
;---------------------- Left to Right always going top to bottom ------------------------------------
CacheLeftToRight:       
.CalcDy:                ld      a,e                     ; dy% = y2% - y1%
                        sub     d                       ; . dy will always be positive
                        ld      (CacheDY),a             ; .     
.CalcDx:                ld      a,b                     ; dx% = x2% - x1%
                        ld      (CacheDX),a             ; .
                        bit     7,a                     ; if a is negative then load latter half of DX with FF
                        ld  a   a,$FF                   ; to form a full 2's c value
                        ld      (CacheDX+1),a           ;
.CalcError:             ld      a,(CacheDY)             ; error% = dx%+dy%
                        ld      h,0                     ; . needs conversion of two 8 bit values to 16 bit
                        ld      l,a                     ; .
                        ld      a,b                     ; .
                        add     hl,a                    ; .
                        ld      (CacheError),hl         ; .
.CacheLoop:             AddOneToXSeg                    ; First Pixel on X row
.CalcE2:                ShiftHLLeft1                    ; LET e2% = 2 * error%
                        ld      (CacheE2),hl            ; .
                        ld      de,(CacheDY)            ; IF e2% >= dy% THEN
                        JumpIfHLLTDE .SkipXInc          ; .
.CheckXComplete:        ld      hl,(CacheXRemaining)    ; if x remaining = 0
                        ld      a,h                     ; .
                        or      l                       ; .
                        jp      nz,.ContinueXDrawing    ; .
                        ld      a,(CacheXExtraPixel)    ; was there a 256th pixel?
.XallDone:              and     a                       ; in this case no
                        jp      nz,.XOneMore            ;
.FinalXCache:           CacheXSegment                   ;
                        ret                             ;
.XOneMore:              ZeroA                           ; an extra pixel, so clear the extra pixel flag
                        ld      (CacheXExtraPixel),a    ;
                        inc     l                       ; and add 1 to remaining x pixels
                        ld      (CacheXRemaining)       ;
.ContinueXDrawing:      ErrorMinusDY                    ;   ELSE  error% = error% - dy%
                        IncrementX1Pos                  ;         x1% = x1% + 1
.SkipXInc:              ld      de,(CacheE2)            ; IF e2% <= dx% THEN
                        ld      hl,(CacheDX)            ; . we reverse this so its if dx < e2 then skip this branch
                        JumpIfHLLTDE .CacheLoop         ; . if not then we can continue looping
                        ld      a,(CacheYRemaining)     ;   IF y1% = y2% THEN
                        or      a                       ;     
                        jp      nz,.StillMore           ; 
.FinalYCacheUpdate:     CacheXSegment                   ;     perform final pending cache update
                        ret                             ;     GOTO 990
.StillMore              ErrorPlusDX                     ;   ELSE error% = error% + dx%
                        CacheXSegment                   ;        write cache line result & set seg length to 0 & fix xpos
                        IncrementY1Pos                  ;        y1% = y1% + 1
                        jp      .CacheLoop              ; loop around again
CacheRightToLeft:       break
;;;;   5 MODE 0
;;;;  10 LET x1% = 200: LET x2% = 300: LET y1% = 10: LET y2% = 20 : LET startx1% = x1%: LET starty1% = y1% : LET lastx1% = x1%
;;;;  20 IF y1% > y2% THEN a% = x2%: x2%= x1%: x1%= a%: a% = y2%: y2%= y1%: y2 = a%
;;;;  30 IF x1% <0 OR x1% > 255 THEN REM X1 Clipped
;;;;  40 IF x2% <0 OR x2% > 255 THEN REM X2 Clipped
;;;;  50 IF y1% <0  THEN REM y1 clipped
;;;;  60 IF y2% < 0 THEN REM Y2 cliped
;;;;  70 REM draw line x1 y1 x2 y2
;;;;  80 DIM pointList%((y2%-y1%)+1,2): yidx% = 1
;;;;  90 IF x1% < x2% THEN PROC_LeftToRight ELSE dx% = x1% - x2%: PROC_RightToLeft
;;;; 990 PROC_Draw_CachedLine: STOP
;;;; 999 REM -------- Draw Left to Right ----------------------------------------------------------
;;;;1000 DEF PROC_LeftToRight
;;;;1010 dx% = x2% - x1% : REM dx = abs(x1 - x0)
;;;;1020 dy% = y2% - y1% : REM calculate dy
;;;;1030 error% = dx%+dy% : pixcnt% = 1: yidx% = 1  : PlotCNT% = 0
;;;;1040 REM Plot loop
;;;;1050 PLOT x1%,y1%: PlotCNT% = PlotCNT% + 1
;;;;1060 LET e2% = 2 * error%
;;;;1070 IF e2% >= dy% THEN
;;;;1080   IF x1% = x2% THEN
;;;;1090     PROC_Save_Point: GOTO 990
;;;;1100   ELSE
;;;;1110     error% = error% - dy%
;;;;1120     x1% = x1% + 1: pixcnt% = pixcnt%+1
;;;;1130   ENDIF
;;;;1140 ENDIF
;;;;1150 IF e2% <= dx% THEN
;;;;1160   IF y1% = y2% THEN
;;;;1170     PROC_Save_Point: GOTO 990
;;;;1180   ELSE
;;;;1190     error% = error% + dx% : PROC_Save_Point
;;;;2000     y1% = y1% + 1
;;;;2010   ENDIF
;;;;2020 ENDIF
;;;;2030 GOTO 1050
;;;;2040 ENDPROC
;;;;2500 DEF PROC_Draw_CachedLine
;;;;2510 FOR i% = 1 TO 10: REM yidx%
;;;;2520   a% = pointList%(i%,1): b% = pointList%(i%,2)
;;;;2525   PRINT i%;"< ";a%;" > ";b%
;;;;2530   FOR j% = 0 TO b%  -1
;;;;2540     PLOT a% + j%, starty1%+i% + 50
;;;;2550   NEXT j%
;;;;2560 NEXT i%
;;;;2570 END
;;;;3000 DEF PROC_RightToLeft
;;;;3010 dx% = x1% - x2% : REM dx = abs(x1 - x0)
;;;;3020 dy% = y2% - y1% : REM calculate dy
;;;;3030 error% = dx%+dy%
;;;;3040 REM Plot loop
;;;;3050 PLOT x1%,y1%
;;;;3060 LET e2% = 2 * error%
;;;;3070 IF e2% >= dy% THEN
;;;;3080   IF x1% = x2% THEN
;;;;3090     GOTO 990
;;;;3100   ELSE
;;;;3110     error% = error% - dy%
;;;;3120     x1% = x1% - 1
;;;;3130   ENDIF
;;;;3140 ENDIF
;;;;3150 IF e2% <= dx% THEN
;;;;3160   IF y1% = y2% THEN
;;;;3170     GOTO 990
;;;;3180   ELSE
;;;;3190     error% = error% + dx%
;;;;3200     y1% = y1% + 1
;;;;3210   ENDIF
;;;;3220 ENDIF
;;;;3270 GOTO 3050
;;;;3280 ENDPROC
;;;;3300 DEF PROC_Save_Point
;;;;3310 pointList%(yidx%,1) = lastx1%
;;;;3320 pointList%(yidx%,2) = pixcnt%
;;;;3330 pixcnt% = 1
;;;;3340 yidx% = yidx%+1
;;;;3350 lastx1% = x1%
;;;;3360 ENDPROC


