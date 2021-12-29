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
;*******************************************************************************
;
; Worst Case Version.....
; The Original Version included a few natural optimizations based on the way 
; the Atari works.   For comparison purposes this is more of a worst-case
; implementation i.e.  How it may need to work on other systems.  
;
; Re-using the same data for display as screen memory is a trivial and obvious 
; "optimization" on the Atari.  On other systems this is usually not possible.
; For this version of the demo all screen data is declared separately and 
; contiguously.  However, supplying a full, contiguous display screen in memory
; does provide for optimizing the Display List where only one Load Memory Scan
; in the display list instead of using this on each line.  The resulting screen
; looks identical to the Original Version.
;
; Because screen memeoru ids almost 1K, the Display List has to move to the 
; next aligned page, so that it doesn't cross over the 1K boundary limit.  This
; adds another segment to the load file, so the XEX file system overhead is 
; different for this version than for the other versions.
;
; This abuses Atari's structured file format to load all data for display into 
; memory, and update the necessary shadow registers.  In the end, no actual code
; executes to create the display.  The only code running is there to prevent 
; immediately returning to DOS.
;
; While we're here... Create the Display List the same size as a C64 display.
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
;
; WORST CASE ASSEMBLY RESULTS:
; FILE SIZE:         1080 Bytes
; EXE FILE OVERHEAD:   34 Bytes
; NON-DISPLAY DATA:    10 Bytes
; DISPLAY DATA:      1033 Bytes
;                              1000 Bytes Screen memory
;                                33 Bytes Display list
; EXECUTABLE CODE:      3 Bytes 
;
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
;
;*******************************************************************************

; W O R S T    C A S E    V E R S I O N 

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

; 25 lines * 40 bytes each for the display.  Since this is being addressed 
; simply as one contiguous block, there is no need to label every line.

SCREEN_MEMORY
	.sb "                                        " ; Line 1
	.sb "                                        " ; Line 2
	.sb "                                        " ; Line 3
	.sb "                                        " ; Line 4
	.sb "                                        " ; Line 5
	.sb "                                        " ; Line 6
	.sb "                                        " ; Line 7
	.sb "                    *                   " ; Line 8
	.sb "                   ***                  " ; Line 9
	.sb "                  *****                 " ; Line 10
	.sb "                 *******                " ; Line 11
	.sb "                   ***                  " ; Line 12
	.sb "                 *******                " ; Line 13
	.sb "               ***********              " ; Line 14
	.sb "             ***************            " ; Line 15
	.sb "                  *****                 " ; Line 16
	.sb "               ***********              " ; Line 17
	.sb "            *****************           " ; Line 18
	.sb "         ***********************        " ; Line 19
	.sb "                   ***                  " ; Line 20
	.sb "                   ***                  " ; Line 21
	.sb "                                        " ; Line 22
	.sb "                                        " ; Line 23
	.sb "                                        " ; Line 24
	.sb "                                        " ; Line 25

; Since Display memeory is almost 1K, this means the code is very near a
; 1K boundary which the display list cannot cross over.
; Therefore, realign to the next page boundary, so the Display List
; has enough memeory available.

	.align $0400
	
DISPLAY_LIST
	mDL_BLANK DL_BLANK_8
	mDL_BLANK DL_BLANK_8
	mDL_BLANK DL_BLANK_4             ; That was 20 blank lines to take care of overscan at the top of the screen.
	mDL_LMS DL_TEXT_2,SCREEN_MEMORY  ; Line 1 - LMS only here as screen memory is contiguous
	mDL     DL_TEXT_2                ; Line 2
	mDL     DL_TEXT_2                ; Line 3
	mDL     DL_TEXT_2                ; Line 4
	mDL     DL_TEXT_2                ; Line 5
	mDL     DL_TEXT_2                ; Line 6
	mDL     DL_TEXT_2                ; Line 7
	mDL     DL_TEXT_2                ; Line 8
	mDL     DL_TEXT_2                ; Line 9
	mDL     DL_TEXT_2                ; Line 10
	mDL     DL_TEXT_2                ; Line 11
	mDL     DL_TEXT_2                ; Line 12
	mDL     DL_TEXT_2                ; Line 13
	mDL     DL_TEXT_2                ; Line 14
	mDL     DL_TEXT_2                ; Line 15
	mDL     DL_TEXT_2                ; Line 16
	mDL     DL_TEXT_2                ; Line 17
	mDL     DL_TEXT_2                ; Line 18
	mDL     DL_TEXT_2                ; Line 19
	mDL     DL_TEXT_2                ; Line 20
	mDL     DL_TEXT_2                ; Line 21
	mDL     DL_TEXT_2                ; Line 22
	mDL     DL_TEXT_2                ; Line 23
	mDL     DL_TEXT_2                ; Line 24
	mDL     DL_TEXT_2                ; Line 25  Huh.  The Atari can display 200 scan lines.  How about that?
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