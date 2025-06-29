;; perform dehl & de'hl' with d and d' always being 0
;mulu_48:    ld bc,hl                    ; prep de'de bc'bc
;            push de                     ;  
;            exx                         ;
;            pop bc                      ;
;            push hl                     ;
;            exx                         ;
;            pop de                      ;
;            ; perform multipication as 0e'de * 0c'bc
;mulu_64debc:exx                         ; save material for the byte p7 p6 = x3*y3 + p5 carry
;            ld h,d
;            ld l,b
;            push hl                     ;'x3 y3                                 SP + 1 X
;
;            
;            ld l,c                      ; save material for the byte p5 = x3*y2 + x2*y3 + p4 carry
;            push hl                     ;'x3 y2                                 SP + 2 X
;            ld h,b
;            ld l,e
;            push hl                     ;'y3 x2                                 SP + 3 X
;        
;            
;            ld h,e                      ; save material for the byte p4 = x3*y1 + x2*y2 + x1*y3 + p3 carry
;            ld l,c
;            push hl                     ;'x2 y2                                 SP + 4
;            ld h,d
;            ld l,b
;            push hl                     ;'x3 y3                                 SP + 5 X
;            exx                         ; Now we have the alternate register pairs we can start optimising by binning off d' and b' calculations
;            
;            ld l,b
;            ld h,d
;            push hl                     ; x1 y1                                 SP + 6
;        
;            
;            push bc                     ; save material for the byte p3 = x3*y0 + x2*y1 + x1*y2 + x0*y3 + p2 carry y1 y0
;            exx                         ;'
;            push de                     ;'x3 x2                                 SP + 7 X
;            push bc                     ;'y3 y2                                 SP + 8 X
;            exx                         ;
;            push de                     ; x1 x0                                 SP + 9
;        
;
;            exx                         ; save material for the byte p2 = x2*y0 + x0*y2 + x1*y1 + p1 carry start of 32_32x32
;            ld h,e
;            ld l,c
;            push hl                     ;'x2 y2                                 SP + 10
;        
;            exx                         ;
;            ld h,e
;            ld l,c
;            push hl                     ; x0 y0                                 SP + 11
;        
;
;            ;                           
;        
;            ld h,d                      ; start of 32_16x16          p1 = x1*y0 + x0*y1 + p0 carry  p0 = x0*y0
;            ld l,b
;            push hl                     ; x1 y1                                 SP + 12
;        
;            ld h,d                      ; x1
;            ld d,b                      ; y1
;            ld l,c                      ; y0
;            ld b,e                      ; x0 
;            mul de                       ; bc = x0 y0 de = y1 x0 hl = x1 y0 stack = x1 y1, y1*x0
;            ex de,hl
;            mul de                      ; x1*y0
;            
;            xor a                       ; zero A
;            add hl,de                   ; sum cross products p2 p1
;            adc a,a                     ; capture carry p3
;            
;            ld e,c                      ; x0
;            ld d,b                      ; y0
;            mul de                      ; y0*x0
;            
;            ld b,a                      ; carry from cross products
;            ld c,h                      ; LSB of MSW from cross products
;            
;            ld a,d
;            add a,l
;            ld h,a
;            ld l,e                      ; LSW in HL p1 p0
;            
;            pop de                      ;                                       SP + 11
;            mul de                      ; x1*y1
;            
;            ex de,hl
;            adc hl,bc                   ; HL = interim MSW p3 p2
;            ex de,hl                    ; DEHL = 32_16x16
;            
;            push de                     ; stack interim p3 p2                   SP + 12
;            
;
;            exx                         ; continue doing the p2 byte
;            pop bc                      ;'recover interim p3 p2                 SP + 11
;            
;            pop hl                      ;'x0 y0                                 SP + 10
;            pop de                      ;'x2 y2                                 SP + 9
;            ld a,h
;            ld h,d
;            ld d,a
;            mul de                      ;'x0*y2
;            ex de,hl
;            mul de                      ;'x2*y0
;            
;            xor a
;            add hl,bc
;            adc a,a                     ;'capture carry p4
;            add hl,de
;            adc a,0                     ;'capture carry p4
;            
;            push hl                     ;                                       SP + 10
;            exx
;            pop de                      ; save p2 in E'                         SP + 9
;            exx                         ;'
;            
;            ld c,h                      ;'promote BC p4 p3
;            ld b,a 
;
;            pop hl                      ; start doing the p3 byte, 'x1 x0       SP + 9
;            pop de                      ;'y3 y2                                 SP + 8 X
;            ld a,h
;            ld h,d
;            ld d,a
;            mul de                      ;'y3*x0                                        X
;            ex de,hl
;            mul de                      ;'x1*y2
;        
;            xor a                       ;'zero A
;            add hl,de                   ;'p4 p3
;            adc a,a                     ;'p5
;            add hl,bc                   ;'p4 p3
;            adc a,0
;            ld b,h
;            ld c,l
;            ex af,af
;        
;            pop hl                      ;'x3 x2                                 SP + 7 X
;            pop de                      ;'y1 y0                                 SP + 6
;            ld a,h
;            ld h,d
;            ld d,a
;            mul de                      ;'x3*y0                                        X
;            ex de,hl
;            mul de                      ;'y1*x2
;        
;            ex af,af
;            add hl,de                   ;'p4 p3
;            adc a,0                     ;'p5
;            add hl,bc                   ;'p4 p3
;            adc a,0                     ;'p5
;        
;            push hl                     ;'leave final p3 in L                   SP + 7
;            exx                         ; 
;            pop bc                      ;                                       SP + 6
;            ld d,c                      ; put final p3 in D
;            exx                         ;'low 32bits in DEHL
;        
;            ld c,h                      ;'prepare BC for next cycle
;            ld b,a                      ;'promote BC p5 p4
;
;            ; start doing the p4 byte
;        
;            pop hl                      ;'x1 y1                                 SP + 5
;            pop de                      ;'x3 y3                                 SP + 4 X
;            ld a,h
;            ld h,d
;            ld d,a
;            mul de                      ;'x1*y3                                        X
;            ex de,hl
;            mul de                      ;'x3*y1
;        
;        
;            xor a                       ;'zero A
;            add hl,de                   ;'p5 p4
;            adc a,a                     ;'p6
;            add hl,bc                   ;'p5 p4
;            adc a,0                     ;'p6
;        
;            pop de                      ;'x2 y2                                 SP + 3
;            mul de                      ;'x2*y2
;        
;            add hl,de                   ;'p5 p4
;            adc a,0                     ;'p6
;        
;            ld c,l                      ;'final p4 byte in C
;            ld l,h                      ;'prepare HL for next cycle
;            ld h,a                      ;'promote HL p6 p5
;
;            ; start doing the p5 byte
;        
;            pop de                      ;'y3 x2                                 SP + 2 X
;            mul de                      ;'y3*x2                                        X
;        
;            xor a                       ;'zero A
;            add hl,de                   ;'p6 p5
;            adc a,a                     ;'p7
;        
;            pop de                      ;'x3 y2                                 SP + 1
;            mul de                      ;'x3*y2
;        
;            add hl,de                   ;'p6 p5
;            adc a,0                     ;'p7
;        
;            ld b,l                      ;'final p5 byte in B
;            ld l,h                      ;'prepare HL for next cycle
;            ld h,a                      ;'promote HL p7 p6
;        
;            ; start doing the p6 p7 bytes
;            pop de                      ;'y3 x3                                 SP + 0
;            mul de                      ;'y3*x3
;        
;            add hl,de                   ;'p7 p6
;            ex de,hl                    ;'p7 p6
;            ld h,b                      ;'p5
;            ld l,c                      ;'p4
;        
;            ret                         ;'exit  : DEHL DEHL' = 64-bit product

