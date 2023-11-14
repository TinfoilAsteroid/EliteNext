
; ......................................................   
GetExperiencePointsMacro: MACRO prefix1?
prefix1?_GetExperiencePoints:    ; TODO calculate experience points
                        ; TODO mission updates check
                        ret


KillShipMacro:          MACRO   prefix1?
prefix1?_KillShip:      ld      a,(prefix1?_ShipTypeAddr)    ; we can't destroy stations in a collision
                        cp      ShipTypeStation             ; for destructable one we will have a special type of ship
                        ret     z
                        ld      a,(prefix1?_BnKaiatkecm)    ; remove AI, mark killed, mark exploding
                        or      ShipExploding | ShipKilled  ; .
                        and     ShipAIDisabled              ; .
                        ld      (prefix1?_BnKaiatkecm),a            ; .
                        SetMemToN   prefix1?_BnKexplDsp, ShipExplosionDuration ; set debris cloud timer, also usered in main to remove from slots
                        ldWriteZero prefix1?_BnKEnergy              ; Zero ship energy
                        ld      (prefix1?_BnKCloudRadius),a
                        ld      a,18
                        ld      (prefix1?_BnKCloudCounter),a        ; Zero cloud
                        ; TODO logic to spawn cargo/plates goes here
                        ret
                        
; in a = damage                        
DamageShipMacro:        MACRO   prefix1?
prefix1?_DamageShip:    ld      b,a                         ; b = a = damage comming in
                        ld      a,(prefix1?_ShipTypeAddr)   ; we can't destroy stations in a collision
                        cp      ShipTypeStation             ; for destructable one we will have a special type of ship
                        ret     z
                        ld      a,(prefix1?_BnKEnergy)      ; get current energy level
                        ClearCarryFlag
                        sbc     a,b                         ; subtract damage
.Overkilled:            jp      nc,.DoneDamage              ; if no carry then its not gone negative
                        call    prefix1?_KillShip           ; else kill it
                        ret
.DoneDamage:            ld      (prefix1?_BnKEnergy),a
                        ret