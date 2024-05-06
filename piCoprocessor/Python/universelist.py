import math
import numpy            as np
import vector
import universeobject as uo
from graphicshandler import GraphicsHandler  as gh
# global constants for ship types
# missing ships:bushmaster, chameleon, dragon, ghavial, iguana, monitor, ophidian,rattler, shutte (type 9 or mk2?), splinter, 
# note lone = pirate?
# 
SHIP_SUN            = -2
SHIP_PLANET         = -1
SHIP_MISSILE        = 1
SHIP_CORIOLIS       = 2
SHIP_ESCAPE_CAPSULE = 3
SHIP_ALLOY          = 4
SHIP_CARGO          = 5
SHIP_BOULDER        = 6
SHIP_ASTEROID       = 7
SHIP_ROCK           = 8
SHIP_SHUTTLE        = 9
SHIP_TRANSPORTER    = 10
SHIP_COBRA3         = 11
SHIP_PYTHON         = 12
SHIP_BOA            = 13
SHIP_ANACONDA       = 14
SHIP_HERMIT         = 15
SHIP_VIPER          = 16
SHIP_SIDEWINDER     = 17
SHIP_MAMBA          = 18
SHIP_KRAIT          = 19
SHIP_ADDER          = 20
SHIP_GECKO          = 21
SHIP_COBRA1         = 22
SHIP_WORM           = 23
SHIP_COBRA3_LONE    = 24
SHIP_ASP2           = 25
SHIP_PYTHON_LONE    = 26
SHIP_FER_DE_LANCE   = 27
SHIP_MORAY          = 28
SHIP_THARGOID       = 29
SHIP_THARGLET       = 30
SHIP_CONSTRICTOR    = 31
SHIP_COUGAR         = 32
SHIP_DODEC          = 33
SHIP_TYPE_LIST_MAX  = SHIP_DODEC

class UniverseList:

    max_ships = 15
    wireframe = True
    solidObject = True
    shipCount = np.full(SHIP_TYPE_LIST_MAX,0)
    objectList = np.empty(max_ships,dtype=object)
    objectUsage = np.full (max_ships, False,dtype=bool)

    def getFreeSlot(self):
        return next((i for i, j in enumerate(self.objectUsage) if not j), None)

    def addObject(self,type,location,rotationmatrix,rotx,roty,rotz,velocity,accelleration,flags):
        freeslot = self.getFreeSlot()
        if freeslot == None: return    # all slots exhausted so exit
        if self.objectList[freeslot] == None:
           self.objectList[freeslot] = uo.UniverseObject(freeslot, type)
        self.objectList[freeslot].set_ship(freeslot,type)
        self.objectList[freeslot].set_position_data(location,rotationmatrix,rotx,roty,rotz,velocity,accelleration)
        self.objectUsage[freeslot] = True
        if flags & 128: self.flag_is_angry = True
        if flags & 64:  self.flag_is_scared = True
        if flags & 32:  self.flag_is_hunter = True
        if flags & 16:  self.flag_is_trader = True
        if flags & 8:   self.flag_is_courier = True
        if flags & 4:   self.flag_is_bezerk = True
        if flags & 2:   self.flag_has_cloak = True
        if flags & 1:   self.flag_has_ecm = True

    def addSpaceStation(self,type,location):
        freeslot = self.get_freeslot()
        if freeslot == None: return
        rotmat = vector.set_init_matrix (rotmat)
        rotmat[2].x = -rotmat[2].x
        rotmat[2].y = -rotmat[2].y
        rotmat[2].z = -rotmat[2].z
        self.addObject(type,location,rotmat)
        self.objectList[found].is_space_station = True

    def scoop_item(self,index):
        with objectList[index] as univ_obj:
            if univ_obj.flag_dead: return
            if not univ_obj.flag_is_scoopable: return  # this shoudl be a collision or is that done elsewhere?
            if not PlayerStatus.equip_fuel_scoop or univ_obj.location[1] >= 0.0 or PlayerStatus.is_Cargo_Hold_Full() or random(255) > PlayerStatus.equip_fuel_scoop_status:
                univ_obj.explode_object()
                PlayerStatus.damage_ship(128+(univ_obj.energy / 2), univ_obj.location.z > 0.0)
                return
            if univ_obj.type == SHIP_CARGO:
                trade = rand255() & 7
                cmdr.current_cargo[trade] += 1
                #info_message (stock_market[trade].name);
                self.delUnivObject (univ_obj)
                return
            # at this point it is scoopabel as we have tested that earlier
            cmdr.current_cargo[self.ship_list[type]] += 1
            #info_message (stock_market[trade].name);
            self.delUnivObject (univ_obj)

    def delUnivObject(self,objectnbr):
        if objectnbr < len(self.objectUsage):
            self.objectUsage[objectnbr] = False

    def delAllUnivObject(self):
        self.objectUsage = np.full (max_ships, False,dtype=bool)
