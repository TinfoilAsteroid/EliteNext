;-Camera Position of Ship----------------------------------------------------------------------------------------------------------
;--NOTE POSTITION AND MATRIX are loaded by a single LDIR in cases so must be contiguous
StartOfShipRuntimeData      EQU $
UBnKxlo                     DB  0                       ; INWK+0
UBnKxhi                     DB  0                       ; there are hi medium low as some times these are 24 bit
UBnKxsgn                    DB  0                       ; INWK+2
UBnKylo                     DB  0                       ; INWK+3 \ ylo
UBnKyhi                     DB  0                       ; INWK+4 \ yHi
UBnKysgn                    DB  0                       ; INWK +5
UBnKzlo                     DB  0                       ; INWK +6
UBnKzhi                     DB  0                       ; INWK +7
UBnKzsgn                    DB  0                       ; INWK +8
UBnkCompassX                DW  0                       ; Compass offset
UBnkCompassY                DW  0                       ; Compass offset
UBnkRadarX                  DW  0                       ; Radar offset
UBnkRadarY                  DW  0                       ; Radar offset
UBnkNormalX96               DW  0                       ; INWK +20 Normalised Position
UBnKNormalY96               DW  0                       ; INWK +22 Normalised Position
UBnkNormalZ96               DW  0                       ; INWK +24 Normalised Position
UBnkNormalX                 DW  0                       ; INWK +26 Normalised Position
UBnKNormalY                 DW  0                       ; INWK +28 Normalised Position
UBnkNormalZ                 DW  0                       ; INWK +30 Normalised Position
;-Rotation Matrix of Ship----------------------------------------------------------------------------------------------------------
; Rotation data is stored as lohi, but only 15 bits with 16th bit being  a sign bit. Note this is NOT 2'c compliment
; Note they seem to have to be after camera position not quite found why yet, can only assume it does an iy or ix indexed copy? Bu oddly does not affect space station.
UBnkTidyCounter             DB  0                       ; every 16 iterations the rotation matrix is normalised
UBnkrotmatSidevX            DW  0                       ; INWK +21
UBnkrotmatSidev             equ UBnkrotmatSidevX
UBnkrotmatSidevY            DW  0                       ; INWK +23
UBnkrotmatSidevZ            DW  0                       ; INWK +25
UBnkrotmatRoofvX            DW  0                       ; INWK +15
UBnkrotmatRoofv             equ UBnkrotmatRoofvX
UBnkrotmatRoofvY            DW  0                       ; INWK +17
UBnkrotmatRoofvZ            DW  0                       ; INWK +19
UBnkrotmatNosevX            DW  0                       ; INWK +9
UBnkrotmatNosev             EQU UBnkrotmatNosevX
UBnkrotmatNosevY            DW  0                       ; INWK +11
UBnkrotmatNosevZ            DW  0                       ; INWK +13
; -- Note these must be here for initialise blast as it does a 12 byte ldir
; . Note missile explosion will have to have logic to cause linger if a blast is to be enqued
UBnKMissileBlastRange:      DB  0                       ; copied in when setting up a missile
UBnKMissileBlastDamage:     DB  0                       ; copied in when setting up a missile
UBnKMissileDetonateRange:   DB  0                       ; copied in when setting up a missile, allows for proximity missiles
UBnKMissileDetonateDamage:  DB  0                       ; copied in when setting up a missile
; -- Metadata for ship to help with bank managment
UBnKStartOfRuntimeData:
UBnKSlotNumber              DB  0
UbnKShipUnivBankNbr         DB  0                       ; Present ship universe bank number
UBnkShipModelBank           DB  0                       ; Bank nbr ship was from
UBnKShipModelNbr            DB  0                       ; Ship Id with in the bank
UBnKShipModelId             DB  0                       ; Absolute ship id
; -- Ship AI data
; -- Targetting runtime data
UBnKMissleHitToProcess      DB  0                       ; This is used for enquing missle blasts as we can only do one missile at a time, could make it multi but neeed to smooth CPU usage
UBnKMissileTarget           DB  0                       ; This is the ship slot number for the target from 0 to n if the missile is not hostile to us, if the target is $FF then its us
UBnKTargetXPos              DS  3                       ; target position for AI 
UBnKTargetYPos              DS  3                       ; .
UBnKTargetZPos              DS  3                       ; .
UBnKTargetXPosSgn           DS  1                       ; target position sign for AI 
UBnKTargetYPosSgn           DS  1                       ; .
UBnKTargetZPosSgn           DS  1                       ; .
UBnKTargetVectorX           DS  2                       ; target vector for AI
UBnKTargetVectorY           DS  2                       ; .
UBnKTargetVectorZ           DS  2                       ; .
UBnKTargetDotProduct1       DS  2
UBnKTargetDotProduct2       DS  2
UBnKTargetDotProduct3       DS  2
UBnKTacticsRotMatX          DB  0
UBnKTacticsRotMatXSign      DB  0
UBnKTacticsRotMatY          DB  0
UBnKTacticsRotMatYSign      DB  0
UBnKTacticsRotMatZ          DB  0
UBnKTacticsRotMatZSign      DB  0
UBnKOffset                  DS  3 * 3                   ; Offset position for target
UBnKOffsetX                 equ UBnKOffset
UBnKOffsetXHi               equ UBnKOffsetX+1
UBnKOffsetXSign             equ UBnKOffsetX+2
UBnKOffsetY                 equ UBnKOffset+3
UBnKOffsetYHi               equ UBnKOffsetY+1
UBnKOffsetYSign             equ UBnKOffsetY+2
UBnKOffsetZ                 equ UBnKOffset+6
UBnKOffsetZHi               equ UBnKOffsetZ+1
UBnKOffsetZSign             equ UBnKOffsetZ+2
UBnKDirectionX              DB  0
UBnKDirectionXHi            DB  0 
UBnKDirectionXSign          DB  0
UBnKDirectionY              DB  0
UBnKDirectionYHi            DB  0 
UBnKDirectionYSign          DB  0
UBnKDirectionZ              DB  0
UBnKDirectionZHi            DB  0 
UBnKDirectionZSign          DB  0
UBnKDirNormX                DB  0
UBnKDirNormXSign            DB  0
UBnKDirNormY                DB  0
UBnKDirNormYSign            DB  0
UBnKDirNormZ                DB  0
UBnKDirNormZSign            DB  0
UBnKDirection               equ UBnKDirectionX          ; Direction Vector
UBnKDotProductNose          DW  0                       ; Dot Product
UBnKDotProductNoseSign      DB  0
UBnKDotProductRoof          DW  0                       ; Dot Product
UBnKDotProductRoofSign      DB  0
UBnKDotProductSide          DW  0                       ; Dot Product
UBnKDotProductSideSign      DB  0
UBnKSpeed                   DB  0                       ; INWK +27
UBnKAccel                   DB  0                       ; INWK +28
UBnKRotXCounter             DB  0                       ; INWK +29
UBnKRollCounter             equ UBnKRotXCounter         ; change over to this in code
UBnKRotZCounter             DB  0                       ; INWK +30
UBnKPitchCounter            equ UBnKRotZCounter
UBnKRAT                     DB  0                       ; temporary for rotation magnitude or roll counter, for debugging state
UBnKRAT2                    DB  0                       ; temporary for rotation threshold
UBnKCNT                     DB  0                       ; temp for calculating roll and pitch
UBnKCNT2                    DB  0                       ; roll threshold, max angle boynd ship will slow down
univRAT                     DB  0               ; 99
univRAT2                    DB  0               ; 9A
univRAT2Val                 DB  0               ; 9A
UBnKexplDsp                 DB  0                       ; INWK +31 clear exploding/display state|missiles
UBnkDrawAllFaces            DB  0
UBnKShipAggression          DB  0                       ; calculated agression factor
UBnkaiatkecm                DB  0                       ; INWK +32 ai_attack_univ_ecm i.e. AI type
UBnKSpawnObject             DB  0
UBnkCam0yLo                 DB  0                       ; INWK +33 ????
UBnkCam0yHi                 DB  0                       ; INWK +34?????
UBnKEnergy                  DB  0                       ; INWK +35
UBnKECMCountDown            DB  0                       ; counts down ECM usage if activated reducing energy too in update loop
UBnKECMFitted               DB  0                       ; Does ship have ECM, true false
UBnKLaserPower              DB  0                       ; Type of laser fitted
UBnKMissilesLeft            DB  0
UBnKFighterShipId           DB  0                       ; computed ship Id for any carriers
UBnKFightersLeft            DB  0                       ; the number of ships left in hanger, 255 = infinite
UBnKCloudCounter            DB  0                       ; cloud pixels
UBnKCloudRadius             DB  0                       ; cloud pixels
UBnKHeadingToPlanetOrSun    DB  0                       ; 0 = undefined 1 = heading to planet 2 = heading to sun, if it reaches planet then will move to docking, if it heads to sun then will jump

