                IFNDEF SHIPEQUATES
                DEFINE SHIPEQUATES
ScoopDebrisOffset	    equ	0                               ; hull byte#0 high nibble is scoop info, lower nibble is debris spin info
MissileLockLoOffset	    equ 1
MissileLockHiOffset	    equ 2
EdgeAddyOffset		    equ 3
LineX4Offset		    equ 5
GunVertexOffset		    equ 6
ExplosionCtOffset	    equ 7
VertexCtX6Offset	    equ 8
EdgeCountOffset		    equ 9
BountyLoOffset		    equ 10
BountyHiOffset		    equ 11
FaceCtX4Offset		    equ 12
DotOffset			    equ 13
EnergyOffset		    equ 14
SpeedOffset			    equ 15
FaceAddyOffset		    equ 16
QOffset				    equ 18
LaserOffset			    equ 19
VerticiesAddyOffset     equ 20
ShipTypeOffset          equ 22
ShipNewBitsOffset       equ 23
ShipDataLength          equ ShipNewBitsOffset+1

CobraTablePointer       equ 43
;29 faulty
BankThreshold           equ 16

ShipTableALast          equ 23
ShipTableBLast          equ 39
ShipTableCLast          equ 55
               ENDIF
               

               


; For ship number A fetch the adjusted ship number in B and bank number in A for the respective ship based on the ship table
                        IFDEF SHIPBANKA
GetShipModelAddress:
GetShipModelAddressA:   ld      c,a
                        ld      hl,ShipModelBankA                   ; Ship Model BankA, B and C are all the same value
                        ENDIF
                        IFDEF SHIPBANKB
GetShipModelAddressB:   ld      c,a
                        ld      hl,ShipModelBankB
                        ENDIF
                        IFDEF SHIPBANKC
GetShipModelAddressC:   ld      c,a
                        ld      hl,ShipModelBankC
                        ENDIF
                        JumpIfALTNusng ShipTableALast+1, .ShipBankA
                        JumpIfALTNusng ShipTableBLast+1, .ShipBankB
                        JumpIfALTNusng ShipTableCLast+1, .ShipBankC
.Failed:                SetCarryFlag                                ; if its over current bank max then a failure
                        ret
.ShipBankA:             ld      b,a
                        jp      .Done
.ShipBankB:             sub     a,ShipTableALast+1
                        jp      .Done
.ShipBankC:             sub     a,ShipTableBLast+1
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
                        MMUSelectShipModelA
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
                        ld          hl,(VerticesAddyAddr)       ; now the pointers are in Ubnk its easy to read
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
                        ld          hl,(EdgeAddyAddr)          ; now the pointers are in Ubnk its easy to read
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
                        ld          hl,(FaceAddyAddr)          ; now the pointers are in Ubnk its easy to read
                        ld          de,UBnkHullNormals
                        ld          b,0
                        ld          a,(FaceCtX4Addr)
                        ld          c,a
                        ex          de,hl                       ; dma transfer goes de -> hl i.e. opposite of ldir
                        call        memcopy_dma
                        ret


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
                        ret

; change to there are two banks
; the master table in both has the bank and ship replicated in boht banks to simplify quick bank switch
;


                       

; Ships in Bank A
                         IFDEF SHIPBANKA
ShipModelBankA           DB BankShipModelsA
                         DB BankShipModelsB
                         DB BankShipModelsC
                         ENDIF
                         IFDEF SHIPBANKB
ShipModelBankB           DB BankShipModelsA
                         DB BankShipModelsB
                         DB BankShipModelsC
                         ENDIF
                         IFDEF SHIPBANKC
ShipModelBankC           DB BankShipModelsA
                         DB BankShipModelsB
                         DB BankShipModelsC
                         ENDIF
                         IFDEF SHIPBANKA
ShipModelTableA:         DW Adder                                   ;00
                         DW Anaconda                                ;01
                         DW Asp_Mk_2                                ;02
                         DW Asteroid                                ;03
                         DW Boa                                     ;04
                         DW Boulder                                 ;05
                         DW Bushmaster                              ;06
                         DW CargoType5                              ;07
                         DW Chameleon                               ;08
                         DW CobraMk3                                ;09
                         DW Cobra_Mk_1                              ;10
                         DW Cobra_Mk_3_P                            ;11
                         DW Constrictor                             ;12
                         DW Coriolis                                ;13
                         DW Cougar                                  ;14
                         DW Dodo                                    ;15
                         DW Dragon                                  ;16
                         DW Escape_Pod                              ;17
                         DW Fer_De_Lance                            ;18
                         DW Gecko                                   ;19
                         DW Ghavial                                 ;20
                         DW Iguana                                  ;21
                         DW Krait                                   ;22
                         DW Logo                                    ;23
