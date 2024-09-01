/* ShipData.c */
#include "ShipData.h"
#include <stdio.h>
static int    currentShip = 0;
#define debug 1

ShipData    shipData[ShipMax];

void selectShip(int shipNbr)
{
    #ifdef debug
    printf("In selectShip\n");
    #endif
    if (shipNbr < 0 || shipNbr > ShipMax)
    {
        #ifdef debug
        printf("defaulting to 0\n");
        #endif
        currentShip = 0;
    }
    else
    {    
        currentShip = shipNbr;
    }
}

void createShip(int shipModelNbr)
{
    EShipModels ShipModelId;
    
    #ifdef debug
    printf("In createShip\n");
    #endif 
    // sanity test that we have a valid ship id
    if (shipModelNbr < 0 || shipModelNbr > ShipID_Rattler)
    {
        #ifdef debug
        printf("defaulting nbr %i to Cobra Mk3\n", (int) shipModelNbr);
        #endif
        ShipModelId = ShipID_CobraMk3; // Default ship if its invalid
    }
    else
    {
        ShipModelId = (EShipModels)shipModelNbr;
    }
    // Sanity test for current ship out of bounds
    if (currentShip < 0 || currentShip> ShipMax)
    {
        #ifdef debug
        printf("currentShip %i out of range %i\n",currentShip,ShipMax);
        #endif
    }
    // Note at this stage we onyl poitn to the correct ship and set its status
    // we don't care if its currently used, in fact it may even get used
    // later in the game as a "mimic spoof" type clocking device on special missions
    shipData[currentShip].ship_model = ShipModelId;
    shipData[currentShip].status = Active;
}

void explodeShip(int shipNbr)
{
    #ifdef debug
    printf("In explodeCurrentShip\n");
    #endif 
    if (shipNbr < 0 || shipNbr> ShipMax)
    {
        #ifdef debug
        printf("ShipNbr %i out of range %i, ignoring command\n",shipNbr,ShipMax);
        #endif
        return;
    }
    else
    {
        ShipData *ship = &(shipData[shipNbr]);
        if (ship->status == Active)
        {
            ship->status = Exploding;
            ship->rollRate = 0.0f;
            ship->pitchRate = 0.0f;
            ship->acceleration = 0.0f;
            ship->explosionCountDown = 0;
        }
        #ifdef debug
        else
        {
            printf("ShipNbr is not active, status %i, ignoring command\n",(int)(shipData[shipNbr].status));
        }
        #endif
    }
}
        
void destroyShip(int shipNbr)
{
    #ifdef debug
    printf("In destroyCurrentShip\n");
    #endif 
    if (shipNbr < 0 || shipNbr> ShipMax)
    {
        #ifdef debug
        printf("ShipNbr %i out of range %i, ignoring command\n",shipNbr,ShipMax);
        #endif
        return;
    }
    else
    {
        if (shipData[shipNbr].status == Active || shipData[shipNbr].status == Exploding)
        {
            shipData[shipNbr].status = Empty;
            shipData[shipNbr].distance =MAXDISTANCE; // this is to optimise the draw routine z order sort, to push empty to the back
        }
        #ifdef debug
        else
        {
            printf("ShipNbr is not active or exploding, status %i, ignoring command\n",(int)(shipData[shipNbr].status));
        }
        #endif
     }

}
        
void setShipPosition(Vector *position)
{
    #ifdef debug
    printf("In setShipPosition\n");
    #endif 
    if (currentShip < 0 || currentShip> ShipMax)
    {
        #ifdef debug
        printf("ShipNbr %i out of range %i, ignoring command\n",currentShip,ShipMax);
        #endif
        return;
    }
    else
    {
        Vector *myPos = &(shipData[currentShip].position); // get pointer to vector rather than having to address by index for next 3
        myPos->x = position->x;
        myPos->y = position->y;
        myPos->z = position->z;
    }
}
        
void setShipMatrix(Matrix *mat)
{
    #ifdef debug
    printf("In setShipMatrix\n");
    #endif 
    if (currentShip < 0 || currentShip> ShipMax)
    {
        #ifdef debug
        printf("ShipNbr %i out of range %i, ignoring command\n",currentShip,ShipMax);
        #endif
        return;
    }
    else
    {
        Matrix  *myMat = &(shipData[currentShip].orientation); // get pointer to vector rather than having to address by index for next 3
        for (int i = 0; i < 3; i++)
        {
            Vector *vect    = myMat->row; // Could just do a mem copy but
            Vector *vectmat = mat->row;    // this is easier to read and 
            vect->x = vectmat->x;            // we have enough pi compute power
            vect->y = vectmat->y;
            vect->z = vectmat->z;
        }
    }
}




