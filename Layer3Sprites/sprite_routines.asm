
galactic_cursor_sprite				equ	0                            ; 00
galactic_cursor_sprite1				equ	galactic_cursor_sprite+1     ; 01
galactic_cursor_sprite2				equ	galactic_cursor_sprite1+2    ; 02
                                                                     ; 
galactic_hyper_sprite				equ	galactic_cursor_sprite2+1    ; 03
;galactic_hyper_sprite1				equ galactic_hyper_sprite+1      ; 
;galactic_hyper_sprite2				equ	galactic_hyper_sprite1+1     ; 
                                                                      
local_cursor_sprite					equ	galactic_hyper_sprite+1      ; 04
local_cursor_sprite1				equ	local_cursor_sprite+1        ; 05
local_cursor_sprite2				equ	local_cursor_sprite1+1       ; 06
                                                                     
local_hyper_sprite					equ	local_cursor_sprite2+1       ; 07
local_hyper_sprite1					equ	local_hyper_sprite+1         ; 08
local_hyper_sprite2					equ	local_hyper_sprite1+2        ; 09
                                                                     
reticlule_sprite1                   equ	local_hyper_sprite2+1        ; 10
reticlule_sprite2                   equ	reticlule_sprite1+1          ; 11
reticlule_sprite3                   equ	reticlule_sprite2+1          ; 12
reticlule_sprite4                   equ reticlule_sprite3+1          ; 13

laser_sprite1                       equ	reticlule_sprite4+1          ; 14
laser_sprite2                       equ	laser_sprite1    +1          ; 15
laser_sprite3                       equ	laser_sprite2    +1          ; 16
laser_sprite4                       equ laser_sprite3    +1          ; 17
laser_sprite5                       equ	laser_sprite4    +1          ; 18
laser_sprite6                       equ	laser_sprite5    +1          ; 19
laser_sprite7                       equ	laser_sprite6    +1          ; 20
laser_sprite8                       equ laser_sprite7    +1          ; 21
laser_sprite9                       equ	laser_sprite8    +1          ; 22
laser_sprite10                      equ	laser_sprite9    +1          ; 23
laser_sprite11                      equ	laser_sprite10   +1          ; 24
laser_sprite12                      equ laser_sprite11   +1          ; 25
laser_sprite13                      equ	laser_sprite12   +1          ; 26
laser_sprite14                      equ	laser_sprite13   +1          ; 27
laser_sprite15                      equ	laser_sprite14   +1          ; 28
laser_sprite16                      equ laser_sprite15   +1          ; 29
compass_sun                         equ laser_sprite16   +1          ; 30
compass_planet                      equ compass_sun      +1          ; 31
compass_station                     equ compass_planet   +1          ; 31
targetting_sprite1                  equ compass_station  +1          ; 32
targetting_sprite2                  equ targetting_sprite1   +1      ; 33
ECM_sprite                          equ targetting_sprite2   +1      ; 34
missile_sprite1                     equ ECM_sprite       +1          ; 35
missile_sprite2                     equ missile_sprite1  +1          ; 36
missile_sprite3                     equ missile_sprite2  +1          ; 37
missile_sprite4                     equ missile_sprite3  +1          ; 38
suncompass_sprite1                  equ missile_sprite4  +1
suncompass_sprite2                  equ suncompass_sprite1  +1
suncompass_sprite3                  equ suncompass_sprite2  +1
suncompass_sprite4                  equ suncompass_sprite3  +1

planetcompass_sprite1               equ suncompass_sprite4  +1
planetcompass_sprite2               equ planetcompass_sprite1  +1
planetcompass_sprite3               equ planetcompass_sprite2  +1
planetcompass_sprite4               equ planetcompass_sprite3  +1

stationcompass_sprite1              equ planetcompass_sprite4  +1
stationcompass_sprite2              equ stationcompass_sprite1  +1
stationcompass_sprite3              equ stationcompass_sprite2  +1
stationcompass_sprite4              equ stationcompass_sprite3  +1
diagnostic_sprite                   equ stationcompass_sprite4  +1


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
compass_sun_infront                 equ 17
compass_sun_behind                  equ 18
compass_planet_infront              equ 19
compass_planet_behind               equ 20
compass_station_infront             equ 21
compass_station_behind              equ 22
targetting_pattern                  equ 23
lock_pattern                        equ 24
ecm_pattern                         equ 25
missile_ready_pattern               equ 26
missile_armed_pattern               equ 27
missile_locked_pattern              equ 28
compass_sun_pattern                 equ 29
compass_planet_pattern              equ 30
compass_station_pattern             equ 31
compass_bottomright_pattern         equ 32
mass_locked_pattern                 equ 33
space_station_safe_zone_pattern     equ 34

spritecursoroffset					equ 17
spriteborderoffset                  equ 32

HideSprite:                 MACRO   spritenbr
                            nextreg		SPRITE_PORT_INDEX_REGISTER,spritenbr
                            nextreg		SPRITE_PORT_ATTR3_REGISTER,$00
                            ENDM

