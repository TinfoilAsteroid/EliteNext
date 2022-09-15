; limited to 255 character length
CountLengthHL:          MACRO   Limiter
                        ld      de,hl
                        ld      bc,Limiter
                        xor     a
                        cpir
                        ClearCarryFlag
                        sbc     hl,de
                        ld      a,l
                        ret
                        ENDM

IncMemMaxN:             MACRO   mem, maxvalue
                        ld      a,(mem)
                        cp      maxvalue
                        jr      c,.IncMaxed
                        inc     a
                        ld      (mem),a
.IncMaxed:
                        ENDM

IncMemMaxNCycle:        MACRO   mem, cyclevalue
                        ld      a,(mem)
                        inc     a
                        cp      cyclevalue
                        jr      c,.IncMaxed
                        xor     a
.IncMaxed:              ld      (mem),a
                        ENDM
                        

HalfLengthHL:           MACRO
                        ld      b,0
.CountLenLoop:          ld      a,(hl)
                        cp      0
                        jr      z,.DoneCount
                        inc     b
                        inc     hl
                        jr      .CountLenLoop
.DoneCount:             ld      a,32
                        sub     b
                        sra     a         
                        ENDM

MakeInnocentMacro:		MACRO
						xor		a
						ld		(FugitiveInnocentStatus),a
						ENDM
						
NoEscapePodMacro:		MACRO
						xor		a
						ld		(EscapePod),a
						ENDM				

MaxFuelLevel            EQU     70              ; 7.0 light years max
MaxFuelMacro:			MACRO
						ld		a,MaxFuelLevel
						ld		(Fuel),a
						ENDM				
                        
MaxThrottle:            MACRO
                        ld      a,(SHIPMAXSPEED)
                        ld      (DELTA),a
                        ld      d,a
                        ld      e,4
                        mul
                        ld      (DELT4Lo),de
                        ENDM
                        
ZeroThrottle:           MACRO                        
                        xor     a
                        ld      (DELTA),a
                        ld      (DELT4Lo),a
                        ld      (DELT4Lo+1),a
                        ENDM
                        
ZeroPitch:              MACRO
                        xor     a   
                        ld      (BET2),a
                        ld      (BET2FLIP),a
                        ld      (JSTY),a
                        ld      (BETA),a
                        ENDM
                        
ZeroRoll:               MACRO
                        xor     a                              ; zero roll and climb
                        ld      (ALP2),a
                        ld      (ALP2FLIP),a
                        ld      (JSTX),a
                        ld      (ALPHA),a
                        ENDM

CorrectPostJumpFuel:    MACRO
                        ld      a,(Fuel)
                        ld      hl,Distance
                        sub     a,(hl)
                        ld      (Fuel),a
                        ENDM

AnyMissilesLeft:        MACRO
                        ld      a,(NbrMissiles)
                        and     a
                        ENDM

SetMissileTargetA:      MACRO
                        ld      (MissileTargettingFlag),a   ; Set to slot number clearing bit 7
                        ENDM

IsMissileLaunchFlagged: MACRO
                        ld      a,(MissileTargettingFlag)
                        and     $80
                        ENDM

SetMissileTargetting:   MACRO
                        ld      a,StageMissileTargeting
                        ld      (MissileTargettingFlag),a
                        ENDM

ClearMissileTargetting: MACRO
                        ld      a,StageMissileNotTargeting
                        ld      (MissileTargettingFlag),a
                        ENDM


; Clear targetting bits which signals launch if lower nibble has selected target
SetMissileLaunch:       MACRO
                        ld      a,(MissileTargettingFlag)
                        and     $0F
                        ld      (MissileTargettingFlag),a                        
                        ENDM 
                        
LockMissileToA:         MACRO
                        or      $80
                        ld      (MissileTargettingFlag),a
                        ENDM
                        
ClearECM:               MACRO   
                        xor     a
                        ld      (ECMCountDown),a
                        ENDM

                        
; Will check to see if bit 2 is set, if it is clear, then friendly hence z is set
;                                    if hit is set then hostile hence z is not set
IsShipHostile:          MACRO                               
                        ld      a,(ShipNewBitsAddr)
                        and     ShipIsHostile
                        ENDM     

; Will check to see if bit 2 is set, if it is clear, then friendly hence z is set
;                                    if hit is set then hostile hence z is not set
IsShipFriendly:         MACRO
                        ld      a,(ShipNewBitsAddr)
                        and     ShipNotHostile                  ; mask so we only have hostile bit
                        ENDM
                        
; Will check to see if bit 5 is set, if clear, then not exploding z clear
;                                    if set    then exploding     z set
IsShipExploding:        MACRO
                        ld      a,(UBnkaiatkecm)   
                        and     ShipExploding                              
                        ENDM

