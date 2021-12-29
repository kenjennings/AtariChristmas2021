# AtariChristmas2021
**VC3 2021 Vintage Christmas Programming Challenge #VCCC2021**

https://logiker.com/Vintage-Computing-Christmas-Challenge-2021?fbclid=IwAR0qiysYCVLMEjuKfM3jJBGuRMUOgWTrwhW59gOEJmwtkl_B4mfJ7-PDw5Y

Unfortunately, I missed the contest this year.  But, decided to roll up something unconventional for the entertainment value.  

The methods presented here are fairly atypical as solutions go.  Yes, I realize the intent of the challenge is to compute the components to display the Tree -- how many blank spaces, and how many asterisks to use for the lines.  This is supposed to be about patterns and relationships between each line and for each triangular section on the tree.  

However, the Atari can do some unusual things with the display.  Where a brute force method to output of all the data for the tree is the least optimized method of display for most computers, on the Atari there are ways to optimize the direct output approach.

These demos are built with MADS assembler from eclipse+WUDSN by Ken Jennings

---

**VERSION SUMMARY**

| **VERSION** | **FILE SIZE** | **6502 CODE SIZE** |
| ------- | ------- | ------- |
| WorstCase | 1080 bytes | 3 bytes |
| Original  | 452 bytes | 3 bytes |
| 32 Width  | 272 bytes | 3 bytes |
| Pretty    | 340 bytes | 3 bytes |
| Computed  | 181 bytes | 31 bytes |

---

**2021 Atari Christmas Original Version...**

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

**2021 Atari Christmas Worst Case Version...**

[![DEMO](https://raw.githubusercontent.com/kenjennings/AtariChristmas2021/master/AtariChristmas2021.png)](https://github.com/kenjennings/AtariChristmas2021/blob/main/README.md "Demo") 

WORST CASE ASSEMBLY RESULTS:
FILE SIZE:         1080 Bytes
- EXE FILE OVERHEAD:   34 Bytes
- NON-DISPLAY DATA:    10 Bytes
- DISPLAY DATA:      1033 Bytes
- (1000 Bytes Screen memory)
- (33 Bytes Display list)
- EXECUTABLE CODE:     3 Bytes 

The Original version contains some optimizations that are automatic, typical, and  trivial based on the way the Atari's ANTIC chip operates.  For example, re-using the same screen memory data for multiple lines on the screen.  This Worst Case Version produces a display identical to the Original version, but avoids these kinds of  Atari-specific environment optimizations.  This result is what would be expected on most non-Atari systems as the only way to directly generate the display without computation.

The program declares contiguous data for the entire display.  Since screen data is contiguous the Display List is more simple, because the Load Memory Scan only needs to be set up once in the display list and then automatically reads the subsequent data as screen memory for the following lines.

Because the screen data is nearly 1K, the display list following the screen would run over the 1K boundary limit for Display Lists.  Unlike the other versions of the demo using much less data for screen display, this version must move the  Display List to a location that will prevent it from crossing over the 1K boundary.  This introduces an extra segment and more XEX file overhead not present in the other versions.

Again, the only code running is a do-nothing loop to prevent returning to DOS immediately.

---

**2021 Atari Christmas Optimized For 32 Character Width...**

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
 2) The tree at its widest point is less than the 32 characters for ANTIC's Narrow Width display, so use this feature to reduce the data needed for each line.
 3) Since each line begins and ends with blank spaces then the blanks can overlap from line to line to produce the correct number of leading/trailing blanks from "shared" data.

This nearly cuts the original Assembly results in half.

---

**2021 Atari Christmas Optimized Width Plus Prettification...**

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

**2021 Atari Christmas Prettification With Computation...**

[![DEMO](https://raw.githubusercontent.com/kenjennings/AtariChristmas2021/master/AtariChristmas2021opt32pretty.png)](https://github.com/kenjennings/AtariChristmas2021/blob/main/README.md "Demo") 

PRETTIFICATION COMPUTATION ASSEMBLY RESULTS:
FILE SIZE:         181 Bytes
- EXE FILE OVERHEAD:  38 Bytes
- NON-DISPLAY DATA:   32 Bytes
- DISPLAY DATA:       80 Bytes
- (48 Bytes Display list)
- (32 Bytes Character Set)
- EXECUTABLE CODE:    31 Bytes 

Do not populate screen memory at load time.  Instead, compute the values and write into screen memory.

No, this is not a clever analysis of the relationship of the number of asterisks in each line and in each section.   This version unpacks 22 bytes of run-length-encoded data to populate the 209 bytes of allocated screen memory which represent 448 apparent bytes of displayed data on screen.  The unpacking code is 28 bytes long.  (Plus the ubiquitous 3 bytes of do-nothing loop to prevent returning to DOS.)

--- 
