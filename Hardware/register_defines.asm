; Peripheral 2
ENABLE_CPU_SPEED_MODE                   EQU %10000000
DIVERT_BEEP_ONLY                        EQU %01000000
ENABLE_50_60_SWITCH                     EQU %00100000
ENABLE_MMCAUTO_SWITCH                   EQU %00010000
ENABLE_MULTIFACE_M1                     EQU %00001000
PS2MODE_KEYBOARD                        EQU %00000000
PS2MODE_MOUSE                           EQU %00000100
AUDIO_CHIPMODE_YM                       EQU %00000000
AUDIO_CHIPMODE_AY                       EQU %00000001
AUDIO_CHIPMODE_DISABLED                 EQU %00000010
INTERNAL_SPEAKER_ENABLE                 EQU %00010000
; Peripheral 3
UNLOCK_PORT_7FFD_PAGING                 EQU %10000000
DISABLE_RAM_IO_CONTENTION               EQU %01000000
AY_STEREO_MODE_ACB                      EQU %00100000
INTERNAL_SPEAKER                        EQU %00010000
ENABLE_DACS                             EQU %00001000
ENABLE_TIMEX_VIDEO_MODE                 EQU %00000100
ENABLE_TURBO_SOUND                      EQU %00000010
ENABLE_ISSUE2_KEYBOARD                  EQU %00000001
; Peripheral 4
ENABLE_AY2_MONO                         EQU %10000000
ENABLE_AY1_MONO                         EQU %01000000
ENABLE_AY0_MONO                         EQU %00100000
SPRITE_ID_LOCKSTEP                      EQU %00010000
RESET_DIVMMC_MAPRAM                     EQU %00001000
SILENCE_HDMI_AUDIO                      EQU %00000100
SCALLINES_50PCT                         EQU %00000001
SCANLINES_25PCT                         EQU %00000010
SCANLINES_125PCT                        EQU %00000011
; Audio Registers
CHANNEL_A_FINE                          EQU 0
CHANNEL_A_COARSE                        EQU 1
CHANNEL_B_FINE                          EQU 2
CHANNEL_B_COARSE                        EQU 3
CHANNEL_C_FINE                          EQU 4
CHANNEL_C_COARSE                        EQU 5
NOISE_PERIOD                            EQU 6
TONE_ENABLE                             EQU 7
CHANNEL_A_AMPLITUDE                     EQU 8
CHANNEL_B_AMPLITUDE                     EQU 9
CHANNEL_C_AMPLITUDE                     EQU 10
ENVELOPE_PERIOD_FINE                    EQU 11
ENVELOPE_PERIOD_COARSE                  EQU 12
ENVELOPE_SHAPE                          EQU 13

ENVELOPE_HOLD_ON                        EQU 1
ENVELOPE_ALTERNATE_ON                   EQU 2
ENVELOPE_ATTACK_ON                      EQU 4
ENVELOPE_CONTINUE_ON                    EQU 8

ENVELOPE_SHAPE_SINGLE_DECAY             EQU 0                                                                                    ; \____________
ENVELOPE_SHAPE_SINGLE_ATTACK            EQU                        ENVELOPE_ATTACK_ON                                            ; /|___________
ENVELOPE_SHAPE_REPEAT_DECAY             EQU ENVELOPE_CONTINUE_ON                                                                 ; \|\|\|\|\|\|\
ENVELOPE_SHAPE_REPEAT_DECAY_ATTACK      EQU ENVELOPE_CONTINUE_ON |                      ENVELOPE_ALTERNATE_ON                    ; \/\/\/\/\/\/\
ENVELOPE_SHAPE_SINGLE_DECAY_HOLD        EQU ENVELOPE_CONTINUE_ON |                      ENVELOPE_ALTERNATE_ON | ENVELOPE_HOLD_ON ; \|-----------
ENVELOPE_SHAPE_REPEAT_ATTACK            EQU ENVELOPE_CONTINUE_ON | ENVELOPE_ATTACK_ON                                            ; /|/|/|/|/|/|/|
ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD       EQU ENVELOPE_CONTINUE_ON | ENVELOPE_ATTACK_ON |                         ENVELOPE_HOLD_ON ; /------------
ENVELOPE_SHAPE_REPEAT_ATTACK_DECAY      EQU ENVELOPE_CONTINUE_ON | ENVELOPE_ATTACK_ON | ENVELOPE_ALTERNATE_ON                    ; /\/\/\/\/\/\/

