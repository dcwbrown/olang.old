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

cl -nologo -Icompiler -DOLANG_VERSION=0.5 buildtool/EstablishParameters.c >nul
setlocal
EstablishParameters.exe
del EstablishParameters.obj EstablishParameters.exe 2>nul
:: Extract make variables into local environment

for /F "delims='=' tokens=1,2" %%a in (make.include) do set %%a=%%b




:: Process parameters

if "%1" equ "" (
  call :all
) else (
  call :%1
)
endlocal
goto :eof




:all
call :translatetoc
call :compilec
goto :eof






:: Translate compiler source files to C
:translatetoc
cd %BUILDDIR%
copy ..\BasicTypeParameters >nul
set MODULES=../compiler
..\bin\%OLANGNAME% -PSFs    ../Configuration.Mod
..\bin\%OLANGNAME% -PSFs    Platform%PLATFORM%.Mod
..\bin\%OLANGNAME% -PSsiapx Heap.Mod
..\bin\%OLANGNAME% -PSFs    Console.Mod
..\bin\%OLANGNAME% -PSFs    Strings.Mod
..\bin\%OLANGNAME% -PSFs    Modules.Mod
..\bin\%OLANGNAME% -PSFsx   Files.Mod
..\bin\%OLANGNAME% -PSFs    Reals.Mod
..\bin\%OLANGNAME% -PSFs    Texts.Mod
..\bin\%OLANGNAME% -PSFs    vt100.Mod
..\bin\%OLANGNAME% -PSFs    errors.Mod
..\bin\%OLANGNAME% -PSFs    OPM.cmdln.Mod
..\bin\%OLANGNAME% -PSFs    extTools.Mod
..\bin\%OLANGNAME% -PSFsx   OPS.Mod
..\bin\%OLANGNAME% -PSFs    OPT.Mod
..\bin\%OLANGNAME% -PSFs    OPC.Mod
..\bin\%OLANGNAME% -PSFs    OPV.Mod
..\bin\%OLANGNAME% -PSFs    OPB.Mod
..\bin\%OLANGNAME% -PSFs    OPP.Mod
..\bin\%OLANGNAME% -PSsm    olang.Mod
cd ..
goto :eof


:: Compile translated compiler source files
:compilec
cd %BUILDDIR%
cl -nologo -c -I..\compiler Platform.c Heap.c Console.c Modules.c Strings.c Configuration.c ..\compiler\SYSTEM.c Files.c Reals.c Texts.c vt100.c extTools.c	OPM.c OPS.c OPT.c OPC.c OPV.c OPB.c OPP.c errors.c
cl -nologo -I..\compiler olang.c /Fe..\olang%BINEXT% Platform.obj Heap.obj Console.obj Modules.obj Strings.obj Configuration.obj Files.obj Reals.obj Texts.obj vt100.obj extTools.obj SYSTEM.obj OPM.obj OPS.obj OPT.obj OPC.obj OPV.obj OPB.obj OPP.obj errors.obj -link -map
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
goto :eof




:v4
setlocal
cd %BUILDDIR%
set MODULES=../library/v4   
set INCLUDE=../compiler;%INCLUDE%
..\bin\%OLANGNAME% -PFsv Args.Mod
..\bin\%OLANGNAME% -PFsv Printer.Mod
..\bin\%OLANGNAME% -PFsv Sets.Mod
cd ..
endlocal
goto :eof

:ooc2
setlocal
cd %BUILDDIR%
set MODULES=../library/ooc2 
set INCLUDE=../compiler;%INCLUDE%
..\bin\%OLANGNAME% -PFs ooc2Strings.Mod
..\bin\%OLANGNAME% -PFs ooc2Ascii.Mod
..\bin\%OLANGNAME% -PFs ooc2CharClass.Mod
..\bin\%OLANGNAME% -PFs ooc2ConvTypes.Mod
..\bin\%OLANGNAME% -PFs ooc2IntConv.Mod
..\bin\%OLANGNAME% -PFs ooc2IntStr.Mod
..\bin\%OLANGNAME% -PFs ooc2Real0.Mod
cd ..
endlocal
goto :eof

