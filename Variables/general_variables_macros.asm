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
                    

HalfLengthHL:           ld      b,0
.CountLenLoop:          ld      a,(hl)
                        cp      0
                        jr      z,.DoneCount
                        inc     b
                        inc     hl
                        jr      .CountLenLoop
.DoneCount:             ld      a,32
                        sub     b
                        sra     a         
                        ret

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

ClearMissileTarget:     MACRO
                        xor     a
                        dec     a
                        ld      (MissileTarget),a
                        ENDM
                        
ClearECM:               MACRO   
                        xor     a
                        ld      (ECMLoopA),a
                        ld      (ECMLoopB),a
                        ENDM
                        
ChargeEnergyAndShields: MACRO
                        ld      a,$FF
                        ld      (PlayerEnergy),a
                        ld      (ForeShield),a
                        ld      (AftShield),a
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
                
SetSafeZone:            MACRO
                        ld      a,$FF
                        ld      (SpaceStationSafeZone),a
                        ENDM

ClearSafeZone:          MACRO
                        xor     a
                        ld      (SpaceStationSafeZone),a
                        ENDM

CoolLasers:             MACRO
                        ld      a,(GunTemperature)
                        and     a
                        jr      z,.AlreadyCool
                        dec     a
                        ld      (GunTemperature),a
.AlreadyCool:           
                        ENDM                        
                        
InitEventCounter:       MACRO
                        xor     a
                        ld      (EventCounter),a
                        ENDM
                        
ClearMissJump:          MACRO
                        xor     a
                        ld      (MissJumpFlag),a
                        ENDM
                        