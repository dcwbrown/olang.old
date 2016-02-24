# Before running make, run selectcompiler.sh to generate configuration files for 
# the current platform and chosen compiler.

include ./make.include




all: translatetoc compilec




translatetoc:
	mkdir -p $(BUILDDIR)
	cp BasicTypeParameters $(BUILDDIR)

	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSFs    ../Configuration.Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSFs    Platform$(PLATFORM).Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSsiapx Heap.Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSFs    Console.Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSFs    Strings.Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSFs    Modules.Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSFsx   Files.Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSFs    Reals.Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSFs    Texts.Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSFs    vt100.Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSFs    errors.Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSFs    OPM.cmdln.Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSFs    extTools.Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSFsx   OPS.Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSFs    OPT.Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSFs    OPC.Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSFs    OPV.Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSFs    OPB.Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSFs    OPP.Mod
	cd $(BUILDDIR); MODULES=../compiler ../bin/$(OLANGNAME) -PSsm    olang.Mod


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
	cd $(BUILDDIR); MODULES=../library/v4   ../bin/$(OLANGNAME) -PFs Args.Mod
	cd $(BUILDDIR); MODULES=../library/v4   ../bin/$(OLANGNAME) -PFs Printer.Mod
	cd $(BUILDDIR); MODULES=../library/v4   ../bin/$(OLANGNAME) -PFs Sets.Mod

ooc2:
	cd $(BUILDDIR); MODULES=../library/ooc2 ../bin/$(OLANGNAME) -PFs ooc2Strings.Mod
	cd $(BUILDDIR); MODULES=../library/ooc2 ../bin/$(OLANGNAME) -PFs ooc2Ascii.Mod
	cd $(BUILDDIR); MODULES=../library/ooc2 ../bin/$(OLANGNAME) -PFs ooc2CharClass.Mod
	cd $(BUILDDIR); MODULES=../library/ooc2 ../bin/$(OLANGNAME) -PFs ooc2ConvTypes.Mod
	cd $(BUILDDIR); MODULES=../library/ooc2 ../bin/$(OLANGNAME) -PFs ooc2IntConv.Mod
	cd $(BUILDDIR); MODULES=../library/ooc2 ../bin/$(OLANGNAME) -PFs ooc2IntStr.Mod
	cd $(BUILDDIR); MODULES=../library/ooc2 ../bin/$(OLANGNAME) -PFs ooc2Real0.Mod

ooc:
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocLowReal.Mod
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocLowLReal.Mod
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocRealMath.Mod
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocOakMath.Mod
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocLRealMath.Mod
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocLongInts.Mod
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocComplexMath.Mod 
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocLComplexMath.Mod
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocAscii.Mod 
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocCharClass.Mod 
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocStrings.Mod 
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocConvTypes.Mod 
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocLRealConv.Mod 
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocLRealStr.Mod
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocRealConv.Mod 
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocRealStr.Mod
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocIntConv.Mod 
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocIntStr.Mod 
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocMsg.Mod 
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocSysClock.Mod 
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocTime.Mod 
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocChannel.Mod
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocStrings2.Mod 
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocRts.Mod 
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocFilenames.Mod
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocTextRider.Mod 
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocBinaryRider.Mod 
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocJulianDay.Mod
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocFilenames.Mod
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocwrapperlibc.Mod
	cd $(BUILDDIR); MODULES=../library/ooc  ../bin/$(OLANGNAME) -PFs oocC$(CPUARCH).Mod

oocX:
	cd $(BUILDDIR); MODULES=../library/oocX ../bin/$(OLANGNAME) -PFs oocX11.Mod
	cd $(BUILDDIR); MODULES=../library/oocX ../bin/$(OLANGNAME) -PFs oocXutil.Mod
	cd $(BUILDDIR); MODULES=../library/oocX ../bin/$(OLANGNAME) -PFs oocXYplane.Mod

