#####OLang - Cross-platform Oberon compiler for 32 and 64 bit Unix/Linux/Windows.

Olang is a version of Vishap Oberon by Norayr Chilingarian. It has been adapted to build more easily on a wider variety of modern platforms, including cygwin and native Windows.

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
 - LONGINT, LONGREAL, SET: 64 bits.

#####Changes relative to Vishap Oberon

HALT and compiler error reporting have been updated to print error number and meaning where possible, and to include line number with source lines.

The Vishap Oberon enlistment handles different platforms with multiple version of core files, each with the appropriate, usually small, changes for that platform. OLang avoids nearly all of these multiple similar files with a combination of approaches:

 - Reference to Unix/Linux data structures is achieved without creating parallel RECORD layouts in Oberon code by moving all platform dependent code into code procedures.
 - Compiler specific versions of the v4 library files are removed in favour of necessary functionality provided as small extensions of standard v4 libraries. In practise this amounts to little more than a search path feature added to Files.Mod.
 - All size dependent code is abstracted into simple definitions in SYSTEM.h and referenced from code procedures.

All C and Oberon compilation warnings have been fixed. In particular there were a lot of type conversion warnings solved by casting twith with uintptr_t as the intermediate type.

A couple of type size issues have been fixed:

 - It is not necessary to specify literal numeric sizes on parameters to ANSI C functions as the compiler knows the size from the declaration of the called function. 
The Oberon compiler includes a procedure to gnerate 'l' at the end of long literal parameters on K&R C systems, but intentionally omits the 'l' when the compiler is known to be ANSI (as all the supported compilers are). 
Arguably there's no harm adding the 'l', and this test is an unnecessary complication, but it works. 
**Except** where the parameter is being passed to a vararg. In this case the compiler cannot tell what size the code will fetch at run time and does not extend a literal integer to long. 
Why does this matter, surely Oberon does not use varargs? 
Unfortunately it does - for the individual dimension size parameters to NEW. Thus on a 64 bit system, the dimesion size must be specified as 64 bit or the compiler will only pass 32 bits. (Generating intermittent out of memory failures when the subsequent tack word is non-zero.)  
Removing the test for ANSI and thus generating the trailing 'l' is a sufficient fix for the data models supported by Vishap Oberon. 
However there is a further complication - this is not sufficient for the LLP64 C data model favoured by Windows. In LLP64, 'long' is only 32 bit. The 64 bit integer type is  'long long' and literal numerics of this type require an 'll' suffix. 
Rather than create more complex 'l' suffix code OLang chooses instead to replace it by (LONGINT)(n) typecasts, which forces n to the correct size in all cases.

 - Oberon generates code to copy strings passed by value, so that changes do not affect the original string. 
The copy is not allocated from the Oberon Heap, but direct from the OS (e.g. via malloc on Linux/Unix). At function return the copy is free'd by generating C code to call free before the return statement. 
There is a problem here when the expression on the return statement references the local string copy as the reference is now to free'd memory. 
All bets are off - the OS or C runtime could have done anythng to this memory as part of heap management (e.g. used it for free chain linkage), and with pre-emptive multitasking it may have been reallocated and used for another purpose before the return expression refers to it. 
This is one of that category of frustrating bug that can hit vary rarely and is very difficult to diagnose when it does. 
The solution I have implemented is to generate a return value variable at the entry of every function, and generate code to evaluate the return expression into the variable *before* generating the local variable free code. 
In theory the Oberon compiler could inspect the return value for reference to a local copy and only generate the result variable when necessary, however this is a lot of complicated code at function entry and I'm not sure it is necessary, really the C compiler should be able to optimize code with a result variable much the same as code without it.

Texts.WriteInt corrected to work with both 4 and 8 byte LONGINTs. Previously values with more than 11 digits caused an index out of range error.
