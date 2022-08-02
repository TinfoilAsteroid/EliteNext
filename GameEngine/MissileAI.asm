                        DEFINE MISSILEDEBUG 1
                        DEFINE MISSILEDOHIT 1

MISSILEMAXACCEL         equ 3
MISSILEMAXDECEL         equ -3                        
                        ;DEFINE MISSILEBREAK
;... Now the tactics if current ship is the missile, when we enter this SelectedUniverseSlot holds slot of missile
MissileAI:              IFDEF MISSILEDOHIT
                            JumpIfMemTrue UBnKMissleHitToProcess, .ProcessMissileHit
                        ENDIF
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
                        IFDEF MISSILEDOHIT
                            JumpIfNotZero       .FarAway           ; .
                        ELSE
                            jp                  .FarAway
                        ENDIF
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
.UpdateMissilePos:      break
                        SelectMissileBank
.NormaliseDirection:    IFDEF MISSILEBREAK
                            break
                        ENDIF
                        call    NormalizeTactics                    ; Normalise vector down to 7 bit + sign byte (.TA19->TAS2)
                        IFDEF MISSILEDEBUG
                            call DebugTacticsCopy
                        ENDIF
.NoseDotProduct:        call    XX12EquTacticsDotNosev              ; SA = nose . XX15                           (     ->TAS3)
                        ld      (TacticsDotProduct1),a               ; CNT = A (high byte of dot product)
                        ld      a,(varS)                            ; get sign from dot product
.FlipNoseDotProduct:    xor     SignOnly8Bit                        ; and flip the sign bit
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
                        ld      a,(UBnKRotXCounter)                 ; Get abs roll counter
                        IFDEF MISSILEDEBUG      
                            ld  (TacticsRotZ),a
                        ENDIF
                        and     SignMask8Bit                        ; .
                        JumpIfAGTENusng 16, .AlreadyRolling
                        
                        ;sla     a                                   ; strip off sign (also doubling it)
                        ;JumpIfAGTENusng 32, .AlreadyRolling
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
                        ;ld      (UBnKRotXCounter),a
                        IFDEF MISSILEDEBUG
                            ld  (TacticsRotX),a
                        ENDIF
.AlreadyRolling:        ld      a,(TacticsDotProduct1+1)             ; Fetch the dot product, and if it's negative jump to
                        JumpIfAIsNotZero    .SlowDown               ; slow down routine
                        ld      a,(TacticsDotProduct1)
                        JumpIfALTNusng  22, .SlowDown
.Accellerate:           ld      a,MISSILEMAXACCEL;3                                 ; full accelleration
                        ld      (UBnKAccel),a
                        IFDEF MISSILEDEBUG
                            ld  (TacticsSpeed),a
                        ENDIF
                        ret
.SlowDown:              ld      a,(TacticsDotProduct2)              ; this is already abs so no need to do abs
                        ReturnIfALTNusng  18                        ; If A < 18 then the ship is way off the XX15 vector, so return without slowing down, as it still has quite a bit ofturning to do to get on course
                        ld      a,MISSILEMAXDECEL;$FE                               ; A = -3 as missiles are more nimble and can brake more quickly
                        ld      (UBnKAccel),a
                        IFDEF MISSILEDEBUG
                            ld  (TacticsSpeed),a
                        ENDIF
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



;.. Thsi version uses new kind logic
;... Now the tactics if current ship is the missile, when we enter this SelectedUniverseSlot holds slot of missile
MissileAIV2:            JumpIfMemTrue UBnKMissleHitToProcess, .ProcessMissileHit
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
; Tactics vector = missile - target
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
.UpdateMissilePos:      break
                        SelectMissileBank
.NormaliseDirection:    IFDEF MISSILEBREAK
                            break
                        ENDIF
                        call    NormalizeTactics                    ; Normalise vector down to 7 bit + sign byte (.TA19->TAS2)
                        IFDEF MISSILEDEBUG
                            call DebugTacticsCopy
                        ENDIF
.NoseDotProduct:        call    XX12EquTacticsDotNosev              ; SA = nose . XX15                           (     ->TAS3)
                        ld      (TacticsDotProduct1),a              ; CNT = A (high byte of dot product)
                        ld      a,(varS)                            ; get sign from dot product
.FlipNoseDotProduct:    xor     SignOnly8Bit                        ; and flip the sign bit
                        and     SignOnly8Bit                        ; and save the sign into Dot product
                        ld      (TacticsDotProduct1+1),a             ; negate value of CNT so +ve if facing or -ve if facing same way
.NegateDirection:       FlipSignMem TacticsVectorX+2                ; negate vector in XX15 so it points opposite direction
                        FlipSignMem TacticsVectorY+2                ; we have already negated the dot product above
                        FlipSignMem TacticsVectorZ+2                ; .  
