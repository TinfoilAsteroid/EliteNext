

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
StockFood			DB  00,  0, 0,  19, -2,      6, $01, 00  ; 00
StockTextiles		DB	01,  0, 0,  20, -1,     10, $03, 00  ; 01
StockRadioactives	DB  02,  0, 0,  65, -3,      2, $07, 00  ; 02
StockSlaves			DB  03,  0, 0,  40, -5,    226, $1F, 00  ; 03
StockLiquorWines	DB  04,  0, 0,  83, -5,    251, $0F, 00  ; 04
StockLuxuries		DB  05,  0, 0, 196,  8,     54, $03, 00  ; 05
StockNarcotics		DB  06,  0, 0, 235, 29,      8, $78, 00  ; 06
StockComputers		DB  07,  0, 0, 154, 14,     56, $03, 00  ; 07
StockMachinery		DB  08,  0, 0, 117,  6,     40, $07, 00  ; 08
StockAlloys			DB  09,  0, 0,  78,  1,     17, $1F, 00  ; 09
StockFirearms   	DB  10,  0, 0, 124, 13,     29, $07, 00  ; 10
StockFurs       	DB  11,  0, 0, 176, -9,    220, $3F, 00  ; 11
StockMinerals   	DB  12,  0, 0,  32, -1,     53, $03, 00  ; 12
StockGold       	DB  13,  0, 0,  97, -1,     66, $07, 01  ; 13
StockPlatinum   	DB  14,  0, 0, 171, -2,     55, $1F, 01  ; 14
StockGemStones 		DB  15,  0, 0,  45, -1,    250, $0F, 02  ; 15
StockAlienItems		DB  16,  0, 0,  53, 15,    192, $07, 00  ; 16
StockRowWidth       EQU StockTextiles - StockFood
StockNameOffset     EQU 0
StockQtyOffset      EQU 1
StockPriceOffset    EQU 2
StockUoMOffset      EQU 7

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


FoodIndex               EQU 01
TextilesIndex           EQU 02
RadioactivesIndex       EQU 03
SlavesIndex             EQU 04
LiquorWinesIndex        EQU 05
LuxuriesIndex           EQU 06
NarcoticsIndex          EQU 07
ComputersIndex          EQU 08
MachineryIndex          EQU 09
AlloysIndex             EQU 10
FirearmsIndex           EQU 11
FursIndex               EQU 12
MineralsIndex           EQU 13
GoldIndex               EQU 14
PlatinumIndex           EQU 15
GemStonesIndex          EQU 16
AlienItemsIndex		    equ 17
StockListLen		    equ	18

StockItemTable		    DW 	StockFood           ;01
                        DW  StockTextiles       ;02
                        DW  StockRadioactives   ;03
                        DW 	StockSlaves         ;04
                        DW  StockLiquorWines    ;05
                        DW  StockLuxuries       ;06
                        DW 	StockNarcotics      ;07
                        DW  StockComputers      ;08
                        DW  StockMachinery      ;09
                        DW	StockAlloys         ;10
                        DW  StockFirearms       ;11
                        DW  StockFurs           ;12
                        DW  StockMinerals       ;13
                        DW  StockGold           ;14
                        DW  StockPlatinum       ;15
                        DW  StockGemStones      ;16
                        DW  StockAlienItems     ;17
;----------------------------------------------------------------------------------------------------------------------------------
; "DispHL, writes HL to DE address"
Stock_DispHLtoDE:       ld	bc,-10000
                        call	Stock_Num1
                        ld	bc,-1000
                        call	Stock_Num1
                        ld	bc,-100
                        call	Stock_Num1
                        ld	c,-10
                        call	Stock_Num1
                        ld	c,-1
Stock_Num1:	            ld	a,'0'-1
.Num2:	                inc	a
                        add	hl,bc
                        jr	c,.Num2
                        sbc	hl,bc
                        ld	(de),a
                        inc	de
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; As per regular copy but does not write the 0x00 terminator as its expetect to go into a table
Stock_copy_str_hl_to_de:ld      a,(hl)
                        and     a                               ; check if a \0 if so then done
                        ret     z
                        ld      (de),a
                        inc     hl
                        inc     de
                        jp      Stock_copy_str_hl_to_de
;----------------------------------------------------------------------------------------------------------------------------------
Stock_DispQtyAtoDE:     cp	0
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
                        jr		Stock_Num1
.NotHundredsZero:       ld	c,-10
                        call	Stock_Num1
                        ld	c,-1
                        jr		Stock_Num1
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
Stock_DispPriceAtoDE:   ld h,0
                        ld l,a
                        ld	bc,-100
                        call	.NumLeadBlank1
                        ld	c,-10
                        call	Stock_Num1
                        ld		a,'.'					; we could assume preformat but
                        ld		(de),a					; we can optimse that later TODO
                        inc		de						; with just an inc De
                        ld	c,-1
                        jr		Stock_Num1
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
getStockItemNameIX:     ld		hl,WordPtrStock
                        ld		a,(ix+StockNameOffset)
                        call	getTableText
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
copyStockItemNameIXDE:  call    getStockItemNameIX
                        call    Stock_copy_str_hl_to_de
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
getStockUoMIX:          ld		hl,WordPtrUoMFull
                        ld		a,(ix+StockUoMOffset)
                        call	getTableText
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
copyStockStockUoMIXDE:  call    getStockUoMIX
                        call    Stock_copy_str_hl_to_de
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
getStockPriceIXtoDE:    ld		a,(ix+StockPriceOffset)
                        ;ld		de,txt_market_amount
                        call	Stock_DispPriceAtoDE
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
getStockQtyIX:          ld		a,(ix+StockQtyOffset)
                        ;ld		de,txt_market_quantity
                        call	Stock_DispQtyAtoDE
                        ret                
;----------------------------------------------------------------------------------------------------------------------------------
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
