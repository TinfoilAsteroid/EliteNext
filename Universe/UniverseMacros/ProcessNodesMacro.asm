
ProcessVisibleNodeMacro:        MACRO   p?
p?_ProcessVisibleNode:
p?_RotateNode:            call    p?_XX12EquXX15DotProductXX16                                                                                       ;;;           call      XX12=XX15.XX16
.LL52LL53LL54LL55
p?_TransposeNode:         call    p?_TransposeXX12NodeToXX15
;..................................                                                         ;;; 
p?_NodeAdditionsDone:
p?_Scale16BitTo8Bit:
p?__LL57:                 ld          a,(varU)                            ; U \ z hi
                                ld          hl,p?_BnkXPointHi
                                or          (hl)                                ; XX15+1    \ x hi
                                ld          hl,p?_BnkYPointHi
                                or          (hl)                                ; XX15+4    \ y hi
.AreXYZHiAllZero:               jr          z,.NodeScalingDone                  ; if X, Y, Z = 0  exit loop down once hi U rolled to 0
.DivideXYZBy2:                  ShiftMem16Right1    p?_BnkXPoint                  ; XX15[0,1]
                                ShiftMem16Right1    p?_BnkYPoint                  ; XX15[3,4]
                                ld          a,(varU)                            ; U \ z hi
                                ld          h,a
                                ld          a,(varT)                            ; T \ z lo
                                ld          l,a
                                ShiftHLRight1
                                ld          a,h
                                ld          (varU),a
                                ld          a,l
                                ld          (varT),a                            ; T \ z lo
                                jp          p?_Scale16BitTo8Bit                 ; loop U
.NodeScalingDone:
.LL60:                                                   ; hi U rolled to 0, exited loop above.
.ProjectNodeToScreen:           ldCopyByte  varT,varQ                           ; T =>  Q   \ zdist lo
                                ld          a,(p?_BnkXPointLo)                    ; XX15  \ rolled x lo
                                ld          hl,varQ
                                cp          (hl)                                ; Q
                                JumpIfALTusng .DoSmallAngle                      ; LL69 if xdist < zdist hop over jmp to small x angle
                                call        RequAdivQ                           ; LL61  \ visit up  R = A/Q = x/z
                                jp          .SkipSmallAngle                      ; LL65  \ hop over small xangle
; small x angle
.DoSmallAngle:          
.LL69:
; TODO check if we need to retain BC as this trashes it
;Input: BC = Dividend, DE = Divisor, HL = 0
;Output: BC = Quotient, HL = Remainder
                                ld      b,a
                                call    DIV16UNDOC
                                ld      a,c
                                ld      (varR),a
 ;;;       call        RequAmul256divQ                     ; LL28  \ BFRDIV R=A*256/Q byte for remainder of division
.SkipSmallAngle:
.ScaleX:
.LL65:                          ld          a,(p?_BnkXPointSign)                  ; XX15+2 \ sign of X dist
                                JumpOnBitSet a,7,.NegativeXPoint                 ; LL62 up, -ve Xdist, RU screen onto XX3 heap   
; ......................................................   
.PositiveXPoint:                ld          a,(varR)
                                ld          l,a
                                ld          a,(varU)
                                ld          h,a
                                ld          a,ScreenCenterX
                                add         hl,a
                                ex          de,hl
                                jp          .StoreXPoint
; Arrive from LL65 just below, screen for -ve RU onto XX3 heap, index X=CNT ;;;
.NegativeXPoint:
.LL62:                          ld          a,(varR)
                                ld          l,a
                                ld          a,(varU)
                                ld          h,a
                                ld          c,ScreenCenterX
                                ld          b,0
                                ClearCarryFlag
                                sbc         hl,bc                               ; hl = RU-ScreenCenterX
                                ex          de,hl      
; also from LL62, XX3 node heap has xscreen node so far.
.StoreXPoint:                   ld          (iy+0),e                            ; Update X Point
                                ld          (iy+1),d                            ; Update X Point
                                inc         iy
                                inc         iy
