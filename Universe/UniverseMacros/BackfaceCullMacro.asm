;    DEFINE DEBUGDRAWDISTANCE 1
;    DEFINE CHECKDOTSHIPDATA  1
 ;   DEFINE DEBUGFORCEFACEDRAW 1
; SomeFacesVisible:   
; EE29:             

;   Backface cull logic  line of sight vector . face normal vector
;       line of sight vector . face normal vector
;       => line of sight vector = [x y z] + face normal vector
;       Where [x y z] =
;                                               [ [x y z] . sidev ]
;                    projected [x y z] vector = [ [x y z] . roofv ]
;                                               [ [x y z] . nosev ]
;       
;   so project the [x y z] vector into the face's normal space
;  line of sight vector = projected [x y z] vector + face normal vector
;                         [ [x y z] . sidev ]   [ normal_x ]
;                       = [ [x y z] . roofv ] + [ normal_y ]
;                         [ [x y z] . nosev ]   [ normal_z ]
;
;                         [ [x y z] . sidev + normal_x ]
;                       = [ [x y z] . roofv + normal_y ]
;                         [ [x y z] . nosev + normal_z ]
;
; so 
;              visibility = [ [x y z] . sidev + normal_x ]   [ normal_x ]
;                            [ [x y z] . roofv + normal_y ] . [ normal_y ]
;                           [ [x y z] . nosev + normal_z ]   [ normal_z ]
;               
; where face is visible if visibility < 0
; 
;   so we set XX15 to [x y z] . sidev 
;                     [x y z] . roofv 
;                     [x y z] . nosev 
;


ScaleDrawcamMacro:      MACRO p?
p?_CurrentNormIdx  DB 0

p?_ScaleDrawcam:  ld      a,(p?_BnkDrawCam0zHi)         ; if z hi is 0 then we have scaled XX18
                        JumpIfAIsZero .ScaleDone            ; 
                        ld      hl,(p?_BnkDrawCam0xLo)        ; pull postition into registers
                        ld      de,(p?_BnkDrawCam0yLo)        ; we only pull in if needed to save fetches
                        ld      bc,(p?_BnkDrawCam0zLo)        ;
.ScaleNormalLoop:       inc     iyl                         ; Q goes up by one
                        ShiftHLRight1                       ; divide cam position by 2
                        ShiftDERight1                       ;
                        ShiftBCRight1                       ;
                        ld      a,b                         ; loop if not scaled down
                        JumpIfAIsNotZero .ScaleNormalLoop     ;
                        ld      (p?_BnkDrawCam0xLo),hl        ; save position back to XX18
                        ld      (p?_BnkDrawCam0yLo),de        ;
                        ld      (p?_BnkDrawCam0zLo),bc        ;
.ScaleDone:             ld      a,iyl
                        ld      (varXX17),a                  ; XX17 = normal scale factor for current ship adjusted for camera
                        ret
                        ENDM

CheckVisibleMacro:      MACRO p?
p?_CheckVisible:  ld      a,(p?_Bnkzsgn)                 ; Is the ship behind us
.CheckBehind:           and     SignOnly8Bit                 ; which means z sign is negative
                        jr      nz,.ShipNoDraw               ; .
.CheckViewPort:         ld      hl,(p?_Bnkzlo)                 ; now check to see if its within 90 degree arc
                        ld      a,h
                        JumpIfAGTENusng ShipMaxDistance, .ShipNoDraw
.CheckXAxis:            ld      de,(p?_Bnkxlo)                 ; if abs x > abx z then its out side of view port
                        call    compare16HLDE                
                        jr      c,.ShipNoDraw               ; ship is too far out on the X Axis
.CheckYAxis:            ld      de,(p?_Bnkylo)                ; if abs y > abx z then its out side of view port
                        call    compare16HLDE
                        jr      c,.ShipNoDraw               ; ship is too far out on the X Axis
