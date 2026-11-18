# shipmodels.py
from shiploader import ShipLoader as sl
import numpy            as np
import shipmodel        as sm

# objects that are singleton
modelList = ["missile","coriolis","escape_pod","alloy","cargo"]
shipMasterList = np.empty (len(modelList),dtype=object)
# functions to support the singleton
def loadModels():
    for i, element in enumerate(modelList):
        shipdata = sl.loadShip("ship_"+element+".json")
        #shiploadobj.diagPrintShip(shipdata)
        #print ("Adding to array",shipdata)
        #print ("Index ",i,"Element ",element)
        shipMasterList[i] = sm.ShipModel(shipdata)
