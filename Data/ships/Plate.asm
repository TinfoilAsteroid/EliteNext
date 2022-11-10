Plate:	                DB $80                    ; Number of cargo canisters released when destroyed
                        DW $0064                  ; Ship's targetable area LoHi
                        DW PlateEdges             ; Edge Data 
                        DB PlateEdgesSize         ; Size of Edge Data
                        DB $00                    ; Gun Vertex Byte offset
                        DB $0A                    ; Explosion Count 
                        DB PlateVertSize /6       ; Vertex Count /6
                        DB PlateVertSize          ; Vertex Count
                        DB PlateEdgesCnt          ; Edges Count
                        DW $0000                  ; Bounty LoHi
                        DB PlateNormalsSize       ; Face (Normal) Count
                        DB $05                    ; Range when it turns to a dot
                        DB $10                    ; Energy Max
                        DB $10                    ; Speed Max
                        DW PlateNormals           ; Normals
                        DB $03                    ; Q scaling
                        DB $00                    ; Laser power and Nbr Missiles
                        DW PlateVertices          ; Verticles Address
                        DB ShipTypeScoopable      ; Ship Type
                        DB 0                      ; NewB Tactics 
                        DB ShipCanAnger           ; AI Flags            
                        DB $00                    ; chance of ECM module
                        DB $FF                              ; Supports Solid Fill = false
                        DW $0000                            ; no solid data
                        DB $00                              ; no solid data
                        

	
PlateVertices:	        DB $0F, $16, $09, $FF, $FF, $FF
                        DB $0F, $26, $09, $BF, $FF, $FF
                        DB $13, $20, $0B, $14, $FF, $FF

PlateVertSize: equ $ - PlateVertices	
	
	
	
PlateEdges:	DB $1F, $FF, $00, $04
	DB $10, $FF, $04, $08
	DB $14, $FF, $08, $0C
	DB $10, $FF, $0C, $00

PlateEdgesSize: equ $ - PlateEdges	
	
	
PlateEdgesCnt: equ PlateEdgesSize/4	
	
	
PlateNormals:	DB $00, $00, $00, $00

	
PlateNormalsSize: equ $ - PlateNormals	
PlateLen: equ $ - Plate	
