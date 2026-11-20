
;                       DEFINE ALWAYSANGRY 1
;                        DEFINE TARGETDEBUG 1
MISSILEMAXPITCH         equ 3
MISSILEMINPITCH         equ -3
MISSILEMAXROLL          equ 3
MISSILEMINROLL          equ -3
;Ship Tactics
; To be added
;ShipTypeTargoid
;ShipTypeHermit
; Maybe add the followign with ai flags changing in memory shiptype
;ShipTypePirate
;ShipTypeBountyHunter
;ShipTypeTrader
;ShipType.....
;ShipTypeMissionTypeA
;ShipTypeMissionTypeB
;ShipTypeMissionTypeETC
;ShipTypeNoAI


ShipAIJumpTable:      DW    NormalAI,   MissileAIV3,  StationAI,  JunkAI,     ScoopableAI
                      DW    ThargoidAI, NoAI,       NoAI,       NoAI,       NoAI
ShipAiJumpTableMax:   EQU ($ - ShipAIJumpTable)/2


;----------------------------------------------------------------------------------------------------------------------------------
; Main entry point to tactics. Every time it will do a a tidy and the do AI logic
UpdateShip:             ;  call    DEBUGSETNODES ;       call    DEBUGSETPOS
                       ; This shoudl be a call nz to tidy *****ret     nz
                       ; add AI in here too
.SkipBreak:            ld       a,(ShipTypeAddr)
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


StationAI:              ret
JunkAI:                 ret
ScoopableAI:            ret
ThargoidAI:             ret
NoAI:                   ret
;----------------------------------------------------------------------------------------------------------------------------------
CalculateAgression:     IFDEF   ALWAYSANGRY
                            jp  UltraHostile
                        ENDIF
                        ld      a,(ShipAIFlagsAddr)
                        ld      b,a
                        and     %00000010
                        jr      nz,.UltraHostile
                        ld      a,b
                        and     %11110000                               ; if it can can anger a fighter bay then generally more hostile as implies its a large ship
                        ld      hl,UBnKMissilesLeft                     ; more missiles more agression
                        or      (hl)
                        ld      b,a                       
                        ld      a,(ShipNewBitsAddr)
                        and     %01001110                               ; We look at if its a bounty hunter, hostile already, pirate and cop
                        or      b
                        ld      b,a
                        ld      a,(UBnKShipAggression)
                        JumpIfALTNusng 64,.NotAlreadyAgressive
                        ld      a,b
                        or      %10000000                               ; if its already at least 64 agressive then likley to stay so
                        ld      b,a
.NotAlreadyAgressive:   ld      a,b
                        ld      (UBnKShipAggression),a
                        ret
.UltraHostile:          ld      a,$FF
                        ld      (UBnKShipAggression),a
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; set angry if possible, if its an innocent then flag the space station to get angry
MakeHostile:            ld      a,(ShipNewBitsAddr)                     ; Check bit 5 of newb flags
                        JumpIfMemEqNusng ShipTypeAddr, ShipTypeStation, .SetNewbHostile
.ItsNotAStation:        and     ShipIsBystander                         ; check if space station present if its a bystander
                        call    nz, SetStationHostile                   ; Set Space Station if present, Angry
                        IsAIEnabled                                     ; get AI data
                        ret     z                                       ; if 0 then no AI attached so it can't get angry
                        ld      c,a                                     ; Copy to c in case we need it later
                        SetMemToN UBnKAccel, 2                          ; set accelleration to 2 to speed up
                        sla     a                                       ; set pitch to 4
                        ld      (UBnKRotZCounter),a                     ; .
                        ld      a,(ShipAIFlagsAddr)
                        ReturnIfBitMaskClear ShipCanAnger
.SetNewbHostile:        call    SetShipHostile
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
PlayerHitByMissile:     MMUSelectLayer1
                        ld      a,L1ColourInkCyan
                        call    l1_set_border
                        ld      a,(UBnKMissileBlastDamage)
                        ld      b,a                                     ; b = damage
                        ld      a,(UBnKzsgn)
                        and     $80
                        jr      nz,.HitRear
.HitFront:              ld      a,(ForeShield)
                        call    ApplyDamage
                        ld      (ForeShield),a
                        ret
.HitRear:               ld      a,(AftShield)
                        call    ApplyDamage
                        ld      (AftShield),a  
                        ret; TODO , do hit set up blast radius etc
