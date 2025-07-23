
                        
                        IFDEF PLANET_DIAGNOSTICS
                            MMUSelectLayer1
                            ld      a,$47
                            ld      d,1
                            call    l1_attr_line_d_to_a
                            ld      a,$47
                            ld      d,2
                            call    l1_attr_line_d_to_a
                            ld      a,$47
                            ld      d,3
                            call    l1_attr_line_d_to_a
                            ld      d,4
                            call    l1_attr_line_d_to_a
                            ld      d,5
                            call    l1_attr_line_d_to_a
                            ld      d,6
                            call    l1_attr_line_d_to_a
                            MMUSelectPlanet
                            ld      a,(P_BnKxlo)
                            ld      hl,(P_BnKxhi)
                            ld      de,$0103
                            call    l1_print_s24_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      a,(P_BnKylo)
                            ld      hl,(P_BnKyhi)
                            ld      de,$0203
                            call    l1_print_s24_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      a,(P_BnKzlo)
                            ld      hl,(P_BnKzhi)
                            ld      de,$0303
                            call    l1_print_s24_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      a,(AlphaDecimal)
                            ld      hl,(AlphaDecimal+1)
                            ld      de,$0403
                            call    l1_print_s24_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      a,(BetaDecimal)
                            ld      hl,(BetaDecimal+1)
                            ld      de,$0503
                            call    l1_print_s24_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                        ENDIF
                        
                        IFDEF SUN_DIAGNOSTICS
                            MMUSelectLayer1
                            ld      a,$47
                            ld      d,1
                            call    l1_attr_line_d_to_a
                            ld      a,$47
                            ld      d,2
                            call    l1_attr_line_d_to_a
                            ld      a,$47
                            ld      d,3
                            call    l1_attr_line_d_to_a
                            ld      d,4
                            call    l1_attr_line_d_to_a
                            ld      d,5
                            call    l1_attr_line_d_to_a
                            ld      d,6
                            call    l1_attr_line_d_to_a
                            MMUSelectSun
                            ld      a,(SBnKxlo)
                            ld      hl,(SBnKxhi)
                            ld      de,$010C
                            call    l1_print_s24_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      a,(SBnKylo)
                            ld      hl,(SBnKyhi)
                            ld      de,$020C
                            call    l1_print_s24_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      a,(SBnKzlo)
                            ld      hl,(SBnKzhi)
                            ld      de,$030C
                            call    l1_print_s24_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      hl,(SBnkNormalX)
                            ld      de,$050C
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      hl,(SCompassX)
                            ld      de,$0513
                            call    l1_print_162c_hex_at_char ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      hl,(SBnKNormalY)
                            ld      de,$060C
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      hl,(SCompassY)
                            ld      de,$0613
                            call    l1_print_162c_hex_at_char ; prints 16 bit lead sign hex value in HLA at char pos DE
                        ENDIF
                        
                        IFDEF STATION_DIAGNOSTICS
                            MMUSelectLayer1
                            ld      a,$47
                            ld      d,1
                            call    l1_attr_line_d_to_a
                            ld      a,$47
                            ld      d,2
                            call    l1_attr_line_d_to_a
                            ld      a,$47
                            ld      d,3
                            call    l1_attr_line_d_to_a
                            ld      d,4
                            call    l1_attr_line_d_to_a
                            ld      d,5
                            call    l1_attr_line_d_to_a
                            ld      d,6
                            call    l1_attr_line_d_to_a
                            MMUSelectSpaceStation
                            ld      a,(UBnKxlo)
                            ld      hl,(UBnKxhi)
                            ld      de,$0114
                            call    l1_print_s24_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      a,(UBnKylo)
                            ld      hl,(UBnKyhi)
                            ld      de,$0214
                            call    l1_print_s24_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      a,(UBnKzlo)
                            ld      hl,(UBnKzhi)
                            ld      de,$0314
                            call    l1_print_s24_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                        ENDIF