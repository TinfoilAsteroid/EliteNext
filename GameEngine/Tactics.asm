                        DEFINE TACTICSDEBUG
;Ship Tactics
ShipAIJumpTable:      DW    NormalAI,   MissileAI,  StationAI,  JunkAI,     ScoopableAI
                      DW    ThargoidAI, NoAI,       NoAI,       NoAI,       NoAI
ShipAiJumpTableMax:   EQU ($ - ShipAIJumpTable)/2



;----------------------------------------------------------------------------------------------------------------------------------
; Main entry point to tactics. Every time it will do a a tidy and the do AI logic
UpdateShip:             ;  call    DEBUGSETNODES ;       call    DEBUGSETPOS
                       ld      hl,TidyCounter
                       dec     (hl)
                       ret     nz
                       ld      a,16
                       ld      (TidyCounter),a
                        ; call    TIDY TIDY IS BROKEN
                       ; add AI in here too
                       ld       a,(ShipTypeAddr)
                       ReturnIfAGTEusng ShipAiJumpTableMax              ; TODO capture duff jumps whilst debugging in case a new shjip type code is added
                       ld       hl,ShipAIJumpTable
                       add      hl,a
                       add      hl,a
                       ld       a,(hl)                                  ; contrary to the name
                       inc      hl                                      ; jp (hl) is really 
                       ld       h,(hl)                                  ; jp hl
                       ld       l,a                                     ;
                       jp       hl                                      ; Follow the AI Jump Table
                       ret                                              ; not needed as jp handles this



; used  when no pre-checks are requrired, e.g. if forcing a space station from main loop

NormalAI:               ret
StationAI:              ret
JunkAI:                 ret
ScoopableAI:            ret
ThargoidAI:             ret
NoAI:                   ret

;----------------------------------------------------------------------------------------------------------------------------------
; set angry if possible, if its an innocent then flag the space station to get angry
MakeAngry:              ld      a,(ShipNewBitsAddr)                     ; Check bit 5 of newb flags
                        ;break
                        JumpIfMemEqNusng ShipTypeAddr, ShipTypeStation, .SetNewbAngry
.ItsNotAStation:        and     ShipIsBystander                         ; check if space station present if its a bystander
                        call    nz, SetStationAngry                     ; Set Space Station if present, Angry
                        ld      a,(UBnkaiatkecm)                        ; get AI data
                        ReturnOnBitClear a, ShipAIEnabledBitNbr         ; if 0 then no AI attached so it can't get angry
                        ld      c,a                                     ; Copy to c in case we need it later
                        SetMemToN UBnKAccel, 2                          ; set accelleration to 2 to speed up
                        sla     a                                       ; set pitch to 4
                        ld      (UBnKRotZCounter),a                     ; .
                        ld      a,(ShipAIFlagsAddr)
                        ReturnIfBitMaskClear ShipCanAnger
.SetNewbAngry:          call    SetShipHostile
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
MissileDidHitUs:        ret ; TODO

;----------------------------------------------------------------------------------------------------------------------------------
PlayerHitByMissile:     ret; TODO , do hit set up blast radius etc
;----------------------------------------------------------------------------------------------------------------------------------
MissileHitShipA:        ret; TODO hit ship do explosion, check for near by and if player is near and missile type logic, e.g. AP or HE
;----------------------------------------------------------------------------------------------------------------------------------
SetStationAngry:        call    IsSpaceStationPresent                   ; only if present
                        ret     c
                        ld      a,(UbnKShipUnivBankNbr)                     ; save current bank
                        ld      iyh,a
                        MMUSelectUniverseN 0                            ; space station is always 0
                        call    SetShipHostile
                        ld      a,iyh                                   ; get prev bank back
                        MMUSelectUniverseA                              ;
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
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
                        
;----------------------------------------------------------------------------------------------------------------------------------
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

