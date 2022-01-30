ClearSlotCount:         xor     a
                        ld      hl,UniverseSlotCount
                        ld      b, UniverseListSize * 2
.fillLoop:              ld      (hl),a
                        inc     hl
                        djnz    .fillLoop
                        ret

; Initialises all types to a count of 1 where there is an occupied universe slot
; this needs expanding to cater for a missing type, find type and increment count (use cpir?)
CorrectSlotCount:       call    ClearSlotCount
                        ld      hl,UniverseSlotCount
                        ld      de,UniverseSlotList
                        ld      b,UniverseListSize
.fillLoop:              ld      a,(de)
                        cp      $FF
                        jr      z,.SkipSlot
.CorrectSlot:           ld      (hl),a
                        inc     hl
                        ld      (hl),1
                        inc     hl
.SkipSlot               inc     de
                        djnz    .fillLoop
                        ret

ClearUnivExceptSun:     ld      a,$FF
                        ld      hl,UniverseSlotList + 1
                        ld      b, UniverseListSize - 1
.fillLoop:              ld      (hl),a
                        inc     hl
                        djnz    .fillLoop
                        ret

SetSunSlot:             ld      a,129
                        ld      (UniverseSlotList),a
                        ret

SetPlanetSlot:          ld      a,129
                        ld      (UniverseSlotList+1),a
                        ret

; Wipe all items
ClearUnivSlotList:      ld      a,$FF
                        ld      hl,UniverseSlotList
                        ld      b, UniverseListSize
.fillLoop:              ld      (hl),a
                        inc     hl
                        djnz    .fillLoop
                        ret

SetSlot0ToSpaceStation: ld      hl,UniverseSlotList+1
                        ld      (hl),ShipTypeStation
                        ret
                        
SetSlotAToTypeB:        ld      hl,UniverseSlotList
                        add     hl,a
                        ld      (hl),b
                        ret                     
                        
; Clears all except slot A, used when say restarting a space station post launch
ClearFreeSlotListSaveA: ld      d,a
                        ld      c,0
                        ld      hl,UniverseSlotList
                        ld      b, UniverseListSize
.fillLoop:              ld      a,c
                        cp      d
                        jr      z,.SkipSlot
                        ld      a,$FF
                        ld      (hl),a
.SkipSlot:              inc     hl
                        djnz    .fillLoop
                        ret

SetSlotAOccupiedByB:    ld      hl,UniverseSlotList
                        add     hl,a
                        ld      a,b
                        ld      (hl),b
                        ret

FindSpaceStationSlotInC:ld      hl,UniverseSlotList
                        ld      b,UniverseListSize
                        ld      c,0
.SearchLoop:            ld      a,(hl)
                        JumpIfAEqNusng ShipTypeStation, .FoundSlot
                        inc     c
                        inc     hl
                        djnz    .SearchLoop
                        SetCarryFlag
                        ret
.FoundSlot:             ClearCarryFlag
                        ret
                        
GetTypeAtSlotA:         ld      hl,UniverseSlotList
                        add     hl,a
                        ld      a,(hl)
                        ret
                        
IsPlanetOrSpaceStation: ld      hl,UniverseSlotList+1
                        ld      a,(hl)
                        ret

FindNextFreeSlotInC:    ld      hl,UniverseSlotList
                        ld      b, UniverseListSize
                        ld      c, 0
.SearchLoop:            ld      a,(hl)
                        JumpIfAEqNusng $FF, .FoundSlot
                        inc     c
                        inc     hl
                        djnz    .SearchLoop
                        SetCarryFlag
                        ret
.FoundSlot:             ClearCarryFlag
                        ret
                        
FindNextFreeSlotInA:    call    FindNextFreeSlotInC
                        ld      a,c
                        ret
