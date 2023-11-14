
                        DEFINE TACTICSDEBUG 1
;                       DEFINE ALWAYSANGRY 1
;                        DEFINE TARGETDEBUG 1
MISSILEMAXPITCH         equ 3
MISSILEMINPITCH         equ -3
MISSILEMAXROLL          equ 3
MISSILEMINROLL          equ -3
;Ship Tactics
;ShipTypeNormal          equ 0
;ShipTypeMissile         equ 1
;ShipTypeStation         equ 2
;ShipTypeJunk            equ 3
;ShipTypeScoopable       equ 4         ; a sub set of junk
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
                       ld      hl,TidyCounter
                       dec     (hl)
                       DISPLAY "TODO: SEE IF THIS IS AN ISSUE"
                       call     z,TidyUBnk  ;TODO SEE IF THIS IS AN ISSUE"
                       ; This shoudl be a call nz to tidy *****ret     nz
                       ld      a,16
                       ld      (TidyCounter),a
                       ;call    TidyUBnk
                       ; add AI in here too
                       ld       a,(ShipTypeAddr)
                                   DISPLAY "TODO: capture duff jumps"
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
                        ld      hl,UBnkMissilesLeft                     ; more missiles more agression
                        or      (hl)
                        ld      b,a                       
                        ld      a,(ShipNewBitsAddr)
                        and     %01001110                               ; We look at if its a bounty hunter, hostile already, pirate and cop
                        or      b
                        ld      b,a
                        ld      a,(UBnkShipAggression)
                        JumpIfALTNusng 64,.NotAlreadyAgressive
                        ld      a,b
                        or      %10000000                               ; if its already at least 64 agressive then likley to stay so
                        ld      b,a
.NotAlreadyAgressive:   ld      a,b
                        ld      (UBnkShipAggression),a
                        ret
.UltraHostile:          ld      a,$FF
                        ld      (UBnkShipAggression),a
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; set angry if possible, if its an innocent then flag the space station to get angry
MakeHostile:            ld      a,(ShipNewBitsAddr)                     ; Check bit 5 of newb flags
                        ;break
                        JumpIfMemEqNusng ShipTypeAddr, ShipTypeStation, .SetNewbHostile
.ItsNotAStation:        and     ShipIsBystander                         ; check if space station present if its a bystander
                        call    nz, SetStationHostile                   ; Set Space Station if present, Angry
                        ld      a,(UBnkaiatkecm)                        ; get AI data
                        ReturnOnBitClear a, ShipAIEnabledBitNbr         ; if 0 then no AI attached so it can't get angry
                        ld      c,a                                     ; Copy to c in case we need it later
                        SetMemToN UBnkAccel, 2                          ; set accelleration to 2 to speed up
                        sla     a                                       ; set pitch to 4
                        ld      (UBnkRotZCounter),a                     ; .
                        ld      a,(ShipAIFlagsAddr)
                        ReturnIfBitMaskClear ShipCanAnger
.SetNewbHostile:        call    SetShipHostile
                        ret

            DISPLAY "TODO: Missile Did Hit Us"
;----------------------------------------------------------------------------------------------------------------------------------
MissileDidHitUs:        ret ; TODO

;----------------------------------------------------------------------------------------------------------------------------------
PlayerHitByMissile:     MMUSelectLayer1
                        ld      a,L1ColourInkCyan
                        call    l1_set_border
                        ld      a,(UBnkMissileBlastDamage)
                        ld      b,a                                     ; b = damage
                        ld      a,(UBnkzsgn)
                        and     $80
                        jr      nz,.HitRear
.HitFront:              ld      a,(ForeShield)
                        call    ApplyDamage
                        ld      (ForeShield),a
                        ret
.HitRear:               ld      a,(AftShield)
                        call    ApplyDamage
                        ld      (AftShield),a  
                                    DISPLAY "TODO: Set up blast radius"
                        ret; TODO , do hit set up blast radius etc
;----------------------------------------------------------------------------------------------------------------------------------
MissileHitShipA:        MMUSelectLayer1
                        ld      a,L1ColourInkRed
                        call    l1_set_border
                        call    UnivExplodeShip
                                    DISPLAY "TODO:  hit ship do explosion"
                        ret; TODO hit ship do explosion, check for near by and if player is near and missile type logic, e.g. AP or HE
