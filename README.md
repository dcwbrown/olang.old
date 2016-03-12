#####OLang - Cross-platform Oberon compiler for 32 and 64 bit Unix/Linux/Windows.

Olang is a version of Vishap Oberon by Norayr Chilingarian. It has been adapted to build more easily on a wider variety of modern platforms, including cygwin and native Windows. See notes.md for differences.

#####Building and installation summary

1. git clone https://github.com/dcwbrown/olang
2. cd olang
3. make full
4. make install

Step 4 requires root/administrator pivilege on most Unix/Linux systems and on native windows.

#####What it does
'make' starts one of three makefiles: GNUmakefile for GNU make systems, makefile on BSD systems, and make.cmd on native Windows. 
All three first compile and run src/buildtools/configure.c, which establishes platform details including:

1. Platform type (unix/windows) and distribution (freebsd/ubuntu/raspbian/...).
2. C compiler command line for assembling olang output.
3. C compiler memory model - ILP32, LP64 or LLP64.
4. C compiler pointer variable alignment. (See SIZEALIGN in olang.make for details.)
5. Directory to install to for this system.

These are written to two files: 
 - Configuration.Mod will be compiled with olang *.Mod sources to embed platform details.
 - Configuration.make will be included by GNUmakefile/makefile/make.cmd to provide the remainder of the make process with platform specific variables.

GNUmakefile and makefile are just wrappers to run configure.c and then include olang.make. (Executing a shell command as part of macro definition has different syntax in BSD and GNU, but with all the platform specific details handled in configure.c, olang.make is fully compatible with both GNU and BSD.) For Windows, make.cmd is coded to provide the same functionality as olang.make.

#####Bootstrapping.
The olang repository includes pre-compiled binaries for many platforms, including ubuntu, freebsd, openbsd, darwin (mac), raspbian, cygwin, cygwin/mingw and native windows.
Also included are C source files in three size and alignment flavours that are sufficient to bootstrap on new unix/linux based platfroms.
When making a fresh enlsitment, the makefile will first obtain a baseline olang compiler by copying the precompiled binary if available, or running the ready made C sources through the C compiler if not. This baseline compiler is then used to compiile the Oberon compiler sources for for this specific platform.

#####c-source directory

The sources in c-sources are sufficient to build a compiler for unix/linux based systems, but which  will always be used with the -T SIZEALIGN parameter. This compiler is then rebuilt (bootstrapped) on the target architecture so that the target SIZEALIGN gets embedded as the default settings for the compiler. The makefile takes care of this automatically in the 'translate' target used by 'make full' and 'make compiler'.

#####Selecting gcc vs clang (Unix/Linux)
By default make uses the compiler defined in variable CC. THis can be overriden by running 'export CC=gcc' or 'export CC=clang' from the command line before running make.
*Note*: be sure to run 'make clean' any time you change the value of CC. Otherwise directories will be mixed up.
*Note*: Darwin (MAC OS/X) redirects gcc to clang, so specifying CC=gcc still builds clang binaries.

#####Native windows
make.cmd is hardcoded to use 'cl', the Microsoft Visual C compiler. For other compilers on windows use cygwin.
The compiler built by make.cmd uses the WIn32 API directly - it does not depened on cygwin or other unix-like layers.
At the time of writing Microsoft provides a free command line Visual C compiler called the 'Visual C++ Build Tools 2015'. See https://blogs.msdn.microsoft.com/vcblog/2015/11/02/announcing-visual-c-build-tools-2015-standalone-c-tools-for-build-environments

#####Cygwin on Windows
Just as on Unix or Linux systems, make can build a gcc or clang based compiler for the cygwin environment on Windows. The generated compiler will depend on cygwin.dll.

#####MingW on Cygwin on Windows
Cygwin also provides packages for building MingW binaries. Although built with gcc these binaries use the Win32 API directly.

To build mingw compiler binaries, set up a cygwin environment, add the corresponding mingw package and set the CC environment variable as follows:

######For 32 bit cygwin
 - use setup-x86.exe to add the package mingw64-i686-gcc-core.
 - run 'export CC=i686-w64-mingw32-gcc'

######For 64 bit cygwin
 - use setup-x86_64.exe to add the package mingw64-x86_64-gcc-core.
 - run 'export CC=x86_64-w64-mingw32-gcc'

(*Note*: Don't be put off by the name 'mingw64' in the 32 bit package.)

Now run 'make full' and 'make install'. This will place the compiler and libraries in /opt/olang in the cygwin filesystem.

#####32 bit vs 64 bit versions and Oberon type sizes.
On Linux/Unix systems, the built compiler is specific to the machine size. Building on 32 bit Ubuntu will create a 32 bit compiler, etc.

On Windows, both native, and under cygwin, it is possible to build both 32 bit and 64 bit compilers. 

For cygwin it depends on the cygwin setup file used (setup-x86.exe generates a 32 bit installation, and setup-x86_64.exe a 64 bit installation.) Both can be installed side by side. Use the start menu entries 'Cygwin Terminal' or 'Cygwin64 Terminal'.

For the Visual C\++ Build Tools,  use the installation provided start menu entries 'Visual C\++ x86 Native Build Tools Command Prompt' or 'Visual C\++ x64 Native Build Tools Command Prompt'. 

Type sizes are fixed across the 32 and 64 bit compilers as follows:
 - CHAR, SHORTINT: 8 bits.
 - INTEGER, REAL: 32 bits.
 - LONGINT, LONGREAL, SET: 64 bi


