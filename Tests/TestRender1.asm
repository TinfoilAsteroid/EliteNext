    ld      a,CobraTablePointer
    MMUSelectUniverseN 0                          ; load up register into universe bank
    call    ResetUBnkData                         ; call the routine in the paged in bank, each universe bank will hold a code copy local to it
    MMUSelectShipModelsA
	ld		a,CobraTablePointer
    call    CopyShipDataToUBnk

    call        InitialiseOrientation
    call        CopyRotmatToTransMat           ; -> XX16                                                                                     ;;; load object position to camera matrix XX16 			::LL91 (ish)
    call        NormaliseTransMat                                                                                                   ;;; 

    ld      a,0
    ld      (UBnkxlo),a
    ld      (UBnkylo),a
	ld      a,$55
    ld      (UBnkzlo),a
    xor     a
    ld      (UBnkxsgn),a
    ld      (UBnkysgn),a
    ld      (UBnkzsgn),a
    ld      (UBnkxhi),a
    ld      (UBnkyhi),a
	ld      a,66
    ld      (UBnkzhi),a
    call    LoadCraftToCamera 
;	call	TestRender
    call    SetAllFacesVisible     
 ;   call    BackFaceCull
    call    InverseXX16 
    call    ProcessNodes                ; Loop through and determine visibility based on faces and position
    call    PrepLines                   ; LL72, process lines and clip
    call    DrawLines                   ; Need to plot all lines
TESTP1:
    call    SetAllFacesVisible  
	