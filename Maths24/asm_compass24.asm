; Updates compass based on vertex positions in IX
; IX structure is3 x 24 bit (x, y, z) followed by two 16t bit Compass X, Y
; compas range is +-14 so we scale to +-16 and if result (or result + 1) has bit 5 set then clamp to 14 +-

ScaleCompass:           MACRO        
                        ld      l,h                 ; hl = result /256
                        ld      h,a                 ;
                        and     $80                 ; save sign bit
                        ld      c,a                 ; .
                        res     7,h                 ; clear sign before shifting
                        ex      de,hl               ; de = Compass X
                        ld      b,8                 ; shift assuming max of +- 4095 for result
                        bsrl    de,b                ; shift down to lower nibble
                        ld      a,e
                        and     $F0
                        jp      z,.NoTidy
                        cp      15
                        jp      nz,.NoTidy
                        ld      a,14                ; clamp to 14
.NoTidy:                or      c                   ; return sign bit
                        ENDM
                        
SetCompassXtoHL:        MACRO
                        ld      (ix+9),hl
                        ENDM

SetCompassYtoHL:        MACRO
                        ld      (ix+9),hl
                        ENDM
                        
UpdateCompassIX:        SetCDEtoZ
                        SetAHLtoX
                        call    divs24              ; AHL = result
                        ScaleCompass
                        SetCompassXtoHL
                        SetCDEtoZ
                        SetAHLToY
                        call    divs24
                        ScaleCompass
                        SetCompassYtoHL
                        ret

                        
                        