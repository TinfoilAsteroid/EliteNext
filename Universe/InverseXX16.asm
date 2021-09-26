; TESTEDOK

;ScaleOrientationXX16:                       ; DEBUG TODO will combine with inverse later
;        ld      a,(XX17)
;        ld      ixl,a
;        ld      ixh,9
;        ld      hl,UBnkTransInv0x
;        ld      a,(hl)
;ScaleNode:
;        ld      b,ixl
;ScaleNodeLoop:        
;        sla      a
;        djnz    ScaleNodeLoop
;        ld      (hl),a
;        inc     hl
;        inc     hl
;        dec     ixh
;        jr      nz,ScaleNode
;        ret


InverseXX16:								; lead routine into .LL42	\ ->  &4B04 \ DO nodeX-Ycoords their comment  \  TrnspMat
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
        ld      hl,(UBnkTransmatSidevX)     ;  
        ld      de,(UBnkTransmatRoofvX)     ;  
        ld      bc,(UBnkTransmatNosevX)     ;  
        ld      (UbnkTransInvRow0x0),hl     ;  
        ld      (UbnkTransInvRow0x1),de     ;  
        ld      (UbnkTransInvRow0x2),bc     ;  
        ld      hl,(UBnkTransmatSidevY)     ;  
        ld      de,(UBnkTransmatRoofvY)     ;  
        ld      bc,(UBnkTransmatNosevY)     ;  
        ld      (UbnkTransInvRow1y0),hl     ;  
        ld      (UbnkTransInvRow1y1),de     ;  
        ld      (UbnkTransInvRow1y2),bc     ;  
        ld      hl,(UBnkTransmatSidevZ)     ;  
        ld      de,(UBnkTransmatRoofvZ)     ;  
        ld      bc,(UBnkTransmatNosevZ)     ;  
        ld      (UbnkTransInvRow2z0),hl     ;  
        ld      (UbnkTransInvRow2z1),de     ;  
        ld      (UbnkTransInvRow2z2),bc     ;  
        ret
        
		