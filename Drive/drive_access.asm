M_GETSETDRV             equ $89
F_OPEN                  equ $9a
F_CLOSE                 equ $9b
F_READ                  equ $9d
F_WRITE                 equ $9e
F_SEEK                  equ $9f
            
FA_READ                 equ $01
FA_APPEND               equ $06
FA_OVERWRITE            equ $0C

GetDefaultDrive:        push	af,,bc,,de,,hl,,ix
                        xor	    a	; set drive. 0 is default
                        rst	    $08
                        db	    $89
                        ld	    (DefaultDrive),a
                        pop		af,,bc,,de,,hl,,ix
                        ret
DefaultDrive:	        db	0

; *******************************************************************************************************
;	Function:	Open a file read for reading/writing
;	In:		ix = filename
;			b  = Open filemode
;	ret		a  = handle, 0 on error
; *******************************************************************************************************
fOpen:	                push	hl,,ix
                        push	ix
                        ld	    a,(DefaultDrive)
                        rst	    $08
                        db	    F_OPEN
                        pop	    hl,,ix
                        ret
				
; *******************************************************************************************************
;	Function	Read bytes from the open file
;	In:		ix  = address to read into
;			bc  = amount to read
;	ret:		carry set = error
; *******************************************************************************************************
fRead:                  or   	a             ; is it zero?
                        ret  	z             ; if so return		
                        push	hl,,ix   	 ; load ix into hl and save hl for later
                        pop		hl
                        rst	    $08
                        db	    F_READ
                        pop	    hl
                        ret		
		
; *******************************************************************************************************
;	Function	Read bytes from the open file
;	In:		ix  = address to read into
;			bc  = amount to read
;	ret:		carry set = error
; *******************************************************************************************************
fWrite:                 or   	a             ; is it zero?
                        ret  	z             ; if so return		
                        push	hl,,ix
                        pop	    hl
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
;		ix = address to load to
; *******************************************************************************************************
FileLoad:	            call    GetDefaultDrive		; need to do this each time?!?!?
                        push	bc,,de,,af
                        ; get file size
                        ld	    c,(hl)
                        inc	    l
                        ld	    b,(hl)
                        inc	    l
                        push	bc,,ix			; store size, load address, 
                        push	hl				; get name into ix
                        pop	    ix
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
; In:		hl = file data pointer
;		ix = address to save from
;		bc = size
; *******************************************************************************************************
FileSave:	            call    GetDefaultDrive		; need to do this each time?!?!?
                        push	bc,,hl   			; store size& save address
                        push	hl		        	; get name into ix
                        pop	    ix
                        ld      b,FA_OVERWRITE		; mode open for writing
                        call    fOpen
                        jr	    c,.error_opening	; carry set? so there was an error opening and A=error code
                        cp	    0			        ; was file handle 0?
                        jr	    z,.error_opening	; of so there was an error opening.
                        pop	    ix			        ; get save address back
                        pop	    bc			        ; get size back
                        push	af			        ; remember handle
                        call	fWrite			    ; read data from A to address IX of length BC                
                        jr	c,.error
                        pop	af			            ; get handle back
                        call	fClose			    ; close file
.error:                 ret
;
; On error, display error code an lock up so we can see it
;
.error_opening:         pop	ix
                        pop	bc	; don't pop a, need error code
                        ret		
		