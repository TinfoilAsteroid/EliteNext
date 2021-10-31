

LAYER2_SHIFTED_SCREEN_TOP  	 equ 0
LAYER2_SHIFTED_SCREEN_MIDDLE equ $40
LAYER2_SHIFTED_SCREEN_BOTTOM equ $80

; note hi byte is not decoded on DMA port so can out OUTIR
IO_DATAGEAR_DMA_PORT 		 equ 107
IO_SPRITE_SLOT_PORT 		 equ 12347
IO_SPRITE_PATTERN_PORT       equ 91
IO_SPRITE_ATTRIBUTES_PORT    equ 87

LAYER2_VISIBLE_MASK 		equ $02
; DEBUG 0 for always write to primary 08 for double buffering
    IFDEF DOUBLEBUFFER
LAYER2_SHADOW_SCREEN_MASK 	equ $08
    ELSE
LAYER2_SHADOW_SCREEN_MASK 	equ $00
    ENDIF
LAYER2_WRITE_ENABLE_MASK 	equ $01
LAYER2_SCREEN_SECTION_MASK 	equ $03
LAYER2_SCREEN_SECTION_SHIFT equ 6

LAYER2_SCREEN_BANK1          equ 8
LAYER2_SCREEN_BANK2          equ 9
LAYER2_SCREEN_BANK3          equ 10
LAYER2_SHADOW_BANK1          equ 11
LAYER2_SHADOW_BANK2          equ 12
LAYER2_SHADOW_BANK3          equ 13

SCREEN_HEIGHT 				 equ 192
SCREEN_RAM_BASE				 equ $0000
SCREEN_HOZ_MIN_PIX		     equ 10

SPRITES_VISIBLE_MASK         equ $01
SPRITES_ON_BORDER_MASK       equ $02
LAYER_PRIORITIES_MASK        equ $07
LORES_MODE_MASK              equ $80
LAYER_PRIORITIES_SHIFT       equ 2

LAYER_PRIORITIES_S_L_U 		equ 0
LAYER_PRIORITIES_L_S_U 		equ 1
LAYER_PRIORITIES_S_U_L  	equ 2
LAYER_PRIORITIES_L_U_S 		equ 3
LAYER_PRIORITIES_U_S_L 		equ 4
LAYER_PRIORITIES_U_L_S 		equ 5

DMA_WRO_BLOCK_PORTA_A2B_XFR  equ $7D
DMA_WRO_BLOCK_PORTA_B2A_XFR  equ $79
DMA_WR1_P1FIXED_MEMORY       equ $24
DMA_WR1_P1DEC_MEMORY         equ $04
DMA_WR1_P1INC_MEMORY         equ $14
DMA_WR2_P2FIXED_MEMORY       equ $20
DMA_WR2_P2DEC_MEMORY         equ $00
DMA_WR2_P2INC_MEMORY         equ $10
DMA_WR4_CONT_MODE            equ $AD
DMA_RESET                    equ $c3
DMA_RESET_PORT_A_TIMING      equ $c7
DMA_RESET_PORT_B_TIMING      equ $cb
DMA_LOAD                     equ $cf
DMA_CONTINUE                 equ $d3
DMA_DISABLE_INTERUPTS        equ $af
DMA_ENABLE_INTERUPTS         equ $ab
DMA_RESET_DISABLE_INTERUPTS  equ $a3
DMA_ENABLE_AFTER_RETI        equ $b7
DMA_READ_STATUS_BYTE         equ $bf
DMA_REINIT_STATUS_BYTE       equ $8b
DMA_START_READ_SEQUENCE      equ $a7
DMA_FORCE_READY              equ $b3
DMA_STOP_AT_END			     equ $82
DMA_DISABLE                  equ $83  
DMA_ENABLE                   equ $87
DMA_WRITE_REGISTER_COMMAND   equ $bb
DMA_BURST                    equ $cd
DMA_CONTINUOUS               equ $ad
ZXN_DMA_PORT                 equ $6b


COLOUR_TRANSPARENT			 equ $E3