; " sprite_big BC = rowcol, D = sprite nbr , E= , pattern"
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
                                                  nextreg	SPRITE_PORT_INDEX_REGISTER,a
                            ld		a,16        : nextreg   SPRITE_PORT_ATTR0_REGISTER,a	; lower x
                            xor 	a           : nextreg   SPRITE_PORT_ATTR1_REGISTER,a	; lower y
                                                  nextreg   SPRITE_PORT_ATTR2_REGISTER,a	; relative setup
                            ld		a,%11000001	:
                            nextreg		SPRITE_PORT_ATTR3_REGISTER,a					; relative and 4 bytes of data, pattern 1
                            ld		a,%01000001							; big unified composite
                            nextreg	SPRITE_PORT_ATTR4_REGISTER,a		; visible 5 bytes pattern e
.BigSprite2:                pop		af
                            inc		a           : nextreg   SPRITE_PORT_INDEX_REGISTER,a
                            xor		a           : nextreg   SPRITE_PORT_ATTR0_REGISTER,a	; lower x
                            ld		a,16        : nextreg   SPRITE_PORT_ATTR1_REGISTER,a	; lower y
                            xor		a           : nextreg   SPRITE_PORT_ATTR2_REGISTER,a	; relative setup
                            ld		a,%11000010	: nextreg   SPRITE_PORT_ATTR3_REGISTER,a	; relative and 4 bytes of data, pattern 2
                            ld		a,%01000001	: nextreg   SPRITE_PORT_ATTR4_REGISTER,a	; visible 5 bytes pattern e 					; big unified composite
                            ret	

; Creates a 32x32 sprite based on first sprite number and pattern, then goes:
;    Spr,   pattern     spr+1, pattern+1
;    Spr+1, pattern+2   spr+3, pattern+3
; " sprite_big BC = row, hl= col D = sprite nbr , E= , pattern"
; note, BC and HL must be in correct range else they will mess up other byte's attributes, not masked for speed
; note this is based on full screen sprites including writing to border
; Currently can not get realtive sprites to work so will brute force it.
sprite_4x4:                 ld      a,e                                                         ; prep upper 2 bits as we will 
                            or      %11000000                                                   ; Enable visible and 5th byte
                            ld      e,a                                                         ; a now holds value to use for anchor
                            break
.SetAnchor:	                ld		a,d         : nextreg   SPRITE_PORT_INDEX_REGISTER,a		; set up sprite id
                            ld		a,l         : nextreg   SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x cc
                            ld      a,c         : nextreg   SPRITE_PORT_ATTR1_REGISTER,a		; Set up lower y cc
                            ld      a,h         : nextreg   SPRITE_PORT_ATTR2_REGISTER,a		; MSB of X position
                            ld      a,e         : nextreg	SPRITE_PORT_ATTR3_REGISTER,a		; visible 5 bytes pattern e
                            ld      a,b                                 ; get down MSB from b
                            or      %00100000   : nextreg   SPRITE_PORT_MIRROR_ATTRIBUTE_4_WITH_INC,a		; its going to be a unified "Big sprite" to uses rotations & scaling from anchor
;-- now process unified sprites
.TopRightRelative:         ; inc     d
                           ; ld      a,d         : nextreg	SPRITE_PORT_INDEX_REGISTER,a		; set up sprite id + 1
                            ld      a,l : add a,16 : nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x cc
                            ld      a,c               : nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; Set up lower y cc
                            ld      a,h                    : nextreg   SPRITE_PORT_ATTR2_REGISTER,a        ; clear MSB of X
                            inc     e
                            ld      a,e : nextreg	SPRITE_PORT_ATTR3_REGISTER,a		; visible, 5 bytes pattern is achor + 1
                            ld      a,%0100000  : nextreg	SPRITE_PORT_MIRROR_ATTRIBUTE_4_WITH_INC,a        ; pattern is relative and relative pattern 
.BottomLeftRelative:       ; inc     d
                           ; ld      a,d         : nextreg	SPRITE_PORT_INDEX_REGISTER,a		; set up sprite id + 1
                            ld      a,l:             : nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x cc
                            ld      a,c: add a,16        : nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; Set up lower y cc
                            ZeroA               : nextreg   SPRITE_PORT_ATTR2_REGISTER,a        ; clear MSB of X
                            inc     e
                            ld      a,e:/*%1100010*/  : nextreg	SPRITE_PORT_ATTR3_REGISTER,a		; visible, 5 bytes pattern is achor + 2
                            ld      a,%0100000  : nextreg	SPRITE_PORT_MIRROR_ATTRIBUTE_4_WITH_INC,a        ; pattern is relative and relative pattern 
