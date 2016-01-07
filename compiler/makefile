BUILDDATE=$(shell date +%Y/%m/%d)

# Get OS architecture, linux or cygwin
OSARCH = $(shell uname -o | sed "s/GNU\///" | tr A-Z a-z)

# Get processor architecture, i686 or amd64
CPUARCH = $(shell uname -m | sed "s/x86_64/amd64/" | tr A-Z a-z)

# Compiler to use
CCOMP = clang

RELEASE = 1.2

INCLUDEPATH = -Isrc

SETENV  = CFLAGS=$(INCLUDEPATH)
SETENV += PATH=bin:/usr/bin
SETENV += MODULES=.:src

OBERONCOMPILER0 = $(SETENV) bin/oc.$(CCOMP).$(OSARCH).$(CPUARCH)
OBERONCOMPILER  = $(SETENV) ./oc
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
	cp bin/oc.$(CCOMP).$(OSARCH).$(CPUARCH).bak bin/oc.$(CCOMP).$(OSARCH).$(CPUARCH)


setnew:
	cp oc.exe bin/oc.$(CCOMP).$(OSARCH).$(CPUARCH)


translateToC:
	#
	$(info $(BUILDDATE) making Oberon compiler for $(OSARCH) $(CPUARCH) using compiler $(CCOMP).)

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

	$(OBERONCOMPILER0) -PSFs    Configuration.Mod
	$(OBERONCOMPILER0) -PSFs    Platform$(OSARCH).Mod
	$(OBERONCOMPILER0) -PSsiapx Heap.Mod
	$(OBERONCOMPILER0) -PSFs    Args.Mod
	$(OBERONCOMPILER0) -PSFs    Console.Mod
	# $(OBERONCOMPILER0) -PSFs    Unix.Mod
	$(OBERONCOMPILER0) -PSFs    Strings.Mod
	# $(OBERONCOMPILER0) -PSFs    Kernel0.Mod
	$(OBERONCOMPILER0) -PSFs    Modules.Mod
	$(OBERONCOMPILER0) -PSFsx   Files0.Mod
	$(OBERONCOMPILER0) -PSFs    Reals.Mod
	$(OBERONCOMPILER0) -PSFs    Texts0.Mod
	$(OBERONCOMPILER0) -PSFs    vt100.Mod
	$(OBERONCOMPILER0) -PSFs    errors.Mod
	$(OBERONCOMPILER0) -PSFs    extTools.Mod
	$(OBERONCOMPILER0) -PSFs    OPM.cmdln.Mod
	$(OBERONCOMPILER0) -PSFsx   OPS.Mod
	$(OBERONCOMPILER0) -PSFs    OPT.Mod
	$(OBERONCOMPILER0) -PSFs    OPC.Mod
	$(OBERONCOMPILER0) -PSFs    OPV.Mod
	$(OBERONCOMPILER0) -PSFs    OPB.Mod
	$(OBERONCOMPILER0) -PSFs    OPP.Mod
	$(OBERONCOMPILER0) -PSsm    oc.Mod


compileC:
	#
	$(CC) Platform.c Heap.c Args.c Console.c Modules.c Strings.c Configuration.c \
	src/SYSTEM.c Files0.c Reals.c Texts0.c vt100.c extTools.c \
	OPM.c OPS.c OPT.c OPC.c OPV.c OPB.c OPP.c errors.c
	#
	$(CL) -static  oc.c -o oc  Platform.o Heap.o Args.o Console.o Modules.o \
	Strings.o Configuration.o Files0.o Reals.o Texts0.o vt100.o extTools.o \
	SYSTEM.o OPM.o OPS.o OPT.o OPC.o OPV.o OPB.o OPP.o errors.o


clean:
	rm -f *.c *.h *.o *.Mod *.sym *.exe *.stackdump



