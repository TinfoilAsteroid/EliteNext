            DISPLAY "MODULE: ProcessWarp.asm"
;-----------------------------------------------------------------------------------------------------
;-- Process in system warp key press, only called when warp press detected
MassLockDistance:       DB      $FF, $03, $00
PlanetWarpPosition:     DS      3            
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
; Moved this up so that if we enter DynamicJumpRangeCode we already have some planet data in place
.CheckShipsInBubble:    call    AreShipsPresent                         ; Any ships present then masslocked
                        jp      nc,     .MassLocked             
.CheckSunMassLocking:   MMUSelectSun                                    ; is planet within 1023 (i.e. 3FF) then mass locked
                        ld      ix,SBnKzhi
                        MMUSelectMathsBankedFns : call ManhattanDistanceIXIY
                        jp      nz,.MassLocked                        
.CheckPlanetMassLocking:MMUSelectPlanet                                 ; is planet within 1023 (i.e. 3FF) then mass locked
                        ld      ix,P_BnKzhi
                        MMUSelectMathsBankedFns : call ManhattanDistanceIXIY
                        jp      nz,.MassLocked
;-- Now we do dynamic jump based on facign towards sun or planet. Sun is largest so determines the mass lock                        
;-- take sun and planet z distance, pick smaller of the two
;-- z jump delta = distance %7F0000 / 2
;-- now we know that lo m
.DynamicJumpRange:      ld      hl,(P_BnKzlo)                           ; for now we will only base warp on z distance for speed, later on we can look at 3D
                        ld      a,(P_BnKzsgn)                           ;
                        ld      (PlanetWarpPosition),hl                 ; copy locally as when we swap to sun bank planet bank won't be in memory
                        ld      (PlanetWarpPosition+2),a                ; .
                        ld      iy,PlanetWarpPosition                   ; now point IY at planet
                        MMUSelectSun
                        ld      ix,SBnKzlo                              ; now we point IX at sun
                        call    CompareAtIXtoIYABS                      ; we know we have Mths BankdFns in bank zero, on return IY holds the shorter of the two distances
; After compare c means that we have done a swap and on 
                        ld      a,(iy+2)                                ; load HL with the position high bytes as we won't warp if less than 256 (well 1023 in reality)
                        and     SignMask8Bit                            ; we want abs of distnace
                        ld      h,a
                        and     a                                       ; if its zero then we are not doing a big jump
                        jp      nz,.DoBigWarp                           ; .
.DoSmallWarp:           ld      l,(iy+1)                                ; if we got here the l must hold a value of interest and h must hold 0
                        srl     l                                       ; divide l by 2 so now hl0 = warp distance
                        jp      .DoWarp                                 ; now we can do a hl0 warp
.DoBigWarp:             srl     h                                       ; big warp is h/2 but if Srl made it zero then we need to adjust l
                        ld      l,0                                     ; so we assume we are doing H/2 0 0 jump
                        jp      nz,.DoWarp                              ; and if srl did not result in zero this is a case
                        ld      l,$FF                                   ; bit if not then we do 0 $FF 0 jump
.DoWarp:
.UpdatePlanet:          push    hl,,hl                                  ; save 2 copied of jump distance so we can do sun and space station
                        MMUSelectPlanet                                 ; update planet
                        call    WarpPlanetByHL                          ; .
                        pop     hl                                      ; get back first stacked copy of distance
                        MMUSelectSun                                    ; update sun
                        call    WarpSunByHL                             ; .
                        pop     hl                                      ; get back last stacked copy of distance
                        MMUSelectSpaceStation                           ; update space station
                        call    WarpUnivByHL                            ; .
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
