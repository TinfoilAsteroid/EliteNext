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
UBnkXPoint                  equ XX15
UBnkXPointLo                equ XX15+0
UBnkXPointHi                equ XX15+1
UBnkXPointSign              equ XX15+2
UBnkYPoint                  equ XX15+3
UBnkYPointLo                equ XX15+3
UBnkYPointHi                equ XX15+4
UBnkYPointSign              equ XX15+5
; Repurposed XX15 pre clip plines
UBnkPreClipX1               equ XX15+0
UBnkPreClipY1               equ XX15+2
UBnkPreClipX2               equ XX15+4
UBnkPreClipY2               equ XX15+6
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
UBnkx1Lo                    equ XX15
UBnkx1Hi                    equ XX15+1
UBnkY1                      equ XX15+2
UBnky1Lo                    equ XX15+2
UBnkY1Hi                    equ XX15+3
UBnkX2                      equ XX15+4
UBnkX2Lo                    equ XX15+4
UBnkX2Hi                    equ XX15+5
