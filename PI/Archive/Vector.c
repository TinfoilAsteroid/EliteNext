#include "vector.h"

const static Vector defaultVector = {0.0,0.0,0.0};
const static Matrix identityMatrix = {{{1.0,0.0,0.0},{0.0,1.0,0.0},{0.0,0.0,-1.0}}};

void createVectorDefault(Vector *vec)
{
    vec->x = defaultVector.x;
    vec->y = defaultVector.y;
    vec->z = defaultVector.z;
}

void createVector (Vector *vec, double px,double py,double pz)
{
    vec->x = px;
    vec->y = py;
    vec->z = pz;
}

void createMatrix (Matrix *mat)
{
    mat->row[0].x = identityMatrix.row[0].x;
    mat->row[0].y = identityMatrix.row[0].y;
    mat->row[0].z = identityMatrix.row[0].z;
    mat->row[1].x = identityMatrix.row[1].x;
    mat->row[1].y = identityMatrix.row[1].y;
    mat->row[1].z = identityMatrix.row[1].z;
    mat->row[2].x = identityMatrix.row[2].x;
    mat->row[2].y = identityMatrix.row[2].y;
    mat->row[2].z = identityMatrix.row[2].z;
}