;.BottomRightRelative:      ; inc     d
;                           ; inc     e
;                           ; ld      a,d         : nextreg	SPRITE_PORT_INDEX_REGISTER,a		; set up sprite id + 1
;                            ld      a,16        : nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x cc
;                            ld      a,16        : nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; Set up lower y cc
;                            ZeroA               : nextreg   SPRITE_PORT_ATTR2_REGISTER,a        ; clear MSB of X
;                            ld      a,%1100011  : nextreg	SPRITE_PORT_ATTR3_REGISTER,a		; visible, 5 bytes pattern is achor + 3
;                            ld      a,%0100001  : nextreg	SPRITE_PORT_ATTR4_REGISTER,a        ; pattern is relative and relative pattern 
;                            ld      a,e                                                         ; prep upper 2 bits as we will 
;                            or      %11000000                                                   ; Enable visible and 5th byte
;                            ld      e,a                                                         ; a now holds value to use for anchor
;                            break
.BRAbs:	                    ld		a,d :add a,3       : nextreg   SPRITE_PORT_INDEX_REGISTER,a		; set up sprite id
                            ld		a,l :add a,16:        : nextreg   SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x cc
                            ld      a,c :add a,16:        : nextreg   SPRITE_PORT_ATTR1_REGISTER,a		; Set up lower y cc
                            ld      a,h         : nextreg   SPRITE_PORT_ATTR2_REGISTER,a		; MSB of X position
                            inc     e
                            ld      a,e         : nextreg	SPRITE_PORT_ATTR3_REGISTER,a		; visible 5 bytes pattern e
                            ld      a,b                                 ; get down MSB from b
                            or      %00100000   : nextreg   SPRITE_PORT_MIRROR_ATTRIBUTE_4_WITH_INC,a	                            
                            ret	

	
; for a sinle sprite within 256x192 area    
sprite_single:              ld		a,d                                 ; a = sprite nbr, bug fix?
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
;-----------------------------------------------------------------------
; ">sprite_galactic_cursor BC = rowcol"    
sprite_galactic_cursor:     ld		d,galactic_cursor_sprite
                            ld		e,0
                            ld		a,b
                            add		a,galactic_chart_y_offset
                            ld		b,a	
                            call	sprite_big
                            ret
;-----------------------------------------------------------------------	
; "> sprite_galactic_hyper_cursorBC = rowcol"
sprite_galactic_hyper_cursor:ld		a,b
                            add		a,galactic_chart_hyper_offset
                            ld		b,a	
                            ld		d,galactic_hyper_sprite
                            ld		e,3
                            call	sprite_single ; sprite_big:
                            ret
;-----------------------------------------------------------------------
; moves hyperspace cursor to target system x position
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
;-----------------------------------------------------------------------
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
;-----------------------------------------------------------------------
; "sprite_local_cursor BC = rowcol"
sprite_local_cursor:        ld		d,local_cursor_sprite
                            ld		e,local_present_cursor
                            call	sprite_big
                            ret
;-----------------------------------------------------------------------
; "sprite_local_hyper_cursor BC = rowcol"
sprite_local_hyper_cursor:  ld		d,local_hyper_sprite
                            ld		e,local_hyper_pattern
                            call	sprite_big
                            ret	
;-----------------------------------------------------------------------
SunCompassTLX               equ 0
PlanetCompassTLX            equ 0
StationCompassTLX           equ 0
SunCompassTLY               equ 10
PlanetCompassTLY            equ 60
StationCompassTLY           equ 110
RadarCentreX                equ 128
RadarCentreY                equ 171


compass_offset              equ 2
ScannerX                    equ RadarCentreX
ScannerY                    equ RadarCentreY
SunScanCenterX              equ SunCompassTLX + 17
SunScanCenterY              equ SunCompassTLY + 17
PlanetScanCenterX           equ PlanetCompassTLX + 17
PlanetScanCenterY           equ PlanetCompassTLY + 17
StationScanCenterX          equ StationCompassTLX + 17
StationScanCenterY          equ StationCompassTLY + 17

;-----------------------------------------------------------------------
; ">sprite_galactic_cursor BC = rowcol"    
        DISPLAY "TODO : Compass positions, correct offsets for indicators, add in hide/show"
; " sprite_big BC = row, hl= col D = sprite nbr , E= , pattern"
sprite_sun_compass:         ld		hl,sunCompositeData
                            ld      b,4
                            ld      a,(hl)      : nextreg   SPRITE_PORT_INDEX_REGISTER,a              : inc hl
.Loop:                      ld      a,(hl)      : nextreg   SPRITE_PORT_ATTR0_REGISTER,a              : inc hl
                            ld      a,(hl)      : nextreg   SPRITE_PORT_ATTR1_REGISTER,a              : inc hl
                            ld      a,(hl)      : nextreg   SPRITE_PORT_ATTR2_REGISTER,a              : inc hl
                            ld      a,(hl)      : nextreg   SPRITE_PORT_ATTR3_REGISTER,a              : inc hl
                            ld      a,(hl)      : nextreg   SPRITE_PORT_MIRROR_ATTRIBUTE_4_WITH_INC,a : inc hl
                            djnz    .Loop
                            ret
sunCompassData:             db      suncompass_sprite1, SunCompassTLX,     SunCompassTLY,      %00000000 , $80 | compass_sun_pattern
                            db                          SunCompassTLX +17, SunCompassTLY,      %00001000 , $80 | compass_sun_pattern
                            db                          SunCompassTLX,     SunCompassTLY + 17, %00000100 , $80 | compass_sun_pattern
                            db                          SunCompassTLX +17, SunCompassTLY + 17, %00001100 , $80 | compass_sun_pattern
