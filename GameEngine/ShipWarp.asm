                IFDEF MAINLOOP_WARP_ENABLED
;... Warp or in system jump thsi moves everything by 1 on the high (sign) byte away or towards ship based on their z axis only
;... its not a true move in the right direction, more a z axis warp                
ProcessWarp:            JumpIfMemFalse  WarpPressed, .NoWarp
.WarpIsPressed:         SetMemFalse     WarpPressed                               ; clear and acknowlege
                        JumpIfMemZero   WarpCooldown, .WarpDriveCool
                        DISPLAY "TODO Need logic for in system jump drive malfunction"
.JumpDriveHot:          DISPLAY "TODO call bong jump drive hot"
                        DISPLAY "TODO flash jump drive status icon"
                        jp      .NoWarp
.WarpDriveCool:         JumpIfMemFalse    SpaceStationSafeZone, .NotInSpaceStationRange
.MassLocked:            DISPLAY "TODO Mass locked by object call bong"
                        DISPLAY "TODO message mass locked"
                        DISPLAY "TODO make space station a body just like planet and sun"
                        jp      .NoWarp
.NotInSpaceStationRange:call    AreShipsPresent
                        jr      nc,     .MassLocked
.IsPlanetMassLocking:   MMUSelectPlanet                 ; is planet within 256 then mass locked
                        ld      bc,(P_Bnkzhi)
                        ld      a,b                     ; if z sign is == 0 then mass locked
                        and     $7F                     ; h = abs zsign
                        or      l                       ; to get to here a must be zero to or with l will give a quick result
                        jp      z,     .MassLocked
.IsSunMassLocking:      MMUSelectSun
                        ld      hl,(SBnKzhi)
                        ld      a,h                     ; if z sign is == 0 then mass locked
                        and     $7F                     ; h = abs zsign
                        or      l                       ; to get to here a must be zero to or with l will give a quick result
                        jp      z,     .MassLocked
.IsStationMassLocking:  MMUSelectSpaceStation
                        IFDEF SPACESTATIONUNIQUECODE
                        ld      de,(SS_Bnkzhi)          ; if z hi or sign == 0 then mass locked, needs to be at least 256 away
                        ELSE
                        ld      de,(UBnkzhi)
                        ENDIF
                        ld      a,d
                        and     $7F
                        or      e
                        jp      z,      .MassLocked
            IFDEF SIMPLEWARP
;-- when we get here bc = [planet sign, high] hl = [sun sign, high]
.MassiveJumpCheck:      ld      a,b                     ; if range is 7000 to 1000 do a $1000 jump
                        or      h
                        and     $70
                        ld      de,$9000
                        jp      nz,.PerformJumpPlanet
.LargeJumpCheck:        ld      a,b                     ; now if sign byte has a value then we do
                        or      h                       ; a jump of $0100 
                        and     $7F
                        ld      de,$8100
                        jp      nz,.PerformJumpPlanet
;-- now see if we are doing a $0010 jump
.MediumJumpCheck:       ld      a,c                     ; if the distance is in the range
                        or      l                       ; 00F0 to 0010 then its a $0010 jump
                        and     $F0
                        ld      de,$8010
                        jp      nz,.PerformJumpPlanet
.SmallJump:             ld      de,$0001
; When jumping distance is based on planet or sun not station, as station is near a planet then its not an issue
.PerformJumpPlanet:     MMUSelectPlanet
                        ld      hl,(P_Bnkzhi)
                        MMUSelectMathsBankedFns
                        call    AddDEtoHLSigned
                        ld      (P_Bnkzhi),hl
.PerformJumpStation:    MMUSelectSpaceStation
                        IFDEF SPACESTATIONUNIQUECODE
                        ld      de,(SS_Bnkzhi)
                        ELSE
                        ld      de,(UBnkzhi)
                        ENDIF
                        MMUSelectMathsBankedFns
                        call    AddDEtoHLSigned
                        IFDEF SPACESTATIONUNIQUECODE
                        ld      de,(SS_Bnkzhi)
                        ELSE
                        ld      de,(UBnkzhi)
                        ENDIF
.PerformJumpSun:        MMUSelectSun
                        ld      (SBnKzhi),hl
                        MMUSelectMathsBankedFns
                        call    AddDEtoHLSigned
                        ld      (SBnKzhi),hl
                        jp      .MoveJunk
            ELSE
.NotCorrectFacing:      ;       call bong, align with body
                        jp      .NoWarp
.JumpToPlanetCheck:     ld      a,(P_Bnkzhi)
                        JumpIfAGTENusng  2, .PlanetRangeOK 
                        ld      a,(P_Bnkyhi)
                        JumpIfAGTENusng  2, .PlanetRangeOK
                        ld      a,(P_Bnkxhi)
                        JumpIfAGTENusng  2, .PlanetRangeOK
                        jp      .MassLocked
.PlanetRangeOK:         call    WarpPlanetCloser
                        MMUSelectSun
                        call    WarpSunFurther
                        jp      .MoveJunk
.JumpToSunCheck:        ld      a,(SBnKzsgn)
                        ld      hl,SBnKxsgn
                        or      (hl)
                        ld      hl,SBnKysgn
                        or      (hl)
                        and     SignMask8Bit
                        JumpIfAGTENusng  2, .SunRangeOK
                        jp      .MassLocked
.SunRangeOK:            call    WarpSunCloser
                        MMUSelectPlanet
                        call    WarpPlanetFurther
            ENDIF
.MoveJunk:              call    ClearJunk;  call    WarpJunk - as it will move sign bit hi then all junk will be lost
                        ld      a,WarpCoolDownPeriod
                        ld      (WarpCooldown),a
.WarpSFX:               MMUSelectLayer1
                        DISPLAY "TODO: Add Warp Sound"
                        call    WarpSFX             ; Do the visual SFX based on facing
                        jp      .DoneWarp
.NoWarp:                MMUSelectLayer1
.DoneWarp:
                ENDIF