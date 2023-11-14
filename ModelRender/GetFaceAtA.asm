;--------------------------------------------------------------------------------------------------------
GetFaceAtA:         MACRO
                    ld          hl,UBnkFaceVisArray
                    add         hl,a
                    ld          a,(hl)                              ; get face visibility
                    ENDM
                    