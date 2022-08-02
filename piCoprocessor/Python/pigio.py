import pigpio

class piio:
    pi = 0
    start_pin = 4
    data_ready_pin = 24
    clear_to_send_pin = 25
    debugmode = True
    def __init__(self):
        self.pi = pigpio.pi()
        pi.set_mode(data_ready_pin, pigpio.OUTPUT)
        pi.set_mode(clear_to_send_pin, pigpio.INPUT)
        set_port_read()
        
    def set_port_mode(self,io_mode):
        count = 0
        pin_nbr = start_pint
        while count < 8:
            self.pi.set_mode(pin_nbr, io_mode)
            count += 1
            pin_nbr += 1
        
    def set_data_ready(self):
        self.pi.write(self.data_ready_pin,1)
    
    def set_data_not_ready(self):
        self.pi.write(self.data_ready_pin,0)
        
    def is_clear_to_send(self):
        if (self.pi.read(self.clear_to_send_pin) == 1)
            return False
        else
            return True
            
    def is_data_ready_to_read(self):
        if (self.pi.read(self.clear_to_send_pin) == 0)
            return false
        else
            return true
            
    def wait_for_clear_to_send(self):
        if (is_clear_to_send(self) != True):
            self.pi.wait_for_edge(clear_to_send_pin,pigpio.RISING_EDGE)    

    def wait_for_data_to_read(self):
        if (is_data_ready_to_read(self) != True):
            self.pi.wait_for_edge(clear_to_send_pin,pigpio.FALLING_EDGE)    

    def ack_data(self):
        set_data_ready(self)
    
    def set_port_write(self):
        self.set_port_mode(self,pigpio.OUTPUT)
    
    def set_port_read(self):
        self.set_port_mode(self,pigpio.INPUT)
        
    def write_value(self,value):
        pinindex = self.start_pin
        bitmask = 128
        set_data_not_ready(self)
        wait_for_clear_to_send(self)
        while bitmask > 0:
            if (value & bitmask != 0):
                self.pi.write(pinindex,1)
            else:
                self.pi.write(pinindex,0)
            pinindex += 1
            bitmask >> 1
        set_data_ready(self)
        if (self.debug_mode == True):
            print('Written ', value)
        
    def read_value(self):
        pinindex = self.start_pin
        count  = 8
        value = 0
        bitmask = 128
        set_data_not_ready(self)
        wait_for_data_to_read()
        while value > 0:
            if (value & bitmask != 0):
                value += 1
            pinindex += 1
            value    << 1
            count    += 1
        set_data_ready(self)
        if (self.debug_mode == True):
            print('Read ', value)
        return value

       