OPCODE_IncHL            EQU $23
OPCODE_DecHL            EQU $2B
OPCODE_IncHLIndirect    EQU $34
OPCODE_DecHLIndirect    EQU $35
OPCODE_IncDE            EQU $13
OPCODE_DecDE            EQU $1B
OPCODE_JpNCnn           EQU $D2
OPCODE_JpCnn            EQU $DA
LOWEST_SAVE             EQU 0
HIGHEST_SAVE            EQU 1

SetIncrement:           MACRO   Location
                        ld      a,OPCODE_IncDE
                        ld      (Location),a
                        ENDM
SetDecrement:           MACRO   Location
                        ld      a,OPCODE_DecDE
                        ld      (Location),a
                        ENDM
                        
; So next optimisation
; we know that we start from row y0 to row Y0
; so we can just reference that row range and zero it out rather than the whole
; data set
l2_fillValue            DB 0
        
l2_fill_line            DB DMA_DISABLE,  DMA_RESET, DMA_RESET_PORT_A_TIMING, DMA_RESET_PORT_B_TIMING ,DMA_WRO_BLOCK_PORTA_A2B_XFR
l2_fill_colr            DW l2_fillValue
l2_fill_lenlo           DB 255
l2_fill_lenhi           DB 0
                        DB DMA_WR1_P1FIXED_MEMORY, DMA_WR2_P2INC_MEMORY, DMA_WR4_CONT_MODE
l2_fill_target          DB $00, $00
                        DB DMA_LOAD, DMA_ENABLE			   
l2_bren_cmd_len	        EQU $ - l2_fill_line
               
l2_fill_dma:            ld		(l2_fillValue),a                                 ; T=13     ;
                        ld      (l2_fill_target),hl
.write_dma:             ld 		hl, l2_fill_line                                  ;          ;
                        ld 		b, l2_bren_cmd_len                                ; 
                        ld		c,IO_DATAGEAR_DMA_PORT                            ; 
                        otir                                                      ; 
                        ret

; to find a point Y1 along a line X0Y0 to X2Y2
; DX = X2-X0, DY = Y2-Y0, D = DX/DY, X1 = X0+ ((Y1-Y0)*DX)
; will need 16.8 24 bit maths for DX DY unless we scale down and do a muliplier up
; so we could do DX = X2-X0, scale to 8.8  ... Note this will fail for extrmem near vertical or horizontal angles
;                DY = Y2-Y0, scale to 8.8  ... could we use an octlet lookup table?
;                D  = DX/DY which would give us an 8.2 proportion
; a look up table would not work for calc of DX DY but we could use a log table and anti log to simplify to add/subtract
; need a version of this that counts down to a trigger Y axis + 1, ideallign using DX DY if possible
; We may be able to use the flat top/flat botttom and pick up a calculated value 0nce it hits Y2?
; Yes logirithm table will work, need to build as a decimal set optimised
; logically if the ship is too close it will always be too close to render so we can exclude 
; excessivley large values for X and Y as they will either be too far off side or span the whole screen
; and just flood fill
; Thsi means we can do log maths for jsut 0 to 1024
; 9/11 we assume that large values will either flood fill or be straight lines
; so we allow a range of -256 to + 512 ,i.e. off screen by a whole additional screen
; then divide becomes 16 bit div 16 bit to yeild an 8.8 result. This can then be used to work out the new position
; so                    DE = DX (Ignoring signs for now)
;                       HL = DY
; we need L2_DX, L2_DY output is HL
; After workign out in excel Formulas are:
; incomming X0, Y0, Y1, DX , DY
; dY2 = Y1-Y0
; dXHi = DX/DY*256
; dxRemainder = DX-dXHi
; dXRemainder = TRUNC((dxRemainder)/DY)*256
; Integer component = dY2 * dXHi /256
; Adj     component = DY2 * dXRemainder /256
; total = Integer + Adj + X0

l2_X0                   DW 0
l2_Y0                   DW 0
l2_X1                   DW 0
l2_Y1                   DW 0
ld_YMid                 DW 0
l2_DX                   DW 0
l2_DY                   DW 0
l2_Error                DW 0
l2_E2                   DW 0
l2_dY2                  DW 0
ld_dxHi                 DW 0
l2_dxRemainder          DW 0
l2_dxRemainder2         DW 0
l2_dXRemainderAdj       DW 0
l2_integer              DW 0
l2_integer2             DW 0

ScaleDXDY:              ld      hl,(l2_DX)
                        ld      de,(l2_DY)
