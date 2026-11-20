; -- The planet's size and colours (only the planet uses this). It also held the meridian / crater drawing's working
; variables (BLINE, the plot heaps, the sin / cos terms, STP, the planet type...), unused since the planets are solid:
; they are in Unused/Unused/universe_unused.asm
UnivCoreAIVarsMacro:        MACRO  prefix1?
prefix1?_Radius                     DB  0
; For planets, Colour 1 is main colour, Colour 2 is outer rim, Colour2Thickness its width in pixels (atmosphere)
prefix1?_Colour1                    DB 0
prefix1?_Colour2                    DB 0
prefix1?_Colour2Thickness           DB 0
                            ENDM

UnivPosVarsMacro:            MACRO  prefix1?
prefix1?_BnKxlo                     DB  0                       ; INWK+0
prefix1?_BnKxhi                     DB  0                       ; there are hi medium low as some times these are 24 bit
prefix1?_BnKxsgn                    DB  0                       ; INWK+2
prefix1?_BnKylo                     DB  0                       ; INWK+3 \ ylo
prefix1?_BnKyhi                     DB  0                       ; INWK+4 \ yHi
prefix1?_BnKysgn                    DB  0                       ; INWK +5
prefix1?_BnKzlo                     DB  0                       ; INWK +6
prefix1?_BnKzhi                     DB  0                       ; INWK +7
prefix1?_BnKzsgn                    DB  0                       ; INWK +8
prefix1?_CompassX                   DW  0
prefix1?_CompassY                   DW  0
prefix1?_RadarX                     DW  0
prefix1?_RadarY                     DW  0
prefix1?_BnkNormRoot                DS  3                       ; 3 bytes for normnalisation
prefix1?_BnkNormalX96               DW  0                       ; INWK +20 Normalised Position
prefix1?_BnKNormalY96               DW  0                       ; INWK +22 Normalised Position
prefix1?_BnkNormalZ96               DW  0                       ; INWK +24 Normalised Position
prefix1?_BnkNormalX                 DW  0                       ; INWK +26 Normalised Position
prefix1?_BnKNormalY                 DW  0                       ; INWK +28 Normalised Position
prefix1?_BnkNormalZ                 DW  0                       ; INWK +30 Normalised Positionprefix1?_BnKElipseCenterX           DW  0
prefix1?_BnKElipseCenterY           DW  0
prefix1?_BnKElipseRadiusU           DW  0
prefix1?_BnKElipseRadiusV           DW  0
                            ENDM

; Rotation data is stored as lohi, but only 15 bits with 16th bit being  a sign bit. Note this is NOT 2'c compliment
;-Rotation Matrix of Universe Object-----------------------------------------------------------------------------------------------
UnivRotationVarsMacro:      MACRO prefix1?
prefix1?_BnKrotmatSidevX            DW  0                       ; INWK +21
prefix1?_BnKrotmatSidev             equ prefix1?_BnKrotmatSidevX
prefix1?_BnKrotmatSidevY            DW  0                       ; INWK +23
prefix1?_BnKrotmatSidevZ            DW  0                       ; INWK +25
prefix1?_BnKrotmatRoofvX            DW  0                       ; INWK +15
prefix1?_BnKrotmatRoofv             equ prefix1?_BnKrotmatRoofvX
prefix1?_BnKrotmatRoofvY            DW  0                       ; INWK +17
prefix1?_BnKrotmatRoofvZ            DW  0                       ; INWK +19
prefix1?_BnKrotmatNosevX            DW  0                       ; INWK +9
prefix1?_BnKrotmatNosev             EQU prefix1?_BnKrotmatNosevX
prefix1?_BnKrotmatNosevY            DW  0                       ; INWK +11
prefix1?_BnKrotmatNosevZ            DW  0                       ; INWK +13
                            ENDM


XX15DefineMacro: MACRO   prefix1?
        
