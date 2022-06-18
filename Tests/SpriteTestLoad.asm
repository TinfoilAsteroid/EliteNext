                        DEVICE ZXSPECTRUMNEXT
                        DEFINE  DOUBLEBUFFER 1
                        CSPECTMAP Sprites.map
                        OPT --zxnext=cspect --syntax=a --reversepop
IO_LAYER2_PORT                          EQU $123B
IO_EXT_BANK_PORT 			            EQU $DFFD ; 57341
IO_BANK_PORT                            EQU $7FFD ; 32765
REGISTER_NUMBER_PORT					EQU $243B
REGISTER_VALUE_PORT						EQU $253B
SPRITE_SLOT_PORT						EQU $303B ; port for sprite and pattern index 
SPRITE_INFO_PORT                        EQU $0057
SPRITE_PATTERN_UPLOAD_PORT				EQU $005B

MACHINE_ID_REGISTER						EQU 0
VERSION_REGISTER						EQU 1
RESET_REGISTER		    				EQU 2
MACHINE_TYPE_REGISTER					EQU 3
PAGE_RAM_REGISTER						EQU 4
PERIPHERAL_1_REGISTER					EQU 5
PERIPHERAL_2_REGISTER					EQU 6
TURBO_MODE_REGISTER						EQU 7
PERIPHERAL_3_REGISTER					EQU 8
ANTI_BRICK_SYSTEM_REGISTER				EQU 10
LAYER2_RAM_PAGE_REGISTER				EQU 18
LAYER2_RAM_SHADOW_REGISTER      		EQU 19
TRANSPARENCY_COLOUR_REGISTER			EQU 20
SPRITE_LAYERS_SYSTEM_REGISTER			EQU 21
LAYER2_OFFSET_X_REGISTER				EQU 22
LAYER2_OFFSET_Y_REGISTER				EQU 23
CLIP_WINDOW_LAYER2_REGISTER				EQU 24
CLIP_WINDOW_SPRITES_REGISTER			EQU 25
CLIP_WINDOW_ULA_REGISTER				EQU 26
CLIP_WINDOW_CONTROL_REGISTER			EQU 28
ACTIVE_VIDEO_LINE_MSB_REGISTER			EQU 30
ACTIVE_VIDEO_LINE_LSB_REGISTER			EQU 31
LINE_INTERRUPT_CONTROL_REGISTER			EQU 34
LINE_INTERRUPT_VALUE_LSB_REGISTER		EQU 35
KEYMAP_HIGH_ADDRESS_REGISTER			EQU 40
KEYMAP_LOW_ADDRESS_REGISTER				EQU 41
KEYMAP_HIGH_DATA_REGISTER				EQU 42
KEYMAP_LOW_DATA_REGISTER				EQU 43
DAC_B_MIRROR_REGISTER                   EQU 44
DAC_AB_MIRROR_REGISTER                  EQU 45
DAC_C_MORROR_REGISTER                   EQU 46
TILEMAP_OFFSET_XMSB_REGISTER            EQU 47
TILEMAP_OFFSET_XLSB_REGISTER            EQU 48
TILEMAP_OFFSET_YMSB_REGISTER            EQU 49
LORES_OFFSET_X_REGISTER					EQU 50
LORES_OFFSET_Y_REGISTER					EQU 51
SPRITE_PORT_INDEX_REGISTER              EQU 52
SPRITE_PORT_ATTR0_REGISTER              EQU 53
SPRITE_PORT_ATTR1_REGISTER              EQU 54
SPRITE_PORT_ATTR2_REGISTER              EQU 55
SPRITE_PORT_ATTR3_REGISTER              EQU 56
SPRITE_PORT_ATTR4_REGISTER              EQU 57
PALETTE_INDEX_REGISTER					EQU 64
PALETTE_VALUE_8BIT_REGISTER				EQU 65
PALETTE_FORMAT_REGISTER					EQU 66
PALETTE_CONTROL_REGISTER				EQU 67
PALETTE_VALUE_9BIT_REGISTER				EQU 68
MMU_SLOT_0_REGISTER						EQU 80
MMU_SLOT_1_REGISTER						EQU 81
MMU_SLOT_2_REGISTER						EQU 82
MMU_SLOT_3_REGISTER						EQU 83
MMU_SLOT_4_REGISTER						EQU 84
MMU_SLOT_5_REGISTER						EQU 85
MMU_SLOT_6_REGISTER						EQU 86
MMU_SLOT_7_REGISTER						EQU 87
COPPER_DATA_REGISTER					EQU 96
COPPER_CONTROL_LOW_REGISTER				EQU 97
COPPER_CONTROL_HIGH_REGISTER			EQU 98
DISPLAY_CONTROL_1_REGISTER              EQU 105
LAYER_2_CONTROL_REGISTER                EQU 112
LAYER_2_X_OFFSET_MSB_REGISTER           EQU 113
DEBUG_LEDS_REGISTER						EQU 255
 