.ScaleLoop:             ld      a,h
                        or      d
                        jr      z,.ScaleDone
                        ShiftHLRight1
                        ShiftDERight1
                        jp      .ScaleLoop
.ScaleDone:             ld      (l2_DX),hl
                        ld      (l2_DY),de
                        ret

HLEquMidX:              ld      hl,(l2_X1)
                        ld      de,(l2_X0)
                        ClearCarryFlag
                        sbc     hl,de
                        ld      (l2_DX),hl
                        ld      hl,(l2_Y1)
                        ld      de,(l2_Y0)
                        ClearCarryFlag
                        sbc     hl,de
                        ld      (l2_DY),hl
                        ;break
                        call    ScaleDXDY
                        ld      hl,(ld_YMid)
                        ClearCarryFlag
                        sbc     hl,de
                        ld      (l2_dY2),hl
                        ld      bc,(l2_DX)          ; dXHi(DE)= DX/DY*256
                        ld      de,(l2_DY)          ; .
                        ld      ix,de               ; .
                        ld      iy,hl               ; .
;                       BC = DX/DY as 8.8           ; .
                        call    BC_Div_DE; DEequDEDivBC; DE is the result HL is the remainder
                        ld      a,b                 ; if DE is 8 bit only
                        and     a                   ; .
                        jr      z,.LT255            ; goto LT255
                        ld      bc,$FFFF            ; else set BC to $FFFF
                        jp      .DoneCalc           ; .
.LT255:                 ld      (ld_dxHi),bc        ; 
                        ld      (l2_dxRemainder),hl ; dxRemainder = DX-dXHi                    
.CalcIntegerComponent:  ;break
                        ld      hl,(l2_dY2)         ; Integer component = dY2 * dXHi /256
                        ld      de,(ld_dxHi)        ; .
                        call    DEHLequDEmulHL      ; .
                        ld      (l2_integer),de     ; .
                        ld      (l2_integer2),hl    ; .
.CalcRemainderFraction: ld      bc,(l2_dxRemainder) ; dXRemainder = TRUNC((dxRemainder)/DY)*256
                        ld      de,(l2_DY)          ; .
                        call    BC_Div_DE           ; BC, remainder in HL
                        ld      (l2_dXRemainderAdj),bc
                        ld      (l2_dxRemainder2),hl
.CalcAdjustment:        ld      hl,(l2_dY2)         ; Adj component = DY2 * dXRemainder /256
                        ld      de,bc               ;
                        call    DEHLequDEmulHL      ;
                        ld      hl,(l2_integer)
                        add     hl,de
                        ret
                        
                        
;                       HL = (DE * B) /256          
.DoneCalc:              push    bc
                        ld      e,b
                        ld      hl,ix
                        call AHLequHLmulE
                        ld l,h
                        ld h,a
                        ld      ix,hl
;                       DE = (DE * C) /256          ld e,c call AHLequHLmulE,ld l,h, ld h,a
                        pop     bc
                        ld      e,c
                        ld      hl,iy
                        call AHLequHLmulE
                        ld l,h
                        ld h,a
;                       HL + = DE
                        ld      de,ix
                        add     hl,de
;                       HL + + X0
                        ld      de,(l2_X0)
                        add     hl,de
                        ret




;; Need optimisation for vertical line and horizonal
int_bren_save_Array1Low:
                        ld      a,$FF
                        ld      hl,l2targetArray1   ; L2targetArray2 Population
                        call    l2_fill_dma
                        ld      a,OPCODE_JpCnn
                        ld      hl,l2targetArray1   ; L2targetArray2 Population
                        jp      int_bren_save_Array ; 
int_bren_save_Array1High:
                        ZeroA
                        ld      hl,l2targetArray1   ; L2targetArray2 Population
                        call    l2_fill_dma
                        ld      a,OPCODE_JpNCnn
                        ld      hl,l2targetArray1   ; L2targetArray2 Population
                        jp      int_bren_save_Array ; 
int_bren_save_Array2Low:
                        ld      a,$FF
                        ld      hl,l2targetArray2   ; L2targetArray2 Population
                        call    l2_fill_dma
                        ld      a,OPCODE_JpCnn
                        ld      hl,l2targetArray2   ; L2targetArray2 Population
                        jp      int_bren_save_Array ; 
int_bren_save_Array2High:
                        ZeroA
                        ld      hl,l2targetArray2   ; L2targetArray2 Population
                        call    l2_fill_dma
                        ld      hl,l2targetArray2   ; L2targetArray2 Population
                        ld      a,OPCODE_JpNCnn
