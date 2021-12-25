# AtariChristmas2021
VC3 2021 Programming Challenge

---

2021 Atari Christmas

Vintage Christmas Challenge 2021 #VCCC2021

Built with MADS assembler from eclipse+WUDSN by Ken Jennings

Unfortunately, I was unaware of the contest until results were announced.   I saw a limited number of Atari submissions in the results and decided to work on an unconventional solution.   

2021-12-25

Abuse Atari's structured file format to load all data for display into memeory, update the necessary shadow registers. In the end, no actual code executes to create the display. The only code running is there ot prevent returning to DOS immediately.

While we're here... Setup the display to immitate the number of lines on the C64.
 
 ASSEMBLY RESULTS:
FILE SIZE:         452 Bytes
- EXE FILE OVERHEAD:  30 Bytes
- NON-DISPLAY DATA:   10 Bytes
- DISPLAY DATA:      409 Bytes
- (340 Bytes Screen memory)
- (69 Bytes Display List)
- EXECUTABLE CODE:     3 Bytes 
