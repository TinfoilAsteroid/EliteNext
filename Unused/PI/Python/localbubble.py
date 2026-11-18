import numpy as np
import universelist  as ul
import universeobject   as uo
import graphicshandler
import vector
import shipmodels

detonate_energy_bomb = False
ecm_active           = 0
universe_paused      = False

class LocalBubble:

    tactics_counter      = 0
    tactics_tick         = 4
    tactics_current_ship = 0
    ul = ul.UniverseList()
    # treat star, planet and sun as special cases as they will do 24 bit data to spectrum
    star = uo.UniverseObject(0xFF, 0xFF)
    planet = uo.UniverseObject(0xFF, 0xFF)
    station = uo.UniverseObject(0xFF, 0xFF)
    bubble_seed = np.full(6,0)
    flight_climb = 0.0
    flight_roll = 0.0
    flight_speed = 0.0
    flight_accel = 0.0
    techlevel = 0
    economy = 0
    government = 0
    population = 0
    productivity = 0
    radius = 0
    player_viewport = 0
    
    def __init__(self):
        self.star.flag_is_sun = True
        self.star.flag_immune_to_missile
        self.star.flag_no_ai = True
        self.star.flag_can_move = False
        self.star.flag_is_dead = False
        self.star.rotx = 0.0
        self.star.roty = 0.0
        self.star.rotz = 0.0
        self.planet.flag_is_plaanet = True
        self.planet.flag_no_ai = True
        self.planet.flag_immune_to_missile
        self.planet.flag_can_move = False
        self.station.flag_is_station = True
        self.station.flag_no_ai = False
        self.station.flag_immune_to_missile
        self.station.flag_can_move = False
        
    def set_viewport(self,viewport):
        if viewport < 0 or viewport > 4: return
        self.player_viewport = viewport

    def set_bubble_seed(self,seed_data):
        bubble_seed = seed_data.copy();
        self.government = (bubble_seed[2] / 8) & 7
        self.economy = bubble_seed[1] & 7
        if self.government < 2: self.economy = self.economy | 2
        self.techlevel = self.economy ^ 7
        self.techlevel += bubble_seed[4] & 3
        self.techlevel += (self.government / 2) + (self.government & 1)
        self.population = self.techlevel * 4
        self.population += self.government
        self.population += self.economy
        self.population += 1
        self.productivity = (self.economy ^ 7) + 3
        self.productivity *= self.government + 4
        self.productivity *= self.population
        self.productivity *= 8
        
        self.radius = (((planet_seed.f & 15) + 11) * 256) + planet_seed.d;
        
    def delete_all_ships(self):
        self.ul.delAllUnivObject()

    def add_star(self):
        zpos = -(((bubble_seed[1] & 7) | 1) << 16)
        xpos =   ((bubble_seed[5] & 3) << 16) | ((bubble_seed[6] & 3) << 8)
        ypos =  (((bubble_seed[1] & 7) + 7) / 4)<<16
        if bubble_seed[1] & 1 == 0: ypos = -ypos
        self.star.location = np.array([float(xpos),float(ypos),float(zpos)])
        self.star.type = bubble.seed[0] & 7
        self.star.flag_dead = False
        self.star.flag_remove = False

    def add_planet(self):
        zpos =  ((bubble_seed[1] & 7) + 7) / 2
        xpos =  (zpos / 2) <<16
        ypos =  xpos <<16
        zpos =  zpos << 16
        if bubble_seed[1] & 1 == 0: ypos = -ypos
        planet.location = np.array([float(xpos),float(ypos),float(zpos)])
        planet.type = bubble.seed[4] & 7
             
    def add_station(self):
        self.station.location = np.array([planetPos[0] + ((rand() & 32767) - 16384), planetPos[1] + ((rand() & 32767) - 16384), planetPos[2] + ((rand() & 32767) - 16384)])
        self.station.rotmat = vector.tidy_matrix(np.array([1.0,0,0,0,0],[self.station.location[0],self.station.location[1],self.station.location[2]],[self.station.location[0],self.station.location[1],self.station.location[2]]))
        self.station.type = SHIP_DODEC if local.techlevel >= 10 else SHIP_CORIOLIS

    def jumped_to_system(self,seedset):
        self.set_bubble_seed(seedset)
        self.add_star()
        self.add_planet()
        self.add_station()
        
    def undock_player(self):
        #geernate station position
        self.station.locaion = np.array([0.0,0.0,-256.0])
        self.station.rotmat = vector.tidy_matrix(np.array([1.0,0,0,0,0],[self.station.location[0],self.station.location[1],self.station.location[2]],[-self.station.location[0],-self.station.location[1],-self.station.location[2]]))
        self.station.type = SHIP_DODEC if local.techlevel >= 10 else SHIP_CORIOLIS
        #enerate sun & planet in reverse based on station i.e. subtract positoin
        self.add_star()
        self.star.location -= self.station.location
        self.add_planet()
        self.star.planet -= self.station.location

    def fire_ecm(duration):
        if ecm_active < duration: ecm_active = duration

    def reset_bubble():
        self.delete_all_ships()
        self.add_star()
        self.add_planet()
        self.add_stations
        
    def generate_line_list(self):
        renderer.generate_line_list(ul)

    def update_universe(self):
        if universe_paused: return
        if ecm_active > 0: ecm_active -= 1              # age ecm
        # move all objects
        # check for explosions, energy bomb death etc and update object if still present
        it = np.nditer(self.ul.objectList, flags=['c_index'])
        for x in it:
            # if slot has an active object
            if self.ul.objectUsage[it.index]:
                # if its flagged as ready for expiry
                if x.flag_remove:
                    if x.flag_authority_vessel:
                        Player_Status.legal_status |= 64
                    bounty = ship_models.shipMasterList[j.type].bounty
                    if bounty != 0:
                        PlayerStatus.credits += bounty
                        # signal aded credits
                    self.ul.delUnivObject(it.index)
                else:
                    # now check if energy bomb was fired, affects all non resitant objects
                    if detonate_energy_bomb and not x.flag_dead and not x.flag_energy_bomb_resistant:
                        self.ul.objectList[it.index].explode_ship()
                    else:
                        with self.ul.objectList[it.index] as univ_obj: # now we need it read write
                            if univ_obj.flag_remove:
                                self.ul.delUnivObject(it.index)
                            else:
                                if ecm_active > 0 and not flag_immune_to_ecm:
                                    univ_obj.explode_ship()
                                else:
                                    univ_obj.update_univ_object(flight_roll,flight_climb,flight_speed)
                                    if univ_obj.is_planet:
                                        if univ_obj.distance < 657992: LocalBubble.make_station_appear()
                                    else:
                                        if univ_obj.distance < 170:
                                            if univ_obj.flag_is_station:
                                                PlayerStatus.check_docking(i)
                                            else:
                                                scoop_item(i)
                                        elif univ_objj.distance > 57344:
                                            self.ul.delUnivObject(it.index)
        # update ai tick counter and then refresh tactics for selected craft
        if LocalBubble.tactics_counter <> LocalBubble.tactics_tick:
            LocalBubble.tactics_counter += 1
        else:
            LocalBubble.tactics_counter = 0
            # always iterate through objects, if its not present then just ignore that cycle
            if self.ul.objectUsage[LocalBubble.tactics_current_ship]:
                # the actual object determines if it has AI attached etc
                self.ul.objectList[LocalBubble.tactics_current_ship].tactics()
                LocalBubble.tactics_counter += 1
                if LocalBubble.tactics_current_ship >= self.ul.objectUsage.size(self):
                    LocalBubble.tactics_current_ship = 0

    #def get_explode_list(self):
    def player_firing(self):    # returns 255 if no hit found
        # z index determines which is the axis along the facing ,.e.g front to back is z
        # then we determine what is behind or infront, done by muitiplying the z index by +1 for forwards or -1 to flip it over
        # then its a simple is the result >= 0 for check
        distance = 99999
        current_ship =255
        if self.player_viewport == 0 or self.player_viewport == 1:  # front and read check x & y
            index1 = 0
            index2 = 1
            zindex = 2
            zmultiplier = 1 if self.player_viewport == 0 else -1
        else:                               # sides check y and z
            index1 = 1
            index2 = 2
            zindex = 0
            zmultiplier = -1 if self.player_viewport == 2 else 1
        ul = ul.UniverseList()
        for i in range(0,ul.objectList.size):
            if ul.objectUsage[i]:
                with ul.objectList[i] as ship:
                    if not ship.flag_dead:
                        if (ship.location[zindex] * zmultiplier >= 0) and ((ship.location[0]**2 + ship.location[1]**2) <= ship.size) and ship.distance < distance:
                            current_ship = i            # we hit the closest one 
                            distance = ship.distance
        return current_ship

   
    #def update_tactics_all(self):
    #def update_tactics(self):
    