;----------------------------------------------------------------------------------------------------------------------------------
SetStationHostile:      call    IsSpaceStationPresent                   ; only if present
                        ret     c
                        ld      a,(UBnkShipUnivBankNbr)                     ; save current bank
                        ld      iyh,a
                        MMUSelectUniverseN 0                            ; space station is always 0
                        call    SetShipHostile
                        ld      a,iyh                                   ; get prev bank back
                        MMUSelectUniverseA                              ;
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
CheckMissileBlastInit:  ZeroA
                        ld      (CurrentMissileCheck),a
                        ld      hl,UBnkxlo                      ; Copy Blast Coordinates
                        ld      bc,12                           ; and Damage stats
                        ld      de,MissileXPos
                        ldir
                        ZeroA                                   ; we have processd enque request
                        ld      (UBnkMissleHitToProcess),a      ; 
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
                        ld      a,(UBnkexplDsp)                     ; Don't explode a ship twice
                        and     ShipExploding                       ;
                        ReturnIfNotZero                             ;
                        ld      a,(CurrentMissileBlastRange)
                        ld      iyh,a                               ; iyh = missile blast depending on type
.CheckRange:            ld      a,iyl                               ; now page in universe data
                        MMUSelectUniverseA      
                        CheckPointRange UBnkxlo, UBnkxsgn, MissileXPos, MissileXSgn  ; its a square but its good enough
                        CheckPointRange UBnkylo, UBnkysgn, MissileYPos, MissileYSgn
                        CheckPointRange UBnkzlo, UBnkzsgn, MissileZPos, MissileZSgn
                        call    ShipMissileBlast                    ; Ship hit by missile blast
                        ret                                         ; we are done
;...................................................................
CheckIfBlastHitUs:      ld      a,(UBnkMissileBlastRange)
                        ld      c,a
                        jp      MissileHitUsCheckPos
;...................................................................                        
CheckIfMissileHitUs:    ld      a,(UBnkMissileDetonateRange)
                        ld      c,a
;...................................................................
MissileHitUsCheckPos:   ld      hl, (UBnkxlo)
                        ld      de, (UBnkylo)
                        ld      bc, (UBnkzlo)
                        ld      a,h
                        or      d
                        or      b
                        ClearCarryFlag
                        ReturnIfNotZero
                        SetCarryFlag
                        ret
                        
                        ZeroA
                        or      h
                        ClearCarryFlag
                        ReturnIfNotZero                             ; will return with carry clear if way far away
                        ld      a,l
                        ReturnIfAGTENusng    c                      ; return no carry if x far
.CheckY:                ld      hl,(UBnkylo)
                        ZeroA
                        or      l
                        ClearCarryFlag
                        ReturnIfNotZero                             ; will return with carry clear if way far away
                        ld      a,l
                        ReturnIfAGTENusng    c                      ; return no carry if y far
.CheckZ:                ld      hl,(UBnkzlo)
                        ZeroA
                        or      l
                        ClearCarryFlag
                        ReturnIfNotZero                             ; will return with carry clear if way far away
                        ld      a,l
                        ReturnIfAGTENusng    c                      ; return no carry if z far
.ItsAHit:               SetCarryFlag                                ; So must have hit
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
                        ld      a,(UBnkRotZCounter)             ; b = abs (currentz pitch)
                        ret
                        
                        and     SignMask8Bit                    ; . which will initially be 0
                        ld      b,a                             ; .
                        ld      a,(TacticsDotProduct2)          ; a = abs roof dot product
                        JumpIfALTNusng MISSILEMAXPITCH+1, .calcNPitch2    ; if a >= roll threshold
                        ld      a,b
                        and     SignOnly8Bit
                        ;jr      z,.NPitchPositive
                       ; ld      a,
                        ld      a,MISSILEMAXPITCH                         ;    z rot = z rot * dot product flipped sign
                        or      c                               ;    i.e. zrot = current magnitude but dot product sign flipped
                        ld      (UBnkRotZCounter),a             ;    .
                        ret                                     ; else (a LT current abs z)
.calcNPitch2:           or      c                               ;     rot z = dot product with sign flipped
                        ld      (UBnkRotZCounter),a             ;
                        ret                                     ;
                        
calcNRoll:              ld      a,(UBnkRotZCounter)
                        and     SignOnly8Bit
                        xor     SignOnly8Bit                    ; flip sign of dot product
                        or      5
                        ld      (UBnkRotXCounter),a
                        ret
                        
                        ld      c,a
                        or      MISSILEMAXPITCH   
                        ld      a,(UBnkRotXCounter)
                        ret
                        
                        
                        
                        and     SignMask8Bit                    ; get ABS value
                        ld      b,a
                        ld      a,(TacticsDotProduct2)          ; now we have the dot product abs value
                        JumpIfALTNusng MISSILEMAXROLL+1, .calcNRoll2
                        ld      a,MISSILEMAXROLL
                        or      c
                        ld      (UBnkRotXCounter),a
                        ret
