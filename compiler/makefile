BUILDDATE=$(shell date +%Y/%m/%d)

# Get OS architecture, linux or cygwin
OSARCH = $(shell uname -o | sed "s/GNU\///" | tr A-Z a-z)

ifeq ($(OSARCH),cygwin)
	BINEXT = .exe
else
	BINEXT =
endif

# Get processor architecture, i686 or amd64
CPUARCH = $(shell uname -m | sed "s/x86_64/amd64/" | tr A-Z a-z)

TARGET = oc.$(CCOMP).$(OSARCH).$(CPUARCH)$(BINEXT)



# Compiler to use
CCOMP = clang

RELEASE = 0.5

INCLUDEPATH = -Isrc

SETENV  = CFLAGS=$(INCLUDEPATH)
SETENV += PATH=bin:/usr/bin
SETENV += MODULES=.:src

OBERONCOMPILER = $(SETENV) bin/$(TARGET)
LIBNAME = OberonCompiler
LIBRARY = lib$(LIBNAME)

ifndef DIRPREFIX
DIRPREFIX = /opt
endif
PREFIX = $(DIRPREFIX)/oc-$(RELEASE)
PREFIXLINK = $(DIRPREFIX)/oc

CCOPT = -fPIC $(INCLUDEPATH) -g
SHRLIBEXT = so
CC = $(CCOMP) $(CCOPT) -c -Wno-pointer-sign
CL = $(CCOMP) $(CCOPT) -Wno-pointer-sign
LD = $(CCOMP) -shared -o $(LIBRARY).$(SHRLIBEXT)

# s is necessary to create index inside an archive
ARCHIVE = ar rcs $(LIBRARY).a


all: translateToC compileC


setoriginal:
	cp bin/$(TARGET).bak bin/$(TARGET)


setnew:
	cp oc$(BINEXT) bin/$(TARGET)


translateToC:
	#
	$(info $(BUILDDATE) making Oberon compiler for $(OSARCH) $(CPUARCH) using C compiler $(CCOMP).)

	$(file  >Configuration.Mod,MODULE Configuration;)
	$(file >>Configuration.Mod,CONST)
	$(file >>Configuration.Mod,  prefix*      = "$(PREFIX)";)
	$(file >>Configuration.Mod,  osarch*      = "$(OSARCH)";)
	$(file >>Configuration.Mod,  cpuarch*     = "$(CPUARCH)";)
	$(file >>Configuration.Mod,  date*        = "[$(BUILDDATE)]";)
	$(file >>Configuration.Mod,  compiler*    = "$(CCOMP)";)
	$(file >>Configuration.Mod,  version*     = "$(RELEASE)";)
	$(file >>Configuration.Mod,  versionLong* = "Oberon compiler OC for $(OSARCH) $(CPUARCH) [$(BUILDDATE)] $(PREFIX)";)
	$(file >>Configuration.Mod,END Configuration.)

	$(OBERONCOMPILER) -PSFs    Configuration.Mod
	$(OBERONCOMPILER) -PSFs    Platform$(OSARCH).Mod
	$(OBERONCOMPILER) -PSsiapx Heap.Mod
	$(OBERONCOMPILER) -PSFs    Console.Mod
	$(OBERONCOMPILER) -PSFs    Strings.Mod
	$(OBERONCOMPILER) -PSFs    Modules.Mod
	$(OBERONCOMPILER) -PSFsx   Files0.Mod
	$(OBERONCOMPILER) -PSFs    Reals.Mod
	$(OBERONCOMPILER) -PSFs    Texts0.Mod
	$(OBERONCOMPILER) -PSFs    vt100.Mod
	$(OBERONCOMPILER) -PSFs    errors.Mod
	$(OBERONCOMPILER) -PSFs    extTools.Mod
	$(OBERONCOMPILER) -PSFs    OPM.cmdln.Mod
	$(OBERONCOMPILER) -PSFsx   OPS.Mod
	$(OBERONCOMPILER) -PSFs    OPT.Mod
	$(OBERONCOMPILER) -PSFs    OPC.Mod
	$(OBERONCOMPILER) -PSFs    OPV.Mod
	$(OBERONCOMPILER) -PSFs    OPB.Mod
	$(OBERONCOMPILER) -PSFs    OPP.Mod
	$(OBERONCOMPILER) -PSsm    oc.Mod


compileC:
	#
	$(CC) Platform.c Heap.c Console.c Modules.c Strings.c Configuration.c \
	src/SYSTEM.c Files0.c Reals.c Texts0.c vt100.c extTools.c \
	OPM.c OPS.c OPT.c OPC.c OPV.c OPB.c OPP.c errors.c
	#
	$(CL) -static  oc.c -o oc  Platform.o Heap.o Console.o Modules.o \
	Strings.o Configuration.o Files0.o Reals.o Texts0.o vt100.o extTools.o \
	SYSTEM.o OPM.o OPS.o OPT.o OPC.o OPV.o OPB.o OPP.o errors.o


clean:
	rm -f *.c *.h *.o *.Mod *.sym *.exe *.stackdump



