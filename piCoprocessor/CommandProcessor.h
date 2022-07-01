#ifndef  COMMANDPROCESSOR_H_
#define  COMMANDPROCESSOR_H_
#include <stdbool.h>
#include "Typedefs.h"
#include "Vector.h"
#include "Engine.h"

// we need logic to signal back ship was blown up by player for scoring
// for laserts game engien can do that by workign on damage then just signal to erase
// for missiles we need to signal back, or check distance to targetr
typedef enum  EnumCommands
{
    NoOperation,            /*Done*/
    Initialise,
    BinaryIOMode,           /*Done*/
    TextIOMode,             /*Done*/
    FetchError,
    UpdateAll,
    GetUpdateStatus,        /*Done*/
    SelectShip,             /*Done*/
    CreateShip,             /*Done*/
    ExplodeShip,            /*Done*/
    DestroyShip,            /*Done*/
    GetPosition,        
    GetShipMatrix,      
    GetShipLineCount,
    GetShipLineList,
    SetSun,     
    GetSunPosition,
    GetSunMatrix,
    GetSunLineCount,
    GetSunLineList,
    SetPlanet,
    GetPlanetPosition,
    GetPlanetMatrix,
    GetPlanetLineCount,
    GetPlanetLineList,
    GetShipInSightCount,
    GetShipsInSightList,
    GetShipTargetId,
    SetShipTargetId,
    GetShipType,
    GetShipStatus,
    RoateShipToTarget,
    RotateShipToShipN,
    RotateShipToPlayer,
    PitchShipToTarget,
    PitchShipToShipN,
    PitchShipToPlayer,
    RollShipToTarget,
    RollShipToShipN,
    RollShipToPlayer,
    AdjustSpeedToTarget,
    AdjustSpeedToShipN,
    AdjustSpeedToPlayer,
    NormaliseVector,        /*Done*/
    OrthagnoaliseMatrix,    /*Done*/
    SquareRoot,             /*Done*/
    VectMulMatrix,          /*Done*/
    DotProduct,             /*Done*/
    GetIdentitymatrix,      /*Done*/
    SetShipPosition,        /*Done*/
    SetShipMatrix,          /*Done*/
    SetPlayerRoll,          /*Done*/
    SetPlayerPitch,         /*Done*/
    SetPlayerSpeed,         /*Done*/
    SetPlayerViewPort,      // needed for rendering
    ShipVectorToPlayer,
    ShipVectorToTarget,
    ShipVectorToShipN,
    ShipVectorToPlanet,
    ShipVectorToSun,
    GetShipDocking,         // tells us if we can dock
    GetShipDistanceToTarget,
    GetShipDistanceToPlayer,
    InvalidCommand,         /*Done*/
    Exit                    /*Done*/
} EnumCommands;


typedef struct CommandTable
{
    EnumCommands  command;
    bool          implemented;
    bool          async;
    void          (*processorFn)(void);
} CommandTable;

EnumCommands command_to_binary(void);
void parseCommand(EnumCommands commandId);
bool processCommand  (EnumCommands command);
void cmdBinaryIOMode(void);
void cmdTextIOMode(void);
void /*01*/cmdInitialise(void);
void /*04*/cmdFetchError(void);
void /*05*/cmdUpdateAll(void);
void /*06*/cmdGetUpdateStatus(void);
void /*07*/cmdSelectShip(void);
void /*08*/cmdCreateShip(void);
void /*09*/cmdExplodeShip(void);
void /*10*/cmdDestroyShip(void);
void /*11*/cmdGetPosition(void);
void /*12*/cmdGetShipMatrix(void);
void /*13*/cmdGetShipLineCount(void);
void /*14*/cmdGetShipLineList(void);
void /*15*/cmdSetSun(void);
void /*16*/cmdGetSunPosition(void);
void /*17*/cmdGetSunMatrix(void);
void /*18*/cmdGetSunLineCount(void);
void /*19*/cmdGetSunLineList(void);
void /*20*/cmdSetPlanet(void);
void /*21*/cmdGetPlanetPosition(void);
void /*22*/cmdGetPlanetMatrix(void);
void /*23*/cmdGetPlanetLineCount(void);
void /*24*/cmdGetPlanetLineList(void);
void /*25*/cmdGetShipInSightCount(void);
void /*26*/cmdGetShipsInSightList(void);
void /*27*/cmdGetShipTargetId(void);
void /*28*/cmdSetShipTargetId(void);
void /*29*/cmdGetShipType(void);
void /*30*/cmdGetShipStatus(void);
void /*31*/cmdRoateShipToTarget(void);
void /*32*/cmdRotateShipToShipN(void);
void /*33*/cmdRotateShipToPlayer(void);
void /*34*/cmdPitchShipToTarget(void);
void /*35*/cmdPitchShipToShipN(void);
void /*36*/cmdPitchShipToPlayer(void);
void /*37*/cmdRollShipToTarget(void);
void /*38*/cmdRollShipToShipN(void);
void /*39*/cmdRollShipToPlayer(void);
void /*40*/cmdAdjustSpeedToTarget(void);
void /*41*/cmdAdjustSpeedToShipN(void);
void /*42*/cmdAdjustSpeedToPlayer(void);
void /*43*/cmdNormalise(void);
void /*44*/cmdOrthagnonaliseMatrix(void);
void /*45*/cmdSquareRoot(void);
void /*46*/cmdVectMulMatrix(void);
void /*47*/cmdDotProduct(void);
void /*48*/cmdGetIdentitymatrix(void);
void /*49*/cmdSetShipPosition(void);
void /*50*/cmdSetShipMatrix(void);
void /*51*/cmdSetPlayerRoll(void);
void /*52*/cmdSetPlayerPitch(void);
void /*53*/cmdSetPlayerSpeed(void);
void /*  */cmdExit(void);
void cmdVoid(void);

#endif