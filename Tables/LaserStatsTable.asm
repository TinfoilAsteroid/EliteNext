; LaserTypeTable
; laser type = id of laser
; laser pulse pause = time before next pulse
; laser pulse duration = time laser is on per shot
; laser damage output
;
; LaserType                
; LaserPulseRate                          ; how many pulses can be fired before long pause
; LaserPulsePause                         ; time before next pulse - 0 = beam
; LaserPulseOnTime                        ; cycles laser is on for
; LaserPulseOffTime                       ; cycles laser is off for
; LaserPulseRest                          ; time before pulse count resets to 0 (i.e cooldown)
; LaserDamageOutput                       ; amount of damage for a laser hit
; LaserEnergyDrain                        ; amount of energy drained by cycle
; LaserHeat                               ; amount of heat generated
; LaserDurability                         ; probabability out of 255 that a hit on unshielded will add random amount of damage
; LaserDurabilityAmount                   ; max amount of damagage can be sustained in one damage hit
; LaserInMarkets                          ; can this laser be purchased 0 = yes 1 = no
; LaserTechLevel                          ; minimum tech level system to buy from
;
;                          Typ  Rate On   Off  Rst  Dam  Drn  Het  Dur  DAt  Mrk  Tek
LaserStatsTable:        DB $01, $01, $05, $20, $10, $03, $10, $02, $20 ,$10 ,$00, $00; basic laser
                        DB $02, $01, $03, $05, $0A, $03, $10, $08, $20 ,$10 ,$00, $01; pulse laser
                        DB $03, $03, $05, $03, $0A, $03, $10, $02, $20 ,$10 ,$00, $02; burst laser
                        DB $04, $10, $02, $02, $05, $02, $10, $05, $30 ,$10 ,$00, $03; Gatling laser
                        DB $05, $00, $01, $00, $03, $03, $03, $10, $20 ,$10 ,$00, $04; beam
                        DB $06, $01, $20, $30, $60, $03, $02, $02, $20 ,$10 ,$00, $05; mining
                        DB $07, $00, $01, $00, $06, $05, $05, $05, $10 ,$10 ,$00, $08; military beam
                        DB $08, $01, $01, $02, $20, $02, $01, $30, $30 ,$11 ,$01, $10; thargoid
                        DB $09, $01, $30, $80, $80, $40, $02, $03, $60 ,$11 ,$01, $10; Starkiller

    






