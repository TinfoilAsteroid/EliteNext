
varL2_BANK_SELECTED			 DB	0
varL2_CURRENT_BANK           DB	0
varL2_BUFFER_MODE            DB 0
varL2_ACCESS_MODE            DB 0
varL2_SAVED_SELECT           DB 0
varL2_SAVED_OFFSET           DB 0

asm_l2_double_buffer_on:    ld      a,8
                            ld      (varL2_BUFFER_MODE),a
                            ret

asm_l2_double_buffer_off:   xor     a
                            ld      (varL2_BUFFER_MODE),a
                            ret

asm_disable_l2_readwrite:   ld      bc, IO_LAYER2_PORT
                            in      (c)
                            ld      (varL2_ACCESS_MODE),a
                            and     LAYER2_DISABLE_MEM_ACCESS
                            out     (c),a
                            ret

asm_restore_l2_readwrite:   ld      a,(varL2_ACCESS_MODE)
                            and     LAYER2_READ_WRITE_MASK
                            ld      d,a
                            ld      bc, IO_LAYER2_PORT
                            in      (c)
                            ld      (varL2_ACCESS_MODE),a
                            and     d
                            out     (c),a
                            ret  

asm_enable_l2_readwrite:    ld      bc, IO_LAYER2_PORT
                            in      (c)
                            or      LAYER2_READ_WRITE_MASK
                            out     (c),a
                            ret                               
    
; "asm_l2_bank_select"
; " a = sepecific bank mask value to select, does not set varL2_BANK_SELECTED"
asm_l2_bank_select:         ld      d,a
                            cp      0
                            jr      z,.NotBreakDebug
                            cp      $40
                            jr      z,.NotBreakDebug
                            cp      $80
                            jr      z,.NotBreakDebug
.NotBreakDebug:                            
                            ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK
                            or      d; | LAYER2_SHADOW_SCREEN_MASK
                            ld 		bc, IO_LAYER2_PORT
                            out 	(c),a
                            ret
;  "asm_l2_bank_select a = sepecific bank number to select, dsets varL2_BANK_SELECTED"		
asm_l2_bank_n_select:       ld		(varL2_BANK_SELECTED),a
                            cp		0
                            jr 		nz,.nottopbank
.topbank:                   ld		a,LAYER2_SHIFTED_SCREEN_TOP
                            jr		asm_l2_bank_select
.nottopbank:                cp		1
                            jr 		nz,.notmiddlebank
.middlebank:                ld		a,LAYER2_SHIFTED_SCREEN_MIDDLE
                            jr		asm_l2_bank_select
.notmiddlebank:             ld		a,LAYER2_SHIFTED_SCREEN_BOTTOM ; default to bottom
                            jr		asm_l2_bank_select
		; Note no ret as its handled by above routines

asm_l2_reselect_saved_bank: ld      a,(varL2_SAVED_SELECT)  ; recover selected option
                            ld 		bc, IO_LAYER2_PORT
                            out 	(c),a
                            ld      a,(varL2_SAVED_OFFSET)
                            out 	(c),a
                            ret
                            

asm_l2_bank_0_macro:        MACRO
                            ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_TOP
                            ld      (varL2_SAVED_SELECT),a  ; save selected option
                            ld 		bc, IO_LAYER2_PORT
                            out 	(c),a
                            ld      a,%00010000             ; write bit 4 set so we can force a bank offset of 0 from top bank
                            ld      (varL2_SAVED_OFFSET),a
                            out 	(c),a
                            ZeroA						; set a to 0
                            ld		(varL2_BANK_SELECTED),a	; save selected bank number 0
                            ENDM

asm_l2_bank_1_macro:        MACRO
                            ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_MIDDLE
                            ld      (varL2_SAVED_SELECT),a  ; save selected option
                            ld 		bc, IO_LAYER2_PORT
                            out 	(c),a
                            ld      a,%00010000             ; write bit 4 set so we can force a bank offset of 0 from middle bank
                            ld      (varL2_SAVED_OFFSET),a
                            out 	(c),a
                            ld      a,1						; set a to 0
                            ld		(varL2_BANK_SELECTED),a	; save selected bank number 0
                            ENDM
                            
asm_l2_bank_2_macro:        MACRO
                            ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_BOTTOM
                            ld      (varL2_SAVED_SELECT),a  ; save selected option
                            ld 		bc, IO_LAYER2_PORT
                            out 	(c),a
                            ld      a,%00010000             ; write bit 4 set so we can force a bank offset of 0 from bottom bank
                            ld      (varL2_SAVED_OFFSET),a
                            out 	(c),a
                            ld      a,2						; set a to 0
                            ld		(varL2_BANK_SELECTED),a	; save selected bank number 0
                            ENDM

asm_l2_bank_3_macro:        MACRO
                            ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_BOTTOM
                            ld      (varL2_SAVED_SELECT),a  ; save selected option
                            ld 		bc, IO_LAYER2_PORT
                            out 	(c),a
                            ld      a,%00010001             ; write bit 4 set so we can force a bank offset of 1 from bottom bank
                            ld      (varL2_SAVED_OFFSET),a
                            out 	(c),a
                            ld      a,3						; set a to 0
                            ld		(varL2_BANK_SELECTED),a	; save selected bank number 0
                            ENDM

asm_l2_bank_4_macro:        MACRO
                            ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_BOTTOM
                            ld 		bc, IO_LAYER2_PORT
                            ld      (varL2_SAVED_SELECT),a  ; save selected option
                            out 	(c),a
                            ld      a,%00010010             ; write bit 4 set so we can force a bank offset of 2 from bottom bank
                            ld      (varL2_SAVED_OFFSET),a
                            out 	(c),a
                            ld      a,4						; set a to 0
                            ld		(varL2_BANK_SELECTED),a	; save selected bank number 0
                            ENDM

