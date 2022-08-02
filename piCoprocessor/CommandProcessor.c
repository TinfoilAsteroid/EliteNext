#include <math.h>
#include "CommandProcessor.h"
#include "consoleIO.h"
#include "ShipModels.h"
#include "ShipData.h"
#include "maths3d.h"
#define   debug 1

extern EFileStatus  readstatus ;
extern Vector       defaultVector;
extern Matrix       identityMatrix;

static const CommandTable commandTable[] = {{/*00*/NoOperation           ,false,    false, &cmdVoid},
                                            {/*01*/Initialise            ,false,    false, &cmdVoid},
                                            {/*02*/BinaryIOMode          ,true,     false, &cmdBinaryIOMode},
                                            {/*03*/TextIOMode            ,true,     false, &cmdTextIOMode},
                                            {/*04*/FetchError            ,false,    false, &cmdVoid},
                                            {/*05*/UpdateAll             ,false,    true,  &cmdVoid},
                                            {/*06*/GetUpdateStatus       ,false,    false, &cmdVoid},
                                            {/*07*/SelectShip            ,true,     false, &cmdSelectShip},
                                            {/*08*/CreateShip            ,true,     false, &cmdCreateShip},
                                            {/*09*/ExplodeShip           ,true,     false, &cmdExplodeShip},
                                            {/*10*/DestroyShip           ,true,     false, &cmdDestroyShip},
                                            {/*11*/GetPosition           ,false,    false, &cmdVoid},
                                            {/*12*/GetShipMatrix         ,false,    false, &cmdVoid},
                                            {/*13*/GetShipLineCount      ,false,    false, &cmdVoid},
                                            {/*14*/GetShipLineList       ,false,    false, &cmdVoid},
                                            {/*15*/SetSun                ,false,    false, &cmdVoid},
                                            {/*16*/GetSunPosition        ,false,    false, &cmdVoid},
                                            {/*17*/GetSunMatrix          ,false,    false, &cmdVoid},
                                            {/*18*/GetSunLineCount       ,false,    false, &cmdVoid},
                                            {/*19*/GetSunLineList        ,false,    false, &cmdVoid},
                                            {/*20*/SetPlanet             ,false,    false, &cmdVoid},
                                            {/*21*/GetPlanetPosition     ,false,    false, &cmdVoid},
                                            {/*22*/GetPlanetMatrix       ,false,    false, &cmdVoid},
                                            {/*23*/GetPlanetLineCount    ,false,    false, &cmdVoid},
                                            {/*24*/GetPlanetLineList     ,false,    false, &cmdVoid},
                                            {/*25*/GetShipInSightCount   ,false,    false, &cmdVoid},
                                            {/*26*/GetShipsInSightList   ,false,    false, &cmdVoid},
                                            {/*27*/GetShipTargetId       ,false,    false, &cmdVoid},
                                            {/*28*/SetShipTargetId       ,false,    false, &cmdVoid},
                                            {/*29*/GetShipType           ,false,    false, &cmdVoid},
                                            {/*30*/GetShipStatus         ,false,    false, &cmdVoid},
                                            {/*31*/RoateShipToTarget     ,false,    false, &cmdVoid},
                                            {/*32*/RotateShipToShipN     ,false,    false, &cmdVoid},
                                            {/*33*/RotateShipToPlayer    ,false,    false, &cmdVoid},
                                            {/*34*/PitchShipToTarget     ,false,    false, &cmdVoid},
                                            {/*35*/PitchShipToShipN      ,false,    false, &cmdVoid},
                                            {/*36*/PitchShipToPlayer     ,false,    false, &cmdVoid},
                                            {/*37*/RollShipToTarget      ,false,    false, &cmdVoid},
                                            {/*38*/RollShipToShipN       ,false,    false, &cmdVoid},
                                            {/*39*/RollShipToPlayer      ,false,    false, &cmdVoid},
                                            {/*40*/AdjustSpeedToTarget   ,false,    false, &cmdVoid},
                                            {/*41*/AdjustSpeedToShipN    ,false,    false, &cmdVoid},
                                            {/*42*/AdjustSpeedToPlayer   ,false,    false, &cmdVoid},
                                            {/*43*/NormaliseVector       ,true,     false, &cmdNormalise},
                                            {/*44*/OrthagnoaliseMatrix   ,true,     false, &cmdOrthagnonaliseMatrix},
                                            {/*45*/SquareRoot            ,true,     false, &cmdSquareRoot},
                                            {/*46*/VectMulMatrix         ,true,     false, &cmdVectMulMatrix},
                                            {/*47*/DotProduct            ,true,     false, &cmdDotProduct},
                                            {/*48*/GetIdentitymatrix     ,false,    false, &cmdVoid},
                                            {/*49*/SetShipPosition       ,true,     false, &cmdSetShipPosition},
                                            {/*50*/SetShipMatrix         ,true,     false, &cmdSetShipMatrix},
                                            {/*51*/SetPlayerRoll         ,true,     false, &cmdSetPlayerRoll},
                                            {/*52*/SetPlayerPitch        ,true,     false, &cmdSetPlayerPitch},
                                            {/*53*/SetPlayerSpeed        ,true,     false, &cmdSetPlayerSpeed},
                                            {/*57*/InvalidCommand        ,false,    false, &cmdVoid},
                                            {/*58*/Exit                  ,true,     false, &cmdExit}};

