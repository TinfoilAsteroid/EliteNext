SetLastFaceVisible: MACRO
                    ld      a,$FF                       ; last normal is always visible                                                         ;;; 
                    ld      (UbnkFaceVisArray+15),a     ; XX2+15                                                                                ;;; 
                    ENDM

SetLastFaceVisCall: ld      a,$FF 
                    ld      (UbnkFaceVisArray+15),a
                    ret

CheckIfExplodingCall:
; DEBUG TODO turn into MACRO later
; Sets Z flag to true if only some faces are visible
; Clears Z flag if exploding so all faces should be rendered
        ld      a,(explDsp)                 ; INWK+31                                                                               ;;; If bit 5 of exploding state is clear
;;DEBUG
        or      $FF ; force bit 5 set so exploding
        ld      (explDsp),a
;;DEBUG        
        ld      c,a                         ; save explDsp into c                                                                   ;;; 
        and     $20                         ; mask bit5 exploding                                                                   ;;; 
        ret
        
        
DrawForwardsIXL:
DrawForwards:
LL17:                                       ; draw Wireframe (including nodes exploding)                                            ;;; LL17 draw Wireframe 
; Copy the three orientation vectors into XX16
LL15:   call    CopyRotmatToTransMat        ; Copy Ship rotation to XX16                                                                                          ;;; load object position to camera matrix XX16 			::LL91 (ish)
;;;;LL21:   call    NormaliseTransMat       ; Normalise XX16
LL91lc: call    LoadCraftToCamera           ; Load Ship Coords to XX18
; ......................................................                                                                            ;;; 
LastNormalAlwaysVisible:      
        call    SetLastFaceVisCall          ; DEBUG TODO revert back to MACRO later                                                                                                          ;;; Set last Normal to visible FF regarless
; HEre original does LDY 12
; ......................................................                                                                            ;;; (Originally loaded faces count here and stored in B, but will remove to simplify code)
CheckIfExplodingState:
        call    CheckIfExplodingCall
        jr      z,CullBackFaces             ; EE29 no, only Some visible                                                            ;;;    Goto EE29 - Only some faces visible
; ......................................................                                                                            ;;; else
ItIsExploding:
MakeAllFacesVisible:                                                                                                                        ;;;    Set all faces in XX0 visible
        call    SetAllFacesVisible          ; code point EE30                                                                      ;;; 
        ld      b,0                         ; X = 0                                                                                 ;;;
        ldWriteZero LastNormalVisible       ; XX4  \ visibility                                                                     ;;;    XX4 visibility = 0
LL41:                                       ; visibilities now set in XX2,X Transpose matrix.                                       ;;; 
        jp      TransposeMatrix             ; LL42 \ jump to transpose matrix and onwards                                           ;;;    goto LL42
; ......................................................                                                                            ;;; 
CullBackFaces:
EE29Entry:
        call    BackFaceCull
;-- All normals' visibilities now set in XX2,X                                                                                      ;;;
TransposeMatrix:
LL42:	                                    ; DO nodeX-Ycoords their comment  \  TrnspMat                                           ;;; ......................................................
        call    InverseXX16         


        call    ProcessNodes                ; Loop through and determine visibility based on faces and position
DrawResults:
        call    PrepLines                   ; LL72, process lines and clip
        call    DrawLines                   ; Need to plot all lines
        ret