ENVELOPE_HOLD                           EQU %00000001
ENVELOPE_ALTERNATE                      EQU %00000010
ENVELOPE_ATTACK                         EQU %00000010
ENVELOPE_CONTINUE                       EQU %00000010
; Sound Control
TONE_CHANNEL_A                          EQU %00000001
TONE_CHANNEL_B                          EQU %00000010
TONE_CHANNEL_C                          EQU %00000100
NOISE_CHANNEL_A                         EQU %00001000
NOISE_CHANNEL_B                         EQU %00010000
NOISE_CHANNEL_C                         EQU %00100000
; Version for AND to enabled (its inverted)
TONE_CHANNEL_A_ON                       EQU %11111110
TONE_CHANNEL_B_ON                       EQU %11111101
TONE_CHANNEL_C_ON                       EQU %11111011
NOISE_CHANNEL_A_ON                      EQU %11110111
NOISE_CHANNEL_B_ON                      EQU %11101111
NOISE_CHANNEL_C_ON                      EQU %11011111

; Turbo Sound Control
TURBO_MANDATORY                         EQU %10011100
TURBO_LEFT                              EQU %01000000
TURBO_RIGHT                             EQU %00100000
TURBO_CHIP_AY3                          EQU %00000011
TURBO_CHIP_AY2                          EQU %00000010
TURBO_CHIP_AY1                          EQU %00000001

IO_LAYER2_PORT                          EQU $123B
IO_EXT_BANK_PORT 			            EQU $DFFD ; 57341
IO_BANK_PORT                            EQU $7FFD ; 32765
REGISTER_NUMBER_PORT					EQU $243B
REGISTER_VALUE_PORT						EQU $253B
SPRITE_SLOT_PORT						EQU $303B ; port for sprite and pattern index 
SPRITE_INFO_PORT                        EQU $0057
SPRITE_PATTERN_UPLOAD_PORT				EQU $005B
TURBO_SOUND_NEXT_CONTROL                EQU $FFFD
SOUND_CHIP_REGISTER_WRITE               EQU $BFFD
IO_KEYBOARD_PORT                        EQU $FE
IO_DATAGEAR_DMA_PORT 		            EQU $6B
UART_TX_PORT_PORT                       EQU $133B
UART_RX_PORT_PORT                       EQU $143B
UART_CONTROL_PORT                       EQU $153B
UART_FRAME_PORT                         EQU $163B
CTC_CHANNEL1_PORT                       EQU $183B
CTC_CHANNEL2_PORT                       EQU $193B
CTC_CHANNEL3_PORT                       EQU $1A3B
CTC_CHANNEL4_PORT                       EQU $1B3B
PLUS_3_MEMORY_PAGING_CONTROL_PORT       EQU $1FFD
MB02_DMA_PORT                           EQU $0B
SPECDRUM_DAC_OUTPUT                     EQU $DF

Speed_3_5MHZ                            EQU 0
Speed_7MHZ                              EQU 1
Speed_14MHZ                             EQU 2
Speed_28MHZ                             EQU 3


