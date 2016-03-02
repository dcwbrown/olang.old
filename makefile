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



config != $(CC) -D O_VER=0.5 -I src/compiler -o a.o src/buildtools/configure.c; ./a.o; rm a.o
include ./Configuration.Make

FLAVOUR    = $(COMPILER).$(OS).$(DATAMODEL)
BUILDDIR   = build/$(FLAVOUR)
SAVEDOLANG = bin/olang.$(FLAVOUR)$(BINEXT)
SOURCE     = $(CURDIR)/src
OLANG      = $(CURDIR)/olang$(BINEXT)
CSOURCEDIR = $(CURDIR)/c-source/$(SIZEALIGN)





usage:
	@echo ""
	@echo Usage:
	@echo ""
	@echo "  make clean          - Remove made files"
	@echo "  make compile        - Build the compiler but not the library"
	@echo "                        (Run twice for a full compiler bootstrap)"
	@echo "  make setnewcompiler - copy built compiler to bin directory"
	@echo "  make library        - Build all library files and make libolang"
	@echo "  make full           - Runs all the above"
	@echo "  make install        - Install built compiler and library in /opt"
	@echo "                        (May need root access)"
	@echo "  make newsystem      - Display help on how to build on a new system"





# compiler: Builds the compiler, but not the library
compiler: translate assemble




# full: Bootstraps the compiler by building it twice, then builds the
#       library. If this works the now-proven new compiler is copied to 
#       the bin directory.
full:
	@make clean
	@make compiler
	@rm -rf $(BUILDDIR)
	@make compiler
	@make library
	@make setnewcompiler




# translateallsizes: Build C source directories for each of the C
#                    pointer size and alignment models supported.
#
# These are:
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
# Note that in practise for 32 and 64 bit systems, this only affects
# LONGINT.
#
# C data model names:
#
# name           32 bit types            64 bit types         alignment
# ---------   ------------------   ------------------------   ---------
# ILP32       int, long, pointer   long long                     32
# ILP32-A64   int, long, pointer   long long                     64
# LP64        int                  long, long long, pointer      64
# LLP64       int, long            long long                     64

translateallsizes:
	@make clean
	@for SA in 44 48 88; do make translate SIZEALIGN=$$SA; done