;----------------------------------------------------------------------------------------------------------------------------------
SetStationHostile:      call    IsSpaceStationPresent                   ; only if present
                        ret     c
                        ld      a,(UbnKShipUnivBankNbr)                     ; save current bank
                        ld      iyh,a
                        MMUSelectUniverseN 0                            ; space station is always 0
                        call    SetShipHostile
                        ld      a,iyh                                   ; get prev bank back
                        MMUSelectUniverseA                              ;
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
; Missile blast (splash damage). Call with the exploding missile's bank paged in (it must already be flagged exploding so it
; skips itself). Applies UBnKMissileBlastDamage to us and to every ship with |distance| < UBnKMissileBlastRange on every axis.
; The range is a fraction in 1/256ths (S15.8 lo byte, so 0.0 to 0.996), e.g. 51 = 0.2. Space stations are immune.
; MissileDirectHitSlot (slot, MissileHitPlayer or MissileNoDirectHit) is skipped as a direct hit has already been damaged
; The missile bank (SelectedUniverseSlot) is paged back in on exit. Preserves ix and iy.
MissileBlast:           push    ix,,iy
                        ld      hl,UBnKxlo                          ; copy blast position
                        ld      de,MissileXPos                      ; .
                        ld      bc,3*3                              ; .
                        ldir                                        ; .
                        ld      hl,UBnKMissileBlastRange            ; and blast stats (range, damage, detonate range and damage)
                        ld      de,CurrentMissileBlastRange         ; .
                        ld      bc,4                                ; .
                        ldir                                        ; .
.CheckPlayer:           ld      a,(MissileDirectHitSlot)            ; were we hit directly
                        cp      MissileHitPlayer                    ; .
                        jr      z,.SkipPlayer                       ; .
                        call    BlastInRangeOfPlayer                ; are we in the blast
                        call    c,PlayerHitByMissile                ; .
.SkipPlayer:            ZeroA                                       ; check every universe slot
.SlotLoop:              ld      (CurrentMissileCheck),a             ; .
                        ld      hl,MissileDirectHitSlot             ; skip the ship hit directly
                        cp      (hl)                                ; .
                        jp      z,.NextSlot                         ; .
                        JumpIfSlotAEmpty .NextSlot                  ; .
                        ld      a,(CurrentMissileCheck)             ; page in the ship
                        MMUSelectUniverseA                          ; .
                        IsShipExploding                             ; already exploding (this includes the missile itself)
                        jp      nz,.NextSlot                        ; .
                        ld      a,(UBnKexplDsp)                     ; or destroyed
                        and     %10100000                           ; .
                        jp      nz,.NextSlot                        ; .
                        ld      a,(ShipTypeAddr)                    ; stations are immune
                        cp      ShipTypeStation                     ; .
                        jp      z,.NextSlot                         ; .
                        ld      ix,UBnKxlo                          ; is it in blast range
                        ld      iy,MissileXPos                      ; .
                        MMUSelectMathsBankedFns : call CheckInCollisionRange
                        call    c,ShipMissileBlast                  ; reduce energy and explode if exhausted
.NextSlot:              ld      a,(CurrentMissileCheck)
                        inc     a
                        cp      UniverseSlotListSize
                        jp      c,.SlotLoop
                        ld      a,(SelectedUniverseSlot)            ; page the missile back in
                        MMUSelectUniverseA                          ; .
                        pop     ix,,iy
                        ret
;...................................................................
; Carry set if the missile (paged in, S15.8 position relative to us) is |d| < CurrentMissileBlastRange (1/256ths) on every
; axis, i.e. integer part 0 and fraction (lo byte) < range
BlastInRangeOfPlayer:   ld      a,(CurrentMissileBlastRange)
                        ld      c,a
                        ld      hl,UBnKxlo
                        ld      b,3
.AxisLoop:              ld      a,(hl)                              ; lo byte = fraction
                        cp      c                                   ; .
                        ret     nc                                  ; >= range so out of range, carry clear
                        inc     hl                                  ; hi byte = integer bits 0-7 must be 0
                        ld      a,(hl)                              ; .
                        and     a                                   ; .
                        ret     nz                                  ; and clears carry
                        inc     hl                                  ; sign byte, integer bits 8-14 must be 0
                        ld      a,(hl)                              ; .
                        and     SignMask8Bit                        ; .
                        ret     nz                                  ; and clears carry
                        inc     hl                                  ; next axis lo byte
                        djnz    .AxisLoop
                        scf
                        ret