galactic_cursor_sprite				equ	0
galactic_cursor_sprite1				equ	galactic_cursor_sprite+1
galactic_cursor_sprite2				equ	galactic_cursor_sprite1+2

galactic_hyper_sprite				equ	galactic_cursor_sprite2+1
;galactic_hyper_sprite1				equ galactic_hyper_sprite+1
;galactic_hyper_sprite2				equ	galactic_hyper_sprite1+1

local_cursor_sprite					equ	galactic_hyper_sprite+1
local_cursor_sprite1				equ	local_cursor_sprite+1
local_cursor_sprite2				equ	local_cursor_sprite1+1

local_hyper_sprite					equ	local_cursor_sprite2+1
local_hyper_sprite1					equ	local_hyper_sprite+1
local_hyper_sprite2					equ	local_hyper_sprite1+2

reticlule_sprite1                   equ	local_hyper_sprite2+1
reticlule_sprite2                   equ	reticlule_sprite1+1
reticlule_sprite3                   equ	reticlule_sprite2+1
reticlule_sprite4                   equ reticlule_sprite3+1

EXSDOSMMU0              equ MMU_SLOT_0_REGISTER
EXSDOSMMU1              equ MMU_SLOT_1_REGISTER

BankROM                 equ 255

glactic_pattern_1					equ 0
glactic_hyper_pattern_1             equ 2
local_present_cursor                equ 4
local_hyper_pattern                 equ 7
reticule_pattern_1                  equ 10
reticule_pattern_2                  equ 11
laser_pattern_1                     equ 12
laser_pattern_2                     equ 13
laser_pattern_3                     equ 14
laser_pattern_4                     equ 15
laser_pattern_5                     equ 16
targetting_pattern                  equ 23
lock_pattern                        equ 24
ecm_pattern                         equ 25
galactic_chart_y_offset		equ $18
galactic_chart_hyper_offset equ 4
galactic_chart_hyper_x_offset equ 32 - 4
galactic_chart_hyper_y_offset equ 32 - 4 + 24
compass_sun_infront                 equ 17
compass_sun_behind                  equ 18
compass_station_infront             equ 19
compass_station_behind              equ 20
spritecursoroffset					equ 17
spriteborderoffset                  equ 32

COLOUR_TRANSPARENT			 equ $E3     
     
HideSprite:                 MACRO   spritenbr
                            nextreg		SPRITE_PORT_INDEX_REGISTER,spritenbr
                            nextreg		SPRITE_PORT_ATTR3_REGISTER,$00
                            ENDM
                            
ShowSprite                  MACRO   spritenbr, patternnbr
                            ld      a, spritenbr
                            nextreg SPRITE_PORT_INDEX_REGISTER,a
                            ld      a,patternnbr | %10000000
                            nextreg	SPRITE_PORT_ATTR3_REGISTER,a
                            ENDM
                            
TopOfStack                  equ $6100    
                            org    $6200
StartOfCode:                di
l2_initialise:              nextreg		TRANSPARENCY_COLOUR_REGISTER, 		COLOUR_TRANSPARENT
                            nextreg 	SPRITE_LAYERS_SYSTEM_REGISTER,%01000011
                            nextreg EXSDOSMMU0,        BankROM
                            nextreg EXSDOSMMU1,        BankROM
                            call    GetDefaultDrive
                            call    stream_sprite_data
sprite_galactic_cursor:     ld		d,galactic_cursor_sprite
                            ld		e,0
                            ld		a,b
                            add		a,galactic_chart_y_offset
                            ld		b,a	
                            call	sprite_big
sprite_local_cursor:        ld		d,local_cursor_sprite
                            ld		e,local_present_cursor
                            call	sprite_big
sprite_local_hyper_cursor:  ld		d,local_hyper_sprite
                            ld		e,local_hyper_pattern
                            call	sprite_big
