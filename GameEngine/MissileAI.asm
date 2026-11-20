                        DEFINE MISSILEDEBUG 1
                        DEFINE MISSILEDOHIT 1

MISSILEMAXACCEL         equ 3
MISSILEMAXDECEL         equ -3
MissileLifespan         equ 500                     ; frames at 50Hz (FrameCounter16) = 10 seconds, then the missile self destructs
MissileHitPlayer        equ $FE                     ; MissileDirectHitSlot values other than a slot number
MissileNoDirectHit      equ $FF                     ; .
                        ;DEFINE MISSILEBREAK
;.. Thsi version uses new kind logic
;... Now the tactics if current ship is the missile, when we enter this SelectedUniverseSlot holds slot of missile
; Positions are S15.8 lead sign (lo = fraction, hi + sign byte bits 0-6 = 15 bit integer, sign byte bit 7 = sign).
; The missile - target vector is S15.8 (saturating at +/-32767.996) and NormalizeTactics scales it down to S7
MissileAIV3:            ;ld      a,(ShipAIEnabled)
.IsAlreadyExploding:    IsShipExploding                             ; blast has already been applied when it exploded
                        ret     nz                                  ; .
.CheckLifespan:         ld      hl,(FrameCounter16)                 ; elapsed = now - launch frame (16 bit so wrap safe)
                        ld      de,(UBnKMissileLaunchFrame)         ; .
                        or      a                                   ; .
                        sbc     hl,de                               ; .
                        ld      de,MissileLifespan                  ; if elapsed >= lifespan then self destruct
                        or      a                                   ; .
                        sbc     hl,de                               ; .
                        jp      nc,.ECMIsActive                     ; .
.CheckForECM:           JumpIfMemNotZero ECMCountDown,.ECMIsActive  ; If ECM is running then kill the missile
.IsMissileHostile:      IsShipHostile                               ; is missle attacking us?
                        JumpIfZero .MissileTargetingShip            ; Missile is friendly then z is set else targetting us
.MissileTargetingPlayer:call    MissileHitUsCheckPos                ; within 1.0 of us on every axis
.MissileNotHitUsYet:    jp      nc, .UpdateTargetingUsPos
.MissleHitUs:           call    PlayerHitByMissile                  ; direct hit damages us (blast range is smaller than hit range)
                        ld      a,MissileHitPlayer                  ; so the blast skips us
                        jp      .DirectHitExplode                   ; explode
.UpdateTargetingUsPos:  call    SetPlayerAsTarget
                        call    CopyPosToVector                     ; vector = missile - us (us = 0,0,0), S15.8
                        ld      a,(SelectedUniverseSlot)            ; we will use this quite a lot with next bank switching
                        add     a,BankUNIVDATA0                     ; pre calculate add to optimise
                        ld      iyh,a
                        jp      .NormaliseDirection
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
                        ld      a,(UBnKMissileTarget)               ; slot number for the empty check
.IsMissleTargetGone:    JumpIfSlotAEmpty    .ECMIsActive            ; if the target was blown up then detonate
.SelectTargetShip:      SelectTargetBank
.IsShipExploding:       IsShipExploding                             ; check exploding status
                        jr      z,.UpdateTargetingShipX             ; as if exploding then the missile will also explode
.ShipIsExploding:       SelectMissileBank                           ; get missile back into memory
                        jp      .ECMIsActive
;--- At this point we already have the target banked in ready for calculating vector
; Tactics vector = missile - target, S15.8: AHL = BHL + CDE with the target sign flipped
.UpdateTargetingShipX:  MMUSelectMathsBankedFns                     ; for AHLequBHLplusCDE, universe banks are in a different slot
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
                        call    MissileVectorAdd                    ; AHL = BHL + CDE i.e. missile - target x (S15.8)
                        ld      (TacticsVectorX),hl
                        ld      (TacticsVectorX+2),a
