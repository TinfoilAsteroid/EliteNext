#include "Engine.h"   
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <math.h>
#include <pthread.h>

#define debug = 1

#define cos_threshold -0.2
#define cos_explosion_threshold -0.13
EngineStatus    engineStatus = Initialised;
pthread_t       update_thread_id;
ViewPort        viewPort;
extern ShipModel shipModels[];

void engineInitialise(void)
{
   engineStatus = Initialised;
   viewPort     = Front;
   srand(time(NULL));
}

EngineStatus getStatus(void)
{
    return engineStatus;
}

void updateAll(void)
{
    if (engineStatus != Processing)
    {   
        if (pthread_create (&update_thread_id, NULL, (void*)threadedUpdate, (void*)&update_thread_id) == 0)
        {
            #ifdef debug
            printf ("updateAll thread creation failed setting to processed so last data set avaliable\n");
            #endif
            engineStatus = ReadyToSend;
        }
        #ifdef debug
        else
        {
            printf("Thread launched\n");
        }
        #endif
    }
    #ifdef debug
    else
    {
        printf ("updateAll already processing, ignoring\n");
    }
    #endif
}

void  setPlayerRoll(double rotation)
{
    playerRoll = rotation;
}

void  setPlayerPitch(double pitch)
{
    playerPitch = pitch;
}

void  setPlayerSpeed(double speed)
{
    playerSpeed = speed;
}

void updateShipPosition(ShipData *shipData)
{
     double x;
     double y;
     double z;
     double k2;
     double alpha; // calculated roll
     double beta;  // calculated pitch
     double delta; // calculated speed
     double distance;
     
     if (shipData->status == Empty)
     {
        #ifdef debug
        printf("Empty ship, ignoring\n");
        #endif
        shipData->distance = MAXDISTANCE ; // this is to optimise the draw routine z order sort, to push empty to the back
        return;
     }
     
     if (shipData->status == Exploding && shipData->explosionCountDown == 0)
     {
        #ifdef debug
        printf("Erasing\n");
        #endif
        return;
     }
                
     alpha = playerRoll  / 256.0;
     beta  = playerPitch /256.0;
     
     x     = shipData->position.x;
     y     = shipData->position.y;
     z     = shipData->position.z;
     
     // if its stationary we can ignore all speed logic
     if (shipData->speed != 0)
     {
         double speed = shipData->speed;
         speed *= 1.5;
         x += shipData->orientation.row[2].x * speed;
         y += shipData->orientation.row[2].y * speed;
         z += shipData->orientation.row[2].z * speed;
     }
     // if its accelerating then update speed for next cycle, dead/exploding shipts set accel to 0
     if (shipData->acceleration != 0)
     {
         shipData->speed       += shipData->acceleration;
         shipData->acceleration = 0;
         shipData->speed = shipData->speed<=shipModels[shipData->ship_model].maxSpeed?shipData->speed:shipModels[shipData->ship_model].maxSpeed;
         shipData->speed = shipData->speed<0?0:shipData->speed;
     }
     // perform minsky rotation
     if (alpha != 0 && beta != 0)
     {
         k2 = y - alpha * x;
         z  += beta * k2;
         y  = k2 - z * beta;
         x  += alpha * y;
     }
     // adjust for player speed which is always >= 0
     z = z - playerSpeed;
     // get ship distance from player for visibility
     distance = vectorLength(&(shipData->position));
     // perform rotation now around player
     rotateVectorRollPitch(&(shipData->orientation.row[2]),alpha, beta);
     rotateVectorRollPitch(&(shipData->orientation.row[1]),alpha, beta);
     rotateVectorRollPitch(&(shipData->orientation.row[0]),alpha, beta);
     // If is exploding we don't apply rotation and we are done
     if (shipData->Status == Exploding)
     {
         return;
     }
     else
     {
         // rotate aroudn its own axis
         double rotx = shipData->roll;
         double rotz = shipData->pitch;
         if (rotx != 0)
         {
             rotateXY(&(shipData->orientation.row[2].x),&(shipData->orientation.row[1].x), rotx);
             rotateXY(&(shipData->orientation.row[2].y),&(shipData->orientation.row[1].y), rotx);
             rotateXY(&(shipData->orientation.row[2].z),&(shipData->orientation.row[1].z), rotx);
             if (fabs(rotx) != 127) // 127 is a special case where damping does not get applied
             {
                 shipData->roll -= (rotx<0)? -1.0 : 1.0;    // dampen roll
             }
         }
         if (rotz != 0)
         {
             rotateXY(&(shipData->orientation.row[0].x),&(shipData->orientation.row[1].x), rotz);
             rotateXY(&(shipData->orientation.row[0].y),&(shipData->orientation.row[1].y), rotz);
             rotateXY(&(shipData->orientation.row[0].z),&(shipData->orientation.row[1].z), rotz);
             if (fabs(rotz) != 127) // 127 is a special case where damping does not get applied
             {
                 shipData->pitch -= (rotz<0)? -1.0 : 1.0;    // dampen roll
             }
         }
         // Now we orthanonise matrix
         orthagonise(&(shipData->orientation));
     }
} 

