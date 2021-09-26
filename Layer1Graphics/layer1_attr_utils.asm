
L1AttrRow00:            DW $5800                    ;Row 1    */
L1AttrRow01:            DW $5820                    ;Row 2    */
L1AttrRow02:            DW $5840                    ;Row 3    */
L1AttrRow03:            DW $5860                    ;Row 4    */
L1AttrRow04:            DW $5880                    ;Row 5    */
L1AttrRow05:            DW $58A0                    ;Row 6    */
L1AttrRow06:            DW $58C0                    ;Row 7    */
L1AttrRow07:            DW $58E0                    ;Row 8    */
L1AttrRow08:            DW $5900                    ;Row 9    */
L1AttrRow09:            DW $5920                    ;Row 10   */
L1AttrRow10:            DW $5940                    ;Row 11   */
L1AttrRow11:            DW $5960                    ;Row 12   */
L1AttrRow12:            DW $5980                    ;Row 13   */
L1AttrRow13:            DW $59A0                    ;Row 14   */
L1AttrRow14:            DW $59C0                    ;Row 15   */
L1AttrRow15:            DW $59E0                    ;Row 16   */
L1AttrRow16:            DW $5A00                    ;Row 17   */
L1AttrRow17:            DW $5A20                    ;Row 18   */
L1AttrRow18:            DW $5A40                    ;Row 19   */
L1AttrRow19:            DW $5A60                    ;Row 20   */
L1AttrRow20:            DW $5A80                    ;Row 21   */
L1AttrRow21:            DW $5AA0                    ;Row 22   */
L1AttrRow22:            DW $5AC0                    ;Row 23   */
L1AttrRow23:            DW $5AE0                    ;Row 23   */

; "l2_hilight_row, d = row, e = colour"
l1_hilight_row:         ld      hl, L1AttrRow00
                        ld      c,e
                        ld      a,d
                        sla     a
                        add     hl,a
                        ld      a,(hl)
                        ld      e,a
                        inc     hl
                        ld      a,(hl)
                        ld      d,a
                        ex      hl,de
                        ld		a,c
                        ld		de, 32
                        call	memfill_dma
                        ret	