ShipVertexTableA:        DW AdderVertices
                         DW AnacondaVertices
                         DW Asp_Mk_2Vertices
                         DW AsteroidVertices
                         DW BoaVertices
                         DW BoulderVertices
                         DW BushmasterVertices
                         DW CargoType5Vertices
                         DW ChameleonVertices
                         DW CobraMk3Vertices
                         DW Cobra_Mk_1Vertices
                         DW Cobra_Mk_3_PVertices
                         DW ConstrictorVertices
                         DW CoriolisVertices
                         DW CougarVertices
                         DW DodoVertices
ShipEdgeTableA:          DW AdderEdges
                         DW AnacondaEdges
                         DW Asp_Mk_2Edges
                         DW AsteroidEdges
                         DW BoaEdges
                         DW BoulderEdges
                         DW BushmasterEdges
                         DW CargoType5Edges
                         DW ChameleonEdges
                         DW CobraMk3Edges
                         DW Cobra_Mk_1Edges
                         DW Cobra_Mk_3_PEdges
                         DW ConstrictorEdges
                         DW CoriolisEdges
                         DW CougarEdges
                         DW DodoEdges
ShipNormalTableA:        DW AdderNormals
                         DW AnacondaNormals
                         DW Asp_Mk_2Normals
                         DW AsteroidNormals
                         DW BoaNormals
                         DW BoulderNormals
                         DW BushmasterNormals
                         DW CargoType5Normals
                         DW ChameleonNormals
                         DW CobraMk3Normals
                         DW Cobra_Mk_1Normals
                         DW Cobra_Mk_3_PNormals
                         DW ConstrictorNormals
                         DW CoriolisNormals
                         DW CougarNormals
                         DW DodoNormals
ShipModelSizeTableA:     DW AdderLen
                         DW AnacondaLen
                         DW Asp_Mk_2Len
                         DW AsteroidLen
                         DW BoaLen
                         DW BoulderLen
                         DW BushmasterLen
                         DW CargoType5Len
                         DW ChameleonLen
                         DW CobraMk3Len
                         DW Cobra_Mk_1Len
                         DW Cobra_Mk_3_PLen
                         DW ConstrictorLen
                         DW CoriolisLen
                         DW CougarLen
                         DW DodoLen
                         ENDIF
                         IFDEF SHIPBANKB
ShipModelTableB:         DW Dragon                                  ;24
                         DW Escape_Pod                              ;25
                         DW Fer_De_Lance                            ;26
                         DW Gecko                                   ;27
                         DW Ghavial                                 ;28
                         DW Iguana                                  ;29
                         DW Krait                                   ;30
                         DW Logo                                    ;31
                         DW Mamba                                   ;32
                         DW Missile                                 ;33
                         DW Monitor                                 ;34
                         DW Moray                                   ;35
                         DW Ophidian                                ;36
                         DW Plate                                   ;37
                         DW Python                                  ;38
                         DW Python_P                                ;39
ShipVertexTableB:        DW DragonVertices                          
                         DW Escape_PodVertices                      
                         DW Fer_De_LanceVertices                    
                         DW GeckoVertices                           
                         DW GhavialVertices                         
                         DW IguanaVertices                          
                         DW KraitVertices                           
                         DW LogoVertices                            
                         DW MambaVertices
                         DW MissileVertices
                         DW MonitorVertices
                         DW MorayVertices
                         DW OphidianVertices
                         DW PlateVertices
                         DW PythonVertices
                         DW Python_PVertices
ShipEdgeTableB:          DW DragonEdges
                         DW Escape_PodEdges
                         DW Fer_De_LanceEdges
                         DW GeckoEdges
                         DW GhavialEdges
                         DW IguanaEdges
                         DW KraitEdges
                         DW LogoEdges
                         DW MambaEdges
                         DW MissileEdges
                         DW MonitorEdges
                         DW MorayEdges
                         DW OphidianEdges
                         DW PlateEdges
                         DW PythonEdges
                         DW Python_PEdges
ShipNormalTableB:        DW DragonNormals
                         DW Escape_PodNormals
                         DW Fer_De_LanceNormals
                         DW GeckoNormals
                         DW GhavialNormals
                         DW IguanaNormals
                         DW KraitNormals
                         DW LogoNormals
                         DW MambaNormals
                         DW MissileNormals
                         DW MonitorNormals
                         DW MorayNormals
                         DW OphidianNormals
                         DW PlateNormals
                         DW PythonNormals
                         DW Python_PNormals
ShipModelSizeTableB:     DW DragonLen
                         DW Escape_PodLen
                         DW Fer_De_LanceLen
                         DW GeckoLen
                         DW GhavialLen
                         DW IguanaLen
                         DW KraitLen
                         DW LogoLen
                         DW MambaLen
                         DW MissileLen
                         DW MonitorLen
                         DW MorayLen
                         DW OphidianLen
                         DW PlateLen
                         DW PythonLen
                         DW Python_PLen
                         ENDIF
                         IFDEF SHIPBANKC