; Uses HL DE
; Note this works out the last position for each point, not any intermediate
; so we need a version that plots lowest for left line & highest for right line
int_bren_save_Array:    ld      (.TargetArrayAddr+2),hl
                        ld      (.TargetJump),a
                        ld      hl,(l2_X1)          ; if X0 < X1
                        ld      de,(l2_X0)          ; calculate SX DX
; --- dx = abs(x1 - x0) & set up SX
                        ClearCarryFlag              ;
                        sbc     hl,de               ;
                        bit     7,h                 ;
                        jr      z,.DXPositive       ;
.DXNegative:            NegHL                       ;
                        SetDecrement .UpdateX0Operation
                        jp      .DoneCalcDx         ;
.DXPositive:            SetIncrement .UpdateX0Operation
.DoneCalcDx:            ld      (l2_DX),hl          ;
                        ld      de,(l2_X0)          ; fetch in X0 so we can exx
                        ld      bc,(l2_X1)          ; and also X1
                        exx                         ; ++now hl' = DX, DE'=X0, BC' = X1
; --- dy = -abs(y1 - y0) & set up SY
.CalcDY:                ld      hl,(l2_Y1)          ; If Y1 < Y1
                        ld      de,(l2_Y0)          ; calculate SY DY 
                        ClearCarryFlag              ;
                        sbc     hl,de               ;
                        bit     7,h                 ;
                        jr      z,.DYPositive       ;
.DYNegative:            SetDecrement .UpdateY0Operation 
                        jp      .DoneCalcDx         ;
.DYPositive:            NegHL                       ;
                        SetIncrement .UpdateY0Operation
.DoneCalcDy:            ld      (l2_DY),hl      
                        ld      de,(l2_Y0)          ; fetch in X0
                        ld      bc,(l2_Y1)          ; now hl = DY, DE=Y0, BC = Y1
; ---   error = dx + dy >> at this point hl' = DX, DE'=X0, BC' = X1 and hl = DY, DE=Y0, BC = Y1       
.CalcError:             ld      iy,hl               ; fetch DY into IY
                        exx                         ; ++now looking at DX data set and DY in alternate
                        ex      de,hl               ; quickly flip over de and to support add instruction
                        add     iy,de               ; we have set up IY as L2_Error
                        ex      de,hl
                        ld      (l2_Error),iy
; --- While True        >> at this point we are looing at DX and need to consider state at iteration loop                
.CalcLoop:              exx                         ; ++now looking at DY data set and DX in alternate
                        ;ld      hl,(l2_X0)         ; get X0 and Y0
; --- PLOT X0, Y0       >> now looking at DY data set and DX in alternate
.CheckYRange:           ;ld      de,(l2_Y0)
                        ld      a,d                 ; if Y0 > 127
                        and     a                   ; or Y0 is negative
                        jr      nz,.YOutOfRange     ; then we can skip the plot
                        ld      a,e                 ;
                        and     $80                 ;
                        jr      nz,.YOutOfRange     ;
.CheckXRange:           exx                         ; ++now looking at DX data set and DY in alternate
                        ld      a,d                 ; if X0 is negative 
                        and     a
                        jr      z,.XOKToPlot
                        and     $80
                        jr      z,.NotXNegative
.XNegative:             ld      a,0                 ; if X0 <0 > 255 then clamp it
                        jp      .ClipXDone          ;
.NotXNegative:          ld      a,255               ;
                        jp      .ClipXDone          ;
.XOKToPlot:             ld      a,e                 ; no clip therefore we can just use X0 as is
.ClipXDone:             exx                         ; ++now looking at DY data set and DX in alternate
.TargetArrayAddr:       ld      ix,l2targetArray1   ; later this will be self modifying 
                        ex      af,af'
                        ld      a,e
                        ld      (.TargetRead+2),a   ; Write Y0 offset to IX offset
                        ld      (.TargetWrite+2),a  ; Write Y0 offset to IX offset
                        ex      af,af'
                        push    bc
                        ld      b,a
.TargetRead:            ld      a,(IX+0)
                        cp      b
.TargetJump:            jp      c,.SkipWrite
                        ld      a,b
.TargetWrite:           ld      (IX+0),a            ; directly updates l2targetArray1
.SkipWrite:             pop     bc
; --- if x0 == x1 && y0 == y1 break
.YOutOfRange: ; At this point we have either plotted or its outside array range
                        exx                         ; ++now looking at DX data set and DY in alternate
