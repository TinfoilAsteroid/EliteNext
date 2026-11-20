;..Process A ship..................................................................................................................
; Apply Damage b to ship based on shield value of a
; returns a with new shield value
ApplyDamage:            ClearCarryFlag
                        sbc     b
                        ret     nc                  ; no carry so was not negative
.KilledShield:          neg                         ; over hit shield
                        ld      c,a                 ; save overhit in c
                        ld      a,(PlayerEnergy)    ; and apply it to player energy
                        ClearCarryFlag
                        sbc     c
                        jr      nc,.DoneDamage      ; if result was 0 or more then completed damage (was jp p: energy over 127 always counted as dead)
.KilledPlayer:          xor     a
.DoneDamage:            ld      (PlayerEnergy),a
                        xor     a                   ; shield is gone
                        ret
