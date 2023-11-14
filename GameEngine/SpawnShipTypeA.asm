;.. SpawnShipTypeA
; IN
;  a = ship type to create (equates to the ship model)
; OUT
;  b = ship class
;  a = iyh = slot number
SpawnShipTypeA:         ;break
                        ld      iyl,a                               ; save ship type in iyl
                        call    FindNextFreeSlotInC                 ; c = slot number to use
                        ret     c                                   ; if carry flag was set then no spare slots                       
SpawnShipTypeASlotC:    ld      iyh,c                               ; preserve slot number for now
                        MMUSelectShipBank1                          ; select bank 1
                        ld      a,iyh                               ; A = slot number
                        ld      b,iyl                               ; b = ship type
                        call    SetSlotAToTypeB                     ; Allocate slot as used
                        MMUSelectUniverseA                          ; .   
.MarkUnivDiags:         ld      a,iyh                               ; mark diagnostics for bank number in memory
                        add     "A"                                 ; so fix Universe PB<x> to correct letter
                        ld      (StartOfUnivN),a                    ; to help debugging
                        ld      a,iyl                               ; get ship model type
                        ld      (StartOfUnivM),a                    ; set debugging for model
.CopyOverShipData:      call    GetShipBankId                       ; find actual memory location of ship model data
                        MMUSelectShipBankA                          ; by paging in bank a then looking up computed bank for model a
                        ld      a,b                                 ; b = computed ship id for bank
                        call    CopyShipToUniverse                  ; copy all the ship data in to the paged in bank
                        call    UnivSetSpawnPosition                ; set initial spawn position
                        call    UnivInitRuntime                     ; Clear runtime data before startup, iy h and l are already set up
                        ld      a,(ShipTypeAddr)                    ; get ship type
                        ld      (StartOfUnivT),a                    ; to help debugging we store type too
                        ld      b,a                                 ; and set the type into slot table
                        ld      a,iyh                               ;
                        call    SetSlotAToClassB                    ;
                        ClearCarryFlag                              ; no carry on success
                        ret


; iyh = 0 then its a hyperspace entry, if its $FF them its from a space station launch
; for a hyperspace entry ParentPlanetX.. must be populated else its back populated
;SpawnSpaceStation:      MMUSelectSpaceStation                       ; Get Space station bank in
;                        call    SelectSpaceStationType              ; Use algorithim there to determine station type based on galaxy algorithm
;                        ld      iyl,a                               ; iyl = station type
;                        MMUSelectShipBank1
;                        ld      a,<SpaceStationBank>
;                        ls      a,iyl                               ; a = station type
;.CopyOverShipData:      call    GetShipBankId
;                        MMUSeelctShipBankA                          ; b = computed ship id for station type and bank
;                        ld      a,b                                 ;
;                        call    CopyShipToSpaceStation
;                        call    
                        