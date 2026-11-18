import json


class   ShipLoader:
    @staticmethod
    def loadShip (filename):
        print ("Loading ",filename)
        file = open(filename)
        data = json.load(file)
        file.close()
        return data
     
    @staticmethod
    def diagPrintShip(shipData):
        for key,value in shipData.items():
            print (key,":",value)
