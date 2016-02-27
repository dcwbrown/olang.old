# Before running make, run selectcompiler.sh to generate configuration files for 
# the current platform and chosen compiler.

all: translatetoc compilec


make.include:
	@./selectcompiler.sh
	@exit 1

include ./make.include



translatetoc:
	mkdir -p $(BUILDDIR)
	cp BasicTypeParameters $(BUILDDIR)

	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSFs    ../Configuration.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSFs    ../compiler/Platform$(PLATFORM).Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSsiapx ../compiler/Heap.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSFs    ../compiler/Console.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSFs    ../library/v4/Strings.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSFs    ../library/v4/Modules.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSFsx   ../compiler/Files.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSFs    ../library/v4/Reals.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSFs    ../library/v4/Texts.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSFs    ../compiler/vt100.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSFs    ../compiler/errors.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSFs    ../compiler/OPM.cmdln.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSFs    ../compiler/extTools.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSFsx   ../compiler/OPS.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSFs    ../compiler/OPT.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSFs    ../compiler/OPC.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSFs    ../compiler/OPV.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSFs    ../compiler/OPB.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSFs    ../compiler/OPP.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PSsm    ../compiler/olang.Mod


compilec:
	cd $(BUILDDIR) && $(CC) -c -I../compiler                        \
	Platform.c Heap.c Console.c Modules.c Strings.c Configuration.c \
	../compiler/SYSTEM.c Files.c Reals.c Texts.c vt100.c extTools.c \
	OPM.c OPS.c OPT.c OPC.c OPV.c OPB.c OPP.c errors.c

	cd $(BUILDDIR) && $(CC) $(STATICLINK) -I../compiler                  \
	olang.c -o ../olang$(BINEXT)  Platform.o Heap.o Console.o Modules.o  \
	Strings.o Configuration.o Files.o Reals.o Texts.o vt100.o extTools.o \
	SYSTEM.o OPM.o OPS.o OPT.o OPC.o OPV.o OPB.o OPP.o errors.o


library: v4 ooc2 ooc ulm pow32 misc s3


v4:
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/v4/Args.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/v4/Printer.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/v4/Sets.Mod

ooc2:
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc2/ooc2Strings.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc2/ooc2Ascii.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc2/ooc2CharClass.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc2/ooc2ConvTypes.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc2/ooc2IntConv.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc2/ooc2IntStr.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc2/ooc2Real0.Mod

ooc:
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocLowReal.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocLowLReal.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocRealMath.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocOakMath.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocLRealMath.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocLongInts.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocComplexMath.Mod 
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocLComplexMath.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocAscii.Mod 
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocCharClass.Mod 
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocStrings.Mod 
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocConvTypes.Mod 
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocLRealConv.Mod 
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocLRealStr.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocRealConv.Mod 
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocRealStr.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocIntConv.Mod 
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocIntStr.Mod 
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocMsg.Mod 
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocSysClock.Mod 
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocTime.Mod 
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocChannel.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocStrings2.Mod 
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocRts.Mod 
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocFilenames.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocTextRider.Mod 
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocBinaryRider.Mod 
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocJulianDay.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocFilenames.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocwrapperlibc.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ooc/oocC$(CPUARCH).Mod

oocX:
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/oocX/oocX11.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/oocX/oocXutil.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/oocX/oocXYplane.Mod

ulm:
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmObjects.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmPriorities.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmDisciplines.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmServices.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmSys.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmSYSTEM.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmEvents.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmProcess.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmResources.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmForwarders.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmRelatedEvents.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmTypes.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmStreams.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmStrings.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmSysTypes.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmTexts.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmSysConversions.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmErrors.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmSysErrors.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmSysStat.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmASCII.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmSets.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmIO.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmAssertions.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmIndirectDisciplines.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmStreamDisciplines.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmIEEE.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmMC68881.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmReals.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmPrint.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmWrite.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmConstStrings.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmPlotters.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmSysIO.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmLoader.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmNetIO.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmPersistentObjects.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmPersistentDisciplines.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmOperations.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmScales.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmTimes.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmClocks.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmTimers.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmConditions.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmStreamConditions.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmTimeConditions.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmCiphers.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmCipherOps.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmBlockCiphers.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmAsymmetricCiphers.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmConclusions.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmRandomGenerators.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmTCrypt.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/ulm/ulmIntOperations.Mod

pow32:
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/pow/powStrings.Mod

misc:
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/misc/crt.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/misc/Listen.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/misc/MersenneTwister.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/misc/MultiArrays.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/misc/MultiArrayRiders.Mod

s3:
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/s3/ethBTrees.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/s3/ethMD5.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/s3/ethSets.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/s3/ethZlib.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/s3/ethZlibBuffers.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/s3/ethZlibInflate.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/s3/ethZlibDeflate.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/s3/ethZlibReaders.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/s3/ethZlibWriters.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/s3/ethZip.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/s3/ethRandomNumbers.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/s3/ethGZReaders.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/s3/ethGZWriters.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/s3/ethUnicode.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/s3/ethDates.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/s3/ethReals.Mod
	cd $(BUILDDIR); ../bin/$(OLANGNAME) -PFs ../library/s3/ethStrings.Mod




clean:
	rm -f *.c *.h *.o *.sym *.exe *.par *.stackdump olang$(BINEXT) $(BUILDDIR)/*

setnew:
	cp olang$(BINEXT) bin/$(OLANGNAME)

setbackup:
	cp bin/$(OLANGNAME) bin/$(OLANGNAME).bak

restorebackup:
	cp bin/$(OLANGNAME).bak bin/$(OLANGNAME)




install:
	mkdir -p "$(PREFIX)/bin" "$(PREFIX)/include" "$(PREFIX)/sym" "$(PREFIX)/lib"
	rm -f "$(PREFIXLN)"
	ln -fs "$(PREFIX)" "$(PREFIXLN)"

	cp -p compiler/*.h       "$(PREFIX)/include/"
	cp -p $(BUILDDIR)/*.h    "$(PREFIX)/include/"
	cp -p $(BUILDDIR)/*.sym  "$(PREFIX)/sym/"
	cp -p olang$(BINEXT)     "$(PREFIX)/bin/"

#	Remove objects that should not be part of the library
	rm -f $(BUILDDIR)/olang.o $(BUILDDIR)/errors.o $(BUILDDIR)/extTools.o
	rm -f $(BUILDDIR)/OPM.o   $(BUILDDIR)/OPS.o    $(BUILDDIR)/OPT.o      $(BUILDDIR)/OPP.o 
	rm -f $(BUILDDIR)/OPC.o   $(BUILDDIR)/OPV.o    $(BUILDDIR)/OPB.o

#	Make static library
	ar rcs "$(PREFIX)/lib/libolang.a" $(BUILDDIR)/*.o

#	Link /usr/bin/olang to the new binary
	ln -fs "$(PREFIX)/bin/olang$(BINEXT)" /usr/bin/olang$(BINEXT)




# Shared library (for real unix/linux systems only, don't use on cygwin)
sharedlibrary:
	cd $(BUILDDIR) && $(CC) -shared -o "$(PREFIX)/lib/libolang.so" *.o
	echo "$(PREFIX)/lib" >/etc/ld.so.conf.d
	ldconfig