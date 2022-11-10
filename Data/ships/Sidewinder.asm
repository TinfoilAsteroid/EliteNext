Sidewinder:	            DB $00                      ; Number of cargo canisters released when destroyed
                        DW $1081                    ; Ship's targetable area LoHi
                        DW SidewinderEdges          ; Edge Data 
                        DB SidewinderEdgesSize      ; Size of Edge Data
                        DB $00                      ; Gun Vertex Byte offset
                        DB $1E                      ; Explosion Count 
                        DB SidewinderVertSize /6    ; Vertex Count /6
                        DB SidewinderVertSize       ; Vertex Count
                        DB SidewinderEdgesCnt       ; Edges Count
                        DW $0032                    ; Bounty LoHi
                        DB SidewinderNormalsSize    ; Face (Normal) Count
                        DB $14                      ; Range when it turns to a dot
                        DB $46                      ; Energy Max
                        DB $25                      ; Speed Max
                        DW SidewinderNormals        ; Normals
                        DB $02                      ; Q scaling
                        DB $10 | ShipMissiles1      ; Laser power and Nbr Missiles
                        DW SidewinderVertices       ; Verticles Address
                        DB ShipTypeNormal           ; Ship Type
                        DB 0                        ; NewB Tactics 
                        DB ShipCanAnger             ; AI Flags            
                        DB $30                      ; chance of ECM module
                        DB $FF                              ; Supports Solid Fill = false
                        DW $0000                            ; no solid data
                        DB $00                              ; no solid data
                        

SidewinderVertices:	DB $20, $00, $24, $9F, $10, $54
	DB $20, $00, $24, $1F, $20, $65
	DB $40, $00, $1C, $3F, $32, $66
	DB $40, $00, $1C, $BF, $31, $44
	DB $00, $10, $1C, $3F, $10, $32
	DB $00, $10, $1C, $7F, $43, $65
	DB $0C, $06, $1C, $AF, $33, $33
	DB $0C, $06, $1C, $2F, $33, $33
	DB $0C, $06, $1C, $6C, $33, $33
	DB $0C, $06, $1C, $EC, $33, $33

	
SidewinderVertSize: equ $ - SidewinderVertices	
	
	
	
SidewinderEdges:	DB $1F, $50, $00, $04
	DB $1F, $62, $04, $08
	DB $1F, $20, $04, $10
	DB $1F, $10, $00, $10
	DB $1F, $41, $00, $0C
	DB $1F, $31, $0C, $10
	DB $1F, $32, $08, $10
	DB $1F, $43, $0C, $14
	DB $1F, $63, $08, $14
	DB $1F, $65, $04, $14
	DB $1F, $54, $00, $14
	DB $0F, $33, $18, $1C
	DB $0C, $33, $1C, $20
	DB $0C, $33, $18, $24
	DB $0C, $33, $20, $24

SidewinderEdgesSize: equ $ - SidewinderEdges	
	
	
SidewinderEdgesCnt: equ SidewinderEdgesSize/4	
	
	
SidewinderNormals:	DB $1F, $00, $20, $08
	DB $9F, $0C, $2F, $06
	DB $1F, $0C, $2F, $06
	DB $3F, $00, $00, $70
	DB $DF, $0C, $2F, $06
	DB $5F, $00, $20, $08
	DB $5F, $0C, $2F, $06

	
SidewinderNormalsSize: equ $ - SidewinderNormals	
SidewinderLen: equ $ - Sidewinder	
