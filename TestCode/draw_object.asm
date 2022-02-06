JumpIfObjectIsPlanet:   MACRO target
                        ld a,(UbnkHullCopy)
                        bit 7,a
                        jp  nz,target
                        ENDM

SetMaxVisibility:       MACRO 
                        ld		a,MaxVisibility					; max visibility                                               ;;;; default max visibility
                        ld		(LastNormalVisible),a			; XX4                                                          ;;;;                                    
                        ENDM

JumpIfObjectOutsideFov: MACRO target
LL10CheckXInFoV:
                        ld		hl, (INWKxlo)                   ; compare inkwk to to inwk z                                      ;    else
                        ld		de, (INWKzlo)                   ; we can compare as ABS given + or - extreems will be out of view ;         .
                        or		a							    ; clear carry flag for sbc                                        ;         .
                        sbc		hl,de                           ; FOV is 90degrees                                                ;         .
                        bit     7,h
                        jp      z,target                        ; was the result -ve i.e. hl > de?  x > z so outside FoV                                                                          ;         .
LL10CheckYInFoV:
                        ld		hl, (INWKyLo)                                                                                     ;         .
                        or		a							    ; clear carry flag                                                ;         .
                        sbc		hl,de                           ; and test y axis, FOV is 90degrees                               ;         .
                        bit     7,h
                        jp      z,target                        ; was the result -ve i.e. hl > de?  x > z so outside FoV                                                                          ;         .
                        ENDM

