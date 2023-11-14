

DEBUGSETNODES:          ld      hl,DEBUGUBNKDATA
                        ld      de,UBnKxlo
                        ld      bc,9
                        ldir
                        ld      hl,DEBUGROTMATDATA
                        ld      de,UBnkrotmatSidevX
                        ld      bc,6*3
                        ldir
                        ret

DEBUGSETPOS:            ld      hl,DEBUGUBNKDATA 
                        ld      de,UBnKxlo 
                        ld      bc,9 - 3
                        ldir
                        ret
                        
; culltest
;DEBUGUBNKDATA:          db      $00,	$00,	$00,	$00,	$00,	$00,	$31,	$03,	$00
DEBUGUBNKDATA:          db      $00,	$00,	$00,	$00,	$00,	$00,	$5C,	$07,	$00
DEBUGROTMATDATA:        db      $00,	$60,	$00,	$00,	$00,	$00
                        db      $00,	$00,	$00,	$60,	$00,	$00
                        db      $00,	$00,	$00,	$00,	$00,	$E0

; FAILS due to sharp angle, OK now
;DEBUGUBNKDATA:          db      $39,	$01,	$00,	$43,	$01,	$00,	$EF,	$03,	$00
;DEBUGROTMATDATA:        db      $01,	$2F,	$B2,	$CC,	$4C,	$27
;                        db      $17,	$46,	$87,	$3C,	$95,	$20
;                        db      $E2,	$32,	$31,	$8C,	$EF,	$D1
; TOP RIGHT CORNER Passes as python and cobra
;DEBUGUBNKDATA:          db      $39,	$01,	$00,	$43,	$01,	$00,	$5B,	$04,	$00
;DEBUGROTMATDATA:        db      $E2,	$03,	$3A,	$16,	$F5,	$60
;                        db      $D3,	$CE,	$F3,	$BA,	$4E,	$0F
;                        db      $03,	$BE,	$4A,	$4B,	$DB,	$8C
; Looks OK
;DEBUGUBNKDATA:          db      $39,    $01,    $00,    $43,    $01,    $00,    $EE,    $02,    $00
;DEBUGROTMATDATA:        db      $35,    $d8,    $98,    $9f,    $b0,    $1a
;                        db      $4B,    $26,    $CE,    $d6,    $60,    $16
;                        db      $89,    $90,    $c4,    $9f,    $dd,    $d9
;
; Massive horizontal line
; 15th line (or line 14 has corrodinates 05,00 to D8,00) which looks wrong
; node array looks OK, looks liek its sorted as it was both -ve Y off screen fix added
;DEBUGUBNKDATA:          db      $39,    $01,    $00,    $43,    $01,    $00,    $BD,    $03,    $00
;DEBUGROTMATDATA:        db      $59,    $CF,    $06,    $B6,    $61,    $8D
;                        db      $AD,    $B1,    $97,    $4F,    $C9,    $98
;                        db      $61,    $99,    $E0,    $0D,    $11,    $5C
; Line lost in clipping 
;DEBUGUBNKDATA:          db      $39,    $01,    $00,    $43,    $01,    $00,    $8B,    $04,    $00
;DEBUGROTMATDATA:        db      $A3,    $4D,    $A9,    $28,    $F8,    $AF
;                        db      $FB,    $97,    $8C,    $B5,    $FB,    $D0
;                        db      $DB,    $3A,    $29,    $CA,    $29,    $1C
;DEBUGUBNKDATA:          db      $5E,    $02,    $00,    $FE,    $00,    $FE,    $E5,    $09,    $00
;DEBUGROTMATDATA:        db      $A6,    $88,    $89,    $BB,    $53,    $4D
;                        db      $6D,    $D9,    $F0,    $99,    $BA,    $9E
;                        db      $4A,    $A8,    $89,    $47,    $DF,    $33
;            
;DEBUGUBNKDATA:          db      $ED,    $05,    $00,    $FE,    $00,    $FE,    $F1,    $0A,    $00
;DEBUGROTMATDATA:        db      $1B,    $33,    $DE,    $B4,    $ED,    $C5
;                        db      $73,    $C4,    $BC,    $1E,    $96,    $C4
;                        db      $55,    $B9,    $35,    $D1,    $80,    $0F
; top left off right issue
;DEBUGUBNKDATA:          db      $39,    $01,    $00,    $43,    $01,    $00,    $2F,    $03,    $00
;DEBUGROTMATDATA:        db      $FD,    $50,    $47,    $B0,    $53,    $9A
;                        db      $73,    $B7,    $98,    $C8,    $80,    $A3
;                        db      $E6,    $01,    $81,    $AD,    $B0,    $55
; test middle of screen
;DEBUGUBNKDATA:          db      $00,    $00,    $00,    $00,    $00,    $00,    $20,    $01,    $00
;          
;DEBUGROTMATDATA:        db      $FD,    $50,    $47,    $B0,    $53,    $9A
;                        db      $73,    $B7,    $98,    $C8,    $80,    $A3
;                        db      $E6,    $01,    $81,    $AD,    $B0,    $55
; test middle of screen futher away
;DEBUGUBNKDATA:          db      $00,    $00,    $00,    $00,    $00,    $00,    $20,    $02,    $00
;          
;DEBUGROTMATDATA:        db      $FD,    $50,    $47,    $B0,    $53,    $9A
;                        db      $73,    $B7,    $98,    $C8,    $80,    $A3
;                        db      $E6,    $01,    $81,    $AD,    $B0,    $55

