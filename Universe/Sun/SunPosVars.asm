;-Camera Position of Ship----------------------------------------------------------------------------------------------------------


SBnKxlo                     DB  0                       ; INWK+ 0
SBnKxhi                     DB  0                       ; there are hi medium low as some times these are 24 bit
SBnKxsgn                    DB  0                       ; INWK +2
SBnKylo                     DB  0                       ; INWK +3 \ ylo
SBnKyhi                     DB  0                       ; INWK +4 \ yHi
SBnKysgn                    DB  0                       ; INWK +5
SBnKzlo                     DB  0                       ; INWK +6
SBnKzhi                     DB  0                       ; INWK +7
SBnKzsgn                    DB  0                       ; INWK +8
SCompassX                   DW  0                       ; INWK +9
SCompassY                   DW  0                       ; INWK +11 (0A)
SRadarX                     DW  0                       ; INWK +13 (0C)
SRadarY                     DW  0                       ; INWK +15 (0F)
SBnkNormRoot                DS  3                       ; INWK +17 (11) 3 bytes for normnalisation
SBnkNormalX96               DW  0                       ; INWK +20 (14) Normalised Position
SBnKNormalY96               DW  0                       ; INWK +22 (16) Normalised Position
SBnkNormalZ96               DW  0                       ; INWK +24 (18) Normalised Position
SBnkNormalX                 DW  0                       ; INWK +26 (1A) Normalised Position
SBnKNormalY                 DW  0                       ; INWK +28 (1C) Normalised Position
SBnkNormalZ                 DW  0                       ; INWK +30 (1E) Normalised Position