bool processCommand  (EnumCommands command)
{
    void  (*func)();

    #ifdef debug
    printf("processCommand\n");
    #endif
    if (command > Exit)
    {
        #ifdef debug
        printf("cmd out of range\n");
        #endif
        return false;
    }
    else
    {
        if (commandTable[command].implemented == false)
        {
            #ifdef debug
            printf("cmd not implemented\n");
            #endif
            return false;
        }
        else
        {
            func = commandTable[command].processorFn;
            (*func)();
            return true;
        }
    }
}
void /*01*/cmdInitialise(void)
{
    engineInitialise();
}

/* binaryIOMode - sets input output to binary, all numbers are 24 bit lead sign */
void /*02*/cmdBinaryIOMode(void)
{
    #ifdef debug
    printf("In cmdBinaryIOMode\n");
    #endif
    set_binary_mode();
}
/* binaryIOMode - sets input output to text, all numbers are lead sign terminated by separator (separator excluded) */
void /*03*/cmdTextIOMode(void)
{
    #ifdef debug
    printf("In cmdTextIOMode\n");
    #endif
    set_text_mode();
}

//void /*04*/cmdFetchError
void /*05*/cmdUpdateAll(void)
{
    updateAll();
}

void /*06*/cmdGetUpdateStatus(void)
{
    EngineStatus engineStatus;
    engineStatus = getStatus();
    if (engineStatus != ReadyToSend)
    {
        write_int(255);
    }
    else
    {
        write_int(0);
    }
}

void /*07*/cmdSelectShip(void)
{
    #ifdef debug
    printf("In cmdSelectShip\n");
    #endif
    selectShip((int)read_double());
}
void /*08*/cmdCreateShip(void)
{
    #ifdef debug
    printf("In cmdCreateShip\n");
    #endif
    createShip((int)read_double());
}
void /*09*/cmdExplodeShip(void)
{
    explodeShip((int)read_double());
}

void /*10*/cmdDestroyShip(void)
{
    destroyShip((int)read_double());
}

//void /*11*/cmdGetPosition
//void /*12*/cmdGetShipMatrix
//void /*13*/cmdGetShipLineCount
//void /*14*/cmdGetShipLineList
//void /*15*/cmdSetSun
//void /*16*/cmdGetSunPosition
//void /*17*/cmdGetSunMatrix
//void /*18*/cmdGetSunLineCount
//void /*19*/cmdGetSunLineList
//void /*20*/cmdSetPlanet
//void /*21*/cmdGetPlanetPosition
//void /*22*/cmdGetPlanetMatrix
//void /*23*/cmdGetPlanetLineCount
//void /*24*/cmdGetPlanetLineList
//void /*25*/cmdGetShipInSightCount
//void /*26*/cmdGetShipsInSightList
//void /*27*/cmdGetShipTargetId
//void /*28*/cmdSetShipTargetId
//void /*29*/cmdGetShipType
//void /*30*/cmdGetShipStatus
//void /*31*/cmdRoateShipToTarget
//void /*32*/cmdRotateShipToShipN
//void /*33*/cmdRotateShipToPlayer
//void /*34*/cmdPitchShipToTarget
//void /*35*/cmdPitchShipToShipN
//void /*36*/cmdPitchShipToPlayer
//void /*37*/cmdRollShipToTarget
//void /*38*/cmdRollShipToShipN
//void /*39*/cmdRollShipToPlayer
//void /*40*/cmdAdjustSpeedToTarget
//void /*41*/cmdAdjustSpeedToShipN
//void /*42*/cmdAdjustSpeedToPlayer