.UpdateTargetingShipY:  SelectTargetBank
                        ld      de,(UBnKylo)                        ; get target ship Y
                        ld      a,(UBnKysgn)
                        IFDEF MISSILEDEBUG
                            ld  (TacticsTargetY),de
                            ld  (TacticsTargetY+2),a
                        ENDIF
                        FlipSignBitA
                        ld      c,a                                 ; get target ship y sign but * -1 as we are subtracting
                        SelectMissileBank
                        ld      hl,(UBnKylo)                        ; get missile y
                        ld      a,(UBnKysgn)                        ; get missile y sign
                        IFDEF MISSILEDEBUG
                            ld  (TacticsMissileY),hl
                            ld  (TacticsMissileY+2),a
                        ENDIF
                        ld      b,a
                        call    MissileVectorAdd                    ; AHL = BHL + CDE i.e. missile - target y (S15.8)
                        ld      (TacticsVectorY),hl
                        ld      (TacticsVectorY+2),a
.UpdateTargetingShipZ:  SelectTargetBank
                        ld      de,(UBnKzlo)                        ; get target ship Z
                        ld      a,(UBnKzsgn)
                        IFDEF MISSILEDEBUG
                            ld  (TacticsTargetZ),de
                            ld  (TacticsTargetZ+2),a
                        ENDIF
                        FlipSignBitA
                        ld      c,a                                 ; get target ship z sign but * -1 as we are subtracting
                        SelectMissileBank
                        ld      hl,(UBnKzlo)                        ; get missile z
                        ld      a,(UBnKzsgn)                        ; get missile z sign
                        IFDEF MISSILEDEBUG
                            ld  (TacticsMissileZ),hl
                            ld  (TacticsMissileZ+2),a
                        ENDIF
                        ld      b,a
                        call    MissileVectorAdd                    ; AHL = BHL + CDE i.e. missile - target z (S15.8)
                        ld      (TacticsVectorZ),hl
                        ld      (TacticsVectorZ+2),a
; by here missile in in memory and TacticsVector now holds distance
.CheckDistance:         IFDEF MISSILEDOHIT
                            ld      hl,(TacticsVectorX+1)              ; l = hi byte, h = sign byte of each axis
                            ld      a,h                                ; .
                            ld      de,(TacticsVectorY+1)              ; .
                            or      d                                  ; .
                            ld      bc,(TacticsVectorZ+1)              ; .
                            or      b                                  ; .
                            ClearSignBitA                              ; sign byte magnitude bits (integer bits 8-14)
                            JumpIfNotZero       .FarAway               ; .
                            or      l                                  ; hi bytes (integer bits 0-7), so a hit is |d| < 1.0 on every axis (as BBC)
                            or      e                                  ; .
                            or      c                                  ; .
                            JumpIfNotZero       .FarAway               ; .
                        ELSE
                            jp                  .FarAway
                        ENDIF
; If we get here its close enough to detonate (|d| < 1.0 on every axis). The blast range (0.2) is smaller than the hit
; range so the target takes the detonate damage directly and MissileBlast skips it. A space station is immune but is angered
.CloseMissileExplode:   ld      a,(UBnKMissileDetonateDamage)       ; missile is paged in, b = damage
                        ld      b,a                                 ; .
                        SelectTargetBank                            ; page in target (only uses a)
                        ld      a,(ShipTypeAddr)                    ; .
                        cp      ShipTypeStation                     ; .
                        jr      z,.TargetIsStation                  ; .
                        call    ShipTakeDamageB                     ; reduce energy, explode target if exhausted
                        jr      .TargetHitDone                      ; .
.TargetIsStation:       call    SetShipHostile                      ; .
.TargetHitDone:         SelectMissileBank                           ; missile back in memory
                        ld      a,(UBnKMissileTarget)               ; blast must not damage the target again
                        jp      .DirectHitExplode                   ; and explode it