LL10AddGunNode:         MACRO
                        ld		a,(GunVertexAddr)	            ; Hull byte6, node gun*4 (Probably should be from bank            ;         hl = z / 8
                        ld		c,a                                                                                               ;         if zhi = 0
                        ld      b,0                             ; bc now - GunNode                                                ;                                              ;             GOTO LL13
                        ld		a,$FF						    ; flag on node heap at gun                                        ;          else
                        ld      hl,UBnkNodeArray                ; flag node on node heap                                          ;
                        add     hl,bc                           ; at position UBnkNodeArray[GunNode]
MakeBothGunNodesVisible:
                        ld      (hl),a                          ; made both gun line notes visible always
                        inc     hl                              ; 
                        ld      (hl),a                          ;
                        ENDM

JumpIfTooFarAway:       MACRO   target
                        ld		hl,(UBnKzlo)                    ; hl = z position, by this point it must be positive
                        ShiftHLDiv8                             ; z position / 8
                        ld      a,h                             ; 
                        JumpIfAIsNotZero target                       ; LL13 - hop as far , i.e. zhi not 0 after divide by 8
                        ENDM

DisplayObject:
LL9:										; Draw object in current bank                                  ;;;; Display object LL9
   ; DEBUG JumpIfObjectIsPlanet LL25
; .................................................................................................................................
LL9NotPlanet:
    SetMaxVisibility
;LL9TestRemoveShip:
;    JumpOnMemBitSet UbnkNweb,7,EraseOldLines; if bit 7 is set goto EraseOldLines                         ;;;;    goto EraseOldLines
; .................................................................................................................................
LL9NoEraseLines:
    JumpOnMemBitSet UBnKexplDsp,5,DoExplosionOrClear7 ; mask for bit 5, exploding, display explosion state|missiles  EE28 bit5 set, explosion ongoing
    JumpOnBitClear a,7,DoExplosionOrClear7  ; we now have it in A so EE28 bit7 clear, else Start blowing up!                      ;;;;
	and		$3F								; clear bits 7,6                                               ;;;; else
	ld		(UBnKexplDsp),a					; INWK+31                                                      ;;;;    clear bit 7 & 6 of INKW31
;...............................................................................................................................................................................
LL9ZeroAccelRotCtr:
    ldWriteZero UBnkAccel                   ; byte #28 accel (INF),Y                                       ;;;;    set UBnkAccel & UBnkrotZCounter to 0	
	break
    ld		(UBnkrotZCounter),a				; byte #30 rotz counter (INF),Y                                ;;;;   
	call	EraseOldLines					; EE51 \ if bit3 set erase old lines in XX19 heap              ;;;;    gosub erase old lines (EE51)   
;...............................................................................................................................................................................
LL9SetExploRad:
	ldWriteConst 18,UbnKEdgeHeapCounter		; Counter for explosion radius                                 ;;;;    set explosion raidus XX19[1] to 18 
	ldCopyByte ExplosionCtAddr,UbnkEdgeHeapBytes ; Hull byte#7 explosion of ship type e.g. &2A           ;;;;    set XX19 [2] to Explosion type for ship (i.e nbr of 
    call    fillHeapRandom4Points                                                                          ;;;;    set first 4 bytes of XX19 Heap to random number      ::EE55
    ld      a,(UBnKzsgn)                                                                                   ;;;;    set a to z pos sign
	jp      ObjectInFront                                                                                  ;;;;    goto DoExplosion		
;...............................................................................................................................................................................
DoExplosionOrClear7:	                                                                                   ;;;;     	
EE28:										; bit5 set do explosion, or bit7 clear, dont kill.             ;;;;   DoExplosion:If z ccordinate sign is +ve 
EE49:
	JumpOnMemBitSet UBnKzsgn,7,TestToRemove ; if zSign is negative then its behind so see if we remove
;...............................................................................................................................................................................
ObjectInFront:      
LL10:										; LL10	 object in front of you                                   ; if object z is > FarInFront
    JumpIfMemGTENusng UBnKzhi,FarInFront,TestToRemove  ; LL14		\ test to remove object                               ;    else if abs(x) > z or abs(y) > z
LL10CheckFov:
    JumpIfObjectOutsideFov TestToRemove     ; was the result -ve i.e. hl > de?  x > z so outside FoV                                                                          ;         .
LookAtGunNode:
    LL10AddGunNode                                                                                                ;         NodeHeap[GunVertex, GunVertex+1] = 255
LL10TestTooFarAway:                         ; if zhi / 8 > 0 then its too far
    JumpIfTooFarAway SkipToAsFar            ; LL13 - hop as far , i.e. zhi not 0 after divide by 8
LL10CloseEnoughToDraw:
; if zhi /16     
    ld      a,h                             ; get zHi shifted again
    rr      a                               ; bring in hi bit0 from last shiftHLRight1
    srl     a                               ;
    srl     a                               ; 
    srl     a                               ; zhi is now max 31
    ld      (UBnkVisibility),a              ; set XX4 to result, If this occurs then it’s a guaranteed call to LL17 to draw.
;    Note the use of hop for jump/branch instrunction Rather than hop being calc logic
;    The original did a bransh on positive but 3 shift right logicalks means bit 7 can never be set    
ObjectDrawForwards:
    call    DrawForwards
    ret
    jp      ObjectDrawForwards              ; LL17 guaranteed hop to Draw wireframe
;...............................................................................................................................................................................
SkipToAsFar:
; IF we are here then the ship may just be a dot, if its exploding thought that overrides dot
LL13:                                       ; hopped to as far
LL13DrawIfNearerThanDotDist:
; if dot_distance >= z_hi then we can still draw ship
    JumpIfMemGTEMemusng DotAddr,UBnKzhi,ObjectDrawForwards
LL13DrawIfExplodingTest:
; if exploding then draw ship
    ld      a,(UBnKexplDsp)                 ; INWK+31	\ exploding/display state|missiles
    and     $20                             ; mask bit 5 exploding
    jp      nz,ObjectDrawForwards           ; LL17 hop over to Draw wireframe or exploding
LL13TooFarPlotPoint:
    jp      ShipPlotPoint                   ; SHPPT	\ else ship plot point, up.
;----------------------------------------------------------------------------------------------------------------------------------
;...............................................................................................................................................................................
;;;LL14
;;;   if bit5 of INWK31 is set								  ::LL14
;;;      clear bit 3 of INWK31
;;;      goto DO Explosion (DOEXP )
;;;   end if
;;;   if bit 3 of INKWK 31 is set                             ::EE51
;;;      clear bt 3 of INK31
;;;      goto Clear Lines from X19  
;;;   else
;;;      return from subroutine
;;;
TestToRemove:                                                                                             ;;;;   
LL14:										; Test to remove object                                        ;;;;    
	JumpOnMemBitSet UBnKexplDsp,5,EraseOldLines  ; bit5 currently exploding?                                      ;;;;  
; Ship is exploding
; Not in documented code!!    JumpOnBitSet    a,7,EraseOldLines            ; bit7 ongoing explosion?                                      ;;;;  
	and		$F7								; clear bit3  - No longer being drawn                                                          	
	ld		(UBnKexplDsp),a					; INWK+31
	jp		DOEXP							; DOEXP \ Explosion                                               ;
;; EraseOldLines is in file EraseOldLines-EE51.asm

DOEXP: ; TODO
	or a
	ret
	