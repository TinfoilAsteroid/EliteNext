Monitor:	            DB $04, $36, $00
                        DW MonitorEdges
                        DB MonitorEdgesSize
                        DB $00, $2A
                        DB MonitorVertSize
                        DB MonitorEdgesCnt
                        DB $01, $90
                        DB MonitorNormalsSize
                        DB $28, $84, $10
                        DW MonitorNormals
                        DB $00, $37
                        DW MonitorVertices
                        DB 0,0                      ; Type and Tactics
                        
MonitorVertices:	    DB $00, $0A, $8C, $1F, $FF, $FF
                        DB $14, $28, $14, $3F, $23, $01
                        DB $14, $28, $14, $BF, $50, $34
                        DB $32, $00, $0A, $1F, $78, $12
                        DB $32, $00, $0A, $9F, $96, $45
                        DB $1E, $04, $3C, $3F, $AA, $28
                        DB $1E, $04, $3C, $BF, $AA, $49
                        DB $12, $14, $3C, $3F, $AA, $23
                        DB $12, $14, $3C, $BF, $AA, $34
                        DB $00, $14, $3C, $7F, $AA, $89
                        DB $00, $28, $0A, $5F, $89, $67
                        DB $00, $22, $0A, $0A, $00, $00
                        DB $00, $1A, $32, $0A, $00, $00
                        DB $14, $0A, $3C, $4A, $77, $77
                        DB $0A, $00, $64, $0A, $77, $77
                        DB $14, $0A, $3C, $CA, $66, $66
                        DB $0A, $00, $64, $8A, $66, $66
MonitorVertSize:        equ $ - MonitorVertices
MonitorEdges:	        DB $1F, $01, $00, $04
	                    DB $1F, $12, $04, $0C
                        DB $1F, $23, $04, $1C
                        DB $1F, $34, $08, $20
                        DB $1F, $45, $08, $10
                        DB $1F, $50, $00, $08
                        DB $1F, $03, $04, $08
                        DB $1F, $67, $00, $28
                        DB $1F, $78, $0C, $28
                        DB $1F, $89, $24, $28
                        DB $1F, $96, $10, $28
                        DB $1F, $17, $00, $0C
                        DB $1F, $28, $0C, $14
                        DB $1F, $49, $18, $10
                        DB $1F, $56, $10, $00
                        DB $1F, $2A, $1C, $14
                        DB $1F, $3A, $20, $1C
                        DB $1F, $4A, $20, $18
                        DB $1F, $8A, $14, $24
                        DB $1F, $9A, $18, $24
                        DB $0A, $00, $2C, $30
                        DB $0A, $77, $34, $38
                        DB $0A, $66, $3C, $40
MonitorEdgesSize:       equ $ - MonitorEdges
MonitorEdgesCnt:        equ MonitorEdgesSize/4
MonitorNormals:	        DB $1F, $00, $3E, $0B
                        DB $1F, $2C, $2B, $0D
                        DB $3F, $36, $1C, $10
                        DB $3F, $00, $39, $1C
                        DB $BF, $36, $1C, $10
                        DB $9F, $2C, $2B, $0D
                        DB $DF, $26, $2F, $12
                        DB $5F, $26, $2F, $12
                        DB $7F, $27, $30, $0D
                        DB $FF, $27, $30, $0D
                        DB $3F, $00, $00, $40
MonitorNormalsSize:     equ $ - MonitorNormals
MonitorLen:             equ $ - Monitor
