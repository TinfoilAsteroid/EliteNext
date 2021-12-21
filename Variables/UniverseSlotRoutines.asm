
; Wipe all items
ClearFreeSlotList:      ld      a,$FF
                        ld      hl,UniverseSlotList
                        ld      b, UniverseListSize
.fillLoop:              ld      (hl),a
                        inc     hl
                        djnz    .fillLoop
                        ret

SetSlotAToSpaceStation: ld      hl,UniverseSlotList
                        add     hl,a
                        ld      (hl),ShipTypeStation
                        ret
                        
SetSelotAToTypeB:       ld      hl,UniverseSlotList
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
.SkipSlot:              ld      (hl),a
                        inc     hl
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
                        
FindSpaceStationSlotInA:call    FindSpaceStationSlotInC:
                        ld      a,c
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
