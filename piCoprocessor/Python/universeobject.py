import math
import numpy            as np
import vector
from shipmodel import ShipModel as model
import shipmodels
import localbubble
import universelist  as ul

class UniverseObject:
    type = 0
    size = 0
    universe_index = 0
    missile_detonate_range = 0
    location = np.array([0.0,0.0,0.0])
    compass = np.array([0.0,0.0,0.0])
    compass_colour = 7 << 4         # defaults to 7, white but in upper 4 bits to speed up pi transfer, for bodies it will be lower buts on transmit
    scanner = np.array([0.0,0.0,0.0]) # note scanner holds x1,y1, y2 where y2 is the height, position are relative not screeen
    rotmat = vector.ident.copy()
    rotx = 0.0
    roty = 0.0
    rotz = 0.0
    flag_dead = False              # destroyed so no ai
    flag_is_exploding = False
    flag_is_missile = False
    flag_remove = False      # remove on next universe update
    flag_authority_vessel = False  # is a local authroity vessel
    flag_is_station = False        # is it a space station
    flag_is_planet = False         # is it a space planet
    flag_is_sun = False            # is it a space Sun
    flag_can_move = True
    flag_is_scoopable = False      # can it be scopped
    # AI values
    bravery = 0
    flag_is_seeker = False         # is it a direct seeker, e.g. a missile (used for AI)
    flag_is_angry = False          # is it angry at plater
    flag_is_scared = False         # is it scared of player
    flag_is_firing = False         # is it firing laser
    flag_no_ai = False             # is it just a dormant object, e.g. alloy plate, sun or planet
    flag_is_trader = False         # just flying between systems
    # Equipment flags
    flag_has_ecm = False           # does it have ECM unit that works
    flag_immune_to_missile = False
    flag_immune_to_ecm = True
    flag_is_targoid = False        # Thargods have differen tactics (has potential here for targoid piloting regular ship, e.g inflitrator)
    flag_is_trader = False         # just going from sun to station or visa verse
    flag_is_courier = False        # just transporter, so will avoid combat
    flag_is_berzerk = False        # will try and ram player
    flag_do_draw = True            # destroyed and cloaked ships dont draw
    credits = 0
    legal_staus = 0
    energy = 0
    velocity = 0
    max_velocity = 0
    acceleration = 0
    missiles = 0                   # Nbr of missiles left
    target = 255                   # 255, no target, 254 player
    exp_delta = 0
    exp_seed = 0
    distance = 0
    radius = 1
    explosion_size = 0              # detonation explosion
    explosion_life = 0              
    flag_energy_bomb_resistant = False
    laser_strength = 0
    
            
    def copy_model_data(self):
        model = shipmodels.shipMasterList[self.type]
        self.size = model.size
        self.max_velocity = model.velocity
        self.missiles = model.missiles
        self.laser_strength = model.laser_strength
        self.flag_is_scoopable = model.is_scoopable
        self.flag_energy_bomb_resistant = model.is_bomb_proof
        self.flag_is_station = model.is_space_station
        self.flag_is_missile = model.is_missile
        self.missile_detonate_range = 0 if not self.flag_is_missile else 255 # for now only 1 type
        self.immune_to_ecm = model.immune_to_ecm
        # need to add things like laser type etc 

    def __init__(self, index, type):
        self.default_values()
        self.set_ship(index,type)
        if type != 255: self.copy_model_data()

    def explode_ship(self):
        self.flag_dead = True
        self.flag_is_exploding = True
        self.flag_no_ai = True
        self.explosion_size = self.size / 2 # expands from /2 size for now
        self.explosion_life = 90            # nbr of game loop iterations it expands for

    def default_values(self):
        self.location = np.array([0.0,0.0,0.0])
        self.compass = np.array([0.0,0.0,0.0])
        self.scanner = np.array([0.0,0.0,0.0]) # note scanner holds x1,y1, y2 where y2 is the height, position are relative not screeen
        self.rotmat = vector.ident.copy()
        self.rotx = 0.0
        self.roty = 0.0
        self.rotz = 0.0
        self.flag_dead = False              # destroyed so no ai
        self.flag_remove = False      # remove on next universe update
        self.flag_authority_vessel = False  # is a local authroity vessel
        self.flag_is_station = False        # is it a space station
        self.flag_is_planet = False         # is it a space planet
        self.flag_is_sun = False            # is it a space Sun
        self.flag_can_move = True
        self.flag_is_scoopable = False      # can it be scopped
        self.flag_is_seeker = False         # is it a direct seeker, e.g. a missile (used for AI)
        self.flag_is_angry = False          # is it angry at plater
        self.flag_is_scared = False         # is it scared of player
        self.flag_is_hunter = False
        self.flag_is_firing = False         # is it firing laser
        self.flag_no_ai = False             # is it just a dormant object, e.g. alloy plate, sun or planet
        self.flag_immune_to_missile = False
        self.flag_is_targoid = False        # Thargods have differen tactics (has potential here for targoid piloting regular ship, e.g inflitrator)
        self.flag_is_trader = False         # just going from sun to station or visa verse
        self.flag_is_courier = False        # just transporter, so will avoid combat
        self.flag_is_berzerk = False        # will try and ram player
        self.flag_has_cloak = False
        self.flag_has_ecm = False           # does it have ECM unit that works
        self.flag_do_draw = True            # destroyed and cloaked ships dont draw
        self.credits = 0
        self.legal_staus = 0
        self.energy = 0
        self.velocity = 0
        self.acceleration = 0
        self.missiles = 0                   # Nbr of missiles left
        self.target = 255                   # 255, no target, 254 player
        self.bravery = 0
        self.exp_delta = 0
        self.exp_seed = 0
        self.distance = 0
        self.radius = 1
        self.flag_energy_bomb_resistant = False
            
            # tehre will be more logic to this laters
    def set_ship(self,index,type):
        self.type = type
        self.universe_index = index # reverse pointer to universe object list
        self.default_values()
        if type != 255: self.copy_model_data()
    
    def set_position_data(self,location,rotation,rotx,roty,rotz,velocity,accelleration):
        self.location = location.copy()
        self.rotmat   = rotation.copy()
        self.rotx     = rotx
        self.roty     = roty
        self.rotz     = rotz
        self.velocity = velocity
        self.accelleration =  accelleration
        
    def set_space_station(self,index,type):
        self.set_ship(index.type)
        # palace hodler for now
    
    def set_planet(self,index,type):
        self.set_ship(index.type)
        # palace hodler for now
    
    #def set_stun(self,
    
    def is_docking():
        if ps.auto_pilot: return False
        if self.rotmat[2][2] > -0.90: return True
        vec = vector.unit_vector(self.location)            
        if vec.z < 0.927: return True
        
        if abs(self.rotmat[1][0]) < 0.84: return True
        return False

    def check_target(self):
        if in_target():
            if PlayerStatus.missile_target == MISSILE_ARMED and self.type >= 0:
                PlayerStatus.missile_target = self.index
                #info_message ("Target Locked");
                # do we make angry when player gets tone lock or wait until launch
                # perhaps random make ship panic/evade
            if PlayerStatus.laser_firing(PlayerStatus.current_facing):
                if not self.flag_is_station:
                    if self.type ==SHIP_CONSTRICTOR or self.type == SHIP_COUGAR:
                        if PlayerStatus.laser_type(PlayerStatus.current_facing) == MILITARY_LASER: self.energy -= PlayerStatus.laser_drain(PlayerStatus.current_facing) # needs to be laser damage var
                    else:
                        self.energy -= PlayerStatus.laser_drain(PlayerStatus.current_facing)
                self.make_angry()
            if self.energy <= 0:
                self.explode_object()
                if self.type == SHIP_ASTEROID:
                    if PlayerStatus.laser_type(PlayerStatus.current_facing)== MINING_LASER: self.launch_loot(SHIP_ROCK)
                else:
                    self.launch_loot(SHIP_ALLOY)
                    self.launch_loot(SHIP_CARGO)

    def update_univ_object (self,flight_roll, flight_climb, flight_speed):
        alpha = flight_roll / 256.0                            
        beta = flight_climb / 256.0
        #print (modelList.shipMasterList[self.type].is_space_station,alpha,beta)
        pos = self.location.copy()                          # Pos is working location
        # non dead ships can change speed
        if not self.flag_dead:
            if self.velocity <> 0:
                speed = self.velocity * 1.5
                pos[0] += rotmat[2][0]* speed
                pos[1] += rotmat[2][1]* speed
                pos[2] += rotmat[2][2]* speed
                #pos += (rotmat[2] * speed)
            if self.acceleration <> 0:
                self.velocity += self.acceleration
                self.acceleration = 0
                self.velocity = min(self.velocity, shipmodels.shipMasterList[self.type].velocity)
                if self.velocity <= 0: self.velocity = 1
        else:
            if self.explosion_life >0:
                self.explosion_size += 1
                self.explosion_life -= 1
            else:
                self.flag_remove = True
        # if player is rolling or climbing then update via minsky
        if alpha <> 0 or beta <> 0:
            k2 = pos[1] - (alpha * pos[0])
            pos[2] += beta * k2
            pos[1] = k2 - (pos[2] * beta)
            pos[0] += alpha * pos[1]
        # Speed will always be non zero 
        pos[2] -= flight_speed
        # update location
        self.location = pos.copy()
        # apply 
        self.rotmat = vector.rotate_matrix(self.rotmat,alpha,beta)
        
        #update distance pre-calc
        self.distance = math.sqrt(pos[0]**2 + pos[0]**2 + pos[0]**2)
        # end early if ship is dead
        if self.flag_dead: return

        rotx = self.rotx;
        rotz = self.rotz;
        # apply univ obj rotation
        if rotx <> 0:
            self.rotmat[2][0], self.rotmat[1][0]= vector.rotate_x_first (self.rotmat[2][0], self.rotmat[1][0], rotx)
            self.rotmat[2][1], self.rotmat[1][1]= vector.rotate_x_first (self.rotmat[2][1], self.rotmat[1][1], rotx)
            self.rotmat[2][2], self.rotmat[1][2]= vector.rotate_x_first (self.rotmat[2][2], self.rotmat[1][2], rotx)
            if rotx <> 127.0 and rotx <> -127.0:
                self.rotx -= -1.0 if rotx < 0.0 else 1.0
        
        if rotz <> 0:
            rotmat[0][0], rotmat[1][0]= vector.rotate_x_first (rotmat[0][0], rotmat[1][0], rotz)
            rotmat[0][1], rotmat[1][1]= vector.rotate_x_first (rotmat[0][1], rotmat[1][1], rotz)
            rotmat[0][2], rotmat[1][2]= vector.rotate_x_first (rotmat[0][2], rotmat[1][2], rotx)
            if rotz <> 127.0 and rotz <> -127.0:
                self.rotz -= -1.0 if rotz < 0.0 else 1.0
        self.rotmat = vector.tidy_matrix (self.rotmat)
        # update compass as its a unit vector max value can be +/- 16
        self.compass = unit_vector(self.location)
        self.compass[0] *= 16.0
        self.compass[1] *= -16.0
        # update scanner
        self.scanner = self.location/256.0
        self.scanner[2] = (self.scanner[2] /4 ) - (self.scanner[1] / 2)
        # clamp values, whilst height can be way off from this, game rendering will handle that
        with np.nditer(self.scanner, op_flags=['readwrite']) as it:
            for x in it:
                if x < -120.0: 
                    x[...] = -120.0
                elif x > 120.0:
                    x[...] = 120.0
    #ef track_object(direction, vector)

    def missile_tactics(self):
        if localbubble.ecm_active > 0 or self.target == 255:
            self.explode_object()
            return
        if self.target == 254:
            if self.distance < 256:
                self.explode_object()
                ps.damage_ship(250, self.location[2] >= 0.0) # we will have a damage look up table later + poss enveloping plasma that hits all shields
                return
            workingvec = self.location.copy()
        else:
            if ul.objectUsage[self.target]:
                with ul.objectList[self.target] as target:
                    workingvec = self.location - target.location
                    if abs(workingvec[0]) < 256 and abs(workingvec[1]) < 256 and abs(workingvec[2]) < 256:
                        self.explode_object()
                        if not self.flag_is_station and not self.flag_is_planet and not self.flag_is_sun:
                            target.damage_object(250)
                            return
        nvec = vector.unit_vector(working_vec)
        direction = vector.vector_dot_product(nvec, self.rotmat[2])
        nvec = -nvec
        direction = -direction
        self.track_object(direction,nvec)
        if direction <= -0.167:
            self.acceleration = -2
            return
        if direction >= 0.223 or self.velocity < 6:
            self.acceleration = 3
            return
        if random.rand(255) >= 200: self.acceleration = -2
        
        

    def tactics (self):
        if self.flag_no_ai or self.flag_dead: return
        if self.flag_is_missile:
           missile_tactics()
           return
        
        #if self.flag_is_seeker: self.missile_tactics()
        #elseif self.flag_is_angry:
        #elseif self.flag
