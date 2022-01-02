;-- XX15 --------------------------------------------------------------------------------------------------------------------------
SBnKXScaled                 DB  0               ; XX15+0Xscaled
SBnKXScaledSign             DB  0               ; XX15+1xsign
SBnKYScaled                 DB  0               ; XX15+2yscaled
SBnKYScaledSign             DB  0               ; XX15+3ysign
SBnKZScaled                 DB  0               ; XX15+4zscaled
SBnKZScaledSign             DB  0               ; XX15+5zsign

SXX15                       equ SBnKXScaled
SXX15VecX                   equ SXX15
SXX15VecY                   equ SXX15+1
SXX15VecZ                   equ SXX15+2
SBnKXPoint                  equ SXX15
SBnKXPointLo                equ SXX15+0
SBnKXPointHi                equ SXX15+1
SBnKXPointSign              equ SXX15+2
SBnKYPoint                  equ SXX15+3
SBnKYPointLo                equ SXX15+3
SBnKYPointHi                equ SXX15+4
SBnKYPointSign              equ SXX15+5
