                        DEFINE MISSILEDEBUG
                        ;DEFINE MISSILEBREAK
;... Now the tactics if current ship is the missile, when we enter this SelectedUniverseSlot holds slot of missile
MissileAI:              JumpIfMemTrue UBnKMissleHitToProcess, .ProcessMissileHit
.CheckForECM:           JumpIfMemNotZero ECMCountDown,.ECMIsActive  ; If ECM is running then kill the missile
.IsMissileHostile:      IsShipFriendly                              ; is missle attacking us?
                        JumpIfZero .MissileTargetingShip            ; Missile is friendly then z is set else targetting us
.MissileTargetingPlayer:ld      hl, (UBnKxlo)                       ; check if missile in range of us
                        ld      a,(UBnKMissileDetonateRange)
                        ld      c,a                                 ; c holds detonation range
                        call    MissileHitUsCheckPos
.MissileNotHitUsYet:    jp      nc, .UpdateTargetingUsPos
.MissleHitUs:           call    PlayerHitByMissile
                        jp      .ECMIsActive                        ; we use ECM logic to destroy missile which eqneues is
.UpdateTargetingUsPos:  ret                        ;;;;;;***********TODO
;--- Missile is targeting other ship
.MissileTargetingShip:  ld      a,(SelectedUniverseSlot)            ; we will use this quite a lot with next bank switching
.SaveMissileBank:       add     a,BankUNIVDATA0                     ; pre calculate add to optimise
                        ld      iyh,a
                        IFDEF MISSILEDEBUG
                            ld  (TacticsMissileBank),a
                        ENDIF
.SaveTargetBank:        ld      a,(UBnKMissileTarget)               ; target will be used a lot too
                        add     a,BankUNIVDATA0                     ; pre calculate add to optimise
                        ld      iyl,a                               ; save target                        
                        IFDEF MISSILEDEBUG
                            ld  (TacticsTargetBank),a
                        ENDIF
.IsMissleTargetGone:    JumpIfSlotAEmpty    .ECMIsActive            ; if the target was blown up then detonate
;... Note we don't have to check for impact as we already have a loop doing that
.SelectTargetShip:      SelectTargetBank
.IsShipExploding:       ld      a,(UBnkaiatkecm)                    ; check exploding status
                        and     ShipExploding                       ; as if exploding then the missile will also explode
                        jr      z,.UpdateTargetingShipX
.ShipIsExploding:       SelectMissileBank                           ; get missile back into memory
                        jp      .ECMIsActive
;--- At this point we already have the target banked in ready for calculating vector
.UpdateTargetingShipX:;break
                        ld      de,(UBnKxlo)                        ; get target ship X
                        ld      a,(UBnKxsgn)                        ; and flip sign so we have missile - target
                        IFDEF MISSILEDEBUG
                            ld  (TacticsTargetX),de
                            ld  (TacticsTargetX+2),a
                        ENDIF                        
                        FlipSignBitA
                        ld      c,a                                 ; get target ship x sign but * -1 as we are subtracting
                        SelectMissileBank
                        ld      hl,(UBnKxlo)                        ; get missile x
                        ld      a,(UBnKxsgn)                        ; get missile x sign
                        IFDEF MISSILEDEBUG
                            ld  (TacticsMissileX),hl
                            ld  (TacticsMissileX+2),a
                        ENDIF                        
                        ld      b,a
                        call    ADDHLDESignBC                       ;AHL = BHL + CDE i.e. missile - target x
                        ld      (TacticsVectorX),hl
                        ld      (TacticsVectorX+2),a
.UpdateTargetingShipY:  SelectTargetBank
                        ld      de,(UBnKylo)                        ; get target ship X
                        ld      a,(UBnKysgn)
                        IFDEF MISSILEDEBUG
                            ld  (TacticsTargetY),de
                            ld  (TacticsTargetY+2),a
                        ENDIF                        
                        FlipSignBitA
                        ld      c,a                                 ; get target ship x sign but * -1 as we are subtracting
                        SelectMissileBank
                        ld      hl,(UBnKylo)                        ; get missile x
                        ld      a,(UBnKysgn)                        ; get missile x sign
                        IFDEF MISSILEDEBUG
                            ld  (TacticsMissileY),hl
                            ld  (TacticsMissileY+2),a
                        ENDIF                        
                        ld      b,a
                        call    ADDHLDESignBC                       ;AHL = BHL + CDE i.e. missile - target x
                        ld      (TacticsVectorY),hl
                        ld      (TacticsVectorY+2),a
