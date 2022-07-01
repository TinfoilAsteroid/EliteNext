#ifndef  SHIPDATA_H_
#define  SHIPDATA_H_
#define LineMax 60
#define ShipMax 12
#define MAXDISTANCE 57344
#define EXPLOSIONDURATION 251
#include <stdbool.h>
#include "Typedefs.h"
#include "Line.h"
#include "Vector.h"
#include "ShipModels.h"

typedef enum EShipStatus
{
    Empty,
    Active,
    Exploding
} EShipStatus;

typedef struct ProjectedPoint
{
    double      x;
    double      y;
    double      z;
    double      screenX;
    double      screenY;
} ProjectedPoint;


// we also need some ship profile data in model, e.g max roll and pitch rate, acceleration rate 
typedef struct ShipData
{
    Vector      position;
    double      rollRate;
    double      pitchRate;
    double      acceleration;
    double      roll;
    double      pitch;
    double      speed;
    double      distance; // used for visibility calcs
    Matrix      orientation;
    EShipModels ship_model;
    int         ship_id;
    int         ship_id_target;
    EShipStatus status;
    int         explosionCountDown;
    bool        visible[LineMax]; // visibility check results
    int         renderLineCount;
    ProjectedPoint projectedPoints[LineMax];
    Line        renderLines[LineMax];
    /* Methods */
} ShipData;

void        ProcessShip(); 
void        selectShip(int shipNbr); 
void        createShip(int shipModelNbr);  
void        explodeShip(int shipNbr);
void        destroyShip(int shipNbr);
void        setShipPosition(Vector *position);
void        setShipMatrix(Matrix *mat);
#endif