            DISPLAY "MODULE: ProcessWarp.asm"
;-----------------------------------------------------------------------------------------------------
;-- Process in system warp key press, only called when warp press detected
ProcessWarp:            SetMemFalse     WarpPressed                     ; clear and acknowlege
                        JumpIfMemZero   WarpCooldown, .WarpDriveCool    ; If warp drive is cool then warp
                        DISPLAY "TODO Need logic for in system jump drive malfunction"
.JumpDriveHot:          DISPLAY "TODO call bong jump drive hot"
                        DISPLAY "TODO flash jump drive status icon"
                        ret                                              ; else warp is too hot so exit
.WarpDriveCool:         JumpIfMemFalse    SpaceStationSafeZone, .NotInSpaceStationRange
.MassLocked:            DISPLAY "TODO Mass locked by object call bong"
                        DISPLAY "TODO message mass locked"
                        DISPLAY "TODO make space station a body just like planet and sun"
                        jp      .NoWarp
.NotInSpaceStationRange:call    AreShipsPresent
                        jr      nc,     .MassLocked
.IsPlanetMassLocking:   MMUSelectPlanet                 ; is planet within 256 then mass locked
                        ld      hl,(P_BnKzhi)
                        ld      a,h                     ; if z sign is <> 0 then mass locked
                        and     $7F                     ; h = abs zsign
                        or      l                       ; to get to here a must be zero to or with l will give a quick result
                        jp      z,     .MassLocked
.IsSunMassLocking:      MMUSelectSun
                        ld      hl,(SBnKzhi)
                        ld      a,h                     ; if z sign is <> 0 then mass locked
                        and     $7F                     ; h = abs zsign
                        or      l                       ; to get to here a must be zero to or with l will give a quick result
                        jp      z,     .MassLocked
            IFDEF SIMPLEWARP
                        ld      hl,(P_BnKzhi)           ; z hi,sign must be > 0 else we are mass locked so can't hit here
                        DecHLSigned
                        ld      (P_BnKzhi),hl
                        ld      hl,(SBnKzhi)           ; z hi,sign must be > 0 else we are mass locked so can't hit here
                        DecHLSigned
                        ld      (SBnKzhi),hl
            ELSE
.NotCorrectFacing:      ;       call bong, align with body
                        jp      .NoWarp
.JumpToPlanetCheck:     ld      a,(P_BnKzhi)
                        JumpIfAGTENusng  2, .PlanetRangeOK 
                        ld      a,(P_BnKyhi)
                        JumpIfAGTENusng  2, .PlanetRangeOK
                        ld      a,(P_BnKxhi)
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
                        MMUSelectLayer1
                        call    WarpSFX             ; Do the visual SFX based on facing
                        jp      .DoneWarp
.NoWarp:                MMUSelectLayer1
.DoneWarp: