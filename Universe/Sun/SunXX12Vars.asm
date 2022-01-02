;-- transmat0 --------------------------------------------------------------------------------------------------------------------------
; Note XX12 comes after as some logic in normal processing uses XX15 and XX12 combines
SBnKXX12xLo                 DB  0               ; XX12+0
SBnKXX12xSign               DB  0               ; XX12+1
SBnKXX12yLo                 DB  0               ; XX12+2
SBnKXX12ySign               DB  0               ; XX12+3
SBnKXX12zLo                 DB  0               ; XX12+4
SBnKXX12zSign               DB  0               ; XX12+5
SXX12Save                   DS  6
SXX12Save2                  DS  6
SXX12                       equ SBnKXX12xLo
varSXX12                    equ SBnKXX12xLo
; Repurposed XX12 when plotting lines
SBnkY2                      equ SXX12+0
SbnKy2Lo                    equ SXX12+0
SBnkY2Hi                    equ SXX12+1
SBnkDeltaXLo                equ SXX12+2
SBnkDeltaXHi                equ SXX12+3
SBnkDeltaYLo                equ SXX12+4
SBnkDeltaYHi                equ SXX12+5
SbnkGradient                equ SXX12+2
SBnkTemp1                   equ SXX12+2
SBnkTemp1Lo                 equ SXX12+2
SBnkTemp1Hi                 equ SXX12+3
SBnkTemp2                   equ SXX12+3
SBnkTemp2Lo                 equ SXX12+3
SBnkTemp2Hi                 equ SXX12+4
