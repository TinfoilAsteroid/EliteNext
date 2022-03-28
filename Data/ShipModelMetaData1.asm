ShipModelTable:
ShipModelTable1:         DW Adder                                   ;00 $00
                         DW Anaconda                                ;01 $01
                         DW Asp_Mk_2                                ;02 $02
                         DW Boa                                     ;03 $03
                         DW CargoType5                              ;04 $04
                         DW Boulder                                 ;05 $05
                         DW Asteroid                                ;06 $06                       
                         DW Bushmaster                              ;07 $07
                         DW Chameleon                               ;08 $08
                         DW CobraMk3                                ;09 $09
                         DW Cobra_Mk_1                              ;10 $0A
                         DW Cobra_Mk_3_P                            ;11 $0B
                         DW Constrictor                             ;12 $0C
                         DW Coriolis                                ;13 $0D
                         DW Cougar                                  ;14 $0E
                         DW Dodo                                    ;15 $0F
ShipVertexTable:
ShipVertexTable1:        DW AdderVertices                           ;00 $00
                         DW AnacondaVertices                        ;01 $01
                         DW Asp_Mk_2Vertices                        ;02 $02
                         DW BoaVertices                             ;03 $03
                         DW CargoType5Vertices                      ;04 $04
                         DW BoulderVertices                         ;05 $05
                         DW AsteroidVertices                        ;06 $06
                         DW BushmasterVertices                      ;07 $07
                         DW ChameleonVertices                       ;08 $08
                         DW CobraMk3Vertices                        ;09 $09
                         DW Cobra_Mk_1Vertices                      ;10 $0A
                         DW Cobra_Mk_3_PVertices                    ;11 $0B
                         DW ConstrictorVertices                     ;12 $0C
                         DW CoriolisVertices                        ;13 $0D
                         DW CougarVertices                          ;14 $0E
                         DW DodoVertices                            ;15 $0F
ShipEdgeTable:
ShipEdgeTable1:          DW AdderEdges                              ;00 $00
                         DW AnacondaEdges                           ;01 $01
                         DW Asp_Mk_2Edges                           ;02 $02
                         DW BoaEdges                                ;03 $03
                         DW CargoType5Edges                         ;04 $04
                         DW BoulderEdges                            ;05 $05
                         DW AsteroidEdges                           ;06 $06
                         DW BushmasterEdges                         ;07 $07
                         DW ChameleonEdges                          ;08 $08
                         DW CobraMk3Edges                           ;09 $09
                         DW Cobra_Mk_1Edges                         ;10 $0A
                         DW Cobra_Mk_3_PEdges                       ;11 $0B
                         DW ConstrictorEdges                        ;12 $0C
                         DW CoriolisEdges                           ;13 $0D
                         DW CougarEdges                             ;14 $0E
                         DW DodoEdges                               ;15 $0F
ShipNormalTable:
ShipNormalTable1:        DW AdderNormals                            ;00 $00
                         DW AnacondaNormals                         ;01 $01
                         DW Asp_Mk_2Normals                         ;02 $02
                         DW BoaNormals                              ;03 $03
                         DW CargoType5Normals                       ;04 $04
                         DW BoulderNormals                          ;05 $05
                         DW AsteroidNormals                         ;06 $06
                         DW BushmasterNormals                       ;07 $07
                         DW ChameleonNormals                        ;08 $08
                         DW CobraMk3Normals                         ;09 $09
                         DW Cobra_Mk_1Normals                       ;10 $0A
                         DW Cobra_Mk_3_PNormals                     ;11 $0B
                         DW ConstrictorNormals                      ;12 $0C
                         DW CoriolisNormals                         ;13 $0D
                         DW CougarNormals                           ;14 $0E
                         DW DodoNormals                             ;15 $0F
ShipModelSizeTable:
ShipModelSizeTable1:     DW AdderLen                                ;00 $00
                         DW AnacondaLen                             ;01 $01
                         DW Asp_Mk_2Len                             ;02 $02
                         DW BoaLen                                  ;03 $03
                         DW CargoType5Len                           ;04 $04
                         DW BoulderLen                              ;05 $05
                         DW AsteroidLen                             ;06 $06
                         DW BushmasterLen                           ;07 $07
                         DW ChameleonLen                            ;08 $08
                         DW CobraMk3Len                             ;09 $09
                         DW Cobra_Mk_1Len                           ;10 $0A
                         DW Cobra_Mk_3_PLen                         ;11 $0B
                         DW ConstrictorLen                          ;12 $0C
                         DW CoriolisLen                             ;13 $0D
                         DW CougarLen                               ;14 $0E
                         DW DodoLen                                 ;15 $0F
                         
                        include "Data/ships/Adder.asm"
                        include "Data/ships/Anaconda.asm"
                        include "Data/ships/Asp_Mk_2.asm"
                        include "Data/ships/Boa.asm"

                        include "Data/ships/CargoType5.asm"
                        include "Data/ships/Boulder.asm"
                        include "Data/ships/Asteroid.asm"

                        include "Data/ships/Bushmaster.asm"
                        include "Data/ships/Chameleon.asm"
                        include "Data/ships/CobraMk3.asm"
                        include "Data/ships/Cobra_Mk_1.asm"
                        include "Data/ships/Cobra_Mk_3_P.asm"
                        include "Data/ships/Constrictor.asm"
                        include "Data/ships/Coriolis.asm"
                        include "Data/ships/Cougar.asm"
                        include "Data/ships/Dodo.asm"