;-Camera Position of Ship----------------------------------------------------------------------------------------------------------
;--NOTE POSTITION AND MATRIX are loaded by a single LDIR in cases so must be contiguous
StartOfShipRuntimeData      EQU $
UBnkxlo                     DB  0                       ; INWK+0
UBnkxhi                     DB  0                       ; there are hi medium low as some times these are 24 bit
UBnkxsgn                    DB  0                       ; INWK+2
UBnkylo                     DB  0                       ; INWK+3 \ ylo
UBnkyhi                     DB  0                       ; INWK+4 \ yHi
UBnkysgn                    DB  0                       ; INWK +5
UBnkzlo                     DB  0                       ; INWK +6
UBnkzhi                     DB  0                       ; INWK +7
UBnkzsgn                    DB  0                       ; INWK +8
;-Rotation Matrix of Ship----------------------------------------------------------------------------------------------------------
; Rotation data is stored as lohi, but only 15 bits with 16th bit being  a sign bit. Note this is NOT 2'c compliment
; Note they seem to have to be after camera position not quite found why yet, can only assume it does an iy or ix indexed copy? Bu oddly does not affect space station.
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
UBnkMissileBlastRange:      DB  0                       ; copied in when setting up a missile
UBnkMissileBlastDamage:     DB  0                       ; copied in when setting up a missile
UBnkMissileDetonateRange:   DB  0                       ; copied in when setting up a missile, allows for proximity missiles
UBnkMissileDetonateDamage:  DB  0                       ; copied in when setting up a missile
; -- Metadata for ship to help with bank managment
UBnkStartOfRuntimeData:
UBnkSlotNumber              DB  0
UBnkShipUnivBankNbr         DB  0                       ; Present ship universe bank number
UBnkShipModelBank           DB  0                       ; Bank nbr ship was from
UBnkShipModelNbr            DB  0                       ; Ship Id with in the bank
UBnkShipModelId             DB  0                       ; Absolute ship id
; -- Ship AI data
UBnkMissleHitToProcess      DB  0                       ; This is used for enquing missle blasts as we can only do one missile at a time, could make it multi but neeed to smooth CPU usage
UBnkMissileTarget           DB  0                       ; This is the ship slot number for the target from 0 to n if the missile is not hostile to us, if the target is $FF then its us
UBnkSpeed                   DB  0                       ; INWK +27
UBnkAccel                   DB  0                       ; INWK +28
UBnkRotXCounter             DB  0                       ; INWK +29
UBnkRotYCounter             DB  0                       ; INWK +29
UBnkRotZCounter             DB  0                       ; INWK +30
UBnkRAT                     DB  0                       ; temporary for rotation magnitude or roll counter, for debugging state
UBnkRAT2                    DB  0                       ; temporary for rotation threshold
UBnkCNT                     DB  0                       ; temp for calculating roll and pitch
UBnkCNT2                    DB  0                       ; roll threshold, max angle boynd ship will slow down
univRAT                     DB  0               ; 99
univRAT2                    DB  0               ; 9A
univRAT2Val                 DB  0               ; 9A
UBnkexplDsp                 DB  0                       ; INWK +31 clear exploding/display state|missiles
UBnkDrawAllFaces            DB  0
UBnkShipAggression          DB  0                       ; calculated agression factor
UBnkaiatkecm                DB  0                       ; INWK +32 ai_attack_univ_ecm i.e. AI type
UBnkSpawnObject             DB  0
UBnkCam0yLo                 DB  0                       ; INWK +33 ????
UBnkCam0yHi                 DB  0                       ; INWK +34?????
UBnkEnergy                  DB  0                       ; INWK +35
UBnkECMCountDown            DB  0                       ; counts down ECM usage if activated reducing energy too in update loop
UBnkECMFitted               DB  0                       ; Does ship have ECM, true false
UBnkLaserPower              DB  0                       ; Type of laser fitted
UBnkMissilesLeft            DB  0
UBnkFighterShipId           DB  0                       ; computed ship Id for any carriers
UBnkFightersLeft            DB  0                       ; the number of ships left in hanger, 255 = infinite
UBnkCloudCounter            DB  0                       ; cloud pixels
UBnkCloudRadius             DB  0                       ; cloud pixels
UBnkRuntimeSize             EQU $-UBnkStartOfRuntimeData
; Flags work as follows:
; UBnkSpawnObject - signals on death to spawn cargo items
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
; 4 -                   Ship marked as exploded, cleared once aknowledged then bit 5 takes over and UBnkCloudCounter
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