MACHINE_ID_REGISTER						EQU $00
VERSION_REGISTER						EQU $01
RESET_REGISTER		    				EQU $02
MACHINE_TYPE_REGISTER					EQU $03
PAGE_RAM_REGISTER						EQU $04
PERIPHERAL_1_REGISTER					EQU $05   ; Sets joystick mode, video frequency and Scandoubler
PERIPHERAL_2_REGISTER					EQU $06   ; Enables CPU Speed key, DivMMC, Multiface, Mouse and AY audio.
TURBO_MODE_REGISTER						EQU $07
PERIPHERAL_3_REGISTER					EQU $08   ; ABC/ACB Stereo, Internal Speaker, SpecDrum, Timex Video Modes, Turbo Sound Next, RAM contention and [un]lock 128k paging
PERIPHERAL_4_REGISTER                   EQU $09   ; Sets scanlines, AY mono output, Sprite-id lockstep, reset DivMMC mapram and disable HDMI audio 
PERIPHERAL_5_REGISTER                   EQU $0A  ; Mouse
CORE_VERSION_REGISTER                   EQU $0E
ANTI_BRICK_SYSTEM_REGISTER				EQU $10
VIDEO_TIMING_REGISTER                   EQU $11
LAYER2_RAM_PAGE_REGISTER				EQU $12
LAYER2_RAM_SHADOW_REGISTER      		EQU $13
TRANSPARENCY_COLOUR_REGISTER			EQU $14
SPRITE_LAYERS_SYSTEM_REGISTER			EQU $15
LAYER2_OFFSET_X_REGISTER				EQU $16
LAYER2_OFFSET_Y_REGISTER				EQU $17
CLIP_WINDOW_LAYER2_REGISTER				EQU $18
CLIP_WINDOW_SPRITES_REGISTER			EQU $19
CLIP_WINDOW_ULA_REGISTER				EQU $1A
CLIP_WINDOW_TILEMAP_REGISTER            EQU $1B
CLIP_WINDOW_CONTROL_REGISTER			EQU $1C
;29 not used
ACTIVE_VIDEO_LINE_MSB_REGISTER			EQU $1E
ACTIVE_VIDEO_LINE_LSB_REGISTER			EQU $1F
; 32 to 34 not used
LINE_INTERRUPT_CONTROL_REGISTER			EQU $22
LINE_INTERRUPT_VALUE_LSB_REGISTER		EQU $23
ULA_X_OFFSET_REGISTER                   EQU $26
ULA_Y_OFFSET_REGSITER                   EQU $27
KEYMAP_HIGH_ADDRESS_REGISTER			EQU $28
KEYMAP_LOW_ADDRESS_REGISTER				EQU $29
KEYMAP_HIGH_DATA_REGISTER				EQU $2A
KEYMAP_LOW_DATA_REGISTER				EQU $2B
DAC_B_MIRROR_REGISTER                   EQU $2C
DAC_AB_MIRROR_REGISTER                  EQU $2D
DAC_C_MORROR_REGISTER                   EQU $2E
TILEMAP_OFFSET_XMSB_REGISTER            EQU $2F
TILEMAP_OFFSET_XLSB_REGISTER            EQU $30
TILEMAP_OFFSET_YMSB_REGISTER            EQU $31
LORES_OFFSET_X_REGISTER					EQU $32
LORES_OFFSET_Y_REGISTER					EQU $33
SPRITE_PORT_INDEX_REGISTER              EQU $34
SPRITE_PORT_ATTR0_REGISTER              EQU $35
SPRITE_PORT_ATTR1_REGISTER              EQU $36
SPRITE_PORT_ATTR2_REGISTER              EQU $37
SPRITE_PORT_ATTR3_REGISTER              EQU $38
SPRITE_PORT_ATTR4_REGISTER              EQU $39
PALETTE_INDEX_REGISTER					EQU $40
PALETTE_VALUE_8BIT_REGISTER				EQU $41
PALETTE_FORMAT_REGISTER					EQU $42
PALETTE_CONTROL_REGISTER				EQU $43
PALETTE_VALUE_9BIT_REGISTER				EQU $44
TRANSPARENCY_COLOUR_FALLBACK_REGISTER   EQU $4A
SPRITES_TRANSPARENCY_INDEX_REGISTER     EQU $4B
TILEMAP_TRANSPARENCY_INDEX_REGISTER     EQU $4C
; 72 to 79 unused
MMU_SLOT_0_REGISTER						EQU $50
MMU_SLOT_1_REGISTER						EQU $51
MMU_SLOT_2_REGISTER						EQU $52
MMU_SLOT_3_REGISTER						EQU $53
MMU_SLOT_4_REGISTER						EQU $54
MMU_SLOT_5_REGISTER						EQU $55
MMU_SLOT_6_REGISTER						EQU $56
MMU_SLOT_7_REGISTER						EQU $57
; 88 to 95 unused
COPPER_DATA_REGISTER					EQU $60
COPPER_CONTROL_LOW_REGISTER				EQU $61
COPPER_CONTROL_HIGH_REGISTER			EQU $62
COPPER_DATA_16BIT_WRITE_REGISTER        EQU $63
VERTICAL_VIDEO_LINE_OFFSET_REGISTER     EQU $64
ULA_CONTROL_REGISTER                    EQU $68
DISPLAY_CONTROL_1_REGISTER              EQU $69
LORES_CONTROL_REGISTER                  EQU $6A
TILEMAP_CONTROL_REGISTER                EQU $6B
DEFAULT_TILEMAP_ATTRIBUTE_REGISTER      EQU $6C
; 109 unused
TILEMAP_BASE_ADDRESS_REGISTER           EQU $6E
TILE_DEFINITIONS_BASE_ADDRESS_REGISTER  EQU $6F
LAYER_2_CONTROL_REGISTER                EQU $70
LAYER_2_X_OFFSET_MSB_REGISTER           EQU $71
SPRITE_PORT_MIRROR_ATTRIBUTE_0_WITH_INC EQU $75
SPRITE_PORT_MIRROR_ATTRIBUTE_1_WITH_INC EQU $76
SPRITE_PORT_MIRROR_ATTRIBUTE_2_WITH_INC EQU $77
SPRITE_PORT_MIRROR_ATTRIBUTE_3_WITH_INC EQU $78
SPRITE_PORT_MIRROR_ATTRIBUTE_4_WITH_INC EQU $79
USER_STORAGE_0_REGISTER                 EQU $7F ; general purpose variable, e.g. for copper
EXPANSION_BUS_ENABLE_REGISTER           EQU $80
EXPANSION_BUS_CONTROL_REGISTER          EQU $81
INTERNAL_PORT_DECODING_B0_7_REGISTER    EQU $82
INTERNAL_PORT_DECODING_B8_15_REGISTER   EQU $83
INTERNAL_PORT_DECODING_B16_23_REGISTER  EQU $84
INTERNAL_PORT_DECODING_B24_31_REGISTER  EQU $85
EXPANSION_BUS_DECODING_B0_7_REGISTER    EQU $86
EXPANSION_BUS_DECODING_B8_15_REGISTER   EQU $87
EXPANSION_BUS_DECODING_B16_23_REGISTER  EQU $88
EXPANSION_BUS_DECODING_B24_31_REGISTER  EQU $89
EXPANSION_BUS_IO_PROPAGE_REGISTER       EQU $8A
ALTERNATE_ROM_REGISTER                  EQU $8C
MEMORY_MAPPING_REGISTER                 EQU $8E
PI_GPI_OUTPUT_ENABLE_0_REIGISTER        EQU $98
PI_GPI_OUTPUT_ENABLE_1_REIGISTER        EQU $99
PI_GPI_OUTPUT_ENABLE_2_REIGISTER        EQU $9A
PI_GPI_OUTPUT_ENABLE_3_REIGISTER        EQU $9B
PI_PERPIPHERAL_ENABLE_REGISTER          EQU $A0
PI_I2S_AUDIO_CONTROL_REGISTER           EQU $A2
PI_I2S_CLOCK_DIVIDE_REGISTER            EQU $A3
ESP_WIFI_GPIO_OUTPUT_REGISTER           EQU $A8
ESP_WIFI_GPIO_REGISTER                  EQU $A9
EXTENDED_KEYS_0_REGISTER                EQU $B0
EXTENDED_KEYS_1_REGISTER                EQU $B1
DIVMMC_TRAP_ENABLE_1                    EQU $B2
DIVMMC_TRAP_ENABLE_2                    EQU $B4
DEBUG_LED_CONTROL_REGISTER              EQU $FF

