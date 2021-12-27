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
; This abuses Atari's structured file format to load all data for 
; display into memory, and update the necessary shadow registers.
; In the end, no actual code executes to create the display.
; The only code running is there to prevent returning to DOS 
; immediately.
;
;*******************************************************************************
;
; Easy Optimization Version....
; Since the point is to display the Christmas tree let's just 
; service only enough data to make that possible.
; 1) Make the Display List only produce what is necessary to 
; display the lines of the tree.   There is no need to present 
; any blank/empty text mode lines. 
; 2) The tree at it's widest point is less than the 32 characters
; for the narrow width screen, so use narrow width.
; 3) Since each line begins and end with blank spaces then 
; the blanks can overlap from line to line to produce the correct
; number of leading/trailing blanks from "shared" data.
;
; This nearly cuts the original Assembly results in half.
; 
;*******************************************************************************
;
; Prettification Version....
; Don't the default colors (modeled from the C64) look ugly?  
; Let's make this look more like a Christams tree. 
; 1) Use ANTIC Mode 4 for color text.
; 2) Use a (partial) redefined character set to provide the colored asterix   
; for building the tree.
; 
; Yes, this is going to make the demo a little bigger. 
; 
;*******************************************************************************
;
; ORIGINAL ASSEMBLY RESULTS:
; FILE SIZE:         452 Bytes
; EXE FILE OVERHEAD:  30 Bytes
; NON-DISPLAY DATA:   10 Bytes
; DISPLAY DATA:      409 Bytes
;                              340 Bytes Screen memory
;                               69 Bytes Display list
; EXECUTABLE CODE:     3 Bytes 
;
; EASY OPTIMIZE 32 ASSEMBLY RESULTS:
; FILE SIZE:         272 Bytes
; EXE FILE OVERHEAD:  30 Bytes
; NON-DISPLAY DATA:   10 Bytes
; DISPLAY DATA:      229 Bytes
;                              181 Bytes Screen memory
;                               48 Bytes Display list
; EXECUTABLE CODE:     3 Bytes 
;
; PRETTIFICATION ASSEMBLY RESULTS:
; FILE SIZE:         340 Bytes
; EXE FILE OVERHEAD:  38 Bytes
; NON-DISPLAY DATA:   10 Bytes
; DISPLAY DATA:      289 Bytes
;                              209 Bytes Screen memory
;                               48 Bytes Display list
;                               32 Bytes Character Set
; EXECUTABLE CODE:     3 Bytes 
;*******************************************************************************

; O P T I M I Z E D    F O R    3 2   W I D T H    A N D    P R E T T I F I E D

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

TREE_01	  .sb "                "
		  .by $02 ; Tough to do " in the declare" ; 17      (+15)  ; Borrow trailing spaces from the line of data that follows.
TREE_03	  .sb "               !!!"                ; 18      (+14)
TREE_05	  .sb "              !!!!!"               ; 19      (+13)
TREE_07	  .sb "             !!!!!!! "             ; 20 (+1) (+10)
TREE_11	  .sb "           !!!!!!!!!!! "           ; 22 (+1) (+9)         
TREE_15	  .sb "         !!!!!!!!!!!!!!!"          ; 24      (+8)
TREE_17	  .sb "        !!!!!!!!!!!!!!!!!  "       ; 25 (+2) (+5)   
TREE_23	  .sb "     !!!!!!!!!!!!!!!!!!!!!!!"      ; 28          
ROOT_03   .sb "               ###              "  ; 32  This is not the same color as TREE_03
;                                               == 209 total bytes of screen memory

; Because screen data is "shared" between adjacent lines, every 
; instruction in the display list needs LMS to start reading at the 
; correct spot.   The difference is easily made up by the number of 
; bytes saved for screen memeory, not to mention that the lines of 
; blank spaces are also removed saving even more.

DISPLAY_LIST                   ; Total 48 bytes
	mDL_BLANK DL_BLANK_8
	mDL_BLANK DL_BLANK_8
	mDL_BLANK DL_BLANK_8       ; That was 24 blank lines to take care of overscan at the top of the screen.
	mDL_LMS DL_TEXT_4,TREE_01  ; Line 1
	mDL_LMS DL_TEXT_4,TREE_03  ; Line 2 
	mDL_LMS DL_TEXT_4,TREE_05  ; Line 3
	mDL_LMS DL_TEXT_4,TREE_07  ; Line 4
	mDL_LMS DL_TEXT_4,TREE_03  ; Line 5
	mDL_LMS DL_TEXT_4,TREE_07  ; Line 6
	mDL_LMS DL_TEXT_4,TREE_11  ; Line 7
	mDL_LMS DL_TEXT_4,TREE_15  ; Line 8
	mDL_LMS DL_TEXT_4,TREE_05  ; Line 9
	mDL_LMS DL_TEXT_4,TREE_11  ; Line 10
	mDL_LMS DL_TEXT_4,TREE_17  ; Line 11
	mDL_LMS DL_TEXT_4,TREE_23  ; Line 12
	mDL_LMS DL_TEXT_4,ROOT_03  ; Line 13
	mDL_LMS DL_TEXT_4,ROOT_03  ; Line 14
	mDL_JVB DISPLAY_LIST

; ==========================================================================

	.align $0400 ; Align to the next 1K address for the character set.

CHARACTER_SET
	; Model Asterisk for Mode 4
	; 0 - XX .. .. XX
	; 1 - XX .. .. XX
	; 2 - .. XX XX ..
	; 3 - XX XX XX XX
	; 4 - .. XX XX ..
	; 5 - XX .. .. XX
	; 6 - XX .. .. XX
	; 7 - .. .. .. ..

	; Internal 0 == Space (insure this is 0/blank) 
	.byte 0,0,0,0,0,0,0,0
	; Internal 1 == ! - Green Tree
	.byte 65,65,20,85,20,65,65,0
	; Internal 2 == " - Yellow Star
	.byte 130,130,40,170,40,130,130,0
	; Internal 3 == # - Brown Trunk.
	.byte 195,195,60,255,60,195,195,0

; ==========================================================================
; Setup OS shadow registers to present the display.

	ORG CHBAS
	.byte >CHARACTER_SET ; POKE Character Set Base, PAGE NUMBER of CHARACTER_SET

	ORG COLOR0
	.byte $C8,$1C,$24 ; POKE colors 708, 709, 710 (green, yellow, brown)

	ORG SDLSTL 
	.word DISPLAY_LIST    ; DPOKE SDLSTL, DISPLAY_LIST

	ORG SDMCTL
	.byte ENABLE_DL_DMA|PLAYFIELD_WIDTH_NARROW  ; POKE SDMCTL, Display On, Narrow Width

	
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
