import pigio

DataToSend = [1,2,4,6,8,10,64,88, 90]

myPi = piio()

for value in DataToSend:
    myPi.write_value(value)
    
while(1 ==1 ):
    returnval = myPi.read_value
    print ('Returned ',returnval)
    

