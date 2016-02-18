# selectcompiler.sh - build environment files for current platfrom and compiler choice.
#
# Generates:
#    Configuratiom.Mod
#    make.include
#    BasicTypeParameters
#
# Use this script on Unix systems or under cygwin to select either of 'gcc' or 'clang'
# prior to running make. You only need to run this once.
# 
# Additionally under a 64 bit cygwin shell you can choose 'x86_64-w64-mingw32-gcc' or
# under a 32 bit cygwin shell you can choose 'i686-w64-mingw32-gcc'.
# 
# (To build with Microsoft C, use a Windows command prompt and run make.cmd which will
# create the environment files for Microsofts compiler 'cl'.)   


echo Selecting compiler $1
$1 -I compiler -D OLANG_VERSION=0.5 -D OLANG_ROOT=/opt/olang -o a.o buildtool/EstablishParameters.c; ./a.o; rm a.o
