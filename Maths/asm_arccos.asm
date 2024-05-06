;Calculate a = arccos (b a) where b is the sign and a is the value 
ArcCos:                 bit     7,b
                        jp      z,.PositiveTable
.NegativeTable:         ld      hl,ArcNegPosTable
                        jp      .LookupAngle
.PositiveTable:         ld      hl,ArcCosPosTable
.LookupAngle:           JumpIfAGTENusng 37, .NaN
                        add     hl,a
                        ld      a,(hl)
                        ClearCarryFlag
                        ret
.NaN:                   ld      a,$FF
                        SetCarryFlag
                        ret