.UpdateTargetingShipZ:  SelectTargetBank
                        ld      de,(UBnKzlo)                        ; get target ship X
                        ld      a,(UBnKzsgn)
                        IFDEF MISSILEDEBUG
                            ld  (TacticsTargetZ),de
                            ld  (TacticsTargetZ+2),a
                        ENDIF                        
                        FlipSignBitA
                        ld      c,a                                 ; get target ship x sign but * -1 as we are subtracting
                        SelectMissileBank
                        ld      hl,(UBnKzlo)                        ; get missile x
                        ld      a,(UBnKzsgn)                        ; get missile x sign
                        IFDEF MISSILEDEBUG
                            ld  (TacticsMissileZ),hl
                            ld  (TacticsMissileZ+2),a
                        ENDIF                        
                        
                        ld      b,a
                        call    ADDHLDESignBC                       ;AHL = BHL + CDE i.e. missile - target x
                        ld      (TacticsVectorZ),hl
                        ld      (TacticsVectorZ+2),a
; by here missile in in memory and TacticsVector now holds distance
; if or ABS all high bytes is <> 0
.CheckDistance:         ld      hl,(TacticsVectorX+1)              ; test if high bytes are set (value is assumed to be 24 bit, though calcs are only 16 so this is uneeded)
                        ld      a,h                                ; .
                        ld      de,(TacticsVectorY+1)              ; .
                        or      d                                  ; .
                        ld      bc,(TacticsVectorZ+1)              ; .
                        or      b                                  ; .
                        ClearSignBitA                              ; .
                        JumpIfNotZero       .FarAway               ; .
                        or      l                                    ; test for low byte bit 7, i.e high of 16 bit values
                        or      e                                  ; .
                        or      c                                  ; .
                        JumpIfNotZero       .FarAway               ; .
; If we get here its close enough to detonate
.CloseMissileExplode:   ld      a,(UBnKMissileTarget) 
                        jp      MissileHitShipA
;   *far away ** TODO need to set memory read write on page 0
.FarAway:               SelectTargetBank
                        JumpIfMemFalse      UBnKECMFitted, .NoECM                   ; if target has ECM and enough energy to use it
                        JumpIfMemLTNusng    UBnKEnergy,    ECMCounterMax, .NoECM    ; .
                        JumpIfMemIsNotZero   ECMCountDown, .NoECM                ; . ECM is already active
.TestIfUsingECM:        ld      a,(RandomSeed2)                                             ; if random < 16
                        JumpIfAGTENusng     16, .UpdateMissilePos                           ;   then fire ECM destroying missile
;. If we get here then target is still paged in to fire ECM
.ZeroPageFireECM:       jp      FireECM                                             ; with an implicit return
;                       implicit ret
;. If we get here then target is still paged in with no ECM
.NoECM:
                      ;;;         ** can do 16 bit maths as we can take teh view that once a object/space station is 24 bit value away then 
                      ;;;         ** targeting computer looses track and destructs missiles
;--- Now we can actually update the missile AI                      
.UpdateMissilePos:      ;break
                        SelectMissileBank
.NormaliseDirection:    IFDEF MISSILEBREAK
                            break
                        ENDIF
                        call    NormalizeTactics                    ; Normalise vector down to 7 bit + sign byte
.NoseDotProduct:        call    XX12EquTacticsDotNosev              ; SA = nose . XX15
                        ld      (TacticsDotProduct1),a               ; CNT = A (high byte of dot product)
                        ld      a,(varS)                            ; get sign from dot product
                        xor     SignOnly8Bit                        ; and flip the sign bit
                        and     SignOnly8Bit                        ; and save the sign into Dot product
                        ld      (TacticsDotProduct1+1),a             ; negate value of CNT so +ve if facing or -ve if facing same way