; ......................................................   
.LL66:
.ProcessYPoint:                 xor         a                                   ; y hi = 0
                                ld          (varU),a                            ; U
                                ldCopyByte  varT,varQ                           ; Q \ zdist lo
                                ld          a,(p?_BnkYPointLo)                    ; XX15+3 \ rolled y low
                                ld          hl,varQ
                                cp          (hl)                                ; Q
                                JumpIfALTusng .SmallYHop                         ; if ydist < zdist hop to small yangle
.SmallYPoint:                   call        RequAdivQ                           ; LL61  \ else visit up R = A/Q = y/z
                                jp          .SkipYScale                          ; LL68 hop over small y yangle
; Arrive from LL66 above if XX15+3 < Q \ small yangle
.SmallYHop:
.LL67:                          call        RequAmul256divQ                     ; LL28  \ BFRDIV R=A*256/Q byte for remainder of division
; both carry on, also arrive from LL66, yscaled based on z
.SkipYScale:
.LL68:                          ld          a,(p?_BnkYPointSign)                  ; XX15+5 \ sign of X dist
                                bit         7,a
                                jp          nz,.NegativeYPoint                   ; LL62 up, -ve Xdist, RU screen onto XX3 heap   
.PositiveYPoint:                ld          a,(varR)
                                ld          l,a
                                ld          a,(varU)
                                ld          h,a
                                ld          a,ScreenHeightHalf
                                add         hl,a
                                ex          de,hl
                                jp          LL50
; Arrive from LL65 just below, screen for -ve RU onto XX3 heap, index X=CNT ;;;
.NegativeYPoint:
.LL70:                          ld          a,(varR)
                                ld          l,a
                                ld          a,(varU)
                                ld          h,a
                                ld          c,ScreenHeightHalf
                                ld          b,0
                                ClearCarryFlag
                                sbc         hl,bc                               ; hl = RU-ScreenCenterX
                                ex          de,hl      
; also from LL62, XX3 node heap has xscreen node so far.
.LL50:                          ld          (iy+0),e                            ; Update X Point
                                ld          (iy+1),d                            ; Update X Point
                                inc         iy
                                inc         iy
                                ret
                                ENDM
                                
                                
                                
;;;     Byte 4 = High 4 bits Face 2 Index Low 4 bits = Face 1 Index
;;;     Byte 5 = High 4 bits Face 4 Index Low 4 bits = Face 3 Index
;..............................................................................................................................
; Start loop on Nodes for visibility, each node has 4 faces associated with ;;; For each node (point) in model                  ::LL48 
ProcessANodemacro:              MACRO   p?
p?_ProcessANode:
.LL48GetScale:                  ld          a,(LastNormalVisible)               ; get Normal visible range into e before we copy node
                                ld          e,a
                                call        p?_CopyNodeToXX15
.LL48GetVertices:
.LL48GetVertSignAndVisDist:
                                JumpIfALTNusng e,.NodeIsNotVisible               ; if XX4 > Visibility distance then vertext too far away , next vertex.                                             ;;;        goto LL50 (end of loop)
.CheckFace1:                    CopyByteAtNextHL varP                           ; vertex byte#4, first 2 faces two 4-bit indices 0:15 into XX2 for 2 of the ;;;     get point face idx from byte 4 & 5 of normal
                                ld          d,a                                 ; use d to hold a as a temp                                                 ;;;
                                and         $0F                                 ; face 1                                                                    ;;;
                                push        hl                                  ; we need to save HL                                                        ;;;
                                ldHLIdxAToA p?_BnkFaceVisArray                    ; visibility at face 1                                                Byte 4;;;
                                pop         hl                                  ;                                                                           ;;;
                                JumpIfAIsNotZero .NodeIsVisible                  ; is face 1 visible                                                         ;;;
.CheckFace2:                    ld          a,d                                                                                                             ;;;
                                swapnib                                                                                                                     ;;;
                                and         $0F                                 ; this is face 2                                                            ;;;
                                JumpIfAIsNotZero .NodeIsVisible                  ; is face 1 visible                                                         ;;;