sunCompositeData:           db      suncompass_sprite1, SunCompassTLX,     SunCompassTLY,      %00000000 , $81 | compass_sun_pattern , %00000000
                            db                          SunCompassTLX +17, SunCompassTLY,      %00001000 , $81                       , %01000001
                            db                          SunCompassTLX,     SunCompassTLY + 17, %00000100 , $81                       , %01000001
                            db                          SunCompassTLX +17, SunCompassTLY + 17, %00001100 , $81                       , %01000001
                            
;-----------------------------------------------------------------------
sprite_planet_compass:      ld		hl,planetCompositeData
                            ld      b,4
                            ld      a,(hl)      : nextreg   SPRITE_PORT_INDEX_REGISTER,a              : inc hl
.Loop:                      ld      a,(hl)      : nextreg   SPRITE_PORT_ATTR0_REGISTER,a              : inc hl
                            ld      a,(hl)      : nextreg   SPRITE_PORT_ATTR1_REGISTER,a              : inc hl
                            ld      a,(hl)      : nextreg   SPRITE_PORT_ATTR2_REGISTER,a              : inc hl
                            ld      a,(hl)      : nextreg   SPRITE_PORT_ATTR3_REGISTER,a              : inc hl
                            ld      a,(hl)      : nextreg   SPRITE_PORT_MIRROR_ATTRIBUTE_4_WITH_INC,a : inc hl
                            djnz    .Loop
                            ret
planetCompassData:          db      planetcompass_sprite1, PlanetCompassTLX,     PlanetCompassTLY,      %00000000 , $80 | compass_planet_pattern
                            db                             PlanetCompassTLX +17, PlanetCompassTLY,      %00001000 , $80 | compass_planet_pattern
                            db                             PlanetCompassTLX,     PlanetCompassTLY + 17, %00000100 , $80 | compass_planet_pattern
                            db                             PlanetCompassTLX +17, PlanetCompassTLY + 17, %00001100 , $80 | compass_planet_pattern
planetCompositeData:        db      planetcompass_sprite1, PlanetCompassTLX,     PlanetCompassTLY,      %00000000 , $81 | compass_planet_pattern , %00000000
                            db                             PlanetCompassTLX +17, PlanetCompassTLY,      %00001000 , $81                          , %01000001
                            db                             PlanetCompassTLX,     PlanetCompassTLY + 17, %00000100 , $81                          , %01000001
                            db                             PlanetCompassTLX +17, PlanetCompassTLY + 17, %00001100 , $81                          , %01000001

;-----------------------------------------------------------------------

sprite_station_compass:     ld		hl,stationCompositeData
                            ld      b,4
                            ld      a,(hl)      : nextreg   SPRITE_PORT_INDEX_REGISTER,a              : inc hl
.Loop:                      ld      a,(hl)      : nextreg   SPRITE_PORT_ATTR0_REGISTER,a              : inc hl
                            ld      a,(hl)      : nextreg   SPRITE_PORT_ATTR1_REGISTER,a              : inc hl
                            ld      a,(hl)      : nextreg   SPRITE_PORT_ATTR2_REGISTER,a              : inc hl
                            ld      a,(hl)      : nextreg   SPRITE_PORT_ATTR3_REGISTER,a              : inc hl
                            ld      a,(hl)      : nextreg   SPRITE_PORT_MIRROR_ATTRIBUTE_4_WITH_INC,a : inc hl
                            djnz    .Loop
                            ret
stationCompassData:         db      stationcompass_sprite1, StationCompassTLX,     StationCompassTLY,      %00000000 , $80 | compass_station_pattern
                            db                              StationCompassTLX +17, StationCompassTLY,      %00001000 , $80 | compass_station_pattern
                            db                              StationCompassTLX,     StationCompassTLY + 17, %00000100 , $80 | compass_station_pattern
                            db                              StationCompassTLX +17, StationCompassTLY + 17, %00001100 , $80 | compass_station_pattern
stationCompositeData:       db      stationcompass_sprite1, StationCompassTLX,     StationCompassTLY,      %00000000 , $81 | compass_station_pattern , %00000000
                            db                              StationCompassTLX +17, StationCompassTLY,      %00001000 , $81                           , %01000001
                            db                              StationCompassTLX,     StationCompassTLY + 17, %00000100 , $81                           , %01000001
                            db                              StationCompassTLX +17, StationCompassTLY + 17, %00001100 , $81                           , %01000001
 


; Put on compas based on bc = Y X position offset from compass center    
compass_sun_move:       ld		a,compass_sun
                        nextreg	SPRITE_PORT_INDEX_REGISTER,a		; set up sprite id
; write out X position bits 1 to 8
                        ld      a, SunScanCenterX - compass_offset ; adjust offset for effective centre of sprite
                        add     a,c
                        DISPLAY "TODO - Add min max on X and Y"
                        nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x cc
; write out Y position bits 1 to 8
                        ld      a, SunScanCenterY - compass_offset ; adjust offset for effective centre of sprite
                        sub     b
                        nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
                        ret    

; Put on compas based on bc = Y X position offset from compass center    
compass_planet_move:    ld		a,compass_planet
                        nextreg	SPRITE_PORT_INDEX_REGISTER,a		; set up sprite id
; write out X position bits 1 to 8
                        ld      a, PlanetScanCenterX - compass_offset ; adjust offset for effective centre of sprite
                        add     a,c
                        nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x cc
