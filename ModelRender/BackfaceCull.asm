CurrentNormIdx  DB 0
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



ScaleDrawcam:           ld      a,(UBnkDrawCam0zHi)         ; if z hi is 0 then we have scaled XX18
                        IfAIsZeroGoto .ScaleDone            ; 
                        ld      hl,(UBnkDrawCam0xLo)        ; pull postition into registers
                        ld      de,(UBnkDrawCam0yLo)        ; we only pull in if needed to save fetches
                        ld      bc,(UBnkDrawCam0zLo)        ;
.ScaleNormalLoop:       inc     iyl                         ; Q goes up by one
                        ShiftHLRight1                       ; divide cam position by 2
                        ShiftDERight1                       ;
                        ShiftBCRight1                       ;
                        ld      a,b                         ; loop if not scaled down
                        IfANotZeroGoto .ScaleNormalLoop     ;
                        ld      (UBnkDrawCam0xLo),hl        ; save position back to XX18
                        ld      (UBnkDrawCam0yLo),de        ;
                        ld      (UBnkDrawCam0zLo),bc        ;
.ScaleDone:             ld      a,iyl
                        ld      (varXX17),a                  ; XX17 = normal scale factor for current ship adjusted for camera
                        ret

;;--BackFaceCull:
;;--;debug:jp debug                       
;;--; DEBUG  force for now
;;--;                        ld     a,MaxVisibility                 ; max visibility                                               ;;;; default max visibility
;;--;                        ld     (LastNormalVisible),a           ; XX4                                                          ;;;;                                    
;;--;
;;--; DEBUG                 
;;--                         ReturnIfMemisZero FaceCtX4Addr      ; get number of faces * 4      FaceCntX4 &  return if no faces
;;--                       ; break                       
;;--                        call    CopyRotmatToTransMat             ;#01; Load to Rotation Matrix to XX16, 16th bit is sign bit
;;--                        call    ScaleXX16Matrix197               ;#02; Normalise XX16
;;--                        call    LoadCraftToCamera                ;#04; Load Ship Coords to XX18
;;--                        call    InverseXX16                      ;#11; Invert rotation matrix
;;--
;;--.BackfaceLoop:          ld      a,(QAddr)                   ; a = ship normal scale factor
;;--                        ld      iyl,a                       ; iyl = scale factor
;;--; By this point XX18 = scaled draw cam and iyl = scale factor
;;--                        call    ScaleDrawcam                        
;;--                        call    CopyDrawCamToScaled
;;--.LL91:                  call    XX12EquNodeDotOrientation  ; xx12 = xx15 . XX16
;;--                        call    CopyXX12ScaledToXX18        ; now xx18 = xx15.xx16
;;--.PrepNormals:           ld      hl,UBnkHullNormals                                                                                                 ;;; V = address of Normal start
;;--                        ld      (varV),hl  
;;--                        ld      a,(FaceCtX4Addr)                                        ; For each face
;;--                        srl     a                                                       ;
;;--                        srl     a                                                       ;
;;--                        ld      b,a                                                     ;
;;--                        xor     a
;;--                        ld      (CurrentNormIdx),a                                                   ; used to increment up face incdex as b decrements
;;--ProcessNormalsLoop:     push    hl
;;--                        push    bc
;;--                        ld      a,(hl)                                                  ;     Get Face sign and visibility distance byte 
;;--                        and     $1F                                                     ;     if normal visibility range  < XX4
;;--                        ;JumpIfAGTENusng c,FaceVisible                                   ; commented out for debuggging the skip 
;;--.LL86:                  jp  .LL87 ; force testing of normals
;;--                        jp      .FaceVisible
;;--; This bit needs to be added to force face visible
;;--.LL87:                  call    CopyFaceToXX12
;;--                        ld      a,(XX17)
;;--                        JumpIfALTNusng 4,.LL92    
;;--.LL143:                 call    CopyXX18toXX15
;;--                        jp      .LL89
;;--.Ovflw:                 ld      a,(XX18)
;;--                        srl     a
;;--                        ld      (XX18),a
;;--                        ld      a,(XX18+6)
;;--                        srl     a
;;--                        ld      (XX18+6),a
;;--                        ld      a,(XX18+3)
;;--                        srl     a
;;--                        ld      (XX18+3),a
;;--                        ld      a,1                        ; set scale to 1 so when we fall through into LL92, we divide the normal vector by 2 as well
;;--.LL92:                   ld      b,a
;;--                        ldCopyByte  XX12,   UBnkXScaled
;;--                        ldCopyByte  XX12+2, UBnkYScaled
;;--                        ldCopyByte  XX12+4, UBnkZScaled
;;--.LL93                   dec     b
;;--                        jp      m, .LL94
;;--.LL93Loop:              ShiftMem8Right1 UBnkXScaled
;;--                        ShiftMem8Right1 UBnkYScaled
;;--                        ShiftMem8Right1 UBnkZScaled
;;--                        dec     b
;;--                        jp      p,.LL93Loop
;;--; Add normal to XX15
;;--.LL94:                  ldCopyByte  UBnkZScaled,     varR
;;--                        ldCopyByte  UBnkYScaled,     varS
;;--                        ldCopyByte  UBnkDrawCam0zLo, varQ
;;--                        ld      a,(XX18+8)
;;--                        call    SAEquSRPlusAQ
;;--                        jp      c,.Ovflw
;;--                        ld      (UBnkZScaled),a
;;--                        ldCopyByte  varS,            UBnkZScaledSign
;;--                        ldCopyByte  UBnkXScaled,     varR
;;--                        ldCopyByte  UBnkXScaledSign, varS
;;--                        ldCopyByte  UBnkDrawCam0xLo, varQ
;;--                        ld      a,(UBnkDrawCam0xSgn)
;;--                        call    SAEquSRPlusAQ
;;--                        jp      c,.Ovflw
;;--                        ld      (UBnkXScaled),a
;;--                        ldCopyByte  varS,            UBnkXScaledSign
;;--                        ldCopyByte  UBnkYScaled,     varR
;;--                        ldCopyByte  UBnkYScaledSign, varS
;;--                        ld      a,(UBnkDrawCam0ySgn)
;;--                        call    SAEquSRPlusAQ
;;--                        jp      c,.Ovflw
;;--                        ld      (UBnkYScaled),a
;;--                        ldCopyByte   varS, UBnkYScaledSign
;;--; calculate dot product:
;;--.LL89:                  ldCopyByte  UBnkXX12xLo, varQ
;;--                        ld      a,(UBnkXScaled)
;;--                        call    AequAmulQdiv256
;;--                        ld      (varT),a
;;--                        ld      a,(UBnkXX12xSign)
;;--                        ld      hl,UBnkXScaledSign
;;--                        xor     (hl)
;;--                        ld      (varS),a
;;--                        ldCopyByte  UBnkXX12yLo, varQ
;;--                        ld      a,(UBnkYScaled)
;;--                        call    AequAmulQdiv256
;;--                        ld      (varQ),a
;;--                        ldCopyByte  varT,varR
;;--                        ld      a,  (UBnkXX12ySign)
;;--                        ld      hl, UBnkYScaledSign
;;--                        xor     (hl)
;;--                        call    SAEquSRPlusAQ
;;--                        ld      (varT),a
;;--                        ldCopyByte  UBnkXX12zLo, varQ
;;--                        ld      a,  (UBnkZScaled)
;;--                        call    AequAmulQdiv256
;;--                        ld      (varQ),a
;;--                        ldCopyByte  varT, varR
;;--                        ld      a,  (UBnkZScaledSign)
;;--                        ld      hl, UBnkXX12zSign
;;--                        xor     (hl)
;;--                        call    SAEquSRPlusAQ           ; now A = dot product
;;--                        test    $80
;;--                        jr      nz,.FaceVisible                                      ;        if dot product < 0 set face visible
;;--.FaceNotVisible:         ld          a,(CurrentNormIdx)
;;--                        call        SetFaceAHidden                                      ;           set face invisible
;;--                        jp          ProcessNormalLoopEnd                                ;        end if
;;--.FaceVisible:            ld          a,(CurrentNormIdx)
;;--                        call        SetFaceAVisible
;;--ProcessNormalLoopEnd:   ld          hl, CurrentNormIdx
;;--                        inc         (hl)                    ; move index pointer up by one
;;--                        pop         bc
;;--                        pop         hl                      ; get normal data pointer back
;;--                        ld          a,4
;;--                        add         hl,a                    ; move to next normal entry
;;--                        ld          (varV),hl               ; save as we need it again
;;--                        dec         b
;;--                        jp          nz,ProcessNormalsLoop
;;--                        ret   
                        
                        
                        

