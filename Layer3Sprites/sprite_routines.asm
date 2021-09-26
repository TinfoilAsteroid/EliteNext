
galactic_cursor_sprite				equ	0
galactic_cursor_sprite1				equ	galactic_cursor_sprite+1
galactic_cursor_sprite2				equ	galactic_cursor_sprite1+2

galactic_hyper_sprite				equ	galactic_cursor_sprite2+1
galactic_hyper_sprite1				equ galactic_hyper_sprite+1
galactic_hyper_sprite2				equ	galactic_hyper_sprite1+1

local_cursor_sprite					equ	galactic_hyper_sprite2+1
local_cursor_sprite1				equ	local_cursor_sprite+1
local_cursor_sprite2				equ	local_cursor_sprite1+1

local_hyper_sprite					equ	local_cursor_sprite2+1
local_hyper_sprite1					equ	local_hyper_sprite+1
local_hyper_sprite2					equ	local_hyper_sprite1+2

glactic_pattern_1					equ 0
glactic_hyper_pattern_1             equ 2
local_pattern_1                     equ 4
local_hyper_pattern_1               equ 6

spritecursoroffset					equ 17



	
sprite_big:
; " sprite_big BC = rowcol, D = sprite nbr , E= , pattern"
.SetAnchor:	
	ld		a,d                                 ; a = sprite nbr, bug fix?
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
.BigSprite1:
	pop		af
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
.BigSprite2:
	pop		af
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
	
sprite_galactic_cursor:
; ">sprite_galactic_cursor BC = rowcol"
	ld		d,galactic_cursor_sprite
	ld		e,0
	ld		a,b
	add		a,galactic_chart_y_offset
	ld		b,a	
	call	sprite_big:
	ret
	
sprite_galactic_hyper_cursor:
; "> sprite_galactic_hyper_cursorBC = rowcol"
	ld		a,b
	add		a,galactic_chart_y_offset
	ld		b,a	
	ld		d,galactic_hyper_sprite
	ld		e,3
	call	sprite_big:
	ret

sprite_ghc_move:
	ld		a,galactic_hyper_sprite
	nextreg	SPRITE_PORT_INDEX_REGISTER,a		; set up sprite id
; write out X position bits 1 to 8
	ld		a,c
    ld      hl,spritecursoroffset
	add		hl,a                                ; hl = full x position
	ld		a,l
	nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x cc
; write out Y position bits 1 to 8
	ex		de,hl								; de = full x position
    ld      a,b
	add		a,galactic_chart_y_offset
	ld		b,a	
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


sprite_lhc_move:
;DBG:jp DBG
;DBX:
	ld		a,local_hyper_sprite
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

sprite_local_cursor:
; "sprite_local_cursor BC = rowcol"
	ld		d,local_cursor_sprite
	ld		e,6
	call	sprite_big
	ret
	
sprite_local_hyper_cursor:
; "sprite_local_hyper_cursor BC = rowcol"
	ld		d,local_hyper_sprite
	ld		e,9
	call	sprite_big
	ret	


sprite_galactic_hide:
	nextreg		SPRITE_PORT_INDEX_REGISTER,galactic_cursor_sprite
	nextreg		SPRITE_PORT_ATTR3_REGISTER,$00
	nextreg		SPRITE_PORT_INDEX_REGISTER,galactic_cursor_sprite1
	nextreg		SPRITE_PORT_ATTR3_REGISTER,$00
	nextreg		SPRITE_PORT_INDEX_REGISTER,galactic_cursor_sprite2
	nextreg		SPRITE_PORT_ATTR3_REGISTER,$00
	ret	
	
sprite_galactic_hyper_hide:
	nextreg		SPRITE_PORT_INDEX_REGISTER,galactic_hyper_sprite
	nextreg		SPRITE_PORT_ATTR3_REGISTER,$00
	nextreg		SPRITE_PORT_INDEX_REGISTER,galactic_hyper_sprite1
	nextreg		SPRITE_PORT_ATTR3_REGISTER,$00
	nextreg		SPRITE_PORT_INDEX_REGISTER,galactic_hyper_sprite2
	nextreg		SPRITE_PORT_ATTR3_REGISTER,$00
	ret
	
sprite_local_hide:
	nextreg		SPRITE_PORT_INDEX_REGISTER,local_cursor_sprite
	nextreg		SPRITE_PORT_ATTR3_REGISTER,$00
	nextreg		SPRITE_PORT_INDEX_REGISTER,local_cursor_sprite1
	nextreg		SPRITE_PORT_ATTR3_REGISTER,$00
	nextreg		SPRITE_PORT_INDEX_REGISTER,local_cursor_sprite2
	nextreg		SPRITE_PORT_ATTR3_REGISTER,$00
	ret
	
sprite_local_hyper_hide:
	nextreg		SPRITE_PORT_INDEX_REGISTER,local_hyper_sprite
	nextreg		SPRITE_PORT_ATTR3_REGISTER,$00
	nextreg		SPRITE_PORT_INDEX_REGISTER,local_hyper_sprite1
	nextreg		SPRITE_PORT_ATTR3_REGISTER,$00
	nextreg		SPRITE_PORT_INDEX_REGISTER,local_hyper_sprite2
	nextreg		SPRITE_PORT_ATTR3_REGISTER,$00
	ret
	
sprite_cls_cursors:
	call	sprite_galactic_hide	
	call	sprite_galactic_hyper_hide	
	call	sprite_local_hide	
	call	sprite_local_hyper_hide	
	ret

init_sprites:
	call		sprite_cls_cursors
	nextreg 	SPRITE_LAYERS_SYSTEM_REGISTER,$63
	ret
	