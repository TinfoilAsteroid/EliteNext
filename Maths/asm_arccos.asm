;Calculate a = arccos (a)
ArcCos:                 and     a
                        jp      p,.PositiveTable
.NegativeTable:         ld      hl,ArcNegPosTable
                        neg
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