.CheckDotV2:            ld      a,(DotAddr)
                        JumpIfAGTENusng h, .DrawFull
                        jp      .ShipIsADot
.DrawFull:              ld      a,(p?_Bnkaiatkecm)            ; its visible but a dot
                        or      ShipIsVisible               ; Visible and not a dot
                        and     ShipIsNotDot                ;
                        ld      (p?_Bnkaiatkecm),a            ;
                        ClearCarryFlag
                        ret
.ShipNoDraw:            ClearMemBitN  p?_Bnkaiatkecm  , ShipIsVisibleBitNbr ; Assume its hidden
                        ret
.ShipIsADot:            ld      a,(p?_Bnkaiatkecm)            ; its visible but a dot
                        or      ShipIsVisible | ShipIsDot   ; 
                        ld      (p?_Bnkaiatkecm),a            ; 
                        ret
                        ENDM
                        
                                    DISPLAY "TODO:remove all teh processing of rotmat to load craft to camera as its already been done"
CullV2Macro:            MACRO p?                                    
p?_CullV2:        break
                        ReturnIfMemisZero p?_FaceCtX4Addr      ;   
                       ; break                          
                        call    p?_CopyRotmatToTransMat        ; XX16 = p?_BnkRotMat    
                        call    p?_ScaleXX16Matrix197          ; scale rotation matrix in XX16
                        call    p?_LoadCraftToCamera           ; XX18 = camera
                        ;call    CopyCameraToXX15Signed      ; Copy the camera to XX15 as signed 15 bit
.BackfaceLoop:          ld      a,(QAddr)                   ;  
                        ld      iyl,a                       ; iyl = scale factor
; By this point XX18 = scaled draw cam and iyl = scale factor
                        call    p?_ScaleDrawcam                ; XX18 = scaled camera XX17 = scale
                        call    p?_CopyCameraToXX15Signed      ; Xx18 -> xx15 sign + 15 bit
.LL91:                  call    p?_XX12EquNodeDotXX16          ; xx12 = Scaled Camera . Rotation matrix (Note Xx16 no Xx16 inv)
                        call    p?_CopyXX12ScaledToXX18        ; now xx18 = XX12 = xx15.xx16
.PrepNormals:           ld      hl,p?_BnkHullNormals                                                                                                 ;;; V = address of Normal start
                        ld      (varV),hl  
                        ld      a,(p?_FaceCtX4Addr)                                        ; For each face
                        srl     a                                              ;
                        srl     a                                              ;
                        ld      b,a                                            ;
                        xor     a                           
                        ld      (p?_CurrentNormIdx),a                                          ; used to increment up face incdex as b decrements
.ProcessNormalsLoop:    push    hl                          
                        push    bc                          
.LL86:                  ld      a,(hl)                                         ; Get Face sign and visibility distance byte 
                        and     $1F                                            ; if normal visibility range  < XX4
                        push    hl                          
                        ld      hl,p?_BnkDrawAllFaces              
                        cp      (hl)                        
                        pop     hl                 
                        jp      c,.FaceVisible              ; then we always draw
; This bit needs to be added to force face visible
.LL87:                  call    p?_CopyFaceToXX12              ; XX12 = normal (repolaced scale version) as a working copy
                        ld      a,(XX17)                    ; a = q scale XX17 cauclated by the call to ScaleDrawcam
                        ld      b,a
                        JumpIfALTNusng 4,.ScaleNormByXX17   ; if q >= 4 then is so big we don;t factor in + normal for dot product
.LL143:                 call    p?_CopyXX18toXX15              ; and we just set XX15 = scaled Camera dot rotation matrix
                        jp      .DoneScalingIntoXX15        ; Now Process XX12 normal