sprite_galactic_hyper_cursor:ld		a,b
                            add		a,galactic_chart_hyper_offset
                            ld		b,a	
                            ld		d,galactic_hyper_sprite
                            ld		e,3
                            call	sprite_single ; sprite_big:
                            break
LoopPoint:                  jp      LoopPoint   
                         
l1_set_border:          ld	    bc, 0xFEFE
                        out		(c),a
                        ret
                        
sprite_ghc_move:            ld		a,galactic_hyper_sprite
                            nextreg	SPRITE_PORT_INDEX_REGISTER,a		; set up sprite id
; write out X position bits 1 to 8
                            ld		a,c
                            ld      hl,galactic_chart_hyper_x_offset
                            add		hl,a                                ; hl = full x position
                            ld		a,l
                            nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x cc
; write out Y position bits 1 to 8
                            ex		de,hl								; de = full x position
                            srl		b			    					; row is row / 2
                            ld      a,b
                            ld      hl,galactic_chart_hyper_y_offset
                            add		hl,a
                            ld		a,l                                 ; hl = full y position
                            nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
; write out MSB of X as its an anchor  
                            ld		a,d									; de = MSB of X (hl bit 0)
                            nextreg	SPRITE_PORT_ATTR2_REGISTER,a		; lower y
; write out msb of y in h must be bit 0 only
                            ld		a,%00000000							; big unified composite
                            or		d									; MSB Y
                            nextreg	SPRITE_PORT_ATTR4_REGISTER,a		; visible 5 bytes pattern e
                            ret

sprite_lhc_move:            ld		a,local_hyper_sprite
                            nextreg	SPRITE_PORT_INDEX_REGISTER,a		; set up sprite id
; write out X position bits 1 to 8
                            ld		a,c
                            ld      hl,spritecursoroffset
                            add		hl,a                                ; hl = full x position
                            ld		a,l
                            nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x cc
; write out Y position bits 1 to 8
                            ex		de,hl								; de = full x position
                            ld		a,b
                            ld      hl,spritecursoroffset
                            add		hl,a
                            ld		a,l                                 ; hl = full y position
                            nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
; write out MSB of X as its an anchor  
                            ld		a,d									; de = MSB of X (hl bit 0)
                            nextreg	SPRITE_PORT_ATTR2_REGISTER,a		; lower y
; write out msb of y in h must be bit 0 only
                            ld		a,%00000000							; big unified composite
                            or		d									; MSB Y
                            nextreg	SPRITE_PORT_ATTR4_REGISTER,a		; visible 5 bytes pattern e
                            ret

stream_sprite_data:     ld          bc,SPRITE_SLOT_PORT             ; select pattern 0
                        xor a
                        out         (c),a
                        ld          (SpriteCounter),a               ; set up counter as it may be a nextos bug that sprites don't load
                        ld          a,7
                        call        l1_set_border
.OpenOutputFile:        ld          ix, SpriteFilename
                        ld          b, FA_READ
                        call        fOpen
                        jr          c,.OpenCarrySet
                        cp          0
                        jr          z,.OpenFailed                        
                        ld          (SpriteFileChannel),a
                        ld          d,29
.streamLoop:            push        de
                        ld          hl,SpriteCounter
                        inc         (hl)
                        ld          ix, SpriteDatabuffer
                        ld          bc,256
                        ld          a,(SpriteFileChannel)
                        call        fRead
                        jr          c,.ReadFailed
                        ld          e,255
.streamPattern:         ld          bc, SPRITE_PATTERN_UPLOAD_PORT
                        ld          hl, SpriteDatabuffer
.streamPatternLoop:     outinb                                      ; write byte of pattern
                        dec         e
                        jr          nz, .streamPatternLoop          ; carry on writing for "e" iterations
                        outinb                                      ; write byte 256
                        pop         de    
                        dec         d
                        jr          nz, .streamLoop
.CloseFile:             ld          a,(SpriteFileChannel)
                        call        fClose
                        cp          0
                        jr          z, .CloseFailed
                        ld          a,5
                        call        l1_set_border
                        ret
.OpenCarrySet:          ld          a,6
                        call        l1_set_border
                        jp          .OpenCarrySet
.OpenFailed:            ld          a,2
                        call        l1_set_border
                        jp          .OpenFailed

.CloseFailed:           ld          a,3
                        call        l1_set_border
                        jp          .CloseFailed                                
