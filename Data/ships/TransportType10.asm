TransportType10:	    DB $00
                        DW $09C4
                        DW TransportType10Edges
                        DB TransportType10EdgesSize
                        DB $30, $1A
                        DB TransportType10VertSize /6 
                        DB TransportType10VertSize
                        DB TransportType10EdgesCnt
                        DB $00, $00
                        DB TransportType10NormalsSize
                        DB $10, $20, $0A
                        DW TransportType10Normals
                        DB $02, $00
                        DW TransportType10Vertices
                        DB 0,0                      ; Type and Tactics
                        DB 0

TransportType10Vertices:DB $00, $0A, $1A, $3F, $06, $77     ;01
                        DB $19, $04, $1A, $BF, $01, $77     ;02
                        DB $1C, $03, $1A, $FF, $01, $22     ;03
                        DB $19, $08, $1A, $FF, $02, $33     ;04
                        DB $1A, $08, $1A, $7F, $03, $44     ;05
                        DB $1D, $03, $1A, $7F, $04, $55     ;06
                        DB $1A, $04, $1A, $3F, $05, $66     ;07
                        DB $00, $06, $0C, $13, $FF, $FF     ;08
                        DB $1E, $01, $0C, $DF, $17, $89     ;09
                        DB $21, $08, $0C, $DF, $12, $39     ;10
                        DB $21, $08, $0C, $5F, $34, $5A     ;11
                        DB $1E, $01, $0C, $5F, $56, $AB     ;12
                        DB $0B, $02, $1E, $DF, $89, $CD     ;13
                        DB $0D, $08, $1E, $DF, $39, $DD     ;14
                        DB $0E, $08, $1E, $5F, $3A, $DD     ;15
                        DB $0B, $02, $1E, $5F, $AB, $CD     ;16
                        DB $05, $06, $02, $87, $77, $77     ;17
                        DB $12, $03, $02, $87, $77, $77     ;18
                        DB $05, $07, $07, $A7, $77, $77     ;19
                        DB $12, $04, $07, $A7, $77, $77     ;20
                        DB $0B, $06, $0E, $A7, $77, $77     ;21
                        DB $0B, $05, $07, $A7, $77, $77     ;22
                        DB $05, $07, $0E, $27, $66, $66     ;23
                        DB $12, $04, $0E, $27, $66, $66     ;24
                        DB $0B, $05, $07, $27, $66, $66     ;25
                        DB $05, $06, $03, $27, $66, $66     ;26
                        DB $12, $03, $03, $27, $66, $66     ;27
                        DB $0B, $04, $08, $07, $66, $66     ;28
                        DB $0B, $05, $03, $27, $66, $66     ;29
                        DB $10, $08, $0D, $E6, $33, $33     ;30
                        DB $10, $08, $10, $C6, $33, $33     ;31
                        DB $11, $08, $0D, $66, $33, $33     ;32
                        DB $11, $08, $10, $46, $33, $33     ;33
                        DB $0D, $03, $1A, $E8, $00, $00     ;34
                        DB $0D, $03, $1A, $68, $00, $00     ;35
                        DB $09, $03, $1A, $25, $00, $00     ;36
                        DB $08, $03, $1A, $A5, $00, $00     ;37

TransportType10VertSize: equ $ - TransportType10Vertices	
	
	
	
TransportType10Edges:	DB $1F, $07, $00, $04               ;01
                        DB $1F, $01, $04, $08               ;02
                        DB $1F, $02, $08, $0C               ;03
                        DB $1F, $03, $0C, $10               ;04
                        DB $1F, $04, $10, $14               ;05
                        DB $1F, $05, $14, $18               ;06
                        DB $1F, $06, $00, $18               ;07
                        DB $10, $67, $00, $1C               ;08
                        DB $1F, $17, $04, $20               ;09
                        DB $0B, $12, $08, $24               ;10
                        DB $1F, $23, $0C, $24               ;11
                        DB $1F, $34, $10, $28               ;12
                        DB $0B, $45, $14, $28               ;13
                        DB $1F, $56, $18, $2C               ;14
                        DB $11, $78, $1C, $20               ;15
                        DB $11, $19, $20, $24               ;16
                        DB $11, $5A, $28, $2C               ;17
                        DB $11, $6B, $1C, $2C               ;18
                        DB $13, $BC, $1C, $3C               ;19
                        DB $13, $8C, $1C, $30               ;20
                        DB $10, $89, $20, $30               ;21
                        DB $1F, $39, $24, $34               ;22
                        DB $1F, $3A, $28, $38               ;23
                        DB $10, $AB, $2C, $3C               ;24
                        DB $1F, $9D, $30, $34               ;25
                        DB $1F, $3D, $34, $38               ;26
                        DB $1F, $AD, $38, $3C               ;27
                        DB $1F, $CD, $30, $3C               ;28
                        DB $07, $77, $40, $44               ;29
                        DB $07, $77, $48, $4C               ;30
                        DB $07, $77, $4C, $50               ;31
                        DB $07, $77, $48, $50               ;32
                        DB $07, $77, $50, $54               ;33
                        DB $07, $66, $58, $5C               ;34
                        DB $07, $66, $5C, $60               ;35
                        DB $07, $66, $60, $58               ;36
                        DB $07, $66, $64, $68               ;37
                        DB $07, $66, $68, $6C               ;38
                        DB $07, $66, $64, $6C               ;39
                        DB $07, $66, $6C, $70               ;40
                        DB $06, $33, $74, $78               ;41
                        DB $06, $33, $7C, $80               ;42
                        DB $08, $00, $84, $88               ;43
                        DB $05, $00, $88, $8C               ;44
                        DB $05, $00, $8C, $90               ;45
                        DB $05, $00, $90, $84               ;46

TransportType10EdgesSize: equ $ - TransportType10Edges	
	
	
TransportType10EdgesCnt: equ TransportType10EdgesSize/4	
	
	
TransportType10Normals:	DB $3F, $00, $00, $67               ;01
                        DB $BF, $6F, $30, $07               ;02
                        DB $FF, $69, $3F, $15               ;03
                        DB $5F, $00, $22, $00               ;04
                        DB $7F, $69, $3F, $15               ;05
                        DB $3F, $6F, $30, $07               ;06
                        DB $1F, $08, $20, $03               ;07
                        DB $9F, $08, $20, $03               ;08
                        DB $93, $08, $22, $0B               ;09
                        DB $9F, $4B, $20, $4F               ;10
                        DB $1F, $4B, $20, $4F               ;11
                        DB $13, $08, $22, $0B               ;12
                        DB $1F, $00, $26, $11               ;13
                        DB $1F, $00, $00, $79               ;14

	
TransportType10NormalsSize: equ $ - TransportType10Normals	
TransportType10Len: equ $ - TransportType10	
