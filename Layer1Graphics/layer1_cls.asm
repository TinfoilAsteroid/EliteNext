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