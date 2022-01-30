ShipModelTable:
ShipModelTable1:         DW Adder                                   ;00
                         DW Anaconda                                ;01
                         DW Asp_Mk_2                                ;02
                         DW Boa                                     ;03
                         
                         DW CargoType5                              ;04
                         DW Boulder                                 ;05
                         DW Asteroid                                ;06
                         
                         DW Bushmaster                              ;07
                         DW Chameleon                               ;08
                         DW CobraMk3                                ;09
                         DW Cobra_Mk_1                              ;10
                         DW Cobra_Mk_3_P                            ;11
                         DW Constrictor                             ;12
                         DW Coriolis                                ;13
                         DW Cougar                                  ;14
                         DW Dodo                                    ;15
ShipVertexTable:
ShipVertexTable1:        DW AdderVertices
                         DW AnacondaVertices
                         DW Asp_Mk_2Vertices
                         DW BoaVertices

                         DW CargoType5Vertices
                         DW BoulderVertices
                         DW AsteroidVertices

                         DW BushmasterVertices
                         DW ChameleonVertices
                         DW CobraMk3Vertices
                         DW Cobra_Mk_1Vertices
                         DW Cobra_Mk_3_PVertices
                         DW ConstrictorVertices
                         DW CoriolisVertices
                         DW CougarVertices
                         DW DodoVertices
ShipEdgeTable:
ShipEdgeTable1:          DW AdderEdges
                         DW AnacondaEdges
                         DW Asp_Mk_2Edges
                         DW BoaEdges

                         DW CargoType5Edges
                         DW BoulderEdges
                         DW AsteroidEdges

                         DW BushmasterEdges
                         DW ChameleonEdges
                         DW CobraMk3Edges
                         DW Cobra_Mk_1Edges
                         DW Cobra_Mk_3_PEdges
                         DW ConstrictorEdges
                         DW CoriolisEdges
                         DW CougarEdges
                         DW DodoEdges
ShipNormalTable:
ShipNormalTable1:        DW AdderNormals
                         DW AnacondaNormals
                         DW Asp_Mk_2Normals
                         DW BoaNormals

                         DW CargoType5Normals
                         DW BoulderNormals
                         DW AsteroidNormals

                         DW BushmasterNormals
                         DW ChameleonNormals
                         DW CobraMk3Normals
                         DW Cobra_Mk_1Normals
                         DW Cobra_Mk_3_PNormals
                         DW ConstrictorNormals
                         DW CoriolisNormals
                         DW CougarNormals
                         DW DodoNormals
ShipModelSizeTable:
ShipModelSizeTable1:     DW AdderLen
                         DW AnacondaLen
                         DW Asp_Mk_2Len
                         DW BoaLen

                         DW CargoType5Len
                         DW BoulderLen
                         DW AsteroidLen

                         DW BushmasterLen
                         DW ChameleonLen
                         DW CobraMk3Len
                         DW Cobra_Mk_1Len
                         DW Cobra_Mk_3_PLen
                         DW ConstrictorLen
                         DW CoriolisLen
                         DW CougarLen
                         DW DodoLen
                         
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