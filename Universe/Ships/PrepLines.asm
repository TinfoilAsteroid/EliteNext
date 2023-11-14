
;--------------------------------------------------------------------------------------------------------
        DISPLAY "Tracing 8", $

    INCLUDE "./ModelRender/getVertexNodeAtAToX1Y1.asm"
    
        DISPLAY "Tracing 9", $

    INCLUDE "./ModelRender/getVertexNodeAtAToX2Y2.asm"
        DISPLAY "Tracing 10", $

    INCLUDE "./ModelRender/GetFaceAtA.asm"
        DISPLAY "Tracing 11", $

;--------------------------------------------------------------------------------------------------------
; LL72 Goes through each edge in to determine if they are on a visible face, if so load start and end to line array as clipped lines
 ;   DEFINE NOBACKFACECULL 1
PLEDGECTR           DB          0

PrepLines:
; FOR NOW BRUTE FORCE IF OFF SCREEN

; TODO add in onced DOEXP is finished
;        ld          a,(UBnkexplDsp)                     ; INWK+31  \ display/exploding state|missiles
;        JumpOnBitClear  a,5,EE31                        ; bit5 of mask, if zero no explosion
;        or          8
;        ld          (UBnkexplDsp),a                     ; else else set bit3 to erase old line
;        jp          DOEXP                               ; erase using Do Explosion and use implicit return
;EE31:                                                   ; no explosion
;        JumpOnBitClear  a,3,LL74                        ; clear is hop to do New lines
;        call        ClearLine                           ; LL155    \ else erase lines in XX19 heap at LINEstr down
;        ld          a, $08                              ; set bit 3 of a and fall into LL74
;
;--------------------------------------------------------------------------------------------------------

InitialiseLineRead:  
        ;break
        ldWriteZero UBnkLineArrayLen                    ; current line array index = 0
        ld          (UBnkLineArrayBytes),a              ; UBnkLineArrayBytes= nbr of bytes of lines laoded = array len * 4
        ld          (PLEDGECTR),a
        ld          a,(EdgeCountAddr)
        ld          ixh,a                               ; ixh = XX17 = Total number of edges to traverse
        ld          iyl,0                               ; ixl = current edge index
        ld          hl,UBnkLineArray                    ; head of array
        ld          (varU16),hl                         ; store current line array pointer un varU16
        ldCopyByte  EdgeCountAddr, XX17                 ; XX17  = total number of edges to traverse edge counter
        ld          a,(UBnkexplDsp)                     ; get explosion status
        JumpOnBitClear a,6,CalculateNewLines            ; LL170 bit6 of display state clear (laser not firing) \ Calculate new lines
        and         $BF                                 ; else laser is firing, clear bit6.
        ld          (UBnkexplDsp),a                     ; INWK+31
;   TODO commentedout as teh subroutine is a mess   call        AddLaserBeamLine                    ; add laser beam line to draw list
; NOw we can calculate hull after including laser line        
CalculateNewLines:
LL170:                                                  ;(laser not firing) \ Calculate new lines   \ their comment
CheckEdgesForVisibility:        
        ld          hl,UBnkHullEdges
        ; TODO change heap to 3 separate arrays and break them down during copy of ship hull data
        ld          (varV),hl                           ; V \ is pointer to where edges data start
        ld          a,(LineX4Addr)
        ld          b,a                                 ; nbr of bytes of edge data
LL75Loop:                                               ; count Visible edges
IsEdgeInVisibilityRange:
        ld          hl,(varV)
        push        hl
        pop         iy
       ; DEFINE NOBACKFACECULL 1
        IFDEF NOBACKFACECULL
            jp          VisibileEdge; DEBUGTODO
        ENDIF
        ld          a,(LastNormalVisible)               ; XX4 is visibility range
        ld          d,a                                 ; d holds copy of XX4
; Get Edge Byte 0
        ld          a,(IY+0)                            ; edge data byte#0 is visibility distance
        JumpIfALTNusng d,LL78EdgeNotVisible             ; XX4   \ visibility LLx78 edge not visible
