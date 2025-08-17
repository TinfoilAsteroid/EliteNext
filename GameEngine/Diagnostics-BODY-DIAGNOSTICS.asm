
                        
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
                            ld      d,0
                            call    l1_attr_line_d_to_a
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
                            ; Player speed roll and pitch
                            ld      a,(ALPHAFLIP)
                            ld      h,a
                            ld      a,(AlphaDecimal)
                            ld      l,a
                            ld      de,$0001
                            call    l1_print_s16_hex_at_char
                            ld      a,(BETA)
                            ld      h,a
                            ld      a,(BetaDecimal)
                            ld      l,a
                            ld      de,$0007
                            call    l1_print_s16_hex_at_char
                            ld      a,(ALPHAFLIP)
                            ld      h,a
                            ld      a,(AlphaDecimal)
                            ld      l,a
                            ld      de,$0001
                            call    l1_print_s16_hex_at_char
                            ld      a,(BETA)
                            ld      h,a
                            ld      a,(BetaDecimal)
                            ld      l,a
                            ld      de,$0007
                            call    l1_print_s16_hex_at_char
                            ; ship speed roll and pitch
                            ld      de,$0010
                            ld      a,(UBnKRotZCounter)
                            call    l1_print_82c_hex_at_char
                            ld      de,$0016
                            ld      a,(UBnKRotXCounter)
                            call    l1_print_82c_hex_at_char
                            ; Position X Y Z
                            ld      a,(UBnKxlo)
                            ld      hl,(UBnKxhi)
                            ld      de,$0101
                            call    l1_print_s24_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      a,(UBnKylo)
                            ld      hl,(UBnKyhi)
                            ld      de,$0201
                            call    l1_print_s24_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      a,(UBnKzlo)
                            ld      hl,(UBnKzhi)
                            ld      de,$0301
                            call    l1_print_s24_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                           
                            ld      hl,(UBnkrotmatSidevX)
                            ld      de,$010A
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      hl,(UBnkrotmatSidevY)
                            ld      de,$0110
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      hl,(UBnkrotmatSidevZ)
                            ld      de,$0116
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                           
                            ld      hl,(UBnkrotmatRoofvX)
                            ld      de,$020A
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      hl,(UBnkrotmatRoofvY)
                            ld      de,$0210
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      hl,(UBnkrotmatRoofvZ)
                            ld      de,$0216
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE

                            ld      hl,(UBnkrotmatNosevX)
                            ld      de,$030A
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      hl,(UBnkrotmatNosevY)
                            ld      de,$0310
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      hl,(UBnkrotmatNosevZ)
                            ld      de,$0316
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE

                            ld      hl,(UBnkTransmatSidevX)
                            ld      de,$040A
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      hl,(UBnkTransmatSidevY)
                            ld      de,$0410
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      hl,(UBnkTransmatSidevZ)
                            ld      de,$0416
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                           
                            ld      hl,(UBnkTransmatRoofvX)
                            ld      de,$050A
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      hl,(UBnkTransmatRoofvY)
                            ld      de,$0510
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      hl,(UBnkTransmatRoofvZ)
                            ld      de,$0516
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE

                            ld      hl,(UBnkTransmatNosevX)
                            ld      de,$060A
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      hl,(UBnkTransmatNosevY)
                            ld      de,$0610
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE
                            ld      hl,(UBnkTransmatNosevZ)
                            ld      de,$0616
                            call    l1_print_s16_hex_at_char  ; prints 16 bit lead sign hex value in HLA at char pos DE

                        ENDIF
                        