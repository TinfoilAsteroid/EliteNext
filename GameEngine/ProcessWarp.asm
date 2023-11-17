            DISPLAY "MODULE: ProcessWarp.asm"
;-----------------------------------------------------------------------------------------------------
;-- Process in system warp key press, only called when warp press detected
MassLockDistance:       DB      $FF, $03, $00
ProcessWarp:            SetMemFalse     WarpPressed                     ; clear and acknowlege
                        JumpIfMemZero   WarpCooldown, .CheckSpaceStationLock    ; If warp drive is cool then warp
                        DISPLAY "TODO Need logic for in system jump drive malfunction"
.JumpDriveHot:          DISPLAY "TODO call bong jump drive hot"
                        DISPLAY "TODO flash jump drive status icon"
                        jp      .TooHot                                 ; else warp is too hot so exit
.CheckSpaceStationLock: MMUSelectSpaceStation
                        ld      ix,UBnKxlo
                        ld      iy,MassLockDistance
                        MMUSelectMathsBankedFns : call ManhattanDistanceIXIY
                        jp      nz,.MassLocked
.CheckPlanetMassLocking:MMUSelectPlanet                                 ; is planet within 1023 (i.e. 3FF) then mass locked
                        ld      ix,P_BnKzhi
                        MMUSelectMathsBankedFns : call ManhattanDistanceIXIY
                        jp      nz,.MassLocked
.CheckSunMassLocking:   MMUSelectPlanet                                 ; is planet within 1023 (i.e. 3FF) then mass locked
                        ld      ix,SBnKzhi
                        MMUSelectMathsBankedFns : call ManhattanDistanceIXIY
                        jp      nz,.MassLocked                        
.NotInSpaceStationRange:call    AreShipsPresent                         ; Any ships present then masslocked
                        jr      nc,     .MassLocked             
;-- Now we do dynamic jump based on facign towards sun or planet. Sun is largest so determines the mass lock                        
;-- take sun and planet z distance, pick smaller of the two
;-- z jump delta = distance %7F0000 / 2
;-- now we know that lo m
.DynamicJumpRange:      ld      a,h                                     ; hl = abs saved planet distance from above
                        and     SignMask8Bit                            ;
                        ld      h,a                                     ; 
                        ld      a,d                                     ; de = abs saved sun distance from above
                        and     SignMask8Bit                            ;
                        JumpIfALTNusng  h,.SunCloser                    ; set a to closest (lower) of sun
.PlanetCloser:          ld      a,h                                     ; and planet
.SunCloser:             srl     a                                       ; now divide distance by 2
                        jp      nz,.DoBigWarp                           ; if its a non zero value then we can warp
.SmallerWarp:           ld      a,e
                        JumpIfALTNusng  l,.SunCloserSmallWarp
.PlanetCloserSmallWarp: ld      a,l
.SunCloserSmallWarp:    srl     a
                        jp      nz,.DoSmallWarp
.DoBigWarp:             ld      h,a
                        ld      l,0
                        jp      .DoWarp
.DoSmallWarp:           ld      h,0
                        ld      l,a
.DoWarp:
.UpdatePlanet:          MMUSelectPlanet
                        call    WarpPlanetByHL
                        MMUSelectSun
                        call    WarpSunByHL
                        MMUSelectSpaceStation
                        call    WarpUnivByHL
.MoveJunk:              call    ClearJunk           ;  call    WarpJunk - as it will move sign bit hi then all junk will be lost
                        ld      a,WarpCoolDownPeriod
                        ld      (WarpCooldown),a
                        MMUSelectLayer1
                        call    WarpSFX             ; Do the visual SFX based on facing
                        ret
.TooHot:                ;       call hot bong
                        MMUSelectLayer1
                        ret                     
.MassLocked:            ;       call bing bong noise 
.NoWarp:                MMUSelectLayer1             ; skip with no sound
                        ret 
