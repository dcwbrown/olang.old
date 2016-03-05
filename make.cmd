@echo off

:: mscmake.cmd - Build Oberon with Microsoft C compiler.

:: Expects the path to include cl.exe. 

:: As of 10th Feb 2016 the miscrosoft c compiler and build tools 
:: can be downloaded independently of  the full Visual Studio IDE
:: as the 'Visual C++ Build Tools 2015'.

:: See: https://blogs.msdn.microsoft.com/vcblog/2015/11/02/announcing-visual-c-build-tools-2015-standalone-c-tools-for-build-environments/

:: With this installed, from the start button select:
::   All Apps / Visual C++ Build Tools / Visual C++ x86 Native Build Tools Command Prompt


:: Create configuration and parameter files.

cl -nologo -Icompiler -DO_VER=0.5 buildtools/configure.c >nul
setlocal
configure.exe
del configure.obj configure.exe 2>nul

:: Extract make variables into local environment

for /F "delims='=' tokens=1,2" %%a in (make.config) do set %%a=%%b

set FLAVOUR=%COMPILER%.%OS%.%DATAMODEL%
set BUILDDIR=build.%FLAVOUR%
set NEWOLANG=olang%BINEXT%
set SAVEDOLANG=bin\olang.%FLAVOUR%%BINEXT%





:: Process target parameter

if "%1" equ "" (
  call :all
) else (
  call :%1
)
endlocal
goto :eof



:: all: Builds the compiler, but not the library
:all
call :translatetoc
call :compilec
goto :eof




:: full: Bootstraps the compiler by building it twice, then builds the
::       library. If this works the now-proven new compiler is copied to 
::       the bin directory.
:full
call :clean
call :all
rd /s /q %BUILDDIR% 2>nul
call :all
call :library
call :setnewcompiler
goto :eof



:clean
del /q olang%BINEXT% olang.map 2>nul
rd /s /q %BUILDDIR% 2>nul
goto :eof



:setnewcompiler
copy %NEWOLANG% %SAVEDOLANG%
goto :eof



:install
whoami /groups | find "12288" >nul
if errorlevel 1 (
echo make install - administrator rights required. Please run under an administrator command prompt.
goto :eof
)
mkdir "%INSTALLDIR%\bin"                            >nul 2>&1 
mkdir "%INSTALLDIR%\include"                        >nul 2>&1     
mkdir "%INSTALLDIR%\sym"                            >nul 2>&1 
mkdir "%INSTALLDIR%\lib"                            >nul 2>&1 
copy %BUILDDIR%\*.h          "%INSTALLDIR%\include" >nul       
copy %BUILDDIR%\*.sym        "%INSTALLDIR%\sym"     >nul   
copy %SAVEDOLANG%            "%INSTALLDIR%\bin"     >nul   
copy %BUILDDIR%\libolang.lib "%INSTALLDIR%\lib"     >nul   
:: Optional: Link c:\windows\olang.exe to the new binary
::del /q c:\windows\olang.exe >nul 2>&1
::mklink c:\windows\olang.exe "%INSTALLDIR%\bin\olang%BINEXT%"
goto :eof




:: Translate compiler source files to C
:translatetoc
echo.
echo.Translating compiler source to C using configuration:
echo.
echo.  PLATFORM:  %PLATFORM%
echo.  OS:        %OS%
echo.  DATAMODEL: %DATAMODEL%
echo.  SIZEALIGN: %SIZEALIGN%
echo.  COMPILER:  %COMPILER%
echo.  VERSION:   %VERSION%
echo.

