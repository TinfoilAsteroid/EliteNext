; -- AI Core data
UnivCoreAIVarsMacro:        MACRO  prefix1?
prefix1?_BnKRotXCounter             DB  0                       ; INWK +29
prefix1?_BnKRotZCounter             DB  0                       ; INWK +30
prefix1?_BnkCam0yLo                 DB  0                       ; INWK +33 ????
prefix1?_BnkCam0yHi                 DB  0                       ; INWK +34?????
prefix1?_BnKShipType                DB  0
        
; Used to make 16 bit reads a little cleaner in source code
prefix1?_BnKzPoint                  DS  3
prefix1?_BnKzPointLo                equ prefix1?_BnKzPoint
prefix1?_BnKzPointHi                equ prefix1?_BnKzPoint+1
prefix1?_BnKzPointSign              equ prefix1?_BnKzPoint+2

; Used for medridan drawing routines
prefix1?_BnKCx                      DW  0
prefix1?_BnKCxSign                  EQU prefix1?_BnKCx+1
prefix1?_BnKCy                      DW  0
prefix1?_BnKCySign                  EQU prefix1?_BnKCy+1
prefix1?_BnKUx                      DW  0
prefix1?_BnKUxSign                  EQU prefix1?_BnKUx+1
prefix1?_BnKUy                      DW  0
prefix1?_BnKUySign                  EQU prefix1?_BnKUy+1
prefix1?_BnKVx                      DW  0
prefix1?_BnKVxSign                  EQU prefix1?_BnKVx+1
prefix1?_BnKVy                      DW  0
prefix1?_BnKVySign                  EQU prefix1?_BnKVy+1
prefix1?_BnKSinCNT2                 DB  0
prefix1?_BnKSinCNT2Sign             DB  0
prefix1?_BnKCosCNT2                 DB  0
prefix1?_BnKCosCNT2Sign             DB  0
prefix1?_BnKUxCos                   DB  0
prefix1?_BnKUxCosSign               DB  0
prefix1?_BnKUyCos                   DB  0
prefix1?_BnKUyCosSign               DB  0
prefix1?_BnKVxSin                   DB  0
prefix1?_BnKVxSinSign               DB  0
prefix1?_BnKVySin                   DB  0
prefix1?_BnKVySinSign               DB  0
prefix1?_BnKVxVySinSign             DB  0
prefix1?_BnKUxUyCosSign             DB  0
prefix1?_BnKUxCosAddVxSin           DW  0
prefix1?_BnKUyCosSubVySin           DW  0
prefix1?_BnKAngle                   DB  0
s
        
; General local variables used in universe object
prefix1?_BnKTGT                     DB  0
prefix1?_BnKSTP                     DB  0
prefix1?_BnKLSP                     DS  50              ; move to planet or L2 code ?
prefix1?_BnKCNT                     DB  0               ; 93
prefix1?_BnKCNT2                    DB  0               ; 93
; Replaced LSX2 and LSY2 with plot heaps of 64 x 2 bytes each + 1 pair for initial point
    IFDEF MERIDANLINEDEBUG
prefix1?_BnKPlotXHeap               DS  $82			   ; &0EC0	    \ LSX2 bline buffer size?
prefix1?_BnKPlotYHeap               DS  $82            ; &0F0E	    \ LSY2
    ENDIF
prefix1?_BnKPlotIndex               DB  0
    DISPLAY "TODO can we remove this and just use BnkCNT = 0 as the same thing?"
prefix1?_BnKFlag					DB  0

; Post clipping the results are now 8 bit
prefix1?_BnKVisibility              DB  0               ; replaces general purpose xx4 in renderingW
prefix1?_BnKProjectedY              DB  0
prefix1?_BnKProjectedX              DB  0
prefix1?_BnKProjected               equ prefix1?_BnKProjectedY  ; resultant projected position
prefix1?_XX15Save                   DS  8
prefix1?_XX15Save2                  DS  8
prefix1?_Radius                     DB  0
; Used when drawing curves for the end value from previous calls to BLINE
; held as 16 bit values pre clipping
prefix1?_PrevXPos                   DW 0
prefix1?_PrevYPos                   DW 0
prefix1?_NewXPos                    DW 0
prefix1?_NewYPos                    DW 0
                            
