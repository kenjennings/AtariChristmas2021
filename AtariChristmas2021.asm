;*******************************************************************************
; 2021 Atari Christmas
; Vintage Christmas Challenge 2021 #VCCC2021
; Built with MADS assembler from eclipse+WUDSN
; by Ken Jennings
;
; Unfortunately, I was unaware of the contest until results 
; were announced.   I saw a limited number of Atari submissions
; in the results and decided to work on an unconventional 
; solution.   2021-12-25
;
; Abuse Atari's structured file format to load all data for 
; display into memeory, update the necessary shadow registers.
; In the end, no actual code executes to create the display.
; The only code running is there ot prevent returning to DOS 
; immediately.
;
; While we're here... Setup the display to immitate the number
; of lines on the C64.
; 
; ASSEMBLY RESULTS:
; FILE SIZE:         452 Bytes
; EXE FILE OVERHEAD:  30 Bytes
; NON-DISPLAY DATA:   10 Bytes
; DISPLAY DATA:      409 Bytes
;                              340 Bytes Screen memory
;                               69 Bytes Display list
; EXECUTABLE CODE:     3 Bytes 
;*******************************************************************************

; ==========================================================================
; Atari System Includes (MADS assembler versions)
; https://github.com/kenjennings/Atari-Mads-Includes
	icl "ANTIC.asm"  ; Display List registers
	icl "GTIA.asm"   ; Color Registers.
	icl "OS.asm"     ; Interrupt definitions.
	icl "DOS.asm"    ; LOMEM, load file start, and run addresses.

	icl "macros.asm" ; Macros (No code/data declared)


; ==========================================================================
; Stop the display.   Hopefully the other data loading goes on long enough 
; that this does not risk the rare condition of partially updating the 
; display list pointer while ANTIC is still running a display.  While this
; is very improbable my OCD programming say we must still take care 
; of DMACTL.

	ORG SDMCTL
	.byte 0               ; POKE DMACTL,0 ; Turn off display.


; ==========================================================================
; Display Data and Display List.

	ORG $4000               ; Arbitrary

SPACES_40 .sb "                    "                     ; Borrowing the next 20 spaces from the line that follows...          
TREE_01	  .sb "                    *                   "
TREE_03	  .sb "                   ***                  "            
TREE_05	  .sb "                  *****                 "            
TREE_07	  .sb "                 *******                "            
TREE_11	  .sb "               ***********              "                    
TREE_15	  .sb "             ***************            "            
TREE_17	  .sb "            *****************           "            
TREE_23	  .sb "         ***********************        "            

DISPLAY_LIST
	mDL_BLANK DL_BLANK_8
	mDL_BLANK DL_BLANK_8
	mDL_BLANK DL_BLANK_4         ; That was 20 blank lines to take care of overscan at the top of the screen.
	mDL_LMS DL_TEXT_2,SPACES_40  ; Line 1
	mDL_LMS DL_TEXT_2,SPACES_40  ; Line 2
	mDL_LMS DL_TEXT_2,SPACES_40  ; Line 3
	mDL_LMS DL_TEXT_2,SPACES_40  ; Line 4
	mDL_LMS DL_TEXT_2,SPACES_40  ; Line 5
	mDL_LMS DL_TEXT_2,SPACES_40  ; Line 6
	mDL_LMS DL_TEXT_2,SPACES_40  ; Line 7
	mDL_LMS DL_TEXT_2,TREE_01    ; Line 8
	mDL     DL_TEXT_2 ; TREE_03  ; Line 9 ; LMS is not always needed when the data of continuguous line is contiguous in memeory
	mDL     DL_TEXT_2 ; TREE_05  ; Line 10
	mDL     DL_TEXT_2 ; TREE_07  ; Line 11
	mDL_LMS DL_TEXT_2,TREE_03    ; Line 12
	mDL_LMS DL_TEXT_2,TREE_07    ; Line 13
	mDL     DL_TEXT_2 ; TREE_11  ; Line 14
	mDL     DL_TEXT_2 ; TREE_15  ; Line 15
	mDL_LMS DL_TEXT_2,TREE_05    ; Line 16
	mDL_LMS DL_TEXT_2,TREE_11    ; Line 17
	mDL_LMS DL_TEXT_2,TREE_17    ; Line 18
	mDL     DL_TEXT_2 ; TREE_23  ; Line 19
	mDL_LMS DL_TEXT_2,TREE_03    ; Line 20
	mDL_LMS DL_TEXT_2,TREE_03    ; Line 21
	mDL_LMS DL_TEXT_2,SPACES_40  ; Line 22
	mDL_LMS DL_TEXT_2,SPACES_40  ; Line 23
	mDL_LMS DL_TEXT_2,SPACES_40  ; Line 24
	mDL_LMS DL_TEXT_2,SPACES_40  ; Line 25 ; Huh.  The Atari can display 200 scan lines.  How about that?
	mDL_JVB DISPLAY_LIST

; ==========================================================================
; Setup OS shadow registers to present the display.

	ORG COLOR1
	.byte $0c,$76,$00,$8C ; POKE colors 709, 710, (711), 712

	ORG SDLSTL 
	.word DISPLAY_LIST    ; DPOKE SDLSTL, DISPLAY_LIST

	ORG SDMCTL
	.byte ENABLE_DL_DMA|PLAYFIELD_WIDTH_NORMAL  ; POKE SDMCTL, Display On, Normal Width

	
; ==========================================================================
; The "Program"

	ORG LOMEM_DOS           ; First usable memory after DOS (2.0s)
;	ORG LOMEM_DOS_DUP       ; Use this if LOMEM_DOS won't work.  or just use $5000 or $6000

Do_While_More_Electricity

	jmp Do_While_More_Electricity ; Forever


; ==========================================================================
; Inform DOS of the program's Auto-Run address...

	mDiskDPoke DOS_RUN_ADDR,Do_While_More_Electricity  
 
	END
