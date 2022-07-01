#ifndef  SHIPMODELS_H_
#define  SHIPMODELS_H_

#include "Typedefs.h"
#include "ConsoleIO.h"
#include "Vector.h"

#define NodeMax 60
#define FaceMax 60

typedef enum EShipModels
{
//    ShipID_Adder,
//    ShipID_Anaconda,
//    ShipID_Asp_Mk_2,
//    ShipID_Boa,
//    ShipID_CargoType5,
//    ShipID_Boulder,
//    ShipID_Asteroid,
//    ShipID_Bushmaster,
//    ShipID_Chameleon,
    ShipID_CobraMk3,
//    ShipID_Cobra_Mk_1,
//    ShipID_Cobra_Mk_3_P,
//    ShipID_Constrictor,
//    ShipID_Coriolis,
//    ShipID_Cougar,
//    ShipID_Dodo,
//    ShipID_Dragon,
//    ShipID_Escape_Pod,
//    ShipID_Fer_De_Lance,
//    ShipID_Gecko,
//    ShipID_Ghavial,
//    ShipID_Iguana,
//    ShipID_Krait,
//    ShipID_Logo,
//    ShipID_Mamba,
//    ShipID_Missile,
//    ShipID_Monitor,
//    ShipID_Moray,
//    ShipID_Ophidian,
//    ShipID_Plate,
//    ShipID_Python,
//    ShipID_Python_P,
//    ShipID_Rock_Hermit,
//    ShipID_ShuttleType9,
//    ShipID_Shuttle_Mk_2,
//    ShipID_Sidewinder,
//    ShipID_Splinter,
//    ShipID_TestVector,
//    ShipID_Thargoid,
//    ShipID_Thargon,
//    ShipID_TransportType10,
//    ShipID_Viper,
//    ShipID_Worm,
    ShipID_Rattler
} EShipModels;
                            
typedef struct ShipNode
{
    double  x;
    double  y;
    double  z;
    double  always_draw_distance;
    int     face1;
    int     face2;
    int     face3;
    int     face4;
} ShipNode;

typedef struct ShipLine
{
    double  always_draw_distance;
    int     face1;
    int     face2;
    int     start_node;
    int     end_node;
} ShipLine;

typedef struct ShipFaceNormal
{
    double  always_draw_distance;
    double  x;
    double  y;
    double  z;
} ShipFaceNormal;

typedef struct ShipModel
{
    EShipModels      shipModelId;
    double           viewDistance;
    double           drawAllFacesDistance;
    double           maxRoll;
    double           maxPitch;
    double           maxSpeed;
    int              nodeCount;
    int              lineCount;
    int              normalCount;
    const ShipNode         *nodes;
    const ShipLine         *lines;
    const ShipFaceNormal   *normals;
} ShipModel;

int dummyFn(void);

#endif