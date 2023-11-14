
XX16DefineMacro:            MACRO   p?
;-- XX16 --------------------------------------------------------------------------------------------------------------------------")
p?_BnkTransmatSidevX          DW  0               ; XX16+0
p?_BnkTransmatSidev           EQU p?_BnkTransmatSidevX
p?_BnkTransmatSidevY          DW 0                ; XX16+2
p?_BnkTransmatSidevZ          DW 0                ; XX16+2
p?_BnkTransmatRoofvX          DW 0
p?_BnkTransmatRoofv           EQU p?_BnkTransmatRoofvX
p?_BnkTransmatRoofvY          DW 0                ; XX16+2
p?_BnkTransmatRoofvZ          DW 0                ; XX16+2
p?_BnkTransmatNosevX          DW 0
p?_BnkTransmatNosev           EQU p?_BnkTransmatNosevX
p?_BnkTransmatNosevY          DW 0                ; XX16+2
p?_BnkTransmatNosevZ          DW 0                ; XX16+2
p?_BnkTransmatTransX          DW 0
p?_BnkTransmatTransY          DW 0
p?_BnkTransmatTransZ          DW 0
p?_XX16                       equ p?_BnkTransmatSidev
;-- XX16Inv --------------------------------------------------------------------------------------------------------------------------
p?_BnkTransInvRow0x0          DW 0
p?_BnkTransInvRow0x1          DW 0
p?_BnkTransInvRow0x2          DW 0
p?_BnkTransInvRow0x3          DW 0
p?_BnkTransInvRow1y0          DW 0
p?_BnkTransInvRow1y1          DW 0
p?_BnkTransInvRow1y2          DW 0
p?_BnkTransInvRow1y3          DW 0
p?_BnkTransInvRow2z0          DW 0
p?_BnkTransInvRow2z1          DW 0
p?_BnkTransInvRow2z2          DW 0
p?_BnkTransInvRow2z3          DW 0
p?_XX16Inv                    equ p?_BnkTransInvRow0x0
                            ENDM

InverseXX16Macro:               MACRO p?
; lead routine into .LL42	\ ->  &4B04 \ DO nodeX-Ycoords their comment  \  TrnspMat
p?_InverseXX16:
; we coudl combine this with move to transmat later as an optimisation
; INPUT - All Scaled
;  They transmat has already been put into side, roof nose order
;  XX16   = |sidev_x| |sidev_y| |sidev_z|  1  0  3  2  5  4 note each bytepair is Scaled value in low and high byte just for sign
;  XX16   = |roofv_x| |roofv_y| |roofv_z|  7  6  8  9 11 10
;  XX16   = |nosev_x| |nosev_y| |nosev_z| 13 12 15 14 17 16
; OUTPUT 
;  XX16(1 0)   ( 3 2) ( 5 4 ) =  sidev_x roofv_x nosev_x
;  XX16(7 6)   ( 8 9) (11 10) =  sidev_y roofv_y nosev_y
;  XX16(13 12) (15 14)(17 16) =  sidev_z roofv_z nosev_z
; First all side values become compoment 0 of each vector
                                ld      hl,(p?_BnkTransmatSidevX)     ;  
                                ld      de,(p?_BnkTransmatRoofvX)     ;  
                                ld      bc,(p?_BnkTransmatNosevX)     ;  
                                ld      (p?_BnkTransInvRow0x0),hl     ;  
                                ld      (p?_BnkTransInvRow0x1),de     ;  
                                ld      (p?_BnkTransInvRow0x2),bc     ;  
                                ld      hl,(p?_BnkTransmatSidevY)     ;  
                                ld      de,(p?_BnkTransmatRoofvY)     ;  
                                ld      bc,(p?_BnkTransmatNosevY)     ;  
                                ld      (p?_BnkTransInvRow1y0),hl     ;  
                                ld      (p?_BnkTransInvRow1y1),de     ;  
                                ld      (p?_BnkTransInvRow1y2),bc     ;  
                                ld      hl,(p?_BnkTransmatSidevZ)     ;  
                                ld      de,(p?_BnkTransmatRoofvZ)     ;  
                                ld      bc,(p?_BnkTransmatNosevZ)     ;  
                                ld      (p?_BnkTransInvRow2z0),hl     ;  
                                ld      (p?_BnkTransInvRow2z1),de     ;  
                                ld      (p?_BnkTransInvRow2z2),bc     ;  
                                ret
                                ENDM
        
		                            
ScaleXX16Matrix197Macro:        MACRO p?
p?_ScaleXX16Matrix197:
                        IFDEF LOGMATHS
                                ld		b,9                 ; Interate though all 9 matrix elements
                                ld		hl,p?_BnkTransmatSidev ; within XX16 (transmat)
                                MMUSelectMathsTables
.ScaleXX16Loop:                 ld		e,(hl)              ; set DE = matrix value              ;
                                inc		hl                  ;
                                ld		a,(hl)              ;
                                ld		d,a                 ;
                                and     SignOnly8Bit        ; A holds high still to we can strip out sign bit
                                ld		ixl,a				; retain for sign bit
                                ShiftDELeft1				; carry now holds sign bit and DE = De * 2, this will in effect strip off the sign bit automatically
                                ld      a,d                 ; a = high byte after x 2
                                push	bc                  ; save BC  counter and constant 197
                                push	hl                  ; save HL
                                call    AEquAmul256Div197Log;
                                pop		hl
                                dec     hl                  ; move back to low byte
                                ld      (hl),a              ; save result in low byte as we want to preserve high byte sign    
                                inc     hl                  ; move back to high byte  
                                ld      a,ixl
                                ld      (hl),a              ; write back just sign bit
                                pop		bc                  ; retrieve both counter and constant 197
                                inc     hl                  ; no to next vertex value
                                djnz	.ScaleXX16Loop
                                MMUSelectROM0
                                ret
                        ELSE       
                                ld		b,9                 ; Interate though all 9 matrix elements
                                ld		c,ConstNorm         ; c = 197
                                ld		hl,p?_BnkTransmatSidev ; within XX16 (transmat)
.ScaleXX16Loop:                 ld		a,(hl)              ; set DE = matrix value
                                ld		e,a                 ;
                                inc		hl                  ;
                                ld		a,(hl)              ;
                                ld		d,a                 ;
                                and     SignOnly8Bit        ; A holds high still to we can strip out sign bit
                                ld		ixl,a				; retain for sign bit
                                ShiftDELeft1				; carry now holds sign bit and DE = De * 2, this will in effect strip off the sign bit automatically
                                ld      a,d                 ; a = high byte after x 2
                                push	bc                  ; save BC  counter and constant 197
                                push	hl                  ; save HL
                                call	DIV16Amul256dCUNDOC; AEquAmul256DivD; DIV16Amul256dCUNDOC	; result in BC = A*256 / 197 or D *512 / 197 = 2.6 * vector element, effectivley the result will always be in c
                                pop		hl
                                dec     hl                  ; move back to low byte
                                ld      (hl),c              ; save result in low byte as we want to preserve high byte sign    
                                inc     hl                  ; move back to high byte  
                    ;            ld      a,(hl)
                    ;            and     $80
                                ld      a,ixl
                                ld      (hl),a              ; write back just sign bit
                                pop		bc                  ; retrieve both counter and constant 197
                                inc     hl                  ; no to next vertex value
                                djnz	.ScaleXX16Loop
                                ret
                        ENDIF
                        ENDM