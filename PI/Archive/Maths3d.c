#include <math.h>
#include "maths3d.h"

 double vector_dot_product (Vector *vec1, Vector *vec2)
 {
     return (vec1->x * vec2->x) + (vec1->y * vec2->y) + (vec1->z * vec2->z);	
 }
               
 void rotate_matrix(Matrix *mat)
 {
     double tmp;
     
	tmp            = mat->row[0].y;
	mat->row[0].y  = mat->row[1].x;
	mat->row[1].x  = tmp;

	tmp            = mat->row[0].z;
	mat->row[0].z  = mat->row[2].x;
	mat->row[2].x  = tmp;

	tmp            = mat->row[1].z;
	mat->row[1].z  = mat->row[2].y;
	mat->row[2].y  = tmp;
 }
               
 void multiply_vector_by_matrix (Vector *vec, Matrix *mat)
 {
     double x;
     double y;
     double z;

     x = (vec->x * mat->row[0].x) + (vec->y * mat->row[0].y) + (vec->z * mat->row[0].z);
     y = (vec->x * mat->row[1].x) + (vec->y * mat->row[1].y) + (vec->z * mat->row[1].z);
     z = (vec->x * mat->row[2].x) + (vec->y * mat->row[2].y) + (vec->z * mat->row[2].z);

     vec->x = x;
     vec->y = y;
     vec->z = z;
 }

 void multiply_matrix_by_matrix (Matrix *mat1, Matrix *mat2)
 {
     int i;
     Matrix rv;
 
     for (i = 0; i < 3; i++)
     {
         rv.row[i].x =	(mat1->row[0].x * mat2->row[i].x) +(mat1->row[1].x * mat2->row[i].y) +(mat1->row[2].x * mat2->row[i].z);
         rv.row[i].y =	(mat1->row[0].y * mat2->row[i].x) +(mat1->row[1].y * mat2->row[i].y) +(mat1->row[2].y * mat2->row[i].z);
         rv.row[i].z =	(mat1->row[0].z * mat2->row[i].x) +(mat1->row[1].z * mat2->row[i].y) +(mat1->row[2].z * mat2->row[i].z);
     }
 
     for (i = 0; i < 3; i++) 
     {
         mat1->row[i].x = rv.row[i].x;
         mat1->row[i].y = rv.row[i].y;
         mat1->row[i].z = rv.row[i].z;
     }
 }


Vector normalise(Vector *vec )
{
    double lx,ly,lz;
    double uni;
    Vector res;

    lx = vec->x;
    ly = vec->y;
    lz = vec->z;
    uni = sqrt ((lx*lx)+(ly*ly)+(lz*lz));
    res.x = lx/uni;
    res.y = ly/uni;
    res.z = lz/uni;
    return res;
}
 
 void set_identity(Matrix *mat)
 {
     mat->row[0].x = 1.0;
     mat->row[0].y = 0.0;
     mat->row[0].z = 0.0;
     mat->row[1].x = 0.0;
     mat->row[1].y = 1.0;
     mat->row[1].z = 0.0;
     mat->row[2].x = 0.0;
     mat->row[2].y = 0.0;
     mat->row[2].z = -1.0;

 }
 
 void copy_vector(Vector *to, Vector *from)
 {
     to->x = from->x;
     to->y = from->y;
     to->z = from->z;
 }
 
void copy_matrix(Matrix *to, Matrix *from)
{
    for (int i = 0 ; i < 3; i++)
    {
        to->row[i].x = from->row[i].x;
        to->row[i].y = from->row[i].y;
        to->row[i].z = from->row[i].z;
    }
}
 
 void orthagonise(Matrix *mat)
 {
     mat->row[2] = normalise (&mat->row[2]);
 
     if ((mat->row[2].x > -1) && (mat->row[2].x < 1))
     {
         if ((mat->row[2].y > -1) && (mat->row[2].y < 1))
         {
             mat->row[1].z = -(mat->row[2].x * mat->row[1].x + mat->row[2].y * mat->row[1].y) / mat->row[2].z;
         }
         else
         {
             mat->row[1].y = -(mat->row[2].x * mat->row[1].x + mat->row[2].z * mat->row[1].z) / mat->row[2].y;
         }
     }
     else
     {
         mat->row[1].x = -(mat->row[2].y * mat->row[1].y + mat->row[2].z * mat->row[1].z) / mat->row[2].x;
     }
     mat->row[1] = normalise (&mat->row[1]);
     mat->row[0].x = mat->row[1].y * mat->row[2].z - mat->row[1].z * mat->row[2].y;
     mat->row[0].y = mat->row[1].z * mat->row[2].x - mat->row[1].x * mat->row[2].z;
     mat->row[0].z = mat->row[1].x * mat->row[2].y - mat->row[1].y * mat->row[2].x;
 }
 
 void rotateVectorRollPitch(Vector *vec, double alpha, double beta)
 {
     double x;
     double y;
     double z;
     x = vec->x;
     y = vec->y;
     z = vec->z;
     
     y = y - alpha * x;
     x = x + alpha * y;
     y = y - beta  * z;
     z = z + beta  * y;

     vec->x = x;
     vec->y = y;
     vec->z = z;
}

void rotateXY(double *a, double *b, int direction)
{
	double fx;
    double ux;
    
    fx = *a;
	ux = *b;

	if (direction < 0)
	{	
		*a = fx - (fx / 512) + (ux / 19);
		*b = ux - (ux / 512) - (fx / 19);
	}
	else
	{
		*a = fx - (fx / 512) - (ux / 19);
		*b = ux - (ux / 512) + (fx / 19);
	}
}

double vectorLength(Vector *vec)
{
   return sqrt(vec->x*vec->x + vec->y* vec->y + vec->z*vec->z);
}
    