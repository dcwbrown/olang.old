# selectcompiler.sh - build environment files for current platfrom and compiler choice.
#
# Usage:
#   ./selectplatform.sh compilercommand
#
# Where compilercommand is one of 'gcc', 'clang', 'i686-w64-mingw32-gcc' or 
# 'x86_64-w64-mingw32-gcc'.
#
# After running selectcompiler, run ./fullmake.sh to do a full bootstrap build
# and install of the compiler and libraries. (Full make is just a  sequence of 
# make commands).
#
# Note that fullmake will require administrator/root privileges to install. On
# most platforms it uses sudo and will ask for a password when it reaches the
# first make install. 
#
#
# selectcompiler generates the following files:
#
#    Configuratiom.Mod   - Config strings and basic type parameters
#    make.include        - Config strings as environment variables
#    BasicTypeParameters - Basic type parameters for the -P option.
#
#
# Use this script on Unix based systems to select either of 'gcc' or 'clang'
# prior to running make. You only need to run this once.
#
# Supported systems:
#    Linux:             clang and gcc, 32 and 64 bit
#    Cygwin on Windows: clang and gcc, 32 and 64 bit
#    FreeBSD:           clang 64 bit (others should work, but are untested)
#    Darwin (Mac OSX):  clang 64 bit (others should work, but are untested)
# 
# Additionally under a 64 bit cygwin shell you can choose 'x86_64-w64-mingw32-gcc' or
# under a 32 bit cygwin shell you can choose 'i686-w64-mingw32-gcc'.
#
# Windows and Microsoft C
# 
# To build a windows specific version you can also use Microsoft C from a
# Windows command prompt with no unix shell or make dependencies - instead
# run fullmake.cmd for the full bootstrap build, and make.cmd for parts.


if [ "$1" = "" ]; then
  echo ""
  echo ""
  echo "Please run:"
  echo ""
  echo "  ./selectcompiler.sh compiler"
  echo ""
  echo "Where compiler is 'clang', 'gcc' or 'mingw'."
  echo ""
  echo ""
  exit 1
fi



# Mingw running under cygwin builds binaries that are independent
# of cygwin.dll. For convenience map 'mingw' to the actual compiler
# binary names based on whether this is 32 or 64 bit cygwin.

if [ "$1" = "mingw" ]; then
  cc="$(uname -m)-w64-mingw32-gcc"
else
  cc=$1
fi


if ! which $cc >/dev/null; then
  echo "Cannot find compiler $1"
  exit
fi


$cc -I compiler -D OLANG_VERSION=0.5 -D OLANG_ROOT=/opt/olang -o a.o buildtool/EstablishParameters.c
./a.o
rm a.o