.Ovflw:                 ld      a,(p?_BnkDrawCam0xLo)         ; divide camera by 2 if overflow
                        srl     a                           ; which is held in XX18
                        ld      (p?_BnkDrawCam0xLo),a         ; .
                        ld      a,(p?_BnkDrawCam0zLo)         ; .
                        srl     a                           ; .
                        ld      (p?_BnkDrawCam0zLo),a         ; .
                        ld      a,(p?_BnkDrawCam0yLo)         ; .
                        srl     a                           ; .
                        ld      (p?_BnkDrawCam0yLo),a        ; .
.ScaleXScaledAgain:     ld      b,1                         ; set scale to 1 so we divide original normal by 2 into face and try again and hope we didn't scaled down XX12 earlier so if we did then we must be in the do doo as the object was obscenely large and very close
                        ShiftMem8Right1 p?_BnkXScaled         ; Divide XX15 by 2^B
                        ShiftMem8Right1 p?_BnkYScaled         ; 
                        ShiftMem8Right1 p?_BnkZScaled         ; 
; if we jumped to here scale factor < 4 so we copy in normal to XX15 (scaled) LL92
.ScaleNormByXX17:       ;ld      b,a
                        call    p?_CopyXX12toXX15
.LL93                   dec     b
                        jp      m, .ScaledNorm
.LL93Loop:              ShiftMem8Right1 p?_BnkXScaled        ; Divide XX15 by 2^B, I think this should be really XX12 and is a bug in the original code
                        ShiftMem8Right1 p?_BnkYScaled        ; 
                        ShiftMem8Right1 p?_BnkZScaled        ; 
                        dec     b                          ; 
                        jp      p,.LL93Loop                ; Now we have XX15 as scaled Normal, XX15 as camera, don;t really knwo why as cals work on XX12 and XX18