.CheckFace3:                    CopyByteAtNextHL varP                           ; vertex byte#4, first 2 faces two 4-bit indices 0:15 into XX2 for 2 of the ;;;     
                                ld          d,a                                 ; use d to hold a as a temp                                                 ;;;
                                and         $0F                                 ; face 1                                                                    ;;;     
                                push        hl                                  ; we need to save HL                                                        ;;;
                                ldHLIdxAToA p?_BnkFaceVisArray                  ; visibility at face 1                                                Byte 5;;;
                                pop         hl                                  ;                                                                           ;;;
                                JumpIfAIsNotZero .NodeIsVisible                  ; is face 1 visible                                                         ;;;
.CheckFace4:                    ld          a,d                                                                                                             ;;;
                                swapnib                                                                                                                     ;;;
                                and         $0F                                 ; this is face 2                                                            ;;;
                                JumpIfAIsNotZero .NodeIsVisible                  ; is face 1 visible                                                         ;;;
.NodeIsNotVisible:              ld          bc,4
                                add         iy,bc                               ; if not visible then move to next element in array anyway                  ;;;
                                ;;; Should we be loading FFFFFFFF into 4 bytes or just ignore?
                                ret                                                                                                      ;;;        goto LL50 (end of loop)
.NodeIsVisible:
.LL49:                          call        p?_ProcessVisibleNode                  ; Process node to determine if it goes on heap
                                ret

p?_ProjectNodeToEye:      ld          bc,(p?_BnkZScaled)                    ; BC = Z Cordinate. By here it MUST be positive as its clamped to 4 min
                                ld          a,c                                 ;  so no need for a negative check
                                ld          (varQ),a                            ; VarQ = z
                                ld          a,(p?_BnkXScaled)                     ; XX15  \ rolled x lo which is signed
                                call        DIV16Amul256dCUNDOC                 ; result in BC which is 16 bit TODO Move to 16 bit below not just C reg
                                ld          a,(p?_BnkXScaledSign)                 ; XX15+2 \ sign of X dist
                                JumpOnBitSet a,7,.EyeNegativeXPoint             ; LL62 up, -ve Xdist, RU screen onto XX3 heap
; x was positive result
.EyePositiveXPoint:             ld          l,ScreenCenterX                     ; 
                                ld          h,0
                                add         hl,bc                               ; hl = Screen Centre + X
                                jp          .EyeStoreXPoint
; x < 0 so need to subtract from the screen centre position
.EyeNegativeXPoint:             ld          l,ScreenCenterX                     
                                ld          h,0
                                ClearCarryFlag
                                sbc         hl,bc                               ; hl = Screen Centre - X
; also from LL62, XX3 node heap has xscreen node so far.
.EyeStoreXPoint:                ex          de,hl
                                ld          (iy+0),e                            ; Update X Point TODO this bit is 16 bit aware just need to fix above bit
                                ld          (iy+1),d                            ; Update X Point
.EyeProcessYPoint:              ld          bc,(p?_BnkZScaled)                    ; Now process Y co-ordinate
                                ld          a,c
                                ld          (varQ),a
                                ld          a,(p?_BnkYScaled)                     ; XX15  \ rolled x lo
                                call        DIV16Amul256dCUNDOC                 ; a = Y scaled * 256 / zscaled
                                ld          a,(p?_BnkYScaledSign)                 ; XX15+2 \ sign of X dist
                                JumpOnBitSet a,7,.EyeNegativeYPoint             ; LL62 up, -ve Xdist, RU screen onto XX3 heap top of screen is Y = 0
; Y is positive so above the centre line
.EyePositiveYPoint:             ld          l,ScreenCenterY
                                ClearCarryFlag
                                sbc         hl,bc                               ; hl = ScreenCentreY - Y coord (as screen is 0 at top)
                                jp          .EyeStoreYPoint
; this bit is only 8 bit aware TODO FIX
.EyeNegativeYPoint:             ld          l,ScreenCenterY                     
                                ld          h,0
                                add         hl,bc                               ; hl = ScreenCenterY + Y as negative is below the center of screen