SelectMissileBank:      MACRO
                        ld      a,iyh
                        MMUSelectUnivBankA
                        ENDM

SelectTargetBank:       MACRO
                        ld      a,iyl
                        MMUSelectUnivBankA
                        ENDM
                        
;...................................................................                        
; ... Copy of target data for missile calcs etc
                        INCLUDE "./TacticsWorkingData.asm"
                        INCLUDE "../GameEngine/MissileAI.asm"

; On Entry A = TacticsDotProduct2 sign (i.e. roof direction)
; on exit a == new roll
calcNPitch:             xor     SignOnly8Bit                    ; c = sign flipped of dot product only
                        and     SignOnly8Bit                    ; .
                        ld      c,a                             ; . (varT in effect)
                        ld      a,(UBnKRotZCounter)             ; b = abs (currentz pitch)
                        and     SignMask8Bit                    ; . which will initially be 0
                        ld      b,a                             ; .
                        ld      a,(TacticsDotProduct2)          ; a = abs roof dot product
                        JumpIfALTNusng 4, .calcNPitch2          ; if a >= roll threshold
                        ld      a,3                             ;    z rot = z rot * dot product flipped sign
                        or      c                               ;    i.e. zrot = current magnitude but dot product sign flipped
                        ld      (UBnKRotZCounter),a             ;    .
                        ret                                     ; else (a LT current abs z)
.calcNPitch2:           or      c                               ;     rot z = dot product with sign flipped
                        ld      (UBnKRotZCounter),a             ;
                        ret                                     ;
                        
calcNRoll:              xor     SignOnly8Bit                    ; flip sign of dot product
                        and     SignOnly8Bit
                        ld      c,a
                        ld      a,(UBnKRotXCounter)
                        and     SignMask8Bit                    ; get ABS value
                        ld      b,a
                        ld      a,(TacticsDotProduct2)          ; now we have the dot product abs value
                        JumpIfALTNusng 4, .calcNRoll2
                        ld      a,3
                        or      c
                        ld      (UBnKRotXCounter),a
                        ret
.calcNRoll2:            or      c                               ;     rot z = dot product with sign flipped
                        ld      (UBnKRotXCounter),a
                        ret

CopyRotmatToTacticsMat: ld      hl,UBnkrotmatSidevX+1
                        ld      de,TacticsRotMatX
                        ld      a,(hl)              ; matrix high byte of x
                        ld      b,a
                        and     SignMask8Bit
                        ld      (de),a              ; set rot mat value
                        inc     de
                        ld      a,b
                        and     SignOnly8Bit
                        ld      (de),a              ; set rot mat sign
                        inc     de                  ; move to next rot mat element
                        inc     hl                  
                        inc     hl                  ; matrix high byte of y
.processYElement:       ld      a,(hl)              ; matrix high byte of y
                        ld      b,a
                        and     SignMask8Bit
                        ld      (de),a              ; set rot mat value
                        inc     de
                        ld      a,b
                        and     SignOnly8Bit
                        ld      (de),a              ; set rot mat sign
                        inc     de                  ; move to next rot mat element
                        inc     hl                  
                        inc     hl                  ; matrix high byte of z
.ProcessZElement:       ld      a,(hl)              ; matrix high byte of z
                        ld      b,a
                        and     SignMask8Bit
                        ld      (de),a              ; set rot mat value
                        inc     de
                        ld      a,b
                        and     SignOnly8Bit
                        ld      (de),a              ; set rot mat sign
                        ret
                        

XX12EquTacticsDotNosev: ld      hl,TacticsRotMatX; UBnkTransmatNosevX    ; ROTMATX HI
XX12EquTacticsDotHL:    push    hl
                        call    CopyRotmatToTacticsMat
                        pop     hl
.CalcXValue:            ld      a,(hl)
                        ld      e,a
                        ld      a,(TacticsVectorX)
                        ld      d,a
                        mul
                        ld      a,d
                        ld      (varT),a
                        inc     hl                                  ; move to sign byte