;;;;;                        call    CopyFaceToXX15                                          ;        Get Face data into XX12
;;;;;                        ld      a,(UBnkXScaledSign)    
;;;;;                        call    XX12EquNodeDotOrientation        
;;;;;                        ld      a,(UBnkXX12zSign)
;;;;;                        test    $80
;;;;;                        jp      nz, FaceVisible                           
;;;;;.BackfaceLoop:          ld      a,(QAddr)                   ; a = ship normal scale factor
;;;;;                        ld      iyl,a                       ; iyl = scale factor
;;;;;.ScaleNormal:           ld      a,(UBnkDrawCam0zHi)         ; if z hi is 0 then we have scaled XX18
;;;;;                        IfAIsZeroGoto .ScaleDone            ; 
;;;;;                        ld      hl,(UBnkDrawCam0xLo)        ; pull postition into registers
;;;;;                        ld      de,(UBnkDrawCam0yLo)        ; we only pull in if needed to save fetches
;;;;;                        ld      bc,(UBnkDrawCam0zLo)        ;
;;;;;.ScaleNormalLoop:       inc     iyl                         ; Q goes up by one
;;;;;                        ShiftHLRight1                       ; divide cam position by 2
;;;;;                        ShiftDERight1                       ;
;;;;;                        ShiftBCRight1                       ;
;;;;;                        ld      a,b                         ; loop if not scaled down
;;;;;                        IfANotZeroGoto .ScaleNormalLoop     ;
;;;;;                        ld      (UBnkDrawCam0xLo),hl        ; save position back to XX18
;;;;;                        ld      (UBnkDrawCam0yLo),de        ;
;;;;;                        ld      (UBnkDrawCam0zLo),bc        ;
;;;;;; By this point XX18 = scaled draw cam and iyl = scale factor
;;;;;.ScaleDone:             ld      a,iyl
;;;;;                        ld      (varXX17),a                  ; XX17 = normal scale factor for current ship adjusted for camera
;;;;;    call    CopyRotmatToTransMat             ;#01; Load to Rotation Matrix to XX16, 16th bit is sign bit
;;;;;    call    ScaleXX16Matrix197               ;#02; Normalise XX16
;;;;;;    call    LoadCraftToCamera                ;#04; Load Ship Coords to XX18
;;;;;    call    InverseXX16                      ;#11; Invert rotation matrix
;;;;;                        
;;;;;                        
;;;;;                        
;;;;;                        call    CopyXX18toXX15              ; copy DrawCam to Xx15
;;;;;                        call    XX12EquNodeDotOrientation   ; Xx12 = XX15 (face normal) dot rotation matrix
;;;;;                        call    CopyXX12ScaledToXX18              ; now XX18 = dot product
;;;;;.ProcessNormals:        ld      hl,UBnkHullNormals                                                                                                 ;;; V = address of Normal start
;;;;;                        ld      (varV),hl  
;;;;;                        ld      a,(FaceCtX4Addr)                                        ; For each face
;;;;;                        srl     a                                                       ;
;;;;;                        srl     a                                                       ;
;;;;;                        ld      b,a                                                     ;
;;;;;                        xor     a
;;;;;                        ld      (CurrentNormIdx),a                                                   ; used to increment up face incdex as b decrements
;;;;;.ProcessNormalsLoop:    push    hl
;;;;;                        push    bc
;;;;;                        ld      a,(hl)                                                  ;     Get Face sign and visibility distance byte 
;;;;;                        and     $1F                                                     ;     if normal visibility range  < XX4
;;;;;                        ;JumpIfAGTENusng c,FaceVisible                                   ; commented out for debuggging the skip 
;;;;;.CheckFaceVisibility:   call    CopyFaceToXX12              ; Get Face data into XX12
;;;;;                        ld      a,(varXX17)                  ; if scale factor < 4 then skip next bit
;;;;;                        JumpIfALTNusng 4,.LL92              
;;;;;.LargeScaleFactor:      call    CopyXX18toXX15
;;;;;                        jp      .LL89
;;;;;.Ovflw:                 ld      a,(XX18)
;;;;;                        srl     a
;;;;;                        ld      (XX18),a
;;;;;                        ld      a,(XX18+6)
;;;;;                        srl     a
;;;;;                        ld      (XX18+6),a
;;;;;                        ld      a,(XX18+3)
;;;;;                        srl     a
;;;;;                        ld      (XX18+3),a
;;;;;                        ld      a,1                        ; set scale to 1 so when we fall through into LL92, we divide the normal vector by 2 as well
;;;;;.LL92:                  ld      b,a
;;;;;                        ldCopyByte  XX12,   UBnkXScaled
;;;;;                        ldCopyByte  XX12+2, UBnkYScaled
;;;;;                        ldCopyByte  XX12+4, UBnkZScaled
;;;;;.LL93                   dec     b
;;;;;                        jp      m, .LL94
;;;;;.LL93Loop:              ShiftMem8Right1 UBnkXScaled
;;;;;                        ShiftMem8Right1 UBnkYScaled
;;;;;                        ShiftMem8Right1 UBnkZScaled
;;;;;                        dec     b
;;;;;                        jp      p,.LL93Loop
;;;;;.LL94:                  ldCopyByte  UBnkZScaled,     varR
;;;;;                        ldCopyByte  UBnkYScaled,     varS
;;;;;                        ldCopyByte  UBnkDrawCam0zLo, varQ
;;;;;                        ld      a,(XX18+8)
;;;;;                        call    SAEquSRPlusAQ
;;;;;                        jp      c,.Ovflw
;;;;;                        ld      (UBnkZScaled),a
;;;;;                        ldCopyByte  varS,            UBnkZScaledSign
;;;;;                        ldCopyByte  UBnkXScaled,     varR
;;;;;                        ldCopyByte  UBnkXScaledSign, varS
;;;;;                        ldCopyByte  UBnkDrawCam0xLo, varQ
;;;;;                        ld      a,(UBnkDrawCam0xSgn)
;;;;;                        call    SAEquSRPlusAQ
;;;;;                        jp      c,.Ovflw
;;;;;                        ld      (UBnkXScaled),a
;;;;;                        ldCopyByte  varS,            UBnkXScaledSign
;;;;;                        ldCopyByte  UBnkYScaled,     varR
;;;;;                        ldCopyByte  UBnkYScaledSign, varS
;;;;;                        ld      a,(UBnkDrawCam0ySgn)
;;;;;                        call    SAEquSRPlusAQ
;;;;;                        jp      c,.Ovflw
;;;;;                        ld      (UBnkYScaled),a
;;;;;                        ldCopyByte   varS, UBnkYScaledSign
;;;;;.LL89:                  ldCopyByte  UBnkXX12xLo, varQ
;;;;;                        ld      a,(UBnkXScaled)
;;;;;                        call    AequAmulQdiv256
;;;;;                        ld      (varT),a
;;;;;                        ld      a,(UBnkXX12xSign)
;;;;;                        ld      hl,UBnkXScaledSign
;;;;;                        xor     (hl)
;;;;;                        ld      (varS),a
;;;;;                        ldCopyByte  UBnkXX12yLo, varQ
;;;;;                        ld      a,(UBnkYScaled)
;;;;;                        call    AequAmulQdiv256
;;;;;                        ld      (varQ),a
;;;;;                        ldCopyByte  varT,varR
;;;;;                        ld      a,  (UBnkXX12ySign)
;;;;;                        ld      hl, UBnkYScaledSign
;;;;;                        xor     (hl)
;;;;;                        call    SAEquSRPlusAQ
;;;;;                        ld      (varT),a
;;;;;                        ldCopyByte  UBnkXX12zLo, varQ
;;;;;                        ld      a,  (UBnkZScaled)
;;;;;                        call    AequAmulQdiv256
;;;;;                        ld      (varQ),a
;;;;;                        ldCopyByte  varT, varR
;;;;;                        ld      a,  (UBnkZScaledSign)
;;;;;                        ld      hl, UBnkXX12zSign
;;;;;                        xor     (hl)
;;;;;                        call    SAEquSRPlusAQ           ; now A = dot product
;;;;;                        test    $80
;;;;;                        jr      nz,.FaceVisible
;;;;;.FaceNotVisible:        ld      a,(CurrentNormIdx)
;;;;;                        call    SetFaceAHidden                                      ;           set face invisible
;;;;;                        jp      .ProcessNormalLoopEnd                                ;        end if
;;;;;.FaceVisible:           ld      a,(CurrentNormIdx)
;;;;;                        call    SetFaceAVisible
;;;;;.ProcessNormalLoopEnd:   ld      hl, CurrentNormIdx
;;;;;                        inc         (hl)                    ; move index pointer up by one
;;;;;                        pop         bc
;;;;;                        pop         hl                      ; get normal data pointer back
;;;;;                        ld          a,4
;;;;;                        add         hl,a                    ; move to next normal entry
;;;;;                        ld          (varV),hl               ; save as we need it again
;;;;;                        dec         b
;;;;;                        jp          nz,.ProcessNormalsLoop
;;;;;                        ret                                 ; If Y >= XX20 all normals' visibilities set, onto Transpose. return
;;;;;