UpdateLaserOnCounter:   MACRO
                        ld      a,(CurrLaserPulseOnCount)
                        and     a
                        jr      z,.LaserOnIsDone
                        dec     a
                        ld      (CurrLaserPulseOnCount),a
                        jr      z,.LaserOnIsDone
                        ldCopyByte CurrLaserPulseOffTime, CurrLaserPulseOffCount
.LaserOnIsDone:
                        ENDM

UpdateLaserOffCounter:  MACRO
                        ld      a,(CurrLaserPulseOffTime)
                        and     a
                        jr      z,.LaserOffIsDone
                        dec     a
                        ld      (CurrLaserPulseOffTime),a
                        jr      z,.LaserOffIsDone
                        ldCopyByte CurrLaserPulseRest, CurrLaserPulseRestCount
.LaserOffIsDone:
                        ENDM

UpdateLaserRestCounter: MACRO
                        ld      a,(CurrLaserPulseRestCount)
                        and     a
                        jr      z,.LaserRestIsDone
                        dec     a
                        ld      (CurrLaserPulseRestCount),a
                        jr      z,.LaserRestIsDone
                        ZeroA                                                                           ;    then pulse rate count = 0
                        ld      (CurrLaserPulseRateCount),a                                             ;    .
.LaserRestIsDone
                        ENDM
                        
ChargeEnergyAndShields: MACRO
                        ld      a,$FF
                        ld      (PlayerEnergy),a
                        ld      (ForeShield),a
                        ld      (AftShield),a
                        ENDM
                        
CopyPresentSystemToTarget: MACRO
                        ld      hl,(PresentSystemX)
                        ld      (TargetSystemX),hl
                        ENDM

CopyTargetSystemToPresent: MACRO
                        ld      hl,(TargetSystemX)
                        ld      (PresentSystemX),hl
                        ENDM
               
HalveFugitiveStatus:    MACRO
                        ld      hl,FugitiveInnocentStatus
                        srl     (hl)
                        ENDM

ClearForceTransition    MACRO
                        ld      a,$FF
                        ld      (ScreenTransitionForced),a
                        ENDM

ForceTransition:        MACRO newScreen
                        ld      a,newScreen
                        ld      (ScreenTransitionForced), a
                        ENDM
                
IsSpaceStationPresent:  MACRO
                        ld      a,(SpaceStationSafeZone)
                        and     a
                        ENDM
                                                
SetSafeZone:            MACRO
                        xor     a
                        ld      (SpaceStationSafeZone),a
                        ENDM

ClearSafeZone:          MACRO
                        ld      a,$FF
                        ld      (SpaceStationSafeZone),a
                        ENDM

ClearTemperatures:      MACRO
                        xor     a
                        ld      (CabinTemperature),a
                        ld      (GunTemperature),a
                        ENDM

CoolCabin:              MACRO
                        ld      a,(CabinTemperature)
                        and     a
                        jr      z,.AlreadyCool
                        dec     a
                        ld      (CabinTemperature),a
.AlreadyCool:           
                        ENDM                        
                        
CoolLasers:             MACRO
                        ld      a,(GunTemperature)
                        and     a
                        jr      z,.AlreadyCool
                        dec     a
                        ld      (GunTemperature),a
.AlreadyCool:           
                        ENDM                        
                        
; type 255 is "not fitted"                            


InitEventCounter:       MACRO
                        xor     a
                        ld      (EventCounter),a
                        ENDM
                        
ClearMissJump:          MACRO
                        ld      a,$FF
                        ld      (MissJumpFlag),a
                        ENDM


DrainSystem:            MACRO   SystemMem, DrainMem
                        ld      a,(DrainMem)
                        ld      b,a
                        ld      a,(SystemMem)
                        sub     a,b
                        ld      (SystemMem),a
                        jr      c,.ZeroSystem
                        jp      .ExitPoint
.ZeroSystem:            ZeroA
                        ld      (SystemMem),a
.ExitPoint              
                        ENDM

BoostSystem:            MACRO   SystemMem, BoostMem
                        ld      a,(BoostMem)
                        ld      b,a
                        ld      a,(SystemMem)
                        add     b
                        ld      (SystemMem),a
                        jr      c, .MaxSystem
                        jp      .ExitPoint
.MaxSystem:             ld      a,255
                        ld      (SystemMem),a
.ExitPoint              
                        ENDM
                        
HasEngineSoundChanged:  MACRO
                        ld      a,(EngineSoundChanged)
                        and     a
                        ENDM
                        
ClearEngineSoundChanged:MACRO
                        xor      a
                        ld      (EngineSoundChanged),a
                        ENDM

SetEngineSoundChanged:  MACRO
                        ld      a,$FF
                        ld      (EngineSoundChanged),a
                        ENDM
                        