; also from LL62, XX3 node heap has xscreen node so far.
.EyeStoreYPoint:                ex          de,hl
                                ld          (iy+2),e                            ; Update Y Point
                                ld          (iy+3),d                            ; Update Y Point
                                ret
                                ENDM
                                
; DIot seem to lawyas have Y = 0???
ProcessDotMacro:                MACRO p?
p?_ProcessDot:            call    p?_CopyRotmatToTransMat             ;#01; Load to Rotation Matrix to XX16, 16th bit is sign bit
                                call    p?_ScaleXX16Matrix197               ;#02; Normalise XX16
                                call    p?_LoadCraftToCamera                ;#04; Load Ship Coords to XX18
                                call    p?_InverseXX16                      ;#11; Invert rotation matrix
                                ld      hl,0
                                ld      (p?_BnkXScaled),hl
                                ld      (p?_BnkYScaled),hl
                                ld      (p?_BnkZScaled),hl
                                xor     a
                                call    p?_XX12EquNodeDotOrientation
                                call    p?_TransposeXX12ByShipToXX15
                                call    p?_ScaleNodeTo8Bit                     ; scale to 8 bit values, why don't we hold the magnitude here?x
                                ld      iy,p?_BnkNodeArray
                                call    p?_ProjectNodeToEye
                                ret      
                                ENDM                                
                                
ProcessNodesMacro:              MACRO p?
p?_ProcessNodes:          ZeroA
                                ld      (p?_BnkLineArrayLen),a
                                call    p?_CopyRotmatToTransMat ; CopyRotToTransMacro                      ;#01; Load to Rotation Matrix to XX16, 16th bit is sign bit
                                call    p?_ScaleXX16Matrix197               ;#02; Normalise XX16
                                call    p?_LoadCraftToCamera                ;#04; Load Ship Coords to XX18
                                call    p?_InverseXX16                      ;#11; Invert rotation matrix
                                ld      hl,p?_BnkHullVerticies
                                ld      a,(p?_VertexCtX6Addr)               ; get Hull byte#9 = number of vertices *6                                   ;;;
p?_GetActualVertexCount:  ld      c,a                              ; XX20 also c = number of vertices * 6 (or XX20)
                                ld      c,a                              ; XX20 also c = number of vertices * 6 (or XX20)
                                ld      d,6
                                call    asm_div8                         ; asm_div8 C_Div_D - C is the numerator, D is the denominator, A is the remainder, B is 0, C is the result of C/D,D,E,H,L are not changed"
                                ld      b,c                              ; c = number of vertices
                                ld      iy,p?_BnkNodeArray
p?_LL48:   
p?_PointLoop:             push    bc                                  ; save counters
                                push    hl                                  ; save verticies list pointer
                                push    iy                                  ; save Screen plot array pointer
                                ld      a,b
                                ;break
                                call    p?_CopyNodeToXX15                      ; copy verices at hl to xx15
                                ld      a,(p?_BnkXScaledSign)
                                call    p?_XX12EquNodeDotOrientation
                                call    p?_TransposeXX12ByShipToXX15
                                call    p?_ScaleNodeTo8Bit                     ; scale to 8 bit values, why don't we hold the magnitude here?x
                                pop     iy                                  ; get back screen plot array pointer
                                call    p?_ProjectNodeToEye                     ; set up screen plot list entry
   ; ld      hl,p?_BnkLineArrayLen
  ;  inc     (hl)                                ; another node done
p?_ReadyForNextPoint:     push    iy                                  ; copy screen plot pointer to hl
                                pop     hl
                                ld      a,4
                                add     hl,a
                                push    hl                                  ; write it back at iy + 4
                                pop     iy                                  ; and put it in iy again
                                pop     hl                                  ; get hl back as vertex list
                                ld      a,6
                                add     hl,a                                ; and move to next vertex
                                pop     bc                                  ; get counter back
                                djnz    p?_PointLoop
; ......................................................   
                                ClearCarryFlag
                                ret
                                ENDM
                                
                                
