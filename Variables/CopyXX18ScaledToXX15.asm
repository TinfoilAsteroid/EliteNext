LoadCraftToCamera:      ld      hl,UBnKxlo
                        ld      de,UBnkDrawCam0xLo
                        NineLDIInstrunctions                ; transfer 9 bytes
                        ret
                        
CopyCameraToXX15Signed:
        ld  hl,(UBnkDrawCam0xLo)
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
                        
CopyXX18ScaledToXX15:
CopyDrawCamToScaledMatrix:
        ldCopyByte  UBnkDrawCam0zSgn, UBnkZScaledSign   ; XX18+8 => XX15+5
        ldCopyByte  UBnkDrawCam0xLo,  UBnkXScaled       ; XX18+0 => XX15+0
        ldCopyByte  UBnkDrawCam0xSgn, UBnkXScaledSign   ; XX18+2 => XX15+1
        ldCopyByte  UBnkDrawCam0yLo,  UBnkYScaled       ; XX18+3 => XX15+2
        ldCopyByte  UBnkDrawCam0ySgn, UBnkYScaledSign   ; XX18+5 => XX15+3
        ldCopyByte  UBnkDrawCam0zLo,  UBnkZScaled       ; XX18+6 => XX15+4
        ret
		
CopyXX15ToXX18Scaled:
CopyScaledMatrixToDrawCam:
        ldCopyByte UBnkZScaledSign,   UBnkDrawCam0zSgn  ; XX15+5 => XX18+8  
        ldCopyByte UBnkXScaled,       UBnkDrawCam0xLo   ; XX15+0 => XX18+0  
        ldCopyByte UBnkXScaledSign,   UBnkDrawCam0xSgn  ; XX15+1 => XX18+2  
        ldCopyByte UBnkYScaled,       UBnkDrawCam0yLo   ; XX15+2 => XX18+3  
        ldCopyByte UBnkYScaledSign,   UBnkDrawCam0ySgn  ; XX15+3 => XX18+5  
        ldCopyByte UBnkZScaled,       UBnkDrawCam0zLo   ; XX15+4 => XX18+6  
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