.ReadFailed:            ld          a,4
                        call        l1_set_border
                        jp          .ReadFailed

SpriteFileChannel       DB  0
SpriteCounter   db 0
SpriteFilename:         DB "NEXT.DAT",0
SpriteDatabuffer:       DS  256
sprite_big:
.SetAnchor:	                ld		a,d                                 ; a = sprite nbr, bug fix?
                            push	af									; save id for next few
                            push	de
                            nextreg	SPRITE_PORT_INDEX_REGISTER,a		; set up sprite id
; write out X position bits 1 to 8
                            ld		a,c
                            ld      hl,spritecursoroffset
                            add		hl,a                                ; hl = full x position
                            ld		a,l
                            nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x cc
; write out Y position bits 1 to 8
                            ex		de,hl								; de = full x position
                            ld		a,b
                            ld      hl,spritecursoroffset
                            add		hl,a
                            ld		a,l                                 ; hl = full y position
                            nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
; write out MSB of X as its an anchor  
                            ld		a,d									; de = MSB of X (hl bit 0)
                            nextreg	SPRITE_PORT_ATTR2_REGISTER,a		; lower y
; write out sprite pattern
                            pop		de                                  ; de = pattern and sprite nbr
                            ld		a,e
                            or		%11000000							; 
                            nextreg	SPRITE_PORT_ATTR3_REGISTER,a		; visible 5 bytes pattern e
; write out msb of y in h must be bit 0 only
                            ld		a,%00000000							; big unified composite
                            or		h									; MSB Y
                            nextreg	SPRITE_PORT_ATTR4_REGISTER,a		; visible 5 bytes pattern e
.BigSprite1:                pop		af
                            inc		a
                            push	af
                            nextreg		SPRITE_PORT_INDEX_REGISTER,a
                            ld		a,16
                            nextreg		SPRITE_PORT_ATTR0_REGISTER,a	; lower x
                            xor 	a
                            nextreg		SPRITE_PORT_ATTR1_REGISTER,a	; lower y
                            nextreg		SPRITE_PORT_ATTR2_REGISTER,a	; relative setup
                            ld		a,%11000001							; relative and 4 bytes of data, pattern 1
                            nextreg		SPRITE_PORT_ATTR3_REGISTER,a
                            ld		a,%01000001							; big unified composite
                            nextreg	SPRITE_PORT_ATTR4_REGISTER,a		; visible 5 bytes pattern e
.BigSprite2:                pop		af
                            inc		a
                            nextreg		SPRITE_PORT_INDEX_REGISTER,a
                            xor		a
                            nextreg		SPRITE_PORT_ATTR0_REGISTER,a	; lower x
                            ld		a,16
                            nextreg		SPRITE_PORT_ATTR1_REGISTER,a	; lower y
                            xor		a
                            nextreg		SPRITE_PORT_ATTR2_REGISTER,a	; relative setup
                            ld		a,%11000010							; relative and 4 bytes of data, pattern 2
                            nextreg		SPRITE_PORT_ATTR3_REGISTER,a
                            ld		a,%01000001							; big unified composite
                            nextreg	SPRITE_PORT_ATTR4_REGISTER,a		; visible 5 bytes pattern e
                            ret	
                            
sprite_single:          ld		a,d                                 ; a = sprite nbr, bug fix?
                        push    de
                        nextreg	SPRITE_PORT_INDEX_REGISTER,a		; set up sprite id
; write out X position bits 1 to 8
                        ld		a,c                                 ; a = column (c)
                        ld      hl,spriteborderoffset
                        add		hl,a                                ; hl = full x position
                        ex		de,hl								; de = full x position
                        ld		a,e
                        nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x cc
; write out Y position bits 1 to 8
                        ld		a,b                                 ; a = row
                        ld      hl,spriteborderoffset
                        add		hl,a
                        ld		a,l                                 ; hl = full y position
                        nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
; write out MSB of X as its an anchor  
                        ld		a,d									; de = MSB of X (hl bit 0)
                        nextreg	SPRITE_PORT_ATTR2_REGISTER,a		; lower y
; write out sprite pattern
                        pop     de
                        ld		a,e
                        or		%10000000							; 
                        nextreg	SPRITE_PORT_ATTR3_REGISTER,a		; visible 5 bytes pattern e
