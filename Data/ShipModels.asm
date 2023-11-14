

; For ship number A fetch the adjusted ship number in B and bank number in A for the respective ship based on the ship table
                        IFDEF SHIPBANKA
GetShipModelId:
GetShipModelIdA:        ld      c,a
                        ld      hl,ShipModelBankA                  ; Ship Model BankA, B and C are all the same value
                        ENDIF
                        IFDEF SHIPBANKB
GetShipModelIdB:        ld      c,a
                        ld      hl,ShipModelBankB
                        ENDIF
                        IFDEF SHIPBANKC
GetShipModelIdC:        ld      c,a
                        ld      hl,ShipModelBankC
                        ENDIF
                        JumpIfALTNusng ShipTableALast+1, .ShipBankA
                        JumpIfALTNusng ShipTableBLast+1, .ShipBankB
                        JumpIfALTNusng ShipTableCLast+1, .ShipBankC
.Failed:                SetCarryFlag                                ; if its over current bank max then a failure
                        ret
.ShipBankA:             ld      b,a
                        ld      a,BankShipModelsA
                        jp      .Done
.ShipBankB:             sub     a,ShipTableALast+1
                        ld      a,BankShipModelsB
                        jp      .Done
.ShipBankC:             sub     a,ShipTableBLast+1
                        ld      a,BankShipModelsC
.Done:                  ld      a,BankShipModelsA
                        ClearCarryFlag
                        ret
;GINF:
                        IFDEF SHIPBANKA
GetInfo:                                    ; gets pointer to ship data for ship type in a
GetInfoA:                                   ; gets pointer to ship data for ship type in a
                        ENDIF
                        IFDEF SHIPBANKB
GetInfoB:
                        ENDIF
                        IFDEF SHIPBANKC
GetInfoC:
                        ENDIF
                        ld          c,a
                        sra         a       
                        sra         a
                        sra         a
                        sra         a       ; Divide by 16 to get bank table offset
                        ld          b,a     ; save it as this is the number of x16 we need to subtract
                        ld          hl,ShipModelBankA
                        add         hl,a
                        ld          a,(hl)
                        ;MMUSelectShipModelA
                        ld          a,c
                        ld          d,b
                        ld          e,16
                        mul
                        sub         a,e
                        ld          hl,ShipModelTable
                        add         hl,a
                        add         hl,a
                        ld          e,(hl)
                        inc         hl
                        ld          d,(hl)
                        ret


; memcopy_dma, hl = target address de = source address to copy, bc = length"
                        IFDEF SHIPBANKA
CopyVerticesDataToUBnk: 
CopyVerticesDataToUBnkA:               
                        ENDIF
                        IFDEF SHIPBANKB
CopyVerticesDataToUBnkB:
                        ENDIF
                        IFDEF SHIPBANKC
CopyVerticesDataToUBnkC:
                        ENDIF
                        ld          hl,(VerticesAddyAddr)       ; now the pointers are in UBnk its easy to read
                        ld          de,UBnkHullVerticies
                        ld          b,0
                        ld			a,(VertexCtX6Addr)
                        ld          c,a
                        ex          de,hl                       ; dma transfer goes de -> hl i.e. opposite of ldir
                        call        memcopy_dma
                        ret

                        IFDEF SHIPBANKA
CopyEdgeDataToUBnk: 
CopyEdgeDataToUBnkA:               
                        ENDIF
                        IFDEF SHIPBANKB
CopyEdgeDataToUBnkB:
                        ENDIF
                        IFDEF SHIPBANKC
CopyEdgeDataToUBnkC:
                        ENDIF
                        ld          hl,(EdgeAddyAddr)          ; now the pointers are in UBnk its easy to read
                        ld          de,UBnkHullEdges
                        ld          b,0
                        ld			a,(LineX4Addr)
                        ld          c,a
                        ex          de,hl                       ; dma transfer goes de -> hl i.e. opposite of ldir
                        call        memcopy_dma
                        ret

                        IFDEF SHIPBANKA
CopyNormalDataToUBnk: 
CopyNormalDataToUBnkA:               
                        ENDIF
                        IFDEF SHIPBANKB
CopyNormalDataToUBnkB:
                        ENDIF
                        IFDEF SHIPBANKC
CopyNormalDataToUBnkC:
                        ENDIF
                        ld          hl,(FaceAddyAddr)          ; now the pointers are in UBnk its easy to read
                        ld          de,UBnkHullNormals
                        ld          b,0
                        ld          a,(FaceCtX4Addr)
                        ld          c,a
                        ex          de,hl                       ; dma transfer goes de -> hl i.e. opposite of ldir
                        call        memcopy_dma
                        ret
                        
                        IFDEF SHIPBANKA
