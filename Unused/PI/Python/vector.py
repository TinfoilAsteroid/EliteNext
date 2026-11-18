# to open in python 2
# variables= {}
# >>> execfile( "someFile.py", variables )
import numpy as np

ident  = np.array ([[1.0, 0.0, 0.0],[0.0, 1.0, 0.0],[0.0, 0.0,-1.0]])

def mult_manual_matrix(first, second):
    return np.array( [first[0][0] * second[0][0] + first [1][0] * second[0][1] + first[2][0] * second[0][2],
                      first[0][1] * second[0][0] + first [1][1] * second[0][1] + first[2][1] * second[0][2],
                      first[0][2] * second[0][0] + first [1][2] * second[0][1] + first[2][2] * second[0][2]],
                     [first[0][0] * second[1][0] + first [1][0] * second[1][1] + first[2][0] * second[1][2],
                      first[0][1] * second[1][0] + first [1][1] * second[1][1] + first[2][1] * second[1][2],
                      first[0][2] * second[1][0] + first [1][2] * second[1][1] + first[2][2] * second[1][2]],
                     [first[0][0] * second[2][0] + first [1][0] * second[2][1] + first[2][0] * second[2][2],
                      first[0][1] * second[2][0] + first [1][1] * second[2][1] + first[2][1] * second[2][2],
                      first[0][2] * second[2][0] + first [1][2] * second[2][1] + first[2][2] * second[2][2]])

def mult_vect_matrix(vector, matrix):
    #print ('vector',vector,'matrix',matrix)
    return np.array([vector[0] * matrix[0][0]  + vector[0] * matrix[0][1] + vector[0] * matrix[0][2],
                     vector[1] * matrix[1][0]  + vector[0] * matrix[1][1] + vector[0] * matrix[1][2],
                     vector[2] * matrix[2][0]  + vector[0] * matrix[2][1] + vector[0] * matrix[2][2]])

def mult_vector (vector, matrix):
    return np.array([ (vector[0] * matrix[0][0]) + (vector[1] * matrix[0][1]) + (vector[2] * matrix[0][2]),
                      (vector[0] * matrix[1][0]) + (vector[1] * matrix[1][1]) + (vector[2] * matrix[1][2]),
                      (vector[0] * matrix[2][0]) + (vector[1] * matrix[2][1]) + (vector[2] * matrix[2][2])])

def rotate_x_first(a,b,direction):
    fx = a
    ux = b
    if direction < 0:
        retfx = fx - (fx/512) + (ux /19)
        retux = ux - (ux/512) - (fx /10)
    else:
        retfx = fx - (fx/512) - (ux /19)
        retux = ux - (ux/512) + (fx /10)           
    return fx,ux

def rotate_vec(vector, alpha, beta):
    retvec = copy()
    retvec[1] -= alpha * retvec[0]  # y = y - alpha * x
    retvec[0] += alpha * retvec[1]  # x = x + alpah * y
    retvec[1] -= beta * retvec[2]   # y = y - beta * z
    retvec[2] += beta * retvec[1]   # z = z + beta * y
    return retvec

def rotate_matrix(matrix,alpha,beta):
    return np.array( [ rotate_vec ( matrix[0], alpha, beta),
                       rotate_vec ( matrix[1], alpha, beta),
                       rotate_vec ( matrix[2], alpha, beta)])
   

#  turns rows to columns so row 0 becomes column 0, row 1 becomes column 1 & row 2 becomes column 2
def rotate_trans_mat(trans_matrix):
    # make a copy of the transformation matrix before swapping over elements
    rotated_matrix = np.ndarray.copy(trans_matrix)
    rotated_matrix[0][1] = trans_matrix[1][0]  # 0.y = 1.x
    rotated_matrix[1][0] = trans_matrix[0][1]  # 1.x = 0.y

    rotated_matrix[0][2] = trans_matrix[2][0]  # 0.y = 2.x
    rotated_matrix[2][0] = trans_matrix[0][2]  # 2.x = 0.z

    rotated_matrix[1][2] = trans_matrix[2][1]  # 1.z = 2.y
    rotated_matrix[2][1] = trans_matrix[1][2]  # 2.y = 1.z
    return rotated_matrix

def vector_dot_product(first, second):
    #print ("first",first,"second",second)
    dot_product = (first[0] * second[0]) + (first[1]*second[1]) + (first[2]*second[2])
    #print ('result',dot_product)
    return ((first[0] * second[0]) + (first[1]*second[1]) + (first[2]*second[2]))

def unit_vector(vector):
    #print("unit",vector)
    return vector / np.linalg.norm(vector)

def tidy_matrix(matrix):
    mat = matrix.copy()
    mat[2] = unit_vector(mat[2])
    
    if mat[2][0] > -1 and mat[2][0] < 1:
        if mat[2][1] > -1 and mat[2][1] < 1:
            mat[1][2] = - ((mat[2][0] * mat[1][0]) + (mat[2][1] * mat[1][1]))/mat[2][2]
        else:
            mat[1][1] = - ((mat[2][0] * mat[1][0]) + (mat[2][2] * mat[1][2]))/mat[2][1]
    else:
        mat[1][0]= - ((mat[2][1] * mat[1][1]) + (mat[2][2] * mat[1][2]))/mat[2][0]

    mat[1] = mat[1] / np.linalg.norm(mat[1])        # mat 1 becomes a unit vector

    mat[0][0] = mat[1][1] * mat[2][2] - mat[1][2] * mat[2][1]
    mat[0][1] = mat[1][2] * mat[2][0] - mat[1][0] * mat[2][2]
    mat[0][2] = mat[1][0] * mat[2][1] - mat[1][1] * mat[2][0]
    return mat.copy()

