;-- XX15 --------------------------------------------------------------------------------------------------------------------------
UBnkXScaled                 DB  0               ; XX15+0Xscaled
UBnkXScaledSign             DB  0               ; XX15+1xsign
UBnkYScaled                 DB  0               ; XX15+2yscaled
UBnkYScaledSign             DB  0               ; XX15+3ysign
UBnkZScaled                 DB  0               ; XX15+4zscaled
UBnkZScaledSign             DB  0               ; XX15+5zsign

XX15                        equ UBnkXScaled
XX15VecX                    equ XX15
XX15VecY                    equ XX15+1
XX15VecZ                    equ XX15+2
UbnkXPoint                  equ XX15
UbnkXPointLo                equ XX15+0
UbnkXPointHi                equ XX15+1
UbnkXPointSign              equ XX15+2
UbnkYPoint                  equ XX15+3
UbnkYPointLo                equ XX15+3
UbnkYPointHi                equ XX15+4
UbnkYPointSign              equ XX15+5
; Repurposed XX15 pre clip plines
UbnkPreClipX1               equ XX15+0
UbnkPreClipY1               equ XX15+2
UbnkPreClipX2               equ XX15+4
UbnkPreClipY2               equ XX15+6
; Repurposed XX15 post clip lines
UBnkNewX1                   equ XX15+0
UBnkNewY1                   equ XX15+1
UBnkNewX2                   equ XX15+2
UBnkNewY2                   equ XX15+3
; Repurposed XX15
regXX15fx                   equ UBnkXScaled
regXX15fxSgn                equ UBnkXScaledSign
regXX15fy                   equ UBnkYScaled
regXX15fySgn                equ UBnkYScaledSign
regXX15fz                   equ UBnkZScaled
regXX15fzSgn                equ UBnkZScaledSign
; Repurposed XX15
varX1                       equ UBnkXScaled       ; Reused, verify correct position
varY1                       equ UBnkXScaledSign   ; Reused, verify correct position
varZ1                       equ UBnkYScaled       ; Reused, verify correct position
; After clipping the coords are two 8 bit pairs
UBnkPoint1Clipped           equ UBnkXScaled
UBnkPoint2Clipped           equ UBnkYScaled
; Repurposed XX15 when plotting lines
; Repurposed XX15 before calling clip routine
UBnkX1                      equ XX15
UBnKx1Lo                    equ XX15
UBnKx1Hi                    equ XX15+1
UBnkY1                      equ XX15+2
UbnKy1Lo                    equ XX15+2
UBnkY1Hi                    equ XX15+3
UBnkX2                      equ XX15+4
UBnkX2Lo                    equ XX15+4
UBnkX2Hi                    equ XX15+5