.CalcXSign:             ld      a,(TacticsVectorX+2)
                        xor     (hl)
.MoveToY:               inc     hl                                  ; Move on to Y component
.CalcYValue:            ld      a,(hl)
                        ld      e,a
                        ld      a,(TacticsVectorY)
                        ld      d,a
                        mul
                        ld      a,d
                        ld      (varT),a
                        inc     hl                                  ; move to sign byte
.CalcYSign:             ld      a,(TacticsVectorY+2)
                        xor     (hl)
                        ld      (varS),a                            ; Set S to the sign of x_sign * sidev_x
.MoveToZ:               inc     hl                                  ; Move on to Y component
.AddXandY:              push    hl
                        call    baddll38                            ; JSR &4812 \ LL38   \ BADD(S)A=R+Q(SA) \ 1byte add (subtract)
                        pop     hl
                        ld      (varT),a                            ; T = |sidev_x| * x_lo + |sidev_y| * y_lo
.CalcZValue:            ld      a,(hl)
                        ld      e,a
                        ld      a,(TacticsVectorZ)
                        ld      d,a
                        mul
                        ld      a, d
                        ld      (varT),a
                        inc     hl                                  ; move to sign byte
.CalcZSign:             ld      a,(TacticsVectorZ+2)
                        xor     (hl)
                        ld      (varS),a                            ; Set S to the sign of x_sign * sidev_x
                        call    baddll38                            ; JSR &4812 \ LL38   \ BADD(S)A=R+Q(SA)   \ 1byte add (subtract)
                        ret

XX12EquTacticsDotRoofv: ld      hl,UBnkrotmatRoofvX; UBnkTransmatRoofvX
                        jp      XX12EquTacticsDotHL
                        
XX12EquTacticsDotSidev: ld      hl,UBnkrotmatSidevX; UBnkTransmatSidevX
                        jp      XX12EquTacticsDotHL
                        
;-- Now its scaled we can normalise
;-- Scale down so that h d &b are zero, then do once again so l e and c are 7 bit
;-- use 7 bit mul96 to ensure we don;t get odd maths
NormalizeTactics:       ld      hl, (TacticsVectorX)        ; pull XX15 into registers
                        ld      de, (TacticsVectorY)        ; .
                        ld      bc, (TacticsVectorZ)        ; .
.ScaleLoop:             ld      a,h
                        or      d
                        or      b
                        jr      z,.DoneScaling
                        ShiftHLRight1
                        ShiftDERight1
                        ShiftBCRight1
                        jp      .ScaleLoop
