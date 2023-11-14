; -- AI Core data
UnivCoreAIVarsMacro:        MACRO  p?
p?_BnkShipType                DB  0       
; Used to make 16 bit reads a little cleaner in source code
p?_BnkzPoint                  DS  3
p?_BnkzPointLo                equ p?_BnkzPoint
p?_BnkzPointHi                equ p?_BnkzPoint+1
p?_BnkzPointSign              equ p?_BnkzPoint+2

; Used for medridan drawing routines
p?_BnkCx                      DW  0
p?_BnkCxSign                  EQU p?_BnkCx+1
p?_BnkCy                      DW  0
p?_BnkCySign                  EQU p?_BnkCy+1
p?_BnkUx                      DW  0
p?_BnkUxSign                  EQU p?_BnkUx+1
p?_BnkUy                      DW  0
p?_BnkUySign                  EQU p?_BnkUy+1
p?_BnkVx                      DW  0
p?_BnkVxSign                  EQU p?_BnkVx+1
p?_BnkVy                      DW  0
p?_BnkVySign                  EQU p?_BnkVy+1
p?_BnkSinCNT2                 DB  0
p?_BnkSinCNT2Sign             DB  0
p?_BnkCosCNT2                 DB  0
p?_BnkCosCNT2Sign             DB  0
p?_BnkUxCos                   DB  0
p?_BnkUxCosSign               DB  0
p?_BnkUyCos                   DB  0
p?_BnkUyCosSign               DB  0
p?_BnkVxSin                   DB  0
p?_BnkVxSinSign               DB  0
p?_BnkVySin                   DB  0
p?_BnkVySinSign               DB  0
p?_BnkVxVySinSign             DB  0
p?_BnkUxUyCosSign             DB  0
p?_BnkUxCosAddVxSin           DW  0
p?_BnkUyCosSubVySin           DW  0
p?_BnkAngle                   DB  0
        
; General local variables used in universe object
p?_BnkTGT                     DB  0
p?_BnkSTP                     DB  0
p?_BnkLSP                     DS  50              ; move to planet or L2 code ?
p?_BnkCNT                     DB  0               ; 93
p?_BnkCNT2                    DB  0               ; 93
; Replaced LSX2 and LSY2 with plot heaps of 64 x 2 bytes each + 1 pair for initial point
    IFDEF MERIDANLINEDEBUG
p?_BnkPlotXHeap               DS  $82			   ; &0EC0	    \ LSX2 bline buffer size?
p?_BnkPlotYHeap               DS  $82            ; &0F0E	    \ LSY2
    ENDIF
p?_BnkPlotIndex               DB  0
    DISPLAY "TODO can we remove this and just use BnKCNT = 0 as the same thing?"
p?_BnkFlag					DB  0

; Post clipping the results are now 8 bit
p?_BnkVisibility              DB  0               ; replaces general purpose xx4 in renderingW
p?_BnkProjectedY              DB  0
p?_BnkProjectedX              DB  0
p?_BnkProjected               equ p?_BnkProjectedY  ; resultant projected position
p?_XX15Save                   DS  8
p?_XX15Save2                  DS  8
p?_Radius                     DB  0
; Used when drawing curves for the end value from previous calls to BLINE
; held as 16 bit values pre clipping
p?_PrevXPos                   DW 0
p?_PrevYPos                   DW 0
p?_NewXPos                    DW 0
p?_NewYPos                    DW 0
                            
