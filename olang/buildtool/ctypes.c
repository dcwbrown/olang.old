#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#ifndef __MINGW32__
  #include <sys/utsname.h>
#endif


void fail(char *msg) {printf("%s\n", msg); exit(1);}


char* cpuarch  = "unknown";
char* ccomp    = "unknown";

#ifdef __MINGW32__
char* osarch   = "mingw";
#else
char* osarch   = "unknown";
struct utsname sys;
#endif


void computeParameters() {
  #ifndef __MINGW32__
    if (uname(&sys)<0) fail("Couldn't get sys name - uname() failed.");
  
    if      (strncasecmp(sys.sysname, "cygwin",  6) == 0) {osarch = "cygwin";}
    else if (strncasecmp(sys.sysname, "linux",   5) == 0) {osarch = "linux";}
    else if (strncasecmp(sys.sysname, "freebsd", 5) == 0) {osarch = "freebsd";}
    else fail("Unrecognised OS architecture name returned by uname.");
  #endif

  // Deermine memory model
  if (sizeof (void*) == 4) {
    // 32 bit address space, LP32 or ILP32
    if (sizeof(long) != 4) fail("long not 32 bits in 32 bit address architecture.");
    if (sizeof(int) == 2) {
      cpuarch = "LP32";   // Win 16 (Windows 3.x)
    } else if (sizeof(int) == 4) {
      cpuarch = "ILP32";  // Modern 32 bit architectures
    } else fail("int neither 16 nor 32 bits in 32 bit address architecture.");
  } else if (sizeof (void*) == 8) {
    // 64 bit address space
    if (sizeof(long long) != 8) fail("long long not 64 bits in 64 bit address architecture.");
    if (sizeof(int) == 4) { // LP64 or LLP64
      if (sizeof(long) == 4) {
        cpuarch = "LLP64";
      } else if (sizeof(long) == 8) {
        cpuarch = "LP64";
      } else fail("long neither 32 bits nor 64 bits in 64 bit address architecture.");
    } else if (sizeof(int) == 8) { // ILP64
      if (sizeof(long) != 8) fail("long not 64 bits in 64 bit address architecture though int is 64 bits.");
      cpuarch = "ILP64";
    } else fail ("int neither 32 nor 64 bits in 64 bit address architecture.");
  } else {
    fail("Pointer size neither 32 bits nor 64 bits.");
  }

  #if defined(__clang__)
  ccomp = "clang";
  #elif defined(__GNUC__)
  ccomp = "gcc";
  #elif defined(_MSC_VER)
  ccomp = "msc";
  #else
  ccomp = "unknown";
  #endif
}


void writeCTypes() {
  printf("os        cpu     compiler  char  short  int  long  long long  void*\n");
  printf("%-8.8s  %-6.6s  %-8.8s  %4d  %5d  %3d  %4d  %9d  %5d\n",
    osarch, cpuarch, ccomp,
    (int)sizeof(char), (int)sizeof(short), (int)sizeof(int),
		(int)sizeof(long), (int)sizeof(long long), (int)sizeof(void*));
}


int main()
{
  computeParameters();
  writeCTypes();
}
