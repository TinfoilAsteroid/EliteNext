


FileWork                DS 10
FileNumber:             DB  0

Filename                DB "NESpr"
FileNbr                 DB "00"
Extension:              DB ".dat",0


FileNbrA:               ld      a,(FileNumber)
                        swapnib
                        and     %00001111
                        ld      b,"0"
                        add     b
                        ld      (FileNbr),a
                        ld      a,(FileNumber)
                        and     %00001111
                        add     b
                        ld      (FileNbr+1),a
                        ret

load_pattern_files:     ld          bc,SPRITE_SLOT_PORT             ; select pattern 0
                        ZeroA                                       ;
                        out         (c),a
                        ld          a,$01
                        ld          (FileNumber),a
                        ld          b,29
.ReadLoop:              push        bc
                        call        FileNbrA
                        call        load_a_pattern
                        ld          a,(FileNumber)
                        inc         a
                        daa 
                        ld          (FileNumber),a
                        pop         bc
                        djnz        .ReadLoop
                        ret
                                     ; write byte 256

load_a_pattern:         ld          hl,Filename
                        ld          ix,SpriteDatabuffer
                        ld          bc,256
                        call        FileLoad
                        ld          e,255
.streamPattern:         ld          bc, SPRITE_PATTERN_UPLOAD_PORT
                        ld          hl, SpriteDatabuffer
.streamPatternLoop:     outinb                                      ; write byte of pattern
                        dec         e
                        jr          nz, .streamPatternLoop          ; carry on writing for "e" iterations
                        outinb                         
                        ret
                        
SpriteDatabuffer:       DS  256
    