prefix1?_BnKXScaled                  DB  0               ; XX15+0Xscaled
prefix1?_BnKXScaledSign              DB  0               ; XX15+1xsign
prefix1?_BnKYScaled                  DB  0               ; XX15+2yscaled
prefix1?_BnKYScaledSign              DB  0               ; XX15+3ysign
prefix1?_BnKZScaled                  DB  0               ; XX15+4zscaled
prefix1?_BnKZScaledSign              DB  0               ; XX15+5zsign
prefix1?_XX1576                      DW  0    ; y2

prefix1?_XX15:                       equ prefix1?_BnKXScaled
prefix1?_XX15VecX:                   equ prefix1?_XX15
prefix1?_XX15VecY:                   equ prefix1?_XX15+1
prefix1?_XX15VecZ:                   equ prefix1?_XX15+2
prefix1?_BnKXPoint:                  equ prefix1?_XX15
prefix1?_BnKXPointLo:                equ prefix1?_XX15+0
prefix1?_BnKXPointHi:                equ prefix1?_XX15+1
prefix1?_BnKXPointSign:              equ prefix1?_XX15+2
prefix1?_BnKYPoint:                  equ prefix1?_XX15+3
prefix1?_BnKYPointLo:                equ prefix1?_XX15+3
prefix1?_BnKYPointHi:                equ prefix1?_XX15+4
prefix1?_BnKYPointSign:              equ prefix1?_XX15+5

prefix1?_XX1510                      EQU prefix1?_BnKXScaled    ; x1 as a 16-bit coordinate (x1_hi x1_lo)
prefix1?_XX1532                      EQU prefix1?_BnKYScaled   ; y1 as a 16-bit coordinate (y1_hi y1_lo)
prefix1?_XX1554                      EQU prefix1?_BnKZScaled   ; x2
prefix1?_XX1554p1                    EQU prefix1?_XX1554+1
prefix1?_XX15X1lo                    EQU prefix1?_XX1510
prefix1?_XX15X1hi                    EQU prefix1?_XX1510+1
prefix1?_XX15Y1lo                    EQU prefix1?_XX1532
prefix1?_XX15Y1hi                    EQU prefix1?_XX1532+1
prefix1?_XX15X2lo                    EQU prefix1?_XX1554
prefix1?_XX15X2hi                    EQU prefix1?_XX1554+1
prefix1?_XX15Y2lo                    EQU prefix1?_XX1210
prefix1?_XX15Y2hi                    EQU prefix1?_XX1210+1
prefix1?_XX15PlotX1                  EQU prefix1?_XX15
prefix1?_XX15PlotY1                  EQU prefix1?_XX15+1
prefix1?_XX15PlotX2                  EQU prefix1?_XX15+2
prefix1?_XX15PlotY2                  EQU prefix1?_XX15+3
            ENDM
            
XX12DefineMacro: MACRO   prefix1?
;-- transmat0 --------------------------------------------------------------------------------------------------------------------------
; Note XX12 comes after as some logic in normal processing uses XX15 and XX12 combines

prefix1?_XX1210                     EQU prefix1?_XX1576
prefix1?_XX12p1                     EQU prefix1?_XX1210+1
prefix1?_XX12                       EQU prefix1?_XX1210


prefix1?_BnKXX12xLo                 EQU prefix1?_XX12               ; XX12+0
prefix1?_BnKXX12xSign               EQU prefix1?_XX12+1   ; XX12+1
prefix1?_BnKXX12yLo                 EQU prefix1?_XX12+2   ; XX12+2
prefix1?_BnKXX12ySign               EQU prefix1?_XX12+3   ; XX12+3
prefix1?_BnKXX12zLo                 EQU prefix1?_XX12+4   ; XX12+4
prefix1?_BnKXX12zSign               EQU prefix1?_XX12+5   ; XX12+5
prefix1?_XX12Save                   DS  6
prefix1?_XX12Save2                  DS  6