CullV2:                 ReturnIfMemisZero FaceCtX4Addr      ;   
                       ; break                          
                        call    CopyRotmatToTransMat        ; XX16 = UBNKRotMat    
                        call    ScaleXX16Matrix197          ; scale rotation matrix in XX16
                        call    LoadCraftToCamera           ; XX18 = camera
                        ;call    CopyCameraToXX15Signed      ; Copy the camera to XX15 as signed 15 bit
.BackfaceLoop:          ld      a,(QAddr)                   ;  
                        ld      iyl,a                       ; iyl = scale factor
; By this point XX18 = scaled draw cam and iyl = scale factor
                        call    ScaleDrawcam                ; XX18 = scaled camera XX17 = scale
                        call    CopyCameraToXX15Signed      ; Xx18 -> xx15 sign + 15 bit
.LL91:                  call    XX12EquNodeDotXX16          ; xx12 = Scaled Camera . Rotation matrix (Note Xx16 no Xx16 inv)
                        call    CopyXX12ScaledToXX18        ; now xx18 = XX12 = xx15.xx16
.PrepNormals:           ld      hl,UBnkHullNormals                                                                                                 ;;; V = address of Normal start
                        ld      (varV),hl  
                        ld      a,(FaceCtX4Addr)                                        ; For each face
                        srl     a                                                       ;
                        srl     a                                                       ;
                        ld      b,a                                                     ;
                        xor     a
                        ld      (CurrentNormIdx),a                                                   ; used to increment up face incdex as b decrements
