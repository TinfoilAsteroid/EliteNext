#include "Line.h"
 

void initLine(Line *pLine)
{
    pLine->xPos1 = 0;
    pLine->yPos1 = 0;
    pLine->xPos2 = 0;
    pLine->yPos1 = 0;
    pLine->drawable  = clipLine(pLine);
    pLine->point     = isPoint(pLine);
}

void createLine(Line *pLine, int x1,int y1,int x2,int y2)
{
    pLine->xPos1 = x1;
    pLine->yPos1 = y1;
    pLine->xPos2 = x2;
    pLine->yPos2 = y2;        
    pLine->drawable = clipLine(pLine);
    pLine->point    = isPoint(pLine);
}
        

bool isPoint(Line *pLine)
{
    if (pLine->x1Clipped == pLine->x2Clipped && pLine->y1Clipped == pLine->y2Clipped)
    {
        return true;
    }
    else
    {
        return false;
    }
}

bool clipLine(Line *pLine)
{
    double t0 = 0.0;
    double t1 = 1.0;
    double xDelta = pLine->xPos2 - pLine->xPos1;
    double yDelta = pLine->yPos2 - pLine->yPos1;
    double p,q,r;
    /* Fast eliminate if there is no work to do */
    if  (pLine->xPos1 >= clipX1 && pLine->xPos1 <= clipX2 && 
         pLine->xPos2 >= clipX1 && pLine->xPos2 <= clipX2 &&
         pLine->yPos1 >= clipY1 && pLine->yPos1 <= clipY2 &&
         pLine->yPos2 >= clipY2 && pLine->yPos2 <= clipY2)
    {
        pLine->x1Clipped = pLine->xPos1;
        pLine->y1Clipped = pLine->yPos1;
        pLine->x2Clipped = pLine->xPos2;
        pLine->y2Clipped = pLine->yPos2;
        return      true;
    }
    else
    {
        for ( int edge = 0; edge < 4; edge++)
        {
            if (edge==0) {  p = -xDelta;    q = -(clipX1-pLine->xPos1); }
            if (edge==1) {  p =  xDelta;    q =  (clipX2-pLine->xPos2); }
            if (edge==2) {  p = -yDelta;    q = -(clipY1-pLine->yPos1); }
            if (edge==3) {  p =  yDelta;    q =  (clipY2-pLine->yPos2); }   
            r = q/p;
            if(p==0 && q<0) return false;   // Don't draw line at all. (parallel line outside)

            if(p<0) {
                if(r>t1)
                {
                    return false;         // Don't draw line at all.
                }
                else
                {
                    if(r>t0)
                    {
                        t0=r;            // Line is clipped
                    }
                }
            } 
            else
            {
                if(p>0)
                {
                    if(r<t0)
                    {
                        return false;      // Don't draw line at all.
                    }
                    else
                    {
                        if(r<t1)
                        {
                            t1=r;         // Line is clipped
                        }
                    }
                }
            }
        }

        pLine->x1Clipped = pLine->xPos1 + t0*xDelta;
        pLine->y1Clipped = pLine->xPos2 + t0*yDelta;
        pLine->x2Clipped = pLine->yPos1 + t1*xDelta;
        pLine->y2Clipped = pLine->yPos2 + t1*yDelta;
        return  true;
    }
}