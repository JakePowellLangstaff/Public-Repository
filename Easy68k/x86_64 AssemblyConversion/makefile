AS=nasm #Assembly compiler
ASFLAGS=-f elf64 -g -l starter.lst #Assembly flags 64 bit (create linux elf)
LD=ld #Lmainker
LDFLAGS= #Linker flags
SOURCES=$(wildcard ./*.asm) #Sources
OBJECTS=$(SOURCES:.asm=.o) #Object files
EXECUTABLE=PROJECTII

#Check version
all:$(SOURCES) $(EXECUTABLE)

#Create Executable
$(EXECUTABLE): $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -O $@
	./${EXECUTABLE}

#Compile assembly program
$(OBJECTS): $(SOURCES)
	@clear
	$(AS) $(ASFLAGS) $(SOURCES)

#Clean folder
clean:
	rm -rf *o *.;st $(EXECUTABLE)
