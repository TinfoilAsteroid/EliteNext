; LaserTypeTable
; laser type = id of laser
; laser pulse pause = time before next pulse
; laser pulse duration = time laser is on per shot
; laser damage output
;
; LaserType                
; LaserPulseRate                          ; how many pulses can be fired before long pause
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
LaserStatsTableWidth    EQU 12
;                           0    1    2    3    4    5    6    7    8    9   10   11
;                          Typ  Rate On   Off  Rst  Dam  Drn  Het  Dur  DAt  Mrk  Tek
LaserStatsTable:        DB $00, $02, $05, $20, $40, $03, $10, $02, $20 ,$10 ,$00, $00; basic laser
                        DB $01, $01, $08, $08, $20, $03, $10, $08, $20 ,$10 ,$00, $01; pulse laser
                        DB $02, $03, $06, $06, $3A, $03, $05, $02, $20 ,$10 ,$00, $02; burst laser TODO THIS ONE IS ODD
                        DB $03, $01, $05, $05, $01, $02, $04, $05, $30 ,$10 ,$00, $03; Gatling laser
                        DB $04, $01, $01, $00, $00, $03, $03, $10, $20 ,$10 ,$00, $04; beam ; DOES NOT WORK
                        DB $05, $01, $20, $30, $60, $03, $02, $02, $20 ,$10 ,$00, $05; mining
                        DB $06, $00, $01, $00, $06, $05, $05, $05, $10 ,$10 ,$00, $08; military beam DOES NOT WORK
                        DB $07, $01, $01, $02, $20, $22, $01, $30, $30 ,$11 ,$01, $10; thargoid 
                        DB $08, $01, $05, $10, $80, $70, $02, $03, $60 ,$11 ,$01, $10; Starkiller