.DoneScaling:           ShiftHLRight1                       ; as the values now need to be sign magnitued
                        ShiftDERight1                       ; e.g. S + 7 bit we need an extra shift
                        ShiftBCRight1                       ; now values are in L E C
                        push    hl,,de,,bc                  ; save vecrtor x y and z nwo they are scaled to 1 byte
                        ld      d,e                         ; hl = y(e) ^ 2
                        mul     de                          ; .
                        ex      de,hl                       ; .
                        ld      d,e                         ; de = x(l) ^ 2
                        mul     de                          ; .
                        add     hl,de                       ; hl = hl + de
                        ld      d,c                         ; de = y(c)^ 2 + x ^ 2
                        ld      e,c                         ; .
                        mul     de                          ; .
                        add     hl,de                       ; hl =  y^ 2 + x ^ 2 + z ^ 2
                        ex      de,hl                       ; fix as hl was holding square
                        call    asm_sqrt                    ; IYH = A = hl = sqrt (de) = sqrt (x ^ 2 + y ^ 2 + z ^ 2)
                        ; add in logic if h is low then use lower bytes for all 
                        ld      a,l                         ;
                        ld      iyh,a                       ;
                        ld      d,a                         ; D = sqrt
                        pop     bc                          ; retrive tacticsvectorz scaled
                        ld      a,c                         ; a = scaled byte
                        call    AequAdivDmul967Bit;AequAdivDmul96Unsg          ; This rountine I think is wrong and retuins bad values
                        ld      (TacticsVectorZ),a          ; z = normalised z
                        pop     de
                        ld      a,e
                        ld      d,iyh                        
                        call    AequAdivDmul967Bit;AequAdivDmul96Unsg
                        ld      (TacticsVectorY),a
                        pop     hl
                        ld      a,l
                        ld      d,iyh                        
                        call    AequAdivDmul967Bit;AequAdivDmul96Unsg
                        ld      (TacticsVectorX),a
                        ; BODGE FOR NOW
                       ; BODGE FOR NOW
                        ZeroA                              ;; added to help debugging
                        ld      (TacticsVectorX+1),a       ;; added to help debugging
                        ld      (TacticsVectorY+1),a       ;; added to help debugging
                        ld      (TacticsVectorZ+1),a       ;; added to help debugging
                        SignBitOnlyMem TacticsVectorX+2     ; now upper byte is sign only
                        SignBitOnlyMem TacticsVectorY+2     ; (could move it to lower perhaps later if 
                        SignBitOnlyMem TacticsVectorZ+2     ;  its worth it)
                        ret


;TODOcall    TacticsPosMinusTarget              ; calculate vector to target
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




ReduceTacticVectors:ld      hl, (TacticsVectorX)        ; pull XX15 into registers
                    ld      de, (TacticsVectorY)        ; .
                    ld      bc, (TacticsVectorZ)        ; .
                    ld      a,(TacticsVectorX+2)        ; .
                    ld      iyh,a                       ; iyh = X sign
                    ld      a,(TacticsVectorY+2)        ; .
                    ld      iyl,a                       ; iyl = Y sign
                    ld      a,(TacticsVectorZ+2)        ; .
                    ld      ixh,a                       ; ixh = z sign
.ScaleLoop:         or      iyh                         ; now check if upper has value
                    or      iyl                         ; .
                    ClearSignBitA                       ;  exluding sign bit
                    jr      z,.DoneScaling              ; and exit loop if upper byte is only sign component
.ScaledDownBy2:     ld      a,iyh
                    sra     a
                    ld      iyh,a                       ; actually we can keep sign bit so just sr then rr
                    rr      h                           ; Deal with X
                    rr      l                           ;
                    ld      a,iyl
                    sra     a                           ; actually we can keep sign bit so just sr then rr
                    ld      iyl,a
                    rr      d                           ; Deal with Y
                    rr      e                           ;
                    ld      a, ixl                      ; actually we can keep sign bit so just sr then rr
                    sra     a
                    ld      ixl,a
                    rr      b                           ; Deal with Z
                    rr      c                           ;
                    jp      .ScaleLoop
.DoneScaling:       ld      a,h
                    or      d
                    or      b
                    SignBitOnlyA                        ; check if new sign bit has a value rotated in, 
                    jr      z,.OKToNormalise
.ShiftTo15Bit:      ShiftHLRight1                       ; one last shift to 15 bit we don't need
                    ShiftDERight1                       ; to do sign bytes 
                    ShiftBCRight1                       ; as value must be 0
.OKToNormalise:     ld      a,h                         ; iyh now can only hold sign 
                    or      iyh                         ; so by the end of here
                    ld      h,a                         ;   hl = x
                    ld      a,d                         ;   de = y
                    or      iyl                         ;   bc = z
                    ld      d,a                         ; all scaled to 15 bit + sign
                    ld      a,b                         ;
                    or      ixh                         ;
                    ld      b,a                         ;
                    ld      (TacticsNormX),hl
                    ld      (TacticsNormY),hl
                    ld      (TacticsNormZ),hl
                    ret
                   ; ***SIgn bits*** need to be in byte 3
