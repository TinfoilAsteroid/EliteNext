
    MMUSelectLayer1
	call	l1_cls
	ld		a,7
	call	l1_attr_cls_to_a
    MMUSelectLayer2
	call    asm_l2_double_buffer_off    
	call	l2_cls	; Get some space
	MMUSelectSpriteBank
	call    sprite_cls_cursors
	
    