; write out extended attribute
                        ld      a,%00000000                         ; its a single sprite
                        or      h
                        nextreg	SPRITE_PORT_ATTR4_REGISTER,a
                        ret
M_GETSETDRV             equ $89
F_OPEN                  equ $9a
F_CLOSE                 equ $9b
F_READ                  equ $9d
F_WRITE                 equ $9e
F_SEEK                  equ $9f
            
FA_READ                 equ $01
FA_APPEND               equ $06
FA_OVERWRITE            equ $0C

; Success 1 = default drive, carry reset
; Failure HL = -1 , carry set, errno set
GetDefaultDrive:        push	af,,bc,,de,,hl,,ix
                        xor	    a	; a = 0 means get default drive into A
                        rst	    $08
                        db	    $89
                        ld	    (DefaultDrive),a
                        pop		af,,bc,,de,,hl,,ix
                        ret
DefaultDrive:	        db	0

; *******************************************************************************************************
;	Function:	Open a file read for reading/writing
;	In:		ix = filename
;			b  = Open filemode
;	ret		a  = handle, 0 on error
; *******************************************************************************************************
fOpen:	                push	hl
                        ld      hl,ix
                        ld	    a,(DefaultDrive)
                        rst	    $08
                        db	    F_OPEN
                        pop	    hl
                        ret
				
; *******************************************************************************************************
;	Function	Read bytes from the open file
;	In:		ix  = address to read into
;			bc  = amount to read
;	ret:		carry set = error
; *******************************************************************************************************
fRead:                  or   	a             ; is it zero?
                        ret  	z             ; if so return		
                        push    hl
                        ld      hl,ix    	 ; load ix into hl and save hl for later
                        rst	    $08
                        db	    F_READ
                        pop	    hl
                        ret		
		
; *******************************************************************************************************
;	Function	Write bytes to the open file
;	In:		ix  = address to read from
;			bc  = amount to write
;	ret:		carry set = error
; *******************************************************************************************************
fWrite:                 or   	a             ; is it zero?
                        ret  	z             ; if so return		
                        push	hl
                        ld      hl,ix
                        rst	    $08
                        db	    F_WRITE
                        pop	    hl
                        ret

; *******************************************************************************************************
;	Function:	Close open file
;	In:		a  = handle
;	ret		a  = handle, 0 on error
; *******************************************************************************************************
fClose:		            or   	a             ; is it zero?
                        ret  	z             ; if so return		
                        rst	    $08
                        db	    F_CLOSE
                        ret

; *******************************************************************************************************
;	Function	Read bytes from the open file
;	In:		a   = file handle
;			L   = Seek mode (0=start, 1=rel, 2=-rel)
;			BCDE = bytes to seek
;	ret:		BCDE = file pos from start
; *******************************************************************************************************
fSeek:                  push	ix,,hl
                        rst	    $08
                        db	    F_SEEK
                        pop	    ix,,hl
                        ret

; *******************************************************************************************************
; Init the file system
; *******************************************************************************************************
InitFileSystem:         call    GetDefaultDrive
                        ret

; *******************************************************************************************************
; Function:	Load a whole file into memory	(confirmed working on real machine)
; In:		hl = file data pointer
;		    ix = address to load to
;           bc = filelength
; *******************************************************************************************************
FileLoad:	            call    GetDefaultDrive
                        push	bc,,de,,af
                        ; get file size
                        push	bc,,ix			; store size, load address, 
                        ld      ix,hl
                        ld      b,FA_READ		; mode open for reading
                        call    fOpen
                        jr	    c,.error_opening; carry set? so there was an error opening and A=error code
                        cp	    0				; was file handle 0?
                        jr	    z,.error_opening; of so there was an error opening.
                        pop     bc,,ix          ; get load address back and size back
                        push	af				; remember handle
                        call	fRead			; read data from A to address IX of length BC                
                        jr	    c,.error_reading
                        pop	    af			    ; get handle back
                        call	fClose			; close file
                        jr	    c,.error_closing
                        pop     bc,,de,,af      ; normal exit
                        ret
;
; On error, display error code an lock up so we can see it
;
.error_opening:         pop	ix
.error_reading:		    pop	bc	; don't pop a, need error code

.error_closing: 
.NormalError:  	        pop	bc	; don't pop into A, return with error code
                        pop	de
                        pop	bc
                        ret
    
    SAVENEX OPEN "Sprites4.nex", StartOfCode , StartOfCode
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
        