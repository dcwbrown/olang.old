# Oberon compiler and library makefile.
#
# To build and install the Oberon compiler and library on a Unix based 
# OS (Linux/Mac/BSD etc.) or on cygwin, run:
#
#   make full
#
# To override your OSs default C compiler, first run
#
#   export CC=compiler
#
# Where compiler is one of:
#  
#   clang                     
#   gcc
#   i686-w64-mingw32-gcc        (32 bit cygwin only)
#   x86_64-w64-mingw32-gcc      (64 bit cygwin only)
#
# (To build on native Windows use make.cmd, not this makefile. Make.cmd automatically 
# assumes use of the Microsoft compiler cl.)



# C compiler data models and sizes and alignments of Oberon types.
#
# There are just three distinct data models that we build for:
#
#    44  -  32 bit pointers, 32 bit alignment
#    48  -  32 bit pointers, 64 bit alignment
#    88  -  64 bit pointers, 64 bit alignment
#
# Meaning of n bit alignment:
#
#    Individual variables of up to n bits are aligned in memory to 
#    whole multiples of their own size, rounded up to a power of two.
#    Variables larger than n bits are aligned to n bits.
#
#    (n will always be a power of 2).
#
# Thus:
#
#                  Size     32 bit alignment   64 bit alignment
#                --------   ----------------   ----------------
# CHAR            1 byte         1 byte             1 byte 
# INTEGER         4 bytes        4 bytes            4 bytes
# LONGINT         8 bytes        4 bytes            8 bytes
#
# Note that in practice for 32 and 64 bit systems, this only affects
# LONGINT.
#
# C data model names:
#
# name           32 bit types            64 bit types         alignment
# ---------   ------------------   ------------------------   ---------
# ILP32       int, long, pointer   long long                  32 or 64
# LP64        int                  long, long long, pointer      64
# LLP64       int, long            long long                     64



config != $(CC) -D O_VER=0.5 -I src/compiler -o a.o src/buildtools/configure.c; ./a.o; rm a.o
include ./Configuration.Make

FLAVOUR    = $(COMPILER).$(OS).$(DATAMODEL)
BUILDDIR   = build/$(FLAVOUR)
SAVEDOLANG = bin/olang.$(FLAVOUR)$(BINEXT)
SOURCE     = $(CURDIR)/src
OLANG      = olang$(BINEXT)
CSOURCEDIR = $(CURDIR)/c-source/$(SIZEALIGN)





usage:
	@echo ""
	@echo Usage:
	@echo ""
	@echo "  make clean         - Remove made files"
	@echo "  make compiler      - Build the compiler but not the library"
	@echo "  make library       - Build all library files and make libolang"
	@echo "  make full          - Runs all the above"
	@echo "  make install       - Install built compiler and library in /opt"
	@echo "                       (May need root access)"
	@echo "  make preparecommit - Uddate c-source and binary directories."
	@echo "  make revertcsource - Use git checkout to restore the c-source directories"





# full: Full build of compiler and libarary.
full:
	@make -s clean
	@make -s compiler
	@make -s library
	@echo "Compiler and library built in $(BUILDDIR)"




