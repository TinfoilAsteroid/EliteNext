CopyFaceToXX12:         ld      a,(hl)                      ; get Normal byte 0                                                                    ;;;     if visibility (bits 4 to 0 of byte 0) > XX4
                        ld      b,a                         ; save sign bits to b
                        and     SignOnly8Bit
                        ld      (UBnkXX12xSign),a           ; write Sign bits to x sign                                                            ;;;
                        ld      a,b
                        sla     a                           ; move y sign to bit 7                                                                 ;;;   copy sign bits to XX12
                        ld      b,a        
                        and     SignOnly8Bit
                        ld      (UBnkXX12ySign),a           ;                                                                                      ;;;
                        ld      a,b
                        sla     a                           ; move y sign to bit 7                                                                 ;;;   copy sign bits to XX12
                        and     SignOnly8Bit
                        ld      (UBnkXX12zSign),a           ;                                                                                      ;;;
                        inc     hl                          ; move to X ccord
                        ld      a,(hl)                      ;                                                                                      ;;;   XX12 x,y,z lo = Normal[loop].x,y,z
                        ld      (UBnkXX12xLo),a                                                                                                    ;;;
                        inc     hl                                                                                                                 ;;;
                        ld      a,(hl)                      ;                                                                                      ;;;
                        ld      (UBnkXX12yLo),a                                                                                                    ;;;
                        inc     hl                                                                                                                 ;;;
                        ld      a,(hl)                      ;                                                                                      ;;;
                        ld      (UBnkXX12zLo),a     
                        ret
