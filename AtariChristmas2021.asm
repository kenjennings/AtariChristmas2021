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
; Original Version...
; This abuses Atari's structured file format to load all data for 
; display into memory, and update the necessary shadow registers.
; In the end, no actual code executes to create the display.
; The only code running is there to prevent returning to DOS 
; immediately.
;
; While we're here... Create the Display List the same size as a C64 display.
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
; Prettification With Computation Version....
; This does still abuse Atari's structured file format to load SOME 
; data for display into memory, (Display List and Character set) and update 
; the necessary shadow registers.
;
; This will attempt to compute and draw the tree on the screen.
; 
; However, this is not doing any clever math computation, but is 
; running a simple kind of run lenth decoder to put data into the 
; screen memory.
;
; This allocates space for the screen memory, but does not populate
; it with data at build time.  Screen memory population  will occur 
; via code at run time (like a "normal" program).
;
;*******************************************************************************
;
; V E R S I O N    S U M M A R Y 
; 
; +-----------+-----------+----------------+
; | VERSION   | FILE SIZE | 6502 CODE SIZE |   
; +-----------+-----------+----------------+
; | WorstCase | 1080      | 3              |
; +-----------+-----------+----------------+
; | Original  | 452       | 3              |
; +-----------+-----------+----------------+
; | 32 Width  | 272       | 3              |
; +-----------+-----------+----------------+
; | Pretty    | 340       | 3              |
; +-----------+-----------+----------------+
; | Computed  | 181       | 31             |
; +-----------+-----------+----------------+
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
;
; PRETTIFICATION COMPUTATION ASSEMBLY RESULTS:
; FILE SIZE:         181 Bytes
; EXE FILE OVERHEAD:  38 Bytes
; NON-DISPLAY DATA:   32 Bytes
; DISPLAY DATA:       80 Bytes
;                               48 Bytes Display list
;                               32 Bytes Character Set
; EXECUTABLE CODE:    31 Bytes 
;
;*******************************************************************************



; O R I G I N A L    V E R S I O N 

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
