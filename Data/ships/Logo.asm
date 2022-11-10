Logo:	                DB $00                    ; Number of cargo canisters released when destroyed
                        DW $2649                  ; Ship's targetable area LoHi
                        DW LogoEdges              ; Edge Data 
                        DB LogoEdgesSize          ; Size of Edge Data
                        DB $00                    ; Gun Vertex Byte offset
                        DB $36                    ; Explosion Count 
                        DB LogoVertSize /6        ; Vertex Count /6
                        DB LogoVertSize           ; Vertex Count
                        DB LogoEdgesCnt           ; Edges Count
                        DW $0000                  ; Bounty LoHi
                        DB LogoNormalsSize        ; Face (Normal) Count
                        DB $63                    ; Range when it turns to a dot
                        DB $FC                    ; Energy Max
                        DB $24                    ; Speed Max
                        DW LogoNormals            ; Normals
                        DB $01                    ; Q scaling
                        DB $00                    ; Laser power and Nbr Missiles
                        DW LogoVertices           ; Verticles Address
                        DB ShipTypeText           ; Ship Type
                        DB 0                      ; NewB Tactics 
                        DB 0                      ; AI Flags            
                        DB $FF                    ; chance of ECM module
                        DB $FF                              ; Supports Solid Fill = false
                        DW $0000                            ; no solid data
                        DB $00                              ; no solid data
                        

LogoVertices:	DB $00, $09, $37, $5F, $00, $00
	DB $0A, $09, $1E, $DF, $00, $00
	DB $19, $09, $5D, $DF, $00, $00
	DB $96, $09, $B4, $DF, $00, $00
	DB $5A, $09, $0A, $DF, $00, $00
	DB $8C, $09, $0A, $DF, $00, $00
	DB $00, $09, $5F, $7F, $00, $00
	DB $8C, $09, $0A, $5F, $00, $00
	DB $5A, $09, $0A, $5F, $00, $00
	DB $96, $09, $B4, $5F, $00, $00
	DB $19, $09, $5D, $5F, $00, $00
	DB $0A, $09, $1E, $5F, $00, $00
	DB $55, $09, $1E, $FF, $02, $33
	DB $55, $09, $1E, $7F, $02, $44
	DB $46, $0B, $05, $9F, $01, $33
	DB $46, $0B, $19, $BF, $02, $33
	DB $46, $0B, $19, $3F, $02, $44
	DB $46, $0B, $05, $1F, $01, $44
	DB $00, $09, $05, $5F, $00, $00
	DB $00, $09, $05, $5F, $00, $00
	DB $00, $09, $05, $5F, $00, $00
	DB $1C, $0B, $02, $BF, $00, $00
	DB $31, $0B, $02, $BF, $00, $00
	DB $31, $0B, $0A, $BF, $00, $00
	DB $31, $0B, $11, $BF, $00, $00
	DB $1C, $0B, $11, $BF, $00, $00
	DB $1C, $0B, $0A, $BF, $00, $00
	DB $18, $0B, $02, $BF, $00, $00
	DB $18, $0B, $11, $BF, $00, $00
	DB $03, $0B, $11, $BF, $00, $00
	DB $00, $0B, $02, $3F, $00, $00
	DB $00, $0B, $11, $3F, $00, $00
	DB $04, $0B, $02, $3F, $00, $00
	DB $19, $0B, $02, $3F, $00, $00
	DB $0E, $0B, $02, $3F, $00, $00
	DB $0E, $0B, $11, $3F, $00, $00
	DB $31, $0B, $02, $3F, $00, $00
	DB $1C, $0B, $02, $3F, $00, $00
	DB $1C, $0B, $0A, $3F, $00, $00
	DB $1C, $0B, $11, $3F, $00, $00
	DB $31, $0B, $11, $3F, $00, $00
	DB $31, $0B, $0A, $3F, $00, $00

LogoVertSize: equ $ - LogoVertices	
	
	
	
LogoEdges:	DB $1F, $00, $00, $04
	DB $1F, $00, $04, $08
	DB $1F, $00, $08, $0C
	DB $1F, $00, $0C, $10
	DB $1F, $00, $10, $14
	DB $1F, $00, $14, $18
	DB $1F, $00, $18, $1C
	DB $1F, $00, $1C, $20
	DB $1F, $00, $20, $24
	DB $1F, $00, $24, $28
	DB $1F, $00, $28, $2C
	DB $1F, $00, $2C, $00
	DB $1E, $03, $38, $3C
	DB $1E, $01, $3C, $40
	DB $1E, $04, $40, $44
	DB $1E, $01, $44, $38
	DB $1E, $03, $10, $30
	DB $1E, $22, $30, $34
	DB $1E, $04, $34, $20
	DB $1E, $11, $20, $10
	DB $1E, $13, $10, $38
	DB $1E, $13, $30, $3C
	DB $1E, $24, $34, $40
	DB $1E, $14, $20, $44
	DB $1E, $00, $54, $58
	DB $1E, $00, $58, $60
	DB $1E, $00, $60, $64
	DB $1E, $00, $5C, $68
	DB $1E, $00, $6C, $70
	DB $1E, $00, $70, $74
	DB $1E, $00, $78, $7C
	DB $1E, $00, $80, $84
	DB $1E, $00, $88, $8C
	DB $1E, $00, $90, $94
	DB $1E, $00, $94, $9C
	DB $1E, $00, $9C, $A0
	DB $1E, $00, $A4, $98

LogoEdgesSize: equ $ - LogoEdges	
	
	
LogoEdgesCnt: equ LogoEdgesSize/4	
	
	
LogoNormals:	DB $1F, $00, $17, $00
	DB $1F, $00, $04, $0F
	DB $3F, $00, $0D, $34
	DB $9F, $51, $51, $00
	DB $1F, $51, $51, $00

	
LogoNormalsSize: equ $ - LogoNormals	
LogoLen: equ $ - Logo	
