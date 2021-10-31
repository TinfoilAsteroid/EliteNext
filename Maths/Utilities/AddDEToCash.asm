; Note its big endian
addDEtoCash:            ld      hl,(Cash)
                        add     hl,de
                        ld      (Cash),hl
                        ld      de,0
                        ld      hl,(Cash+2)
                        adc     hl,de
                        ld      (Cash+2),hl
                        ret

subDEfromCash:          ld      hl,(Cash)
                        ld      a,h
                        or      l
                        ld      hl,(Cash+2)
                        or      h
                        or      l
                        ret     z               ; No cash return
                        or      a
                        ld      hl,(Cash)
                        sbc     hl,de
                        ld      (Cash),hl
                        ld      de,0
                        ld      hl,(Cash+2)
                        sbc     hl,de
                        ld      (Cash+2),hl
                        JumpOnBitSet h,7,.ZeroCash
                        ret
.ZeroCash:              ld      hl,0
                        ld      (Cash),hl
                        ld      (Cash+2),hl
                        ret
                        