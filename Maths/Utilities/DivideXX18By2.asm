
DivideXX18By2:          ld      hl,UBnkDrawCam0xLo
                        srl     (hl)                        ; XX18  \ xnormal lo/2 \ LL93+3 \ counter X
                        inc     hl                          ; looking at XX18 x sign now
                        inc     hl                          ; looking at XX18 y Lo now
                        srl     (hl)                        ; XX18+2    \ ynormal lo/2
                        inc     hl                          ; looking at XX18 y sign now
                        inc     hl                          ; looking at XX18 z Lo now
                        srl     (hl)
                        ret