;...................................................................
; Carry set if the missile is |d| < 1.0 from us on every axis, i.e. S15.8 integer part 0 (hi and sign bits 0-6, as BBC)
MissileHitUsCheckPos:   ld      a,(UBnKxsgn)
                        ld      hl,UBnKysgn
                        or      (hl)
                        ld      hl,UBnKzsgn
                        or      (hl)
                        and     SignMask8Bit                        ; integer bits 8-14 of each axis
                        ld      hl,UBnKxhi
                        or      (hl)
                        ld      hl,UBnKyhi
                        or      (hl)
                        ld      hl,UBnKzhi
                        or      (hl)                                ; or clears carry
                        ret     nz                                  ; too far, carry clear
                        scf                                         ; hit
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
                        INCLUDE "../GameEngine/NormalAI.asm"

; On Entry A = TacticsDotProduct2 sign (i.e. roof direction)
; on exit a == new roll
calcNPitch:             xor     SignOnly8Bit                    ; c = sign flipped of dot product only
                        and     SignOnly8Bit                    ; .
                        ld      c,a                             ; . (varT in effect)
                        or      MISSILEMAXPITCH                 ; a = flipped sign max pitch
                        ld      a,(UBnKRotZCounter)             ; b = abs (currentz pitch)
                        ret
                        
                        and     SignMask8Bit                    ; . which will initially be 0
                        ld      b,a                             ; .
                        ld      a,(TacticsDotProduct2)          ; a = abs roof dot product
                        JumpIfALTNusng MISSILEMAXPITCH+1, .calcNPitch2    ; if a >= roll threshold
                        ld      a,b
                        and     SignOnly8Bit
                        ld      a,MISSILEMAXPITCH                         ;    z rot = z rot * dot product flipped sign
                        or      c                               ;    i.e. zrot = current magnitude but dot product sign flipped
                        ld      (UBnKRotZCounter),a             ;    .
                        ret                                     ; else (a LT current abs z)
.calcNPitch2:           or      c                               ;     rot z = dot product with sign flipped
                        ld      (UBnKRotZCounter),a             ;
                        ret                                     ;
                        
calcNRoll:              ld      a,(UBnKRotZCounter)
                        and     SignOnly8Bit
                        xor     SignOnly8Bit                    ; flip sign of dot product
                        or      5
                        ld      (UBnKRotXCounter),a
                        ret
                        
                        ld      c,a
                        or      MISSILEMAXPITCH   
                        ld      a,(UBnKRotXCounter)
                        ret
                        
                        
                        and     SignMask8Bit                    ; get ABS value
                        ld      b,a
                        ld      a,(TacticsDotProduct2)          ; now we have the dot product abs value
                        JumpIfALTNusng MISSILEMAXROLL+1, .calcNRoll2
                        ld      a,MISSILEMAXROLL
                        or      c
                        ld      (UBnKRotXCounter),a
                        ret
.calcNRoll2:            or      c                               ;     rot z = dot product with sign flipped
                        ld      (UBnKRotXCounter),a
                        ret


CopyRotSideToTacticsMat:ld      hl,UBnkrotmatSidevX+1
                        jp      CopyRotmatToTacticsMat
                        
CopyRotNoseToTacticsMat:ld      hl,UBnkrotmatNosevX+1
                        jp      CopyRotmatToTacticsMat
                        
CopyRotRoofToTacticsMat:ld      hl,UBnkrotmatRoofvX+1
; Coy rotation matrix high byte to trans rot mat, strip off sign and separate to rotmat byte 2
CopyRotmatToTacticsMat: ld      de,TacticsRotMatX
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

XX12EquTacticsDotNosev: call    CopyRotNoseToTacticsMat
XX12EquTacticsDotHL:    ld      hl,TacticsRotMatX; UBnkTransmatNosevX    ; ROTMATX HI
.CalcXValue:            ld      a,(hl)                              ; DE = RotMatX & Vect X
                        ld      e,a                                 ; .
                        ld      a,(TacticsVectorX)                  ; .
                        ld      d,a                                 ; .
                        mul                                         ; .
                        ld      a,d                                 ; S = A = Hi (RotMatX & Vect X)
                        ld      (varS),a                            ; .
                        inc     hl                                  ; move to sign byte
