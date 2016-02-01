# Select (uncomment) one of the following compilers:

CC = clang -fPIC -Wno-pointer-sign -g
#CC = gcc -Wno-int-to-pointer-cast -Wno-pointer-to-int-cast -g

OLANG_VERSION = 0.5
OLANG_ROOT    = /opt

# The '!=' assignemnt below compiles and runs 'EstablishParameters.c', which
# determines all the machine specific build variables and creates the parameter
# files 'Configuration.Mod' and 'BasicTypeParameters' in the build directory.
# The build variables are writtn to 'make.include' which is then loaded by
# the following line.

MAKEINCLUDEVARS != $(CC) -D OLANG_CC="$(CC)" -D OLANG_VERSION=$(OLANG_VERSION) -D OLANG_ROOT=$(OLANG_ROOT) -o a.o src/EstablishParameters.c; ./a.o; rm a.o
include ./make.include


INCLUDEPATH = -I../src

.phony: all selectplatform translatetoc compilec setnew setbackup restorebackup clean install


all: translatetoc compilec


translatetoc:
#	The following line is temporary, while master binaries still need voc.par
	cp $(BUILDDIR)/BasicTypeParameters $(BUILDDIR)/voc.par

	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSFs    Configuration.Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSFs    Platform$(PLATFORM).Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSsiapx Heap.Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSFs    Console.Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSFs    Strings.Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSFs    Modules.Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSFsx   Files.Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSFs    Reals.Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSFs    Texts.Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSFs    vt100.Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSFs    errors.Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSFs    extTools.Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSFs    OPM.cmdln.Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSFsx   OPS.Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSFs    OPT.Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSFs    OPC.Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSFs    OPV.Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSFs    OPB.Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSFs    OPP.Mod
	cd $(BUILDDIR); MODULES=../src ../bin/$(OLANGNAME) -PSsm    oc.Mod


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
	rm -f *.c *.h *.o *.Mod *.sym *.exe *.par *.stackdump olang$(BINEXT) make.include $(BUILDDIR)/*


setnew:
	cp olang$(BINEXT) bin/$(OLANGNAME)

setbackup:
	cp bin/$(OLANGNAME) bin/$(OLANGNAME).bak

restorebackup:
	cp bin/$(OLANGNAME).bak bin/$(OLANGNAME)


install:
	mkdir -p $(PREFIX)/bin
	mkdir -p $(PREFIX)/include
	mkdir -p $(PREFIX)/sym
	rm -f $(PREFIXLN)
	ln -fs $(PREFIX) $(PREFIXLN)

	cp src/*.h $(BUILDDIR)/*.h $(PREFIX)/include/
	cp $(BUILDDIR)/*.sym       $(PREFIX)/sym/
	cp olang$(BINEXT)          $(PREFIX)/bin/

#	Make the object library
	ar rcs $(PREFIX)/libolang.a $(BUILDDIR)/*.o

#	Link /usr/bin/olang to the new binary
	ln -fs $(PREFIX)/bin/olang$(BINEXT) /usr/bin/olang$(BINEXT)

