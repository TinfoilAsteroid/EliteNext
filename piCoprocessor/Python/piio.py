import pigpio
import numpy as np
import math

# pi accellerator pins
# 0  1  2  3  4  5  6  7  8  9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25..26
#            D3 D2 D1 D0 D7 D6  D5  D4                                                  Rdy Cts Ack
#                                                                                           Dsr
class piio:
    pi = 0
    start_pin = 4
    data_ready_pin = 24
    clear_to_send_pin = 25
    ack_pin = 26
    reset_pin = 27          # used if something happens in the code and one device needs to signal its lost data stream
    debugmode = True
    
    # Must be called first to initialise 

    def __init__ (self):
        print ("Intiailising pigpio")
        self.pi = pigpio.pi()
        # initialse all control pins to low (DSR, CTS, ACK)
        print ("Clearing status bits and data")
        self.desyncReset()
    
    def desyncReset(self):
        self.set_port_write()
        #              3322222222221111111111
        #              10987654321098765432109876543210
        clearmask =  0b00000101000000000000111111110000
        self.pi.clear_bank_1(clearmask)
        self.set_port_read()
        self.pi.write(self.ack_pin,0)
        self.pi.write(self.clear_to_send_pin,0)
        

    def set_port_read(self):
        self.pi.set_mode(self.data_ready_pin, pigpio.INPUT)
        self.pi.set_mode(self.clear_to_send_pin, pigpio.OUTPUT)
        self.pi.set_mode(self.ack_pin,pigpio.OUTPUT)
        self.pi.set_mode(self.reset_pin,pigpio.INPUT)
        for i in range(self.start_pin,self.start_pin+8):
            self.pi.set_mode(i,pigpio.INPUT)
        #print ("DSR in, CTS, ACK out, DATA in")

    def write_mode(self):
        self.set_port_write()

    def set_port_write(self):
        self.pi.set_mode(self.data_ready_pin, pigpio.OUTPUT)
        self.pi.set_mode(self.clear_to_send_pin, pigpio.INPUT)
        self.pi.set_mode(self.ack_pin,pigpio.INPUT)
        self.pi.set_mode(self.reset_pin,pigpio.OUTPUT)
        for i in range(self.start_pin,self.start_pin+8):
            self.pi.set_mode(i,pigpio.OUTPUT)
        print ("DSR out, CTS, ACK in, DATA out")

    def shutdownPigpio(self):
        piio.pi.stop()

    def data_ready(self):
        self.pi.write(self.data_ready_pin,1)

    def set_data_not_ready(self):
        self.pi.write(self.data_ready_pin,0)

    def write_byte(self,byte):
        #                                               3322222222221111111111
        #                                               10987654321098765432109876543210
        # set up byte with data ready bit done
        # done by caller self.set_port_write()
        debug = False
        self.pi.write(self.data_ready_pin,0)            # set data set ready to low immedately
        #print ("In write byte")
        if debug: print ("Clearing data ready")
        if debug: print ("Input byte ", byte)
        bitmask = 0b00000001000000000000000000000000
        if debug: print ("Bit mask ", bitmask)
        if debug: print ("Data to send ",byte & 0xF0,byte & 0x0F )
        mybyte = ((byte & 0x0F) << 8 ) + (byte & 0xF0)
        mybyte += bitmask
        # move to 2 bytes and d swapnib at the same time
        # when clear to send is set, ack will also be set low so next byte can be acknowledged
        while True:
            if debug: print ("Waiting for CTS 1 and ACK 0", self.pi.read(self.data_ready_pin), self.pi.read(self.clear_to_send_pin), self.pi.read(self.ack_pin))
            if self.pi.read(self.clear_to_send_pin) == 1 and self.pi.read(self.ack_pin) == 0: break
        #print ("Write mode")
        clearmask =  0b00000000000000000000111111110000
        self.pi.clear_bank_1(clearmask)
        # now as we have cleared bits, set the respective ones that were set to 1 as well as data ready
        if debug: print("Sending ",mybyte)
        self.pi.set_bank_1(mybyte)
        if debug: print ("Waiting for ACK")
        while True:
            if self.pi.read(piio.ack_pin) == 1: break
        self.pi.write(self.data_ready_pin,0)            # once we get an ack we clear data set ready as the byte is no longer valid for next op

    def read_byte(self):
        #                                               3322222222221111111111
        #                                               10987654321098765432109876543210
        # read to receieve, un acknowledged send
        debug = False
        if debug: print "In read byte"
        self.set_port_read()               # Force into read mode
        self.pi.write(piio.ack_pin,0)          # clear ack so it doesn't think we are reading
        if debug: print "Ack cleared"
        self.pi.write(piio.clear_to_send_pin,1)# also clear the CTS to it doesn't think the line is ready
        if debug: print "Clear to send set"
        while True:                            # wait for data to be ready
            if self.pi.read(self.data_ready_pin) == True: break
        # now read the bank
        if debug: print "Data is ready to read"
        my_data = self.pi.read_bank_1()        # we want pins 11 to 4 for data
        # acknowlege the data and clear CTS to block futher transmissions until ready
        self.pi.write(self.clear_to_send_pin,0)# no longer clear to send any more data as we are processing
        self.pi.write(self.ack_pin,1)          # acknowledge the byte so sender knows its been read
        # now we have data process bits to correct order
        if debug: print ("data bank 1 " , my_data)
        my_data &= 0xFF0
        if debug: print ("my data bits ", my_data)
        my_data = my_data >> 4 
        if debug: print ("my data shifted ", my_data)
        my_byte = ((my_data & 0x0f) << 4) + ((my_data & 0xF0 ) >> 4)
        if debug: print ("my byte" , my_byte)
        return my_byte

    def write_string(self,mystring):
        print ("In write string", mystring, len(mystring))
        for i in mystring:
            self.write_byte(ord(i))

    def write_16bit(self,myword):
        self.write_byte (myword & 0xFF)
        self.write_byte ((myword & 0xFF00) >> 8)

    def write_24bit(self,myword):
        self.write_byte (myword & 0xFF)
        self.write_byte ((myword & 0xFF00) >> 8)
        self.write_byte ((myword & 0xFF0000) >> 16)

    # writes out a 2's compliment byte based on an incomming signed value
    def write_byte_signed(self,byte):
        if byte < 0:
            self.write_byte(256 - byte)
        else:
            self.write_byte(byte)

    def write_8dot8_abs(self,mydecimal):
        self.write16bit(int(abs(mydecimal * 256.0)))

    def write_16dot8_abs(self,mydecimal):
        self.write24bit(int(abs(mydecimal * 256.0)))

    def write_8dot8_2c(self,mydecimal):
        if mydecimal < 0:
            self.write16bit(65536 - max(abs(mydecimal*256.0),32767))
        else:
            self.write16bit(max(abs(mydecimal*256.0),32767))

    def write_16dot8_2c(self,mydecimal):
        if mydecimal < 0:
            self.write24bit(1677216 - max(abs(mydecimal*256.0),8388607))
        else:
            self.write24bit(max(abs(mydecimal*256.0),8388607))

    def write_8dot8_leadsign(self,mydecimal):
        if mydecimal < 0:
            self.write16bit(32768 + max(abs(mydecimal*256.0),32767))
        else:
            self.write16bit(max(abs(mydecimal*256.0),32767))

    def write_16dot8_leadsign(Self,mydecimal):
        if mydecimal < 0:
            self.write24bit(8388608 + max(abs(mydecimal*256.0),8388607))
        else:
            self.write24bit(max(abs(mydecimal*256.0),8388607))

    def read_16bit(self):
        return self.read_byte() >> 8 + self.read_byte()

    def read_byte_signed(self):
        value = self.read_byte()
        if value > 127:
            value = 256-value
        return value
 
    def read_8dot8_abs(self):
        return (self.read_byte() / 265.0) + self.read_byte

    def read_16dot8_abs(Self):
        return (self.read_byte() / 256.0) + self.read_byte + (self.read_byte * 256.0)

    def read_8dot8_2c(self):
        signed_val = self.read_byte() + (self.read_byte() << 8) 
        if signed_val >= 32768:
            signed_val = (65536 - signed_val) * -1
        return signed_val / 256.0
         
    def read_16dot8_2c(Self):
        signed_val = self.read_byte() + (self.read_byte() << 8) + (self.read_byte() << 16) 
        if signed_val >= 8388607:
            signed_val = (1677216 -signed_val) * -1
        return signed_val / 256.0
       
    def read_8dot8_leadsign(self):
        signed_low = self.read_byte()
        signed_hi  = self.read_byte()
        if self.debugmode: print ("read 8.8 lead sign > ",signed_hi, signed_low,)
        if signed_hi < 128:
            if self.debugmode: print ("positive > ",((signed_hi << 8) + signed_low) /256.0)
            return (signed_low + (signed_hi << 8))  / 256.0
        else:
            if self.debugmode: print ("negative > ",(((signed_hi-128) << 8) + signed_low) /256.0)
            return (signed_low + ((signed_hi-128) << 8) / 256.0) * -1

    def read_16dot8_leadsign(Self):
        signed_val = self.read_byte() + (self.read_byte() << 8) + (self.read_byte() << 16) 
        if signed_val >= 8388607:
            signed_val = (signed_val -8388607) * -1
        return signed_val / 256.0

    def write_compass(self,location):
        #print (@In write compass position)
        # now stream out all 3 components of compass as 8 bit bytes
        # by design it can never be greater than 16

        for x in np.nditer(location, flags=['external_loop'], order ='C'):
            self.write_byte_signed(int(floor(x)))

    def write_scanner(self,location):
        for x in np.nditer(location, flags=['external_loop'], order ='C'):
            self.write_byte_signed(int(floor(x)))
    
    def write_univ_body_position(self,location):
        for x in np.nditer(location, flags=['external_loop'], order ='C'):
            self.write_16dot8_leadsign(x)

    def write_univ_position(self,location):
        for x in np.nditer(location, flags=['external_loop'], order ='C'):
            self.write_8dot8_leadsign(x)

    def read_univ_position(self):
        print ("In read univ position")
        location = np.empty([3])
        location[0] = self.read_8dot8_leadsign()
        location[1] = self.read_8dot8_leadsign()
        location[2] = self.read_8dot8_leadsign()
        print ("out read univ position")
        return location

    def write_line_list(self,listsize,linelist):
        self.write_byte(listsize)
        for i in range(0,max(listsize,255)):
            for x in np.nditer(linelist[i], flags=['external_loop'], order ='C'):
                self.write_byte(x[0])
                self.write_byte(x[1])
                self.write_byte(x[2])
                self.write_byte(x[3])

    def write_matrix(self,matrix):
        for i in np.nditer(matrix, flags=['external_loop'], order ='C'):
            self.write_8dot8(i)

    def read_matrix(self):
        rotmat = np.empty([3,3])
        for i in range (0,3):
            for j in range (0,3):
                rotmat[i,j] = self.read_8dot8_leadsign()
        return rotmat
