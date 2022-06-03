.ReducePlayerECM:       ld      a,(PlayerECMActiveCount)
                        and     a
                        jp      z, .DonePlayerECM
                        dec     a
                        ld      (PlayerECMActiveCount),a
                        ld      a,(PlayerEnergy)
                        and     a
                        jp      z, .DonePlayerECM
                        dec     a
                        ld      (PlayerEnergy),a
.DonePlayerECM:         
.ReduceCommonECM:       ld      a,(ECMCountDown)
                        and     a
                        jp      z, .DoneCommonECM
                        dec     a
                        ld      (ECMCountDown),a
.DoneCommonECM:                        
