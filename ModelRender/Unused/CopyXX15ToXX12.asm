CopyXX15ToXX12:         ld		hl,XX15
                        ld      de,XX12
                        ld      bc,6
                        ldir
                        ret



CopyXX15ToXX15Save:     ld		hl,XX15
                        ld      de,XX15Save
                        ld      bc,6
                        ldir
                        ret

CopyXX15SaveToXX15:     ld		hl,XX15Save
                        ld      de,XX15
                        ld      bc,6
                        ldir
                        ret

CopyXX15ToXX15Save2:    ld		hl,XX15
                        ld      de,XX15Save2
                        ld      bc,6
                        ldir
                        ret

CopyXX15Save2ToXX15:    ld		hl,XX15Save2
                        ld      de,XX15
                        ld      bc,6
                        ldir
                        ret
