
AnyMessagesMacro:       MACRO   NoMessageTarget
                        ld      a, (MessageCount)
                        and     a
                        jr      z, NoMessageTarget
                        ENDM
                        
AnyHyperSpaceMacro:     MACRO   NoMessageText                        
                        ld      hl,(InnerHyperCount)
                        ld      a,h
                        or      l
                        jr      z, NoMessageText
                        ENDM
                        