;                        ld      bc,(l2_X1)
.CheckEndXY:            cpDEEquBC .CheckEndXYOK     ; de will equal X0 still by here
                        jp      nz,.x0x1Differ
.CheckEndXYOK:          exx                         ; ++ in this branch in this branchnow looking at DY data set and DX in alternate
;                        ld      bc,(l2_Y1)
                        cpDEEquBC  .x0x1Differ      ; de will equal Y0 still by here
                        exx                         ; ++ in this branch now looking at DX data set and DY in alternate
                        ret     z                   ; if they are both the same we are done
.x0x1Differ:                                        ; by this point we could be looking at DX on all branches
; --- e2 = 2 * error
.SetError2:             exx                         ; ++now looking at DY data set and DX in alternate
                        push    hl,,de              ; save HL
                        ex      de,hl               ; de = DY; could futher optimise to check DY>E2 and reduce instruction count
                        ld      hl,iy;(l2_Error)       ; e2 = 2 * error	
                        add     hl,hl               ; .
                        ld      (l2_E2),hl          ; .
                        ; before here we are looking at DY
; --- if e2 >= dy
.CheckE2gteDY:          call    compare16HLDE       ; .
                        pop     hl,,de              ; before jumps get HL back
                        jp      pe, .E2DyParitySet  ; Jump looking at DY
                        jp      m,  .E2ltDY         ; Jump looking at DY to get here overflow clear, so if m is set then HL<DE
                        jp      .E2gteDY            ; Jump looking at DY
.E2DyParitySet:         ; entering here looking at DY
                        jp      p,  .E2ltDY         ; Jump looking at DY if pe is set, then if sign is clear HL<DE
; --- if x0 == x1 break
.E2gteDY:               exx                         ; ++ in this branch now looking at DX data set and DY in alternate
                        cpDEEquBC .ErrorUpdateDY    ;      if x0 == x1 break
                        ret     z                   ;      .
; --- error = error + dy
.ErrorUpdateDY:         exx                         ; if we get here we are looking at DY data set and DX in alternate
                        push    hl,,de              ; save HL
                        ex      de,hl               ; de = DY
                        ld      hl,iy;(l2_Error)       ;      error = error + dy	
                        add     hl,de               ;      .
                        ld      iy,hl;(l2_Error),hl       ;      .
                        pop     hl,,de
; --- x0 = x0 + sx
.UpdateX0:              exx                         ; now back looking at DX data set and DY in alternate
.UpdateX0Operation:     nop                         ;      x0 = x0 +/- sx
                        exx                         ; correction on this brach so we are looking at DY 
.E2ltDY:                ; entering here, looking at DY in all branches
; --- if e2 <= dx
.CheckE2lteDX:          exx                         ; we want to look at DX
                        push    hl,,de
                        ex      de,hl               ; de = l2_DX
                        ld      hl,(l2_E2)          ; if e2 <= dx
;                        ld      de,(l2_DX)          ; as we can't do skip on e2>dx 
                        call    compare16HLDE       ; we will jump based on e2 <= dx
                        pop     hl,,de              ; recover saved HL DE
                        jp      z, .E2lteDX         ; Jump looking at DX
                        jp      pe, .E2DxParitySet  ; Jump looking at DX
                        jp      m,  .E2lteDX        ; Jump looking at DX : to get here overflow clear, so if m is set then HL<DE
                        jp      .E2gteDx            ; Jump looking at DX
.E2DxParitySet:         jp      p,  .E2lteDX        ; Jump looking at DX
                        jp      .E2gteDx            ; Jump looking at DX
; ---  if y0 == y1 break
.E2lteDX:               ; Entry looking at DX
                        exx                         ;      in branch looking at DY
                        cpDEEquBC .ErrorUpdateDX    ;      .
                        exx                         ;      in branch looking at DX
                        ret     z                   ;      .
; --- error = error + dx
.ErrorUpdateDX:         ; at this point will be looking at DX
                        push    hl,,de
                        ex      de,hl               ;      de = DY
                        ld      hl,iy;(l2_Error)       ;      error = error + dx	
                        add     hl,de               ;      .
                        ld      iy,hl;(l2_Error),hl       ;      .                        
                        pop     hl,,de
; --- y0 = y0 + sy
.UpdateY0:              exx                         ;      in this branch we are looking at DY
.UpdateY0Operation:     nop                         ;      y0 = y0 + sy
                        exx                         ;      in this branch we are looking at 
; --- Loop
.E2gteDx:               ; at this point will be looking at DX again
                        jp      .CalcLoop           ; repeat until we have a return
