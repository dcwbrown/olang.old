# GNU makefile starter
# Runs configuration then includes the common makefile.

config:=$(shell $(CC) -D O_VER=0.5 -I src/compiler -o a.o src/buildtools/configure.c; ./a.o; rm a.o)
include olang.make