EdgeMayBeVisibile:
; Get Edge Byte 1
IsFace1Visibile:                                        ; edges have 2 faces to test
        ld          a,(IY+1)                            ; (V),Y \ edge data byte#1 bits 0 to 3 face 1 4 to 7 face 2
        ld          c,a                                 ;  c = a copy of byte 1
        and         $0F                                 ;
        GetFaceAtA
;       jp  VisibileEdge; DEBUG BODGE TEST TODO
        JumpIfAIsNotZero VisibileEdge                     ; LL70 visible edge
IsFace2Visibile:
        ld          a,c                                 ; restore byte 1 from c register
        swapnib                                         ; 
        and         $0F                                 ; swap high byte into low byte
        push        hl
        GetFaceAtA
        pop         hl
        JumpIfAIsZero LL78EdgeNotVisible                ; edge not visible
VisibileEdge:                                           ; Now we need to node id from bytes 2 - start and 3 - end
;LL79--Visible edge--------------------------------------
; Get Edge Byte 2
        ld          a,(IY+2)                            ; get Node id
        ld          de,UBnkX1
        call        getVertexNodeAtAToDE; getVertexNodeAtAToX1Y1              ; get the points X1Y1 from node
        ld          a,(IY+3)
        ld          de,UBnkX2
        call        getVertexNodeAtAToDE; getVertexNodeAtAToX2Y2              ; get the points X2Y2 from node

        IFDEF       CLIPVersion3
            call        ClipLineV3
            jr          nc,.SkipBreak1
            nop
            nop
            ;break
.SkipBreak1:            
            jr          c,LL78EdgeNotVisible
//COMMENEDOUT FOR LATECLIPPING        ELSE
//COMMENEDOUT FOR LATECLIPPING            call        ClipLine
//COMMENEDOUT FOR LATECLIPPING            jr          c,LL78EdgeNotVisible                ; LL78 edge not visible
        ENDIF
LL80:                                                   ; ll80 \ Shove visible edge onto XX19 ship lines heap counter U
        IFDEF       LATECLIPPING
                ld          de,(varU16)                         ; clipped edges heap address
                ld          hl,UBnkPreClipX1
                FourLDIInstrunctions
                FourLDIInstrunctions
                ld          (varU16),de                         ; update U16 with current address
        ELSE
                ld          de,(varU16)                         ; clipped edges heap address
                ld          hl,UBnkNewX1
                FourLDIInstrunctions
                ld          (varU16),de                         ; update U16 with current address
        ENDIF
        ld          hl,UBnkLineArrayLen                 ; we have loaded one line
        inc         (hl)
        ld          a,(hl)
        JumpIfAGTENusng LineArraySize,CompletedLineGeneration   ; have we hit max lines for a model hop over jmp to Exit edge data loop
; If we hit here we skip the write of line arryay u16
LL78EdgeNotVisible:                                     ; also arrive here if Edge not visible, loop next data edge.
LL78:
        ld          hl,(varV)                           ; varV is current edge address
        ld          a,4
        add         hl,a
        ld          (varV),hl
        ld          hl,PLEDGECTR                        ;
        inc         (hl)                                ;
        ld          a,(hl)                              ; current edge index ++
        JumpIfANEMemusng XX17,LL75Loop                  ; compare with total number of edges
CompletedLineGeneration:        
LL81:
LL81SHPPT:                                              ; SHPPT ship is a point arrives here with Acc=2, bottom entry in heap
        ld          a,(UBnkLineArrayLen)                ; UBnkLineArrayLen = nbr of lines loaded 
        sla         a
        sla         a                                   ; multiple by 4 to equal number of bytes
        IFDEF       LATECLIPPING        
                sla         a                           ; multiple by 8 to equal number of bytes
        ENDIF
        ld          (UBnkLineArrayBytes),a              ; UBnkLineArrayBytes= nbr of bytes of lines laoded = array len * 4
ExitEdgeDataLoop:
        ret
        