.FarAway:               SelectTargetBank
                        JumpIfMemFalse      UBnKECMFitted, .NoECM                   ; if target has ECM and enough energy to use it
                        JumpIfMemLTNusng    UBnKEnergy,    ECMCounterMax, .NoECM    ; .
                        JumpIfMemIsNotZero   ECMCountDown, .NoECM                ; . ECM is already active
.TestIfUsingECM:        call    doRandom                                                    ; if random < 16 (uses a c hl only)
                        JumpIfAGTENusng     16, .UpdateMissilePos                           ;   then fire ECM destroying missile
;. If we get here then target is still paged in to fire ECM
.ZeroPageFireECM:       jp      FireECM                                             ; with an implicit return
;                       implicit ret
;. If we get here then target is still paged in with no ECM
.NoECM:
;--- Now we can actually update the missile AI
.UpdateMissilePos:      SelectMissileBank
.NormaliseDirection:    IFDEF MISSILEBREAK
                        ENDIF
                        MMUSelectMathsBankedFns
                        call    NormalizeTactics                    ; Normalise S15.8 vector down to 7 bit + sign byte (.TA19->TAS2)
.NegateDirection:       FlipSignMem TacticsVectorX+2                ; negate vector so it is target - missile, i.e. points from
                        FlipSignMem TacticsVectorY+2                ; the missile to the target; all dot products are taken after
                        FlipSignMem TacticsVectorZ+2                ; this so +ve nose dot means facing the target
                        call    SeekingLogic
                        ret
;. Missile bank must be paged in. Explodes the missile and applies its blast to us and all ships in range. On entry to
;. .DirectHitExplode a = slot that was hit directly ($FE = us) which has already been damaged so the blast skips it
.ECMIsActive:           ld      a,MissileNoDirectHit                ; ECM or lifespan, nothing hit directly
.DirectHitExplode:      ld      (MissileDirectHitSlot),a            ; .
                        call    UnivExplodeShip                     ; detonate missile
                        jp      MissileBlast                        ; splash damage, implicit ret
;----------------------------------------------------------------------------------------------------------------------------------
; AHL = BHL + CDE in S15.8 lead sign, saturating. AHLequBHLplusCDE does not detect overflow: with the same signs a magnitude
; sum >= 32768.0 carries into bit 7 and flips the sign, which would point the missile the wrong way. Opposite signs can not
; overflow. On overflow the result is clamped to B's sign with the maximum magnitude (direction is all that matters then).
; Needs the maths banked fns paged in. Destroys C and DE, preserves B
MissileVectorAdd:       ld      a,b
                        xor     c
                        jp      m,AHLequBHLplusCDE                  ; opposite signs, can not overflow, implicit ret
                        call    AHLequBHLplusCDE
                        ld      c,a                                 ; did the sign change
                        xor     b                                   ; .
                        ld      a,c                                 ; .
                        ret     p                                   ; no so no overflow
                        ld      a,b                                 ; overflow so saturate
                        or      SignMask8Bit                        ; .
                        ld      hl,$FFFF                            ; .
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
SeekingLogic:           call    XX12EquTacticsDotNosev              ; SA = nose . XX15                           (     ->TAS3)
                        ld      (TacticsDotProduct1),a              ; CNT = A (high byte of dot product)
                        ld      a,(varS)                            ; get sign from dot product
                        ld      (TacticsDotProduct1+1),a            ; nose direction sign, read by the speed logic and pitch
.RoofDotProduct:        call    XX12EquTacticsDotRoofv              ; Now tran the roof for rotation        
                        ld      (TacticsDotProduct2),a              ; so if its +ve then the roof is similar so pull up to head towards it
                        ld      a,(varS)                            ; .                                       
                        ld      (TacticsDotProduct2+1),a            ; Note here its direction not dir
                        call    SimplifiedShipPitchv3
                        call    SimplifiedShipRollv3
                        call    SimplifiedShipSpeedv3
                        ret
                       