CopyTrianlDataToUBnk: 
CopyTrianDataToUBnkA:               
                        ENDIF
                        IFDEF SHIPBANKB
CopyTrianDataToUBnkB:
                        ENDIF
                        IFDEF SHIPBANKC
CopyTrianDataToUBnkC:
                        ENDIF
    IFDEF SOLIDHULLTEST

                        ld          hl,(ShipSolidFillAddr)      ; now the pointers are in UBnk its easy to read
                        ld          de,UBnkHullSolid
                        ld          b,0
                        ld          a,(ShipSolidLenAddr)
                        ld          c,a
                        ex          de,hl                       ; dma transfer goes de -> hl i.e. opposite of ldir
                        call        memcopy_dma
                        ret
    ENDIF
;CopyShipIdToUBnk:       ld      


                        IFDEF SHIPBANKA
CopyShipDataToUBnk:     
CopyShipDataToUBnkA:    push        af
                        ld          a,BankShipModelsA
                        ENDIF
                        IFDEF SHIPBANKB
CopyShipDataToUBnkB:    push        af
                        ld          a,BankShipModelsB
                        ENDIF
                        IFDEF SHIPBANKC
CopyShipDataToUBnkC:    push        af
                        ld          a,BankShipModelsC
                        ENDIF
                        ld          (UBnkShipModelBank),a
                        pop         af                              ; save the current ship number and bank in case we need it later, say for a space station
                        ld			(UBnkShipModelNbr),a			; mark ship type in bank
                        
.GetHullDataLength:     ld          hl,ShipModelSizeTable
                        add         hl,a
                        add         hl,a                        ; we won't multiply by 2 as GetInfo is a general purpose routines so would end up x 4
                        ld          c,(hl)
                        inc         hl
                        ld          b,(hl)                      ; bc now equals length of data set
.GetHullDataAddress:    call        GetInfo                     ; de = address of Ship Data
                        ex          de,hl                       ; hl = address of Ship Data
                        ld          de,UBnkHullCopy             ; Universe bank
                        ld          bc,ShipDataLength           
                        ldir                                    
                        call        CopyVerticesDataToUBnk
                        call        CopyEdgeDataToUBnk
                        call        CopyNormalDataToUBnk
    IFDEF SOLIDHULLTEST
                        ReturnIfMemFalse ShipSolidFlagAddr
                        call        CopyTrianlDataToUBnk
    ENDIF
                        ret

; change to there are two banks
; the master table in both has the bank and ship replicated in boht banks to simplify quick bank switch
;

; Ships in Bank A
                         IFDEF SHIPBANKA
ShipModelBank1           DB BankShipModelsA
                         DB BankShipModelsB
                         DB BankShipModelsC
                         ENDIF
                         IFDEF SHIPBANKB
ShipModelBank2           DB BankShipModelsA
                         DB BankShipModelsB
                         DB BankShipModelsC
                         ENDIF
                         IFDEF SHIPBANKC
ShipModelBank3           DB BankShipModelsA
                         DB BankShipModelsB
                         DB BankShipModelsC
                         ENDIF
                         IFDEF SHIPBANKA

                         ENDIF
                         IFDEF SHIPBANKB

                         ENDIF
                         IFDEF SHIPBANKC

                         ENDIF
 

                        IFNDEF SHIPMODELTABLES
                        DEFINE SHIPMODELTABLES
ShipModelSizeTable:     EQU ShipModelSizeTableA
ShipModelBank:          EQU ShipModelBankA
ShipModelTable:         EQU ShipModelTableA
ShipVertexTable:        EQU ShipVertexTableA
ShipEdgeTable:          EQU ShipEdgeTableA
ShipNormalTable:        EQU ShipNormalTableA
                        ENDIF
                        
                        IFDEF SHIPBANKA

                        ENDIF
                        IFDEF SHIPBANKB

                        ENDIF
                        IFDEF SHIPBANKC

                        ENDIF


                DISPLAY "TODO: Later reorg these offsets for better 16 bit read - Done"
                DISPLAY "TODO: Add in roll max rates and data to allow ship replacement, reference to custom console"


