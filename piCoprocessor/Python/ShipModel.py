import numpy            as np

class   ShipPoint:
    def __init__(self,x,y,z,dist,face1,face2,face3,face4):
        self.x = x
        self.y = y
        self.z = z
        self.dist = dist
        self.face1 = face1
        self.face2 = face2
        self.face3 = face3
        self.face4 = face4

class   ShipLine:
    def __init__(self,dist,face1,face2,start_point,end_point):
        self.dist = dist
        self.face1 = face1
        self.face2 = face2
        self.start_point = start_point
        self.end_point = end_point

class   ShipNormal:
    def __init__(self,dist,x,y,z):
        self.dist = dist
        self.x = x
        self.y = y
        self.z = z

class   ShipFace:
    def __init__(self,color,normx,normy,normz,points,p1,p2,p3,p4,p5,p6,p7,p8):
        self.color = color
        self.normx = normx
        self.normy = normy
        self.normz = normz
        self.points= points
        self.p1    = p1
        self.p2    = p2
        self.p3    = p3
        self.p4    = p4
        self.p5    = p5
        self.p6    = p6
        self.p7    = p7
        self.p8    = p8

class   ShipModel:
    def __init__(self,ShipModel):
        #print ("Loading ",ShipModel)

        self.id              = ShipModel["ship_number"]
        self.name            = ShipModel["ship_name"]
        self.num_points      = ShipModel["num_points"]
        self.num_faces       = ShipModel["num_faces"]
        self.num_solids      = ShipModel["num_solids"]
        self.max_bounty      = ShipModel["max_bounty"]
        self.scoop_type      = ShipModel["scoop_type"]
        self.size            = ShipModel["size"]
        self.front_laser     = ShipModel["front_laser"]
        self.bounty          = ShipModel["bounty"]
        self.vanish_point    = ShipModel["vanish_point"]
        self.energy          = ShipModel["energy"]
        self.velocity        = ShipModel["velocity"]
        self.missiles        = ShipModel["missiles"]
        self.laser_strength  = ShipModel["laser_strength"]
        self.is_missile      = True if ShipModel["is_missile"] == "Y" else False
        self.is_space_station= True if ShipModel["is_space_station"] == "Y" else False
        self.is_debris       = True if ShipModel["is_debris"] == "Y" else False
        self.is_scoopable    = True if ShipModel["is_scoopable"] == "Y" else False
        self.is_bomb_proof   = True if ShipModel["is_bomb_proof"] == "Y" else False
        self.immune_to_ecm   = True if ShipModel["immune_to_ecm"] == "Y" else False
        #load points
        self.points          = np.empty (len(ShipModel["points"]), dtype=object )
        array_index          = 0
        for i in ShipModel["points"]:
            self.points[array_index] = ShipPoint(i["x"],i["y"],i["z"],i["dist"],i["face1"],i["face2"],i["face3"],i["face4"])
            array_index += 1
        #load lines
        self.lines            = np.empty (len(ShipModel["lines"]), dtype=object)
        array_index = 0
        for i in ShipModel["lines"]:
            self.lines[array_index]  = ShipLine(i["dist"],i["face1"],i["face2"],i["start_point"],i["end_point"])
            array_index += 1
        #load normals
        self.normals          = np.empty (len(ShipModel["normals"]), dtype=object)
        array_index = 0
        for i in ShipModel["normals"]:
            self.normals[array_index] = ShipNormal(i["dist"],i["x"],i["y"],i["z"])
            array_index += 1
        #load faces
        self.faces            = np.empty (len(ShipModel["faces"]), dtype=object)
        array_index = 0
        for i in ShipModel["faces"]:
            self.faces[array_index] = ShipFace(i["color"],i["normx"],i["normy"],i["normz"],i["points"],i["p1"],i["p2"],i["p3"],i["p4"],i["p5"],i["p6"],i["p7"],i["p8"])
            array_index += 1