; write out Y position bits 1 to 8
                        ld      a, PlanetScanCenterY - compass_offset ; adjust offset for effective centre of sprite
                        sub     b
                        nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
                        ret    
                        
                        
; Put on compas based on bc = Y X position offset from compass center    
compass_station_move:   ld		a,compass_station
                        nextreg	SPRITE_PORT_INDEX_REGISTER,a		; set up sprite id
; write out X position bits 1 to 8
                        ld      a, StationScanCenterX - compass_offset ; adjust offset for effective centre of sprite
                        add     a,c
                        nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x cc
; write out Y position bits 1 to 8
                        ld      a, StationScanCenterY - compass_offset ; adjust offset for effective centre of sprite
                        sub     b
                        nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
                        ret    
                        
ReticuleCentreX         EQU (256/2)+32 -1
ReticuleCentreY         EQU (192/2)+32 -1
ReticuleOffset          EQU 8

TargetetingCentreX1     EQU ReticuleCentreX -32
TargetetingCentreX2     EQU ReticuleCentreX +16
TargetetingCentreY      EQU ReticuleCentreY -7

sprite_missile_x        EQU 2+32
sprite_missile_y        EQU 192-8+32

sprite_ecm_x            EQU (6*8) +2 +32
sprite_ecm_y            EQU 192-15+32

sprite_ECM:             ld      a,ECM_sprite
                        nextreg SPRITE_PORT_INDEX_REGISTER,a
                        ld      a,sprite_ecm_x
                        nextreg	SPRITE_PORT_ATTR0_REGISTER,a	
                        ld		a,sprite_ecm_y 
                        nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
                        ld      a,ecm_pattern | %10000000
                        nextreg	SPRITE_PORT_ATTR3_REGISTER,a		; visible 5 bytes pattern left reticule
                        ret

sprite_missile_ready:   nextreg SPRITE_PORT_INDEX_REGISTER,a
                        ld      a,c
                        nextreg	SPRITE_PORT_ATTR0_REGISTER,a	
                        ld		a,sprite_missile_y 
                        nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
                        ld      a,missile_ready_pattern | %10000000
                        nextreg	SPRITE_PORT_ATTR3_REGISTER,a		; visible 5 bytes pattern left reticule
                        ret

sprite_missile_1:       ld      a,missile_sprite1                            
                        ld      c,sprite_missile_x
                        jp      sprite_missile_ready
                           
sprite_missile_2:       ld      a,missile_sprite2                            
                        ld      c,sprite_missile_x+15
                        jp      sprite_missile_ready
                              
sprite_missile_3:       ld      a,missile_sprite3                            
                        ld      c,sprite_missile_x+25
                        jp      sprite_missile_ready
                        
sprite_missile_4:       ld      a,missile_sprite4
                        ld      c,sprite_missile_x +35
                        jp      sprite_missile_ready


                        
sprite_reticule:        ld      a,reticlule_sprite1                 ; LEFT ARM
                        nextreg SPRITE_PORT_INDEX_REGISTER,a        ; select left hand side
                        ld      a,ReticuleCentreX -16 - ReticuleOffset
                        nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x pos as 136 (104 + 32 border)
                        ld		a,ReticuleCentreY
                        nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
                        xor     a
                        nextreg	SPRITE_PORT_ATTR2_REGISTER,a		; attribute 2
                        ld      a,reticule_pattern_2 | %10000000
                        nextreg	SPRITE_PORT_ATTR3_REGISTER,a		; visible 5 bytes pattern left reticule
.rightReticule          ld      a,reticlule_sprite2                 ; RIGHT ARM
                        nextreg SPRITE_PORT_INDEX_REGISTER,a        ; select left hand side
                        ld      a,ReticuleCentreX + ReticuleOffset
                        nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x pos as 136 (104 + 32 border)
                        ld		a,ReticuleCentreY
                        nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
                        ld      a,%00001000
                        nextreg	SPRITE_PORT_ATTR2_REGISTER,a		; attribute 2 including mirroring horizontal
                        ld      a,reticule_pattern_2 | %10000000
                        nextreg	SPRITE_PORT_ATTR3_REGISTER,a		; visible 5 bytes pattern left reticule
.topReticule            ld      a,reticlule_sprite3
                        nextreg SPRITE_PORT_INDEX_REGISTER,a        ; select left hand side
                        ld      a,ReticuleCentreX
                        nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x pos as 136 (104 + 32 border)
                        ld		a,ReticuleCentreY-16 - ReticuleOffset
                        nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
                        xor     a
                        nextreg	SPRITE_PORT_ATTR2_REGISTER,a		; attribute 2 
                        ld      a,reticule_pattern_1 | %10000000
                        nextreg	SPRITE_PORT_ATTR3_REGISTER,a		; visible 5 bytes pattern left reticule
