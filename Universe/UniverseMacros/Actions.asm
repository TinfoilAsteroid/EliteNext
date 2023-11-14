
; ......................................................   
GetExperiencePointsMacro: MACRO p?
p?_GetExperiencePoints:    ; TODO calculate experience points
                        ; TODO mission updates check
                        ret


KillShipMacro:          MACRO   p?
p?_KillShip:      ld      a,(p?_ShipTypeAddr)    ; we can't destroy stations in a collision
                        cp      ShipTypeStation             ; for destructable one we will have a special type of ship
                        ret     z
                        ld      a,(p?_Bnkaiatkecm)    ; remove AI, mark killed, mark exploding
                        or      ShipExploding | ShipKilled  ; .
                        and     ShipAIDisabled              ; .
                        ld      (p?_Bnkaiatkecm),a            ; .
                        SetMemToN   p?_BnkexplDsp, ShipExplosionDuration ; set debris cloud timer, also usered in main to remove from slots
                        ldWriteZero p?_BnkEnergy              ; Zero ship energy
                        ld      (p?_BnkCloudRadius),a
                        ld      a,18
                        ld      (p?_BnkCloudCounter),a        ; Zero cloud
                        ; TODO logic to spawn cargo/plates goes here
                        ret
                        
; in a = damage                        
DamageShipMacro:        MACRO   p?
p?_DamageShip:    ld      b,a                         ; b = a = damage comming in
                        ld      a,(p?_ShipTypeAddr)   ; we can't destroy stations in a collision
                        cp      ShipTypeStation             ; for destructable one we will have a special type of ship
                        ret     z
                        ld      a,(p?_BnkEnergy)      ; get current energy level
                        ClearCarryFlag
                        sbc     a,b                         ; subtract damage
.Overkilled:            jp      nc,.DoneDamage              ; if no carry then its not gone negative
                        call    p?_KillShip           ; else kill it
                        ret
.DoneDamage:            ld      (p?_BnkEnergy),a
                        ret
                        ENDM