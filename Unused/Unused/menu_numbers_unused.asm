; Menu number routines nothing called (2026-11-20, the Menus TODOs "Optimise ... DispPriceAtoDE"): kept for reference.

; ---- from Menus/equip_ship_menu.asm
;----------------------------------------------------------------------------------------------------------------------------------
EQSHP_DispAtoDE:          ld h,0
                        ld l,a
                        jp EQSHP_DispHLtoDE
;----------------------------------------------------------------------------------------------------------------------------------
EQSHP_DispPriceAtoDE:     ld h,0
                        ld l,a
                        ld	bc,-100
                        call	.NumLeadBlank1
                        ld	c,-10
                        call	EQSHP_Num1
                        ld		a,'.'					; we could assume preformat but
                        ld		(de),a					; we can optimse that later TODO
                        inc		de						; with just an inc De
                        ld	c,-1
                        jr		EQSHP_Num1
.NumLeadBlank1:	        ld	a,'0'-1
.NumLeadBlank2:	        inc	a
                        add	hl,bc
                        jr	c,.NumLeadBlank2
                        cp	'0'
                        jr	nz,.DontBlank
.Blank:                 ld	a,' '
.DontBlank:	            sbc	hl,bc
                        ld	(de),a
                        inc	de
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
EQSHP_DispQtyAtoDE:      cp	0
                        jr	z,.NoStock
                        ld h,0
                        ld l,a
                        ld	bc,-100
                        call	.NumLeadBlank1
.WasLead0:              cp      ' '
                        jr      nz,.NotHundredsZero
                        ld	c,-10
                        call	.NumLeadBlank1
                        ld	c,-1
                        jr		EQSHP_Num1
.NotHundredsZero:       ld	c,-10
                        call	EQSHP_Num1
                        ld	c,-1
                        jr		EQSHP_Num1
.NumLeadBlank1:	        ld	a,'0'-1
.NumLeadBlank2:	        inc	a
                        add	hl,bc
                        jr	c,.NumLeadBlank2
                        cp	'0'
                        jr	nz,.DontBlank
.Blank:                 ld	a,' '
.DontBlank:	            sbc	hl,bc
                        ld	(de),a
                        inc	de
                        ret
.NoStock:               ld	a,' '
                        ld	(de),a
                        inc	de
                        ld	(de),a
                        inc	de
                        ld	a,'-'
                        ld	(de),a
                        inc de
                        ret
;----------------------------------------------------------------------------------------------------------------------------------

; ---- from Menus/market_prices_menu.asm
;----------------------------------------------------------------------------------------------------------------------------------
MPM_DispAtoDE:          ld h,0
                        ld l,a
                        jp MPM_DispHLtoDE
;----------------------------------------------------------------------------------------------------------------------------------
MPM_DispPriceAtoDE:     ld h,0
                        ld l,a
                        ld	bc,-100
                        call	.NumLeadBlank1
                        ld	c,-10
                        call	MPM_Num1
                        ld		a,'.'					; we could assume preformat but
                        ld		(de),a					; we can optimse that later TODO
                        inc		de						; with just an inc De
                        ld	c,-1
                        jr		MPM_Num1
.NumLeadBlank1:	        ld	a,'0'-1
.NumLeadBlank2:	        inc	a
                        add	hl,bc
                        jr	c,.NumLeadBlank2
                        cp	'0'
                        jr	nz,.DontBlank
.Blank:                 ld	a,' '
.DontBlank:	            sbc	hl,bc
                        ld	(de),a
                        inc	de
                        ret
