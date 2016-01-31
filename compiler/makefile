OLANG_VERSION = 0.5
OLANG_ROOT    = /opt

# Select one of the following:
#CC = clang -fPIC -Wno-pointer-sign -g
CC = gcc -Wno-int-to-pointer-cast -Wno-pointer-to-int-cast -g

MAKEINCLUDEVARS != $(CC) -D OLANG_CC="$(CC)" -D OLANG_VERSION=$(OLANG_VERSION) -D OLANG_ROOT=$(OLANG_ROOT) -o a.o src/EstablishParameters.c; ./a.o; rm a.o
include ./make.include

OLANGNAME = olang.$(CCOMP).$(OSARCH).$(CPUARCH)$(BINEXT)
BUILDDIR = build.$(CCOMP).$(OSARCH).$(CPUARCH)


INCLUDEPATH = -I../src

SETENV  = CFLAGS=$(INCLUDEPATH)
SETENV += PATH=bin:/usr/bin
SETENV += MODULES=..:../src

OLANG = $(SETENV) ../bin/$(OLANGNAME)


.phony: all selectplatform tarnslatetoc compilec setoriginal setnew clean install


all: translatetoc compilec


translatetoc:
	mkdir -vp $(BUILDDIR)
	cd $(BUILDDIR); $(OLANG) -PSFs    Configuration.Mod
	cd $(BUILDDIR); $(OLANG) -PSFs    Platform$(PLATFORM).Mod
	cd $(BUILDDIR); $(OLANG) -PSsiapx Heap.Mod
	cd $(BUILDDIR); $(OLANG) -PSFs    Console.Mod
	cd $(BUILDDIR); $(OLANG) -PSFs    Strings.Mod
	cd $(BUILDDIR); $(OLANG) -PSFs    Modules.Mod
	cd $(BUILDDIR); $(OLANG) -PSFsx   Files.Mod
	cd $(BUILDDIR); $(OLANG) -PSFs    Reals.Mod
	cd $(BUILDDIR); $(OLANG) -PSFs    Texts.Mod
	cd $(BUILDDIR); $(OLANG) -PSFs    vt100.Mod
	cd $(BUILDDIR); $(OLANG) -PSFs    errors.Mod
	cd $(BUILDDIR); $(OLANG) -PSFs    extTools.Mod
	cd $(BUILDDIR); $(OLANG) -PSFs    OPM.cmdln.Mod
	cd $(BUILDDIR); $(OLANG) -PSFsx   OPS.Mod
	cd $(BUILDDIR); $(OLANG) -PSFs    OPT.Mod
	cd $(BUILDDIR); $(OLANG) -PSFs    OPC.Mod
	cd $(BUILDDIR); $(OLANG) -PSFs    OPV.Mod
	cd $(BUILDDIR); $(OLANG) -PSFs    OPB.Mod
	cd $(BUILDDIR); $(OLANG) -PSFs    OPP.Mod
	cd $(BUILDDIR); $(OLANG) -PSsm    oc.Mod
	rm -f make.include voc.par Configuration.Mod


compilec:

	cd $(BUILDDIR) && $(CC) -c $(INCLUDEPATH)                       \
	Platform.c Heap.c Console.c Modules.c Strings.c Configuration.c \
	../src/SYSTEM.c Files.c Reals.c Texts.c vt100.c extTools.c      \
	OPM.c OPS.c OPT.c OPC.c OPV.c OPB.c OPP.c errors.c

	cd $(BUILDDIR) && $(CC) -static $(INCLUDEPATH)                       \
	oc.c -o ../olang$(BINEXT)  Platform.o Heap.o Console.o Modules.o     \
	Strings.o Configuration.o Files.o Reals.o Texts.o vt100.o extTools.o \
	SYSTEM.o OPM.o OPS.o OPT.o OPC.o OPV.o OPB.o OPP.o errors.o


clean:
	rm -f *.c *.h *.o *.Mod *.sym *.exe *.par *.stackdump oc oc.exe make.include voc.par Configuration.mod $(BUILDDIR)/*


setoriginal:
	cp bin/$(OLANGNAME).bak bin/$(OLANGNAME)


setnew:
	cp olang$(BINEXT) bin/$(OLANGNAME)


install:
	mkdir -p $(PREFIX)/bin
	mkdir -p $(PREFIX)/include
	mkdir -p $(PREFIX)/sym
	ln -fs $(PREFIX) $(PREFIXLN)

	cp src/*.h $(BUILDDIR)/*.h $(PREFIX)/include/
	cp $(BUILDDIR)/*.sym       $(PREFIX)/sym/
	cp olang$(BINEXT)          $(PREFIX)/bin/

#	Make the object library
	ar rcs $(PREFIX)/libolang.a $(BUILDDIR)/*.o

#	Link /bin/olang to the new binary
	ln -fs $(PREFIX)/bin/olang$(BINEXT) /bin/olang$(BINEXT)