.bottomReticule         ld      a,reticlule_sprite4
                        nextreg SPRITE_PORT_INDEX_REGISTER,a        ; select left hand side
                        ld      a,ReticuleCentreX
                        nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x pos as 136 (104 + 32 border)
                        ld		a,ReticuleCentreY + ReticuleOffset
                        nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
                        ld      a,%00000100
                        nextreg	SPRITE_PORT_ATTR2_REGISTER,a		; attribute 2 including mirroring vertical
                        ld      a,reticule_pattern_1 | %10000000
                        nextreg	SPRITE_PORT_ATTR3_REGISTER,a		; visible 5 bytes pattern left reticule
                        ret

laserbasex              equ 6
laserbasey              equ 14  
    
ShowSprite              MACRO   spritenbr, patternnbr
                        ld      a, spritenbr
                        nextreg SPRITE_PORT_INDEX_REGISTER,a
                        ld      a,patternnbr | %10000000
                        nextreg	SPRITE_PORT_ATTR3_REGISTER,a
                        ENDM
                        
LeftLaser:              MACRO   xoffset, yoffset, spriteL, patternL
                        ld      a, spriteL
                        nextreg SPRITE_PORT_INDEX_REGISTER,a        ; select left hand side
                        ld      a,((laserbasex + xoffset) *8) + 32 
                        nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x pos as 136 (104 + 32 border)
                        ld		a,((laserbasey -yoffset) * 8) + 32 -1
                        nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
                        xor     a
                        nextreg	SPRITE_PORT_ATTR2_REGISTER,a		; attribute 2
                        ld      a, patternL | %00000000             ; hidden by default
                        nextreg	SPRITE_PORT_ATTR3_REGISTER,a		 
                        ENDM
    
RightLaser:             MACRO   xoffset, yoffset, spriteL, patternL
                        ld      a, spriteL
                        nextreg SPRITE_PORT_INDEX_REGISTER,a        ; select left hand side
                        ld      a,(((30-laserbasex) - xoffset) *8) + 32 -2
                        nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x pos as 136 (104 + 32 border)
                        ld		a,((laserbasey -yoffset) * 8) + 32 -1
                        nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
                        ld      a,%00001000
                        nextreg	SPRITE_PORT_ATTR2_REGISTER,a		; attribute 2
                        ld      a, patternL | %00000000             ; hidden by default
                        nextreg	SPRITE_PORT_ATTR3_REGISTER,a		 
                        ENDM
                    
show_ecm_sprite:        ShowSprite  ECM_sprite, ecm_pattern
                        ret

show_missile_1_ready:   ShowSprite  missile_sprite1, missile_ready_pattern
                        ret

show_missile_2_ready:   ShowSprite  missile_sprite2, missile_ready_pattern
                        ret

show_missile_3_ready:   ShowSprite  missile_sprite3, missile_ready_pattern
                        ret

show_missile_4_ready:   ShowSprite  missile_sprite4, missile_ready_pattern
                        ret

show_missile_1_armed:   ShowSprite  missile_sprite1, missile_armed_pattern
                        ret

show_missile_1_locked:  ShowSprite  missile_sprite1, missile_locked_pattern
                        ret

                        
show_compass_sun_infront:ShowSprite  compass_sun, compass_sun_infront
                         ret
                         
show_compass_sun_behind: ShowSprite  compass_sun, compass_sun_behind
                         ret

show_compass_station_infront: ShowSprite  compass_station, compass_station_infront
                         ret

show_compass_station_behind:  ShowSprite  compass_station, compass_station_behind
                            ret
show_compass_planet_infront: ShowSprite  compass_planet, compass_planet_infront
                         ret

show_compass_planet_behind:  ShowSprite  compass_planet, compass_planet_behind
                            ret
;-----------------------------------------------------------------------                        
show_sprite_sun_compass:    ShowSprite  suncompass_sprite1, compass_sun_pattern
                            ShowSprite  suncompass_sprite2, compass_sun_pattern
                            ShowSprite  suncompass_sprite3, compass_sun_pattern
                            ShowSprite  suncompass_sprite4, compass_sun_pattern
                            ret
;-----------------------------------------------------------------------
show_sprite_planet_compass: ShowSprite  planetcompass_sprite1, compass_planet_pattern
                            ShowSprite  planetcompass_sprite2, compass_planet_pattern
                            ShowSprite  planetcompass_sprite3, compass_planet_pattern
                            ShowSprite  planetcompass_sprite4, compass_planet_pattern
                            ret	
;-----------------------------------------------------------------------
show_sprite_station_compass:ShowSprite  stationcompass_sprite1, compass_station_pattern
                            ShowSprite  stationcompass_sprite2, compass_station_pattern
                            ShowSprite  stationcompass_sprite3, compass_station_pattern
                            ShowSprite  stationcompass_sprite4, compass_station_pattern
                            ret	
;-----------------------------------------------------------------------                            
;-----------------------------------------------------------------------
    
sprite_laser:           LeftLaser  0,0,laser_sprite1 ,laser_pattern_1
                        LeftLaser  2,0,laser_sprite2 ,laser_pattern_2
                        LeftLaser  4,1,laser_sprite3 ,laser_pattern_3
                        LeftLaser  6,1,laser_sprite4 ,laser_pattern_4
                        LeftLaser  8,2,laser_sprite5 ,laser_pattern_5
                        RightLaser 0,0,laser_sprite9 ,laser_pattern_1
                        RightLaser 2,0,laser_sprite10,laser_pattern_2
                        RightLaser 4,1,laser_sprite11,laser_pattern_3
                        RightLaser 6,1,laser_sprite12,laser_pattern_4
                        RightLaser 8,2,laser_sprite13,laser_pattern_5
                        ret                           
                        ; Need simple show updates just to update the show attribute

