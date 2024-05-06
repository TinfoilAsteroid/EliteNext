from   piio import piio as piio
import messagehandler as mh
import shipmodels

print ("TO DO - add in an emergency reset pin for GPIO so if this pin is set from either side, it resets status and rebuilds universe")
print ("Intiailised")
print ("In read mode skipped, next controls this")
running = True
messageHandler = mh.MessageHandler()
print ("Loading ship models")
shipmodels.loadModels()
print ("Enterint run mode")
while running:
    command = messageHandler.wait_for_command()
    print ("Command received ",command)
    if command == -1:
        print ("Desync reset")
        messageHandler.desyncReset()
    elif command > 0 and command < 255:
        messageHandler.processMsg(command)
    else:
        print ("Command ",command," unrecognised")
    if command == 0x66:
        print ("Received shutdown command")
        running = False
print("Exiting")
# shutdown
exit(0)