/* normalise
   IN  - vector (3 doubles)
   OUT - vector (3 doubles), if read fails, writes 1,0,0 vector
*/
void /*43*/cmdNormalise(void)
{
    Vector lVector;
    #ifdef debug
    printf("In cmdNormalise\n");
    #endif
    lVector.x = read_double();
    lVector.y = read_double();
    lVector.z = read_double();
    lVector = normalise(&lVector);
    lVector.x *= 96;
    lVector.y *= 96;
    lVector.z *= 96;
    write_vector(&lVector);
}

void /*44*/cmdOrthagnonaliseMatrix(void)
{
    Matrix mat;

    #ifdef debug
    printf("In cmdOrthagnonaliseMatrix\n");
    #endif
    read_matrix(&mat);
    orthagonise(&mat);
    write_matrix(&mat);
}

/* square Root
    IN  - double
    OUT - double, if square root can not read input then returns sqrt 1
*/
void /*45*/cmdSquareRoot(void)
{
    double  value;
    #ifdef debug
    printf("In cmdSquareRoot\n");
    #endif

    value = read_double();
    value = sqrt(value);
    #ifdef debug
    printf("SQRT %f\n",value);
    #endif
    write_double(value);
    write_terminator();

}


void /*46*/cmdVectMulMatrix(void)
{
    Vector  vect;
    Matrix  mat;

    #ifdef debug
    printf("In cmdVectMulMatrix\n");
    #endif
    read_vector(&vect);
    read_matrix(&mat);
    multiply_vector_by_matrix(&vect, &mat);
    write_vector(&vect);
}


void /*47*/cmdDotProduct(void)
{
    Vector vec1;
    Vector vec2;

    #ifdef debug
    printf("In cmdDotProduct\n");
    #endif

    read_vector(&vec1);
    read_vector(&vec2);
    double result = vector_dot_product(&vec1,&vec2);
    write_double(result);
}

void /*48*/cmdGetIdentitymatrix(void)
{
    #ifdef debug
    printf("In cmdGetIdentitymatrix\n");
    #endif
   // write_matrix();
}

void  /*49*/cmdSetShipPosition(void)
{
    Vector position;
    #ifdef debug
    printf("In cmdSetShipPosition\n");
    #endif
    read_vector(&position);
    setShipPosition(&position);
}

void  /*50*/cmdSetShipMatrix(void)
{
    Matrix mat;
    #ifdef debug
    printf("In SetShipMatrix\n");
    #endif
    read_matrix(&mat);
    setShipMatrix(&mat);
}

void /*51*/cmdSetPlayerRoll()
{
    #ifdef debug
    printf("In cmdSetPlayerRotABS\n");
    #endif
    setPlayerRoll(read_double());
}
void /*52*/cmdSetPlayerPitch()
{
    #ifdef debug
    printf("In cmdSetPlayerPitchABS\n");
    #endif
    setPlayerPitch(read_double());    
}
void /*53*/cmdSetPlayerSpeed()
{
    #ifdef debug
    printf("In cmdSetPlayerSpeedABS\n");
    #endif
    setPlayerSpeed(read_double());    
}
                                          
void  cmdExit(void)
{
    #ifdef debug
    printf("In cmdExit\n");
    #endif
    write_exit();
}

void cmdVoid(void)
{
    #ifdef debug
    printf("In cmdVoid\n");
    #endif
    return;
}