.ProcessNormalsLoop:     push    hl
                        push    bc
.LL86:                  ld      a,(hl)                                                  ;     Get Face sign and visibility distance byte 
                        and     $1F                                                     ;     if normal visibility range  < XX4
                        JumpIfAGTENusng c,.FaceVisible                                  ; commented out for debuggging the skip 
; This bit needs to be added to force face visible
.LL87:                  call    CopyFaceToXX12              ; XX12 = normal (repolaced scale version) as a working copy
                        ld      a,(XX17)                    ; a = q scale XX17 cauclated by the call to ScaleDrawcam
                        ld      b,a
                        JumpIfALTNusng 4,.ScaleNormByXX17   ; if q >= 4 then is so big we don;t factor in + normal for dot product
.LL143:                 call    CopyXX18toXX15              ; and we just set XX15 = scaled Camera dot rotation matrix
                        jp      .DoneScalingIntoXX15        ; Now Process XX12 normal
.Ovflw:                 ld      a,(UBnkDrawCam0xLo)         ; divide camera by 2 if overflow
                        srl     a                           ; which is held in XX18
                        ld      (UBnkDrawCam0xLo),a         ; .
                        ld      a,(UBnkDrawCam0zLo)         ; .
                        srl     a                           ; .
                        ld      (UBnkDrawCam0zLo),a         ; .
                        ld      a,(UBnkDrawCam0yLo)         ; .
                        srl     a                           ; .
                        ld      (UBnkDrawCam0yLo),a        ; .
