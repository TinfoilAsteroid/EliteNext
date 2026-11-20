; Note this code is core code and can not be in a memory bank unless do explosion code is changed too
ClearSlotCount:         xor     a
                        ld      hl,UniverseSlotList
                        ld      b, UniverseSlotListSize ; prbably not needed + UniverseSlotTypeSize
.fillLoop:              ld      (hl),a
                        inc     hl
                        djnz    .fillLoop
                        ret

; Initialises all types to a count of 1 where there is an occupied universe slot
; this needs expanding to cater for a missing type, find type and increment count (use cpir?)
; DOE NOT WORK CorrectSlotCount:       call    ClearSlotCount
; DOE NOT WORK                         ld      hl,UniverseSlotCount
; DOE NOT WORK                         ld      de,UniverseSlotList
; DOE NOT WORK                         ld      b,UniverseSlotListSize
; DOE NOT WORK .fillLoop:              ld      a,(de)
; DOE NOT WORK                         cp      $FF
; DOE NOT WORK                         jr      z,.SkipSlot
; DOE NOT WORK .CorrectSlot:           ld      (hl),a
; DOE NOT WORK                         inc     hl
; DOE NOT WORK                         ld      (hl),1
; DOE NOT WORK                         inc     hl
; DOE NOT WORK                         inc     hl
; DOE NOT WORK .SkipSlot               inc     de
; DOE NOT WORK                         djnz    .fillLoop
                        ret
; Wipe all items
ClearUnivSlotList:      ld      a,$FF
                        ld      hl,UniverseSlotList
                        ld      b, UniverseSlotListSize * 2
.fillLoop:              ld      (hl),a
                        inc     hl
                        djnz    .fillLoop
                        ret

SetSlot0ToSpaceStation: ld      hl,UniverseSlotList
                        ld      (hl),ShipTypeStation
                        ld      hl,UniverseSlotType
                        ld      (hl),ShipTypeStation
                        ret
                        
SetSlotAToTypeB:        ld      hl,UniverseSlotList
                        add     hl,a
                        ld      (hl),b
                        ret
                        
SetSlotAToClassB:       ld      hl,UniverseSlotType
                        add     hl,a
                        ld      (hl),b
                        ret                     

ClearSlotA:             ld      hl,UniverseSlotList
                        add     hl,a
                        ld      (hl),$FF
                        ld      a,UniverseSlotListSize  ; move to types
                        add     hl,a
                        ld      (hl),$FF
                        ret

; Space Station will always be slot 0
ClearJunk:              ld      hl,UniverseSlotType+1
                        ld      c,1
                        ld      b,UniverseSlotListSize -1      ; ignore space station
.NextShip:              ld      a,(hl)
                        cp      ShipTypeJunk
                        jp      z,.ProcessJunk
                        cp      ShipTypeScoopable
                        jp      z,.ProcessJunk
.DoneIteration:         inc     hl
                        inc     c
                        djnz    .NextShip
                        ClearJunkCount
                        ret
.ProcessJunk:           ld      a,c
                        push    hl                  ; ClearSlotA uses hl, which is walking the slot types
                        call    ClearSlotA
                        pop     hl
                        jp      .DoneIteration
                        

WarpJunk:               ld      hl,UniverseSlotType+1
                        ld      c,1
                        ld      b,UniverseSlotListSize -1      ; ignore space station
.NextShip:              ld      a,(hl)
                        cp      ShipTypeJunk
                        jp      z,.ProcessJunk
                        cp      ShipTypeScoopable
                        jp      z,.ProcessJunk
.DoneIteration:         inc     hl
                        inc     c
                        djnz    .NextShip
                        ret
.ProcessJunk:           ld      a,c
                        MMUSelectUniverseA
                        call    WarpOffset
                        jp      .DoneIteration

AreShipsPresent:        ld      hl,UniverseSlotType+1
                        ld      b,UniverseSlotListSize -1      ; ignore space station
.NextShip:              ld      a,(hl)
                        cp      ShipTypeNormal
                        ClearCarryFlag
                        ret     z
                        inc     hl
                        djnz    .NextShip
                        SetCarryFlag
                        ret
                        
; carry clear if slot 0 holds the space station, else carry set. UniverseSlotList holds the model, UniverseSlotType the
; class: this once compared the model with ShipTypeStation, so it never found the station
IsSpaceStationPresent:  ld      a,(UniverseSlotList)
                        cp      $FF
                        jr      z,.NotPresent                   ; slot 0 empty
                        ld      a,(UniverseSlotType)
                        cp      ShipTypeStation
                        ret     z                               ; (carry clear)
.NotPresent:            SetCarryFlag
                        ret
                        
GetTypeAtSlotA:         ld      hl,UniverseSlotList
                        add     hl,a
                        ld      a,(hl)
                        ret
                        
IsPlanetOrSpaceStation: ld      hl,UniverseSlotList+1
                        ld      a,(hl)
                        ret
;-----------------------------------------------------------------------------
;-- Search the slot list for a free slot and return the result in c register. 
;-- Carry is clear if successful, else carry is set if all slots full
;-- uses hl, bc, a
; slot 0 is kept for the space station (IsSpaceStationPresent, the station compass and UpdateSafeZone expect it there):
; ships use slots 1 on, so one spawned before we reach a safe zone can't take the station's place
FindNextFreeSlotInC:    ld      hl,UniverseSlotList+1
                        ld      b, UniverseSlotListSize-1
                        ld      c, 1
.SearchLoop:            ld      a,(hl)
                        JumpIfAEqNusng $FF, .FoundSlot
                        inc     c
                        inc     hl
                        djnz    .SearchLoop
                        SetCarryFlag
                        ret
.FoundSlot:             ClearCarryFlag
                        ret
  
;-----------------------------------------------------------------------------
;-- calls FindNextFreeSlotInC and returns the result in a and c registers. 
;-- Carry is clear if successful, else carry is set if all slots full
;-- uses hl, bc, a                        
FindNextFreeSlotInA:    call    FindNextFreeSlotInC
                        ld      a,c
                        ret
