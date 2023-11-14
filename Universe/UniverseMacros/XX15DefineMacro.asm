
XX15DefineMacro: MACRO   p?
        
p?_BnkXScaled                  DB  0               ; XX15+0Xscaled
p?_BnkXScaledSign              DB  0               ; XX15+1xsign
p?_BnkYScaled                  DB  0               ; XX15+2yscaled
p?_BnkYScaledSign              DB  0               ; XX15+3ysign
p?_BnkZScaled                  DB  0               ; XX15+4zscaled
p?_BnkZScaledSign              DB  0               ; XX15+5zsign
p?_XX1576                      DW  0    ; y2

p?_XX15:                       equ p?_BnkXScaled
p?_XX15VecX:                   equ p?_XX15
p?_XX15VecY:                   equ p?_XX15+1
p?_XX15VecZ:                   equ p?_XX15+2
p?_BnkXPoint:                  equ p?_XX15
p?_BnkXPointLo:                equ p?_XX15+0
p?_BnkXPointHi:                equ p?_XX15+1
p?_BnkXPointSign:              equ p?_XX15+2
p?_BnkYPoint:                  equ p?_XX15+3
p?_BnkYPointLo:                equ p?_XX15+3
p?_BnkYPointHi:                equ p?_XX15+4
p?_BnkYPointSign:              equ p?_XX15+5    

p?_XX1510                      EQU p?_BnkXScaled    ; x1 as a 16-bit coordinate (x1_hi x1_lo)
p?_XX1532                      EQU p?_BnkYScaled   ; y1 as a 16-bit coordinate (y1_hi y1_lo)
p?_XX1554                      EQU p?_BnkZScaled   ; x2
p?_XX1554p1                    EQU p?_XX1554+1
p?_XX15X1lo                    EQU p?_XX1510
p?_XX15X1hi                    EQU p?_XX1510+1
p?_XX15Y1lo                    EQU p?_XX1532
p?_XX15Y1hi                    EQU p?_XX1532+1
p?_XX15X2lo                    EQU p?_XX1554
p?_XX15X2hi                    EQU p?_XX1554+1
p?_XX15Y2lo                    EQU p?_XX1210
p?_XX15Y2hi                    EQU p?_XX1210+1
p?_XX15PlotX1                  EQU p?_XX15
p?_XX15PlotY1                  EQU p?_XX15+1
p?_XX15PlotX2                  EQU p?_XX15+2
p?_XX15PlotY2                  EQU p?_XX15+3    

p?_BnkX1                       equ p?_XX15
p?_Bnkx1Lo                     equ p?_XX15
p?_Bnkx1Hi                     equ p?_XX15+1
p?_BnkY1                       equ p?_XX15+2
p?_Bnky1Lo                     equ p?_XX15+2
p?_BnkY1Hi                     equ p?_XX15+3
p?_BnkX2                       equ p?_XX15+4
p?_BnkX2Lo                     equ p?_XX15+4
p?_BnkX2Hi                     equ p?_XX15+5

; Repurposed XX15 pre clip plines
p?_BnkPreClipX1               equ p?_XX15+0
p?_BnkPreClipY1               equ p?_XX15+2
p?_BnkPreClipX2               equ p?_XX15+4
p?_BnkPreClipY2               equ p?_XX15+6
; Repurposed XX15 post clip lines
p?_BnkNewX1                   equ p?_XX15+0
p?_BnkNewY1                   equ p?_XX15+1
p?_BnkNewX2                   equ p?_XX15+2
p?_BnkNewY2                   equ p?_XX15+3

                            ENDM
; Backface cull        
; is the angle between the ship -> camera vector and the normal of the face as long as both are unit vectors soo we can check that normal z > 0
; normal vector = cross product of ship ccordinates 
;

CopyFaceToXX15Macro     MACRO p?
p?_CopyFaceToXX15:ld      a,(hl)                      ; get Normal byte 0                                                                    ;;;     if visibility (bits 4 to 0 of byte 0) > XX4
                        ld      b,a                                                    ;;;      
                        and     SignOnly8Bit
                        ld      (p?_BnkXScaledSign),a           ; write Sign bits to x sign                                                            ;;;
                        ld      a,b
                        sla     a                           ; move y sign to bit 7                                                                 ;;;   copy sign bits to XX12
                        ld      b,a
                        and     SignOnly8Bit
                        ld      (p?_BnkYScaledSign),a           ;                                                                                      ;;;
                        ld      a,b
                        sla     a                           ; move y sign to bit 7                                                                 ;;;   copy sign bits to XX12
                        and     SignOnly8Bit
                        ld      (p?_BnkZScaledSign),a           ;                                                                                      ;;;
                        inc     hl                          ; move to X ccord
                        ld      a,(hl)                      ;                                                                                      ;;;   XX12 x,y,z lo = Normal[loop].x,y,z
                        ld      (p?_BnkXScaled),a                                                                                                    ;;;
                        inc     hl                                                                                                                 ;;;
                        ld      a,(hl)                      ;                                                                                      ;;;
                        ld      (p?_BnkYScaled),a                                                                                                    ;;;
                        inc     hl                                                                                                                 ;;;
                        ld      a,(hl)                      ;                                                                                      ;;;
                        ld      (p?_BnkZScaled),a     
                        ret
                        ENDM


;;;     Byte 0 = X magnitide with origin at middle of ship
;;;     Byte 1 = Y magnitide with origin at middle of ship      
;;;     Byte 2 = Z magnitide with origin at middle of ship          
;;;     Byte 3 = Sign Bits of Vertex 7=X 6=Y 5 = Z 4 - 0 = visibility beyond which vertix is not shown
CopyNodeToXX15Macro:    MACRO p?
p?_CopyNodeToXX15:
                        ldCopyByte  hl, p?_BnkXScaled                     ; Load into XX15                                                                     Byte 0;;;     XX15 xlo   = byte 0
                        inc         hl
                        ldCopyByte  hl, p?_BnkYScaled                     ; Load into XX15                                                                     Byte 0;;;     XX15 xlo   = byte 0
                        inc         hl
                        ldCopyByte  hl, p?_BnkZScaled                     ; Load into XX15                                                                     Byte 0;;;     XX15 xlo   = byte 0
                        inc         hl
p?_PopulateXX15SignBits: 
; Simplfied for debugging, needs optimising back to original DEBUG TODO
                        ld          a,(hl)
                        ld          c,a                                 ; copy sign and visibility to c
                        ld          b,a
                        and         $80                                 ; keep high 3 bits
                        ld          (p?_BnkXScaledSign),a                 ; Copy Sign Bits                                                            ;;;     
                        ld          a,b
                        and         $40
                        sla         a                                   ; Copy Sign Bits                                                            ;;;     
                        ld          (p?_BnkYScaledSign),a                 ; Copy Sign Bits                                                            ;;;     
                        ld          a,b
                        and         $20
                        sla         a                                   ; Copy Sign Bits                                                            ;;;     
                        sla         a                                   ; Copy Sign Bits                                                            ;;;     
                        ld          (p?_BnkZScaledSign),a                 ; Copy Sign Bits                                                            ;;;     
                        ld          a,c                                 ; returns a with visibility sign byte
                        and         $1F                                 ; visibility is held in bits 0 to 4                                                              ;;;     A = XX15 Signs AND &1F (to get lower 5 visibility)
                        ld          (varT),a                            ; and store in varT as its needed later
                        ret
                        ENDM