.TrackObject:           
.RoofDotProduct:        call    XX12EquTacticsDotRoofv              ; Now tran the roof for rotation        
                        ld      (TacticsDotProduct2),a              ; so if its +ve then the roof is similar so pull up to head towards it
                        ld      a,(varS)                            ; .                                       
                        ld      (TacticsDotProduct2+1),a            ; Note here its direction not dir
                        call    SimplifiedShipPitchv2
                        call    SimplifiedShipRollv2
                        call    SimplifiedShipSpeedv2
                        ret
                        
                        
.CheckDirLTNeg861:      and     $80                                 ; if (direction < -0.861)
                        jr      z,.NotNegative                      ; .
                        ld      a,(TacticsDotProduct2)              ; .
                        JumpIfALTNusng 82, .NotNegative             ; .
.Prod2LTNweg861:        ld      a,(TacticsDotProduct1+1)            ; ship->rotx = (dir < 0) ? 7 : -7;
                        xor     $80                                 ; .
                        and     $80
                        or      7
                        ld      (UBnKRotXCounter),a                 ; .
                        jp      .SpeedCalc
.SetZToZero:            ZeroA                                       ; ship->rotz = 0
                        ld      (UBnKRotZCounter),a                 ; .
.ExitEarly:             ret                                         ; return; 
.NotNegative:           ZeroA                                       ; ship->rotx = 0
.SetXToZero:            ld      (UBnKRotXCounter),a                 ; .
.ABSDirGT:              ld      a,(TacticsDotProduct2)              ; if ((fabs(dir) * 2) >= rat2)
                        sla     a                                    ; .
                        JumpIfALTNusng 4, .SkipRotXUpdate           ; .
.RotXUpdate:            ld      a,(TacticsDotProduct2+1)            ; ship->rotx = (dir < 0) ? rat : -rat
                        xor     $80                                 ; .
                        and     $80
                        or      3 ; RAT                             ; .
                        ld      (UBnKRotXCounter),a                 ; .
                        jp      .SpeedCalc
.SkipRotXUpdate:        ld      a,(UBnKRotZCounter)                 ; if (abs(ship->rotz) < 16)
                        ld      b,a                                 ; .
                        and     $80                                 ; .
                        jp      nz,.ProcessZLT16                    ; .
.RotZPositive:          JumpIfALTNusng 16 ,.ProcessZLT16            ; .
                        jp      .SpeedCalc
                        
.ProcessZLT16:          call    XX12EquTacticsDotSidev              ; get dot product of xx15. sidev  dir = vector_dot_product (&nvec, &ship->rotmat[0])
                        ld      (TacticsDotProduct3),a              ; This will be positive if XX15 is pointing in the same direction
                        ld      a,(varS)                            ;  
                        ld      (TacticsDotProduct3+1),a
                        ld      a,(TacticsDotProduct3)              ; if ((fabs(dir) * 2) > rat2)
                        sla     a                                    ; .
                        JumpIfALTNusng 10 , .SpeedCalc                        ; .
                        ld      (TacticsDotProduct3+1),a            ; ship->rotz = (dir < 0) ? rat : -rat
                        xor     $80                                 ; .
                        and     $80
                        or      3                                   ; .
                        ld      (UBnKRotZCounter),a                 ; .
                        ld      a,(UBnKRotXCounter)                 ; if (ship->rotx < 0)
                        and     $80                                 ; .
                        jp     z, .SpeedCalc                             ; .
.RotXNeg:               ld      a,(UBnKRotZCounter)                 ; ship->rotz = -ship->rotz;
                        xor     $80                                 ;
                        ld      (UBnKRotZCounter),a                 ;
.SpeedCalc:             
                        ld      a,(TacticsDotProduct1+1)             ; Fetch the dot product, and if it's negative jump to
                        JumpIfAIsNotZero    .CheckAccell           ; slow down routine
                        ld      a,(TacticsDotProduct1)
                        JumpIfAGTENusng  11, .NotSlowDown           ; note we are looking here at an ABS so its >=
.SlowDown:              ld      a,-2                        
                        ld      (UBnKAccel),a
                        ret
.CheckAccell:           ld      a,(TacticsDotProduct1)
                        JumpIfALTNusng 22, .NotSlowDown
                        ld      a,3
                        ld      (UBnKAccel),a
                        ret
.NotSlowDown:           ld      a,(UBnKSpeed)
                        ReturnIfAGTENusng 6
                        ld      a,3
                        ld      (UBnKAccel),a
                        ret

                        
                        
                        
                        ld      a,h                                ; Should it be opposite?
                        xor     $80                                ;
                        and     $80                                ;
                        or      $03                                ;
                        ld      (UBnKRotZCounter),a                ;
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

                        
SimplifiedShipPitchv2:    ld      hl,(TacticsDotProduct2)            ; set z pitch to negative of dot product 2 of roofv
                        ld      a,h                                ; Should it be opposite?
                        xor     $80                                ;
                        and     $80                                ;
                        or      $03                                ;
                        ld      (UBnKRotZCounter),a                ;
                        ret
