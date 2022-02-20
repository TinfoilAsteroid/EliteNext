;Ship Tactics
; used  when no pre-checks are requrired, e.g. if forcing a space station from main loop

ForceAngryDirect:       ld      hl,ShipNewBitsAddr                      
                        set     ShipIsHostile, (hl)
                        ret

; set angry if possible, if its an innocent then flag the space station to get angry
MakeAngry:              ld      a,(ShipNewBitsAddr)                     ; Check bit 5 of newb flags
                        ld      b,a                                     ; copy to b in case we want it later
                        JumpIfMemEqNusng ShipTypeAddr, ShipTypeStation, .SetNewbAngry
.ItsNotAStation:        and     ShipIsBystander                         ; check if space station present if its a bystander
                        call    nz, SetStationAngry                     ; Set Space Station if present, Angry
                        ld      a,(UBnkaiatkecm)                        ; get AI data
                        ReturnIfAIsZero                                 ; if 0 then no AI attached
                        or      ShipAIEnabled                           ; set AI Enabled set to ensure its set
                        ld      (UBnkaiatkecm),a                        ; .
                        ld      c,a                                     ; Copy to c in case we need it later
                        SetMemToN UBnKAccel, 2                          ; set accelleration to 2 to speed up
                        sla     a                                       ; set pitch to 4
                        ld      (UBnKRotZCounter),a                     ; .
                        ld      a,(ShipAIFlagsAddr)
                        ReturnIfBitMaskClear ShipCanAnger
.SetNewbAngry:          ld      a,b
                        or      ShipIsHostile
                        ld      (ShipNewBitsAddr),a
                        ret


SetStationAngry:        call    IsSpaceStationPresent                   ; only if present
                        ret     c
                        ld      a,(UbnKShipBankNbr)                     ; save current bank
                        ld      iyh,a
                        MMUSelectUniverseN 0                            ; space station is always 0
                        ld      a,(ShipNewBitsAddr)                     ; get station new bits
                        or      ShipIsHostile                           ; and mark hostile
                        ld      (ShipNewBitsAddr),a                     ; .
                        ld      a,iyh                                   ; get prev bank back
                        MMUSelectUniverseA                              ;
                        ret

CheckMissileBlastInit:  ZeroA
                        ld      (CurrentMissileCheck),a
                        ld      hl,UBnKxlo                      ; Copy Blast Coordinates
                        ld      bc,12                           ; and Damage stats
                        ld      de,MissileXPos
                        ldir
                        ZeroA                                   ; we have processd enque request
                        ld      (UBnKMissleHitToProcess),a      ; 
                        call    CheckIfBlastHitUs               ; If we are in Range
                        call    c, MissileDidHitUs              ; Then we get hit
                        ret
                        
CheckPointRange:        MACRO   ShipPos, ShipSign, MissilePos, MissileSign
                        ld      a,(MissilePos)                      ; check X Coord
                        ld      hl,(ShipSign)
                        xor     (hl)
                        and     SignOnly8Bit
                        ld      hl,(ShipPos)
                        ld      de,(MissilePos)
                        jr      z,.SignsDiffernt
.XSame:                 and     a
                        sbc     hl,de                               ; distance = Ship X - Missile X
                        JumpIfPositive      .CheckDiff              ; if result was -ve 
                        NegHL
                        jp      .CheckDiff
.SignsDiffernt:         add     hl,de
                        ReturnIfNegative                            ; if we overflowed then return
.CheckDiff:             ld      a,h                                 ; if we have an h outside blast raidus
                        ReturnIfANotZero
                        ld      a,l
                        and     a
                        ReturnIfAGTEMemusng   CurrentMissileBlastRange
                        ENDM
