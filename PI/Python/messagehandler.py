import piio
import localbubble as lb
class MessageHandler:
    local = lb.LocalBubble()
    pi = piio.piio()

    def read_mode(self):
			  self.pi.set_port_read()

    def wait_for_command(self):
        self.pi.set_port_read()
        return self.pi.read_byte()

    def desyncReset(Self):
        self.pi.desyncReset()
# TODO CHECK ALL list extracts return ship number as part of data
    def processMsg(self,command):
        if command < 1: return
        if command == 0x01:                     #  0x01 Tested.OK..Hello returns olleH 
            self.write_hello_reply()
            return
        elif command == 0x02:                   #  0x02 Tested OK  ping, returns 1
            self.write_ping_code()
        elif command == 0x12:                   #  0x12 Tested OK  SelectViewPort
            self.select_view_port()
        elif command == 0x15:                   #  0x15 To Test    Request Render data
            self.get_line_list()
        elif command == 0x16:                   #  0x16 Input......Request Explode Cloud data, returns render position as xy & ship size, leaves drawing to main game engine
            self.get_explode_list()
        elif command == 0x1A:                   #  0x1A To Test    Request Compass Position Data, nbr of ships, ship data (bits 0-3 array nbr 4 to 7 line color), x, y, stick length, star, sun,planet (as per ship data but no array number)
            self.get_compass_list()
        elif command == 0x1B:                   #  0x1B To Test    Request Compass Position (ship nbr, if bit 7 set then 1 = sun 2 = planet 3 = station) > 4x8 bit values for color, x,y,stick length (signed)
            self.get_compass_ship()             
        elif command == 0x1C:                   #  0x1C To Test    Request all 3d Position Data > next byte is number of ships, followed by 3x24 bit for sun, 3x24 bit for planet, 3x24 bit for space station, nbr ships x 1x8 bit ship index, 3x16 bit for ships
            self.get_all_positions()            
        elif command == 0x1D:                   #  0x1D To Test    Request ship n Position Data (ship nbr, if bit 7 set then 1 = sun 2 = planet 3 = station) >  followed by 3x24 bit for sun, 3x24 bit for planet, 3x24 bit for space station, nbr ships x 3x16 bit for ships
            self.get_position()                 
        elif command == 0x1E:                   #  0x1E To Test    Request Matrix data (ships + space station)
            self.get_matrix_data ()             
        elif command == 0x1F:                   #  0x1F To Test    Request Ship matrix (ship nbr, if bit 7 set then 1 = sun 2 = planet 3 = station) 
            self.get_ship_matrix_data()         
        elif command == 0x20:                   #  0x20 To Test    Firing > next byte is ship id that would be hit by laser in low byte, bit 7 is 0 for front 1 for rear, FF means no hit
            self.player_firing(self)            
        elif command == 0x21:                   #  0x21 Input      List of lasers hitting player and direction, first byte count follwoed by ship id and facing as per 0x20
            self.check_player_shot()            
        elif command == 0x22:                   #  0x22 Input      Missile Hit Check, loops through all missiles in flight: first byte is missile id (low nibble), high nibble nbr of ships hit, list of ships his and distance from missile, if ship id is hit bit 7 then direect hit and no distance byte
            self.check_missiles()
        elif command == 0x23:                   #  0x23 To Test    Fire ECM, byte = duration
            self.fire_ecm()                     
        elif command == 0x30:                   #  0x30 To Test    Add Ship    > next bytes are Type, position, rotation, state (what here) also used for launch missile, flags as bit mask for overides 7=Angry,6 = scared, 5 = hunter, 4 trader, 3 = courier, 2 = bezerk, 1 = has cloak,, 0=has_ecm
            self.addUnivObject()                
        elif command == 0x31:                   #  0x31 To Test    Ship Dead   > next byte is ship number
            self.killUnivObject()
        elif command == 0x32:                   #  0x32 To Test    Remove Ship > next byte is ship number
            self.removeUnivObject()
        #elif command == 0x40:                   #  0x40 Input      Request ship nbrs in range X of position , 3x8 bit for position, 1x8bit for range
        elif command == 0x66:                   #  0x66 To Test    Shutdown
            self.shutdown()                      
        elif command == 0x67:                   #  0x67 To Test    Restart Universe
            self.restart_univ()                  
        elif command == 0x68:                   #  0x68 Input      Performed Jump
            self.performed_jump()                
        elif command == 0x69:                   #  0x69 Input      Undock Player 
            self.undock_player()                 
        elif command == 0x6A:                   #  0x6A Input      Undock Player Seeded
            self.undock_player_seeded()         
        elif command == 0x70:                   #  0x70 Input      Player input
            self.player_input()                      
        elif command == 0x71:                   #  0x71 Input      Update Universe
            self.update_univ()                  
        elif command == 0x72:
            self.update_univ_ticks()            #  0x72 Input      Update Universe n ticks
                                                #  0x73 Input      Update tactics all
                                                #  0x74 Input      Update tactics ship n (bit 7 means space station)
                                                #  0x75 Input      get all status data 2 byte bit masks - In Use,flag_dead, flag_remove,  so up to 16 objects
                                                #  0x76 Input      get ship n status data (bit 7 means space station)
        elif command == 0x80:
            self.get_scanner_list()             #  0x80 Input      get all scanner data
                                                #  0x81 Input      get all scanner data > object id, bit 7 shifs to bodies < returns 3x1 byte, x1,y1,y2, blob is draw at y2
                                                #  0x90 Input      set object status > object nbr
                                                #  0xA0 Input      set all mode 1 = all objects regarless of if they exist, 0 = only ones where object used = true
        elif command == 0xF0:
            self.dump_string()                  #  0xF0 Input      Dump data for n as string to screen
        elif command == 0xF1:
            self.dump_byte()                    #  0xF1 Input      Dump data for n bytes as unsigned byte
        elif command == 0xF2:
            self.dump_byte_2c()                 #  0xF2 Input      Dump data for n bytes as 2's c signed byte
        elif command == 0xF3:
            self.dump_byte_sgn()                #  0xF3 Input      Dump data for n bytes as S7 signed byte
        elif command == 0xF4:
            self.dump_word()                    #  0xF4 Input      Dump data for n bytes as unsigned word
        elif command == 0xF5:
            self.dump_word_2c()                 #  0xF5 Input      Dump data for n bytes as unsigned word
        elif command == 0xF6:
            self.dump_word_sgn()                #  0xF6 Input      Dump data for n bytes as S15 word
        elif command == 0xF7:
            self.dump_8dot8()                   #  0xF7 Input      Dump data for n bytes as S7.8 word
        elif command == 0xF8:
            self.dump_16dot8()                  #  0xF8 Input      Dump data for n bytes as S15.8 24 bit
        elif command == 0xF9:
            self.dump_16dot8_2c()               #  0xF8 Input      Dump data for n bytes as 16.8 2'sc
        elif command == 0xFA:
            self.dump_16dot8_2c()               #  0xF8 Input      Dump data for n bytes as 16.8 lead sign
