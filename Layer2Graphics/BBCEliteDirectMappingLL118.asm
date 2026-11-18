        DEFINE DEBUG_6502_LINE_CLIPPING             
        IFDEF DEBUG_6502_LINE_CLIPPING
                        
XX1510      DW 0    ; x1 as a 16-bit coordinate (x1_hi x1_lo)
XX1532      DW 0    ; y1 as a 16-bit coordinate (y1_hi y1_lo)
Tvar        DB 0    ; The gradient of slope ; 0 if it's a shallow slope (DX > DY) ; &FF if it's a steep slope (DY > DX)
                    ; Returns:  XX15        m         x1 as an 8-bit coordinate XX15+2               y1 as an 8-bit coordinate
Qvar        DB 0
Rvar        DB 0    ; general purpose for calcs  Paired with S must be done this way round for SUBHeightFromY1 etc to work
Svar        DB 0    ; sign variable    
SRvarPair   EQU Rvar                
Xreg        DB 0 
Yreg        DB 0
YXregPair   EQU Xreg

ADDYXRegtoY1:       ld      bc,(YXregPair)          ; Set y1 = y1 + (Y X)
                    ld      hl,(XX1532)
                    ClearCarryFlag                
                    adc     hl,bc
                    ld      (XX1532),hl
                    ret

ADDYXRegtoX1:       ld      bc,(YXregPair)          ; Set x1 = x1 + (Y X)
                    ld      hl,(XX1510)
                    ClearCarryFlag                
                    adc     hl,bc
                    ld      (XX1510),hl
                    ret

SUBBCFromY1:        ld      hl,(XX1532)             ; Set (S R) = (y1_hi y1_lo) - BC where BC can be say screen height 
                    ClearCarryFlag                 
                    sbc     hl,bc
                    ld      (SRvarPair),hl
                    ret

AddSRToYX:          ld      hl,(YXregPair)
                    ld      de,(SRvarPair)
                    ClearCarryFlag
                    adc     hl,de
                    ld      (YXregPair),hl
                    ret

        ENDIF