void threadedUpdate()
{
    engineStatus = Processing;
    for (int i = 0; i < ShipMax; i++)
    {
        if (shipData[i].status == Exploding && shipData[i].explosionCountDown == 0)
        {  
           #ifdef debug
           printf("Erasing\n");
           #endif
           destroyShip(i);
        }
        else
        {
            updateShipPosition(&(shipData[i])); // We do empty ships as that sets distance to max
            if (shipData[i].distance > MAXDISTANCE) || (shipData[i].status = Exploding && shipData[i].explosionCountDown>EXPLOSIONDURATION)
            {
                destroyShip(i); // too far away
            }
            else
            {
                generateShipLines(&(shipData[i]));
            }
        }
    }
    engineStatus = ReadyToSend;
}

bool shipInViewPort(ShipData *shipData)
{
    Vector *position;
    position = &(shipData->position);
    switch (viewPort):
    {
        Front:
        {
            if (position->z >= 0 && fabs(position->x) >= position->z && fabs(position->y) >= position->z)
            {
                return true;
            }
            else
            {
                return false;
            }
            break;
        }
        Rear:
        {
            if (position->z <= 0 && fabs(position->x) >= position->z && fabs(position->y) >= position->z)
            {
                return true;
            }
            else
            {
                return false;
            }
            break;
        }
        Left:
        {
            if (position->x <= 0 && fabs(position->z) >= position->x && fabs(position->y) >= position->x)
            {
                return true;
            }
            else
            {
                return false;
            }
            break;
        }
        Right:
        {
            if (position->x >= 0 && fabs(position->z) >= position->x && fabs(position)->y >= position->x)
            {
                return true;
            }
            else
            {
                return false;
            }
            break;
        }   
    }
    return false;
}

void generateShipLines(ShipData *shipData)
{
    if (viewPort < Front || viewPort > Right)
    {
        #ifdef debug
        printf ("invalid view port, ingoring\n");
        #endif
        return;
    }
    else
    {
        if (shipData->status != Empty)
        {
            if (shipInViewPort(shipData) == true)
            {
                if (shipData->status == Exploding)
                {
                    calculateShipExplosion(shipData);
                }
                else
                {
                    calculateLines(shipData);
                }
            }
        }
    }
}


void projectShip(Vector *camera, Matrix *transformation, ShipData *shipData)
{
    copy_matrix( transformation, &(shipData->orientation));
    copy_vector( camera, &(shipData->position));
    multiply_vector_by_matrix(camera, transformation);
    normalise(camera);
}

