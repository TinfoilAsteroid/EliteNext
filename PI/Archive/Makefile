#sudo root to compile in my Mint vm
#/mnt/h/OneDrive/EliteNext/piCoprocessor/Makefile
#Makefile
CC = gcc
CFLAGS = -Wall -Werror -Wmissing-prototypes
OBJS = eliteCoPro.o Line.o maths3d.o Vector.o CommandProcessor.o consoleIO.o ShipData.o ShipModels.o Engine.o 
#PortIO.o
DEPTS = Line.h maths3d.h Vector.h CommandProcessor.h consoleIO.h ShipData.h ShipModels.h Engine.h 
#PortIO.h
PROG = eliteCoPro
FILES = eliteCoPro.c Line.c maths3d.c Vector.c CommandProcessor.c consoleIO.c ShipData.c ShipModels.c Engine.c 
#PortIO.c
#
all:$(PROG)

files:$(FILES) $(DEPTS)
	$(CC) $(CFLAGS) -o $(PROG) $(FILES) -lm

$(PROG): $(OBJS) $(DEPTS)
	$(CC) $(CFLAGS) -o $@ $(OBJS) -lm -ldl -pthread

Line.o: Line.h
Vector.o:Vector.h
CommandProcesor.o:CommandProcessor.h

clean :
	rm -f *.o eliteCoPro