; dehl dehl' = dehl * dehl' 
mulu_64:    ld bc,hl                    ; prep de'de bc'bc
            push de                     ;  
            exx                         ;
            pop bc                      ;
            push hl                     ;
            exx                         ;
            pop de                      ;
mulu_64debc:exx                         ; save material for the byte p7 p6 = x3*y3 + p5 carry
            ld h,d
            ld l,b
            push hl                     ;'x3 y3

            
            ld l,c                      ; save material for the byte p5 = x3*y2 + x2*y3 + p4 carry
            push hl                     ;'x3 y2
            ld h,b
            ld l,e
            push hl                     ;'y3 x2
        
            
            ld h,e                      ; save material for the byte p4 = x3*y1 + x2*y2 + x1*y3 + p3 carry
            ld l,c
            push hl                     ;'x2 y2
            ld h,d
            ld l,b
            push hl                     ;'x3 y3
            exx                         ;
            ld l,b
            ld h,d
            push hl                     ; x1 y1
        
            
            push bc                     ; ; save material for the byte p3 = x3*y0 + x2*y1 + x1*y2 + x0*y3 + p2 carry y1 y0
            exx                         ;'
            push de                     ;'x3 x2
            push bc                     ;'y3 y2
            exx                         ;
            push de                     ; x1 x0
        

            exx                         ; save material for the byte p2 = x2*y0 + x0*y2 + x1*y1 + p1 carry start of 32_32x32
            ld h,e
            ld l,c
            push hl                     ;'x2 y2
        
            exx                         ;
            ld h,e
            ld l,c
            push hl                     ; x0 y0
        

            ;                           
        
            ld h,d                      ; start of 32_16x16          p1 = x1*y0 + x0*y1 + p0 carry  p0 = x0*y0
            ld l,b
            push hl                     ; x1 y1
        
            ld h,d                      ; x1
            ld d,b                      ; y1
            ld l,c                      ; y0
            ld b,e                      ; x0 
            mul de                       ; bc = x0 y0 de = y1 x0 hl = x1 y0 stack = x1 y1, y1*x0
            ex de,hl
            mul de                      ; x1*y0
            
            xor a                       ; zero A
            add hl,de                   ; sum cross products p2 p1
            adc a,a                     ; capture carry p3
            
            ld e,c                      ; x0
            ld d,b                      ; y0
            mul de                      ; y0*x0
            
            ld b,a                      ; carry from cross products
            ld c,h                      ; LSB of MSW from cross products
            
            ld a,d
            add a,l
            ld h,a
            ld l,e                      ; LSW in HL p1 p0
            
            pop de
            mul de                      ; x1*y1
            
            ex de,hl
            adc hl,bc                   ; HL = interim MSW p3 p2
            ex de,hl                    ; DEHL = 32_16x16
            
            push de                     ; stack interim p3 p2
            

            exx                         ; continue doing the p2 byte
            pop bc                      ;'recover interim p3 p2
            
            pop hl                      ;'x0 y0
            pop de                      ;'x2 y2
            ld a,h
            ld h,d
            ld d,a
            mul de                      ;'x0*y2
            ex de,hl
            mul de                      ;'x2*y0
            
            xor a
            add hl,bc
            adc a,a                     ;'capture carry p4
            add hl,de
            adc a,0                     ;'capture carry p4
            
            push hl
            exx
            pop de                      ; save p2 in E'
            exx                         ;'
            
            ld c,h                      ;'promote BC p4 p3
            ld b,a 

            pop hl                      ; start doing the p3 byte, 'x1 x0
            pop de                      ;'y3 y2
            ld a,h
            ld h,d
            ld d,a
            mul de                      ;'y3*x0
            ex de,hl
            mul de                      ;'x1*y2
        
            xor a                       ;'zero A
            add hl,de                   ;'p4 p3
            adc a,a                     ;'p5
            add hl,bc                   ;'p4 p3
            adc a,0
            ld b,h
            ld c,l
            ex af,af
        
            pop hl                      ;'x3 x2
            pop de                      ;'y1 y0
            ld a,h
            ld h,d
            ld d,a
            mul de                      ;'x3*y0
            ex de,hl
            mul de                      ;'y1*x2
        
            ex af,af
            add hl,de                   ;'p4 p3
            adc a,0                     ;'p5
            add hl,bc                   ;'p4 p3
            adc a,0                     ;'p5
        
            push hl                     ;'leave final p3 in L   
            exx                         ; 
            pop bc
            ld d,c                      ; put final p3 in D
            exx                         ;'low 32bits in DEHL
        
            ld c,h                      ;'prepare BC for next cycle
            ld b,a                      ;'promote BC p5 p4

            ; start doing the p4 byte
        
            pop hl                      ;'x1 y1
            pop de                      ;'x3 y3
            ld a,h
            ld h,d
            ld d,a
            mul de                      ;'x1*y3
            ex de,hl
            mul de                      ;'x3*y1
        
        
            xor a                       ;'zero A
            add hl,de                   ;'p5 p4
            adc a,a                     ;'p6
            add hl,bc                   ;'p5 p4
            adc a,0                     ;'p6
        
            pop de                      ;'x2 y2
            mul de                      ;'x2*y2
        
            add hl,de                   ;'p5 p4
            adc a,0                     ;'p6
        
            ld c,l                      ;'final p4 byte in C
            ld l,h                      ;'prepare HL for next cycle
            ld h,a                      ;'promote HL p6 p5

            ; start doing the p5 byte
        
            pop de                      ;'y3 x2
            mul de                      ;'y3*x2
        
            xor a                       ;'zero A
            add hl,de                   ;'p6 p5
            adc a,a                     ;'p7
        
            pop de                      ;'x3 y2
            mul de                      ;'x3*y2
        
            add hl,de                   ;'p6 p5
            adc a,0                     ;'p7
        
            ld b,l                      ;'final p5 byte in B
            ld l,h                      ;'prepare HL for next cycle
            ld h,a                      ;'promote HL p7 p6
        
            ; start doing the p6 p7 bytes
            pop de                      ;'y3 x3
            mul de                      ;'y3*x3
        
            add hl,de                   ;'p7 p6
            ex de,hl                    ;'p7 p6
            ld h,b                      ;'p5
            ld l,c                      ;'p4
        
            ret                         ;'exit  : DEHL DEHL' = 64-bit product