void calculateShipExplosion(ShipData *shipData)
{
    int i;
	int z;
	int q;
	int cnt;
    int nbr_points;
	Matrix transformation;
	double rz, sx,sy;
	Vector vec;
	Vector camera;
	double cos_angle;

	if (shipData->explosionCountDown > EXPLOSIONDURATION)
    {
        shipData->renderLineCount = 0;
        return;
    }
    (shipData->explosionCountDown)+=4;

    projectShip(&camera, &transformation, shipData);
    
    ShipModel *shipModel = &(shipModels[shipData->ship_id]);
    int faceCount = shipModel->normalCount;
    int faceNormals = shipModel->normals;
    for (int i = 0; i< faceCount; i++)
    {
        vec.x = faceNormals[i].x;
        vec.y = faceNormals[i].y;
        vec.z = faceNormals[i].z;
        
        if (vec.x == 0 && vec.y==0 && vec.z==0)
        {
            shipData->visible[i] = true;
        }
        else
        {
            normalise(&vec);
            cos_angle = vector_dot_product(&vec, &camera);
            shipData->visible[i] = (cos_angle < cos_explosion_threshold)?true:false;
        }
    }
    
    rotate_matrix(&transformation);
    three.c up to  draw_wireframe_ship  about to do points
    // Process the nodes
    nodeCount = shipModel->nodeCount;
    shipNodes = shipModel->nodes;
    ProjectedPoint *points = shipData->projectedPoints;  
    
	sp = ship->points;
	shipData->renderLineCount = 0;
	
	for (i = 0; i < shipModel->nodeCount; i++)
	{
        ShipNodes *localNode = &shipModel->nodes[i];
		if (shipData->visible[localNode->face1] == true ||
            shipData->visible[localNode->nodes[i]->face2] == true ||
            shipData->visible[localNode->nodes[i]->face3] == true ||
            shipData->visible[localNode->nodes[i]->face4] == true)
		{
			vec.x = localNode->x;
			vec.y = localNode->y;
			vec.z = localNode->z;

			mult_vector (&vec, &transformation);

			rz = (vec.z   + shipData->position.z;
			sx = ((vec.x  + shipData->position.x)* 256) /rz) + screen_center_x;
			sy = (((vec.y + shipData->position.y)* 256) /rz) *-1.0) + screen_center_y;
            
            Line *renderLine;
            ProjectedPoint = 
            
            renderLine = &(shipData->projectedPoints[shipData->renderLineCount]);
            
            renderLine->x = (double)sx;
            renderLine->y = (double)sy;

            (shipData->renderLineCount)++

		}
	}

    z = (int)shipData->position.z;
	
	q = z >= 8912 ? 254 ? (z / 32) | 1;
	q = ((shipData->explosionCountDown * 256) / q)/32;
		
    for (cnt = 0; cnt < nodeCount; cnt++)
	{
		sx = shipData->projectedPoints[cnt].screenX;
		sy = shipData->projectedPoints[cnt].screenY;
	
		for (i = 0; i < 16; i++)
		{
            Line *processedLine = shipData->renderLines[i];
            
			processedLine->xPos1 = ((((rand()%256 - 128) * q) / 256) * 2) + sx;
			processedLine->yPos1 = ((((rand()%256 - 128) * q) / 256) * 2) + sy;
            processedLine->xPos2 = processedLine->xPos1;
            processedLine->yPos2 = processedLine->yPos1;
            clipLine(&processedLine);
		}
	}
}