prefix1?_varXX12                    EQU prefix1?_XX12
; Repurposed XX12 when plotting lines
prefix1?_BnkY2                      equ prefix1?_XX12+0
prefix1?_BnKy2Lo                    equ prefix1?_XX12+0
prefix1?_BnkY2Hi                    equ prefix1?_XX12+1
prefix1?_BnkDeltaXLo                equ prefix1?_XX12+2
prefix1?_BnkDeltaXHi                equ prefix1?_XX12+3
prefix1?_BnkDeltaYLo                equ prefix1?_XX12+4
prefix1?_BnkDeltaYHi                equ prefix1?_XX12+5
prefix1?_BnkGradient                equ prefix1?_XX12+2
prefix1?_BnkTemp1                   equ prefix1?_XX12+2
prefix1?_BnkTemp1Lo                 equ prefix1?_XX12+2
prefix1?_BnkTemp1Hi                 equ prefix1?_XX12+3
prefix1?_BnkTemp2                   equ prefix1?_XX12+3
prefix1?_BnkTemp2Lo                 equ prefix1?_XX12+3
prefix1?_BnkTemp2Hi                 equ prefix1?_XX12+4
                            ENDM

XX16DefineMacro: MACRO   prefix1?
;-- XX16 --------------------------------------------------------------------------------------------------------------------------
prefix1?_BnkTransmatSidevX          DW  0               ; XX16+0
prefix1?_BnkTransmatSidev           EQU prefix1?_BnkTransmatSidevX
prefix1?_BnkTransmatSidevY          DW 0                ; XX16+2
prefix1?_BnkTransmatSidevZ          DW 0                ; XX16+2
prefix1?_BnkTransmatRoofvX          DW 0
prefix1?_BnkTransmatRoofv           EQU prefix1?_BnkTransmatRoofvX
prefix1?_BnkTransmatRoofvY          DW 0                ; XX16+2
prefix1?_BnkTransmatRoofvZ          DW 0                ; XX16+2
prefix1?_BnkTransmatNosevX          DW 0
prefix1?_BnkTransmatNosev           EQU prefix1?_BnkTransmatNosevX
prefix1?_BnkTransmatNosevY          DW 0                ; XX16+2
prefix1?_BnkTransmatNosevZ          DW 0                ; XX16+2
prefix1?_BnkTransmatTransX          DW 0
prefix1?_BnkTransmatTransY          DW 0
prefix1?_BnkTransmatTransZ          DW 0
prefix1?_XX16                       equ prefix1?_BnkTransmatSidev
;-- XX16Inv --------------------------------------------------------------------------------------------------------------------------
prefix1?_BnkTransInvRow0x0          DW 0
prefix1?_BnkTransInvRow0x1          DW 0
prefix1?_BnkTransInvRow0x2          DW 0
prefix1?_BnkTransInvRow0x3          DW 0
prefix1?_BnkTransInvRow1y0          DW 0
prefix1?_BnkTransInvRow1y1          DW 0
prefix1?_BnkTransInvRow1y2          DW 0
prefix1?_BnkTransInvRow1y3          DW 0
prefix1?_BnkTransInvRow2z0          DW 0
prefix1?_BnkTransInvRow2z1          DW 0
prefix1?_BnkTransInvRow2z2          DW 0
prefix1?_BnkTransInvRow2z3          DW 0

prefix1?_XX16Inv                    equ prefix1?_BnkTransInvRow0x0
                            ENDM

XX18DefineMacro: MACRO   prefix1?
;-- XX18 --------------------------------------------------------------------------------------------------------------------------
prefix1?_BnkDrawCam0xLo             DB  0               ; XX18+0
prefix1?_BnkDrawCam0xHi             DB  0               ; XX18+1
prefix1?_BnkDrawCam0xSgn            DB  0               ; XX18+2
prefix1?_BnkDrawCam0x               equ prefix1?_BnkDrawCam0xLo
prefix1?_BnkDrawCam0yLo             DB  0               ; XX18+3
prefix1?_BnkDrawCam0yHi             DB  0               ; XX18+4
prefix1?_BnkDrawCam0ySgn            DB  0               ; XX18+5
prefix1?_BnkDrawCam0y               equ prefix1?_BnkDrawCam0yLo
prefix1?_BnkDrawCam0zLo             DB  0               ; XX18+6
prefix1?_BnkDrawCam0zHi             DB  0               ; XX18+7
prefix1?_BnkDrawCam0zSgn            DB  0               ; XX18+8
prefix1?_BnkDrawCam0z               equ prefix1?_BnkDrawCam0zLo
prefix1?_XX18                       equ prefix1?_BnkDrawCam0xLo
                            ENDM                            

