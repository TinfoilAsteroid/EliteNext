
RotateXX15ByTransMatXX16:
                        ld      hl,UBnkTransmatSidevX               ; process orientation matrix row 0
                        call    XX12ProcessOneRow
                        ld      b,a                                 ; get 
                        ld      a,l
                        or      b
                        ld      (UBnkXX12xSign),a                   ; a = result with sign in bit 7
                        ld      a,l
                        ld      (UBnkXX12xLo),a                     ; that is result done for

                        ld      hl,UBnkTransmatRoofvX               ; process orientation matrix row 0
                        call    XX12ProcessOneRow
                        ld      b,a                                 ; get 
                        ld      a,l
                        or      b
                        ld      (UBnkXX12ySign),a                   ; a = result with sign in bit 7
                        ld      a,l
                        ld      (UBnkXX12yLo),a                     ; that is result done for
                 
                        ld      hl,UBnkTransmatNosevX               ; process orientation matrix row 0
                        call    XX12ProcessOneRow
                        ld      b,a                                 ; get 
                        ld      a,l
                        or      b
                        ld      (UBnkXX12zSign),a                   ; a = result with sign in bit 7
                        ld      a,l
                        ld      (UBnkXX12zLo),a                     ; that is result done for
                        ret