; Colouration
; For planets, Colour 1 is main colour, Colour 2 is outer rim
; if we are going to do outer rim then may have colour thickeness as number of pixels to simulat atmosphere
prefix1?_Colour1                    DB 0
prefix1?_Colour2                    DB 0
prefix1?_Colour2Thickness           DB 0
;        -- _pl(prf .. "Radius                     DW  0
;        -- _pl(prf .. "RadiusHigh                 equ prefix1?_Radius+1
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
prefix1?_BnKElipseCenterX           DW  0
prefix1?_BnKElipseCenterY           DW  0
prefix1?_BnKElipseRadiusU           DW  0
prefix1?_BnKElipseRadiusV           DW  0
                            ENDM
                            
UnivModelVarsMacro:         MACRO prefix1?
prefix1?_BnKFaceVisArray            DS FaceArraySize            ; XX2 Up to 16 faces this may be normal list, each entry is controlled by bit 7, 1 visible, 0 hidden
; Node array holds the projected to screen position regardless of if its clipped or not
; When we use traingles we can cheat a bit on clipping as all lines will be horizontal so clipping is much simplified
prefix1?_BnKNodeArray               DS NodeArraySize * 4        ; XX3 Holds the points as an array, its an array not a heap
prefix1?_BnKNodeArray2              DS NodeArraySize * 4        ; XX3 Holds the points as an array, its an array not a heap
prefix1?_BnKLineArray               DS LineArraySize * 8        ; XX19 Holds the clipped line details
; ONLY IF TESTING SOLID FILL prefix1?_BnKTriangleOverspill       DS TraingleArraySize * 4    ; jsut a padding for testing
prefix1?_BnKLinesHeapMax            EQU $ - prefix1?_BnKLineArray
prefix1?_BnKTraingleArray           EQU prefix1?_BnKLineArray           ; We can use the line array as we draw lines or traingles
prefix1?_BnKEdgeProcessedList DS EdgeHeapSize
; Array current Lengths
prefix1?_BnKFaceVisArrayLen         DS 1
prefix1?_BnKNodeArrayLen            DS 1
prefix1?_BnKLineArrayLen            DS 1                        ; total number of lines loaded to array 
prefix1?_BnKLineArrayBytes          DS 1                        ; total number of bytes loaded to array  = array len * 4
prefix1?_XX20                       equ prefix1?_BnKLineArrayLen
varprefix1?_XX20                    equ prefix1?_BnKLineArrayLen

prefix1?_BnKEdgeHeapSize            DS 1
prefix1?_BnKEdgeHeapBytes           DS 1
prefix1?_BnKLinesHeapLen            DS 1
prefix1?_BnKEdgeHeapCounter         DS 1
prefix1?_BnKEdgeRadius              DS 1
prefix1?_BnKEdgeShipType            DS 1
prefix1?_BnKEdgeExplosionType       DS 1

; Lines
prefix1?_BnKXX19                    DS  3
                            ENDM


ShipDataMacro:              MACRO prefix1?
prefix1?_BnKHullCopy                DS  ShipDataLength
prefix1?_ScoopDebrisAddr            equ prefix1?_BnKHullCopy + ScoopDebrisOffset     
prefix1?_MissileLockLoAddr          equ prefix1?_BnKHullCopy + MissileLockLoOffset   
prefix1?_MissileLockHiAddr          equ prefix1?_BnKHullCopy + MissileLockHiOffset   
prefix1?_EdgeAddyAddr               equ prefix1?_BnKHullCopy + EdgeAddyOffset        
prefix1?_LineX4Addr                 equ prefix1?_BnKHullCopy + LineX4Offset      
prefix1?_GunVertexAddr              equ prefix1?_BnKHullCopy + GunVertexOffset       
prefix1?_ExplosionCtAddr            equ prefix1?_BnKHullCopy + ExplosionCtOffset    
prefix1?_VertexCountAddr            equ prefix1?_BnKHullCopy + VertexCountOffset    
prefix1?_VertexCtX6Addr             equ prefix1?_BnKHullCopy + VertexCtX6Offset  
prefix1?_EdgeCountAddr              equ prefix1?_BnKHullCopy + EdgeCountOffset       
prefix1?_BountyLoAddr               equ prefix1?_BnKHullCopy + BountyLoOffset        
prefix1?_BountyHiAddr               equ prefix1?_BnKHullCopy + BountyHiOffset        
prefix1?_FaceCtX4Addr               equ prefix1?_BnKHullCopy + FaceCtX4Offset        
prefix1?_DotAddr                    equ prefix1?_BnKHullCopy + DotOffset             
prefix1?_EnergyAddr                 equ prefix1?_BnKHullCopy + EnergyOffset      
prefix1?_SpeedAddr                  equ prefix1?_BnKHullCopy + SpeedOffset           
prefix1?_FaceAddyAddr               equ prefix1?_BnKHullCopy + FaceAddyOffset        
prefix1?_QAddr                      equ prefix1?_BnKHullCopy + QOffset               
prefix1?_LaserAddr                  equ prefix1?_BnKHullCopy + LaserOffset           
prefix1?_VerticesAddyAddr           equ prefix1?_BnKHullCopy + VerticiesAddyOffset  
prefix1?_ShipTypeAddr               equ prefix1?_BnKHullCopy + ShipTypeOffset       
prefix1?_ShipNewBitsAddr            equ prefix1?_BnKHullCopy + ShipNewBitsOffset    
prefix1?_ShipAIFlagsAddr            equ prefix1?_BnKHullCopy + ShipAIFlagsOffset
prefix1?_ShipECMFittedChanceAddr    equ prefix1?_BnKHullCopy + ShipECMFittedChanceOffset
prefix1?_ShipSolidFlagAddr          equ prefix1?_BnKHullCopy + ShipSolidFlagOffset
prefix1?_ShipSolidFillAddr          equ prefix1?_BnKHullCopy + ShipSolidFillOffset
prefix1?_ShipSolidLenAddr           equ prefix1?_BnKHullCopy + ShipSolidLenOffset
                        ENDM
                        
; Now this will mean some special coding for the copy from model to univ bank
ShipModelDataMacro:         MACRO prefix1?
prefix1?_BnKHullVerticies           DS  40 * 6              ; largetst is trasnport type 10 at 37 vericies so alows for 40 * 6 Bytes  = 
prefix1?_BnKHullEdges               DS  50 * 4              ; ype 10 is 46 edges so allow 50
prefix1?_BnKHullNormals             DS  20 * 4              ; type 10 is 14 edges so 20 to be safe
    IFDEF SOLIDHULLTEST
prefix1?_BnKHullSolid               DS  100 * 4             ; Up to 100 triangles (May optimise so only loads non hidden faces later
    ENDIF
prefix1?_OrthagCountdown             DB  12
prefix1?_BnKShipCopy                equ Sprefix1?__BnKHullVerticies               ; Buffer for copy of ship data, for speed will copy to a local memory block, Cobra is around 400 bytes on creation of a new ship so should be plenty
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
                        ;ld      hl,1
                        ld      (prefix1?_BnKrotmatSidevX),hl
                        ld      (prefix1?_BnKrotmatRoofvY),hl
; Optimised as already have 0 in l
                        ld      h, $E0					            ; -96 in hi byte which is +96 with hl bit 7 set
                        ld      (prefix1?_BnKrotmatNosevZ),hl
                        ret
                            ENDM
                            
ZeroPitchAndRollMacro:  MACRO   prefix1?                
prefix1?_ZeroPitchAndRoll:
                        xor     a
                        ld      (prefix1?_BnKRotXCounter),a
                        ld      (prefix1?_BnKRotZCounter),a
                        ENDM

MaxPitchAndRollMacro:   MACRO   prefix1?
prefix1?_MaxPitchAndRoll: 
                        ld      a,127
                        ld      (prefix1?_BnKRotXCounter),a
                        ld      (prefix1?_BnKRotZCounter),a
                        ENDM                   

RandomPitchAndRollMacro: MACRO  prefix1?
prefix1?_RandomPitchAndRoll:
                        call    doRandom
                        or      %01101111
                        ld      (prefix1?_BnKRotXCounter),a
                        call    doRandom
                        or      %01101111
                        ld      (prefix1?_BnKRotZCounter),a
                        ENDM

RandomSpeedMacro:       MACRO   prefix1?
prefix1?_RandomSpeed:   
                        call    doRandom
                        and     31
                        ld      (prefix1?_BnKSpeed),a
                        ENDM
                        
MaxSpeedMacro:          MACRO   prefix1?
prefix1?_MaxSpeed:      ld      a,31
                        ld      (prefix1?_BnKSpeed),a
                        ENDM
                        
ZeroAccellerationMacro: MACRO   predix1?
prefix1?_ZeroAccelleration:  
                        xor     a
                        ld      (prefix1?_BnKAccel),a
                        ENDM                            


SetShipHostileMacro:    MACRO   prefix1?
prefix1?_SetShipHostile ld      a,(prefix1?_ShipNewBitsAddr)
                        or      ShipIsHostile 
                        ld      (prefix1?_ShipNewBitsAddr),a
                        ret
                        ENDM
                        
ClearShipHostileMacro:  MACRO    prefix1?
prefix1?_ClearShipHostile: ld      a,(prefix1?_ShipNewBitsAddr)
                        and     ShipNotHostile 
                        ld      (prefix1?_ShipNewBitsAddr),a
                        ret             
                        ENDM
                        
ResetBankDataMacro:     MACRO   prefix1?
prefix1?_ResetBnKData:  ld      hl,prefix1?_StartOfUniv
                        ld      de,prefix?_BnK_Data_len
                        xor     a
                        call    memfill_dma
                        ret
                        ENDM
                        
ResetBnKPositionMacro:  MACRO   prefix1?
prefix1?_ResetBnkPosition:                        
                        ld      hl,prefix1?_BnKxlo
                        ld      b, 3*3
                        xor     a
.zeroLoop:              ld      (hl),a
                        inc     hl
                        djnz    .zeroLoop
                        ret
                        ENDM
                        
FireEMCMacro:           MACRO   prefix1?                        
prefix1?_FireECM:       ld      a,ECMCounterMax                 ; set ECM time
                        ld      (prefix1?_BnKECMCountDown),a            ;
                        ld      a,(ECMCountDown)
                        ReturnIfALTNusng ECMCounterMax
                        ld      a,ECMCounterMax
                        ld      (ECMCountDown),a
                        ret
                        ENDM
                        

RechargeEnergyMacro:    MACRO   prefix1?
prefix1?_RechargeEnergy:ld      a,(prefix1?_BnKEnergy)
                        ReturnIfAGTEMemusng EnergyAddr
                        inc     a
                        ld      (prefix1?_BnKEnergy),a
                        ret        
                        ENDM
                        
                        
UpdateECMMacro:         MACRO   prefix1?
prefix1?_UpdateECM:     ld      a,(prefix1?_BnKECMCountDown)
                        ReturnIfAIsZero
                        dec     a
                        ld      (prefix1?_BnKECMCountDown),a
                        ld      hl,prefix1?_BnKEnergy
                        dec     (hl)
                        ret     p
.ExhaustedEnergy:       call    prefix1?_UnivExplodeShip      ; if it ran out of energy it was as it was also shot or collided as it checks in advance. Main ECM loop will continue as a compromise as multiple ships can fire ECM simultaneously
                        ret
                        ENDM
                           
 ;-- This takes an Axis and subtracts 1, handles leading sign and boundary of 0 going negative
JumpOffSetMacro:        MACRO   prefix1?, Axis
prefix1?_JumpOffSet:    ld      hl,(Axis)
                        ld      a,h
                        and     SignOnly8Bit
                        jr      nz,.NegativeAxis
.PositiveAxis:          dec     l
                        jp      m,.MovingNegative
                        jp      .Done
.NegativeAxis:          inc     l                               ; negative means increment the z
                        jp      .Done
.MovingNegative:        ld      hl,$8001                        ; -1
.Done                   ld      (Axis),hl
                        ENDM
                        

WarpOffSetMacro:        MACRO   prefix1?
prefix1?_WarpOffset:    prefix1?_JumpOffSet  prefix1?_BnKzhi                     ; we will simplify on just moving Z
                        ret 
                        ENDM
                           
                           
; --------------------------------------------------------------                        
; This sets the ship as a shower of explosiondwd
ExplodeShipMacro:       MACRO   prefix1?
prefix1?_ExplodeShip:   ld      a,(prefix1?_BnKaiatkecm)
                        or      ShipExploding | ShipKilled      ; Set Exlpoding flag and mark as just been killed
                        and     Bit7Clear                       ; Remove AI
                        ld      (prefix1?_BnKaiatkecm),a
                        xor     a
                        ld      (prefix1?_BnKEnergy),a
                        ;TODO
                        ret  
                        ENDM