M_GETSETDRV             equ $89
F_OPEN                  equ $9a
F_CLOSE                 equ $9b
F_READ                  equ $9d
F_WRITE                 equ $9e
F_SEEK                  equ $9f
            
FA_READ                 equ $01
FA_APPEND               equ $06
FA_OVERWRITE            equ $0C
DISK_FILEMAP            equ $85
DISK_STRMSTART          equ $86
DISK_STRMEND            equ $87

ESX_MODE_READ           equ $01
ESX_MODE_OPEN_EXIST     equ $00

FILEMAP_SIZE            equ $20
FILEMAP_BLOCK_SIZE      equ $06

; Success 1 = default drive, carry reset
; Failure HL = -1 , carry set, errno set
GetDefaultDrive:        push	af,,bc,,de,,hl,,ix
                        xor	    a	; a = 0 means get default drive into A
                        rst	    $08
                        db	    M_GETSETDRV
                        ld	    (DefaultDrive),a
                        pop		af,,bc,,de,,hl,,ix
                        ret
                        

; Disable NMI Multi face - needed for streaming
;disable_multiface:      ld      bc,REGISTER_NUMBER_PORT
;                        ld      a,PERIPHERAL_2_REGISTER
;                        out     (c),a
;                        inc     b
;                        in      a,(c)
;                        and     %11110111
;                        out     (c),a
;                        ret
;
;enable_multiface:       ld      bc,REGISTER_NUMBER_PORT
;                        ld      a,PERIPHERAL_2_REGISTER
;                        out     (c),a
;                        inc     b
;                        in      a,(c)
;                        or      %00001000
;                        out     (c),a
;                        ret
;
; *******************************************************************************************************
;	Function:	Open a file read for reading/writing
;	In:		ix = filename
;			b  = Open filemode
;	ret		a  = handle, 0 on error
;   fOpen_read_exists takes defaults and sets up default drive
; *******************************************************************************************************
;fOpen_read_exists:      ld      b,ESX_MODE_READ | ESX_MODE_OPEN_EXIST
;                        call    GetDefaultDrive
;                        call    fOpen
;                        call    fRefill_map
;                        jp      c,.RefilMapError
;                        jp      z,.RefilMapEmpty
;                        ret
;.RefilMapError:         jp      .RefilMapError
;.RefilMapEmpty:         jp      .RefilMapEmpty
;                        
;                        
                        
fOpen:	                ld	    a,(DefaultDrive); default drive must be called before we start
                        rst	    $08
                        db	    F_OPEN
                        ld      (FileHandle),a  ; make a local copy of last file opened
                        jr      c,.FileOpenError
                        ret
.FileOpenError:         jp      .FileOpenError	

; *******************************************************************************************************
;	Function	refills the buffer map with card addresses for the file
;	In:		a  = file handle (if calling fRefill_mapA)
;           ix = address of filemap_buffer (if calling fRefill_mapA)
;           de = filemap size (which should equal 4 in our case)
;			bc  = amount to read
;	ret:		carry set = error
;               zero set  = no data loaded so still error
;   you can use fRefill_map to pull default valuess
; *******************************************************************************************************
;fRefill_map:            ld      a,(FileHandle)
;                        ld      ix,FilemapBuffer
;                        ld      de,FILEMAP_SIZE
;fRefill_mapA:           rst     $08
;                        db      DISK_FILEMAP
;.SetFlags:              ld      (CardFlags),a                   ; set up adressing mode flags  bit 0=card id (0 or 1) bit 1=0 for byte addressing, 1 for block addressing
;.CheckForEntries:       ld      (FilemapBufferLast),hl          ; save last entry address +2
;                        ld      de,FilemapBuffer
;                        sbc     hl,de                           ; hl = number of entries found
;                        ld      a,$ff
;                        ret
;
;read_stream_block:      ld      hl,(FilemapBufferPointer)                       
;                        ldBCDEatHL                              ; load the disk address 
;                        push    bc                              ; into IXDE
;                        pop     ix                              ; now IXDE = card address
;                        ldBCatHL                                ; bc = number of blocks to be read
;                        ld      (FilemapBlockCount),bc
;                        ret
; Start up stream of data
; If successful, the call returns with:
; B=protocol: 0=SD/MMC, 1=IDE,  C=data port
; NOTE: On the Next, these values will always be: B=0 C=$EB
;fStream_start:          ld      hl,FilemapBuffer                ; set to head of filemap
;                        ld      (FilemapBufferPointer),hl       ; .
;                        ZeroA
;                        ld      (FilereadsPerformed),a
;                        call    read_stream_block
;                        ld      a,(CardFlags)                   ; get card flags back
;                        rst     $08
;                        DB      DISK_STRMSTART                  ; start up stream
;                        ld      (FileStreamPort),bc             ; save port information (even through it will not change on a next)
;                        ret
                
