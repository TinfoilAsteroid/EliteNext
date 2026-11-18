import numpy as np
import vector
import random
import shipmodels
print ("EliteGraphics loaded")

# Defining region codes
INSIDE = 0  # 0000
LEFT = 1  # 0001
RIGHT = 2  # 0010
BOTTOM = 4  # 0100
TOP = 8  # 1000

# Defining x_max, y_max and x_min, y_min for rectangle
# Since diagonal points are enough to define a rectangle

class GraphicsHandler:
    x_max = 255.0
    y_max = 127.0
    x_min = 0.0
    y_min = 0.0
    x_centre = x_max / 2
    y_centre = y_max / 2
    x_offsetmax = x_max / 2
    x_offsetmin = (x_max /2)*-1
    y_offsetmax = y_max / 2
    y_offsetmin = (y_max /2)*-1
    ship_model_array = None
    linelist = np.empty([255,5],dtype=np.uint8)
    linelistsize = 0

# Python program to implement Cohen Sutherland algorithm
# for line clipping.
# Function to compute region code for a point(x, y)

    def computeCode(self,x, y):
        code = INSIDE
        if x < x_min:  # to the left of rectangle
            code |= LEFT
        elif x > GraphicsHandler.x_max:  # to the right of rectangle
            code |= RIGHT
        if y < y_min:  # below the rectangle
            code |= BOTTOM
        elif y > GraphicsHandler.y_max:  # above the rectangle
            code |= TOP
        return code


    def cohenSutherlandClip(self,x1, y1, x2, y2):
        # Compute region codes for P1, P2
        code1 = GraphicsHandler.computeCode(x1, y1)
        code2 = GraphicsHandler.computeCode(x2, y2)
        accept = False

        while True:
            if code1 == 0 and code2 == 0:           # If both endpoints lie within rectangle
                accept = True
                break
            elif (code1 & code2) != 0:              # If both endpoints are outside rectangle
                break
            else:                                   # Some segment lies within the rectangle
                x = 1.0     # Line needs clipping At least one of the points is outside, select it
                y = 1.0
                code_out = code1 if code1 != 0 else code2
                # Find intersection point using formulas y = y1 + slope * (x - x1), x = x1 + (1 / slope) * (y - y1)
                if code_out & TOP:                  # Point is above the clip rectangle
                    x = x1 + (x2 - x1) * (GraphicsHandler.y_max - y1) / (y2 - y1)
                    y = y_max
                elif code_out & BOTTOM:             # Point is below the clip rectangle
                    x = x1 + (x2 - x1) * (GraphicsHandler.y_min - y1) / (y2 - y1)
                    y = y_min
                elif code_out & RIGHT:              # Point is to the right of the clip rectangle
                    y = y1 + (y2 - y1) * (GraphicsHandler.x_max - x1) / (x2 - x1)
                    x = x_max
                elif code_out & LEFT:               # Point is to the left of the clip rectangle
                    y = y1 + (y2 - y1) * (GraphicsHandler.x_min - x1) / (x2 - x1)
                    x = x_min
                # Now intersection point (x, y) is found We replace point outside clipping rectangle by intersection point
                if code_out == code1:
                    x1 = x
                    y1 = y
                    code1 = computeCode(x1, y1)
                else:
                    x2 = x
                    y2 = y
                    code2 = computeCode(x2, y2)

        if accept:
            return (accept,x1,y1,x2,y2)
        else:
            return (accept,0,0,0,0)

    # for now wireframe is monochrome and always sends color as 255
    def generate_object_lines(self,univ_obj):
        # get ship model
        ship_model = ship_models.shipMasterList.ship_model_array[univ_obj.type]
        # get rotation matrix for ship, we take a copy for later
        trans_mat = np.ndarray.copy(univ_obj.rotmat)
        # print ("?",trans_mat)
        # camera vector is unit vector of location mul trans mat
        camera_vec = vector.unit_vector(vector.mult_vector(univ_obj.location,trans_mat))
        # create a working list of visible faces
        visible_list = np.empty (len(shipModel.normals), dtype=bool)        # just the length of the first dimension
        # work out if faces are visible by building a list of true/false
        for i,j in enumerate(shipModel.normals):
            norm_vec = np.array([j.x,j.y,j.z])
            if (norm_vec[0] == 0 and norm_vec[1] == 0 and norm_vec[2] == 0):
                visible_list[i] = True
            else:
                cos_angle = vector.vector_dot_product(norm_vec,camera_vec)
                norm_vec =  vector.unit_vector(norm_vec)
                visible_list[i] = True if cos_angle < -0.2 else False
        # make transformation matrix rotate so its now will calculate ship pos to eye
        trans_mat = vector.rotate_trans_mat(trans_mat)
        #print (trans_mat)
        point_list   = np.empty (shape=(len(ship_model.points),2)) # the number of points
        for i,j in enumerate(ship_model.points):
            # vector = point mult transformation matrix to get screen position in range -1 to + 1
            vec = vector.mult_vector (np.array([j.x, j.y, j.z]), trans_mat)
            r_vec = np.array([vec[0] + univ_obj.location[0], vec[1] + univ_obj.location[1], vec[2] + univ_obj.location[2]])
            # save screen position for points as x & y / z
            point_list[i][0] = GraphicsHandler.x_centre+((r_vec[0] * GraphicsHandler.x_max)/r_vec[2])
            point_list[i][1] = GraphicsHandler.y_centre-((r_vec[1] * GraphicsHandler.y_max)/r_vec[2])
        for i,j in enumerate(ship_model.lines):
            if linelistsize > 254: return       # bail out if we run out of lines
            if visible_list[j.face1] or visible_list[j.face2]:
                with linelist[linelistsize] as newline:
                    accept,x1,y1,x2,y2 = cohenSutherlandClip(point_list[j.start_point][0],point_list[j.start_point][1],point_list[j.end_point][0],  point_list[j.end_point][1])
                    if accept:
                        newline[0] = 255
                        newline[1],newline[2],newline[2],newline[4] = x1,y1,x2,y2
                        linelistsize += 1
        if univ_obj.flag_firing:
            laser = ship_model.front_laser
            with linelist[linelistsize] as newline:
                accept,x1,y1,x2,y2 = cohenSutherlandClip(point_list[[laser]].x,point_list[laser].y, random.randint(0,255), random.randint(0,127))
                if accept:
                    newline[0] = 255
                    newline[1],newline[2],newline[2],newline[4] = x1,y1,x2,y2
                    linelistsize += 1

    def generate_line_list(self,univ_list):
        linelistsize = 0            # empty list head pointer
        for i,j in univ_list.objectList:
            if univ_list.objectUsage[i]:
                if j.flag_do_draw:
                    self.generate_object_lines(i)