SimplifiedShipRollv2:     ld      a,(UBnKRotXCounter)                ; get current roll
                        and     $7F
                        ReturnIfAGTENusng 16                       ; if its 16 then already rolling
                        call    XX12EquTacticsDotSidev             ; lese calculate side dot protuct
                        ld      (TacticsDotProduct3),a              ; This will be positive if XX15 is pointing in the same direction
                        ld      a,(varS)                            ;  
                        ld      (TacticsDotProduct3+1),a
                        ld      hl,UBnKRotZCounter
                        xor     (hl)                                ; set to sign to+ve if pitch and dot have different signs
                        and     $80
                        or      $05                                 ; so its +/- 5
                        ld      (UBnKRotXCounter) ,a
                        ret
SimplifiedShipSpeedv2:    ld      a,(TacticsDotProduct1+1)
                        ld      b,a
                        and     $80
                        jp      nz,.NegativeNose
                        ld      a,b
                        JumpIfALTNusng 22, .NegativeNose
.PositiveNose:          ld      a,3
                        ld      (UBnKAccel),a
                        ret
.NegativeNose:          ld      a,b                                 ; get dot product back
                        and     $7F
                        ReturnIfALTNusng 18                         ; if its < 18 then way off
                        ld      a,-2
                        ld      (UBnKAccel),a
                        ret
                        
;.. Thsi version uses new kind logic
;... Now the tactics if current ship is the missile, when we enter this SelectedUniverseSlot holds slot of missile
MissileAIV3:            IFDEF MISSILEDOHIT
                            JumpIfMemTrue UBnKMissleHitToProcess, .ProcessMissileHit
                        ENDIF
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
; Tactics vector = missile - target
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
.CheckDistance:         IFDEF MISSILEDOHIT
                            ld      hl,(TacticsVectorX+1)              ; test if high bytes are set (value is assumed to be 24 bit, though calcs are only 16 so this is uneeded)
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
                        ELSE
                            jp                  .FarAway
                        ENDIF
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
                        ;break
                        ;call    ORTHOGALISE
.NormaliseDirection:    IFDEF MISSILEBREAK
                            break
                        ENDIF
                        call    NormalizeTactics                    ; Normalise vector down to 7 bit + sign byte (.TA19->TAS2)
                        IFDEF MISSILEDEBUG
                            call DebugTacticsCopy
                        ENDIF
.NegateDirection:       FlipSignMem TacticsVectorX+2                ; negate vector in XX15 so it points opposite direction
                        FlipSignMem TacticsVectorY+2                ; we have already negated the dot product above
                        FlipSignMem TacticsVectorZ+2                ; .                         
.NoseDotProduct:        call    XX12EquTacticsDotNosev              ; SA = nose . XX15                           (     ->TAS3)
                        ld      (TacticsDotProduct1),a              ; CNT = A (high byte of dot product)
                        ld      a,(varS)                            ; get sign from dot product
                        ld      (TacticsDotProduct2+1),a            ; Note here its direction not dir
.RoofDotProduct:        call    XX12EquTacticsDotRoofv              ; Now tran the roof for rotation        
                        ld      (TacticsDotProduct2),a              ; so if its +ve then the roof is similar so pull up to head towards it
                        ld      a,(varS)                            ; .                                       
                        ld      (TacticsDotProduct2+1),a            ; Note here its direction not dir
                        ;break
                        call    SimplifiedShipPitchv3
                        call    SimplifiedShipRollv3
                        ;ZeroA
                        ;ld      (UBnKAccel),a
                        ;ld      (UBnKSpeed),a
                        call    SimplifiedShipSpeedv3
                        ret
.ProcessMissileHit:     ld      a,(CurrentMissileCheck)
                        ReturnIfAGTENusng UniverseSlotListSize  ; need to wait another loop
.ActivateNewExplosion:  jp  CheckMissileBlastInit               ; initialise
                        ; DUMMY RET get a free return by using jp
.ECMIsActive:           call    UnivExplodeShip                 ; ECM detonates missile
                        SetMemTrue  UBnKMissleHitToProcess      ; Enque an explosion
                        jp      .ProcessMissileHit              ; lets see if we can enqueue now
                        ; DUMMY RET get a free return as activenewexplosion does jp to init with a free ret

                        
