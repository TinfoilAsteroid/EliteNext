MShipBankTable          MACRO 
                        DW      BankShipModels1
                        DW      BankShipModels2
                        DW      BankShipModels3
                        DW      BankShipModels4
                        ENDM
; For ship number A fetch 
;           the adjusted ship number in B , C = original number
;           bank number in A for the respective ship based on the ship table
MGetShipBankId:         MACRO   banktable
                        ld      b,0
                        ld      c,a                                 ; c= original ship id
.ShiftLoop:             srl     a
                        srl     a
                        srl     a
                        srl     a                                   ; divide by 16
                        ld      b,a                                 ; b = bank nbr
                        ld      a,c
                        ld      d,b
                        ld      e,16
                        mul                                         ; de = 16 * bank number (max is about 15 banks)
                        sub     e                                   ; a= actual model id now
.SelectedBank:          ld      d,b                                 ; save current bank number
                        ld      b,a                                 ; b = adjusted ship nbr 
                        ld      a,d                                 ; a = bank number
;.. Now b = bank and a = adjusted ship nbr                     
                        ld      hl,banktable                        ; a= bank index
                        add     hl,a
                        add     hl,a
                        ld      a,(hl)                              ; a = actual bank now
                        ClearCarryFlag
                        ret
                        ENDM

McopyVertsToUniverse:   MACRO 
                        ld          hl,(VerticesAddyAddr)       ; now the pointers are in UBnk its easy to read
                        ld          de,UBnkHullVerticies
                        ld          b,0
                        ld			a,(VertexCtX6Addr)
                        ld          c,a
                        ex          de,hl                       ; dma transfer goes de -> hl i.e. opposite of ldir
                        call        memcopy_dma
                        ret
                        ENDM

McopyVertsToSpaceStation:   MACRO 
                        ld          hl,(SS_VerticesAddyAddr)       ; now the pointers are in UBnk its easy to read
                        ld          de,SS_BnkHullVerticies
                        ld          b,0
                        ld			a,(SS_VertexCtX6Addr)
                        ld          c,a
                        ex          de,hl                       ; dma transfer goes de -> hl i.e. opposite of ldir
                        call        memcopy_dma
                        ret
                        ENDM
                        
McopyEdgesToUniverse:   MACRO
                        ld          hl,(EdgeAddyAddr)          ; now the pointers are in UBnk its easy to read
                        ld          de,UBnkHullEdges
                        ld          b,0
                        ld			a,(LineX4Addr)
                        ld          c,a
                        ex          de,hl                       ; dma transfer goes de -> hl i.e. opposite of ldir
                        call        memcopy_dma
                        ret
                        ENDM

McopyEdgesToSpaceStation: MACRO
                        ld          hl,(SS_EdgeAddyAddr)          ; now the pointers are in UBnk its easy to read
                        ld          de,SS_BnkHullEdges
                        ld          b,0
                        ld			a,(SS_LineX4Addr)
                        ld          c,a
                        ex          de,hl                       ; dma transfer goes de -> hl i.e. opposite of ldir
                        call        memcopy_dma
                        ret
                        ENDM                        
                        
McopyNormsToUniverse:   MACRO
                        ld          hl,(FaceAddyAddr)          ; now the pointers are in UBnk its easy to read
                        ld          de,UBnkHullNormals
                        ld          b,0
                        ld          a,(FaceCtX4Addr)
                        ld          c,a
                        ex          de,hl                       ; dma transfer goes de -> hl i.e. opposite of ldir
                        call        memcopy_dma
                        ret
                        ENDM

McopyNormsToSpaceStation:   MACRO
                        ld          hl,(SS_FaceAddyAddr)          ; now the pointers are in UBnk its easy to read
                        ld          de,SS_BnkHullNormals
                        ld          b,0
                        ld          a,(SS_FaceCtX4Addr)
                        ld          c,a
                        ex          de,hl                       ; dma transfer goes de -> hl i.e. opposite of ldir
                        call        memcopy_dma
                        ret
                        ENDM                        
