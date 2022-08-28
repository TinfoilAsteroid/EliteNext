
varL2_BANK_SELECTED			 DB	0
varL2_CURRENT_BANK           DB	0
varL2_BUFFER_MODE            DB 0
varL2_ACCESS_MODE            DB 0

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

asm_l2_bank_0_macro:        MACRO
                            ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_TOP
                            ld 		bc, IO_LAYER2_PORT
                            out 	(c),a
                            ZeroA						; set a to 0
                            ld		(varL2_BANK_SELECTED),a	; save selected bank number 0
                            ENDM

asm_l2_bank_1_macro:        MACRO
                            ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_MIDDLE
                            ld 		bc, IO_LAYER2_PORT
                            out 	(c),a
                            ld      a,1						; set a to 0
                            ld		(varL2_BANK_SELECTED),a	; save selected bank number 0
                            ENDM
                            
asm_l2_bank_2_macro:        MACRO
                            ld      a,(varL2_BUFFER_MODE)
                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_BOTTOM
                            ld 		bc, IO_LAYER2_PORT
                            out 	(c),a
                            ld      a,2						; set a to 0
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
                            
;;;                            
;;;                            
;;;                            cp 		64			; row < 64?
;;;                            jr 		nc, .l2rowGTE64
;;;.l2rowLT64:                 ex		af,af'
;;;                            ;ld		a, LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_TOP | LAYER2_SHADOW_SCREEN_MASK
;;;                            ld      a,(varL2_BUFFER_MODE)
;;;                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_TOP
;;;                            ld 		bc, IO_LAYER2_PORT
;;;                            out 	(c),a
;;;                            xor		a						; set a to 0
;;;                            ld		(varL2_BANK_SELECTED),a	; save selected bank number 0
;;;                            ex		af,af'					; return pixel poke unharmed
;;;                            ret
;;;.l2rowGTE64:                cp 		128
;;;                            jr 		nc, .l2rowGTE128
;;;.l2row64to127:              ex		af,af'
;;;                    ;		ld		a, LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_MIDDLE | LAYER2_SHADOW_SCREEN_MASK
;;;                            ld      a,(varL2_BUFFER_MODE)
;;;                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_MIDDLE
;;;                            ld 		bc, IO_LAYER2_PORT
;;;                            out 	(c),a
;;;                            ld		a,1						; set a to 1
;;;                            ld		(varL2_BANK_SELECTED),a	; save selected bank
;;;                            ex		af,af'
;;;                            sub		64		
;;;                            ret
;;;.l2rowGTE128:               ex		af,af'
;;;                    ;		ld		a, LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_BOTTOM | LAYER2_SHADOW_SCREEN_MASK
;;;                            ld      a,(varL2_BUFFER_MODE)
;;;                            or		LAYER2_VISIBLE_MASK  |  LAYER2_WRITE_ENABLE_MASK | LAYER2_SHIFTED_SCREEN_BOTTOM
;;;
;;;                            ld 		bc, IO_LAYER2_PORT
;;;                            out 	(c),a
;;;                            ld		a,1						; set a to 2
;;;                            ld		(varL2_BANK_SELECTED),a	; save selected bank
;;;                            ex		af,af'
;;;                            sub		128	
;;;                            ret
		
        