UBnKRuntimeSize             EQU $-UBnKStartOfRuntimeData
; Flags work as follows:
; UBnKSpawnObject - signals on death to spawn cargo items
; 0 -                   Spawn Cargo 1
; 1 -                   Spawn Cargo 2
; 2 -                   Spawn Cargo 3
; 3 -                   Spawn Cargo 4
; 4 -                   Spawn Alloy 1
; 5 -                   Spawn Alloy 2
; 6 -                   Spawn Alloy 3
; 7 -                   Spawn Alloy 4

; UBnkaiatkecm 
; Bit	                Description
; 7 -                   AI Enabled Flag
; 6 -                   Ship Visible = ShipOnScreen/NotCloaked (cleared or set by check visible or cloaking override)
; 5 -                   Ship is exploding if set, note if its a missile and one already equeued this will have to linger
;                       linger can be done by not erasing ship unit missile equeue handled
; 4 -                   Ship marked as exploded, cleared once aknowledged then bit 5 takes over and UBnKCloudCounter
; 3 -                   Display state - Plot as a Dot
; 2 -                   Nbr of Missiles bit 2
; 1 -                   Nbr of Missiles bit 1
; 0 -                   ECM present flag
; ShipNewBitsAddr (in blueprint)
;Bit	                Description
;#0	Trader flag         * 0 = not a trader  * 1 = trader
;                       80% of traders are peaceful and mind their own business plying their trade between the planet and space station, but 20% of them moonlight as bounty hunters (see bit #1)
;                       Ships that are traders: Escape pod, Shuttle, Transporter, Anaconda, Rock hermit, Worm
;#1 Bounty hunter flag  * 0 = not a bounty hunter* 1 = bounty hunter
;                       If we are a fugitive or a serious offender and we bump into a bounty hunter, they will become hostile and attack us (see bit #2)
;                       Ships that are bounty hunters: Viper, Fer-de-lance
;#2	Hostile flag        * 0 = not hostile  * 1 = hostile
;                       Hostile ships will attack us on sight; there are quite a few of them
;                       Ships that are hostile: Sidewinder, Mamba, Krait, Adder, Gecko, Cobra Mk I, Worm, Cobra Mk III, Asp Mk II, Python (pirate), Moray, Thargoid, Thargon, Constrictor
;#3	Pirate flag         * 0 = not a pirate * 1 = pirate
;                       Hostile pirates will attack us on sight, but once we get inside the space station safe zone, they will stop
;                       Ships that are pirates: Sidewinder, Mamba, Krait, Adder, Gecko, Cobra Mk I, Cobra Mk III, Asp Mk II, Python (pirate), Moray, Thargoid
;#4	Docking flag        * 0 = not docking * 1 = docking
;                       Traders with their docking flag set fly towards the space station to try to dock, otherwise they aim for the planet
;                       This flag is randomly set for traders when they are spawned
;                       Ships that can be docking: Escape pod, Shuttle, Transporter, Anaconda, Rock hermit, Worm
;#5	Innocent bystander  * 0 = normal * 1 = innocent bystander
;                       If we attack an innocent ship within the space station safe zone, then the station will get angry with us and start spawning cops
;                       Ships that are innocent bystanders: Shuttle, Transporter, Cobra Mk III, Python, Boa, Anaconda, Rock hermit, Cougar
;#6	Cop flag            * 0 = not a cop * 1 = cop
;                       If we destroy a cop, then we instantly become a fugitive (the Transporter isn't actually a cop, but it's clearly under police protection)
;                       Ships that are cops: Viper, Transporter
;#7	Scooped, docked, escape pod flag
;                       For spawned ships, this flag indicates that the ship been scooped or has docked (bit 7 is always clear on spawning)
;                       For blueprints, this flag indicates whether the ship type has an escape pod fitted, so it can launch it when in dire straits
;                       Ships that have escape pods: Cobra Mk III, Python, Boa, Anaconda, Rock hermit, Viper, Mamba, Krait, Adder, Cobra Mk I, Cobra Mk III (pirate), Asp Mk II, Python (pirate), Fer-de-lance

