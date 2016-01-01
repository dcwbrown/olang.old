Dave's branch of Vishap Oberon compiler.
========================================

My loose long term goal here is to get to a functioning version of N. Wirth's 2013 version of project OBERON, functioning on both Linux and Windows.

At this stage I have successfully built 64 bit versions of the Vishap compiler under cygwin64, both clang and gcc. (Published as version 1.1b.)

In getting this far I was bothered by a number of little issues:
- NEW is implemented in C as a varargs function (__NEWARR): the size (of each dimension), when passed as a literal integer, was passed as an int wile the __NEWARR varargs code expected a long. As random memory often contains zero, this caused a problem surprisingly rarely, but sometimes requested vastly too much memory and crashed with a segmentation fault. Are there other similar issues hiding?
- Another worry is the number of compiler warnings emitted. I worked around a number of these with typecasts such as (void*) but it should be possible to satisfy ansi C's typechecking more correctly.
- I was somewhat bewildered by the number of type allocation models that vocparam can support and would rather see much fewer, perhaps just one. (INTEGER = 32 bits, LONGINT = 64 bits.). For PCs (including as small as the raspberry pi) this seems sufficent. 
- OS specific file stat and time structures are duplicated in memory layout as Oberon records, making porting fiddly and error prone. It seems to me that the OS interface layer can hide this more safely by refering directly to struct fields in C interface code.
- Support for a range of systems and compilers has generated a large number of nearly but not quite redundant copies of many modules. It should be possible to refactor system dependencies to massively reduce file duplication.

So at this point I'm leaning towards removing most of the compiler and system specific code, moving OS dependent code into minimal C source files, and using ANSI standard fixed width types, such as int32_t and int64_t to implement Oberon integer types.

The next stage I have in mind is to replace as much of the compiler code as I can with Wirth's parsimonious 2013 source.

Using XWindows or GDI to obtain a graphics surface is fiddly, but not a great deal of code, and with this it should be possible to run either the full Oberon system, or to build turnkey graphics apps.

Well, it's a goal. We'll see how far I get before I give up.


Here is the original VISHAP readme:

vishap oberon compiler
======================

How to install
==============

just cd into source directory and type

>make -f makefile.linux.gcc.x86_64

if you are on linux x86_64 system and you want voc to use gcc as backend.

otherwise use corresponding makefile.

then type

>sudo make install

- or see COMPILE file.

How to use
==========

Type voc and it'll show you help.

voc -M will compile your module and link it statically to libVishapOberon.
voc -m will link the module dynamically.

If you have more than one module, and you want them to be compiled into elf filethen:
Let's assume we have module M0 which imports M1;

>voc -l M1.Mod -s M0.Mod -M

Here -l is a global option.
Module M1 will be compiled with -s option, i. e. sym file will be generated.

Module M0 will be compiled and linked statically.

In case you have modules in different directories, like "ui", "logic", "math", then you need to export MODULES environment variable like this:

>export MODULES=".:ui:logic:math"

and after call voc

>voc -s ui0.Mod

Otherwise you can use full path:

>voc -s ui/ui0.Mod

build rpm
=========

if you'd like to build an rpm installer, then

* compress sources as voc-1.0.src.tar.bz2  
  assuming you in voc directory
> cd ..
> tar -jcvpf voc-1.0.src.tar.bz2 voc
* put them to ~/rpmbuild/SOURCES (on some systems as root to /usr/src/redhat/SOURCES/) or other similar location.  
> mkdir -p ~/rpmbuild/SOURCES  
> cp voc-1.0.src.tar.bz2 ~/rpmbuild/SOURCES  
* cd to voc directory and run  
> rpmbuild -ba voc.spec

this should create voc rpm installers.