; *******************************************************************************************************
;	Function	stream in a block of data to memory
;	In:		ix  = address to read into
;			bc  = amount to read
;	ret:		carry set = error
; *******************************************************************************************************
;fStream_block:          ld      ix,FileBuffer
;                        ld      a,(CardFlags)
;                        ld      bc,(FileStreamPort)
;                        ld      hl,FileBuffer
;                        ld      (FilemapBufferPointer),hl 
;.StreamLoop:            ld      b,0
;                        ld      a,(TargetSize+1)
;                        cp      2
;                        jr      c,.stream_partial_block
;.StreamFullBlock:       inir                                ; read 256 bytes to hl
;                        inir                                ; read 256 bytes to hl+256
;                        dec     b                           ; update byte count
;                        dec     b                           ; .
;                        ld      hl,TargetSize               ; 512 bytes read
;                        ld      de,512
;                        ClearCarryFlag
;                        sbc     hl,de
;                        ld      (TargetSize),hl         
;                        ld      a,(FileStreamPort+1)        ; get the protocol
;                        and     a
;                        jr      nz,.protocol_ide            ; we arn't using but for compatibility
;.protocol_sdmmc:        in      a,(c)                       ; for sd and mmc, read in the 2 byte CRC
;                        nop                                 ; as the max performance of the interface is
;                        nop                                 ; 16T per byte, no ops pad out operation
;                        in      a,(c)
;                        nop                        
;                        nop
;.wait_for_next_block:   in      a,(c)                       ; if wait token is not FF then we are read
;                        cp      $FF
;                        jr      z,.wait_for_next_block
;                        cp      $FE                         ; if not and its not FE its a fault
;                        jr      nz,.token_error
;.protocol_ide:          ld      de,(TargetSize)             ; Any more bytes required
;                        ld      a,d
;                        or      e
;                        jr      z,.streaming_complete
;                        ret
;.stream_partial_block:  and     a                           ; is block at least 256 bytes?
;                        jr      z,.under256_bytes
;                        inir                                ; get 256 bytes
;.under256_bytes:        ld      b,e
;                        inc     b
;                        dec     b
;                        jr      z,.streaming_complete
;                        inir
;.streaming_complete:    ld      a,(CardFlags)
;                        rst     $08
;                        DB      DISK_STRMEND
;                        ld      a,(FileHandle)
;                        call    fClose
;                        ret
;.token_error:           jp      .token_error
;                        
;
;fOpenReadFile:          ld      (TargetSize),bc
;                        call    disable_multiface
;                        call    fOpen_read_exists
;.SetupStream:           call    fStream_start
;                        jr      c,.FileStreamError
;                        ret
;                        
;.FileStreamError:       jp      .FileStreamError
;                
; *******************************************************************************************************
;	Function	Read bytes from the open file
;	In:		ix  = address to read into
;			bc  = amount to read
;	ret:		carry set = error
; *******************************************************************************************************
fRead:                  or   	a             ; is it zero?
                        ret  	z             ; if so return		
                        push    hl
                        ld      hl,ix    	 ; load ix into hl and save hl for later
                        rst	    $08
                        db	    F_READ
                        pop	    hl
                        ret		
		
; *******************************************************************************************************
;	Function	Write bytes to the open file
;	In:		ix  = address to read from
;			bc  = amount to write
;	ret:		carry set = error
; *******************************************************************************************************
fWrite:                 or   	a             ; is it zero?
                        ret  	z             ; if so return		
                        push	hl
                        ld      hl,ix
                        rst	    $08
                        db	    F_WRITE
                        pop	    hl
                        ret

