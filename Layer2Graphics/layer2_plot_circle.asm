
l2_circle_pos		DW 0
l2_circle_colour	DB 0
l2_circle_radius	DB 0
l2_circle_x			DB 0
l2_circle_y			DB 0
l2_circle_d			DB 0

l2_circle_xHeap 	DS 2*66
l2_circle_yHeap     DS 2*66
l2_circle_heap_size DB 0
l2_circle_clip_y    DW 0
l2_circle_clip_x    DW 0
l2_circle_flag      DB 0
l2_circle_counter   DB 0
;Sine table
;FOR I%, 0, 31
;
; N = ABS(SIN((I% / 64) * 2 * PI))
;
; IF N >= 1
;  EQUB 255
; ELSE
;  EQUB INT(256 * N + 0.5)
; ENDIF
;
;NEXT
;---------------------------------------------------------------------------------------------------------------------------------
; in HL = xPixelPos, DE = yPixelPos, A = Radius
;IFDEF   CIRCLE2
;;;;+l2_circle_clipped:	ld		(l2_circle_radius),a
;;;;+					ld		(l2_circle_clip_y),de
;;;;+					ld		(l2_circle_clip_x),hl
;;;;+					ZeroA
;;;;+					ld		(l2_circle_heap_size),a
;;;;+					ld		(l2_circle_counter),a
;;;;+					dec		a
;;;;+					ld		(l2_circle_flag),a
;;;;+.CircleLoop:		call	SinCounter						; a = sin (counter) * 256
;;;;+					ld		d,a
;;;;+					ld		a,(l2_circle_radius)
;;;;+					ld		e,a
;;;;+					mul										; de = k * sin (counter) so d = k * sin (counter) / 256
;;;;+					ld		e,d								; using de as TA
;;;;+					ld		d,0
;;;;+					ld		a,(l2_circle_counter)
;;;;+					JumpIfALTNusng 33,.RightHalf
;;;;+.LeftHalf:			NegateDE								; if >= 33 then DE = de * -1 (2's c)
;;;;+					K6 = de + l2_circle_clip_x
;;;;+					call	CosCounter
;;;;+					ld		d,a
;;;;+					ld		a,(l2_circla_radius)
;;;;+					mul		de
;;;;+					ld		e,d
;;;;+					ld		d,0
;;;;+					a 		= l2_counter + 15 mod 64
;;;;+					JumpIfALTNusng	33, .BottomHalf
;;;;+.TopHalf:			NegateDE
;;;;+					K62 = de + l2_circle_clip_y
;;;;+					ld		a,(l2_circle_flag)
;;;;+					JumpIfAIsZZero		.SkipFlagUpdate
;;;;+					inc		a
;;;;+					ld		(l2_circle_flag),a
;;;;+.SkipFlagUpdate:	
;;;;+					
;;;;+                X = K * SIN (CNT + 16) (i.e X = K * COS (CNT)
;;;;+                A = (CNT + 15) mod 64
;;;;+                if  A >= 33     ; top half of circle
;;;;+                    X = neg X
;;;;+                    T = negative
;;;;+                call    Bline (draw segment)
;;;;+                        K6(32) = TX + K4(10) = y corrc of center + new point
;;;;+                        if flag <> 0
;;;;+                            flag ++ (as flag initially will be $FF so go to 0)
;;;;+                        BL5:    
;;;;+                        if LSY2[LSP-1] <> $FF and LSY2 [LSP1] <> $FF    (BL5)
;;;;+                            X15 [0 1] = K5(10)                      (BL1)
;;;;+                            X15 [2 3] = K5(32)
;;;;+                            X15 [4 5] = K6(10)
;;;;+                            X15 [6 7] = K6(32)
;;;;+                            call clip X1Y1 to X2Y2
;;;;+                            if Line off scren goto BL5
;;;;+                            IF swap <> 0
;;;;+                                swap X1Y1 with X2Y2
;;;;+                            Y = LAP                                 (BL9)
;;;;+                            A = LSY2-1 [Y]
;;;;+                            if A = $FF
;;;;+                                LSX2[Y] = X1
;;;;+                                LSY2[Y] = Y1
;;;;+                                Y++
;;;;+                                
;;;;+                            Store X2 in LSX2(Y)                     (BL8)
;;;;+                            Store Y2 in lSY2(y)
;;;;+                            call    DrawLine from (X1 Y1 to X2 Y2)
;;;;+                            if  XX13 <> 0 goto BL5
;;;;+                                                                (BL7)
;;;;+                        Copy data for K6(3210) into K5(3210) for next call (K5(10) = x  K5(32) = y)
;;;;+                        CNT = CNT + STP
;;;;+            while CNT < 65
;ENDIF

; ix = x Position, iy = y position, d = radius in Leading sign magnitude

;EliteCheckOnSM:     ld      
;; ix = x Position, iy = y position, d = radius in 2's compliment
;;EliteCheckOn2c:
;;.CheckXOffLeft:     ld      hl,ix               ; if x position + radius is < 0 then its off screen
;;                    ld      c,d                 ; use c as a temporary holding
;;                    ld      d,0                 ;
;;                    ld      e,c                 ;
;;                    ClearCarryFlag              ;
;;                    adc     hl,de               ;
;;                    jp      m, .NotOnScreen     ;
;;.CheckXOffRight:    ld      hl,ix               ; if x position - radius > 255 then its off screen
;;                    ClearCarryFlag              ;
;;                    sbc     hl,de               ;
;;                    ld      a,h                 ;
;;                    and     a
;;                    jp      nz,.NotOnScreen
;;.CheckXOffLeft:     ld      hl,iy               ; if y position + radius is < 0 then its off screen
;;                    ld      c,d                 ; use c as a temporary holding
;;                    ld      d,0                 ;
;;                    ld      e,c                 ;
;;                    ClearCarryFlag              ;
;;                    adc     hl,de               ;
;;                    jp      m, .NotOnScreen     ;
;;.CheckXOffRight:    ld      hl,iy               ; if y position - radius > 255 then its off screen
;;                    ClearCarryFlag              ; if y position - radius > 127 then also off screen
;;                    sbc     hl,de               ;
;;                    ld      a,h                 ;
;;                    and     a                   ;
;;                    jp      nz,.NotOnScreen     ;
;;                    ld      a,l                 ;
;;                    and     $80                 ;
;;                    jp      nz,.NotOnScreen     ;
;;.OnScreen:          ClearCarryFlag
;;                    ret
;;.NotOnScreen:       SetCarryFlag
;;                    ret


;;CircleRadius        DB      0
;;CircleStep          DB      0
;;CircleFlag          DB      0
;;CircleCounter       DB      0
;;; EliteCircle, uses lines as per original elite
;;; ix = x Position, iy = y position, d = radius, e = colour x and y are 2's compliment not leading sign
;;EliteCircle:        push    de                      ; save radius
;;                    call    EliteCheckOn2c          ; if its off screen carry will be set to
;;                    ret     c                       ;
;;                    pop     de                      ; set X (or in our case circle radius) to radius
;;                    ld      a,d                     ;
;;                    ld      (CircleRadius),a        ;
;;                    ld      d,8
;;                    JumpIfALTNusng  d,.DoneRadius   ; If the radius < 8, skip to PL89
;;                    srl     d                       ; Halve d so d = 4
;;                    JumpifALTNusng  60,.DoneRadius  ; If the radius < 60, skip to PL89
;;                    srl     d                       ; Halve d so d = 2
;;.DoneRadius:        ld      a,d                     ; Now store value in d into step
;;                    ld      (CircleStep),a           
;;; ix = x Position, iy = y position, CircleRadius = radius, CircleStep = step value based on radius, must be on screen
;;EliteCircle2:       ld      a,$FF                   ; set flag for first plot
;;                    ld      (CircleFlag),a
;;                    inc     a                       ; set counter to 0 (goes to 64)
;;                    ld      (CircleCounter),a
;;.CircleLoop:        ld      a,(CircleCounter)       ; Set A = CNT
;;
;; JSR FMLTU2             \ Call FMLTU2 to calculate:
;;                        \
;;                        \   A = K * sin(A)
;;                        \     = K * sin(CNT)
;;
;; LDX #0                 \ Set T = 0, so we have the following:
;; STX T                  \
;;                        \   (T A) = K * sin(CNT)
;;                        \
;;                        \ which is the x-coordinate of the circle for this count
;;
;; LDX CNT                \ If CNT < 33 then jump to PL37, as this is the right
;; CPX #33                \ half of the circle and the sign of the x-coordinate is
;; BCC PL37               \ correct
;;
;; EOR #%11111111         \ This is the left half of the circle, so we want to
;; ADC #0                 \ flip the sign of the x-coordinate in (T A) using two's
;; TAX                    \ complement, so we start with the low byte and store it
;;                        \ in X (the ADC adds 1 as we know the C flag is set)
;;
;; LDA #&FF               \ And then we flip the high byte in T
;; ADC #0
;; STA T
;;
;; TXA                    \ Finally, we restore the low byte from X, so we have
;;                        \ now negated the x-coordinate in (T A)
;;
;; CLC                    \ Clear the C flag so we can do some more addition below
;;
;;.PL37
;;
;; ADC K3                 \ We now calculate the following:
;; STA K6                 \
;;                        \   K6(1 0) = (T A) + K3(1 0)
;;                        \
;;                        \ to add the coordinates of the centre to our circle
;;                        \ point, starting with the low bytes
;;
;; LDA K3+1               \ And then doing the high bytes, so we now have:
;; ADC T                  \
;; STA K6+1               \   K6(1 0) = K * sin(CNT) + K3(1 0)
;;                        \
;;                        \ which is the result we want for the x-coordinate
;;
;; LDA CNT                \ Set A = CNT + 16
;; CLC
;; ADC #16
;;
;; JSR FMLTU2             \ Call FMLTU2 to calculate:
;;                        \
;;                        \   A = K * sin(A)
;;                        \     = K * sin(CNT + 16)
;;                        \     = K * cos(CNT)
;;
;; TAX                    \ Set X = A
;;                        \       = K * cos(CNT)
;;
;; LDA #0                 \ Set T = 0, so we have the following:
;; STA T                  \
;;                        \   (T X) = K * cos(CNT)
;;                        \
;;                        \ which is the y-coordinate of the circle for this count
;;
;; LDA CNT                \ Set A = (CNT + 15) mod 64
;; ADC #15
;; AND #63
;;
;; CMP #33                \ If A < 33 (i.e. CNT is 0-16 or 48-64) then jump to
;; BCC PL38               \ PL38, as this is the bottom half of the circle and the
;;                        \ sign of the y-coordinate is correct
;;
;; TXA                    \ This is the top half of the circle, so we want to
;; EOR #%11111111         \ flip the sign of the y-coordinate in (T X) using two's
;; ADC #0                 \ complement, so we start with the low byte in X (the
;; TAX                    \ ADC adds 1 as we know the C flag is set)
;;
;; LDA #&FF               \ And then we flip the high byte in T, so we have
;; ADC #0                 \ now negated the y-coordinate in (T X)
;; STA T
;;
;; CLC                    \ Clear the C flag so we can do some more addition below
;;
;;.PL38
;;
;; JSR BLINE              \ Call BLINE to draw this segment, which also increases
;;                        \ CNT by STP, the step size
;;
;; CMP #65                \ If CNT >= 65 then skip the next instruction
;; BCS P%+5
;;
;; JMP PLL3               \ Jump back for the next segment
;;
;; CLC                    \ Clear the C flag to indicate success
;;
;; RTS                    \ Return from the subroutine
;;; ">L2_draw_circle16 bit" ix = x Position, iy = y position, d = radius, e = colour
;;; draw using minium squared algorithm
;;;
;;CircleCurrentX      DB      0
;;CircleCurrentY      DB      0
;;CircleCurrentError  DW      0
;;l2_draw_circle16bit:ld      
;;.ConvertIXto2sC
;;.ConvertIYto2sC
;;.ZeroCurrentError
;;.SetCurrentXRadius: 
;;.ZeroCurrentY
;;.DrawPixels:        
;;
;;                    MMUSelectLayer2                 
;;.PlotLoop:          
;;.Plot1:             
;;
;;.Plot2:
;;
;;.Plot3:
;;
;;.Plot3:
;;
;;.Plot5:
;;
;;.Plot6:
;;
;;.Plot7:
;;
;;.Plot8:
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;                    ld      a,(CurrentX)    ; if x <= y then break loop
;;                    ld      hl,CurrentY     ; .
;;                    cp      (hl)            ; .
;;                    ret     z               ; . X = Y
;;                    ret     c               ; . X < Y
;;.UpdateError:       ld      a,(CurrentY)    ; e += 2*y + 1
;;                    ld      e,a
;;                    ld      d,0
;;                    ShiftDELeft1
;;                    inc     de
;;                    ld      hl,(CircleCurrentError)
;;                    ClearCarryFlag
;;                    adc     hl,de
;;                    ld      (CircleCurrentError),hl
;;.NextCurrentY:      ld      hl,CircleCurrentY
;;                    inc     (hl)
;;.CheckEgtX:         ld      hl,(CircleCurrentError)
;;                    ld      a,(CircleCurrentX)
;;                    ld      d,0
;;                    ld      e,0
;;                    cpHLDE
;;                    jp      z,.AdjustError
;;                    jp      nc,.PlotLoop
;;.AdjustError:       ld      a,(CircleCurrentX)
;;                    ld      d,0
;;                    ld      e,a
;;                    ShiftDELeft1
;;                    ld      hl,(CircleCurrentError)
;;                    inc     hl
;;                    ClearCarryFlag
;;                    sbc     hl,de
;;                    ld      a,e
;;                    dec     a
;;                    ld      (CircleCurrentX),a
;;                    jp      .PlotLoop
;;;plot pixel at x = de y = bc
;;.PlotPixelBCDE:     ld		a,0                     ; This was originally indirect, where as it neeed to be value
;;                    push	de,,bc,,hl
;;                    ld      a,d                     ; if d is not zero then it must be -ve or > 255 to skip
;;                    and     a                       ;
;;                    ret     nz                      ;
;;                    ld      a,b                     ; if b is not zero then it must be -ve or > 255 to skip
;;                    and     a
;;                    ret     nz
;;                    ld      a,c                     ; but also check if y > 127 and if so skip
;;                    and     $80
;;                    ret     nz
;;                    ld      a,c                     ; so we can now plot
;;                    call    asm_l2_row_bank_select
;;                    ld      h,a
;;                    ld      l,e
;;                    ld      a,(line_gfx_colour)
;;                    ld      (hl),a
;;                    pop		de,,bc,,hl
;;                    ret
;;

;---------------------------------------------------------------------------------------------------------------------------------
; ">l2_draw_circle BC = center row col, d = radius, e = colour"
l2_draw_circle:     ld		a,e
                    ld		(.PlotPixel+1),a
                    ld		a,d								; get radius
                    and		a
                    ret		z
                    cp		1
                    jp		z,CircleSinglepixel
                    ld		(.Plot1+1),bc	        ; save origin into cXcY reg in code
                    ld		ixh,a			        ; ixh =  x = raidus
                    ld		ixl,0			        ; iyh =  y = 0
.calcd:	            ld		h,0     
                    ld		l,a     
                    add		hl,hl			        ; hl = r * 2
                    ex		de,hl			        ; de = r * 2
                    ld		hl,3        
                    and		a       
                    sbc		hl,de			        ; hl = 3 - (r * 2)
                    ld		b,h     
                    ld		c,l				        ; bc = 3 - (r * 2)
.calcdelta:         ld		hl,1
                    ld		d,0
                    ld		e,ixl
                    and		a
                    sbc		hl,de
.Setde1:            ld		de,1
.CircleLoop:        ld		a,ixh
                    cp		ixl
                    ret		c
.ProcessLoop:	    exx
.Plot1:             ld		de,0                    ; de = cXcY
                    ld		a,e                     ; c = cY + error
                    add		a,ixl                   ;
                    ld		c,a                     ;
                    ld		a,d                     ; b = xY+radius
                    add		a,ixh                   ;
                    ld		b,a                     ;
                    call	.PlotPixel			    ;CX+X,CY+Y
.Plot2:             ld 		a,e
                    sub 	ixl
                    ld 		c,a
                    ld 		a,d
                    add 	a,ixh
                    ld		b,a
                    call	.PlotPixel			    ;CX-X,CY+Y
.Plot3:             ld 		a,e
                    add		a,ixl
                    ld 		c,a
                    ld 		a,d
                    sub 	ixh
                    ld 		b,a
                    call	.PlotPixel			    ;CX+X,CY-Y
.Plot4:             ld 		a,e
                    sub 	ixl
                    ld 		c,a
                    ld 		a,d
                    sub 	ixh
                    ld 		b,a
                    call	.PlotPixel			    ;CX-X,CY-Y
.Plot5:	            ld 		a,d
                    add 	a,ixl
                    ld 		b,a
                    ld 		a,e
                    add 	a,ixh
                    ld 		c,a
                    call	.PlotPixel			    ;CY+X,CX+Y
.Plot6:	            ld 		a,d
                    sub 	ixl
                    ld 		b,a
                    ld 		a,e
                    add 	a,ixh
                    ld 		c,a
                    call	.PlotPixel			    ;CY-X,CX+Y
.Plot7:	            ld 		a,d
                    add 	a,ixl
                    ld 		b,a
                    ld 		a,e
                    sub 	ixh
                    ld 		c,a
                    call	.PlotPixel			    ;CY+X,CX-Y
.Plot8:	            ld 		a,d
                    sub 	ixl
                    ld		b,a
                    ld 		a,e
                    sub 	ixh
                    ld 		c,a
                    call	.PlotPixel			    ;CY-X,CX-Y
                    exx
.IncrementCircle:	bit     7,h				        ; Check for Hl<=0
                    jr z,   .draw_circle_1
                    add hl,de			            ; Delta=Delta+D1
                    jr      .draw_circle_2		; 
.draw_circle_1:		add     hl,bc			        ; Delta=Delta+D2
                    inc     bc
                    inc     bc				        ; D2=D2+2
                    dec     ixh				        ; Y=Y-1
.draw_circle_2:		inc bc				            ; D2=D2+2
                    inc bc          
                    inc de				            ; D1=D1+2
                    inc de	            
                    inc ixl				            ; X=X+1
                    jp      .CircleLoop
.PlotPixel:         ld		a,0                     ; This was originally indirect, where as it neeed to be value
                    push	de,,bc,,hl
                    l2_plot_macro; call 	l2_plot_pixel_y_test
                    pop		de,,bc,,hl
                    ret
CircleSinglepixel:  ld		a,e
                    l2_plot_macro; call	l2_plot_pixel_y_test
                    ret

CalcNewPointMacro:  MACRO reg1, oper, reg2
                    ClearCarryFlag
                    ld      b,0
                    ld      c,reg2
                    oper    hl,bc
                    ENDM

; ">l2_draw_clipped_circle HL = Center X 2's c, DE = Center Y 2's , c = radius, b = colour"
l2_draw_clipped_circle:     
                    ld      a,b                     ; save Colour
                    ld		(.PlotColour+1),a
                    ld		a,c								; get radius
                    ReturnIfAIsZero
                    JumpIfAEqNusng  1, .circleSinglepixel
                    ld		(.Plot1Y+1),de					; save origin into DE and HL
                    ld      (.Plot1X+1),hl                  ; .
                    DISPLAY "TODO : IXH and IXL need to be 16 bit and in IX and IY"
                    ld		ixh,a							; ixh = x = raidus 
                    ld		ixl,0						    ; ixl = y = error 
.calcd:	            ld		h,0                             ; hl = radius
                    ld		l,a                             ; raidius is still in a at this point
                    add		hl,hl							; hl = r * 2
                    ex		de,hl							; de = r * 2
                    ld		hl,3                            ; hl = 3 - (r * 2)
                    ClearCarryFlag                          ; .
                    sbc		hl,de							; .
                    ld      bc,hl                           ; bc = 3 - (r * 2)
.calcdelta:         ld		hl,1                            ; hl = 1
                    ld		d,0                             ; de = ixl (error)
                    ld		e,ixl                           ; 
                    ClearCarryFlag                          ;
                    sbc		hl,de                           ; hl = 1 - error
.Setde1:            ld		de,1                            ; de = 1
.CircleLoop:        ReturnIfRegLTNusng ixh, ixl             ; if radius > ixl counter
.ProcessLoop:	    exx                                     ; save all bc,de,hl registers
;--- CX+X,CY+Y ---------------------------------------------;
.Plot1Y:            ld		de,0                            ; this is Y coord
.Plot1X:            ld      hl,0                            ; this is x coord
                    push    hl,,de
                    CalcNewPointMacro hl, adc, ixh          ;
                    ex      de,hl                           ; de = x coord calculated, hl =y center Y
                    CalcNewPointMacro hl, adc, ixl          ;
                    call	.PlotPixel	            		; CX+X,CY+Y using DE = x and hl = y *** Note if we order plot 1 to 8 we can selectivley jump past many on elimiation check
.Plot1Done:         pop     hl,,de                          ; get de (y) and hl (x) back but reversed as the next plot expected the to be reversed from the ex de,hl above  + 0
;--- CX+X,CY-Y ---------------------------------------------;
.Plot2:             push    hl,,de                          ; e.g  do all CX + X first, so plot1, plot3 and just one check for cx + x off screen                    
                    CalcNewPointMacro hl, adc, ixh          ;
                    JumpIfRegIsNotZero  h,.Plot2Done        ;
                    ex      de,hl                           ; de = calculated x
                    CalcNewPointMacro hl, sbc, ixl          ;
                    call	.PlotPixel	                    ; CX-X,CY+Y                                     
.Plot2Done:         pop     hl,,de
;--- CX-X,CY-Y ---------------------------------------------; bollocksC
.Plot3:             push    hl,,de
                    CalcNewPointMacro hl, sbc, ixh          ;
                    JumpIfRegIsNotZero  h,.Plot3Done        ; 
                    ex      de,hl                           ; de = calculated x
                    CalcNewPointMacro hl, sbc, ixl          ;
                    call	.PlotPixel	                    ; CX+X,CY-Y                      
.Plot3Done:         pop     hl,,de
;--- CX-X,CY+Y ---------------------------------------------; bollocks
.Plot4:             push    hl,,de
                    CalcNewPointMacro hl, sbc, ixh          ;
                    JumpIfRegIsNotZero  h,.Plot4Done     
                    ex      de,hl                    
                    CalcNewPointMacro hl, adc, ixl          ;
                    call	.PlotPixel	                    ; CX-X,CY-Y                  
.Plot4Done:         pop     hl,,de
;--- CX+Y,CY+X ---------------------------------------------; bollocks
.Plot5:             push    hl,,de
                    CalcNewPointMacro hl, adc, ixl          ;
                    JumpIfRegIsNotZero  h,.Plot5Done     
                    ex      de,hl                    
                    CalcNewPointMacro hl, adc, ixh          ;
                    call	.PlotPixel	                    ;CY+X,CX+Y
.Plot5Done:         pop     hl,,de
;--- CX+Y,CX-X ---------------------------------------------;bollocks
.Plot6:             push    hl,,de
                    CalcNewPointMacro hl, adc, ixl          ;
                    JumpIfRegIsNotZero  h,.Plot6Done     
                    ex      de,hl                    
                    CalcNewPointMacro hl, sbc, ixh          ;
                    call	.PlotPixel	                    ; CY-X,CX+Y                
.Plot6Done:         pop     hl,,de
;--- CX-Y,CY-X ---------------------------------------------;bollocksC
.Plot7:             push    hl,,de
                    CalcNewPointMacro hl, sbc, ixl          ;
                    JumpIfRegIsNotZero  h,.Plot7Done     
                    ex      de,hl                    
                    CalcNewPointMacro hl, sbc, ixh          ;
                    call	.PlotPixel	                    ; CY+X,CX-Y                
.Plot7Done:         pop     hl,,de
;--- CX-Y,CY+X ---------------------------------------------; bollocks
.Plot8:             push    hl,,de
                    CalcNewPointMacro hl, sbc, ixl          ;
                    JumpIfRegIsNotZero  h,.Plot8Done     
                    ex      de,hl                    
                    CalcNewPointMacro hl, adc, ixh          ;
                    call	.PlotPixel	                    ; CY-X,CX-Y                 
.Plot8Done:         pop     hl,,de
.PlotDone:          exx
.IncrementCircle:	bit     7,h				; Check for Hl<=0
                    jr z,   .draw_circle_1
                    add hl,de			; Delta=Delta+D1
                    jr      .draw_circle_2		; 
.draw_circle_1:		add     hl,bc			; Delta=Delta+D2
                    inc     bc
                    inc     bc				; D2=D2+2
                    dec     ixh				; Y=Y-1
.draw_circle_2:		inc     bc				; D2=D2+2
                    inc     bc
                    inc     de				; D1=D1+2
                    inc     de	
                    inc     ixl				; X=X+1
                    jp      .CircleLoop
.PlotPixel:         ld      a,d             ; filter x> 256 or negative
                    and     a
                    ret     nz
                    ld      a,h             ; filter y > 256 or negative
                    and     a
                    ret     nz
                    ld      a,l             ; filter y > 127
                    and     $80
                    ret     nz
.PlotColour:        ld		a,0             ; This was originally indirect, where as it neeed to be value
                    push	de,,bc,,hl
                    ld      b,l             ; At this point de = x and hl = y
                    ld      c,e
                    l2_plot_macro; call 	l2_plot_pixel_y_test
                    pop		de,,bc,,hl
                    ClearCarryFlag
                    ret
.circleSinglepixel: ld      a,h             ; as its 1 pixel if h or d are non zero then its off screen
                    or      d
                    ret     nz
                    bit     7,e             ; and if Y is > 127 then off screen , bit is 8 states like ld a,e and a
                    ret     nz
                    ld      a,b             ; a = colour
                    ld      b,e             ; b = y
                    ld      c,l             ; c = x
                    call    l2_plot_pixel
                    ret