; "asm_l2_row_bank_select"
; "A (unsinged) = y row of pixel line from top, sets the bank to top middle or bottom and adjusts a reg to row memory address"  
; "Could optimise by holding the previous bank but given its only an out statement it may not save T states at all"
; "destroys BC call de is safe a = adjusted poke pixel row"
asm_l2_row_bank_select:     JumpIfAGTENusng 128, .BottomBank
                            JumpIfAGTENusng 64, .MiddleBank
                            ex      af,af'
                            JumpIfMemZero varL2_BANK_SELECTED, .NoTopChange
                            asm_l2_bank_0_macro
.NoTopChange:               ex      af,af'
                            ret
.MiddleBank:                ex      af,af'
                            JumpIfMemEqNusng varL2_BANK_SELECTED, 1, .NoMiddleChange
                            asm_l2_bank_1_macro
.NoMiddleChange:            ex      af,af'
                            sub     64
                            ret
.BottomBank:                ex      af,af'
                            JumpIfMemEqNusng varL2_BANK_SELECTED, 2, .NoBottomChange
                            asm_l2_bank_2_macro
.NoBottomChange:            ex      af,af'                            
                            sub     128
                            ret


; "asm_l2_320_row_bank_select"
; HL (unsinged) = x column of pixel line from left, uses this to define bank
; 0-  63                    Bank 1
; 64- 127                   Bank 2
; 128 - 191                 Bank 3
; 192 - 255                 Bank 4
; 256 - 321                 Bank 5
; outputs h with the correct column number adjusted for bank selection
asm_l2_320_col_bank_select: ld      a,h
                            and     a
                            jp      nz,.Bank5                       ; if high bit is set must be bank 5
                            ld      a,l
                            and     %11000000                       ; if upper 2 bits are set then must be bank 4
                            jp      z,.NotBank4
                            cp      %11000000
                            jp      z,.Bank4
.NotBank4:                  ld      a,l                             ; try again with original number
                            test    %10000000                       ; if 128 or greater then must be bank 3
                            jp      nz,.Bank3
                            test    %01000000                       ; if 64 to 127 then bank 2
                            jp      nz,.Bank2
.Bank1:                     asm_l2_bank_0_macro
                            ld      h,l
                            ret
.Bank2:                     asm_l2_bank_1_macro
                            ClearCarryFlag
                            ld      a,l
                            and     %10111111                       ; fast subtract 64, just clear bit
                            ld      h,a             
                            ret             
.Bank3:                     asm_l2_bank_2_macro             
                            ClearCarryFlag              
                            ld      a,l             
                            and     %01111111                       ; fast subtract 128, just clear bit
                            ld      h,a             
                            ret             
.Bank4:                     asm_l2_bank_3_macro             
                            ClearCarryFlag              
                            ld      a,l             
                            and     %00111111                       ; fast subtract 192, just clear bit
                            ld      h,a             
                            ret             
.Bank5:                     asm_l2_bank_4_macro             
                            ld      h,l                             ; fast subtract 256, just clear bit
                            ret

; takes current bank saved in varL2_BANK_SELECTED, increments it cycling around and selects
; returns h with 0 for adjusted column number
; note this is for a temp bank switch e.g. printing a character so does not load the varL2 values
asm_l2_320_next_bank:       ld      a,(varL2_BANK_SELECTED)
                            inc     a
                            cp      5
                            jp      nz,.bankSelected
.cycleToZero:               ZeroA
                            ld      h,a
.bankSelected:              ld      (varL2_BANK_SELECTED),a         ; mark new bank
                            and     a
                            jp      z,asm_l2_320_col_bank_select.Bank1
.testBank2:                 dec     a
                            jp      z,asm_l2_320_col_bank_select.Bank2
.testBank3:                 dec     a
                            jp      z,asm_l2_320_col_bank_select.Bank3
.testBank4:                 dec     a
                            jp      z,asm_l2_320_col_bank_select.Bank4
.testBank5:                 jp      asm_l2_320_col_bank_select.Bank5

; takes current bank saved in varL2_BANK_SELECTED, increments it cycling around and selects
; note this is for a temp bank switch e.g. printing a character so does not load the varL2 values
asm_l2_320_next_bank_noSv:  ld      a,(varL2_BANK_SELECTED)
                            inc     a
                            cp      5
                            jp      nz,.bankSelected
.cycleToZero:               ZeroA
.bankSelected:              and     a
                            jp      z,.Bank1
.testBank2:                 dec     a
                            jp      z,.Bank2
.testBank3:                 dec     a
                            jp      z,.Bank3
.testBank4:                 dec     a
                            jp      z,.Bank4
.testBank5:                 dec     a
.Bank5:                     ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_BOTTOM
                            ld 		bc, IO_LAYER2_PORT
                            out 	(c),a
                            ld      a,%00010010
                            out 	(c),a
                            ld      a,4						; set a to 0
                            ret
.Bank1:                     ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_TOP
                            ld 		bc, IO_LAYER2_PORT
                            out 	(c),a
                            ld      a,%00010000
                            out 	(c),a
                            ret
.Bank2:                     ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_MIDDLE
                            ld 		bc, IO_LAYER2_PORT
                            out 	(c),a
                            ld      a,%00010000
                            out 	(c),a
                            ret  
.Bank3:                     ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_BOTTOM
                            ld 		bc, IO_LAYER2_PORT
                            out 	(c),a
                            ld      a,%00010000
                            out 	(c),a            
                            ret             
.Bank4:                     ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_BOTTOM
                            ld 		bc, IO_LAYER2_PORT                       
                            out 	(c),a
                            ld      a,%00010001
                            out 	(c),a          
                            ret           