.CalcXSign:             ld      a,(TacticsVectorX+2)                ; B  = A = Sign VecX xor sign RotMatX
                        xor     (hl)                                ; .
                        ld      b,a                                 ; .
.MoveToY:               inc     hl                                  ; Move on to Y component
.CalcYValue:            ld      a,(hl)                              ; D = 0, E = Hi (RotMatY & Vect Y)
                        ld      e,a                                 ; .
                        ld      a,(TacticsVectorY)                  ; .
                        ld      d,a                                 ; .
                        mul     de                                  ; .
                        ld      e,d                                 ; .
                        ld      d,0                                 ; .
                        inc     hl                                  ; move to sign byte
.CalcYSign:             ld      a,(TacticsVectorY+2)                ; c = sign of y_sign * sidev_y
                        xor     (hl)                                ; 
                        ld      c,a                                 ; 
.MoveToZ:               inc     hl                                  ; Move on to Z component
.AddXandY:              push    hl                                  ; but save HL as we need that
                        ld      a,(varS)                            ; hl = Hi (RotMatX & Vect X) b= sign
                        ld      h,0                                 ; de = Hi (RotMatY & Vect Y) c= sign
                        ld      l,a                                 ;
                        call    ADDHLDESignBC                       ; a(sign) hl = sum
                        ld      b,a                                 ; b = sign of result
                        ld      (TacticsVarResult),hl               ; save sub in TacticsVarResult
.CalcZValue:            pop     hl                                  ; get back to the rotation mat z
                        ld      a,(hl)                              ; D = 0, E = Hi (RotMatZ & Vect Z)
                        ld      e,a                                 ; .
                        ld      a,(TacticsVectorZ)                  ; .
                        ld      d,a                                 ; .
                        mul     de                                  ; .
                        ld      e,d                                 ; .
                        ld      d,0                                 ; .
                        inc     hl                                  ; move to sign byte
.CalcZSign:             ld      a,(TacticsVectorZ+2)
                        xor     (hl)
                        ld      c,a                                 ; Set C to the sign of z_sign * sidev_z
                        ld      hl, (TacticsVarResult)              ; CHL = x + y, BDE = z products
                        call    ADDHLDESignBC                       ; so AHL = X y z products
                        ld      (varS),a                            ; for backwards compatibility
                        ld      a,l                                  ; .
                        ret

XX12EquTacticsDotRoofv: call    CopyRotRoofToTacticsMat
                        jp      XX12EquTacticsDotHL
                        
XX12EquTacticsDotSidev: call    CopyRotSideToTacticsMat
                        jp      XX12EquTacticsDotHL

CopyToTargetVector:     ld      hl,UBnKxlo
                        ld      de,TacticsTargetX
                        ld      bc,9
                        ldir    
                        ret

; Copies 24 bit XYZ Vector to tactics vectors
CopyPosToVector:        ld      hl,(UBnKxlo)
                        ld      a,(UBnKxsgn)
                        ld      (TacticsVectorX),hl
                        ld      (TacticsVectorX+2),a

.CopyY24Bit:            ld      hl,(UBnKylo)
                        ld      a,(UBnKysgn)
                        ld      (TacticsVectorY),hl
                        ld      (TacticsVectorY+2),a

.CopyZ24Bit:            ld      hl,(UBnKzlo)
                        ld      a,(UBnKzsgn)
                        ld      (TacticsVectorZ),hl
                        ld      (TacticsVectorZ+2),a
                        ret

SetPlayerAsTarget:      ZeroA
                        ld      hl,TacticsTargetX
                        ld      b, 3*3
.ZeroLoop:              ld      (hl),a                              ; player is always at 0,0,0
                        inc     hl
                        djnz    .ZeroLoop
                        ret

CalcVectorToMyShip:     call    SetPlayerAsTarget
                        call    CopyPosToVector
                        ret
                                              
                        