ShipModelTableC:         DW Rattler                                 ;40
                         DW Rock_Hermit                             ;41
                         DW ShuttleType9                            ;42
                         DW Shuttle_Mk_2                            ;43
                         DW Sidewinder                              ;44
                         DW Splinter                                ;45
                         DW TestVector                              ;46
                         DW Thargoid                                ;47
                         DW Thargon                                 ;48
                         DW TransportType10                         ;49
                         DW Viper                                   ;50
                         DW Worm                                    ;51
                         DW 0                                       ;52
                         DW 0                                       ;53
                         DW 0                                       ;54
                         DW 0                                       ;55
ShipVertexTableC:        DW RattlerVertices
                         DW Rock_HermitVertices
                         DW ShuttleType9Vertices
                         DW Shuttle_Mk_2Vertices
                         DW SidewinderVertices
                         DW SplinterVertices
                         DW TestVectorVertices
                         DW ThargoidVertices
                         DW ThargonVertices
                         DW TransportType10Vertices
                         DW ViperVertices
                         DW WormVertices
                         DW 0
                         DW 0
                         DW 0
                         DW 0
ShipEdgeTableC:          DW RattlerEdges
                         DW Rock_HermitEdges
                         DW ShuttleType9Edges
                         DW Shuttle_Mk_2Edges
                         DW SidewinderEdges
                         DW SplinterEdges
                         DW TestVectorEdges
                         DW ThargoidEdges
                         DW ThargonEdges
                         DW TransportType10Edges
                         DW ViperEdges
                         DW WormEdges
                         DW 0
                         DW 0
                         DW 0
                         DW 0
ShipNormalTableC:        DW RattlerNormals
                         DW Rock_HermitNormals
                         DW ShuttleType9Normals
                         DW Shuttle_Mk_2Normals
                         DW SidewinderNormals
                         DW SplinterNormals
                         DW TestVectorNormals
                         DW ThargoidNormals
                         DW ThargonNormals
                         DW TransportType10Normals
                         DW ViperNormals
                         DW WormNormals
                         DW 0
                         DW 0
                         DW 0
                         DW 0
ShipModelSizeTableC:     DW RattlerLen
                         DW Rock_HermitLen
                         DW ShuttleType9Len
                         DW Shuttle_Mk_2Len
                         DW SidewinderLen
                         DW SplinterLen
                         DW TestVectorLen
                         DW ThargoidLen
                         DW ThargonLen
                         DW TransportType10Len
                         DW ViperLen
                         DW WormLen
                         DW 0
                         DW 0
                         DW 0
                         DW 0
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
                        include "Data/Ships/Adder.asm"
                        include "Data/Ships/Anaconda.asm"
                        include "Data/Ships/Asp_Mk_2.asm"
                        include "Data/Ships/Asteroid.asm"
                        include "Data/Ships/Boa.asm"
                        include "Data/Ships/Boulder.asm"
                        include "Data/Ships/Bushmaster.asm"
                        include "Data/Ships/CargoType5.asm"
                        include "Data/Ships/Chameleon.asm"
                        include "Data/Ships/CobraMk3.asm"
                        include "Data/Ships/Cobra_Mk_1.asm"
                        include "Data/Ships/Cobra_Mk_3_P.asm"
                        include "Data/Ships/Constrictor.asm"
                        include "Data/Ships/Coriolis.asm"
                        include "Data/Ships/Cougar.asm"
                        include "Data/Ships/Dodo.asm"
                        ENDIF
                        IFDEF SHIPBANKB
                        include "Data/Ships/Dragon.asm"
                        include "Data/Ships/Escape_Pod.asm"
                        include "Data/Ships/Fer_De_Lance.asm"
                        include "Data/Ships/Gecko.asm"
                        include "Data/Ships/Ghavial.asm"
                        include "Data/Ships/Iguana.asm"
                        include "Data/Ships/Krait.asm"
                        include "Data/Ships/Logo.asm"
                        include "Data/Ships/Mamba.asm"
                        include "Data/Ships/Missile.asm"
                        include "Data/Ships/Monitor.asm"
                        include "Data/Ships/Moray.asm"
                        include "Data/Ships/Ophidian.asm"
                        include "Data/Ships/Plate.asm"
                        include "Data/Ships/Python.asm"
                        include "Data/Ships/Python_P.asm"
                        ENDIF
                        IFDEF SHIPBANKC
                        include "Data/Ships/Rattler.asm"
                        include "Data/Ships/Rock_Hermit.asm"
                        include "Data/Ships/ShuttleType9.asm"
                        include "Data/Ships/Shuttle_Mk_2.asm"
                        include "Data/Ships/Sidewinder.asm"
                        include "Data/Ships/Splinter.asm"
                        include "Data/Ships/TestVector.asm"
                        include "Data/Ships/Thargoid.asm"
                        include "Data/Ships/Thargon.asm"
                        include "Data/Ships/TransportType10.asm"
                        include "Data/Ships/Viper.asm"
                        include "Data/Ships/Worm.asm"
                        ENDIF


; TODO Later reorg these offsets for better 16 bit read - Done
; TODO Add in roll max rates and data to allow ship replacement, reference to custom console


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