; Colouration
; For planets, Colour 1 is main colour, Colour 2 is outer rim
; if we are going to do outer rim then may have colour thickeness as number of pixels to simulat atmosphere
p?_Colour1                    DB 0
p?_Colour2                    DB 0
p?_Colour2Thickness           DB 0
;        -- _pl(prf .. "Radius                     DW  0
;        -- _pl(prf .. "RadiusHigh                 equ p?_Radius+1
                             ENDM

UnivPosVarsMacro:            MACRO  p?
p?_Bnkxlo                     DB  0                       ; INWK+0
p?_Bnkxhi                     DB  0                       ; there are hi medium low as some times these are 24 bit
p?_Bnkxsgn                    DB  0                       ; INWK+2
p?_Bnkylo                     DB  0                       ; INWK+3 \ ylo
p?_Bnkyhi                     DB  0                       ; INWK+4 \ yHi
p?_Bnkysgn                    DB  0                       ; INWK +5
p?_Bnkzlo                     DB  0                       ; INWK +6
p?_Bnkzhi                     DB  0                       ; INWK +7
p?_Bnkzsgn                    DB  0                       ; INWK +8
p?_CompassX                   DW  0
p?_CompassY                   DW  0
p?_BnkElipseCenterX           DW  0
p?_BnkElipseCenterY           DW  0
p?_BnkElipseRadiusU           DW  0
p?_BnkElipseRadiusV           DW  0
                            ENDM
                            
UnivModelVarsMacro:         MACRO p?
p?_BnkFaceVisArray            DS FaceArraySize            ; XX2 Up to 16 faces this may be normal list, each entry is controlled by bit 7, 1 visible, 0 hidden
; Node array holds the projected to screen position regardless of if its clipped or not
; When we use traingles we can cheat a bit on clipping as all lines will be horizontal so clipping is much simplified
p?_BnkNodeArray               DS NodeArraySize * 4        ; XX3 Holds the points as an array, its an array not a heap
p?_BnkNodeArray2              DS NodeArraySize * 4        ; XX3 Holds the points as an array, its an array not a heap
p?_BnkLineArray               DS LineArraySize * 8        ; XX19 Holds the clipped line details
; ONLY IF TESTING SOLID FILL p?_BnkTriangleOverspill       DS TraingleArraySize * 4    ; jsut a padding for testing
p?_BnkLinesHeapMax            EQU $ - p?_BnkLineArray
p?_BnkTraingleArray           EQU p?_BnkLineArray           ; We can use the line array as we draw lines or traingles
p?_BnkEdgeProcessedList DS EdgeHeapSize
; Array current Lengths
p?_BnkFaceVisArrayLen         DS 1
p?_BnkNodeArrayLen            DS 1
p?_BnkLineArrayLen            DS 1                        ; total number of lines loaded to array 
p?_BnkLineArrayBytes          DS 1                        ; total number of bytes loaded to array  = array len * 4
p?_XX20                       equ p?_BnkLineArrayLen
p?_varXX20                    equ p?_BnkLineArrayLen

p?_BnkEdgeHeapSize            DS 1
p?_BnkEdgeHeapBytes           DS 1
p?_BnkLinesHeapLen            DS 1
p?_BnkEdgeHeapCounter         DS 1
p?_BnkEdgeRadius              DS 1
p?_BnkEdgeShipType            DS 1
p?_BnkEdgeExplosionType       DS 1

; Lines
p?_BnkXX19                    DS  3
                            ENDM


ShipDataMacro:              MACRO p?
p?_BnkHullCopy                DS  ShipDataLength
p?_ScoopDebrisAddr            equ p?_BnkHullCopy + ScoopDebrisOffset     
p?_MissileLockLoAddr          equ p?_BnkHullCopy + MissileLockLoOffset   
p?_MissileLockHiAddr          equ p?_BnkHullCopy + MissileLockHiOffset   
p?_EdgeAddyAddr               equ p?_BnkHullCopy + EdgeAddyOffset        
p?_LineX4Addr                 equ p?_BnkHullCopy + LineX4Offset      
p?_GunVertexAddr              equ p?_BnkHullCopy + GunVertexOffset       
p?_ExplosionCtAddr            equ p?_BnkHullCopy + ExplosionCtOffset    
p?_VertexCountAddr            equ p?_BnkHullCopy + VertexCountOffset    
p?_VertexCtX6Addr             equ p?_BnkHullCopy + VertexCtX6Offset  
p?_EdgeCountAddr              equ p?_BnkHullCopy + EdgeCountOffset       
p?_BountyLoAddr               equ p?_BnkHullCopy + BountyLoOffset        
p?_BountyHiAddr               equ p?_BnkHullCopy + BountyHiOffset        
p?_FaceCtX4Addr               equ p?_BnkHullCopy + FaceCtX4Offset        
p?_DotAddr                    equ p?_BnkHullCopy + DotOffset             
p?_EnergyAddr                 equ p?_BnkHullCopy + EnergyOffset      
p?_SpeedAddr                  equ p?_BnkHullCopy + SpeedOffset           
p?_FaceAddyAddr               equ p?_BnkHullCopy + FaceAddyOffset        
p?_QAddr                      equ p?_BnkHullCopy + QOffset               
p?_LaserAddr                  equ p?_BnkHullCopy + LaserOffset           
p?_VerticesAddyAddr           equ p?_BnkHullCopy + VerticiesAddyOffset  
p?_ShipTypeAddr               equ p?_BnkHullCopy + ShipTypeOffset       
p?_ShipNewBitsAddr            equ p?_BnkHullCopy + ShipNewBitsOffset    
p?_ShipAIFlagsAddr            equ p?_BnkHullCopy + ShipAIFlagsOffset
p?_ShipECMFittedChanceAddr    equ p?_BnkHullCopy + ShipECMFittedChanceOffset
p?_ShipSolidFlagAddr          equ p?_BnkHullCopy + ShipSolidFlagOffset
p?_ShipSolidFillAddr          equ p?_BnkHullCopy + ShipSolidFillOffset
p?_ShipSolidLenAddr           equ p?_BnkHullCopy + ShipSolidLenOffset
                        ENDM
                        
; Now this will mean some special coding for the copy from model to univ bank
ShipModelDataMacro:         MACRO p?
p?_BnkHullVerticies           DS  40 * 6              ; largetst is trasnport type 10 at 37 vericies so alows for 40 * 6 Bytes  = 
p?_BnkHullEdges               DS  50 * 4              ; ype 10 is 46 edges so allow 50
p?_BnkHullNormals             DS  20 * 4              ; type 10 is 14 edges so 20 to be safe
    IFDEF SOLIDHULLTEST
p?_BnkHullSolid               DS  100 * 4             ; Up to 100 triangles (May optimise so only loads non hidden faces later
    ENDIF
p?_OrthagCountdown             DB  12
p?_BnkShipCopy                equ p?_BnkHullVerticies               ; Buffer for copy of ship data, for speed will copy to a local memory block, Cobra is around 400 bytes on creation of a new ship so should be plenty
                            ENDM
                        
                        
;-Rotation Matrix of Ship----------------------------------------------------------------------------------------------------------
; Rotation data is stored as lohi, but only 15 bits with 16th bit being  a sign bit. Note this is NOT 2'c compliment
;-Rotation Matrix of Universe Object-----------------------------------------------------------------------------------------------
UnivRotationVarsMacro:      MACRO p?
p?_BnkrotmatSidevX            DW  0                       ; INWK +21
p?_BnkrotmatSidev             equ p?_BnkrotmatSidevX
p?_BnkrotmatSidevY            DW  0                       ; INWK +23
p?_BnkrotmatSidevZ            DW  0                       ; INWK +25
p?_BnkrotmatRoofvX            DW  0                       ; INWK +15
p?_BnkrotmatRoofv             equ p?_BnkrotmatRoofvX
p?_BnkrotmatRoofvY            DW  0                       ; INWK +17
p?_BnkrotmatRoofvZ            DW  0                       ; INWK +19
p?_BnkrotmatNosevX            DW  0                       ; INWK +9
p?_BnkrotmatNosev             EQU p?_BnkrotmatNosevX
p?_BnkrotmatNosevY            DW  0                       ; INWK +11
p?_BnkrotmatNosevZ            DW  0                       ; INWK +13
                            ENDM

                        
  
                            
CopyPosToXX15Macro: MACRO   p?

p?_CopyPosToXX15:    ld hl,p?_Bnkxhi
                           ld de,p?_BnkXScaled
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


		

InitialiseUniverseObjMacro: MACRO   p?
p?_InitRotMat:    ld      hl, 0
                        ld      (p?_BnkrotmatSidevY),hl       ; set the zeroes
                        ld      (p?_BnkrotmatSidevZ),hl       ; set the zeroes
                        ld      (p?_BnkrotmatRoofvX),hl       ; set the zeroes
                        ld      (p?_BnkrotmatRoofvZ),hl       ; set the zeroes
                        ld      (p?_BnkrotmatNosevX),hl       ; set the zeroes
                        ld      (p?_BnkrotmatNosevY),hl       ; set the zeroes
; Optimised as already have 0 in l
                        ld      h, $60	             				; 96 in hi byte
                        ;ld      hl,1
                        ld      (p?_BnkrotmatSidevX),hl
                        ld      (p?_BnkrotmatRoofvY),hl
; Optimised as already have 0 in l
                        ld      h, $E0					            ; -96 in hi byte which is +96 with hl bit 7 set
                        ld      (p?_BnkrotmatNosevZ),hl
                        ret
                            ENDM
                            
ZeroPitchAndRollMacro:  MACRO   p?                
p?_ZeroPitchAndRoll:
                        xor     a
                        ld      (p?_BnkRotXCounter),a
                        ld      (p?_BnkRotZCounter),a
                        ENDM

MaxPitchAndRollMacro:   MACRO   p?
p?_MaxPitchAndRoll: 
                        ld      a,127
                        ld      (p?_BnkRotXCounter),a
                        ld      (p?_BnkRotZCounter),a
                        ENDM                   

RandomPitchAndRollMacro: MACRO  p?
p?_RandomPitchAndRoll:
                        call    doRandom
                        or      %01101111
                        ld      (p?_BnkRotXCounter),a
                        call    doRandom
                        or      %01101111
                        ld      (p?_BnkRotZCounter),a
                        ENDM

RandomSpeedMacro:       MACRO   p?
p?_RandomSpeed:   
                        call    doRandom
                        and     31
                        ld      (p?_BnkSpeed),a
                        ENDM
                        
MaxSpeedMacro:          MACRO   p?
p?_MaxSpeed:      ld      a,31
                        ld      (p?_BnkSpeed),a
                        ENDM
                        
ZeroAccellerationMacro: MACRO   p?
p?_ZeroAccelleration:  
                        xor     a
                        ld      (p?_BnkAccel),a
                        ENDM                            


SetShipHostileMacro:    MACRO   p?
p?_SetShipHostile ld      a,(p?_ShipNewBitsAddr)
                        or      ShipIsHostile 
                        ld      (p?_ShipNewBitsAddr),a
                        ret
                        ENDM
                        
ClearShipHostileMacro:  MACRO    p?
p?_ClearShipHostile:    ld      a,(p?_ShipNewBitsAddr)
                        and     ShipNotHostile 
                        ld      (p?_ShipNewBitsAddr),a
                        ret             
                        ENDM
                        
ResetBankDataMacro:     MACRO   p?
p?_ResetBnKData:        ld      hl,p?_StartOfUniv
                        ld      de,p?_Bnk_Data_len
                        xor     a
                        call    memfill_dma
                        ret
                        ENDM
                        
ResetBnKPositionMacro:  MACRO   p?
p?_ResetBnKPosition:                        
                        ld      hl,p?_Bnkxlo
                        ld      b, 3*3
                        xor     a
.zeroLoop:              ld      (hl),a
                        inc     hl
                        djnz    .zeroLoop
                        ret
                        ENDM
                        
FireEMCMacro:           MACRO   p?                        
p?_FireECM:       ld      a,ECMCounterMax                 ; set ECM time
                        ld      (p?_BnkECMCountDown),a            ;
                        ld      a,(ECMCountDown)
                        ReturnIfALTNusng ECMCounterMax
                        ld      a,ECMCounterMax
                        ld      (ECMCountDown),a
                        ret
                        ENDM
                        

RechargeEnergyMacro:    MACRO   p?
p?_RechargeEnergy:ld      a,(p?_BnkEnergy)
                        ReturnIfAGTEMemusng EnergyAddr
                        inc     a
                        ld      (p?_BnkEnergy),a
                        ret        
                        ENDM
                        
                        
UpdateECMMacro:         MACRO   p?
p?_UpdateECM:     ld      a,(p?_BnkECMCountDown)
                        ReturnIfAIsZero
                        dec     a
                        ld      (p?_BnkECMCountDown),a
                        ld      hl,p?_BnkEnergy
                        dec     (hl)
                        ret     p
.ExhaustedEnergy:       call    p?_ExplodeShip      ; if it ran out of energy it was as it was also shot or collided as it checks in advance. Main ECM loop will continue as a compromise as multiple ships can fire ECM simultaneously
                        ret
                        ENDM
                           
 ;-- This takes an Axis and subtracts 1, handles leading sign and boundary of 0 going negative
JumpOffSetMacro:        MACRO   p?, Axis
p?_JumpOffSet:    ld      hl,(Axis)
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
                        

WarpOffSetMacro:        MACRO   p?
p?_WarpOffset:    ld      hl,(p?_Bnkzhi)
                        ld      a,h
                        and     SignOnly8Bit
                        jr      nz,.NegativeAxis
.PositiveAxis:          dec     l
                        jp      m,.MovingNegative
                        jp      .Done
.NegativeAxis:          inc     l                               ; negative means increment the z
                        jp      .Done
.MovingNegative:        ld      hl,$8001                        ; -1
.Done                   ld      (p?_Bnkzhi),hl
                        ret 
                        ENDM
                           
                           
; --------------------------------------------------------------                        
; This sets the ship as a shower of explosiondwd
ExplodeShipMacro:       MACRO   p?
p?_ExplodeShip:   ld      a,(p?_Bnkaiatkecm)
                        or      ShipExploding | ShipKilled      ; Set Exlpoding flag and mark as just been killed
                        and     Bit7Clear                       ; Remove AI
                        ld      (p?_Bnkaiatkecm),a
                        xor     a
                        ld      (p?_BnkEnergy),a
                        ;TODO
                        ret  
                        ENDM