;...................................................................                        
; We only do one test per loop for spreading the load of work                        
CheckMissileBlastLoop:  ld      a,(CurrentMissileCheck)
                        ReturnIfAGTENusng   UniverseSlotListSize
                        ld      iyl,a
                        inc     a                                   ; update for next slot so re can fast return on distance checks
                        ld      (CurrentMissileCheck),a
                        ReturnIfSlotAEmpty
                        call    IsSpaceStationPresent               ; If its a station its imune to missiles
                        ret     c                                   ; if we have a special mission to kill a staion then its type won't be space station for game logic
                        ld      a,(UBnKexplDsp)                     ; Don't explode a ship twice
                        and     ShipExploding                       ;
                        ReturnIfNotZero                             ;
                        ld      a,(CurrentMissileBlastRange)
                        ld      iyh,a                               ; iyh = missile blast depending on type
.CheckRange:            ld      a,iyl                               ; now page in universe data
                        MMUSelectUniverseA      
                        CheckPointRange UBnKxlo, UBnKxsgn, MissileXPos, MissileXSgn  ; its a square but its good enough
                        CheckPointRange UBnKylo, UBnKysgn, MissileYPos, MissileYSgn
                        CheckPointRange UBnKzlo, UBnKzsgn, MissileZPos, MissileZSgn
                        call    ShipMissileBlast                    ; Ship hit by missile blast
                        ret                                         ; we are done
;...................................................................
CheckIfBlastHitUs:      ld      a,(UBnKMissileBlastRange)
                        ld      c,a
                        jp      MissileHitUsCheckPos
;...................................................................                        
CheckIfMissileHitUs:    ld      a,(UBnKMissileDetonateRange)
                        ld      c,a
;...................................................................
MissileHitUsCheckPos:   ld      hl, (UBnKxlo)
                        ZeroA
                        or      h
                        ClearCarryFlag
                        ReturnIfNotZero                             ; will return with carry clear if way far away
                        ld      a,l
                        ReturnIfAGTENusng    c                      ; return no carry if x far
.CheckY:                ld      hl,(UBnKylo)
                        ZeroA
                        or      l
                        ClearCarryFlag
                        ReturnIfNotZero                             ; will return with carry clear if way far away
                        ld      a,l
                        ReturnIfAGTENusng    c                      ; return no carry if y far
.CheckZ:                ld      hl,(UBnKzlo)
                        ZeroA
                        or      l
                        ClearCarryFlag
                        ReturnIfNotZero                             ; will return with carry clear if way far away
                        ld      a,l
                        ReturnIfAGTENusng    c                      ; return no carry if z far
.ItsAHit:               SetCarryFlag:                               ; So must have hit
                        ret
                        
;...................................................................                        
;... Now the tactics if current ship is the missile
MissileLogic:           ld      a,(UBnKMissleHitToProcess)
.IsMissleHitEnqued:     JumpIfTrue  .ProcessMissileHit
.CheckForECM:           JumpIFMemTrue   ECMActive,.ECMIsActive
.IsMissileHostile:      ld      a,(ShipNewBitsAddr)                 ; is missle attacking us?
                        and     ShipIsHostile
                        JumpIfNotZero .MissileTargetingShip
.MissileTargetingPlayer:ld      hl, (UBnKxlo)                       ; check if missile in range of us
                        ld      a,(UBnKMissileDetonateRange)
                        ld      c,a                                 ; c holds detonation range
                        call    MissileHitUsCheckPos
.MissileNotHitUsYet:    jp      nc, .UpdateTargetingUsPos
.MissleHitUs:           call    HitByMissile
                        jp      .ECMIsActive                        ; we use ECM logic to destroy missile which eqneues is
.MissileTargetingShip:  ld      a,(UBnKMissileTarget)
.IsMissleTargetGone:    JumpIfSlotAEmpty    .ECMIsActive            ; if the target was blown up then detonate
;... Note we don't have to check for impact as we already have a loop doing that
.SelectTargetShip:      ld      iyl,a
                        MMUSelectUniverseA
.IsShipExploding:       ld      a,(UBnkaiatkecm)
                        and     ShipExploding
                        jr      nz,.UpdateTargetingShipPos
.ShipIsExploding:       ld      a,iyl                               ; get missile back into memory
                        MMUSelectUniverseA
                        jp      .ECMIsActive
