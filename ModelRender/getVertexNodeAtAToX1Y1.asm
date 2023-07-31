;--------------------------------------------------------------------------------------------------------
; a = byteoffset to node array as its pre computed to x4 bytes
getVertexNodeAtAToDE:   ld          hl,UBnkNodeArray                    ; hl = edgelist  current pointer
                        add         hl,a                                ; hl = address of Node
                        ld          a,(hl)                              ; get edge list nbr 1 edge
                        ldi                                             ; x1 lo
                        ldi                                             ; x1 hi
                        ldi                                             ; y1 lo
                        ldi                                             ; y1 hi
                        ret

;getVertexNodeAtAToX1Y1: ld          hl,UBnkNodeArray                    ; hl = edgelist  current pointer
;                        add         hl,a                                ; hl = address of Node
;                        ld          a,(hl)                              ; get edge list nbr 1 edge
;                        ld          de,UBnkX1
;                        ldi                                             ; x1 lo
;                        ldi                                             ; x1 hi
;                        ldi                                             ; y1 lo
;                        ldi                                             ; y1 hi
;                        ret
