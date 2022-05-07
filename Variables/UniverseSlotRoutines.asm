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

; Clears all except slot A, used when say restarting a space station post launch
ClearFreeSlotListSaveA: ld      d,a
                        ld      c,0
                        ld      hl,UniverseSlotList
                        ld      b, UniverseSlotListSize * 2
.fillLoop:              ld      a,c
                        cp      d
                        jr      z,.SkipSlot
                        ld      a,$FF
                        ld      (hl),a
.SkipSlot:              inc     hl
                        inc     hl
                        djnz    .fillLoop
                        ret

ClearSlotA:             ld      hl,UniverseSlotList
                        add     hl,a
                        ld      (hl),$FF
                        ld      a,UniverseSlotListSize  ; move to types
                        add     hl,a
                        ld      (hl),$FF
                        ret
; Space Station will always be slot 0

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
                        
IsSpaceStationPresent:  ld      hl,UniverseSlotList
                        ClearCarryFlag
.SearchLoop:            ld      a,(hl)
                        ReturnIfAEqNusng ShipTypeStation
                        SetCarryFlag
                        ret
                        
GetTypeAtSlotA:         ld      hl,UniverseSlotList
                        add     hl,a
                        ld      a,(hl)
                        ret
                        
IsPlanetOrSpaceStation: ld      hl,UniverseSlotList+1
                        ld      a,(hl)
                        ret

FindNextFreeSlotInC:    ld      hl,UniverseSlotList
                        ld      b, UniverseSlotListSize
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
