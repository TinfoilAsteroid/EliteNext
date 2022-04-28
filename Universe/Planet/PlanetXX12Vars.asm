;-- transmat0 --------------------------------------------------------------------------------------------------------------------------
; Note XX12 comes after as some logic in normal processing uses XX15 and XX12 combines
PBnKXX12xLo                 DB  0               ; XX12+0
PBnKXX12xSign               DB  0               ; XX12+1
PBnKXX12yLo                 DB  0               ; XX12+2
PBnKXX12ySign               DB  0               ; XX12+3
PBnKXX12zLo                 DB  0               ; XX12+4
PBnKXX12zSign               DB  0               ; XX12+5
PXX12Save                   DS  6
PXX12Save2                  DS  6
PXX12                       equ PBnKXX12xLo
varPXX12                    equ PBnKXX12xLo
; Repurposed XX12 when plotting lines
PBnkY2                      equ PXX12+0
PbnKy2Lo                    equ PXX12+0
PBnkY2Hi                    equ PXX12+1
PBnkDeltaXLo                equ PXX12+2
PBnkDeltaXHi                equ PXX12+3
PBnkDeltaYLo                equ PXX12+4
PBnkDeltaYHi                equ PXX12+5
PbnkGradient                equ PXX12+2
PBnkTemp1                   equ PXX12+2
PBnkTemp1Lo                 equ PXX12+2
PBnkTemp1Hi                 equ PXX12+3
PBnkTemp2                   equ PXX12+3
PBnkTemp2Lo                 equ PXX12+3
PBnkTemp2Hi                 equ PXX12+4