INTERUPT_CONTROL                        EQU $0C ; Interrupt control
NMI_RETURN_LSB				            EQU	$0C2	; NMI Return Address LSB
NMI_RETURN_MSB				            EQU	$0C3	; NMI Return Address MSB
INTERRUPT_EN0				            EQU	$0C4	; INT EN 0
INTERRUPT_EN1				            EQU	$0C5	; INT EN 1
INTERRUPT_EN2				            EQU	$0C6	; INT EN 2
INTERRUPT_ST0				            EQU	$0C8	; INT status 0
INTERRUPT_ST1				            EQU	$0C9	; INT status 1
INTERRUPT_ST2				            EQU	$0CA	; INT status 2
INTERRUPT_DM0				            EQU	$0CC	; INT DMA EN 0
INTERRUPT_DM1				            EQU	$0CD	; INT DMA EN 1
INTERRUPT_DM2				            EQU	$0CE	; INT DMA EN 2
CTC_CHANNEL_0				            EQU	$183B	; CTC channel 0 port
CTC_CHANNEL_1				            EQU	$193B	; CTC channel 1 port
CTC_CHANNEL_2				            EQU	$1A3B	; CTC channel 2 port
CTC_CHANNEL_3				            EQU	$1B3B	; CTC channel 3 port
CTC_CHANNEL_4				            EQU	$1C3B	; CTC channel 4 port
CTC_CHANNEL_5				            EQU	$1D3B	; CTC channel 5 port
CTC_CHANNEL_6				            EQU	$1E3B	; CTC channel 6 port
CTC_CHANNEL_7				            EQU	$1F3B	; CTC channel 7 port
CTCBASE                                 EQU $c0		; MSB Base address of buffer 
CTCSIZE                                 EQU $04 	; MSB buffer length 
CTCEND                                  EQU CTCBASE+(CTCSIZE*2)	


DEBUG_LEDS_REGISTER						EQU 255


GetNextRegSaveBC:	MACRO register
                    push bc
                    ld bc,$243B
                    ld a,register
                    out (c),a
                    inc b
                    in a,(c)
                    pop bc
                    ENDM

GetNextReg:	MACRO register
            ld bc,$243B
            ld a,register
            out (c),a
            inc b
            in a,(c)
            ENDM