.ScaledNorm:            ;ORIG CODE DOES NOT HAVE THIS call    CopyXX15ToXX12 ; DEBUG as XX15 shoudl be a sacled nromal
; Add normal to XX15
; if we jumped here direct from LL143 then XX15 = drawcam scaled by Q, XX12 = face normal unscaled, XX18 = drawcam scaled also
; if we jumped here via scaling       then XX15 = normal scaled by Q,  XX12 = face normal unscaled, XX16 = drawcam scaled
; if we hit an overflow               then XX15 = drawcam scaled by Q  XX12 = face normal unscaled, XX18 = (drawcam scaled / 2 ) / 2^ nbr overflows (if we cam in vai scaling then its a mess?
; So LL94 is wrong as it shoud be operating on XX12 not XX15
.LL94:                  ldCopyByte p?_BnkZScaled, varR        ; ldCopyByte  p?_BnkZScaled,     varR  ; if we jumped direct XX15 = drawcam scaled, Xx12 = normal xx18 = drawcam
                        ldCopyByte p?_BnkXX12zSign, varS      ; ldCopyByte  p?_BnkYScaled,     varS  ; if we did scaling then xx15 = norm scaled XX18 = drawcam
                        ldCopyByte  p?_BnkDrawCam0zLo, varQ   ; AQ = drawcam Z signed
                        ld      a,(p?_BnkDrawCam0zSgn)        ; .
                        call    SAEquSRPlusAQ               ; SA = drawcam Z dot + z
                        jp      c,.Ovflw
                        ld      (p?_BnkZScaled),a             ; XX15Z = SA
                        ldCopyByte  varS, p?_BnkZScaledSign   ;
                        ldCopyByte  p?_BnkXScaled,     varR   ; SR = normal X
                        ldCopyByte  p?_BnkXX12xSign,   varS   ; .
                        ldCopyByte  p?_BnkDrawCam0xLo, varQ   ; AQ = drawcam x dot
                        ld      a,(p?_BnkDrawCam0xSgn)        ; .
                        call    SAEquSRPlusAQ               ; SA = normal x + drawcam x dot
                        jp      c,.Ovflw
                        ld      (p?_BnkXScaled),a             ; XX15Z = SA
                        ldCopyByte  varS, p?_BnkXScaledSign   ; .
                        ldCopyByte  p?_BnkYScaled, varR       ; SR = normal Y
                        ldCopyByte  p?_BnkXX12ySign, varS     ; .
                        ldCopyByte  p?_BnkDrawCam0yLo, varQ   ; AQ = drawcam y dot
                        ld      a,(p?_BnkDrawCam0ySgn)        ; .
                        call    SAEquSRPlusAQ               ; SA = normal y + drawcam y dot
                        jp      c,.Ovflw                    ; .
                        ld      (p?_BnkYScaled),a             ; XX15 Y = SA
                        ldCopyByte   varS, p?_BnkYScaledSign  ; .
; calculate dot product LL89
.DoneScalingIntoXX15:   ldCopyByte  p?_BnkXX12xLo, varQ       ; Q = norm X XX12
                        ld      a,(p?_BnkXScaled)             ; A = XX15 X
                        call    AequAmulQdiv256             ; A = XX15 X * XX 12 X
                        ld      (varT),a                    ; T = XX15 X * XX 12 X
                        ld      a,(p?_BnkXX12xSign)           ; S = sign of XX15 X * XX12 X
                        ld      hl,p?_BnkXScaledSign          ; .
                        xor     (hl)                        ; . 
                        ld      (varS),a                    ; .
                        ldCopyByte  p?_BnkXX12yLo, varQ       ; Q = norm Y XX12
                        ld      a,(p?_BnkYScaled)             ; A = XX15 Y
                        call    AequAmulQdiv256             ; A = XX15 Y * XX 12 Y
                        ld      (varQ),a                    ; Q = XX15 Y * XX 12 Y
                        ldCopyByte  varT,varR               ; R = XX15 X * XX 12 X
                        ld      a,  (p?_BnkXX12ySign)         ; A = sign of XX15 Y * XX 12 Y
                        ld      hl, p?_BnkYScaledSign         ; .
                        xor     (hl)                        ; .
                        call    SAEquSRPlusAQ               ; SA = SR+AQ = (X calc) + (Y calc)
                        ld      (varT),a                    ; T = usigned (X calc) + (Y calc)
                        ldCopyByte  p?_BnkXX12zLo, varQ       ; Q = XX12 Z
                        ld      a,  (p?_BnkZScaled)           ; A = XX15 Z
                        call    AequAmulQdiv256             ; A = XX12 Z * XX15 Z
                        ld      (varQ),a                    ; Q = XX12 Z * XX15 Z
                        ldCopyByte  varT, varR              ; R = usigned (X calc) + (Y calc)
                        ld      a,  (p?_BnkZScaledSign)       ; A = sign of XX12 Z * XX15 Z
                        ld      hl, p?_BnkXX12zSign           ; .
                        xor     (hl)                        ; .
                        call    SAEquSRPlusAQ               ; SA = ((X+Y signed)) (Z signed)
                        cp      0                           ; was the result 0, if so then there are scenarios where SAEquSRPlusAQ can return -ve 0
                        jr      z,.FaceNotVisible           ; in which case face is not visible
                        ld      a,(varS)                    ; if the cacl was a negative number then its visible
                        test    $80                         ; this should test S not A
                        jr      nz,.FaceVisible                                      ;        if dot product < 0 set face visible
.FaceNotVisible:        ld      a,(p?_CurrentNormIdx)
                        call    p?_SetFaceAHidden                                      ;           set face invisible
                        jp      .ProcessNormalLoopEnd                                ;        end if
.FaceVisible:           ld      a,(p?_CurrentNormIdx)
                        call    p?_SetFaceAVisible
.ProcessNormalLoopEnd:  ld      hl, p?_CurrentNormIdx
                        inc     (hl)                    ; move index pointer up by one
                        pop     bc
                        pop     hl                      ; get normal data pointer back
                        ld      a,4
                        add     hl,a                    ; move to next normal entry
                        ld      (varV),hl               ; save as we need it again
                        dec     b
                        jp      nz,.ProcessNormalsLoop
                        ret
                        ENDM
                        