; ...........................................................
ProcessShipMacro:               MACRO p?
p?_ProcessShip:           call    p?_CheckVisible                ; checks for z -ve and outside view frustrum, sets up flags for next bit
.IsItADot:                      ld      a,(p?_Bnkaiatkecm)
                                and     ShipIsVisible | ShipIsDot | ShipExploding  ; first off set if we can draw or need to update explosion
                                ret     z                           ; if none of these flags are set we can fast exit
                                break
                                JumpOnABitSet ShipExplodingBitNbr, .ExplodingCloud; we always do the cloud processing even if invisible
;............................................................  
.DetermineDrawType:             ReturnOnBitClear    a, ShipIsVisibleBitNbr          ; if its not visible exit early
                                JumpOnABitClear ShipIsDotBitNbr, .CarryOnWithDraw   ; if not dot do normal draw
;............................................................  
.itsJustADot:                   call    p?_ProcessDot
                                SetMemBitN  p?_Bnkaiatkecm , ShipIsDotBitNbr ; set is a dot flag
                                ld      bc,(p?_BnkNodeArray)          ; if its at dot range get X
                                ld      de,(p?_BnkNodeArray+2)        ; and Y
                                ld      a,b                         ; if high byte components are not 0 then off screen
                                or      d                           ;
                                ret     nz                          ;
                                ld      a,e
                                and     %10000000                   ; check to see if Y > 128
                                ret     nz
                                ld      b,e                         ; now b = y and c = x
                                ld      a,L2ColourWHITE_1           ; just draw a pixel
                                ld      a,224
                                MMUSelectLayer2                     ; then go to update radar
                                call    ShipPixel                   ; 
                                ret
;............................................................  
.CarryOnWithDraw:               call    p?_ProcessNodes                ; process notes is the poor performer or check distnace is not culling
                       ; break
                                ld      a,$E3
                                ld      (line_gfx_colour),a  
                                call    p?_CullV2
                                call    p?_PrepLines                       ; With late clipping this just moves the data to the line array which is now x2 size
                                call    p?_DrawLinesLateClipping
                                IFDEF FLIPBUFFERSTEST
                                    DISPLAY "Univ_ship_data flip buffer test Enabled"
                                    call   l2_flip_buffers
                                    call   l2_flip_buffers
                                ELSE
                                    DISPLAY "Univ_ship_data flip buffer test Disabled"
                                ENDIF
                                ret 
;............................................................  
.ExplodingCloud:                call    p?_ProcessNodes
                                ClearMemBitN  p?_Bnkaiatkecm, ShipKilledBitNbr ; acknowledge ship exploding
.UpdateCloudCounter:            ld      a,(p?_BnkCloudCounter)        ; counter += 4 until > 255
                                add     4                           ; we do this early as we now have logic for
                                jp      c,.FinishedExplosion        ; display or not later
                                ld      (p?_BnkCloudCounter),a        ; .
.SkipHiddenShip:                ReturnOnMemBitClear  p?_Bnkaiatkecm , ShipIsVisibleBitNbr
.IsShipADot:                    JumpOnABitSet ShipIsDotBitNbr, .itsJustADot ; if its dot distance then explosion is a dot, TODO later we will do as a coloured dot
.CalculateZ:                    ld      hl,(p?_Bnkzlo)                ; al = hl = z
                                ld      a,h                         ; .
                                JumpIfALTNusng 32,.CalcFromZ        ; if its >= 32 then set a to FE and we are done
                                ld      h,$FE                       ; .
                                jp      .DoneZDist                  ; .
.CalcFromZ:                     ShiftHLLeft1                        ; else
                                ShiftHLLeft1                        ; hl = hl * 2
                                SetCarryFlag                        ; h = h * 3 rolling in lower bit
                                rl  h                               ; 
.DoneZDist:                     ld      b,0                         ; bc = cloud z distance calculateed
                                ld      c,h                         ; .
.CalcCloudRadius:               ld      a,(p?_BnkCloudCounter)        ; de = cloud counter * 256
                                ld      d,a                         ;
                                ld      e,0                         ;
                                call    DEequDEDivBC                ; de = cloud counter * 256 / z distance
                                ld      a,d                         ; if radius >= 28
                                JumpIfALTNusng  28,.SetCloudRadius  ; then set raidus in d to $FE
