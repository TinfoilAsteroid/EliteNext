; Universe code nothing reached (2026-11-20, the Universe TODOs): kept for reference.

; ---- from univ_ship_data.asm
CopyPlanetGlobaltoSpaceStation:
                        ld      hl,ParentPlanetX
                        ld      de,UBnKxlo
                        ld      bc,3*3
                        ldir
                        ret

; ---- from univ_ship_data.asm
CopySpaceStationtoPlanetGlobal:
                        ld      hl,UBnKxlo
                        ld      de,ParentPlanetX
                        ld      bc,3*3
                        ldir
                        ret

; ---- from univ_ship_data.asm
CopyParentPlanettoUnivTarget:
                        ld      hl,ParentPlanetX                ; Copy the interface data to Univ (interface may be scapped later to just use Planet X Pos
                        jp      copyHlToTargetXPos

; ---- from univ_ship_data.asm
CopyPlanettoUnivTarget: ld      hl,PlanetXPos                   ; Copy planet position to local target data
                        jp      copyHlToTargetXPos

; ---- from univ_ship_data.asm
CopySpaceStationtoUniv: ld      hl,StationXPos                  ; Copy sun position to local target data
                        jp      copyHlToTargetXPos

; ---- from univ_ship_data.asm
CopySuntoUniv:          ld      hl,SunXPos                      ; the Sun routine as teh last one can just fall into copyHL

; ---- from univ_ship_data.asm
; -- General purpose copy 9 bytes from HL to UBnKTarget block
; -- done here so that optimisation can be applied later
copyHlToTargetXPos:     ld      de,UBnKTargetXPos
                        ld      bc,3*3
                        ldir
                        ret

; ---- from univ_ship_data.asm
CalculateSpaceStationWarpPositon:
.CalcZPosition:         ld      a,(WorkingSeeds+1)      ; seed d & 7
                        and     %00000111               ; .
                        add     a,7                     ; + 7
                        sra     a                       ; / 2
.SetZPosition:          ld      (UBnKzsgn),a            ; << 16 (i.e. load into z sign byte
                        ld      hl, $0000               ; now set z hi and lo
                        ld      (UBnKzlo),hl            ;
.CalcXandYPosition:     ld      a,(WorkingSeeds+5)      ; seed f & 3
                        and     %00000011               ; .
                        add     a,3                     ; + 3
                        ld      b,a
                        ld      a,(WorkingSeeds+4)      ; get low bit of seed e
                        and     %00000001
                        rra                             ; roll bit 0 into bit 7
                        or      b                       ; now calc is f & 3 * -1 if seed e is odd
.SetXandYPosition:      ld      (UBnKxsgn),a            ; set into x and y sign byte
                        ld      (UBnKysgn),a            ; .
                        ld      a,b                     ; we want just seed f & 3 here
                        ld      (UBnKxhi),a             ; set into x and y high byte
                        ld      (UBnKyhi),a             ; .
                        ZeroA
                        ld      (UBnKxlo),a
                        ld      (UBnKylo),a
.CaclculateSpaceStationOffset:
.CalculateOffset:       ld      a,(WorkingSeeds+2)
                        and     %00000011
                        ld      c,a
                        ld      a,(WorkingSeeds)
                        and     %00000001
                        rla
                        ld      b,a
                        ld      h,c
                        ld      c,0
.TransposeX:            push    bc,,hl
                        ld      de,(UBnKxhi)
                        ld      a,(UBnKxsgn)
                        ld      l,a
                        MMUSelectMathsBankedFns : call        AddBCHtoDELsigned
                        ld      (UBnKxhi),de
                        ld      a,l
                        ld      (UBnKxsgn),a
.TransposeY:            pop     bc,,hl
                        push    bc,,hl
                        ld      de,(UBnKyhi)
                        ld      a,(UBnKysgn)
                        ld      l,a
                        MMUSelectMathsBankedFns : call        AddBCHtoDELsigned
                        ld      (UBnKyhi),de
                        ld      a,l
                        ld      (UBnKysgn),a
.TransposeZ:            pop     bc,,hl
                        ld      de,(UBnKzhi)
                        ld      a,(UBnKzsgn)
                        ld      l,a
                        MMUSelectMathsBankedFns : call        AddBCHtoDELsigned
                        ld      (UBnKzhi),de
                        ld      a,l
                        ld      (UBnKzsgn),a
                        ret

; ---- from univ_ship_data.asm
SpaceStationLaunchPositon:
                        ld      hl,0
                        ZeroA
                        ld      (UBnKxlo),hl
                        ld      (UBnKxsgn),a
                        ld      (UBnKylo),hl
                        ld      (UBnKysgn),a
                        ld      a,$81
                        ld      (UBnKzlo),hl
                        ld      (UBnKzsgn),a
                        ret

; ---- from univ_ship_data.asm
UnivSpawnSpaceStation:  ;    UnivSelSpaceStationType ; set a to type
.CalculatePosition:     call    CopyPlanetGlobaltoSpaceStation
.CalcOrbitOffset:       call    CalculateSpaceStationWarpPositon
                        call    InitialiseOrientation
.SetRollCounters:       ZeroUnivPitch
                        InfiniteRoll
.SetOrientation:        FlipSignMem UBnkrotmatNosevX+1;  as its 0 flipping will make no difference
                        FlipSignMem UBnkrotmatNosevY+1;  as its 0 flipping will make no difference
                        FlipSignMem UBnkrotmatNosevZ+1
                        ret

; ---- from univ_ship_data.asm
TidyRotation:       IFNDEF FORCE_TIDY
                        ld      a,(UBnkTidyCounter)         ; loops every 16 iterations
                        dec     a                           ; and call is determined
                        and     %00001111                   ; by if the counter
                        ld      (UBnkTidyCounter),a         ; matches teh slot number
                        ld      hl,UBnKSlotNumber           ; of course this is then 16 slots max
                        cp      (hl)
                        ret     nz                          ; when counter matches slot number tidy stops it doing all tidies on same iteration
                    ENDIF
                    IFNDEF BYPASS_TIDY
                        MMUSelectMathsBankedFns
                        call    TidyVectorsIX
                    ENDIF
                        ret

; ---- from sun_data.asm
CalculateSunLaunchedPosition:
.CalcXPosition:         MMUSelectMathsBankedFns
                        ld      ix,SBnKxlo              ; Sun BnKxlo += ParentPlanetX
                        ld      iy,ParentPlanetX        ; .
                        call    AddAtIXtoAtIY24Signed   ; .
.CalcYPosition:         ld      ix,SBnKylo              ; Sun BnKylo += ParentPlanetZ
                        ld      iy,ParentPlanetY        ; .
                        call    AddAtIXtoAtIY24Signed   ; .
.CalcZPosition:         ld      ix,SBnKzlo              ; Sun BnKzlo += ParentPlanetZ
                        ld      iy,ParentPlanetZ        ; .
                        call    AddAtIXtoAtIY24Signed   ; .
                        ret

; ---- from planet_data.asm
CalculatePlanetLaunchedPosition:
.CalcXPosition:         MMUSelectMathsBankedFns
                        ld      ix,P_BnKxlo             ; P_BnKxlo += ParentPlanetX
                        ld      iy,ParentPlanetX        ; .
                        call    AddAtIXtoAtIY24Signed   ; .
.CalcYPosition:         ld      ix,P_BnKylo             ; P_BnKylo += ParentPlanetZ
                        ld      iy,ParentPlanetY        ; .
                        call    AddAtIXtoAtIY24Signed   ; .
.CalcZPosition:         ld      ix,P_BnKzlo             ; P_BnKzlo += ParentPlanetZ
                        ld      iy,ParentPlanetZ        ; .
                        call    AddAtIXtoAtIY24Signed   ; .
                        ret

; ---- from Universe/UniverseMacros/UniverseVarsDefineMacro.asm: UnivCoreAIVarsMacro as it was
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
