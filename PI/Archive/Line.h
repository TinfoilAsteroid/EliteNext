#ifndef  LINE_H_
#define  LINE_H_
#include <stdbool.h>

#define screen_center_x 128
#define screen_center_y 64

#define clipX1 0
#define clipX2 255
#define clipY1 0
#define clipY2 127


typedef struct Line
{
        int     xPos1;
        int     yPos1;
       // double  zPos1; not needed unless we do filled
        int     xPos2;
        int     yPos2;
       // double  zPos2; not needed unless we do filled
        int x1Clipped;
        int y1Clipped;
        int x2Clipped;
        int y2Clipped;
        bool drawable;
        bool point;
}  Line;

Line remainingLine;

void initLine(Line *pLine);
void createLine(Line *pLine, int x1,int y1,int x2,int y2);
bool isPoint(Line *pLine);
bool clipLine(Line *pLine);
void clearZBuffer(int distance);
// we can't do z bufered yet as it would require filled shapes, so later
#endif