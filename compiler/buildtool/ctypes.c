#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include <time.h>
//#include <sys/types.h>
//#include <sys/stat.h>
//#include <fcntl.h>
#include <sys/utsname.h>

void fail(char *msg) {printf("%s\n", msg); exit(1);}

struct utsname sys;

char* cpuarch  = "unknown";
char* osarch   = "unknown";
char* ccomp    = "unknown";


void computeParameters() {
  if (uname(&sys)<0) fail("Couldn't get sys name - uname() failed.");

  // Normalise os and cpu architecture names

  if      (strncasecmp(sys.sysname, "cygwin",  6) == 0) {osarch = "cygwin";}
  else if (strncasecmp(sys.sysname, "linux",   5) == 0) {osarch = "linux";}
  else if (strncasecmp(sys.sysname, "freebsd", 5) == 0) {osarch = "freebsd";}
  else fail("Unrecognised OS architecture name returned by uname.");

  if      (strncasecmp(sys.machine, "i686",   6) == 0) cpuarch = "i686";
  else if (strncasecmp(sys.machine, "x86",    4) == 0) cpuarch = "i686";
  else if (strncasecmp(sys.machine, "x86_64", 6) == 0) cpuarch = "amd64";
  else if (strncasecmp(sys.machine, "amd64",  5) == 0) cpuarch = "amd64";
  else fail("Unrecognised machine architecture name returned by uname.");

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
