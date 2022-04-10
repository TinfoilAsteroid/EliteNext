LaserDrainSystems:      DrainSystem PlayerEnergy, CurrLaserEnergyDrain
                        BoostSystem GunTemperature, CurrLaserHeat
                        ret
                        
                        
ResetPlayerShip:        ZeroThrottle
                        ZeroPitch
                        ZeroRoll
                        ClearMissileTarget
                        ClearECM
                        ChargeEnergyAndShields
                        ClearTemperatures
                        call    IsLaserUseable
                        MMUSelectCommander
                        call    LoadLaserToCurrent
                        ret     z
                        
                        ret

IsLaserUseable:         ld      a,(CurrLaserType)
                        cp      255
                        ret     z
                        ld      a,(CurrLaserDamage)
                        cp      255
                        ret

InitMainLoop:           call    ClearUnivSlotList
                        xor     a
                        ld      (CurrentUniverseAI),a
                        ld      (SetStationAngryFlag),a
                        ld      a,3
                        ld      (MenuIdMax),a
                        SetMemFalse DockedFlag
;                        call    InitialiseFrontView
                        call    InitialiseCommander
                        MMUSelectUniverseN 2    
                        call    SetInitialShipPosition
; Initialist screen refresh
                        ld      a, ConsoleRefreshInterval
                        ld      (ConsoleRefreshCounter),a
                        SetMemFalse    ConsoleRedrawFlag
                        MMUSelectStockTable
                        call    generate_stock_market
                        call    ResetMessageQueue
                        InitEventCounter
                        ClearMissJump
                        SetMemFalse TextInputMode
                        ret
                        