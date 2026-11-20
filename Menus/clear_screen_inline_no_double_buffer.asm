InitNoDoubleBuffer:         MACRO
                            MMUSelectLayer1
                            call	l1_cls
                            ld		a,7
                            call	l1_attr_cls_to_a
                            MMUSelectLayer2
                            call    asm_l2_double_buffer_off    
                            call    l2_initialise   ; 256 x 192: this screen (equip ship) draws in 256 mode, but the menus it is
                                                    ; reached from (charts, status, market) leave Layer 2 in 320 x 256, where the
                                                    ; 256 mode clear and box blanked the left 192 columns
                            call	l2_cls	; Get some space
                            MMUSelectSpriteBank
                            call    sprite_cls_all;sprite_cls_cursors
                            ENDM
	
    