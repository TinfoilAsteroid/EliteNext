
    MMUSelectLayer1
	call	l1_cls
	ld		a,7
	call	l1_attr_cls_to_a
    MMUSelectLayer2
	call	l2_cls	; Get some space
    IFDEF DOUBLEBUFFER    
        MMUSelectLayer2
        ld      a,(varL2_BUFFER_MODE)
        cp      0
        call    nz,l2_flip_buffers     
    ENDIF    
	call	l2_cls	; Get some space 
	MMUSelectSpriteBank
	call    sprite_cls_cursors
	
    
    