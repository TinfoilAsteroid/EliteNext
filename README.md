# EliteNext
ZX Spectrum Next port of Elite. Very much work in progress
This is my rough n ready source code base for Elite Next. I haven’t touched z80 for decades so this is as much me learning z80 again as developing something. 
No code is optimised yet. The priority is to flesh out the code and get the right results first.
The Excel folder contains a bunch of excel work books I use for testing calculations. Not needed for the game but they help when debugging the mess that it is. 
When I was learning I used 6502 simulator to work out maths as I kept getting the carry flag the wrong way round as the 6502 carry is in effect the opposite to the z80 one.
If you want to contribute, please do. I you want to use the drawing routines for your own games please do as well. 
I just ask, if you use the code and tune it, please contribute back here. 
If you want to join in and help with the project please just ask and help out. I don’t expect coding geniuses just have fun experimenting/suggesting ideas etc.
I’m only getting about 5 to 10 hrs a week on the project at the moment so any help is great fully received. 
The only ask I have is, if you want to something, get involved, don’t just grab the code then present it as your own version of an elite port.
Elite Next is an attempt to port the classic Elite to the ZX Spectrum Next. I am trying to make it as open an expandable as possible. 

So far to help expansion
	The universes are all pre-computed so can be moved to file store later
	The ships could be moved to file store and read in.
	I have started some configuration parameters to allow swapping ship at some point

Sources for inspiration:
	Elite NewKind. Awsome C version, tried using this as the basis but code in C is just too slow for the next at the moment (floats are very expensive to compute)
	https://www.bbcelite.com/ and the deep dive contents. Read some of these pages dozens of times trying to understand and learn the maths for 3D.

To compile the code, download sjasmplus and install it and add it to your path. To run the code install cspect. You can see my assemble command in “elitebuild.bat”. 
It's messy as I need to sort out the includes (I got in to a tangle porting from snasm to sjasmplus when snasm could no longer assemble my code).
To run the code I have a sample eliterun.bat, all it does in run cspect with break enabled, -debug is enabled so that it always starts up in debugger (just press F1 to run). 

The keys working so far are
1 – Front view
5 – Galactic chart 
6 – Local Chart 
7 – Local Market
8 Commander screen
c Equipment buy screen
8 Commander status
9 inventory
0 Data on selected system
Cursors QAOP (works on charts and buy screens), left is sell, right is buy
F to get Find input on galactic chart
D to centralise cursor on nearest star
L Launch ship, in which case Q A are dive/climb, OP are roll, W S are throttle
Pause and resume are there but I have forgot they keys as the moment, its all in keyboard.asm :)

I'm doing updates, generally about weekly, of udpates so far on Youtube - https://www.youtube.com/channel/UCFPWRIEGUjcGhZV2rRWU5DA