preparecommit:
	cp $(OLANG) $(SAVEDOLANG)
	rm -rf c-source/*
	for SA in 44 48 88; do make translate SIZEALIGN=$$SA BUILDDIR=c-source/$$SA; done



revertcsource:
	@for SA in 44 48 88; do git checkout c-source/$$SA; done



clean:
	rm -rf $(BUILDDIR)
			rm -f $(OLANG)




translate:
	@printf "\nmake translate - translating compiler source to C for size/alignment $(SIZEALIGN)\n"
	@mkdir -p $(BUILDDIR)

	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFs    -T$(SIZEALIGN) ../../Configuration.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFs    -T$(SIZEALIGN) ../../src//compiler/Platform$(PLATFORM).Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFsapx -T$(SIZEALIGN) ../../src//compiler/Heap.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFs    -T$(SIZEALIGN) ../../src//compiler/Console.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFs    -T$(SIZEALIGN) ../../src//library/v4/Strings.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFs    -T$(SIZEALIGN) ../../src//library/v4/Modules.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFsx   -T$(SIZEALIGN) ../../src//compiler/Files.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFs    -T$(SIZEALIGN) ../../src//library/v4/Reals.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFs    -T$(SIZEALIGN) ../../src//library/v4/Texts.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFs    -T$(SIZEALIGN) ../../src//compiler/vt100.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFs    -T$(SIZEALIGN) ../../src//compiler/errors.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFs    -T$(SIZEALIGN) ../../src//compiler/OPM.cmdln.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFs    -T$(SIZEALIGN) ../../src//compiler/extTools.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFsx   -T$(SIZEALIGN) ../../src//compiler/OPS.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFs    -T$(SIZEALIGN) ../../src//compiler/OPT.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFs    -T$(SIZEALIGN) ../../src//compiler/OPC.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFs    -T$(SIZEALIGN) ../../src//compiler/OPV.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFs    -T$(SIZEALIGN) ../../src//compiler/OPB.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -SFs    -T$(SIZEALIGN) ../../src//compiler/OPP.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Ssm    -T$(SIZEALIGN) ../../src//compiler/olang.Mod

	@printf "$(BUILDDIR) filled with compiler C source.\n"



# Assemble: Generate the olang compiler binary by compiling the C sources in the buidl directory
#
#  - Does nothing if all C sources in the build directory are older than the existing olang binary
#  - However if there are no C sources in the build directory, copies them from the c-source
#    directory and compiles them. This is how the checked-in version is built on a fresh
#    enlistment or after 'make clean'.

assemble: $(OLANG)

$(BUILDDIR)/*.[ch]: src/compiler/*.[ch] $(CSOURCEDIR)/*
	@echo Populating clean build directory from base c sources.
	@mkdir -p $(BUILDDIR)
	cp $(CSOURCEDIR)/* $(BUILDDIR)
	cp src/compiler/*.[ch] $(BUILDDIR)

$(OLANG): $(BUILDDIR)/*.[ch] src/compiler/*.[ch]

	@printf "\nmake assemble - compiling Oberon compiler c source for configuration:\n"
	@printf "  PLATFORM:  %s\n" "$(PLATFORM)"
	@printf "  OS:        %s\n" "$(OS)"
	@printf "  DATAMODEL: %s\n" "$(DATAMODEL)"
	@printf "  SIZEALIGN: %s\n" "$(SIZEALIGN)"
	@printf "  COMPILER:  %s\n" "$(COMPILER)"
	@printf "  VERSION:   %s\n" "$(VERSION)"
	@printf "  COMPILE:   %s\n" "$(COMPILE)"
	@printf "  BUILDDIR:  %s\n" "$(BUILDDIR)"

	cd $(BUILDDIR) && $(COMPILE) -c SYSTEM.c  Configuration.c Platform.c Heap.c 
	cd $(BUILDDIR) && $(COMPILE) -c Console.c Strings.c       Modules.c  Files.c 
	cd $(BUILDDIR) && $(COMPILE) -c Reals.c   Texts.c         vt100.c    errors.c 
	cd $(BUILDDIR) && $(COMPILE) -c OPM.c     extTools.c      OPS.c      OPT.c 
	cd $(BUILDDIR) && $(COMPILE) -c OPC.c     OPV.c           OPB.c      OPP.c

	cd $(BUILDDIR) && $(COMPILE) $(STATICLINK) olang.c -o $(CURDIR)/$(OLANG) \
	SYSTEM.o  Configuration.o Platform.o Heap.o    Console.o Strings.o       Modules.o  Files.o \
	Reals.o   Texts.o         vt100.o    errors.o  OPM.o     extTools.o      OPS.o      OPT.o \
	OPC.o     OPV.o           OPB.o      OPP.o
	@printf "olang$(BINEXT) created.\n"





# compiler: Builds the compiler, but not the library
compiler:
	@make -s assemble      # First build olang.exe from original C source (if necessary)
	@make -s translate     # Use olang.exe to generate new C source
	@make -s assemble      # Build new olang.exe from new C source






# install: Use only after a successful full build. Installs the compiler 
#          and libraries in /opt/olang.
#          May require root access.
install:
	rm -rf $(INSTALLDIR)
	mkdir -p "$(INSTALLDIR)/bin" "$(INSTALLDIR)/include" "$(INSTALLDIR)/sym" "$(INSTALLDIR)/lib"
	cp -p $(BUILDDIR)/*.h        "$(INSTALLDIR)/include/"
	cp -p $(BUILDDIR)/*.sym      "$(INSTALLDIR)/sym/"
	cp -p $(SAVEDOLANG)          "$(INSTALLDIR)/bin/olang$(BINEXT)"
	cp -p $(BUILDDIR)/libolang.a "$(INSTALLDIR)/lib/"
#	Optional: Link /usr/bin/olang to the new binary
#	ln -fs "$(INSTALLDIR)/bin/$(CURDIR)/$(OLANG)" /usr/bin/$(CURDIR)/$(OLANG)



library: v4 ooc2 ooc ulm pow32 misc s3 libolang


v4:
	@printf "\nMaking v4 library\n"
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/v4/Args.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/v4/Printer.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/v4/Sets.Mod

ooc2:
	@printf "Making ooc2 library\n"
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc2/ooc2Strings.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc2/ooc2Ascii.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc2/ooc2CharClass.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc2/ooc2ConvTypes.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc2/ooc2IntConv.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc2/ooc2IntStr.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc2/ooc2Real0.Mod

ooc:
	@printf "Making ooc library\n"
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocLowReal.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocLowLReal.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocRealMath.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocOakMath.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocLRealMath.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocLongInts.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocComplexMath.Mod 
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocLComplexMath.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocAscii.Mod 
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocCharClass.Mod 
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocStrings.Mod 
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocConvTypes.Mod 
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocLRealConv.Mod 
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocLRealStr.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocRealConv.Mod 
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocRealStr.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocIntConv.Mod 
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocIntStr.Mod 
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocMsg.Mod 
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocSysClock.Mod 
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocTime.Mod 
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocChannel.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocStrings2.Mod 
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocRts.Mod 
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocFilenames.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocTextRider.Mod 
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocBinaryRider.Mod 
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocJulianDay.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocFilenames.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocwrapperlibc.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ooc/oocC$(DATAMODEL).Mod

oocX:
	@printf "Making oocX11 library\n"
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/oocX/oocX11.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/oocX/oocXutil.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/oocX/oocXYplane.Mod

ulm:
	@printf "Making ulm library\n"
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmObjects.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmPriorities.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmDisciplines.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmServices.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmSys.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmSYSTEM.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmEvents.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmProcess.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmResources.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmForwarders.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmRelatedEvents.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmTypes.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmStreams.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmStrings.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmSysTypes.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmTexts.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmSysConversions.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmErrors.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmSysErrors.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmSysStat.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmASCII.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmSets.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmIO.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmAssertions.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmIndirectDisciplines.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmStreamDisciplines.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmIEEE.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmMC68881.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmReals.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmPrint.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmWrite.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmConstStrings.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmPlotters.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmSysIO.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmLoader.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmNetIO.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmPersistentObjects.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmPersistentDisciplines.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmOperations.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmScales.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmTimes.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmClocks.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmTimers.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmConditions.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmStreamConditions.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmTimeConditions.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmCiphers.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmCipherOps.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmBlockCiphers.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmAsymmetricCiphers.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmConclusions.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmRandomGenerators.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmTCrypt.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/ulm/ulmIntOperations.Mod

pow32:
	@printf "Making pow library\n"
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/pow/powStrings.Mod

misc:
	@printf "Making misc library\n"
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/misc/crt.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/misc/Listen.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/misc/MersenneTwister.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/misc/MultiArrays.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/misc/MultiArrayRiders.Mod

s3:
	@printf "Making s3 library\n"
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/s3/ethBTrees.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/s3/ethMD5.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/s3/ethSets.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/s3/ethZlib.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/s3/ethZlibBuffers.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/s3/ethZlibInflate.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/s3/ethZlibDeflate.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/s3/ethZlibReaders.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/s3/ethZlibWriters.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/s3/ethZip.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/s3/ethRandomNumbers.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/s3/ethGZReaders.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/s3/ethGZWriters.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/s3/ethUnicode.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/s3/ethDates.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/s3/ethReals.Mod
	cd $(BUILDDIR); $(CURDIR)/$(OLANG) -Fs ../../src/library/s3/ethStrings.Mod

libolang:
	@printf "\nMaking libolang\n"
#	Remove objects that should not be part of the library
	rm -f $(BUILDDIR)/olang.o $(BUILDDIR)/errors.o $(BUILDDIR)/extTools.o
	rm -f $(BUILDDIR)/OPM.o   $(BUILDDIR)/OPS.o    $(BUILDDIR)/OPT.o      $(BUILDDIR)/OPP.o 
	rm -f $(BUILDDIR)/OPC.o   $(BUILDDIR)/OPV.o    $(BUILDDIR)/OPB.o
#	Make static library
	ar rcs "$(BUILDDIR)/libolang.a" $(BUILDDIR)/*.o






# Shared library (for real unix/linux systems only, don't use on cygwin)
sharedlibrary:
	cd $(BUILDDIR) && $(COMPILE) -shared -o "$(PREFIX)/lib/libolang.so" *.o
	echo "$(PREFIX)/lib" >/etc/ld.so.conf.d
	ldconfig









newsystem:
	@echo "This platform is $(OS) $(DATAMODEL)"
	@echo "This platform's SIZEALIGN parameter is '$(SIZEALIGN)'."





