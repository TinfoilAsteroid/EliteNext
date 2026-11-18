import numpy as np

class ShipData:
    __slots__= position, rollRate, pitchRate, acceleration, roll, pitch, speed, distance, orientation, ship_id, ship_id_target, explosionCountDown, shipStatus, projectedPoint, faceVisibilescreenLines, lineType
    position        = np.full([3] , 0.0, dtype=float)
    rollRate        = 0.0
    pitchRate       = 0.0
    acceleration    = 0.0
    roll            = 0.0
    pitch           = 0.0
    speed           = 0.0
    distance        = 0.0
    orientation     = np.identity(3)
    ship_id         = 0
    ship_id_target  = 0
    explosionCountDown = 0
    shipStatus      = 0
    shipModel       = 0
    projectedPoint  = np.empty([60,3], dtype = float) // Nodes projects to world
    faceVisibile    = np.empty([60],   dtype = int)
    screenLines     = np.empty([60,4], dtype = int)
    lineType        = np.empty([60],   dtype = int) // 0 = invisible, 1 = line, 2 = point


    def __init__(self, shipModelNbr):


    def applyPitchRollAndSpeed(self)

    def isShipInSights(self)

    def explodeShip(self)

    def destroyShip(self)

    def setShipOrientation(self,orientationmat):
        self.orientation = np.copy(orientationmat)

    def updateShip(self)


class ShipDataSet:
    Ships              = np.empty([12], dtype = ShipData)
    ShipsUsed          = np.full([12],  -1, dtype = int)
    ShipModels         = np.empty([60], dtype = ShipModel)
    
    def createShip (self,shipModelNbr):
        # fail if the ship model is invalid
        if (shipModelNbr < 0 || shipModelNbr > shipIdMax)
           return
        freeslot = np.where(ShipsUsed == 0)
        # fail if the slots are all used
        if freeslot.size == 0:
           return
        freeIndex = freeslot[0]
        ShipsUsed[freeIndex] = shipModelNbr
        Ships[freeIndex] = ShipData(freeIndex, shipModels[shipModelNbr])

        
    def removeShip(self,shipId):
        if (shipId < 0 || shipId >> 12)
            return
        ShipsUsed[shipId] = 0
        oldShip = Ships[shipId]
        Ships[shipId] = ShipData()
        del oldShip
        
            
    