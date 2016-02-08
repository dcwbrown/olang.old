cc=$1
$cc -I compiler -D OLANG_VERSION=0.5 -D OLANG_ROOT=/opt -o a.o buildtool/EstablishParameters.c; ./a.o; rm a.o
