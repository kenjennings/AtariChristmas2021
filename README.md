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
- (340 Bytes Screen memory)
- (69 Bytes Display List)
- EXECUTABLE CODE:     3 Bytes 

Abuse Atari's structured file format to load all data for display into memory, update the necessary shadow registers. In the end, no actual code executes to create the display. The only code running is there to prevent returning to DOS immediately.

While we're here... Setup the display to immitate the number of lines on the C64.

---

More versions of mad abuse soon.

--- 