sprite_laser_show:      ShowSprite laser_sprite1 ,laser_pattern_1
                        ShowSprite laser_sprite2 ,laser_pattern_2
                        ShowSprite laser_sprite3 ,laser_pattern_3
                        ShowSprite laser_sprite4 ,laser_pattern_4
                        ShowSprite laser_sprite5 ,laser_pattern_5
                        ShowSprite laser_sprite9 ,laser_pattern_1
                        ShowSprite laser_sprite10,laser_pattern_2
                        ShowSprite laser_sprite11,laser_pattern_3
                        ShowSprite laser_sprite12,laser_pattern_4
                        ShowSprite laser_sprite13,laser_pattern_5
                        ret

sprite_galactic_hide:   HideSprite galactic_cursor_sprite
                        HideSprite galactic_cursor_sprite1
                        HideSprite galactic_cursor_sprite2
                        ret	
	
sprite_galactic_hyper_hide:
                        HideSprite galactic_hyper_sprite
                         ;nextreg		SPRITE_PORT_INDEX_REGISTER,galactic_hyper_sprite1
;                        nextreg		SPRITE_PORT_ATTR3_REGISTER,$00
;                        nextreg		SPRITE_PORT_INDEX_REGISTER,galactic_hyper_sprite2
;                        nextreg		SPRITE_PORT_ATTR3_REGISTER,$00
                        ret
	
sprite_local_hide:      HideSprite local_cursor_sprite
                        HideSprite local_cursor_sprite1
                        HideSprite local_cursor_sprite2
                        ret
	
sprite_local_hyper_hide:HideSprite local_hyper_sprite
                        HideSprite local_hyper_sprite1
                        HideSprite local_hyper_sprite2
                        ret

sprite_reticule_hide:   HideSprite reticlule_sprite1
                        HideSprite reticlule_sprite2
                        HideSprite reticlule_sprite3
                        HideSprite reticlule_sprite4
                        ret

sprite_ecm_hide:        HideSprite ECM_sprite
                        ret

sprite_missile_1_hide:  HideSprite missile_sprite1
                        ret

sprite_missile_2_hide:  HideSprite missile_sprite2
                        ret

sprite_missile_3_hide:  HideSprite missile_sprite3
                        ret

sprite_missile_4_hide:  HideSprite missile_sprite4
                        ret

sprite_missile_all_hide:call  sprite_missile_1_hide
                        call  sprite_missile_2_hide
                        call  sprite_missile_3_hide
                        call  sprite_missile_4_hide
                        ret
                            
sprite_targetting:      ld      a,targetting_sprite1                 ; LEFT ARM
                        nextreg SPRITE_PORT_INDEX_REGISTER,a        ; select left hand side
                        ld      a,TargetetingCentreX1
                        nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x pos as 136 (104 + 32 border)
                        ld		a,TargetetingCentreY 
                        nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
                        xor     a
                        nextreg	SPRITE_PORT_ATTR2_REGISTER,a		; attribute 2
                        ld      a,targetting_pattern | %10000000
                        nextreg	SPRITE_PORT_ATTR3_REGISTER,a		; visible 5 bytes pattern left reticule
.right:                 ld      a,targetting_sprite2                ; RIGHT ARM
                        nextreg SPRITE_PORT_INDEX_REGISTER,a        ; select left hand side
                        ld      a,TargetetingCentreX2
                        nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x pos as 136 (104 + 32 border)
                        ld		a,TargetetingCentreY
                        nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
                        ld      a,%00001000
                        nextreg	SPRITE_PORT_ATTR2_REGISTER,a		; attribute 2 including mirroring horizontal
                        ld      a,targetting_pattern | %10000000
                        nextreg	SPRITE_PORT_ATTR3_REGISTER,a		; visible 5 bytes pattern left reticule
                        ret

sprite_lock:            ld      a,targetting_sprite1                 ; LEFT ARM
                        nextreg SPRITE_PORT_INDEX_REGISTER,a        ; select left hand side
                        ld      a,TargetetingCentreX1
                        nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x pos as 136 (104 + 32 border)
                        ld		a,TargetetingCentreY 
                        nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
                        xor     a
                        nextreg	SPRITE_PORT_ATTR2_REGISTER,a		; attribute 2
                        ld      a,lock_pattern | %10000000
                        nextreg	SPRITE_PORT_ATTR3_REGISTER,a		; visible 5 bytes pattern left reticule
.right:                 ld      a,targetting_sprite2                 ; RIGHT ARM
                        nextreg SPRITE_PORT_INDEX_REGISTER,a        ; select left hand side
                        ld      a,TargetetingCentreX2
                        nextreg	SPRITE_PORT_ATTR0_REGISTER,a		; Set up lower x pos as 136 (104 + 32 border)
                        ld		a,TargetetingCentreY
                        nextreg	SPRITE_PORT_ATTR1_REGISTER,a		; lower y coord on screen
                        ld      a,%00001000
                        nextreg	SPRITE_PORT_ATTR2_REGISTER,a		; attribute 2 including mirroring horizontal
                        ld      a,lock_pattern | %10000000
                        nextreg	SPRITE_PORT_ATTR3_REGISTER,a		; visible 5 bytes pattern left reticule
                        ret

       
                            
