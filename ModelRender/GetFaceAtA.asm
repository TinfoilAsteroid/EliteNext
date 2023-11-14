;--------------------------------------------------------------------------------------------------------
GetFaceAtA:         MACRO
                    ld          hl,UbnkFaceVisArray
                    add         hl,a
                    ld          a,(hl)                              ; get face visibility
                    ENDM
                    