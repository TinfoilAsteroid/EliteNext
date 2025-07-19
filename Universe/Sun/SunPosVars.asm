;-Camera Position of Ship----------------------------------------------------------------------------------------------------------
SBnKxlo                     DB  0                       ; INWK+0
SBnKxhi                     DB  0                       ; there are hi medium low as some times these are 24 bit
SBnKxsgn                    DB  0                       ; INWK+2
SBnKylo                     DB  0                       ; INWK+3 \ ylo
SBnKyhi                     DB  0                       ; INWK+4 \ yHi
SBnKysgn                    DB  0                       ; INWK +5
SBnKzlo                     DB  0                       ; INWK +6
SBnKzhi                     DB  0                       ; INWK +7
SBnKzsgn                    DB  0                       ; INWK +8
SCompassX                   DW  0
SCompassY                   DW  0
SRadarX                     DW  0
SRadarY                     DW  0
SBnkNormRoot                DS  3                       ; 3 bytes for normnalisation
SBnkNormalX                 DW  0                       ; Normalised Position
SBnKNormalY                 DW  0                       ; Normalised Position
SBnkNormalZ                 DW  0                       ; Normalised Position