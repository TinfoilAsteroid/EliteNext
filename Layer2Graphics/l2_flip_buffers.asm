; The layer 2 page shown and the shadow (draw) page are kept here rather than read back with GetNextReg, so the flip
; needs no interrupt protection: it's called from main code, from the attract mode interrupt and at startup with
; interrupts off (l2_initialise). l2_initialise and l2_320_initialise are the only other writers of the two registers.
l2_page_shown           DB      LAYER2_SCREEN_BANK1         ; (these two must stay together, read as a pair)
l2_page_shadow          DB      LAYER2_SHADOW_BANK1

l2_flip_buffers:        ld      de,(l2_page_shown)          ; e = shown, d = shadow
                        ld      a,d                         ; the shadow page goes on screen
                        nextreg LAYER2_RAM_PAGE_REGISTER, a
                        ld      a,e                         ; and what was shown becomes the shadow
                        nextreg LAYER2_RAM_SHADOW_REGISTER, a
                        ld      a,d                         ; swap the pair
                        ld      d,e                         ; .
                        ld      e,a                         ; .
                        ld      (l2_page_shown),de          ; .
                        ret

; after the initialises set the registers to LAYER2_SCREEN_BANK1 / LAYER2_SHADOW_BANK1
l2_reset_page_pair:     ld      a,LAYER2_SCREEN_BANK1
                        ld      (l2_page_shown),a
                        ld      a,LAYER2_SHADOW_BANK1
                        ld      (l2_page_shadow),a
                        ret