XX25DefineMacro: MACRO   prefix1?
;-- XX25 --------------------------------------------------------------------------------------------------------------------------
prefix1?_BnKProjxLo                 DB  0
prefix1?_BnKProjxHi                 DB  0
prefix1?_BnKProjxSgn                DB  0
prefix1?_BnKProjx                   EQU prefix1?_BnKProjxLo
prefix1?_BnKProjyLo                 DB  0
prefix1?_BnKProjyHi                 DB  0
prefix1?_BnKProjySgn                DB  0
prefix1?_BnKProjy                   EQU prefix1?_BnKProjyLo
prefix1?_BnKProjzLo                 DB  0
prefix1?_BnKProjzHi                 DB  0
prefix1?_BnKProjzSgn                DB  0
prefix1?_BnKProjz                   EQU prefix1?_BnKProjzLo
prefix1?_XX25                       EQU prefix1?_BnKProjxLo
                            ENDM        
                            
CopyPosToXX15Macro: MACRO   prefix1?

prefix1?_CopyPosToXX15:    ld hl,prefix1?_Bnkxhi
                           ld de,prefix1?_BnkXScaled
                           ldi
                           ldi
                           inc hl ; skip to y high
                           ldi
                           ldi
                           inc hl ; skip to z hig
                           ldi
                           ldi
                           ret
                    ENDM        

CopyXX12ScaledToXX18Macro:  MACRO    prefix1?
prefix1?_CopyXX12ScaledToXX18:
prefix1?_CopyResultToDrawCam:    ld      hl, prefix1?_XX12
                                 ld      de, prefix1?_XX18
                                 ldi    ; X12+0 => XX18+0  Set XX18(2 0) = dot_sidev
                                 inc de ; skip to XX18+2 as it will be on XX18+1
                                 ldi    ; XX12+1 => XX18+2
                                 ldi    ; XX12+2 => XX18+3 Set XX12+1 => XX18+2
                                 inc de ; skip to XX18+5 as it will be on XX18+4
                                 ldi    ; XX12+3 => XX18+5
                                 ldi    ; XX12+4 => XX18+6 Set XX18(8 6) = dot_nosev
                                 inc de ; skip to XX18+8 as it will be on XX18+7
                                 ldi    ; XX12+5 => XX18+8
                                 ret
                            ENDM        
		
CopyXX12toXX15Macro:        MACRO    prefix1?     
prefix1?_CopyXX12toXX15:         ld      hl, prefix1?_BnkXX12xLo
                                 ld      de, prefix1?_XX18
                                 ldi      ; xlo
                                 ldi      ; xsg
                                 ldi      ; xlo
                                 ldi      ; xsg
                                 ldi      ; xlo
                                 ldi      ; xsg
                                 ret
                            ENDM        

InitialiseUniverseObjMacro: MACRO   prefix1?
prefix1?_InitRotMat:    ld      hl, 0
                        ld      (prefix1?_BnKrotmatSidevY),hl       ; set the zeroes
                        ld      (prefix1?_BnKrotmatSidevZ),hl       ; set the zeroes
                        ld      (prefix1?_BnKrotmatRoofvX),hl       ; set the zeroes
                        ld      (prefix1?_BnKrotmatRoofvZ),hl       ; set the zeroes
                        ld      (prefix1?_BnKrotmatNosevX),hl       ; set the zeroes
                        ld      (prefix1?_BnKrotmatNosevY),hl       ; set the zeroes
; Optimised as already have 0 in l
                        ld      h, $60	             				; 96 in hi byte
                        ld      (prefix1?_BnKrotmatSidevX),hl
                        ld      (prefix1?_BnKrotmatRoofvY),hl
; Optimised as already have 0 in l
                        ld      h, $E0					            ; -96 in hi byte which is +96 with hl bit 7 set
                        ld      (prefix1?_BnKrotmatNosevZ),hl
                        ret
                            ENDM
