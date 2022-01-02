
InverseSXX16:								; lead routine into .LL42	\ ->  &4B04 \ DO nodeX-Ycoords their comment  \  TrnspMat
        ld      hl,(SBnKTransmatSidevX)     ;  
        ld      de,(SBnKTransmatRoofvX)     ;  
        ld      bc,(SBnKTransmatNosevX)     ;  
        ld      (SBnKTransInvRow0x0),hl     ;  
        ld      (SBnKTransInvRow0x1),de     ;  
        ld      (SBnKTransInvRow0x2),bc     ;  
        ld      hl,(SBnKTransmatSidevY)     ;  
        ld      de,(SBnKTransmatRoofvY)     ;  
        ld      bc,(SBnKTransmatNosevY)     ;  
        ld      (SBnKTransInvRow1y0),hl     ;  
        ld      (SBnKTransInvRow1y1),de     ;  
        ld      (SBnKTransInvRow1y2),bc     ;  
        ld      hl,(SBnKTransmatSidevZ)     ;  
        ld      de,(SBnKTransmatRoofvZ)     ;  
        ld      bc,(SBnKTransmatNosevZ)     ;  
        ld      (SBnKTransInvRow2z0),hl     ;  
        ld      (SBnKTransInvRow2z1),de     ;  
        ld      (SBnKTransInvRow2z2),bc     ;  
        ret
        
		