; Test left center clip still warping
;DEBUGUBNKDATA:          db      $80,    $00,    $80,    $00,    $00,    $00,    $20,    $01,    $00
;          
;DEBUGROTMATDATA:        db      $FD,    $50,    $47,    $B0,    $53,    $9A
;                        db      $73,    $B7,    $98,    $C8,    $80,    $A3
;                        db      $E6,    $01,    $81,    $AD,    $B0,    $55
; Test right center clip - seems to be warping values towards bottom of screen on clip
;DEBUGUBNKDATA:          db      $80,    $00,    $00,    $00,    $00,    $00,    $20,    $01,    $00
;          
;DEBUGROTMATDATA:        db      $FD,    $50,    $47,    $B0,    $53,    $9A
;                        db      $73,    $B7,    $98,    $C8,    $80,    $A3
;                        db      $E6,    $01,    $81,    $AD,    $B0,    $55
; Test top center clip test 1 - good test many ships fail
;DEBUGUBNKDATA:          db      $19,    $00,    $00,    $50,    $00,    $00,    $20,    $01,    $00
;          
;DEBUGROTMATDATA:        db      $FD,    $50,    $47,    $B0,    $53,    $9A
;                        db      $73,    $B7,    $98,    $C8,    $80,    $A3
;                        db      $E6,    $01,    $81,    $AD,    $B0,    $55
; Test top center clip test 2 - Poss 2nd ship has an issue with a small line
;DEBUGUBNKDATA:          db      $19,    $00,    $00,    $60,    $00,    $00,    $2F,    $01,    $00
;          
;DEBUGROTMATDATA:        db      $FD,    $50,    $47,    $B0,    $53,    $9A
;                        db      $73,    $B7,    $98,    $C8,    $80,    $A3
;                        db      $E6,    $01,    $81,    $AD,    $B0,    $55
; Test bottom center clip ; complet shambles as if its forcing cip to below 128
; looks better now may have some clipping issues maybe ship data
;DEBUGUBNKDATA:          db      $19,    $00,    $00,    $50,    $00,    $80,    $20,    $01,    $00
;          
;DEBUGROTMATDATA:        db      $FD,    $50,    $47,    $B0,    $53,    $9A
;                        db      $73,    $B7,    $98,    $C8,    $80,    $A3
                        db      $E6,    $01,    $81,    $AD,    $B0,    $55
; Test left top center clip

; Test right top center clip
; Test left bottom center clip
; Test right bottom center clip

; Tests with no clip
;DEBUGUBNKDATA:          db      $39,    $00,    $00,    $43,    $00,    $00,    $2F,    $04,    $00
;          
;DEBUGROTMATDATA:        db      $FD,    $50,    $47,    $B0,    $53,    $9A
;                        db      $73,    $B7,    $98,    $C8,    $80,    $A3
;                        db      $E6,    $01,    $81,    $AD,    $B0,    $55
;
;DEBUGUBNKDATA:          db      $00,    $00,    $00,    $00,    $00,    $00,    $1F,    $00,    $00
;      
; UBNKPOs example 39,01,00,43,01,00,f4,03,00
; rotmat  example b1, 83,ae,5d,b0,1a,5e,de,82,8a,69,16,70,99,52,19,dd,d9
