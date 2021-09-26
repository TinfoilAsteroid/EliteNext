; Use bank 0 as source and bank 7 as write target
ResetUniv:
    MODULE ResetUniv
; Move bank 70 into page 0
    MMUSelectCpySrcN BankUNIVDATA0	         ; master universe def in bank 0
	ld		a,BankUNIVDATA1 				 ; we can read bank 0 as if it was rom
	ld		b,12
ResetCopyLoop:
	push	bc
	MMUSelectUniverseA			             ; copy from bank 0 to 71 to 12
	push	af
	ld		hl,UniverseBankAddr
	ld		de,dmaCopySrcAddr
	ld		bc,UnivBankSize
	call	memcopy_dma
	pop		af
	pop		bc
	inc		a
	djnz	ResetCopyLoop
	ret
    ENDMODULE

; Use bank 0 as source and bank 7 as write target
ResetGalaxy:
    MODULE ResetGalaxy
; Move bank 70 into page 0
    MMUSelectCpySrcN BankGalaxyData0	     ; master universe def in bank 0
	ld		a,BankGalaxyData1 			   	 ; we can read bank 0 as if it was rom
	ld		b,8
    ld      c,1
ResetCopyLoop:
	push	af
	push	bc
	MMUSelectGalaxyA    	             ; copy from bank 0 to 71 to 12
	ld		hl,GalaxyDataAddr
	ld		de,dmaCopySrcAddr
	ld		bc,GalaxyBankSize
	call	memcopy_dma   
	pop		bc
    ld      hl, galaxy_pg_cnt
    ld      a,c
    add     a, $30
    ld      (hl),a
    inc     c
    pop     af
	inc		a
	djnz	ResetCopyLoop
	ret
    ENDMODULE