.MaxCloudRadius:                ld      d,$FE                       ;
                                jp      .SizedUpCloud               ;
.SetCloudRadius:                ShiftDELeft1                        ; de = 8 * de
                                ShiftDELeft1                        ; .
                                ShiftDELeft1                        ; .
.SizedUpCloud:                  ld      a,d                         ; cloudradius = a = d or (cloudcounter * 8 / 256)
                                ld      (p?_BnkCloudRadius),a         ; .
                                ld      ixh,a                       ; ixh = a = calculated cloud radius
.CalcSubParticleColour:         ld      a,(p?_BnkCloudCounter)        ; colur fades away
                                swapnib                             ; divive by 16
                                and     $0F                         ; mask off upper bytes
                                sra     a                           ; divide by 32
                                ld      hl,p?_DebrisColourTable
                                add     hl,a
                                ld      a,(hl)
                                ld      iyl,a                       ; iyl = pixel colours
.CalcSubParticleCount:          ld      a,(p?_BnkCloudCounter)        ; cloud counter = abs (cloud counter) in effect if > 127 then shrinks it
                                ABSa2c                              ; a = abs a
.ParticlePositive:              sra a                               ; iyh = (a /8) 
                                sra a                               ; .
                                sra a                               ; .
                                or  1                               ; bit 0 set so minimum 1
.DoneSubParticleCount:          ld      ixl,a                       ; ixl = nbr particles per vertex
.ForEachVertex:                 ld      a,(VertexCountAddr)         ; load vertex count into b
                                ld      b,a                         ; .
                                ld      hl,p?_BnkNodeArray            ; hl = list of vertices
.ExplosionVertLoop:             push    bc,,hl                      ; save vertex counter in b and pointer to verticles in hl
                                ld      ixl,b                   ; save counter
                                ld      c,(hl)                  ; get vertex into bc and de
                                inc     hl                      ; .
                                ld      b,(hl)                  ; .
                                inc     hl                      ; .
                                ld      e,(hl)                  ; .
                                inc     hl                      ; .
                                ld      d,(hl)                  ; now hl is done with and we can use it 
.LoopSubParticles:              ld      a,ixl                   ; iyh = loop iterator for nbr of particles per vertex
                                ld      iyh,a                   ; 
                                ;break
.ProcessAParticle:              push    de,,bc                  ; save y then x coordinates
                                ex      de,hl               ; hl = de (Y)
                                ld      d,ixh               ; d = cloud radius
                                call    HLEquARandCloud     ; vertex = vertex +/- (random * projected cloud side /256)
                                ld      a,h                 ; if off screen skip
                                JumpIfAIsNotZero  .NextIteration
                                ex      de,hl               ; de = result for y which was put into hl
                                pop     hl                  ; get x back from bc on stack
                                push    hl                  ; put bc (which is now in hl) back on the stack
                                push    de                  ; save de
                                ld      d,ixh               ; d = cloud radius
                                call    HLEquARandCloud     ; vertex = vertex +/- (random * projected cloud side /256)
                                pop     de                  ; get de back doing pop here clears stack up
                                ld      a,h                 ; if high byte has a value then off screen
                                JumpIfAIsNotZero .NextIteration ; 
                                ld      b,e                 ; bc = y x of pixel from e and c regs
                                ld      c,l                 ; iyl already has colour
                                MMUSelectLayer2             ; plot it with debris code as this can chop y > 128
                                call    DebrisPixel         ; .
.NextIteration:                 pop    de,,bc                   ; ready for next iteration, get back y and x coordinates
                                dec    iyh                      ; one partcile done
                                jr      nz,.ProcessAParticle    ; until all done
.NextVert:                      pop     bc,,hl                      ; recover loop counter and source pointer
                                ld      a,4                         ; move to next vertex group
                                add     hl,a                        ;
                                djnz    .ExplosionVertLoop          ;         
                                ret