;-- Now its scaled we can normalise
;-- Scale down so that h d &b are zero, then do once again so l e and c are 7 bit
;-- use 7 bit mul96 to ensure we don;t get odd maths
; Moved to Maths BankNormalizeTactics:       ld      hl, (TacticsVectorX)        ; pull XX15 into registers
; Moved to Maths Bank                        ld      de, (TacticsVectorY)        ; .
; Moved to Maths Bank                        ld      bc, (TacticsVectorZ)        ; .
; Moved to Maths Bank.ScaleLoop:             ld      a,h
; Moved to Maths Bank                        or      d
; Moved to Maths Bank                        or      b
; Moved to Maths Bank                        jr      z,.DoneScaling
; Moved to Maths Bank                        ShiftHLRight1
; Moved to Maths Bank                        ShiftDERight1
; Moved to Maths Bank                        ShiftBCRight1
; Moved to Maths Bank                        jp      .ScaleLoop
; Moved to Maths Bank.DoneScaling:           ShiftHLRight1                       ; as the values now need to be sign magnitued
; Moved to Maths Bank                        ShiftDERight1                       ; e.g. S + 7 bit we need an extra shift
; Moved to Maths Bank                        ShiftBCRight1                       ; now values are in L E C
; Moved to Maths Bank                        push    hl,,de,,bc                  ; save vecrtor x y and z nwo they are scaled to 1 byte
; Moved to Maths Bank                        ld      d,e                         ; hl = y(e) ^ 2
; Moved to Maths Bank                        mul     de                          ; .
; Moved to Maths Bank                        ex      de,hl                       ; .
; Moved to Maths Bank                        ld      d,e                         ; de = x(l) ^ 2
; Moved to Maths Bank                        mul     de                          ; .
; Moved to Maths Bank                        add     hl,de                       ; hl = hl + de
; Moved to Maths Bank                        ld      d,c                         ; de = y(c)^ 2 + x ^ 2
; Moved to Maths Bank                        ld      e,c                         ; .
; Moved to Maths Bank                        mul     de                          ; .
; Moved to Maths Bank                        add     hl,de                       ; hl =  y^ 2 + x ^ 2 + z ^ 2
; Moved to Maths Bank                        ex      de,hl                       ; fix as hl was holding square
; Moved to Maths Bank                        call    asm_sqrt                    ; IYH = A = hl = sqrt (de) = sqrt (x ^ 2 + y ^ 2 + z ^ 2)
; Moved to Maths Bank                        ; add in logic if h is low then use lower bytes for all 
; Moved to Maths Bank                        ld      a,l                         ;
; Moved to Maths Bank                        ld      iyh,a                       ;
; Moved to Maths Bank                        ld      d,a                         ; D = sqrt
; Moved to Maths Bank                        pop     bc                          ; retrive tacticsvectorz scaled
; Moved to Maths Bank                        ld      a,c                         ; a = scaled byte
; Moved to Maths Bank                        call    AequAdivDmul967Bit;AequAdivDmul96Unsg          ; This rountine I think is wrong and retuins bad values
; Moved to Maths Bank                        ld      (TacticsVectorZ),a          ; z = normalised z
; Moved to Maths Bank                        pop     de
; Moved to Maths Bank                        ld      a,e
; Moved to Maths Bank                        ld      d,iyh                        
; Moved to Maths Bank                        call    AequAdivDmul967Bit;AequAdivDmul96Unsg
; Moved to Maths Bank                        ld      (TacticsVectorY),a
; Moved to Maths Bank                        pop     hl
; Moved to Maths Bank                        ld      a,l
; Moved to Maths Bank                        ld      d,iyh                        
; Moved to Maths Bank                        call    AequAdivDmul967Bit;AequAdivDmul96Unsg
; Moved to Maths Bank                        ld      (TacticsVectorX),a
; Moved to Maths Bank                        ; BODGE FOR NOW
; Moved to Maths Bank                       ; BODGE FOR NOW
; Moved to Maths Bank                        ZeroA                              ;; added to help debugging
; Moved to Maths Bank                        ld      (TacticsVectorX+1),a       ;; added to help debugging
; Moved to Maths Bank                        ld      (TacticsVectorY+1),a       ;; added to help debugging
; Moved to Maths Bank                        ld      (TacticsVectorZ+1),a       ;; added to help debugging
; Moved to Maths Bank                        SignBitOnlyMem TacticsVectorX+2     ; now upper byte is sign only
; Moved to Maths Bank                        SignBitOnlyMem TacticsVectorY+2     ; (could move it to lower perhaps later if 
; Moved to Maths Bank                        SignBitOnlyMem TacticsVectorZ+2     ;  its worth it)
; Moved to Maths Bank                        ret

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
