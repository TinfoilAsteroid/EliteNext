#ifndef  MATHS3D_H_
#define  MATHS3D_H_

#include "Vector.h"
double vector_dot_product (Vector *vec1, Vector *vec2);                                                                             
void multiply_vector_by_matrix (Vector *vec,  Matrix *mat);
void multiply_matrix_by_matrix (Matrix *mat1, Matrix *mat2);
Vector normalise(Vector *vec );
void set_identity(Matrix *mat);
void orthagonise(Matrix *mat);
void rotate_matrix(Matrix *mat);
void copy_vector(Vector *to, Vector *from);
void copy_matrix(Matrix *to, Matrix *from);
void rotateVectorRollPitch(Vector *vec, double alpha, double beta);
void rotateXY(double *a, double *b, int direction);
double vectorLength(Vector *vec);

#endif