SimplifiedShipPitchv3:  ;break
                        ld      hl,(TacticsDotProduct2)            ; pitch counter sign = opposite sign to roofdir sign
                        ld      a,h                                ; .
                        xor     $80                                ; .
                        and     $80                                ; .
                        ld      h,a                                ; h  = flipped sign
                        ld      a,(UBnKRAT2)                       ; b = turn threshold (RAT2, 4 for missiles as BBC)
                        ld      b,a                                ; .
                        ld      a,l                                ; a = value * 2
                        sla     a                                  ;
                        JumpIfAGTENusng b, .skipPitchZero          ; if |roof dot| * 2 >= RAT2 then update pitch
                        ld      a,(TacticsDotProduct1+1)           ; if the target is behind (nose dot negative) keep pitching,
                        and     $80                                ; else with the target near the tail the roof and side dots
                        jr      nz,.skipPitchZero                  ; stay under the threshold and the missile never turns round
                        ZeroA                                      ; else we zero pitch but
                        or      h                                  ; we need to retain the sign
                        ld      (UBnKRotZCounter),a                ; .
                        IFDEF MISSILEDEBUG
                            ld  (TacticsRotZ),a
                        ENDIF
                        ret
.skipPitchZero:         ld      a,(UBnKRAT)                        ; pitch magnitude (RAT)
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
                        call    XX12EquTacticsDotSidev             ; calculate side dot protuct
                        ld      (TacticsDotProduct3),a             ; .
                        ld      l,a                                ; .
                        ld      a,(varS)                           ; .
                        ld      (TacticsDotProduct3+1),a           ; .
                        ld      h,a                                ; h = sign sidev
                        ld      a,(TacticsDotProduct2+1)           ; get flipped pitch counter sign
                        ld      b,a                                ; b = roof product sign
                        ld      a,(UBnKRAT2)                       ; c = turn threshold
                        ld      c,a                                ; .
                        ld      a,l                                ; a = abs sidev  * 2
                        sla     a                                  ;
                        JumpIfAGTENusng c,.skipRollZero            ; if |side dot| * 2 >= RAT2 then roll
                        ZeroA                                      ; if its zoer then set rotx to zero
                        or      b
                        ld      (UBnKRotXCounter),a
                        IFDEF MISSILEDEBUG
                            ld  (TacticsRotX),a
                        ENDIF
                        ret
.skipRollZero:          ld      a,(UBnKRAT)                        ; roll magnitude (RAT)
                        or      h                                  ; sign = side sign xor roof sign (as BBC)
                        xor     b
                        ld      (UBnKRotXCounter),a
                        IFDEF MISSILEDEBUG
                            ld  (TacticsRotX),a
                        ENDIF
                        ret

SimplifiedShipSpeedv3:  ld      hl,(TacticsDotProduct1)
                        ld      a,h
                        and     a
                        jr      nz,.SlowDown                        ; target behind
                        ld      a,(UBnKCNT2)                        ; b = accelerate threshold (CNT2, 22 for missiles)
                        ld      b,a                                 ; .
                        ld      a,l                                 ; nose dot product +ve so facing target
                        JumpIfALTNusng  b,.SlowDown                 ; nose dot product < CNT2 so not facing closely enough
.Accelerate:            ld      a,3                                 ; else
                        ld      (UBnKAccel),a                       ;  accelleration = 3
                        IFDEF MISSILEDEBUG
                            ld  (TacticsSpeed),a
                        ENDIF                        
                        ret                                         ;  .
.SlowDown:              ld      a,l                                 ; abs nose dot product (a held the sign byte on the -ve path)
                        JumpIfALTNusng 18, .NoSpeedChange
.Deccelerate:           ld      a,-2
                        ld      (UBnKAccel),a
                        IFDEF MISSILEDEBUG
                            ld  (TacticsSpeed),a
                        ENDIF
                        ret
.NoSpeedChange:         ZeroA                                       ; else no change
                        ld      (UBnKAccel),a
                        IFDEF MISSILEDEBUG
                            ld  (TacticsSpeed),a
                        ENDIF
                        ret