; -> &565D	\ Start Hull Data. For each hull, first 20 bytes give header info.
; hull byte#0 high nibble is scoop info, lower nibble is debris spin info
; Scoop: 0 = no scoop 1= scoop , anything more?
; hull byte#1-2 area for missile lock, lo, hi
; hull byte#3   edges data info offset lo
; hull byte#4   faces data info offset lo
; hull byte#5   4*maxlines+1 for ship lines stack   
; hull byte#6   gun vertex*4   
; hull byte#7   explosion count e.g. &2A = 4*n+6
; hull byte#8   vertices*6		
; hull byte#9	edge Count
; hull bytes#10-11 bounty lo hi
; hull byte#12  faces*4
; hull byte#13  dot beyond distance	
; hull byte#14  energy
; hull byte#15  speed (end of 4th row)
; hull byte#16  edges offset hi (goes -ve to use other's edge net).
; hull byte#17  faces offset hi
; hull byte#18  Q% scaling of normals to make large objects' normals flare out further away
; hull byte#19  laser|missile(=lower 3 bits)
; hull byte#20  Added Vertices for 20,21

; Optimised version to be applied to add data brought in to here:
; hull byte#0 high nibble is scoop info, lower nibble is debris spin info
; hull byte#1-2 area for missile lock, lo, hi
; hull byte#3   edges data info offset lo
; hull byte#4   edges offset hi (goes -ve to use other's edge net). (was 16)
; hull byte#5   4*maxlines+1 for ship lines stack   
; hull byte#6   gun vertex*4   
; hull byte#7   explosion count e.g. &2A = 4*n+6
; hull byte#8   vertices*6		
; hull byte#9	edge Count
; hull bytes#10-11 bounty lo hi
; hull byte#12  faces*4
; hull byte#13  dot beyond distance	
; hull byte#14  energy
; hull byte#15  speed (end of 4th row)
; hull byte#16  faces data info offset lo (was 4)
; hull byte#17  faces offset hi
; hull byte#18  Q% scaling of normals to make large objects' normals flare out further away
; hull bute#19  laser|missile(=lower 3 bits)
; hull byte#20  Added Vertices for 20,21
;
; Vertex Data Structure
; Byte 0 X1Lo
; Byte 1 X1Hi
; Byte 2 Y1Lo
; Byte 3 Y1Hi
; Byte 4 High 4 bits Face 2 Index Low 4 bits = Face 1 Index
; Byte 5 High 4 bits Face 4 Index Low 4 bits = Face 3 Index
;
;
; Edge Data Structure
; Byte 0 
; Byte 1 - Face 1 Index (uppernibble), Face 2 Index (lowernibble)
; Byte 2 - Index to Vertex 1
; Byte 3 - Index to Vertex 2
;
; Normal/Faces Data Structure
;
;
;
; Original Data:
;	\ -> &565D	\ Start Hull Data. For each hull, first 20 bytes give header info.
;		\ hull byte#0 high nibble is scoop info, lower nibble is debris spin info
;		\ hull byte#1-2 area for missile lock, lo, hi
;		\ hull byte#3   edges data info offset lo
;		\ hull byte#4   faces data info offset lo
;		\ hull byte#5   4*maxlines+1 for ship lines stack   
;		\ hull byte#6   gun vertex*4   
;		\ hull byte#7   explosion count e.g. &2A = 4*n+6
;		\ hull byte#8   vertices*6		
;		\ hull bytes#10-11 bounty lo hi
;		\ hull byte#12  faces*4
;		\ hull byte#13  dot beyond distance	
;		\ hull byte#14  energy
;		\ hull byte#15  speed (end of 4th row)
;		\ hull byte#16  edges offset hi (goes -ve to use other's edge net).
;		\ hull byte#17  faces offset hi
;		\ hull byte#18  Q% scaling of normals to make large objects' normals flare out further away
;		\ hull bute#19  laser|missile(=lower 3 bits)
; Corrected pointers
; &565D \ Cargo cannister = Type 5
;                      0    1    2    3               4               5             6   7     8            9             10  11  12  13  14  15   16                17                 18  19     20                 21
;					   Scp  Missile   Edg             Edg             Lin           Gun Exp   Vtx          Edg           Bounty  Face             Edg               Face                          Vertices
;                      Deb  Lock      Lo              Hi              x4            Vtx Cnt   x6           X1            lo  hi  x4  Dot Erg Spd  hi                Hi                 Q   Laser  Lo                 hi
; Mapping Orginal to new
; 0    => 0
; 1-2  => 1-2
; 3    => EQU Edges
; 4    => EQU Normals
; 5    => EQU EdgesCnt
; 6    => 6
; 7    => 7
; 8    => EQU VertSize
; 9    => EQU EdgesCnt
; 10-11=> 10-11
; 12   => EQU  NormalsSize
; 13   => 13
; 14   => 14
; 15   => 15
; 16   => EQU Edges
; 17   => EQU Normals
; 18   => 18
; 19   => 19