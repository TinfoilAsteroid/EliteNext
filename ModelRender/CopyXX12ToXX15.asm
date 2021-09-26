CopyXX12ToXX15:
        ld      hl,XX12
        ld      de,XX15
        ld      bc,6
        ldir
		ret
		
CopyXX12ToXX12Save:
        ld      hl,XX12
        ld      de,XX12Save
        ld      bc,6
        ldir
		ret
		        
CopyXX12SaveToXX12:
        ld      hl,XX12Save
        ld      de,XX12
        ld      bc,6
        ldir
		ret

CopyXX12ToXX12Save2:
        ld      hl,XX12
        ld      de,XX12Save2
        ld      bc,6
        ldir
		ret
		        
CopyXX12Save2ToXX12:
        ld      hl,XX12Save2
        ld      de,XX12
        ld      bc,6
        ldir
		ret
                