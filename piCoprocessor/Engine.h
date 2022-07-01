#ifndef  ENGINE_H_
#define  ENGINE_H_
#include "Line.h"
#include "ShipModels.h"
#include "ShipData.h"
#include "Maths3d.h"
typedef enum EngineStatus
{
    Initialised,
    Processing,
    ReadyToSend
} EngineStatus;

typedef struct shipDist
{
    int index;
    double z;
} shipDist;

typedef enum ViewPort
{
    Front,
    Rear,
    Left,
    Right
} ViewPort;

double playerPitch;
double playerRoll;
double playerSpeed;
void         engineInitialise(void);
void         setPlayerRoll(double rotation);
void         setPlayerPitch(double pitch);
void         setPlayerSpeed(double speed);
void         updateAll(void);
void         updateShipPosition(ShipData *shipData);
void         threadedUpdate();
bool         shipInViewPort(ShipData *shipData);
void         projectShip(Vector *camera, Matrix *transformation, ShipData *shipData);
void         generateShipLines(ShipData *shipData);
void         calculateShipExplosion(ShipData *shipData);
void         calculateLines(ShipData *shipData);
EngineStatus getStatus(void);
#endif