# AtariChristmas2021
**VC3 2021 Vintage Christmas Programming Challenge #VCCC2021**

Built with MADS assembler from eclipse+WUDSN by Ken Jennings

2021-12-25

---

2021 Atari Christmas Original Version... 

[![DEMO](https://raw.githubusercontent.com/kenjennings/AtariChristmas2021/master/AtariChristmas2021.png)](https://github.com/kenjennings/AtariChristmas2021/blob/main/README.md "Demo") 

ASSEMBLY RESULTS:
FILE SIZE:         452 Bytes
- EXE FILE OVERHEAD:  30 Bytes
- NON-DISPLAY DATA:   10 Bytes
- DISPLAY DATA:      409 Bytes
- (340 Bytes Screen Memory)
- (69 Bytes Display List)
- EXECUTABLE CODE:     3 Bytes 

Abuse Atari's structured file format to load all data for display directly into memory and update the necessary shadow registers.  In the end, no actual code executes to create the display. The only code running is a do-nothing loop to prevent returning to DOS immediately.

While we're here... Setup the display to immitate the number of lines on the C64.

---

2021 Atari Christmas Optimized For 32 Character Width... 

[![DEMO](https://raw.githubusercontent.com/kenjennings/AtariChristmas2021/master/AtariChristmas2021opt32.png)](https://github.com/kenjennings/AtariChristmas2021/blob/main/README.md "Demo") 

EASY OPTIMIZE 32 ASSEMBLY RESULTS:
FILE SIZE:         272 Bytes
- EXE FILE OVERHEAD:  30 Bytes
- NON-DISPLAY DATA:   10 Bytes
- DISPLAY DATA:      229 Bytes
- (181 Bytes Screen Memory)
- (48 Bytes Display List)
- EXECUTABLE CODE:     3 Bytes 

Since the point is to display the Christmas tree let's just service only enough data to make that possible.
 1) Make the Display List only produce what is necessary to display the lines of the tree.   There is no need to present any blank/empty text mode lines. 
 2) The tree at its widest point is less than the 32 characters for the narrow width screen, so use narrow width.
 3) Since each line begins and end with blank spaces then the blanks can overlap from line to line to produce the correct number of leading/trailing blanks from "shared" data.

This nearly cuts the original Assembly results in half.

---

2021 Atari Christmas Optimized Width Plus Prettification... 

[![DEMO](https://raw.githubusercontent.com/kenjennings/AtariChristmas2021/master/AtariChristmas2021opt32pretty.png)](https://github.com/kenjennings/AtariChristmas2021/blob/main/README.md "Demo") 

PRETTIFICATION ASSEMBLY RESULTS:
FILE SIZE:         340 Bytes
- EXE FILE OVERHEAD:  38 Bytes
- NON-DISPLAY DATA:   10 Bytes
- DISPLAY DATA:      289 Bytes
- (209 Bytes Screen Memory)
- (48 Bytes Display List)
- (32 Bytes Character Set)
- EXECUTABLE CODE:     3 Bytes 

Those default colors (modeled from the C64) are ugly, right?   So, let's make this look more like a Christmas Tree.  
1) Use ANTIC Mode 4 for color text.
2) Use colors more like a Christmas Tree
3) Use a (partial) redefined character set to provide the new colored asterix for building the tree.

Yes, this does make the demo a little bigger, but it is still smaller than the original demo by over 100 bytes.

---

Will there be more versions of mad abuse?

--- 