.UpdateTargetingShipPos:ld      hl,UBnKxlo                          ; get missile target pos top temp while 
                        ld      de,CurrentTargetXpos
                        ld      bc,3*3
                        ldir
                        ld a,iyl
.CalculateMissileVector:call    TacticsPosMinusTarget              ; calculate vector to target
;;TODO                        check range
;;TODO                        if target has ecm then 7% chance it will active, reduce target energy (i.e. damage)
;;TODO                        else
;;TODO                            normalise teh vector for direction
;;TODO                            dot product = missile nosev . normalised vector
;;TODO                            cnt = high byte of dot product, cnf is +ve if facing similar direction
;;TODO                            negate normalised vector so its opposite product
;;TODO                            invert sign of cnt
;;TODO                            AK = roovf . XX15
;;TODO                            Ships pitch = call nroll to caulate teh valu eof ships pitch counter
;;TODO                            if pitch * 2 < 32 then 
;;TODO                                ax = sidev . xx15
;;TODO                                    a = x xort current pitch direction
;;TODO                                    shipts roll = nroll 
;;TODO                            do accelleration at TA6 (    https://www.bbcelite.com/disc/flight/subroutine/tactics_part_7_of_7.html#ta20
                            
;;TODO                        
;;TODO                        
;;TODO
;;TODOget the targetted ship inbto bank
;;TODO                        check range as per player
;;TODO                        handle explosion enc

;                    else see how close it is to target
;                         if close to target
;                            then explodes destroy missile
;                                 if ship is not station
;                                    then set up signal target ship hit my missile flag
;                                         set blastcheckcounter to slotlist length  (12)
;                                 end if
;                                 if we are in range of missle blast
;                                    cause blast damage to our ship (this will signal death is needed)
;                                 end if
;                                 return
;                         end if
;                 end if
;         end if                     
.ProcessMissileHit:     ld      a,(CurrentMissileCheck)
                        ReturnIfAGTENusng UniverseSlotListSize  ; need to wait another loop
.ActivateNewExplosion:  jp  CheckMissileBlastInit               ; initialise
                        ; DUMMY RET get a free return by using jp
.ECMIsActive:           call    UnivExplodeShip                 ; ECM detonates missile
                        SetMemTrue  UBnKMissleHitToProcess      ; Enque an explosion
                        jp      .ProcessMissileHit              ; lets see if we can enqueue now
                        ; DUMMY RET get a free return as activenewexplosion does jp to init with a free ret



            ;            else if ship is angry at us
;                    
                        
; Part 1 - if type is missile and enquing a missile blast and slot free
;             then enqueue missile blast details
;                  mark as exploded
;                  remove missile from universe slot list

; TODO, how to we deal with scared ships, e.g. if angry and no guns or missiles then should be considered scared or if hull mass < say 25% of our ship
; also for future ship vs ship combat
;... Tactics........................................................................
;.PART 1
; if shiphitbymissleflag <> false
;    then dec blast check counter
;         if blast check counter = 0
;            then set shiphitbymissileflag to FF
;    else if SetShipHitByMissileFlag = current ship number
;            then cause damage to ship
;         else if ship is in range and ship is not a station
;                  then cause blast damage to ship
;         if destroyed
;            then explode ship
;                 return
; end if
; if ship is a missle (I think we allow missile on missle action)
;    then if ecm is active
;            then destroy missile and return
;            else if ship is angry at us
;                    then if ship is close to us
;                            then explodes causing damage to our ship
;                                 enque missile blast
;                                 destroy missile
;                                 set blastcheckcounter to slotlist length
;                                 set shiphitbymissileflag to FE (general blast)
;                                 return
;                            else jump to part 3 to do updates
;                         end if
;                    else see how close it is to target
;                         if close to target
;                            then 
;                                 enque missile blast
;                                 destroy missile
;                                 if ship is not station
;                                    then set up signal target ship hit my missile flag
;                                         set blastcheckcounter to slotlist length  (12)
;                                 end if
;                                 if we are in range of missle blast
;                                    cause blast damage to our ship (this will signal death is needed)
;                                 end if
;                                 return
;                         end if
;                 end if
;         end if
;.PART 2A ** adding in a collision logic 
;    else if ship is close to another ship
;            then if docking flag set and other ship is space station or we are space station and other ship has docking flag
;                    then if aligned correctly
;                         then remove ship as docked
;                              return
;         else
;            call collision route and determine daamage based on sizes and bounce vectors
;            return
;.PART 2 ** Need to check if ship has AI flag
;    else if not hostile
;            then if not docking or station not present
;                    then calculate vector to planet
;                         jump to part 7
;                    else calculate verctor to docking slot
;                         call caluclate vector to docking slot (DOCKIT)
;                         jump to part 7
;                 end if 
;            else case ship type 
;                      >>escape pod>> point at planet and jump to step 7
;                      >>space station>> if hostile
;                                           then if cop counter < 7 and 6.2% chance
;                                                   then spawm hostile cop
;                                                end if
;                                           else
;                                                if 0.8% change and transporter count = 0
;                                                   then if 50% chance
;                                                           then spawn transporter
;                                                           else spawn shuttle
;                                                        end if
;                                                end if
;                                        end if
;                                        return
;                      >>targoid and no mother ship in slot list>> set random drift
;                                                                  return
;                      >>if bounty hunter flag>> if ship not hostile
;                                                   then if trader flag clear or 20% chance
;                                                        then if fugitive or offender 
;                                                                then set hosile
;                                                end if
;                      >>Carrier and hanger slots > 0 >> if 22% chance (code to be added later) 
;                                         then spawn agressive hosting one of types carried
;                                              reduce ships in hanger by 1
;                                              return
;                      >>rock hermit>> if 22% chance
;                                         then spawn agressive hosting one of Sidewinder, Mamba, Krait, Adder or Gecko
;                                              return
;                      >>pirate and in safe zone>> stop pirate being hostile by removing agressive and hostileflags
;                 end case
;         end if
;         recharge ship energy by recharge factor (TODO as a config item on ship type but by default 1)
; .PART 3
;         calulcate dot product of ship nose to us
; .PART 4              
;         2.5% change ship rill roll a noticable amount
;         if ship has > 50% energy jump to part 6
;         if ship > 1/8th energy jump to part 5
;         if random 10% chance (i.e. ship < 1/8 energy and bails out)
;            then launch escape pod
;                 set AI to null
;                 set random pitch and roll
;                 set accelleation to 0
;         end if
; .PART 5
;         if ship does not have any missilesor ECM is firing to part 6
;            then if random > threshold for ship type (TODO as a config item on ship type)
;                    then if tharoid ; note this means thargoids are sensitve to ECM
;                            then launch thargon
;                            else spawn angry missle under ship
;                         end if
;                 end if
;            else return
;         end if
; .PART 6
;         if ship is not pointing at us from dot product ( < 160 , also > -32)
;            then jump to part 7
;            else if ship is pointing directly at us ( < 163 i.e. > -35) 
;                    then fire laser at us (which reduces energy)
;                         cause laser damage to our ship (this will signal death is needed)
;                         decellerate by half as ship has lock on
;                         return
;                    else fire laser into space (which reduces energy)
;                 end if
;         end if
; .PART 7#
;        if ship is a msile targetting us
;           then ship turns towards us some more
;           else if z hi > =  3 or ( x hi or y hi > 1) , i.e. ship is far away
;                    then do random wiht bit 7 set
;                         if random < AI flag
;                            then   ship turned towards us
;                            else   ship turns away from us
;                         end if
;                end if
;           end if
;           calculate new roll, pitch and accelleration based on new targe vector 


;        determine ship direction based on agression and type                    
;        set pitch and roll coutners
;        adjust speed depleding on relationship to us 
; .PART 8 - new 
;        if ship has ECM, another ECM is not active and missile targeted at it
;           if ship has enery of ECM energey cost + 1/8th total
;              if chance 25%
;                 then fire ECM
;