.FinishedExplosion:             ;break
                                
                                ld      a,(p?_BnkSlotNumber)          ; get slot number
                                call    ClearSlotA                  ; gauranted to be in main memory as non bankables
                                ClearMemBitN p?_Bnkaiatkecm, ShipExplodingBitNbr
                                ret
                                
p?_DebrisColourTable:     DB L2ColourYELLOW_1, L2ColourYELLOW_2, L2ColourYELLOW_3, L2ColourYELLOW_4, L2ColourYELLOW_5, L2ColourYELLOW_6, L2ColourYELLOW_7,L2ColourGREY_4
                                
                                ENDM
                                
    DISPLAY "TODO: Move to maths bank"

                                
HLEquARandCloudMacro:           MACRO   p?                                
p?_HLEquARandCloud:       push    hl                          ; random number geneator upsets hl register
                                call    doRandom                    ; a= random * 2
                                pop     hl
                                rla                                 ;
                                jr      c,.Negative                 ; if buit 7 went into carry
.Positive:                      ld  e,a
                                mul
                                ld  e,d
                                ld  d,0
                                ClearCarryFlag
                                adc     hl,de                       ; hl = hl + a
                                ret
.Negative:                      ld  e,a
                                mul
                                ld  e,d
                                ld  d,0
                                ClearCarryFlag
                                sbc     hl,de                       ; hl = hl + a
                                ret                
                                ENDM

AddLaserBeamLineMacro:          MACRO   p?
p?_AddLaserBeamLine:
; this code is a bag of shit and needs re-writing
p?_GetGunVertexNode:      ld          a,(p?_GunVertexAddr)                   ; Hull byte#6, gun vertex*4 (XX0),Y
                                ld          hl,p?_BnkNodeArray                    ; list of lines to read
                                add         hl,a                                ; HL = address of GunVertexOnNodeArray
                                ld          iyl,0
p?_MoveX1PointToXX15:     ld          c,(hl)                              ; 
                                inc         hl
                                ld          b,(hl)                              ; bc = x1 of gun vertex
                                inc         hl
                                ld          (p?_BnkX1),bc
                                inc         c
                                ret         z                                   ; was c 255?
                                inc         b
                                ret         z                                   ; was c 255?
p?_MoveY1PointToXX15:     ld          c,(hl)                              ; 
                                inc         hl
                                ld          b,(hl)                              ; bc = y1 of gun vertex
                                inc         hl
                                ld          (p?_BnkY1),bc
p?_SetX2PointToXX15:      ld          bc,0                                ; set X2 to 0
                                ld          (p?_BnkX2),bc
                                ld          a,(p?_Bnkzlo)
                                ld          c,a
p?_SetY2PointToXX15:      ld          (p?_BnkY2),bc                         ; set Y2to 0
                                ld          a,(p?_Bnkxsgn)
                                JumpOnBitClear a,7,LL74SkipDec
p?_LL74DecX2:             ld          a,$FF
                                ld          (p?_BnkX2Lo),a                        ; rather than dec (hl) just load with 255 as it will always be that at this code point
p?_LL74SkipDec:           call        p?_ClipLineV3                            ; LL145 \ clip test on XX15 XX12 vector, returns carry 
                                jr          c,CalculateNewLines
;        jr          c,CalculateNewLines                 ; LL170 clip returned carry set so not visibile if carry set skip the rest (laser not firing)
; Here we are usign hl to replace VarU as index        
                                ld          hl,(varU16)
                                ld          a,(p?_Bnkx1Lo)
                                ld          (hl),a
                                inc         hl
                                ld          a,(p?_Bnky1Lo)
                                ld          (hl),a
                                inc         hl
                                ld          a,(p?_BnkX2Lo)
                                ld          (hl),a
                                inc         hl
                                ld          a,(p?_Bnky2Lo)
                                ld          (hl),a
                                inc         iyl                                 ; iyl holds as a counter to iterations
                                inc         hl
                                inc         iyl                                 ; ready for next byte
                                ld          (varU16),hl
                                ret     
                                ENDM