.ScaleXScaledAgain:     ld      b,1                         ; set scale to 1 so we divide original normal by 2 into face and try again and hope we didn't scaled down XX12 earlier so if we did then we must be in the do doo as the object was obscenely large and very close
                        ShiftMem8Right1 UBnkXScaled         ; Divide XX15 by 2^B
                        ShiftMem8Right1 UBnkYScaled         ; 
                        ShiftMem8Right1 UBnkZScaled         ; 
; if we jumped to here scale factor < 4 so we copy in normal to XX15 (scaled) LL92
.ScaleNormByXX17:       ;ld      b,a
                        call    CopyXX12toXX15
.LL93                   dec     b
                        jp      m, .ScaledNorm
.LL93Loop:              ShiftMem8Right1 UBnkXScaled        ; Divide XX15 by 2^B, I think this should be really XX12 and is a bug in the original code
                        ShiftMem8Right1 UBnkYScaled        ; 
                        ShiftMem8Right1 UBnkZScaled        ; 
                        dec     b                          ; 
                        jp      p,.LL93Loop                ; Now we have XX15 as scaled Normal, XX15 as camera, don;t really knwo why as cals work on XX12 and XX18
.ScaledNorm:            ;ORIG CODE DOES NOT HAVE THIS call    CopyXX15ToXX12 ; DEBUG as XX15 shoudl be a sacled nromal
; Add normal to XX15
; if we jumped here direct from LL143 then XX15 = drawcam scaled by Q, XX12 = face normal unscaled, XX18 = drawcam scaled also
; if we jumped here via scaling       then XX15 = normal scaled by Q,  XX12 = face normal unscaled, XX16 = drawcam scaled
; if we hit an overflow               then XX15 = drawcam scaled by Q  XX12 = face normal unscaled, XX18 = (drawcam scaled / 2 ) / 2^ nbr overflows (if we cam in vai scaling then its a mess?
; So LL94 is wrong as it shoud be operating on XX12 not XX15
.LL94:                  ldCopyByte UBnkZScaled, varR        ; ldCopyByte  UBnkZScaled,     varR  ; if we jumped direct XX15 = drawcam scaled, Xx12 = normal xx18 = drawcam
                        ldCopyByte UBnkXX12zSign, varS      ; ldCopyByte  UBnkYScaled,     varS  ; if we did scaling then xx15 = norm scaled XX18 = drawcam
                        ldCopyByte  UBnkDrawCam0zLo, varQ   ; AQ = drawcam Z signed
                        ld      a,(UBnkDrawCam0zSgn)        ; .
                        call    SAEquSRPlusAQ               ; SA = drawcam Z dot + z
                        jp      c,.Ovflw
                        ld      (UBnkZScaled),a             ; XX15Z = SA
                        ldCopyByte  varS, UBnkZScaledSign   ;
                        ldCopyByte  UBnkXScaled,     varR   ; SR = normal X
                        ldCopyByte  UBnkXX12xSign,   varS   ; .
                        ldCopyByte  UBnkDrawCam0xLo, varQ   ; AQ = drawcam x dot
                        ld      a,(UBnkDrawCam0xSgn)        ; .
                        call    SAEquSRPlusAQ               ; SA = normal x + drawcam x dot
                        jp      c,.Ovflw
                        ld      (UBnkXScaled),a             ; XX15Z = SA
                        ldCopyByte  varS, UBnkXScaledSign   ; .
                        ldCopyByte  UBnkYScaled, varR       ; SR = normal Y
                        ldCopyByte  UBnkXX12ySign, varS     ; .
                        ldCopyByte  UBnkDrawCam0yLo, varQ   ; AQ = drawcam y dot
                        ld      a,(UBnkDrawCam0ySgn)        ; .
                        call    SAEquSRPlusAQ               ; SA = normal y + drawcam y dot
                        jp      c,.Ovflw                    ; .
                        ld      (UBnkYScaled),a             ; XX15 Y = SA
                        ldCopyByte   varS, UBnkYScaledSign  ; .
; calculate dot product LL89
.DoneScalingIntoXX15:   ldCopyByte  UBnkXX12xLo, varQ       ; Q = norm X XX12
                        ld      a,(UBnkXScaled)             ; A = XX15 X
                        call    AequAmulQdiv256             ; A = XX15 X * XX 12 X
                        ld      (varT),a                    ; T = XX15 X * XX 12 X
                        ld      a,(UBnkXX12xSign)           ; S = sign of XX15 X * XX12 X
                        ld      hl,UBnkXScaledSign          ; .
                        xor     (hl)                        ; . 
                        ld      (varS),a                    ; .
                        ldCopyByte  UBnkXX12yLo, varQ       ; Q = norm Y XX12
                        ld      a,(UBnkYScaled)             ; A = XX15 Y
                        call    AequAmulQdiv256             ; A = XX15 Y * XX 12 Y
                        ld      (varQ),a                    ; Q = XX15 Y * XX 12 Y
                        ldCopyByte  varT,varR               ; R = XX15 X * XX 12 X
                        ld      a,  (UBnkXX12ySign)         ; A = sign of XX15 Y * XX 12 Y
                        ld      hl, UBnkYScaledSign         ; .
                        xor     (hl)                        ; .
                        call    SAEquSRPlusAQ               ; SA = SR+AQ = (X calc) + (Y calc)
                        ld      (varT),a                    ; T = usigned (X calc) + (Y calc)
                        ldCopyByte  UBnkXX12zLo, varQ       ; Q = XX12 Z
                        ld      a,  (UBnkZScaled)           ; A = XX15 Z
                        call    AequAmulQdiv256             ; A = XX12 Z * XX15 Z
                        ld      (varQ),a                    ; Q = XX12 Z * XX15 Z
                        ldCopyByte  varT, varR              ; R = usigned (X calc) + (Y calc)
                        ld      a,  (UBnkZScaledSign)       ; A = sign of XX12 Z * XX15 Z
                        ld      hl, UBnkXX12zSign           ; .
                        xor     (hl)                        ; .
                        call    SAEquSRPlusAQ               ; SA = ((X+Y signed)) (Z signed)
                        cp      0                           ; was the result 0, if so then there are scenarios where SAEquSRPlusAQ can return -ve 0
                        jr      z,.FaceNotVisible           ; in which case face is not visible
                        ld      a,(varS)                    ; if the cacl was a negative number then its visible
                        test    $80                         ; this should test S not A
                        jr      nz,.FaceVisible                                      ;        if dot product < 0 set face visible
.FaceNotVisible:         ld          a,(CurrentNormIdx)
                        call        SetFaceAHidden                                      ;           set face invisible
                        jp          .ProcessNormalLoopEnd                                ;        end if
.FaceVisible:            ld          a,(CurrentNormIdx)
                        call        SetFaceAVisible
.ProcessNormalLoopEnd:  ld          hl, CurrentNormIdx
                        inc         (hl)                    ; move index pointer up by one
                        pop         bc
                        pop         hl                      ; get normal data pointer back
                        ld          a,4
                        add         hl,a                    ; move to next normal entry
                        ld          (varV),hl               ; save as we need it again
                        dec         b
                        jp          nz,.ProcessNormalsLoop
                        ret   
                        