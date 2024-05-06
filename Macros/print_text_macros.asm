
print_msg_at_de_at_b_hl_macro:  MACRO   varcolour
                        ld      c,varcolour
                        call    l2_print_at_320
                        ENDM

print_msg_ld_bc_at_de_macro:  MACRO  varcol
                        ld      hl,varcol
                        call    l2_print_at_320
                        ENDM
                        
print_msg_at_de_macro:  MACRO   varcolour, varrow, varcol
                        ld      c,varcolour
                        ld      b,varrow
                        ld      hl,varcol
                        call    l2_print_at_320
                        ENDM

print_msg_ld_bc_macro:  MACRO   varcol, varmessage
                        ld      hl,varcol
                        ld      de,varmessage
                        call    l2_print_at_320
                        ENDM  
                        
print_msg_macro:        MACRO   varcolour, varrow, varcol, varmessage
                        ld      c,varcolour
                        ld      b,varrow
                        ld      hl,varcol
                        ld      de,varmessage
                        call    l2_print_at_320
                        ENDM    

print_msg_wrap_macro:   MACRO   varcolour, varrow, varcol, varmessage
                        ld      c,varcolour
                        ld      b,varrow
                        ld      hl,varcol
                        ld      de,varmessage
                        call    l2_print_at_wrap_320
                        ENDM 
                        