.NegateDirection:       FlipSignMem TacticsVectorX+2                ; negate vector in XX15 so it points opposite direction
                        FlipSignMem TacticsVectorY+2                ; we have already negated the dot product above
                        FlipSignMem TacticsVectorZ+2                ; .  
.RoofDotProduct:        call    XX12EquTacticsDotRoofv              ; Now tran the roof for rotation        
                        ld      (TacticsDotProduct2),a              ; so if its +ve then the roof is similar so pull up to head towards it
                        ld      a,(varS)                            ; .                                       
                        ld      (TacticsDotProduct2+1),a            ; .                                       
                        IFDEF MISSILEBREAK
                            break
                        ENDIF
                        call    calcNPitch                          ; work out pitch
                        ld      a,(UBnKRotZCounter)
                        sla     a                                   ; strip off sign (also doubling it)
                        JumpIfAGTENusng 32, .AlreadyRolling
.SideDotProduct:        call    XX12EquTacticsDotSidev              ; get dot product of xx15. sidev
                        ld      (TacticsDotProduct3),a              ; This will be positive if XX15 is pointing in the same direction
                        ld      a,(varS)                            ;  
                        xor     SignOnly8Bit                        ; and flip the sign bit
                        and     SignOnly8Bit                        ; and save the sign into Dot product                        
                        ld      (TacticsDotProduct3+1),a            ;
                        IFDEF MISSILEBREAK
                            break
                        ENDIF
                        call    calcNRoll
                        ld      (UBnKRotXCounter),a
.AlreadyRolling:        ld      a,(TacticsDotProduct1+1)             ; Fetch the dot product, and if it's negative jump to
                        JumpIfAIsNotZero    .SlowDown               ; slow down routine
                        ld      a,(TacticsDotProduct1)
                        JumpIfALTNusng  22, .SlowDown
.Accellerate:           ld      a,3                                 ; full accelleration
                        ld      (UBnKAccel),a
                        ret
.SlowDown:              ld      a,(TacticsDotProduct2)              ; this is already abs so no need to do abs
                        ReturnIfALTNusng  18                        ; If A < 18 then the ship is way off the XX15 vector, so return without slowing down, as it still has quite a bit ofturning to do to get on course
                        ld      a,$FE                               ; A = -3 as missiles are more nimble and can brake more quickly
                        ld      (UBnKAccel),a
                        ret
                        ;
                        ;           ships pitch counter = calculate teh shipt pitch counter (jsr nroll)
                        ;           get roll counter from ship byte 29 (value = abs(byte 29 * 2) ,e. shift left                        
                        ;           if roll counter < 32
                        ;               AX = sidev . XX15
                        ;               A = A xor pitch counter sigh
                        ;               byte 29 = calcualte nroll to get ship pitch counter into
                        ;           get back CNT
                        ;           if CNT >= 0 AND CNT < CNT2 ** how is CNT2 set up?
                        ;             then
                        ;               Accelleration (byte 28) = 3
                        ;               return
                        ;           A = ABS(CNT)  
                        ;          if |CNT| >=  18
                        ;            then
                        ;              ship accelleration = -2
                        ret
                        
                        
                        

                        ;       
                        ; else 
                        ;   *close enough for a detoniation
                        ;   if target is a space station, set space station to trigger ECM and destroy missile (note that compromised station will not trigger ECM)
                        ;   process missile hit object
                        ;   work out if blast hit anythign else including us
                        
.ProcessMissileHit:     ld      a,(CurrentMissileCheck)
                        ReturnIfAGTENusng UniverseSlotListSize  ; need to wait another loop
.ActivateNewExplosion:  jp  CheckMissileBlastInit               ; initialise
                        ; DUMMY RET get a free return by using jp
.ECMIsActive:           call    UnivExplodeShip                 ; ECM detonates missile
                        SetMemTrue  UBnKMissleHitToProcess      ; Enque an explosion
                        jp      .ProcessMissileHit              ; lets see if we can enqueue now
                        ; DUMMY RET get a free return as activenewexplosion does jp to init with a free ret
