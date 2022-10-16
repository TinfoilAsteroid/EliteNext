
;; NOTE DMA is little endian
l2_horz_pixel           DB 0
        
l2_horz_line            DB DMA_DISABLE,  DMA_RESET, DMA_RESET_PORT_A_TIMING, DMA_RESET_PORT_B_TIMING ,DMA_WRO_BLOCK_PORTA_A2B_XFR
l2_horz_colr            DW l2_horz_pixel
l2_horz_lenlo           DB 0
l2_horz_lenhi           DB 0
                        DB DMA_WR1_P1FIXED_MEMORY, DMA_WR2_P2INC_MEMORY, DMA_WR4_CONT_MODE
l2_horz_target          DB $00, $00
                        DB DMA_LOAD, DMA_ENABLE			   
l2_horz_cmd_len	        EQU $ - l2_horz_line


; "l2_draw_horz_dma"
; "plot at bc for length d colour e using dma, assumes bank already selected"  
l2_draw_horz_dma:       ld		a,e                                               ; T=4      ;
                        ld		(l2_horz_pixel),a                                 ; T=13     ;
                        ld      e,d ; saved 3 t states ld		a,d                                               ; T=4      ; e=d   4
                        ld      d,0; saved 3 t states ld 		(l2_horz_lenlo),a                                 ; T=13     ; d = 0  7 
                        ld      (l2_horz_lenlo),de; saved 3 t states xor 	a                                                 ; T=4      ; t 20  31
                        ; saved 3 t states ld ld 		(l2_horz_lenhi),a                                 ; T=13     ;
                      ; saved 4 t states  ld		h,b                           ;          ;
                      ; saved 4 t states  ld		l,c                           ;          ;
                        ld      (l2_horz_target),bc ; saved 4 t states  was , hl  ; T=20     ;
.write_dma:             ld 		hl, l2_horz_line                                  ;          ;
                        ld 		b, l2_horz_cmd_len                                ; 
                        ld		c,IO_DATAGEAR_DMA_PORT                            ; 
                        otir                                                      ; 
                        ret
	
; "bc = left side row,col, d = length, e = color"
l2_draw_horz_dma_bank:  push 	de							; save length and colour
                        push 	bc							; save row col
                        ld   	a,b
                        call 	asm_l2_row_bank_select		; now we have the correct bank, its a horizontal line so bank will not shift
                        pop  	bc
                        ld	 	b,a	       					; fixed row by the call we can go straight into HL with row col
                        pop  	de							; get length back
                        call    l2_draw_horz_dma
                        ret

; "l2_draw_horz_line"
; "bc = left side row,col, d = length, e = color"
; "optimisation if above min pix is will use dma call SCREEN_HOZ_MIN_PIX not implemented yet"
l2_draw_horz_line:      ld		a,d
                        cp 		0							; if its zero length then just return
.zerolengthexit:        ret		z
.isitlen1:              cp 		1
                        jp 		z,.l2_draw_horz_line_1
.longenoughtfordma:     cp  10
                        jp  l2_draw_horz_dma_bank
.plottableline:         push 	de,,bc  					; save length and colour an d row col
                        ld   	a,b
                        call 	asm_l2_row_bank_select		; now we have the correct bank, its a horizontal line so bank will not shift
                        pop  	bc
                        ld	 	h,a	       					; fixed row by the call we can go straight into HL with row col
                        ld   	l,c
                        pop  	de							; get length back
.cliptest:              ld	 	a,c							; get column + length
                        ld  	b,d  						; speculate that we don't clip by pre-loading b with length
                        add  	a,d
                        jr   	nc, .l2_draw_horz_plot_loop	; if carry is set c+d > 255
.clipat255:             ld   	a,$FF
                        sub  	c							; a holds clipped length
                        ld 		b, a 						; so now hl holds poke address  b = clipped length e = colour
                        jr		.l2_draw_horz_plot_loop		
.l2_draw_horz_plot_loop:ld (hl),e							; loop poking hl with e for b pixels
                        inc hl
                        djnz .l2_draw_horz_plot_loop
                        ret
.l2_draw_horz_line_1:   ld		a,e
                        l2_plot_macro; jp		l2_plot_pixel				; hijack return
                        ret

	
; "l2_draw_horz_line_to"
; "bc = left side row,col, d right pixel, e = color"
l2_draw_horz_line_to:   di
                        ld 		a,d
                        cp 		c
                        jr		nc, .noswap
                        jr      z, .singlepixel
.swap:                  ld		d,c
                        ld		c,a
.noswap:                ld		a,d
                        sub		c
;                        dec		a							; so now its length not offset
                        ld		d,a
                        jr 		l2_draw_horz_line			; hijack routine and return statements
.singlepixel:           ld		a,e
                        l2_plot_macro; jp		l2_plot_pixel				; hijack return
                        ret
