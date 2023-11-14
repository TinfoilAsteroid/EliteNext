; Use bank 0 as source and bank 7 as write target
ResetUniv:              MMUSelectCpySrcN BankUNIVDATA0	         ; master universe def in bank 0
                        ld		a,1             				 ; we can read bank 0 as if it was rom
                        ld		b,TotalUniverseBanks
.ResetCopyLoop:         push	bc,,af
                        MMUSelectUniverseA			             ; copy from bank 0 to 71 to 12
                        ld		hl,UniverseBankAddr
                        ld		de,dmaCopySrcAddr
                        ld		bc,UnivBankSize
                        call	memcopy_dma
                        pop		bc,,af
                        ld      d,a
                        add     "A"
                        ld      (StartOfUnivN),a
                        ld      a,d
                        inc		a
                        djnz	.ResetCopyLoop
                        ret

; Use bank 0 as source and bank 7 as write target
ResetGalaxy:            MMUSelectCpySrcN BankGalaxyData0	     ; master universe def in bank 0 we can read bank 0 as if it was rom
                        ld		a,BankGalaxyData1 			   	 ; and write to real location for galaxy data
                        ld		b,7                              ; 8 galaxies but we start with galaxy 0
                        ld      c,1                              ;
.ResetCopyLoop:         push	af                               ;
                        push	bc                               ;
                        MMUSelectGalaxyA    	                 ; copy from bank 0 to galaxy 1 to 7
                        ld		hl,GalaxyDataAddr                ; using dma transfer
                        ld		de,dmaCopySrcAddr                ; .
                        ld		bc,GalaxyBankSize                ; .
                        call	memcopy_dma                      ; .
                        pop		bc                               ; .
                        ld      hl, galaxy_pg_cnt                ; write out the galaxy page nbr to the page so we can diagnose page swapping
                        ld      a,c                              ;  
                        add     a, $30                           ; add $30 (48) to get ascii of galaxy nbr
                        ld      (hl),a                           ; .
                        inc     c                                ; Do next bank
                        pop     af                               ; .
                        inc		a                                ; .
                        djnz	.ResetCopyLoop                    ; .
                        ret
                    
SeedAllGalaxies:        ld          b,8
                        ld          c,BankGalaxyData0
.SeedAllGalaxiesLoop:   push        bc
                        ld          a,c
                        MMUSelectGalaxyA
                        call        SeedGalaxy
                        pop         bc
                        inc         c
                        djnz        .SeedAllGalaxiesLoop
                        ret