sprite_targetting_hide: HideSprite targetting_sprite1
                        HideSprite targetting_sprite2
                        ret

sprite_targetting_show: ShowSprite targetting_sprite1, targetting_pattern
                        ShowSprite targetting_sprite2, targetting_pattern
                        ret

sprite_laser_hide:      HideSprite laser_sprite1
                        HideSprite laser_sprite2
                        HideSprite laser_sprite3
                        HideSprite laser_sprite4
                        HideSprite laser_sprite5
                        HideSprite laser_sprite6
                        HideSprite laser_sprite7
                        HideSprite laser_sprite8
                        HideSprite laser_sprite9
                        HideSprite laser_sprite10
                        HideSprite laser_sprite11
                        HideSprite laser_sprite12
                        HideSprite laser_sprite13
                        HideSprite laser_sprite14
                        HideSprite laser_sprite15
                        HideSprite laser_sprite16
                        ret
    
sprite_compass_hide:    HideSprite compass_sun
                        HideSprite compass_planet
                        HideSprite compass_station
                        HideSprite suncompass_sprite1
                        HideSprite planetcompass_sprite1
                        HideSprite stationcompass_sprite1
                        ret

sprite_cls_cursors:     call	sprite_galactic_hide	
                        call	sprite_galactic_hyper_hide	
                        call	sprite_local_hide	
                        call	sprite_local_hyper_hide	
                        call    sprite_reticule_hide
                        call    sprite_laser_hide
                        call    sprite_compass_hide
                        call    sprite_targetting_hide
                        call    sprite_missile_all_hide
                        ret
                        
sprite_cls_all:         call    sprite_cls_cursors
                        call    sprite_ecm_hide
                        call    sprite_missile_all_hide
                        ret
                        
init_sprites:           call		sprite_cls_cursors
                        nextreg 	SPRITE_LAYERS_SYSTEM_REGISTER,%01000011
                        ret


select_sprite_a:        MACRO
                        nextreg SPRITE_PORT_INDEX_REGISTER,a
                        ENDM

set_sprite_x_low_a:     MACRO
                        nextreg	SPRITE_PORT_ATTR0_REGISTER,a
                        ENDM
                        
set_sprite_y_low_a:     MACRO
                        nextreg	SPRITE_PORT_ATTR1_REGISTER,a
                        ENDM

set_sprite_x_msb_anc:   MACRO
                        nextreg	SPRITE_PORT_ATTR2_REGISTER,a
                        ENDM

set_sprite_pat_a:       MACRO
                        nextreg	SPRITE_PORT_ATTR3_REGISTER,a
                        ENDM

set_sprite_pat_a_nx:    MACRO
                        and     %10111111
                        set_sprite_pat_a
                        ENDM

set_sprite_pat_a_vis:   MACRO
                        or      %10000000
                        set_sprite_pat_a
                        ENDM

set_sprite_hidden:      MACRO
                        xor     a
                        set_sprite_pat_a
                        ENDM

set_sprite_pas_a_vis_nx:MACRO                        
                        or      %10000000
                        set_sprite_pat_a_nx
                        ENDM

set_sprite_extended_a:  MACRO
                        nextreg	SPRITE_PORT_ATTR4_REGISTER,a
                        ENDM

diag_x_pos:             DB 32
diag_y_pos:             DB 64
diag_sprite_nbr:        DB 0

sprite_diagnostic_clear:ld      b,64
                        ld      c,0
.HideLoop:              ld      a,c
                        HideSprite a
                        inc     c
                        djnz    .HideLoop
                        ret

sprite_diagnostic:      ld      a,$80
                        ld      (diag_sprite_nbr),a
                        ld      a,64
                        ld      (diag_y_pos),a
                        break
.sprite_newline:        xor a
                        ld      (diag_x_pos),a
.sprite_loop:           ld      a,(diag_sprite_nbr) : and $7F:  select_sprite_a
                        ld      a,(diag_x_pos)      : set_sprite_x_low_a
                        add     a,16
                        ld      (diag_x_pos),a
                        ld      a,(diag_y_pos)      : set_sprite_y_low_a
                        ld      a,0                 : set_sprite_x_msb_anc
                        ld      a,(diag_sprite_nbr) : set_sprite_pat_a
                        inc     a
                        ld      (diag_sprite_nbr),a
                        and     $7F
                        JumpIfALTNusng  35,.cont
.drawBig:               ld      de,diagnostic_sprite*256 + compass_sun_pattern
                        ld      bc,150
                        ld      hl,150
                        call    sprite_4x4

                        ret
.cont:                  ld      a,(diag_x_pos)
                        JumpIfALTNusng 200,.sprite_loop
                        ld      a,(diag_y_pos)
                        add     a,20
                        ld      (diag_y_pos),a
                        jr      .sprite_newline
                        ret
                                               
    
    