ulm:
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmObjects.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmPriorities.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmDisciplines.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmServices.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmSys.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmSYSTEM.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmEvents.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmProcess.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmResources.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmForwarders.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmRelatedEvents.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmTypes.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmStreams.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmStrings.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmSysTypes.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmTexts.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmSysConversions.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmErrors.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmSysErrors.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmSysStat.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmASCII.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmSets.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmIO.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmAssertions.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmIndirectDisciplines.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmStreamDisciplines.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmIEEE.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmMC68881.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmReals.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmPrint.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmWrite.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmConstStrings.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmPlotters.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmSysIO.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmLoader.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmNetIO.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmPersistentObjects.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmPersistentDisciplines.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmOperations.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmScales.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmTimes.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmClocks.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmTimers.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmConditions.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmStreamConditions.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmTimeConditions.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmCiphers.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmCipherOps.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmBlockCiphers.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmAsymmetricCiphers.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmConclusions.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmRandomGenerators.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmTCrypt.Mod
	cd $(BUILDDIR); MODULES=../library/ulm  ../bin/$(OLANGNAME) -PFs ulmIntOperations.Mod

pow32:
	cd $(BUILDDIR); MODULES=../library/pow  ../bin/$(OLANGNAME) -PFs powStrings.Mod

misc:
	cd $(BUILDDIR); MODULES=../library/misc ../bin/$(OLANGNAME) -PFs crt.Mod
	cd $(BUILDDIR); MODULES=../library/misc ../bin/$(OLANGNAME) -PFs Listen.Mod
	cd $(BUILDDIR); MODULES=../library/misc ../bin/$(OLANGNAME) -PFs MersenneTwister.Mod
	cd $(BUILDDIR); MODULES=../library/misc ../bin/$(OLANGNAME) -PFs MultiArrays.Mod
	cd $(BUILDDIR); MODULES=../library/misc ../bin/$(OLANGNAME) -PFs MultiArrayRiders.Mod

s3:
	cd $(BUILDDIR); MODULES=../library/s3   ../bin/$(OLANGNAME) -PFs ethBTrees.Mod
	cd $(BUILDDIR); MODULES=../library/s3   ../bin/$(OLANGNAME) -PFs ethMD5.Mod
	cd $(BUILDDIR); MODULES=../library/s3   ../bin/$(OLANGNAME) -PFs ethSets.Mod
	cd $(BUILDDIR); MODULES=../library/s3   ../bin/$(OLANGNAME) -PFs ethZlib.Mod
	cd $(BUILDDIR); MODULES=../library/s3   ../bin/$(OLANGNAME) -PFs ethZlibBuffers.Mod
	cd $(BUILDDIR); MODULES=../library/s3   ../bin/$(OLANGNAME) -PFs ethZlibInflate.Mod
	cd $(BUILDDIR); MODULES=../library/s3   ../bin/$(OLANGNAME) -PFs ethZlibDeflate.Mod
	cd $(BUILDDIR); MODULES=../library/s3   ../bin/$(OLANGNAME) -PFs ethZlibReaders.Mod
	cd $(BUILDDIR); MODULES=../library/s3   ../bin/$(OLANGNAME) -PFs ethZlibWriters.Mod
	cd $(BUILDDIR); MODULES=../library/s3   ../bin/$(OLANGNAME) -PFs ethZip.Mod
	cd $(BUILDDIR); MODULES=../library/s3   ../bin/$(OLANGNAME) -PFs ethRandomNumbers.Mod
	cd $(BUILDDIR); MODULES=../library/s3   ../bin/$(OLANGNAME) -PFs ethGZReaders.Mod
	cd $(BUILDDIR); MODULES=../library/s3   ../bin/$(OLANGNAME) -PFs ethGZWriters.Mod
	cd $(BUILDDIR); MODULES=../library/s3   ../bin/$(OLANGNAME) -PFs ethUnicode.Mod
	cd $(BUILDDIR); MODULES=../library/s3   ../bin/$(OLANGNAME) -PFs ethDates.Mod
	cd $(BUILDDIR); MODULES=../library/s3   ../bin/$(OLANGNAME) -PFs ethReals.Mod
	cd $(BUILDDIR); MODULES=../library/s3   ../bin/$(OLANGNAME) -PFs ethStrings.Mod




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




# Shared library (for real unix systems only, don't use on cygwin)
sharedlibrary:
	cd $(BUILDDIR) && $(CC) -shared -o "$(PREFIX)/lib/libolang.so" *.o
	echo "$(PREFIX)/lib" >/etc/ld.so.conf.d
	ldconfig