  
  
;                       Can Buy
;                       computed row on screen considering what stock is visible
;                       Show
;                       Tech Level
;                       Price
;                       Name 
;                       TypeId


;char name[16];
;current_quantity;
;current_price;
;base_price;
;eco_adjust;
;base_quantity;
;mask;
;units;

;						nam	currr   CR  Ecadj  Qty  Msk  UoM
StockFood			DB  32,  0, 0,  19, -2,      6, $01, 48
StockTextiles		DB	33,  0, 0,  20, -1,     10, $03, 48
StockRadioactives	DB  34,  0, 0,  65, -3,      2, $07, 48
StockSlaves			DB  35,  0, 0,  40, -5,    226, $1F, 48
StockLiquorWines	DB  36,  0, 0,  83, -5,    251, $0F, 48
StockLuxuries		DB  37,  0, 0, 196,  8,     54, $03, 48
StockNarcotics		DB  38,  0, 0, 235, 29,      8, $78, 48
StockComputers		DB  25,  0, 0, 154, 14,     56, $03, 48
StockMachinery		DB  39,  0, 0, 117,  6,     40, $07, 48
StockAlloys			DB  40,  0, 0,  78,  1,     17, $1F, 48
StockFirearms   	DB  41,  0, 0, 124, 13,     29, $07, 48
StockFurs       	DB  42,  0, 0, 176, -9,    220, $3F, 48
StockMinerals   	DB  43,  0, 0,  32, -1,     53, $03, 48
StockGold       	DB  44,  0, 0,  97, -1,     66, $07, 49
StockPlatinum   	DB  45,  0, 0, 171, -2,     55, $1F, 49
StockGemStones 		DB  46,  0, 0,  45, -1,    250, $0F, 50
StockAlienItems		DB  47,  0, 0,  53, 15,    192, $07, 48


;.QQ23	\Prxs -> &3DA6 \  Market prices info 
;\ base_price, gradient sign+5bits, base_quantity, mask, units 2bits 
;13 82 06 01			EQUD &01068213 \ Food
;14 81 0A 03 		EQUD &030A8114 \ Textiles
;41 83 02 07 		EQUD &07028341 \ Radioactives 
;28 85 E2 1F 		EQUD &1FE28528 \ Slaves
;53 85 FB 0F 		EQUD &0FFB8553 \ Liquor/Wines
;C4 08 36 03 		EQUD &033608C4 \ Luxuries
;EB 1D 08 78 		EQUD &78081DEB \ Narcotics
;9A 0E 38 03 		EQUD &03380E9A \ Computers
;75 06 28 07 		EQUD &07280675 \ Machinery
;4E 01 11 1F 		EQUD &1F11014E \ Alloys
;7C 0D 1D 07 		EQUD &071D0D7C \ Firearms
;B0 89 DC 3F 		EQUD &3FDC89B0 \ Furs
;20 81 35 03 		EQUD &03358120 \ Minerals
;61 A1 42 07 		EQUD &0742A161 \ Gold
;AB A2 37 1F 		EQUD &1F37A2AB \ Platinum
;2D C1 FA 0F 		EQUD &0FFAC12D \ Gem-Stones
;35 0F C0 07 		EQUD &07C00F35 \ Alien Items
	




AlienItemsIndex		    equ 16
StockListLen		    equ	17

StockItemTable		    DW 	StockFood,  StockTextiles,	   StockRadioactives	
                        DW 	StockSlaves, StockLiquorWines, StockLuxuries		
                        DW 	StockNarcotics, StockComputers, StockMachinery		
                        DW	StockAlloys, StockFirearms, StockFurs       	
                        DW  StockMinerals, StockGold, StockPlatinum
                        DW  StockGemStones, StockAlienItems	

generate_stock_market:  ld		b,$FF				; so the first iteration puts it at 0
                        call	copy_galaxy_to_system
                        ld		ix,StockFood-8		; start 8 bytes before index as first add will shift
.generate_stock_loop:   ld		de,8
                        add		ix,de				; Move down a row
                        inc		b
.CalcPrice:	            ld		c,(ix+3);			; c = base price
                        ld		a,(RandomMarketSeed)
                        and		(ix+6)				; and with market mask
                        add		a,c
                        ld		c,a					; c = base + rand & market mask
                        ld		a,(DisplayEcononmy)	; d= economy
                        ld		d,a
                        ld		a,(ix+4)			
                        ld		e,a					; e  = economy adjust
                        bit		7,e
                        jr		nz,.PosMul			; it could be negative and we onnly want
;.NegMul:						; e reg from mulitply not a 2'c 16 bit word
                        ld		a,e
                        neg
                        ld		e,a
.PosMul:
                        ld		a,e
                        neg
                        ld		e,a
                        mul
                        ld		a,c
                        add		a,e
                        sla		a
                        sla		a					; Multply price by 4
                        ld		(ix+2),a			; Now have set price
.CalcQty:	            ld		c,(ix+5);			; c = base price
                        ld		a,(RandomMarketSeed)
                        and		(ix+6)				; and with market mask
                        add		a,c
                        ld		c,a					; c = base + rand & market mask
                        ld		a,(DisplayEcononmy)	; d= economy
                        ld		d,a
                        ld		a,(ix+4)			
                        ld		e,a					; e  = economy adjust
                        bit		7,e
                        jr		nz,.PosQtyMul			; it could be negative and we onnly want
.NegQtyMul:				ld		a,e		; e reg from mulitply not a 2'c 16 bit word
                        neg
                        ld		e,a
.PosQtyMul:             ld		a,e
                        neg
                        ld		e,a
                        mul
                        ld		a,c
                        sub		e
                        ld		(ix+1),a			; Now have set quanity
                        ld		a,b
                        cp		AlienItemsIndex
                        jr		nz,.generate_stock_loop
                        xor		a
                        ld		(ix+1),a			; Now have set quanity of alient items to always 0 in stock
                        ret