#---------------------------------------------------------------------------------------------------------------------
# Command Functions
#---------------------------------------------------------------------------------------------------------------------
    #  0x01 Input......Hello
    def write_hello_reply(self):
        self.pi.read_string(
        self.pi.set_port_write()
        self.pi.write_string('olleH')
    #---------------------------------------------------------------------------------------------------------------------
    #  0x02 Input.     ping, returns 1
    #  Tested OK
    def write_ping_code(self):
        self.pi.set_port_write()
        self.pi.write_byte(1)
    #---------------------------------------------------------------------------------------------------------------------
    #  0x12 Input      SelectViewPort (0 = front, 1 = rear, 2 = left, 3 = right)
    #  Tested OK
    def select_view_port(self):
        self.local.set_viewport(self.pi.read_byte())
        print ("view port ",self.local.player_viewport, " processed")
    #---------------------------------------------------------------------------------------------------------------------
    #  0x15 Input      Drawing Ships
    #  to test
    def get_line_list(self):
        self.pi.write_mode()
        self.local.generate_line_list()
        self.pi.write_line_list(self.local.renderer.linelistsize, self.local.renderer.linelist)
    #---------------------------------------------------------------------------------------------------------------------
    #  0x16 Input      Request Explode Cloud data > next byte is number of clouds, batches of x1,y2,size,age
    def get_explode_list(self):
        self.pi.write_mode()
        self.pi.write_cloud_list(self.local.get_explode_list())
    #---------------------------------------------------------------------------------------------------------------------
    #  0x1A Input      Request Compass Position Data > next byte number of followed by batches of 4x3 byte ship nbr, x, y (relative to center of compass)
    def get_compass_list(self):
        self.pi.write_mode()
        self.pi.write_byte(np.count_nonzero(self.local.ul.objectUsage == True))
        it =  np.nditer(self.local.ul.ojectUsage, flags=['c_index'], order ='C')
        for x in it:            # write out each object that has been found with its index to compact data
            if x:
               self.pi.write_byte( it.index + self.local.ul.objectList[it.index].compass_colour) # merged index and color to save 1 byte
               self.pi.write_compass(self.local.ul.objectList[it.index].compass)
        # we don't need to do color - main game handles this elf.pi.write_byte((self.local.star.compass_colour >> 4))   # for consistency we will still store colour in upper 4 bits for bodies as per ships
        self.pi.write_compass(self.local.star.compass)
        self.pi.write_compass(self.local.planet.compass)
        self.pi.write_compass(self.local.station.compass)
    #---------------------------------------------------------------------------------------------------------------------
    #  0x1B Input      Request Compass Position (ship nbr, if bit 7 set then 1 = sun 2 = planet 3 = station) > 4x8 bit values for color, x,y,stick length (signed)
    def get_compass_ship(self):
        objectid = pi.read_byte()
        self.pi.write_mode()
        if objectid == 129:
             self.pi.write_compass(self.local.star.compass)
        elif objectid == 130:
            self.pi.write_compass(self.local.planet.compass)
        elif objectid == 131:
            self.pi.write_compass(self.local.station.compass)
        else:
            if self.local.ul.objectUsage:
                self.pi.write_compass(self.local.ul.objectList[object_id].compass)
            else
                self.pi.write_byte(255)
                self.pi.write_byte(255)
    #---------------------------------------------------------------------------------------------------------------------
    #  0x1C Input      Request all 3d Position Data > next byte is number of ships, nbr ships x 1X8 bit for array nnbr & 3x16 bit for ships followed by 3x24 bit for sun, 3x24 bit for planet, 3x24 bit for space station, 
    def get_all_positions(self):
        self.pi.write_mode()
        self.pi.write_byte(np.count_nonzero(self.local.ul.objectUsage == True))
        it =  np.nditer(self.local.ul.ojectUsage, flags=['c_index'], order ='C')
        for x in it:
            if x:
                self.pi.write_byte(it.index)
                self.pi.write_univ_position(self.local.ul.objectList[it.index].location)
        self.pi.write_univ_body_position(self.local.star.location)
        self.pi.write_univ_body_position(self.local.planet.location)
        self.pi.write_univ_body_position(self.local.station.location)
    #---------------------------------------------------------------------------------------------------------------------
    #  0x1D Input      Request ship n Position Data (ship nbr, if bit 7 set then 1 = sun 2 = planet 3 = station) >  followed by 3x24 bit for sun, 3x24 bit for planet, 3x24 bit for space station, nbr ships x 3x16 bit for ships
    def get_position(self):
        objectid = pi.read_byte()
        self.pi.write_mode()
        if objectid == 129:
            self.pi.write_univ_body_position(self.local.star.location)
        elif objectid == 130:
            self.pi.write_univ_body_position(self.local.planet.location)
        elif objectid == 131:
            self.pi.write_univ_body_position(self.local.station.location)
        else:
            self.pi.write_univ_position(self.local.ul.objectList[objectid])
    #---------------------------------------------------------------------------------------------------------------------
    #  0x1E Input      Request Matrix data (ships + space station)
    def get_matrix_data(self):
        self.pi.write_mode()
        self.pi.write_byte(np.count_nonzero(self.local.ul.objectUsage == True))
        it =  np.nditer(self.local.ul.ojectUsage, flags=['c_index'], order ='C')
        for x in it:
            if x:
                self.pi.write_byte(it.index)
                self.pi.write_univ_matrix(self.local.ul.ojectList[it.index].rotmat)
        self.pi.write_univ_matrix(self.local.station.rotmat)
        # we will consdier planet if we add surface data
    #---------------------------------------------------------------------------------------------------------------------
    #  0x1F Input      Request Ship matrix (ship nbr, if bit 7 set then 1 = sun 2 = planet 3 = station) 
    def get_ship_matrix_data(self):
        self.pi.write_mode()
        if objectid == 131:
            self.pi.write_univ_matrix(self.local.station.rotmat)
        else:
            if self.local.ul.objectUsage:
                self.pi.write_univ_matrix(self.local.ul.objectList[objectid].rotmat)
            else
                self.pi.write_255_block(9*2)
    #---------------------------------------------------------------------------------------------------------------------
    #  0x20 Input      Firing > next byte is ship id that would be hit by laser in low byte, bit 7 is 0 for front 1 for rear, FF means no hit
    def player_firing(self):
        self.pi.write_mode()
        self.pi.write_byte(self.local.player_firing()) #ship_id_hit also includes facing bit or $FF for no hit
    #---------------------------------------------------------------------------------------------------------------------
    #  0x21 Input      List of lasers hitting player and direction, first byte count follwoed by ship id and facing as per 0x20
    #  0x22 Input      Missile Hit Check, first byte status - 255 no hits/missiles in flight 1 player hit, 2 ships hit, 3 player + ships hit, then  first byte is missile id (low nibble), high nibble nbr of ships hit (F if its player), list of ships his and distance from missile, if ship id is hit bit 7 then direect hit and no distance byte
    def check_missiles():
        it =  np.nditer(self.local.ul.ojectUsage, flags=['c_index'], order ='C')
        hitlist = np.full([self.local.ul.objectList.size,3],255)
        shiplistarray = None
        for x in it:
            if x:
                with ul.objectList[it.index] as missile:
                    if missile.flag_is_missile and not missile.flag_is_dead:
                        hitlist[it.index][0] = it.index
                        if distance < 256: 
                            histlist[it.index][1] = 0 # player hit
                        hitlist[it.index][2] = self.local.missile_hit_check(it.index) # returns 255 or ship id missile hit
                        print ("Add angry logic if we are doing it on pi")
                        #if hitlist[it.index[2] != 255:
                        #   sset target angry(hitlist[it.index][2])
                        #   
                        #f hitlist[it.index][1] & hitlist[it.index][2] <> 255:
                        #   missile detonate (it.index)
                       #
                       #apply damage to target and update status for damaged/destroyed
        if missileidlist or hitlist == None:
            self.pi.write_byte(255)
        else:
            firstbyte = 2
            hitcount = 0
            for i in hitlist:
                if i[1] <> 0: firstbyte=3 
                if i[2] <> 255: hitcount += 1
            self.pi.write_byte(firstbyte)
            self.pi.write_byte(hitcount)
            for i in hitlist:
                if i[0] <> 255 and i[2]<> 255: self.pi.write_byte(i[2])
    #  0x23 Input      Fire ECM, byte = duration
    def fire_ecm(self):
        self.local.fire_ecm(pi.read_byte())
    #  0x30 Input      Add Ship    > next bytes are Type, position, rotation, state (what here) also used for launch missile\
    def addUnivObject(self):
        print("Command addUniverseObject------------------------------------")
        type = self.pi.read_byte()
        print ("Adding Ship Type ",type)
        position = self.pi.read_univ_position() 
        for i in range (0,3):
           print ("P",i,position[i],":",)
        rotation = self.pi.read_matrix()
        for i in range (0,3):
            print("")
            for j in range (0,3):
                print ("Rot ",i,j,rotation[i,j],">",)
        print("")
        rotx     = self.pi.read_byte_signed()
        roty     = self.pi.read_byte_signed()
        rotz     = self.pi.read_byte_signed()
        velocity = self.pi.read_byte()
        accelleration  = self.pi.read_byte_signed()
        flags    = self.pi.read_byte()
        self.local.ul.addObject(type,position,rotation,rotx,roty,rotz,velocity,accelleration,flags)
        print("Leaving addUniverseObject------------------------------------")
    #  0x31 Input      Ship Dead   > next byte is ship number
    def killUnivObject(self):
        shipnbr = self.pi.read_byte()
        self.local.ul.objectList[shipnbr].explode_ship()
    #  0x32 Input      Remove Ship > next byte is ship number
    def removeUnivObject(self):
        shipnbr = self.pi.read_byte()
        self.local.ul.objectList[shipnbr].delUnivObject()
    #  0x32 Input      Remove Ship > next byte is ship number
    #  0x40 Input      Request ship nbrs in range X of position , 3x8 bit for position, 1x8bit for range
    #  0x66 Input      Shutdown
    #  to test
    def shutdown(self):
        self.pi.shutdownPigpio()
    #---------------------------------------------------------------------------------------------------------------------
    #  0x67 Input      Restart Universe
    # to test
    def restart_univ(self):
        self.local.delete_all_ships()
    #---------------------------------------------------------------------------------------------------------------------
    #  0x68 Input      Performed Jump > seeds comming next after ACK for 6 bytes
    #  to test
    def performed_jump(self):
        dataset = pi.read_bytes(6)                  # read system seed
        if dataset == None: return
        self.local.delete_all_ships()
        self.local.jumped_to_system(dataset)
    #---------------------------------------------------------------------------------------------------------------------
    #  0x69 Input      Undock Player 
    def undock_player(self):
        self.local.delete_all_ships()
        self.local.undock_player()
    #---------------------------------------------------------------------------------------------------------------------
    #  0x6A Input      Undock Player Seeded > next 6 bytes are a new sed
    def undock_player_seeded(self):
        dataset = pi.read_bytes(6)                  # read system seed
        if dataset == None: return
        self.local.delete_all_ships()
        self.undock_player()
    #---------------------------------------------------------------------------------------------------------------------
    #  0x70 Input      Player input (rotx, roty, speed, accel)
    #                  flight roll 8.8,
    #                  flight climb 8.8
    #                  flight_speed 8.8
    #                  flight_accel 8.8
    def player_input(self):
        self.local.flight_roll = self.pi.read_8dot8_leadsign()
        self.local.flight_climb = self.pi.read_8dot8_leadsign()
        self.local.flight_speed = self.pi.read_8dot8_leadsign()
        self.local.flight_accell = self.pi.read_8dot8_leadsign()
        print ("Local flight data");
        print ("Local r ",self.local.flight_roll );
        print ("Local c ",self.local.flight_climb );
        print ("Local s ",self.local.flight_speed );
        print ("Local a ",self.local.flight_accell );
        prnt
    #  0x71 Input      Update Universe
    # to test
    def update_univ(self):
        self.local.update_universe()
    #---------------------------------------------------------------------------------------------------------------------
    #  0x72 Input      Update Universe n ticks (byte = number of ticks)
    def update_univ_ticks(self):
        count = self.pi.read_byte()
        for i in range(0,count):
            self.local.update_universe()
#  0x73 Input      Update tactics all
#  0x74 Input      Update tactics ship n (bit 7 means space station)
#  0x75 Input      get all status data
#  0x76 Input      get ship n status data (bit 7 means space station)
#  0x80 Input      get all scanner data < next byte is number of ships, followed by 1 byte ship nbr, 3x1 byte, x1,y1,y2, blob is draw at y2
    def get_scanner_list(self):
        self.pi.write_byte(np.count_nonzero(self.local.ul.objectUsage == True))
        it =  np.nditer(self.local.ul.ojectUsage, flags=['c_index'], order ='C')
        for x in it:
            if x:
               pi.write_byte(it.index)
               pi.write_scanner(self.local.ul.objectList[it.index].scanner)
        self.pi.write_scanner(self.local.star.scanner)
        self.pi.write_scanner(self.local.planet.scanner)
        self.pi.write_scanner(self.local.station.scanner)
    #---------------------------------------------------------------------------------------------------------------------
    #  0x81 Input      get ship scanner data > object id, bit 7 shifs to bodies < returns 3x1 byte, x1,y1,y2, blob is draw at y2
    
    #---------------------------------------------------------------------------------------------------------------------
    # Diagnostics section
    #  0xF0 Input      Dump data for n as string to screen
    def self.dump_string(self):
        datalen = self.pi_read_byte()
        for i in range(0,datalen):
            print(self.pi.read_byte(),' ',)
        print("")
    #  0xF1 Input      Dump data for n bytes as unsigned byte
    def self.dump_byte(self):
        print (self.pi.read_string(self.pi_read_byte())
    #  0xF3 Input      Dump data for n bytes as S7 signed byte
    def self.dump_byte_2c(self):
        datalen = self.pi_read_byte()
        for i in range(0,datalen):
            print(self.pi.read_byte_signed(),' ',)
        print("")
    #  0xF4 Input      Dump data for n bytes as unsigned word
    def self.dump_byte_sgn(self):
        datalen = self.pi_read_byte()
        for i in range(0,datalen):
            print(self.pi.read_byte_s7(),' ',)
        print("")
    #  0xF5 Input      Dump data for n bytes as unsigned word
    def self.dump_word(self):
        datalen = self.pi_read_byte()
        for i in range(0,datalen):
            print(self.pi.read_16bit(),' ',)
        print("")
    def self.dump_word_2c(self):
        datalen = self.pi_read_byte()
        for i in range(0,datalen):
            print(self.pi.read_word_signed(),' ',)
        print("")
    #  0xF6 Input      Dump data for n bytes as S15 word
    def self.dump_word_sgn(self):
        datalen = self.pi_read_byte()
        for i in range(0,datalen):
            print(self.pi.read_word_s15(),' ',)
        print("")
    #  0xF7 Input      Dump data for n bytes as S7.8 word
    def self.dump_8dot8(self):
        datalen = self.pi_read_byte()
        for i in range(0,datalen):
            print(self.pi.read_8dot8_abs(),' ',)
        print("")
    #  0xF8 Input      Dump data for n bytes as S15.8 24 bit
    def self.dump_16dot8(self):
        datalen = self.pi_read_byte()
        for i in range(0,datalen):
            print(self.pi.read_16dot8_abs(),' ',)
        print("")
    #  0xF9 Input      Dump data for n bytes as 16.8 2'sc
    def self.dump_16dot8_2c(self):
        datalen = self.pi_read_byte()
        for i in range(0,datalen):
            print(self.pi.read_16dot8_2c(),' ',)
        print("")
    #  0xFA Input      Dump data for n bytes as 16.8 lead sign
    def self.dump_16dot8_2c(self):
        datalen = self.pi_read_byte()
        for i in range(0,datalen):
            print(self.pi.read_8dot8_leadsign(),' ',)
        print("")        