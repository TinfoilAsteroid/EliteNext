 DEVICE ZXSPECTRUMNEXT
 DEFINE  DOUBLEBUFFER 1
 DEFINE  LOGMATHS     1
 CSPECTMAP SpriteWriter.map
 OPT --zxnext=cspect --syntax=a --reversepop

DEBUGSEGSIZE   equ 1
DEBUGLOGSUMMARY equ 1
;DEBUGLOGDETAIL equ 1


                        ORG     $8000
.OpenOutputFile:        ;call    GetDefaultDrive
                        ld      ix, Filename
                        ld      b, FA_OVERWRITE
                        ld      a,$01
                        ld      (FileNumber),a
                        ld      hl,Sprite1
                        ld      b,38
.WriteLoop:             push    bc,,hl
                        call    WriteFile
                        ld      a,(FileNumber)
                        inc     a
                        daa
                        ld      (FileNumber),a
                        pop     bc,,hl
                        ld      de,256
                        add     hl,de
                        djnz    .WriteLoop
.Done:                  jp      .Done                        
                        
                        
                        
WriteFile:              call    FileNbrA
                        ld      ix,hl
                        ld      hl,Filename
                        ld      bc,256
                        call    FileSave
                        ret
                     
                        
FileNbrA:               ld      a,(FileNumber)
                        swapnib
                        and     %00001111
                        ld      b,"0"
                        add     b
                        ld      (FileNbr),a
                        ld      a,(FileNumber)
                        and     %00001111
                        add     b
                        ld      (FileNbr+1),a
                        ret
                        
                       

FileWork                DS 10
FileNumber:             DB  0

Filename                DB "NESpr"
FileNbr                 DB "00"
Extension:              DB ".dat",0
        
                        INCLUDE "./Maths/binary_to_decimal.asm"
                        INCLUDE "./Hardware/drive_access.asm"
                        INCLUDE "./Layer3Sprites/SpriteSheet.asm"


    SAVENEX OPEN "SpriteWriter.nex", $8000 , $7F00
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    