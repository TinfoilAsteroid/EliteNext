CopyFaceToXX15:         ld      a,(hl)                      ; get Normal byte 0                                                                    ;;;     if visibility (bits 4 to 0 of byte 0) > XX4
                        ld      b,a                                                    ;;;      
                        and     $80
                        ld      (UBnkXScaledSign),a           ; write Sign bits to x sign                                                            ;;;
                        ld      a,b
                        sla     a                           ; move y sign to bit 7                                                                 ;;;   copy sign bits to XX12
                        ld      b,a
                        and     $80
                        ld      (UBnkYScaledSign),a           ;                                                                                      ;;;
                        ld      a,b
                        sla     a                           ; move y sign to bit 7                                                                 ;;;   copy sign bits to XX12
                        and     $80
                        ld      (UBnkZScaledSign),a           ;                                                                                      ;;;
                        inc     hl                          ; move to X ccord
                        ld      a,(hl)                      ;                                                                                      ;;;   XX12 x,y,z lo = Normal[loop].x,y,z
                        ld      (UBnkXScaled),a                                                                                                    ;;;
                        inc     hl                                                                                                                 ;;;
                        ld      a,(hl)                      ;                                                                                      ;;;
                        ld      (UBnkYScaled),a                                                                                                    ;;;
                        inc     hl                                                                                                                 ;;;
                        ld      a,(hl)                      ;                                                                                      ;;;
                        ld      (UBnkZScaled),a     
                        ret
                        