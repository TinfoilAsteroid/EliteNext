LoadCraftToCamera:      ld      hl,(UBnKxlo)            ; UBnKxlo, UBnKxhi
                        ld      de,(UBnKxsgn)           ; UBnKxsgn, UBnKylo
                        ld      bc,(UBnKyhi)            ; UBnKyhi, UBnKysgn
                        ld      (UBnkDrawCam0xLo),hl    ; UBnkDrawCam0xLo, UBnkDrawCam0xHi
                        ld      (UBnkDrawCam0xSgn),de   ; UBnkDrawCam0xSgn,UBnkDrawCam0yLo
                        ld      (UBnkDrawCam0yHi),bc    ; UBnkDrawCam0yHi, UBnkDrawCam0ySgn
                        
                        ld      hl,(UBnKzlo)            ; UBnKzlo, UBnKzhi
                        ld      a,(UBnKzsgn)             ; UBnKzlo
                        ld      (UBnkDrawCam0zLo),hl    ; UBnkDrawCam0zLo, UBnkDrawCam0zHi
                        ld      (UBnkDrawCam0zSgn),a    ; UBnkDrawCam0zSgn
                        ret
                        ret
                        
CopyCameraToXX15Signed: ld  hl,(UBnkDrawCam0xLo)
                        ld  a,(UBnkDrawCam0xSgn)
                        or  h
                        ld  h,a
                        ld  (UBnkXScaled),hl
                        ld  hl,(UBnkDrawCam0yLo)
                        ld  a,(UBnkDrawCam0ySgn)
                        or  h
                        ld  h,a
                        ld  (UBnkYScaled),hl
                        ld  hl,(UBnkDrawCam0zLo)
                        ld  a,(UBnkDrawCam0zSgn)
                        or  h
                        ld  h,a
                        ld  (UBnkZScaled),hl
                        ret
                        
		
XX15EquXX15AddXX18:
LL94Z:   
        ld      h,0                                                     ;           AddZ = FaceData (XX12)z +  ShipPos (XX18)z                                         
        ld      d,0                                                     ;           
        ld      a,(UBnkZScaled)                                         ;           
        ld      l,a                                                     ;           
        ld      a,(UBnkZScaledSign)                                     ;           
        ld      b,a                                                     ;           
        ld      a,(UBnkDrawCam0zLo)                                     ;           
        ld      e,a                                                     ;           
        ld      a,(UBnkDrawCam0zSgn)                                    ;
        ld      c,a                                                     ;
        call    ADDHLDESignBC                                           ;           
        ld      b,a                                                     ;           
        ld      a,h                                                     ;           
        ld      a,b                                                     ;           else  Scaled (XX15) Z = AddZ
        ld      (UBnkZScaledSign),a                                     ;           
        ld      a,l                                                     ;           
        ld      (UBnkZScaled),a                                         ;           endif
LL94X:   
        ld      h,0                                                     ;           AddZ = FaceData (XX12)z +  ShipPos (XX18)z                                         
        ld      d,0                                                     ;           
        ld      a,(UBnkXScaled)                                         ;           
        ld      l,a                                                     ;           
        ld      a,(UBnkXScaledSign)                                     ;           
        ld      b,a                                                     ;           
        ld      a,(UBnkDrawCam0xLo)                                     ;           
        ld      e,a                                                     ;           
        ld      a,(UBnkDrawCam0xSgn)                                    ;
        ld      c,a                                                     ;
        call    ADDHLDESignBC                                           ;           
        ld      b,a                                                     ;           
        ld      a,h                                                     ;           
        ld      a,b                                                     ;           else  Scaled (XX15) Z = AddZ
        ld      (UBnkXScaledSign),a                                     ;           
        ld      a,l                                                     ;           
        ld      (UBnkXScaled),a                                         ;           endif                                                                          
LL94Y:   
        ld      h,0                                                     ;           AddZ = FaceData (XX12)z +  ShipPos (XX18)z                                         
        ld      d,0                                                     ;           
        ld      a,(UBnkYScaled)                                         ;           
        ld      l,a                                                     ;           
        ld      a,(UBnkYScaledSign)                                     ;           
        ld      b,a                                                     ;           
        ld      a,(UBnkDrawCam0yLo)                                     ;           
        ld      e,a                                                     ;           
        ld      a,(UBnkDrawCam0ySgn)                                    ;
        ld      c,a                                                     ;
        call    ADDHLDESignBC                                           ;           
        ld      b,a                                                     ;           
        ld      a,h                                                     ;           
        ld      a,b                                                     ;           else  Scaled (XX15) Z = AddZ
        ld      (UBnkYScaledSign),a                                     ;           
        ld      a,l                                                     ;           
        ld      (UBnkYScaled),a                                         ;
        ret
