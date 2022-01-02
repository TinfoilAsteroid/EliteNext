;-Rotation Matrix of Ship----------------------------------------------------------------------------------------------------------
; Rotation data is stored as lohi, but only 15 bits with 16th bit being  a sign bit. Note this is NOT 2'c compliment
SBnKrotmatSidevX            DW  0                       ; INWK +21
SBnKrotmatSidev             equ SBnKrotmatSidevX
SBnKrotmatSidevY            DW  0                       ; INWK +23
SBnKrotmatSidevZ            DW  0                       ; INWK +25
SBnKrotmatRoofvX            DW  0                       ; INWK +15
SBnKrotmatRoofv             equ SBnKrotmatRoofvX
SBnKrotmatRoofvY            DW  0                       ; INWK +17
SBnKrotmatRoofvZ            DW  0                       ; INWK +19
SBnKrotmatNosevX            DW  0                       ; INWK +9
SBnKrotmatNosev             EQU SBnKrotmatNosevX
SBnKrotmatNosevY            DW  0                       ; INWK +11
SBnKrotmatNosevZ            DW  0                       ; INWK +13
