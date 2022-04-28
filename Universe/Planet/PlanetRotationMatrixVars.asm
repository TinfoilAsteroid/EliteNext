;-Rotation Matrix of Ship----------------------------------------------------------------------------------------------------------
; Rotation data is stored as lohi, but only 15 bits with 16th bit being  a sign bit. Note this is NOT 2'c compliment
PBnKrotmatSidevX            DW  0                       ; INWK +21
PBnKrotmatSidev             equ PBnKrotmatSidevX
PBnKrotmatSidevY            DW  0                       ; INWK +23
PBnKrotmatSidevZ            DW  0                       ; INWK +25
PBnKrotmatRoofvX            DW  0                       ; INWK +15
PBnKrotmatRoofv             equ PBnKrotmatRoofvX
PBnKrotmatRoofvY            DW  0                       ; INWK +17
PBnKrotmatRoofvZ            DW  0                       ; INWK +19
PBnKrotmatNosevX            DW  0                       ; INWK +9
PBnKrotmatNosev             EQU PBnKrotmatNosevX
PBnKrotmatNosevY            DW  0                       ; INWK +11
PBnKrotmatNosevZ            DW  0                       ; INWK +13
