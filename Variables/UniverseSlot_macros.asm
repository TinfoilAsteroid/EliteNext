
AddJunkCount:           MACRO
                        ld      hl,JunkCount
                        inc     (hl)
                        ENDM

SubJunkCount:           MACRO
                        ld      hl,JunkCount
                        dec     (hl)
                        ENDM
                        
TestRoomForJunk:        MACRO   Target
                        ld      a,3
                        JumpIfALTMemusng    JunkCount, Target
                        ENDM
                        