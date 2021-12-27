sprite_load_sprite_data:
	ld			bc, $303B; SPRITE_SLOT_PORT
	xor			a
	out			(c),a							; Prime slot upload
	ld			de,22	* 256						; nbr of sprites to upload	
	ld			hl,Sprite1						; sprites are stored contiguous
SpriteLoadLoop:	
	ld			bc, $5b; SPRITE_PATTERN_UPLOAD_PORT
	outinb											; do final 256th sprite
	dec			de
	ld			a,d
	or			e
	jr			nz,SpriteLoadLoop				; keep on rolling through sprites
	ret