:ooc
setlocal
cd %BUILDDIR%
set MODULES=../library/ooc  
set INCLUDE=../compiler;%INCLUDE%
..\bin\%OLANGNAME% -PFs oocLowReal.Mod
..\bin\%OLANGNAME% -PFs oocLowLReal.Mod
..\bin\%OLANGNAME% -PFs oocRealMath.Mod
..\bin\%OLANGNAME% -PFs oocOakMath.Mod
..\bin\%OLANGNAME% -PFs oocLRealMath.Mod
..\bin\%OLANGNAME% -PFs oocLongInts.Mod
..\bin\%OLANGNAME% -PFs oocComplexMath.Mod
..\bin\%OLANGNAME% -PFs oocLComplexMath.Mod
..\bin\%OLANGNAME% -PFs oocAscii.Mod
..\bin\%OLANGNAME% -PFs oocCharClass.Mod
..\bin\%OLANGNAME% -PFs oocStrings.Mod
..\bin\%OLANGNAME% -PFs oocConvTypes.Mod
..\bin\%OLANGNAME% -PFs oocLRealConv.Mod
..\bin\%OLANGNAME% -PFs oocLRealStr.Mod
..\bin\%OLANGNAME% -PFs oocRealConv.Mod
..\bin\%OLANGNAME% -PFs oocRealStr.Mod
..\bin\%OLANGNAME% -PFs oocIntConv.Mod
..\bin\%OLANGNAME% -PFs oocIntStr.Mod
..\bin\%OLANGNAME% -PFs oocMsg.Mod
..\bin\%OLANGNAME% -PFs oocSysClock.Mod
..\bin\%OLANGNAME% -PFs oocTime.Mod
..\bin\%OLANGNAME% -PFs oocChannel.Mod
..\bin\%OLANGNAME% -PFs oocStrings2.Mod
..\bin\%OLANGNAME% -PFs oocRts.Mod
..\bin\%OLANGNAME% -PFs oocFilenames.Mod
..\bin\%OLANGNAME% -PFs oocTextRider.Mod
..\bin\%OLANGNAME% -PFs oocBinaryRider.Mod
..\bin\%OLANGNAME% -PFs oocJulianDay.Mod
..\bin\%OLANGNAME% -PFs oocFilenames.Mod
..\bin\%OLANGNAME% -PFs oocwrapperlibc.Mod
..\bin\%OLANGNAME% -PFs oocC%CPUARCH%.Mod
cd ..
endlocal
goto :eof

:oocX
echo No X11 support on plain Windows - use cygwin and build with cygwin make.
goto :eof

:ulm
setlocal
cd %BUILDDIR%
set MODULES=../library/ulm  
set INCLUDE=../compiler;%INCLUDE%
..\bin\%OLANGNAME% -PFs ulmObjects.Mod
..\bin\%OLANGNAME% -PFs ulmPriorities.Mod
..\bin\%OLANGNAME% -PFs ulmDisciplines.Mod
..\bin\%OLANGNAME% -PFs ulmServices.Mod
..\bin\%OLANGNAME% -PFs ulmSys.Mod
..\bin\%OLANGNAME% -PFs ulmSYSTEM.Mod
..\bin\%OLANGNAME% -PFs ulmEvents.Mod
..\bin\%OLANGNAME% -PFs ulmProcess.Mod
..\bin\%OLANGNAME% -PFs ulmResources.Mod
..\bin\%OLANGNAME% -PFs ulmForwarders.Mod
..\bin\%OLANGNAME% -PFs ulmRelatedEvents.Mod
..\bin\%OLANGNAME% -PFs ulmTypes.Mod
..\bin\%OLANGNAME% -PFs ulmStreams.Mod
..\bin\%OLANGNAME% -PFs ulmStrings.Mod
..\bin\%OLANGNAME% -PFs ulmSysTypes.Mod
..\bin\%OLANGNAME% -PFs ulmTexts.Mod
..\bin\%OLANGNAME% -PFs ulmSysConversions.Mod
..\bin\%OLANGNAME% -PFs ulmErrors.Mod
..\bin\%OLANGNAME% -PFs ulmSysErrors.Mod
..\bin\%OLANGNAME% -PFs ulmSysStat.Mod
..\bin\%OLANGNAME% -PFs ulmASCII.Mod
..\bin\%OLANGNAME% -PFs ulmSets.Mod
..\bin\%OLANGNAME% -PFs ulmIO.Mod
..\bin\%OLANGNAME% -PFs ulmAssertions.Mod
..\bin\%OLANGNAME% -PFs ulmIndirectDisciplines.Mod
..\bin\%OLANGNAME% -PFs ulmStreamDisciplines.Mod
..\bin\%OLANGNAME% -PFs ulmIEEE.Mod
..\bin\%OLANGNAME% -PFs ulmMC68881.Mod
..\bin\%OLANGNAME% -PFs ulmReals.Mod
..\bin\%OLANGNAME% -PFs ulmPrint.Mod
..\bin\%OLANGNAME% -PFs ulmWrite.Mod
..\bin\%OLANGNAME% -PFs ulmConstStrings.Mod
..\bin\%OLANGNAME% -PFs ulmPlotters.Mod
..\bin\%OLANGNAME% -PFs ulmSysIO.Mod
..\bin\%OLANGNAME% -PFs ulmLoader.Mod
..\bin\%OLANGNAME% -PFs ulmNetIO.Mod
..\bin\%OLANGNAME% -PFs ulmPersistentObjects.Mod
..\bin\%OLANGNAME% -PFs ulmPersistentDisciplines.Mod
..\bin\%OLANGNAME% -PFs ulmOperations.Mod
..\bin\%OLANGNAME% -PFs ulmScales.Mod
..\bin\%OLANGNAME% -PFs ulmTimes.Mod
..\bin\%OLANGNAME% -PFs ulmClocks.Mod
..\bin\%OLANGNAME% -PFs ulmTimers.Mod
..\bin\%OLANGNAME% -PFs ulmConditions.Mod
..\bin\%OLANGNAME% -PFs ulmStreamConditions.Mod
..\bin\%OLANGNAME% -PFs ulmTimeConditions.Mod
..\bin\%OLANGNAME% -PFs ulmCiphers.Mod
..\bin\%OLANGNAME% -PFs ulmCipherOps.Mod
..\bin\%OLANGNAME% -PFs ulmBlockCiphers.Mod
..\bin\%OLANGNAME% -PFs ulmAsymmetricCiphers.Mod
..\bin\%OLANGNAME% -PFs ulmConclusions.Mod
..\bin\%OLANGNAME% -PFs ulmRandomGenerators.Mod
..\bin\%OLANGNAME% -PFs ulmTCrypt.Mod
..\bin\%OLANGNAME% -PFs ulmIntOperations.Mod
cd ..
endlocal
goto :eof

