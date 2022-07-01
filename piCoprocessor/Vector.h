#ifndef  VECTOR_H_
#define  VECTOR_H_

#include "Typedefs.h"

typedef struct Vector
{
        double x;
        double y;
        double z;
} Vector;    

typedef struct Matrix
{
        Vector row[3];
} Matrix;

void createVectorDefault(Vector *vec);
void createVector (Vector *vec, double px,double py,double pz);
void createMatrix (Matrix *mat);
#endif