SimplifiedShipPitchv3:  ;break
                        ld      hl,(TacticsDotProduct2)            ; pitch counter sign = opposite sign to roofdir sign
                        ld      a,h                                ; .
                        xor     $80                                ; .
                        and     $80                                ; .
                        ld      h,a                                ; h  = flipped sign
                        ld      a,l                                ; a = value * 2
                        sla     a                                  ; 
                        JumpIfAGTENusng 16, .skipPitchZero         ; if its > 16 then update pitch
                        ZeroA                                      ; else we zero pitch but
                        or      h                                  ; we need to retain the sign
                        ld      (UBnKRotZCounter),a                ; .
                        IFDEF MISSILEDEBUG
                            ld  (TacticsRotZ),a
                        ENDIF
                        ret
.skipPitchZero:         ld      a,2
                        or      h
                        ld      (UBnKRotZCounter),a
                        IFDEF MISSILEDEBUG
                            ld  (TacticsRotZ),a
                        ENDIF
                        ret

;Direct on dot product nose is $24
; Position                  Pitch   Roll    Speed
; Top left forwards         up      -ve     +
; Top right forwards        up      +ve     +
; Bottom left forwards      down    -ve     +
; Bottom right forwards     down    +ve     +
; Top left rear             up      -ve     -
; Top right rear            up      +ve     -
; Bottom left rear          down    -ve     -
; Bottom right rear         down    +ve     -


                        
SimplifiedShipRollv3:  ; ld      a,(UBnKRotXCounter)               ; get current roll
                       ; sla     a                                 ; * 2 to also abs
                       ; ReturnIfAGTENusng 32                      ; and so if >32 skip
                        call    XX12EquTacticsDotSidev             ; calculate side dot protuct
                        ld      (TacticsDotProduct3),a             ; .
                        ld      l,a                                ; .
                        ld      a,(varS)                           ; .
                        ld      (TacticsDotProduct3+1),a           ; .
                        ld      h,a                                ; h = sign sidev
                        ld      a,(TacticsDotProduct2+1)           ; get flipped pitch counter sign
                        ;xor     $80                               ; .
                        ;xor     h                                 ; b = flip against pitch sign
                        ;and     $80                               ; .
                        ;xor $80
                        ld      b,a                                ; b = roof product
                        ld      a,l                                ; a = abs sidev  * 2
                        sla     a                                  ;
                        JumpIfAGTENusng 16,.skipRollZero           ;
                        ZeroA                                      ; if its zoer then set rotx to zero
                        or      b
                        ld      (UBnKRotXCounter),a
                        IFDEF MISSILEDEBUG
                            ld  (TacticsRotX),a
                        ENDIF
                        ret
.skipRollZero:          ld      a,2
                        or      h
                        xor     b
                        ld      (UBnKRotXCounter),a
                        IFDEF MISSILEDEBUG
                            ld  (TacticsRotX),a
                        ENDIF
                        ret

SimplifiedShipSpeedv3:  call    GetDistance                         ;
                        ld      a,h
                        and     a
                        ld      b,22
                        jr      nz,.NotSlow
.CloseSlowTest:         ld      a,l
                        JumpIfAGTENusng 30, .NotSlow
                        ld      b,60
.NotSlow:               ld      hl,(TacticsDotProduct1)             ; if nosedir is negative (pointing the wrong way)
                        ld      a,h                                 ; or nosedir < 22 (very far off)
                        and     $80                                 ; do decelleration test
                        jp      nz,.DecelTest                       ; .
                        ld      a,l                                 ; .
                        JumpIfALTNusng b, .DecelTest               ; .
.Accelerate:            ld      a,1;3                                 ; else
                        ld      (UBnKAccel),a                       ;  accelleration = 3
                        IFDEF MISSILEDEBUG
                            ld  (TacticsSpeed),a
                        ENDIF                        
                        ret                                         ;  .
.DecelTest:             ld      a,l                                 ; if abs acelleration > 18
                        JumpIfAGTENusng 18 ,.Deccelerate             ;    decelerate by 2 
.NoSpeedChange:         ZeroA                                       ; else no change
                        ld      (UBnKAccel),a
                        IFDEF MISSILEDEBUG
                            ld  (TacticsSpeed),a
                        ENDIF
                        ret
.Deccelerate:           ld      a,-2
                        ld      (UBnKAccel),a
                        IFDEF MISSILEDEBUG
                            ld  (TacticsSpeed),a
                        ENDIF
                        ret

GetDistance:            ld      hl,(TacticsVectorX)
                        ld      de,(TacticsVectorY)
                        ld      bc,(TacticsVectorZ)
                        ld      a,h
                        and     $7F
                        ld      h,a
                        ld      a,b
                        and     $7F
                        ld      b,a
                        ld      a,d
                        and     $7F
                        ld      d,a
                        add     hl,bc
                        add     hl,de
                        ShiftHLRight1
                        ShiftHLRight1
                        ret
                        
                        