if not exist olang.exe copy %SAVEDOLANG% %NEWOLANG%
md %BUILDDIR% 2>nul
cd %BUILDDIR%
copy ..\compiler\*.h >nul 2>nul
..\%NEWOLANG% -SFs    -T%SIZEALIGN% ../Configuration.Mod
..\%NEWOLANG% -SFs    -T%SIZEALIGN% ../compiler/Platform%PLATFORM%.Mod
..\%NEWOLANG% -Ssiapx -T%SIZEALIGN% ../compiler/Heap.Mod
..\%NEWOLANG% -SFs    -T%SIZEALIGN% ../compiler/Console.Mod
..\%NEWOLANG% -SFs    -T%SIZEALIGN% ../library/v4/Strings.Mod
..\%NEWOLANG% -SFs    -T%SIZEALIGN% ../library/v4/Modules.Mod
..\%NEWOLANG% -SFsx   -T%SIZEALIGN% ../compiler/Files.Mod
..\%NEWOLANG% -SFs    -T%SIZEALIGN% ../library/v4/Reals.Mod
..\%NEWOLANG% -SFs    -T%SIZEALIGN% ../library/v4/Texts.Mod
..\%NEWOLANG% -SFs    -T%SIZEALIGN% ../compiler/vt100.Mod
..\%NEWOLANG% -SFs    -T%SIZEALIGN% ../compiler/errors.Mod
..\%NEWOLANG% -SFs    -T%SIZEALIGN% ../compiler/OPM.cmdln.Mod
..\%NEWOLANG% -SFs    -T%SIZEALIGN% ../compiler/extTools.Mod
..\%NEWOLANG% -SFsx   -T%SIZEALIGN% ../compiler/OPS.Mod
..\%NEWOLANG% -SFs    -T%SIZEALIGN% ../compiler/OPT.Mod
..\%NEWOLANG% -SFs    -T%SIZEALIGN% ../compiler/OPC.Mod
..\%NEWOLANG% -SFs    -T%SIZEALIGN% ../compiler/OPV.Mod
..\%NEWOLANG% -SFs    -T%SIZEALIGN% ../compiler/OPB.Mod
..\%NEWOLANG% -SFs    -T%SIZEALIGN% ../compiler/OPP.Mod
..\%NEWOLANG% -Ssm    -T%SIZEALIGN% ../compiler/olang.Mod
cd ..
goto :eof


:: Compile translated compiler source files
:compilec
echo.
echo.Compiling translated Oberon compiler using configuration:
echo.
echo.  FLAVOUR: %FLAVOUR%
echo.


cd %BUILDDIR%
cl -nologo -c Platform.c Heap.c Console.c Modules.c Strings.c Configuration.c ..\compiler\SYSTEM.c Files.c Reals.c Texts.c vt100.c extTools.c	OPM.c OPS.c OPT.c OPC.c OPV.c OPB.c OPP.c errors.c
cl -nologo olang.c /Fe..\olang%BINEXT% Platform.obj Heap.obj Console.obj Modules.obj Strings.obj Configuration.obj Files.obj Reals.obj Texts.obj vt100.obj extTools.obj SYSTEM.obj OPM.obj OPS.obj OPT.obj OPC.obj OPV.obj OPB.obj OPP.obj errors.obj -link -map
cd ..
goto :eof




:library
call :v4
call :ooc2
call :ooc
call :ulm
call :pow32
call :misc
call :s3
call :libolang
goto :eof




:v4
echo.
echo.Making V4 library
echo.
cd %BUILDDIR%
..\%NEWOLANG% -Fs ../library/v4/Args.Mod
..\%NEWOLANG% -Fs ../library/v4/Printer.Mod
..\%NEWOLANG% -Fs ../library/v4/Sets.Mod
cd ..
goto :eof

:ooc2
echo.
echo.Making ooc2 library
echo.
cd %BUILDDIR%
..\%NEWOLANG% -Fs ../library/ooc2/ooc2Strings.Mod
..\%NEWOLANG% -Fs ../library/ooc2/ooc2Ascii.Mod
..\%NEWOLANG% -Fs ../library/ooc2/ooc2CharClass.Mod
..\%NEWOLANG% -Fs ../library/ooc2/ooc2ConvTypes.Mod
..\%NEWOLANG% -Fs ../library/ooc2/ooc2IntConv.Mod
..\%NEWOLANG% -Fs ../library/ooc2/ooc2IntStr.Mod
..\%NEWOLANG% -Fs ../library/ooc2/ooc2Real0.Mod
cd ..
goto :eof

:ooc
echo.
echo.Making ooc library
echo.
cd %BUILDDIR%
..\%NEWOLANG% -Fs ../library/ooc/oocLowReal.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocLowLReal.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocRealMath.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocOakMath.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocLRealMath.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocLongInts.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocComplexMath.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocLComplexMath.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocAscii.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocCharClass.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocStrings.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocConvTypes.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocLRealConv.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocLRealStr.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocRealConv.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocRealStr.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocIntConv.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocIntStr.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocMsg.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocSysClock.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocTime.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocChannel.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocStrings2.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocRts.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocFilenames.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocTextRider.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocBinaryRider.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocJulianDay.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocFilenames.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocwrapperlibc.Mod
..\%NEWOLANG% -Fs ../library/ooc/oocC%DATAMODEL%.Mod
cd ..
goto :eof

:oocX
echo No X11 support on plain Windows - use cygwin and build with cygwin make.
goto :eof

