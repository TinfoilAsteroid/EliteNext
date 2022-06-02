;;;sprite_load_sprite_data:ld			bc, SPRITE_SLOT_PORT; SPRITE_SLOT_PORT
;;;                        xor			a                               ; start with pattern 0
;;;                        out			(c),a							; Prime slot upload
;;;                        ld			de,26	* 256						; nbr of sprites to upload	
;;;                        ld			hl,Sprite1						; sprites are stored contiguous
;;;SpriteLoadLoop:	        ld			bc, $5b; SPRITE_PATTERN_UPLOAD_PORT
;;;                        outinb											; do final 256th sprite
;;;                        dec			de
;;;                        ld			a,d
;;;                        or			e
;;;                        jr			nz,SpriteLoadLoop				; keep on rolling through sprites
;;;                        ret

stream_sprite_data:     ld          bc,SPRITE_SLOT_PORT             ; select pattern 0
                        ZeroA                                       ;
                        out         (c),a
.OpenOutputFile:        ld          ix, SpriteFilename
                        ld          b, FA_READ
                        call        fOpen
                        cp          0
                        jr          z,.OpenFailed
                        push        af
                        ld          d,29
.streamLoop:            push        de
                        ld          ix, SpriteDatabuffer
                        ld          bc,256
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
.CloseFile:             pop         af
                        call        fClose
                        cp          0
                        jr          z, .CloseFailed
                        ret
                        
.OpenFailed:            ld          a,-1
                        jp          .OpenFailed
.CloseFailed:           ld          a,-3
                        jp          .CloseFailed                                
.ReadFailed:            ld          a,-1
                        jp          .ReadFailed
SpriteFilename:         DB "NextSprt.dat",0
SpriteDatabuffer:       DS  256