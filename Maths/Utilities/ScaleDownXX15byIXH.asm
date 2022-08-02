
ScaleDownXX15byIXH:     dec     ixh
                        ret     m
                        ld      hl,UBnkXScaled
                        srl     (hl)                        ; XX15  \ xnormal lo/2 \ LL93+3 \ counter X
                        inc     hl                          ; looking at XX15 x sign now
                        inc     hl                          ; looking at XX15 y Lo now
                        srl     (hl)                        ; XX15+2    \ ynormal lo/2
                        inc     hl                          ; looking at XX15 y sign now
                        inc     hl                          ; looking at XX15 z Lo now
                        srl     (hl)
                        jp      ScaleDownXX15byIXH
                        ret