.calcNRoll2:            or      c                               ;     rot z = dot product with sign flipped
                        ld      (UBnkRotXCounter),a
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

                        IFDEF TACTICSDEBUG                        
DebugTacticsCopy:   
                        ld      hl,(UBnkrotmatSidevX)
                        ld      de,(UBnkrotmatSidevY)
                        ld      bc,(UBnkrotmatSidevZ)
                        ld      (TacticsSideX),hl
                        ld      (TacticsSideY),de
                        ld      (TacticsSideZ),bc

                        ld      hl,(UBnkrotmatRoofvX)
                        ld      de,(UBnkrotmatRoofvY)
                        ld      bc,(UBnkrotmatRoofvZ)
                        ld      (TacticsRoofX),hl
                        ld      (TacticsRoofY),de
                        ld      (TacticsRoofZ),bc

                        ld      hl,(UBnkrotmatNosevX)
                        ld      de,(UBnkrotmatNosevY)
                        ld      bc,(UBnkrotmatNosevZ)
                        ld      (TacticsNoseX),hl
                        ld      (TacticsNoseY),de
                        ld      (TacticsNoseZ),bc

                        ret
                        ENDIF

TacticsVarResult        DW 0                        
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

CopyToTargetVector:     ld      hl,UBnkxlo
                        ld      de,TacticsTargetX
                        ld      bc,9
                        ldir    
                        ret

CopyPosToVector:        ld      hl,(UBnkxlo)
                        ld      a,(UBnkxsgn)
                        ;xor     $80
                        ld      (TacticsVectorX),hl
                        ld      (TacticsVectorX+2),a

                        ld      hl,(UBnkylo)
                        ld      a,(UBnkysgn)
                        ;xor     $80
                        ld      (TacticsVectorY),hl
                        ld      (TacticsVectorY+2),a

                        ld      hl,(UBnkzlo)
                        ld      a,(UBnkzsgn)
                        ;xor     $80
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
                        ;call    CopyToTargetVector
                        ;FlipSignMem     TacticsTargetX+2
                        ;FlipSignMem     TacticsTargetY+2
                        ;FlipSignMem     TacticsTargetZ+2
                        ret
                                              
CalcTargetVector:       ld      de,(TacticsTargetX)                        ; get target ship X
                        ld      a,(TacticsTargetX+2)                       ; and flip sign so we have missile - target
                        FlipSignBitA
                        ld      c,a                                 ; get target ship x sign but * -1 as we are subtracting
                        ld      hl,(UBnkxlo)                        ; get missile x
                        ld      a,(UBnkxsgn)                        ; get missile x sign
                        ld      b,a
                        call    ADDHLDESignBC                       ;AHL = BHL + CDE i.e. missile - target x
                        ld      (TacticsVectorX),hl
                        ld      (TacticsVectorX+2),a
.UpdateTargetingShipY:  ld      de,(TacticsTargetY)
                        ld      a,(TacticsTargetY+2)
                        FlipSignBitA
                        ld      c,a                                 ; get target ship x sign but * -1 as we are subtracting
                        ld      hl,(UBnkylo)                        ; get missile x
                        ld      a,(UBnkysgn)                        ; get missile x sign
                        ld      b,a
                        call    ADDHLDESignBC                       ;AHL = BHL + CDE i.e. missile - target x
                        ld      (TacticsVectorY),hl
                        ld      (TacticsVectorY+2),a
.UpdateTargetingShipZ:  ld      de,(TacticsTargetZ)
                        ld      a,(TacticsTargetZ+2)
                        FlipSignBitA
                        ld      c,a                                 ; get target ship x sign but * -1 as we are subtracting
                        ld      hl,(UBnkzlo)                        ; get missile x
                        ld      a,(UBnkzsgn)                        ; get missile x sign
                        ld      b,a
                        call    ADDHLDESignBC                       ;AHL = BHL + CDE i.e. missile - target x
                        ld      (TacticsVectorZ),hl
                        ld      (TacticsVectorZ+2),a
                        ret
                        
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

            DISPLAY "TODO: TactivtsPosMinus Target"
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
