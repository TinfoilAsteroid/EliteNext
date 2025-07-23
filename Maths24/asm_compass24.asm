; Updates compass based on vertex positions in IX
; IX structure is3 x 24 bit (x, y, z) followed by two 16t bit Compass X, Y
; compas range is +-14 so we scale to +-16 and if result (or result + 1) has bit 5 set then clamp to 14 +-
; Compass position is based on the normals for position relative to player scaled to +/- 16

; For Normal to compass we take the leading sign Normal in BC as the basis
; as its not 2's compliment. The result is a 

; When written to compass position its a 2's compliment +/- 15
; Takes bc = Normal and returns HL with 2's compliment offset +/-15

NormalToCompassSigned:  ld      a,c
                        swapnib
                        and     $0F
                        bit     7,b
                        jp      nz,.NormalNegative
.NormalPositive:        ld      h,0
                        ld      l,a
                        ret
.NormalNegative:        neg
                        ld      h,$FF
                        ld      l,a
                        ret                   

UpdateCompassIX:        SetBCToNormX
                        call    NormalToCompassSigned
                        SetCompassXToHL
                        SetBCToNormY
                        call    NormalToCompassSigned
                        SetCompassYToHL
                        ret
                        