 DEVICE ZXSPECTRUMNEXT
 DEFINE  DOUBLEBUFFER 1
 DEFINE  LOGMATHS     1
 CSPECTMAP SpriteWriter.map
 OPT --zxnext=cspect --syntax=a --reversepop

DEBUGSEGSIZE   equ 1
DEBUGLOGSUMMARY equ 1
;DEBUGLOGDETAIL equ 1


                        ORG     $8000
            
.OpenOutputFile:        ld      ix, Filename
                        ld      b, FA_OVERWRITE
                        call    fOpen
                        cp      0
                        jr      z,.OpenFailed
                        push    af
.WriteData:             ld      ix,Sprite1
                        ld      bc,256*29
                        call    fWrite
                        jr      c, .WriteFailed
.CloseFile:             pop     af
                        call    fClose
                        cp      0
                        jr      z, .CloseFailed
.Complete:              jp      .Complete                        
            
            
.OpenFailed:            ld      a,-1
                        jp      .OpenFailed
        
.WriteFailed:           ld      a,-2
                        jp      .WriteFailed
        
.CloseFailed:           ld      a,-3
                        jp      .CloseFailed

Filename                DB "NextSprt.dat",0

                        INCLUDE "./Hardware/drive_access.asm"
                        INCLUDE "./Layer3Sprites/SpriteSheet.asm"


    SAVENEX OPEN "SpriteWriter.nex", $8000 , $7F00
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    