:ulm
echo.
echo.Making ulm library
echo.
cd %BUILDDIR%
..\%NEWOLANG% -Fs ../library/ulm/ulmObjects.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmPriorities.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmDisciplines.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmServices.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmSys.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmSYSTEM.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmEvents.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmProcess.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmResources.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmForwarders.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmRelatedEvents.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmTypes.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmStreams.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmStrings.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmSysTypes.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmTexts.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmSysConversions.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmErrors.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmSysErrors.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmSysStat.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmASCII.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmSets.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmIO.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmAssertions.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmIndirectDisciplines.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmStreamDisciplines.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmIEEE.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmMC68881.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmReals.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmPrint.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmWrite.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmConstStrings.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmPlotters.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmSysIO.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmLoader.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmNetIO.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmPersistentObjects.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmPersistentDisciplines.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmOperations.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmScales.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmTimes.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmClocks.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmTimers.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmConditions.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmStreamConditions.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmTimeConditions.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmCiphers.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmCipherOps.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmBlockCiphers.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmAsymmetricCiphers.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmConclusions.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmRandomGenerators.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmTCrypt.Mod
..\%NEWOLANG% -Fs ../library/ulm/ulmIntOperations.Mod
cd ..
goto :eof

:pow32
echo.
echo.Making pow32 library
echo.
cd %BUILDDIR%
..\%NEWOLANG% -Fs ../library/pow/powStrings.Mod
cd ..
goto :eof

:misc
echo.
echo.Making misc library
echo.
cd %BUILDDIR%
..\%NEWOLANG% -Fs ../library/misc/crt.Mod
..\%NEWOLANG% -Fs ../library/misc/Listen.Mod
..\%NEWOLANG% -Fs ../library/misc/MersenneTwister.Mod
..\%NEWOLANG% -Fs ../library/misc/MultiArrays.Mod
..\%NEWOLANG% -Fs ../library/misc/MultiArrayRiders.Mod
cd ..
goto :eof

:s3
echo.
echo.Making s3 library
echo.
cd %BUILDDIR%
..\%NEWOLANG% -Fs ../library/s3/ethBTrees.Mod
..\%NEWOLANG% -Fs ../library/s3/ethMD5.Mod
..\%NEWOLANG% -Fs ../library/s3/ethSets.Mod
..\%NEWOLANG% -Fs ../library/s3/ethZlib.Mod
..\%NEWOLANG% -Fs ../library/s3/ethZlibBuffers.Mod
..\%NEWOLANG% -Fs ../library/s3/ethZlibInflate.Mod
..\%NEWOLANG% -Fs ../library/s3/ethZlibDeflate.Mod
..\%NEWOLANG% -Fs ../library/s3/ethZlibReaders.Mod
..\%NEWOLANG% -Fs ../library/s3/ethZlibWriters.Mod
..\%NEWOLANG% -Fs ../library/s3/ethZip.Mod
..\%NEWOLANG% -Fs ../library/s3/ethRandomNumbers.Mod
..\%NEWOLANG% -Fs ../library/s3/ethGZReaders.Mod
..\%NEWOLANG% -Fs ../library/s3/ethGZWriters.Mod
..\%NEWOLANG% -Fs ../library/s3/ethUnicode.Mod
..\%NEWOLANG% -Fs ../library/s3/ethDates.Mod
..\%NEWOLANG% -Fs ../library/s3/ethReals.Mod
..\%NEWOLANG% -Fs ../library/s3/ethStrings.Mod
cd ..
goto :eof




:libolang
echo.
echo.Making libolang
echo.
:: Remove objects that should not be part of the library
del /q %BUILDDIR%\olang.obj %BUILDDIR%\errors.obj %BUILDDIR%\extTools.obj
del /q %BUILDDIR%\OPM.obj   %BUILDDIR%\OPS.obj    %BUILDDIR%\OPT.obj      %BUILDDIR%\OPP.obj 
del /q %BUILDDIR%\OPC.obj   %BUILDDIR%\OPV.obj    %BUILDDIR%\OPB.obj
:: Make static library
lib -nologo %BUILDDIR%\*.obj -out:%BUILDDIR%\libolang.lib
goto :eof







:uninstall

whoami /groups | find "12288" >nul
if errorlevel 1 (
echo make uninstall - administrator rights required. Please run under an administrator command prompt.
goto :eof
)

rmdir /s /q "%PREFIX%"         >nul 2>&1 
rmdir "%PREFIXLN%"             >nul 2>&1
del /q c:\windows\olang.exe    >nul 2>&1
goto :eof

