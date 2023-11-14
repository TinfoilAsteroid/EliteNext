SetEnemyMissileMacro:       MACRO p?
p?_SetEnemyMissile:   ld      hl,p?_NewLaunch_BnkX             ; Copy launch ship matrix
                        ld      de,p?Bnkxlo                    ; 
                        ld      bc,NewLaunchDataBlockSize       ; positon + 3 rows of 3 bytes
                        ldir                                    ; 
.SetUpSpeed:            ld      a,3                             ; set accelleration
                        ld      (p?_BnkAccel),a                   ;
                        ZeroA
                        ld      (p?_BnkRotXCounter),a
                        ld      (p?_BnkRotZCounter),a
                        ld      a,3                             ; these are max roll and pitch rates for later
                        ld      (p?_BnkRAT),a
                        inc     a
                        ld      (p?_BnkRAT2),a
                        ld      a,22
                        ld      (p?_BnkCNT2),a
                        MaxUnivSpeed                            ; and immediatley full speed (for now at least) TODO
                        SetMemFalse p?_BnkMissleHitToProcess
                        ld      a,ShipAIEnabled
                        ld      (p?_Bnkaiatkecm),a
                        call    p?_SetShipHostile
.SetupPayload:          ld      a,150
                        ld      (p?_BnkMissileBlastDamage),a
                        ld      (p?_BnkMissileDetonateDamage),a
                        ld      a,5
                        ld      (p?_BnkMissileBlastRange),a
                        ld      (p?_BnkMissileDetonateRange),a
                        ret
                        ENDM
