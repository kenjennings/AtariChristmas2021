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
; Ugly coding version....
; No graphics mode creation or setup.   Just use the default display 
; provided by the E: device.
; The code simply reads from a table listing the number of asterisks needed 
; for each line.  It outputs the correct number of spaces and asterisks
; to the screen editor device to center the asterisks and fill the line.
; Logic is based on the default 38 character/line width for the screen editor.
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
; | Ugly      | 96        | 65             |
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
;
; UGLY CODING ASSEMBLY RESULTS:
; FILE SIZE:          96 Bytes
; EXE FILE OVERHEAD:  10 Bytes
; DATA:               21 Bytes
; EXECUTABLE CODE:    65 Bytes 
;
;*******************************************************************************

; U G L Y    C O D I N G

; ==========================================================================
; Atari System Includes (MADS assembler versions)
; https://github.com/kenjennings/Atari-Mads-Includes
	icl "ANTIC.asm"  ; Display List registers
	icl "OS.asm"     ; Interrupt definitions.
	icl "DOS.asm"    ; LOMEM, load file start, and run addresses.

	icl "macros.asm" ; Macros (No code/data declared)


; ==========================================================================
; The Program

	ORG $80                 ; Run from Page 0 for shorter instructions.

ASTERISKS    .byte 0              ; Save number of asterisks from the table.
SPACES       .byte 0              ; Save number of leading, then trailing spaces needed.

OUTPUT_CHAR  .byte $20            ; Save while writing, because PutCH destroys A.
COUNT_CHARS  .byte 0              ; Cannot use X.  Count characters here.


THE_PROGRAM

Loop_ProcessPackedData
INK_ADDR = *+1                    ; Low byte pointing into data table.	
	lda PACKED_DATA               ; Get a byte from the table
	bmi Do_While_More_Electricity ; The end at byte $FF

	sta ASTERISKS                 ; Save count of asterisks.
	lda #39                       ; 39, not 38, because need tweak for the total width (Default screen width of E: is 38 chars)
	sec
	sbc ASTERISKS                 ; 33 - number of asterisks == the number of spaces.
	lsr                           ; divide number of spaces by 2
	sta SPACES                    ; Keep the count of spaces needed

	jsr EarlyEntry_ForSpaces      ; Output the leading spaces.

	lda ASTERISKS                 ; Use the  count of asterisks.
	sta COUNT_CHARS
	lda #$2a                      ; ATASCII asterisk.
	jsr PrintChars           ; Output the asterisks

	dec SPACES                    ; Decrement trailing spaces -- this is needed to center the odd number of asterisks.
	jsr EarlyEntry_ForSpaces      ; Output the trailing spaces.
	
	inc INK_ADDR                  ; Next pointer to the data table.
	bne Loop_ProcessPackedData    ; Always True


;---------------------------------------------------------------------
; Optimization to eliminate some redundant code, because 
; generating blank spaces occurs twice on each line.

EarlyEntry_ForSpaces
	lda SPACES                    ; Use the adjusted count of spaces.
	sta COUNT_CHARS
	lda #$20                      ; ATASCII space.


;---------------------------------------------------------------------
; Write characters to the screen.
; A == character to print.

PrintChars
	sta OUTPUT_CHAR
	
Loop_PrintChars
	jsr PutCH                     ; Write to Screen.
	dec COUNT_CHARS               ; Subtract character count
	bne Loop_PrintChars     ; If it did not roll over from 0 to $FF then loop again.

	rts


;---------------------------------------------------------------------
; The General Purpose CIO on the Atari doesn't really have a 
; published entry point to output a byte to the screen.   This is 
; supposed to be done by a CIO command.   However, the OS does supply 
; a shortcut to BASIC to output a single character to the device 
; using that control block.  The function copies that address  from 
; the IOCB device 0  (The E: eeditor device) to the stack, and then 
; calls it by rts. 
; 
; INPUT:
; A = character to write
; NOTE:
; OS will modify all registers.
;---------------------------------------------------------------------

PutCH
	lda ICPTH ; High byte for Put Char in E:/IOCB Channel 0.
	pha       ; Push to stack
	lda ICPTL ; Low byte for Put Char in E:/IOCB Channel 0.
	pha       ; Push to stack

	lda OUTPUT_CHAR

	; This rts actually triggers calling the address of PutCH
	; that was pushed onto the stack above. 
	rts  


;---------------------------------------------------------------------
; Park here when done.  

Do_While_More_Electricity

	jmp Do_While_More_Electricity ; Forever


; The Data for the screen.
; This is just the count of asterisks that occur on each line.
; The code calculates leading/trailing spaces needed for each line.
; If byte to unpack is negative, then the loop is over.

PACKED_DATA         ; 15 bytes
	.by $01 ; "                *               "
	.by $03 ; "               ***              "
	.by $05 ; "              *****             "
	.by $07 ; "             *******            "
	.by $03 ; "               ***              "
	.by $07 ; "             *******            "
	.by $0b ; "           ***********          "
	.by $0f ; "         ***************        "
	.by $05 ; "              *****             "
	.by $0b ; "           ***********          "
	.by $11 ; "        *****************       " 
	.by $17 ; "     ***********************    "
	.by $03 ; "               ***              "
	.by $03 ; "               ***              "
	.by $FF ; The End


; ==========================================================================
; Inform DOS of the program's Auto-Run address...

	mDiskDPoke DOS_RUN_ADDR,THE_PROGRAM  
 
	END
