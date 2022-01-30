;-Rotation Matrix of Ship----------------------------------------------------------------------------------------------------------
; Rotation data is stored as lohi, but only 15 bits with 16th bit being  a sign bit. Note this is NOT 2'c compliment
UBnkrotmatSidevX            DW  0                       ; INWK +21
UBnkrotmatSidev             equ UBnkrotmatSidevX
UBnkrotmatSidevY            DW  0                       ; INWK +23
UBnkrotmatSidevZ            DW  0                       ; INWK +25
UBnkrotmatRoofvX            DW  0                       ; INWK +15
UBnkrotmatRoofv             equ UBnkrotmatRoofvX
UBnkrotmatRoofvY            DW  0                       ; INWK +17
UBnkrotmatRoofvZ            DW  0                       ; INWK +19
UBnkrotmatNosevX            DW  0                       ; INWK +9
UBnkrotmatNosev             EQU UBnkrotmatNosevX
UBnkrotmatNosevY            DW  0                       ; INWK +11
UBnkrotmatNosevZ            DW  0                       ; INWK +13