; *******************************************************************************************************
;	Function:	Close open file
;	In:		a  = handle
;	ret		a  = handle, 0 on error
; *******************************************************************************************************
fClose:		            or   	a             ; is it zero?
                        ret  	z             ; if so return		
                        rst	    $08
                        db	    F_CLOSE
                        ret

;fSeekHome:              push    bc,,de,,hl,,ix
;                        ld      bc,0
;                        ld      de,0
;                        ld      l,0
;                        call    fSeek 
;                        pop     bc,,de,,hl,,ix
;                        ret
;                        
;fSeekForward256:        push    bc,,de,,hl,,ix
;                        ld      bc,0
;                        ld      de,256
;                        ld      l,1
;                        call    fSeek
;                        pop     bc,,de,,hl,,ix
;                        ret
                                                
; *******************************************************************************************************
;	Function	Read bytes from the open file
;	In:		a   = file handle
;			L   = Seek mode (0=start, 1=rel, 2=-rel)
;			BCDE = bytes to seek
;	ret:		BCDE = file pos from start
; *******************************************************************************************************
fSeek:                  push	ix,,hl
                        rst	    $08
                        db	    F_SEEK
                        pop	    ix,,hl
                        ret

; *******************************************************************************************************
; Init the file system
; *******************************************************************************************************
InitFileSystem:         call    GetDefaultDrive
                        ret

; *******************************************************************************************************
; Function:	Load a whole file into memory	(confirmed working on real machine)
; In:		hl = file data pointer
;		    ix = address to load to
;           bc = filelength
; *******************************************************************************************************
FileLoad:	            call    GetDefaultDrive
                        push	bc,,de,,af
                        ; get file size
                        push	bc,,ix			; store size, load address, 
                        ld      ix,hl
                        ld      b,FA_READ		; mode open for reading
                        call    fOpen
                        jr	    c,.error_opening; carry set? so there was an error opening and A=error code
                        cp	    0				; was file handle 0?
                        jr	    z,.error_opening; of so there was an error opening.
                        pop     bc,,ix          ; get load address back and size back
                        push	af				; remember handle
                        call	fRead			; read data from A to address IX of length BC                
                        jr	    c,.error_reading
                        pop	    af			    ; get handle back
                        call	fClose			; close file
                        jr	    c,.error_closing
                        pop     bc,,de,,af      ; normal exit
                        ret
;
; On error, display error code an lock up so we can see it
;
.error_opening:         pop	ix
.error_reading:		    pop	bc	; don't pop a, need error code

.error_closing: 
.NormalError:  	        pop	bc	; don't pop into A, return with error code
                        pop	de
                        pop	bc
                        ret

; *******************************************************************************************************
; Function:	Save a whole file into memory	(confirmed working on real machine)
; In:		hl = file name
;		    ix = address to save from
;		    bc = size
; *******************************************************************************************************
FileSave:	            call    GetDefaultDrive		; need to do this each time?!?!?
                        push	bc,,ix   			; store size& save address
                        ld      ix,hl               ; get name into ix
                        ld      b,FA_OVERWRITE		; mode open for writing
                        call    fOpen
                        jr	    c,.error_opening	; carry set? so there was an error opening and A=error code
                        cp	    0			        ; was file handle 0?
                        jr	    z,.error_opening	; of so there was an error opening.
                        pop	    bc,,ix			    ; get lenght and save address back
                        push	af			        ; remember handle
                        call	fWrite			    ; read data from A to address IX of length BC                
                        jr	c,.error
                        pop	af			            ; get handle back
                        call	fClose			    ; close file
.error:                 ret
;
; On error, display error code an lock up so we can see it
;
.error_opening:         pop	bc,,ix                  ; don't pop a, need error code
                        ret		
		
DefaultDrive:	        DB	0
FileHandle:             DB  0
CardFlags               DB  0
TargetSize              DW  0
FileStreamPort          DW  0
FileBuffer              DS  512                     ; block of data
FilereadsPerformed      DB  0
FilemapBlockCount       DW  0
FilemapBufferPointer    DW  0
FilemapBufferLast       DW  0
FilemapBuffer           DS  FILEMAP_BLOCK_SIZE * FILEMAP_SIZE        ; expecting 60 to be overkill as most should be 1