; Passes in ship nbr in A and bank is part of MACRO
MCopyShipToUniverse:    MACRO       banklabel
                        ld          hl,UBnkShipModelBank
                        ld          (hl),banklabel
                        push        af
                        ld          a,iyl
                        ld          (UBnkShipModelId),a
                        pop         af
                        ld          (UBnkShipModelNbr),a
.GetHullDataLength:     ld          hl,ShipModelSizeTable
                        add         hl,a
                        add         hl,a                        ; we won't multiply by 2 as GetInfo is a general purpose routines so would end up x 4
                        ld          c,(hl)
                        inc         hl
                        ld          b,(hl)                      ; bc now equals length of data set
.GetHullDataAddress:    ld          hl,ShipModelTable
                        add         hl,a
                        add         hl,a                        ; now hl = address of ship data value
                        ld          a,(hl)
                        inc         hl
                        ld          h,(hl)
                        ld          l,a                         ; now hl = address of ship hull data
                        ld          de,UBnkHullCopy             ; Universe bank
                        ld          bc,ShipDataLength           
                        ldir                                    
                        call        CopyVertsToUniv
                        call        CopyEdgesToUniv
                        call        CopyNormsToUniv
.ClearName:             ld          hl,StartOfUnivName
                        ld          a," "
                        ld          b,16
.fillLoop:              ld          (hl),a
                        inc         hl
                        djnz        .fillLoop
.SetName:               ld          a,(UBnkShipModelId)
                        call        ShipIndexToAddress
                        ld          de,StartOfUnivName
                        ld          b,16
.CopyLoop:              ld          a,(hl)
                        cp          0
                        jr          z,.CopyDone
                        ld          (de),a
                        inc         hl
                        inc         de
                        djnz        .CopyLoop
.CopyDone:              ret
                        ENDM
                        
MCopyShipToSpaceStation:MACRO       banklabel
                        ld          hl,SS_BnkShipModelBank
                        ld          (hl),banklabel
                        push        af
                        ld          a,iyl
                        ld          (SS_BnkShipModelId),a
                        pop         af
                        ld          (SS_BnkShipModelNbr),a
.GetHullDataLength:     ld          hl,ShipModelSizeTable
                        add         hl,a
                        add         hl,a                        ; we won't multiply by 2 as GetInfo is a general purpose routines so would end up x 4
                        ld          c,(hl)
                        inc         hl
                        ld          b,(hl)                      ; bc now equals length of data set
.GetHullDataAddress:    ld          hl,ShipModelTable
                        add         hl,a
                        add         hl,a                        ; now hl = address of ship data value
                        ld          a,(hl)
                        inc         hl
                        ld          h,(hl)
                        ld          l,a                         ; now hl = address of ship hull data
                        ld          de,SS_BnkHullCopy             ; Universe bank
                        ld          bc,ShipDataLength           
                        ldir                                    
                        call        CopyVertsToSpaceStation
                        call        CopyEdgesToSpaceStation
                        call        CopyNormsToSpaceStation
.SetName:               ld          a,(SS_BnkShipModelId)
                        call        ShipIndexToAddress
                        ld          de,StartOfSpaceStationName
                        ld          b,16
.CopyLoop:              ld          a,(hl)
                        cp          0
                        jr          z,.CopyDone
                        ld          (de),a
                        inc         hl
                        inc         de
                        djnz        .CopyLoop
.CopyDone:              ret
                        ENDM
                        
MCopyBodyToUniverse:    MACRO       copyRoutine
                        ld          a,13
                        call        copyRoutine
                        ret
                        ENDM
                        
MCopyBodyToSpaceStation:MACRO       copyRoutine
                        ld          a,13
                        call        copyRoutine
                        ret
                        ENDM                        
                        
MCopyShipIdToUniverse:  MACRO
                        call        GetShipModelId
                        MMUSelectShipBankA
                        ld          a,b
                        jp          CopyShipToUniverse
                        ENDM

MCopyShipIdToSpaceStation:  MACRO
                        call        GetShipModelId
                        MMUSelectShipBankA
                        ld          a,b
                        jp          CopyShipToSpaceStation
                        ENDM                        