            DISPLAY "MODULE: ProcessWarp.asm"
;-----------------------------------------------------------------------------------------------------
;-- Process in system warp key press, only called when warp press detected
PlanetWarpPosition:     DS      3            
WarpSlotNumber:         DB      0
ProcessWarp:            SetMemFalse     WarpPressed                     ; clear and acknowlege
                        JumpIfMemZero   WarpCooldown, .CheckMassLock    ; If warp drive is cool then warp
.JumpDriveHot:
                        jp      .TooHot                                 ; else warp is too hot so exit
;-- Mass locked if the space station, any ship, the sun or the planet is within 1.0 of us on every axis (WarpIsObjectClose)
.CheckMassLock:         xor     a                                       ; every occupied universe slot: slot 0 is the space station
                        ld      (WarpSlotNumber),a                      ; and 1 onwards are ships
.SlotLoop:              ld      hl,UniverseSlotList
                        add     hl,a
                        ld      a,(hl)
                        cp      $FF
                        jr      z,.NextSlot                             ; empty slot
                        ld      a,(WarpSlotNumber)
                        MMUSelectUniverseA
                        ld      hl,UBnKxlo
                        call    WarpIsObjectClose
                        jp      c,.MassLocked
.NextSlot:              ld      a,(WarpSlotNumber)
                        inc     a
                        ld      (WarpSlotNumber),a
                        cp      UniverseSlotListSize
                        jr      nz,.SlotLoop
.CheckSunMassLocking:   MMUSelectSun
                        ld      hl,SBnKxlo
                        call    WarpIsObjectClose
                        jp      c,.MassLocked
.CheckPlanetMassLocking:MMUSelectPlanet                                 ; planet bank stays selected for the jump range below
                        ld      hl,P_BnKxlo
                        call    WarpIsObjectClose
                        jp      c,.MassLocked
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
                        MMUSelectMathsBankedFns                         ; CompareAtIXtoIYABS is in the banked maths
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
.ClearShips:            call    WarpClearBubbleShips                    ; all ships except the space station are left behind
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

;-----------------------------------------------------------------------------------------------------
; hl -> 9 byte position (x, y, z each lo, hi, sign). Returns carry set if the object is within 1.0 of us on every axis.
; The integer part of each S15.8 axis is the sign byte bits 0-6 (upper) and the hi byte (lower); an axis is far enough
; away if the upper byte is non zero or the lower byte is > 1, and one far axis is enough to allow the warp.
WarpIsObjectClose:      ld      b,3
.AxisLoop:              inc     hl                                      ; hl -> hi byte (integer lower byte)
                        ld      a,(hl)
                        inc     hl                                      ; hl -> sign byte (integer upper byte)
                        cp      2
                        ret     nc                                      ; lower byte > 1 so far enough, carry clear
                        ld      a,(hl)
                        and     SignMask8Bit                            ; also clears carry
                        ret     nz                                      ; upper byte non zero so far enough
                        inc     hl                                      ; next axis lo byte
                        djnz    .AxisLoop
                        scf                                             ; within 1.0 on every axis
                        ret

;-----------------------------------------------------------------------------------------------------
; Removes every ship from the local bubble except the space station (slot 0), resets the ship type counts and drops
; a missile lock that was on one of the removed ships
WarpClearBubbleShips:   ld      b,UniverseSlotListSize - 1
                        ld      c,1
.ClearLoop:             ld      a,c
                        push    bc
                        call    ClearSlotA                              ; marks the slot free in both slot lists
                        pop     bc
                        inc     c
                        djnz    .ClearLoop
                        xor     a
                        ld      (JunkCount),a
                        ld      (CopCount),a
                        ld      (PirateCount),a
.CheckMissileLock:      ld      a,(MissileTargettingFlag)               ; $FF not targeting, $FE targeting, else slot in the low nibble
                        cp      StageMissileTargeting
                        ret     nc
                        and     $0F
                        ret     z                                       ; locked on the space station which is kept
                        ClearMissileTargetting
                        ret
