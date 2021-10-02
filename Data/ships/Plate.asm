Plate:	DB $80, $00, $64
	DW PlateEdges
	DB PlateEdgesSize
	DB $00, $0A
	DB PlateVertSize
	DB PlateEdgesCnt
	DB $00, $00
	DB PlateNormalsSize
	DB $05, $10, $10
	DW PlateNormals
	DB $03, $00
	DW PlateVertices

	
PlateVertices:	DB $0F, $16, $09, $FF, $FF, $FF
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