:pow32
setlocal
cd %BUILDDIR%
set MODULES=../library/pow  
set INCLUDE=../compiler;%INCLUDE%
..\bin\%OLANGNAME% -PFs powStrings.Mod
cd ..
endlocal
goto :eof

:misc
setlocal
cd %BUILDDIR%
set MODULES=../library/misc 
set INCLUDE=../compiler;%INCLUDE%
..\bin\%OLANGNAME% -PFs crt.Mod
..\bin\%OLANGNAME% -PFs Listen.Mod
..\bin\%OLANGNAME% -PFs MersenneTwister.Mod
..\bin\%OLANGNAME% -PFs MultiArrays.Mod
..\bin\%OLANGNAME% -PFs MultiArrayRiders.Mod
cd ..
endlocal
goto :eof

:s3
setlocal
cd %BUILDDIR%
set MODULES=../library/s3   
set INCLUDE=../compiler;%INCLUDE%
..\bin\%OLANGNAME% -PFs ethBTrees.Mod
..\bin\%OLANGNAME% -PFs ethMD5.Mod
..\bin\%OLANGNAME% -PFs ethSets.Mod
..\bin\%OLANGNAME% -PFs ethZlib.Mod
..\bin\%OLANGNAME% -PFs ethZlibBuffers.Mod
..\bin\%OLANGNAME% -PFs ethZlibInflate.Mod
..\bin\%OLANGNAME% -PFs ethZlibDeflate.Mod
..\bin\%OLANGNAME% -PFs ethZlibReaders.Mod
..\bin\%OLANGNAME% -PFs ethZlibWriters.Mod
..\bin\%OLANGNAME% -PFs ethZip.Mod
..\bin\%OLANGNAME% -PFs ethRandomNumbers.Mod
..\bin\%OLANGNAME% -PFs ethGZReaders.Mod
..\bin\%OLANGNAME% -PFs ethGZWriters.Mod
..\bin\%OLANGNAME% -PFs ethUnicode.Mod
..\bin\%OLANGNAME% -PFs ethDates.Mod
..\bin\%OLANGNAME% -PFs ethReals.Mod
..\bin\%OLANGNAME% -PFs ethStrings.Mod
cd ..
endlocal
goto :eof




:clean
del /q olang%BINEXT% 2>nul
rd /s /q %BUILDDIR% 2>nul
goto :eof



:setnew
copy olang%BINEXT% bin\%OLANGNAME%
goto :eof


:setbackup
copy bin\%OLANGNAME% bin\%OLANGNAME%.bak
goto :eof


:restorebackup
copy bin\%OLANGNAME%.bak bin\%OLANGNAME%
goto :eof
 


:install

whoami /groups | find "12288" >nul
if errorlevel 1 (
echo make install - administrator rights required. Please run under an administrator command prompt.
goto :eof
)

lib -nologo %BUILDDIR%\*.obj -out:libolang.lib
mkdir "%PREFIX%\bin"                     >nul 2>&1 
mkdir "%PREFIX%\include"                 >nul 2>&1     
mkdir "%PREFIX%\sym"                     >nul 2>&1 
mkdir "%PREFIX%\lib"                     >nul 2>&1 
copy compiler\*.h     "%PREFIX%\include" >nul       
copy %BUILDDIR%\*.h   "%PREFIX%\include" >nul       
copy %BUILDDIR%\*.sym "%PREFIX%\sym"     >nul   
copy olang%BINEXT%    "%PREFIX%\bin"     >nul   
copy libolang.lib     "%PREFIX%\lib"     >nul   
rmdir "%PREFIXLN%"                       >nul 2>&1
mklink /d "%PREFIXLN%" "%PREFIX%"
del /q c:\windows\olang.exe              >nul 2>&1
mklink c:\windows\olang.exe "%PREFIX%\bin\olang%BINEXT%"
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

