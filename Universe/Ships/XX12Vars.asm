;-- transmat0 --------------------------------------------------------------------------------------------------------------------------
; Note XX12 comes after as some logic in normal processing uses XX15 and XX12 combines
UBnkXX12xLo                 DB  0               ; XX12+0
UBnkXX12xSign               DB  0               ; XX12+1
UBnkXX12yLo                 DB  0               ; XX12+2
UBnkXX12ySign               DB  0               ; XX12+3
UBnkXX12zLo                 DB  0               ; XX12+4
UBnkXX12zSign               DB  0               ; XX12+5
XX12Save                    DS  6
XX12Save2                   DS  6
XX12                        equ UBnkXX12xLo
varXX12                     equ UBnkXX12xLo
; Repurposed XX12 when plotting lines
UBnkY2                      equ XX12+0
UBnky2Lo                    equ XX12+0
UBnkY2Hi                    equ XX12+1
UBnkDeltaXLo                equ XX12+2
UBnkDeltaXHi                equ XX12+3
UBnkDeltaYLo                equ XX12+4
UBnkDeltaYHi                equ XX12+5
UBnkGradient                equ XX12+2
UBnkTemp1                   equ XX12+2
UBnkTemp1Lo                 equ XX12+2
UBnkTemp1Hi                 equ XX12+3
UBnkTemp2                   equ XX12+3
UBnkTemp2Lo                 equ XX12+3
UBnkTemp2Hi                 equ XX12+4
