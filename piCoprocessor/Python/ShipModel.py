import numpy as np

class ShipEdge:
    face1                   = 0
    face2                   = 0
    startNode               = 0
    endNode                 = 0
    always_draw_distance    = 31.0
    
class ShipFaceNormal:
    x                       = 0.0
    y                       = 0.0
    z                       = 0.0
    always_draw_distance    = 31.0


class ShipNode:
    x                       = 0.0
    y                       = 0.0
    z                       = 0.0
    always_draw_distance    = 31.0
    face1                   = 0
    face2                   = 0
    face3                   = 0
    face4                   = 0    

class ShipModel:

    shipModelId             = 0
    viewDistance            = 0.0
    drawAllFacesDistance    = 0.0
    maxRoll                 = 0.0
    maxPitch                = 0.0
    maxSpeed                = 0.0
    nodeCount               = 0
    lineCount               = 0
    normalCount             = 0
    nodeList                = np.empty([60, dtype = ShipNode)
    lineList                = np.empty([60, dtype = ShipEdge)
    normalList              = np.empty([60, dtype = ShipFaceNormal)
