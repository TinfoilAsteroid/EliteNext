;
; EraseOldLines:
;	Loop from 0 to UBnkEdgeHeapCounter (note this should be 4 * actual nbr of lines)
;		draw line (black) UBnkLinesArray[0,1]+Loop to [2,3]+loop
;	 	loop + 4
; Return

EraseOldLines:
EE51:										; if bit3 set draw lines in XX19 heap
	ReturnOnMemBitClear UBnkexplDsp,3       ; bit 3 denotes that there is nothing to erase as its already done
	set		3,a
	ld		(UBnkexplDsp),a  				; else toggle bit3 to allow lines (set will do as its 0 by now)
	jp		clearLines						; LL115	clear LINEstr. Draw lines in XX19 heap.  - note its an & not direct
; We use the ret from the clearLines so not needed here
