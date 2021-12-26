l1_cls_top:             xor     a
                        ld      hl, $4000
                        ld      de, $0800
                        call    memfill_dma
                        ret

l1_cls_mid:             xor     a
                        ld      hl, $4800
                        ld      de, $0800
                        call    memfill_dma
                        ret
                        
l1_cls_bottom:          xor     a
                        ld      hl, $5000
                        ld      de, $0800
                        call    memfill_dma
                        ret
                        
; Designed specifically to clear a whole character aligned line
l1_cls_line_d:          ld      e,0
                        pixelad
                        ld      de,32 * 8
                        call    memfill_dma

; Designed specifically to clear a whole character aligned 2 lines line, used for say clearing hyperspace message
l1_cls_2_lines_d:       ld      e,0
                        pixelad
                        ld      de,32 * 16
                        call    memfill_dma
                        
l1_cls:                 xor		a
l1_cls_to_a:            ld		hl,	$4000
                        ld		de, $1800
                        call	memfill_dma
                        ret
	
l1_attr_cls:            xor		a
l1_attr_cls_to_a:       ld		hl,	$5800
                        ld		de, $0300
                        call	memfill_dma
                        ret	
	
l1_set_border:          ld	    bc, 0xFEFE
                        out		(c),a
                        ret