translate:
	@rm -rf $(CSOURCEDIR)
	@mkdir -p $(CSOURCEDIR)
	@cp -n $(SAVEDOLANG) olang$(BINEXT)  # -n: copy only if not already present

	@printf "\nTranslating compiler source to C for size/alignment $(SIZEALIGN)\n\n"

	cd $(CSOURCEDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(CURDIR)/Configuration.Mod
	cd $(CSOURCEDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/PlatformUnix.Mod
	cd $(CSOURCEDIR); $(OLANG) -Ssiapx -T$(SIZEALIGN) $(SOURCE)/compiler/Heap.Mod
	cd $(CSOURCEDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/Console.Mod
	cd $(CSOURCEDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/library/v4/Strings.Mod
	cd $(CSOURCEDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/library/v4/Modules.Mod
	cd $(CSOURCEDIR); $(OLANG) -SFsx   -T$(SIZEALIGN) $(SOURCE)/compiler/Files.Mod
	cd $(CSOURCEDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/library/v4/Reals.Mod
	cd $(CSOURCEDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/library/v4/Texts.Mod
	cd $(CSOURCEDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/vt100.Mod
	cd $(CSOURCEDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/errors.Mod
	cd $(CSOURCEDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/OPM.cmdln.Mod
	cd $(CSOURCEDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/extTools.Mod
	cd $(CSOURCEDIR); $(OLANG) -SFsx   -T$(SIZEALIGN) $(SOURCE)/compiler/OPS.Mod
	cd $(CSOURCEDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/OPT.Mod
	cd $(CSOURCEDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/OPC.Mod
	cd $(CSOURCEDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/OPV.Mod
	cd $(CSOURCEDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/OPB.Mod
	cd $(CSOURCEDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/OPP.Mod
	cd $(CSOURCEDIR); $(OLANG) -Ssm    -T$(SIZEALIGN) $(SOURCE)/compiler/olang.Mod




# Assemble: Uses the C compiler to compile (aka assemble) the appropriate size/align
#           sources for this OS.

assemble:
	@printf "\nCompiling Oberon compiler c source for configuration::\n\n"
	@printf "  PLATFORM:  %s\n"   "$(PLATFORM)"
	@printf "  OS:        %s\n"   "$(OS)"
	@printf "  DATAMODEL: %s\n"   "$(DATAMODEL)"
	@printf "  SIZEALIGN: %s\n"   "$(SIZEALIGN)"
	@printf "  COMPILER:  %s\n"   "$(COMPILER)"
	@printf "  VERSION:   %s\n"   "$(VERSION)"
	@printf "  COMPILE:   %s\n"   "$(COMPILE)"
	@printf "  BUILDDIR:  %s\n\n" "$(BUILDDIR)"

	@rm -rf $(BUILDDIR)
	@mkdir -p $(BUILDDIR)
	@cp src/compiler/*.c src/compiler/*.h $(BUILDDIR)
	@cp $(CSOURCEDIR)/* $(BUILDDIR)

	cd $(BUILDDIR) && $(COMPILE) -c SYSTEM.c  Configuration.c Platform.c Heap.c 
	cd $(BUILDDIR) && $(COMPILE) -c Console.c Strings.c       Modules.c  Files.c 
	cd $(BUILDDIR) && $(COMPILE) -c Reals.c   Texts.c         vt100.c    errors.c 
	cd $(BUILDDIR) && $(COMPILE) -c OPM.c     extTools.c      OPS.c      OPT.c 
	cd $(BUILDDIR) && $(COMPILE) -c OPC.c     OPV.c           OPB.c      OPP.c

	@printf "\n"
	cd $(BUILDDIR) && $(COMPILE) $(STATICLINK) olang.c -o $(OLANG) \
	                                       SYSTEM.o  Configuration.o Platform.o Heap.o \
	                                       Console.o Strings.o       Modules.o  Files.o \
	                                       Reals.o   Texts.o         vt100.o    errors.o \
	                                       OPM.o     extTools.o      OPS.o      OPT.o \
	                                       OPC.o     OPV.o           OPB.o      OPP.o
	cp $(OLANG) $(SAVEDOLANG)
	@printf "\n$(OLANG) created.\n"






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
#	ln -fs "$(INSTALLDIR)/bin/$(OLANG)" /usr/bin/$(OLANG)



clean:
	rm -f *.c *.h *.o *.sym *.exe *.par *.stackdump $(OLANG) 
	rm -f make.config Configuration.Mod newsystem.zip
	rm -rf $(BUILDDIR) newsystem



library: v4 ooc2 ooc ulm pow32 misc s3 libolang


v4:
	@printf "\nMaking v4 library\n\n"
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/v4/Args.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/v4/Printer.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/v4/Sets.Mod

ooc2:
	@printf "\nMaking ooc2 library\n\n"
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc2/ooc2Strings.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc2/ooc2Ascii.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc2/ooc2CharClass.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc2/ooc2ConvTypes.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc2/ooc2IntConv.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc2/ooc2IntStr.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc2/ooc2Real0.Mod

ooc:
	@printf "\nMaking ooc library\n\n"
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocLowReal.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocLowLReal.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocRealMath.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocOakMath.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocLRealMath.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocLongInts.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocComplexMath.Mod 
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocLComplexMath.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocAscii.Mod 
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocCharClass.Mod 
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocStrings.Mod 
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocConvTypes.Mod 
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocLRealConv.Mod 
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocLRealStr.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocRealConv.Mod 
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocRealStr.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocIntConv.Mod 
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocIntStr.Mod 
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocMsg.Mod 
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocSysClock.Mod 
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocTime.Mod 
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocChannel.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocStrings2.Mod 
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocRts.Mod 
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocFilenames.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocTextRider.Mod 
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocBinaryRider.Mod 
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocJulianDay.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocFilenames.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocwrapperlibc.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ooc/oocC$(DATAMODEL).Mod

oocX:
	@printf "\nMaking oocX11 library\n\n"
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/oocX/oocX11.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/oocX/oocXutil.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/oocX/oocXYplane.Mod

ulm:
	@printf "\nMaking ulm library\n\n"
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmObjects.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmPriorities.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmDisciplines.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmServices.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmSys.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmSYSTEM.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmEvents.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmProcess.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmResources.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmForwarders.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmRelatedEvents.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmTypes.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmStreams.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmStrings.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmSysTypes.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmTexts.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmSysConversions.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmErrors.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmSysErrors.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmSysStat.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmASCII.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmSets.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmIO.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmAssertions.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmIndirectDisciplines.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmStreamDisciplines.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmIEEE.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmMC68881.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmReals.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmPrint.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmWrite.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmConstStrings.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmPlotters.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmSysIO.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmLoader.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmNetIO.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmPersistentObjects.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmPersistentDisciplines.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmOperations.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmScales.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmTimes.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmClocks.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmTimers.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmConditions.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmStreamConditions.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmTimeConditions.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmCiphers.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmCipherOps.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmBlockCiphers.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmAsymmetricCiphers.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmConclusions.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmRandomGenerators.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmTCrypt.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/ulm/ulmIntOperations.Mod

pow32:
	@printf "\nMaking pow library\n\n"
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/pow/powStrings.Mod

misc:
	@printf "\nMaking misc library\n\n"
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/misc/crt.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/misc/Listen.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/misc/MersenneTwister.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/misc/MultiArrays.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/misc/MultiArrayRiders.Mod

s3:
	@printf "\nMaking s3 library\n\n"
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/s3/ethBTrees.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/s3/ethMD5.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/s3/ethSets.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/s3/ethZlib.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/s3/ethZlibBuffers.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/s3/ethZlibInflate.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/s3/ethZlibDeflate.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/s3/ethZlibReaders.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/s3/ethZlibWriters.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/s3/ethZip.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/s3/ethRandomNumbers.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/s3/ethGZReaders.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/s3/ethGZWriters.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/s3/ethUnicode.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/s3/ethDates.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/s3/ethReals.Mod
	cd $(BUILDDIR); $(OLANG) -Fs $(SOURCE)/library/s3/ethStrings.Mod

libolang:
	@printf "\nMaking libolang\n\n"
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
	@echo ""
	@echo "Building Oberon on a new Unix or Linux based OS:"
	@echo ""
	@echo "1.  On the new system:"
	@echo "2.     git clone https://github/dcwbrown/olang.git"
	@echo "3.     make newsystem"
	@echo "       If this make fails, edit buildtools/configure.c to add recognition"
	@echo "       for this sytem type and try again."
	@echo "4.     Write down the 2 digit SIZEALIGN parameter reported by make newsystem."
	@echo ""
	@echo "5.  On an existing working unix/linux/cygwin platform:"
	@echo "6.     make translatenewflavour SIZEALIGN=nn"
	@echo "       Where nn is 44, 48 or 88 as identified in step 3."
	@echo ""
	@echo "7.  Copy the generated newsystem.zip file from the existing platform to the new one."
	@echo ""
	@echo "8.  On the new platform:"
	@echo "9.     make compilenewflavour"
	@echo "       This completes the first compiler build of the bootstrap and leaves"
	@echo "       a working olang binary in the root of the enlistment."
	@echo "10.    make compile"
	@echo "       This is the second compilation of the full compiler bootstrap."
	@echo "11.    make setnewcompiler"
	@echo "       This saves the newly built compiler in the enlistment bin directory"
	@echo "12.    make library"
	@echo "13.    sudo make install"
	@echo ""
	@echo ""
	@echo "This platform is $(OS) $(DATAMODEL)"
	@echo "This platform's SIZEALIGN parameter is '$(SIZEALIGN)'."



# translatenewflavour: Run olang to build C source suitable for another 
#                      platform. The result is packed into file newsystem.zip.
#                      Always pass SIZEALIGN=nn to this target to specify 
#                      the new platform's characteristics.
#
# To be executed on an existing installed platform.
#
translatenewflavour:
	@make clean
	@make translate SIZEALIGN=$(SIZEALIGN) BUILDDIR=build.newsystem.$(SIZEALIGN)
	@zip -jr newsystem.zip build.newsystem.$(SIZEALIGN)
	@echo ""
	@echo "Now copy newsystem.zip to the root of the new platform's enlistment"
	@echo "and run make compilenewflavour on the new platfrom."



# compilenewflavour: unzip the newsystem.zip c source files into the new
#                   target specific build directory and compile them with 
#                   the local c compiler.
#
# To be executed on the new platform.
#
compilenewflavour:
	unzip newsystem.zip -d $(BUILDDIR)
	@make compilec




translateold:
	@mkdir -p $(BUILDDIR)
	cp src/compiler/*.h $(BUILDDIR)
	@cp -n $(SAVEDOLANG) ./$(OLANG)  # -n: copy only if not already present

	@printf "\nTranslating compiler source to C using configuration:\n\n"
	@printf "  PLATFORM:  %s\n"   "$(PLATFORM)"
	@printf "  OS:        %s\n"   "$(OS)"
	@printf "  DATAMODEL: %s\n"   "$(DATAMODEL)"
	@printf "  SIZEALIGN: %s\n"   "$(SIZEALIGN)"
	@printf "  COMPILER:  %s\n"   "$(COMPILER)"
	@printf "  VERSION:   %s\n\n" "$(VERSION)"

	cd $(BUILDDIR); $(OLANG) -SFs    -T$(SIZEALIGN) ../Configuration.Mod
	cd $(BUILDDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/Platform$(PLATFORM).Mod
	cd $(BUILDDIR); $(OLANG) -Ssiapx -T$(SIZEALIGN) $(SOURCE)/compiler/Heap.Mod
	cd $(BUILDDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/Console.Mod
	cd $(BUILDDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/library/v4/Strings.Mod
	cd $(BUILDDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/library/v4/Modules.Mod
	cd $(BUILDDIR); $(OLANG) -SFsx   -T$(SIZEALIGN) $(SOURCE)/compiler/Files.Mod
	cd $(BUILDDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/library/v4/Reals.Mod
	cd $(BUILDDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/library/v4/Texts.Mod
	cd $(BUILDDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/vt100.Mod
	cd $(BUILDDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/errors.Mod
	cd $(BUILDDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/OPM.cmdln.Mod
	cd $(BUILDDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/extTools.Mod
	cd $(BUILDDIR); $(OLANG) -SFsx   -T$(SIZEALIGN) $(SOURCE)/compiler/OPS.Mod
	cd $(BUILDDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/OPT.Mod
	cd $(BUILDDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/OPC.Mod
	cd $(BUILDDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/OPV.Mod
	cd $(BUILDDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/OPB.Mod
	cd $(BUILDDIR); $(OLANG) -SFs    -T$(SIZEALIGN) $(SOURCE)/compiler/OPP.Mod
	cd $(BUILDDIR); $(OLANG) -Ssm    -T$(SIZEALIGN) $(SOURCE)/compiler/olang.Mod


compilec:
	@printf "\nCompiling translated Oberon compiler using configuration:\n\n"
	@printf "  COMPILE:   %s\n"   "$(COMPILE)"
	@printf "  FLAVOUR:   %s\n\n" "$(FLAVOUR)"

	cd $(BUILDDIR) && $(COMPILE) -c -I../compiler Platform.c Heap.c Console.c Modules.c Strings.c Configuration.c
	cd $(BUILDDIR) && $(COMPILE) -c -I../compiler $(SOURCE)/compiler/SYSTEM.c Files.c Reals.c Texts.c vt100.c extTools.c
	cd $(BUILDDIR) && $(COMPILE) -c -I../compiler OPM.c OPS.c OPT.c OPC.c OPV.c OPB.c OPP.c errors.c
	@printf "\n"
	cd $(BUILDDIR) && $(COMPILE) $(STATICLINK) -I../compiler \
	olang.c -o $(OLANG)  Platform.o Heap.o Console.o Modules.o \
	Strings.o Configuration.o Files.o Reals.o Texts.o vt100.o extTools.o \
	SYSTEM.o OPM.o OPS.o OPT.o OPC.o OPV.o OPB.o OPP.o errors.o


setnewcompiler:
	cp $(OLANG) $(SAVEDOLANG)





