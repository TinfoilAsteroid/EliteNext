
;--------------------------------------------------------------------------------------------------------
;What we do is:
; triangle pointer = address of <ship>Triangles
; normal index = 0
; For each normal
;   is it visible
;       No - a = (triangle pointer)
;            while a = normal index
;                  triangle pointer + 4
;                  a = (triangle pointer)
;            if a = $FF then we are done early
;       Yes  -  IY = traingle list
;               for i = 0 to 3
;                   a = (trianglepointer)
;                   hl = ubnkline array + a 
;                   (IY[01]) = (hl [01]
;                   (IY[23]) = (hl [23]
;                    iy += 4
;                next
;                drawtriangle IY 01,23  45,67 89,1011
; next
PrepTriangles:
        ;break
        ldWriteZero UbnkLineArrayLen                    ; current line array index = 0
        ldWriteZero UbnkLineArrayBytes                  ; UbnkLineArrayBytes= nbr of bytes of lines laoded = array len * 4
        ldWriteZero PLEDGECTR
        ld          a,(EdgeCountAddr)
        ld          ixh,a                               ; ixh = XX17 = Total number of edges to traverse
        ld          iyl,0                               ; ixl = current edge index
        ld          hl,UbnkLineArray                    ; head of array
        ld          (varU16),hl                         ; store current line array pointer un varU16
        ldCopyByte  EdgeCountAddr, XX17                 ; XX17  = total number of edges to traverse edge counter
        ld          a,(UBnKexplDsp)                     ; get explosion status
        JumpOnBitClear a,6,CalculateNewLines            ; LL170 bit6 of display state clear (laser not firing) \ Calculate new lines
        and         $BF                                 ; else laser is firing, clear bit6.
        ld          (UBnKexplDsp),a                     ; INWK+31
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
        IFDEF NOBACKFACECULL
                                            DISPLAY "TODO: dbugtodo"
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
                                            DISPLAY "TODO: debug bodge todo"
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
        call        getVertexNodeAtAToX1Y1              ; get the points X1Y1 from node
        ld          a,(IY+3)
        call        getVertexNodeAtAToX2Y2              ; get the points X2Y2 from node
        IFDEF       CLIPVersion3
            call        ClipLineV3
            jr          c,LL78EdgeNotVisible
        ELSE
            call        ClipLine
            jr          c,LL78EdgeNotVisible                ; LL78 edge not visible
        ENDIF
LL80:                                                   ; ll80 \ Shove visible edge onto XX19 ship lines heap counter U
        ld          de,(varU16)                         ; clipped edges heap address
        ld          hl,UBnkNewX1
        FourLDIInstrunctions
        ld          (varU16),de                         ; update U16 with current address
        ld          hl,UbnkLineArrayLen                 ; we have loaded one line
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
        ld          a,(UbnkLineArrayLen)                ; UbnkLineArrayLen = nbr of lines loaded 
        sla         a
        sla         a                                   ; multiple by 4 to equal number of bytes
        ld          (UbnkLineArrayBytes),a              ; UbnkLineArrayBytes= nbr of bytes of lines laoded = array len * 4
ExitEdgeDataLoop:
        ret
        