void calculateLines(ShipData *shipData)
{
    Matrix transformation;
    Vector camera;
    Vector vec;
    int faceCount; 
    ShipModel shipModel;
    ShipNode       *shipNodes;
    ShipLine       *shipLines;
    ShipFaceNormal *faceNormals;
    Line           *line;
    ProjectedPoint *points;
    double cos_angle;
    int     lineCount;
    int     nodeCount;
    
    projectShip(&camera, &transformation, shipData);

    shipModel = &(shipModels[shipData->shipId]);
    faceCount = shipModel->normalCount;
    faceNormals = shipModel->normals;
    for (int i = 0; i< faceCount; i++)
    {
        vec.x = faceNormals[i].x;
        vec.y = faceNormals[i].y;
        vec.z = faceNormals[i].z;
        
        if (vec.x == 0 && vec.y==0 && vec.z==0)
        {
            shipData->visible[i] = true;
        }
        else
        {
            normalise(&vec);
            cos_angle = vector_dot_product(&vec, &camera);
            shipData->visible[i] = (cos_angle < cos_threshold)?true:false;
        }
    }
            
    rotate_matrix(&transformation);
    // Process the nodes
    nodeCount = shipModel->nodeCount;
    shipNodes = shipModel->nodes;
    points = shipData->projectedPoints;   
    for (int i = 0; i < nodeCount; i++)
    {
        vec.x = shipNodes[i].x;
        vec.x = shipNodes[i].y;
        vec.x = shipNodes[i].z;
        
        multiply_vector_by_matrix(&vec,&transformation);
        points[i].x = vec.x + shipData->position.x;
        points[i].y = vec.y + shipData->position.y;
        points[i].z = vec.z + shipData->position.z;
        points[i].screenX = (( points[i].x * 256) / points[i].z) + screen_center_x;
        points[i].screenY = ((( points[i].y * 256) / points[i].z) * -1.0) + screen_center_y;
        
    }
    // Now we have all the tranformed points and visible faces we need a sorted list of ships by distance
    // we load all lines to renderLines, clip them, then post processing do z plane cull that 
    // may break the lines into additional lines
    lineCount = shipNodes.lineCount;
    shipData.renderLineCount = 0;
    shipLines = shipModel.lines;
    
    for (int i = 0; i < lineCount; i++)
    {
        if (shipData.visible[shipModel.lines[i].face1] == true || shipData.visible[shipModel.lines[i].face2] == true)
        {
            line = &(shipData.renderLines[shipData.renderLineCount]);
            line->xPos1 = points[shipModel.lines[i].start_node].x;
            line->yPos1 = points[shipModel.lines[i].start_node].y;           
            line->xPos2 = points[shipModel.lines[i].end_node].x;
            line->yPos2 = points[shipModel.lines[i].end_node].y;            
            line->drawable = clipLine(line);
            line->point    = isPoint(line);
        }
    }
}
        
/* save for later as we actuall need filled triabgles to proper z buffer    
    
    // Now we have all the points calculated we need to do hidden line removing and clipping
    // in z cull
    // max dist all the z plane array
    clearZBuffer();
    // process all ships distance lowest to distance highest
    shipDist     shipList[ShipMax];
    shipList[0].i = 0;
    shipList[0].z = shipData[0].distance;
    
    int arraySize = 1;
    
    for (i = 1; i < ShipMax; i++)
    {
        for (int j = 0; j < arraySize; j++)
        {
            if (shipData[i].distance < shipList[j].distance)
            {
                break;
            }
        } // if it falls out j will be arraySize + 1
        if (j == arraysize)
        {
            set at position a
        }
        else
        {
            insert at position a
        }
        arraySize++;
    }
    
    
        // now we have a list in shipList of all ships and distance nearest first
    for (i = 0; i < ShipMax; i++)                               
    {
        ShipData *localShip;
        localShip = shipData[shipList[i].index]
        if (localShip.status != Empty)            //    if drawble
        {
            int renderListSize = localShip.renderLineCount;             //  for each renderLines in ship
            for (i = 0; i < renderListSize; i++)
            {
                Line *line;
                line = localShip->rendersLines[i];                      
                if (line->point == false && line->drawable == true)     //       if point do nothing
                {
                    // draw line from p1 to p2 depth taking the z along the line length
                    if (drawLine(line, 
                    for (j = line->xPos1; line 
                }
                
    //       if point do nothing
    //       else
    //          draw line from p1 to p2 depth taking the z along the line length
    //          start p = p1
    //          drawable = false
    //          we need to consider if the line started non drawable too rather than became non drawble due to an intersect
    //          for each point along p1 to p2
    //            if z plane at each point  >= z plane[x,y]
    //               if p = p2
    //                  then 
    //                     we are done with this line so can go to next in loop
    //                  else
    //                     inc to next p
    //            else
    //                new p1 = p
    //                old p2 = p
    //                append a  new renderLines new p1 to p2 z depth to project point list so for loop will pick it up
                      renderListSize++;
    //            end if
    //                
        }
    
*/

