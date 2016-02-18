// Generate platform specific files:
//   BasicTypeParameters - Oberon compiler type sizes and alignments
//   Configuration.Mod   - version and directory information to build into the compiler
//   make.include        - make variable settings for this configuration
// Also tests validity of SYSTEM.h macros on this platform.
// from vocparam.c originally by J. Templ 23.6.95

#include "SYSTEM.h"  

#ifndef _WIN32
  #include <sys/types.h>
  #include <sys/stat.h>
  #include <fcntl.h>
  #include <sys/utsname.h>
#endif

#include <stdlib.h>
#include <stdio.h>
#include <time.h>



#ifndef OLANG_VERSION
#define OLANG_VERSION local
#endif

#ifndef OLANG_ROOT
#define OLANG_ROOT /opt
#endif

#define macrotostringhelper(s) #s
#define macrotostring(s) macrotostringhelper(s)



void fail(char *msg) {printf("%s\n", msg); exit(1);}


char builddate[256];
char olangname[256];
char builddir[256];
char flavour[256];
char prefix[256];

char* version = macrotostring(OLANG_VERSION);
char* cpuarch = "unknown";
char* ccomp   = "unknown";
char* cc      = "unknown";

#ifdef _WIN32
  char  prefixln[256];
  char* osarch     = "windows";
  char* platform   = "windows";
  char* binext     = ".exe";
  char* staticlink = ""; // No static link on Windows
#else
  char* prefixln   = macrotostring(OLANG_ROOT);
  char* osarch     = "unknown";
  char* platform   = "unknown";
  char* binext     = "";
  char* staticlink = "-static";  // Static compilation option - though disabled on darwin.
  struct utsname sys;
#endif


void computeParameters() {
  #ifndef _WIN32
    if (uname(&sys)<0) fail("Couldn't get sys name - uname() failed.");
  
    if      (strncasecmp(sys.sysname, "cygwin",  6) == 0) {osarch = "cygwin";  platform = "unix"; binext = ".exe";}
    else if (strncasecmp(sys.sysname, "linux",   5) == 0) {osarch = "linux";   platform = "unix";}
    else if (strncasecmp(sys.sysname, "freebsd", 5) == 0) {osarch = "freebsd"; platform = "unix";}
    else if (strncasecmp(sys.sysname, "darwin",  5) == 0) {osarch = "darwin";  platform = "unix"; staticlink = "";}
    else {
      printf("sysname: '%s'\n", sys.sysname);
      fail("Unrecognised OS architecture name (sysname) returned by uname.");
    }
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

  time_t t = time(0);
  strftime(builddate, sizeof(builddate), "%Y/%m/%d", localtime(&t));

  #if defined(__MINGW32__)
  ccomp = "mingw";
  if (sizeof (void*) == 4)
    cc = "i686-w64-mingw32-gcc -g"; 
  else 
    cc = "x86_64-w64-mingw32-gcc -g";
  #elif defined(__clang__)
  ccomp = "clang";
  cc    = "clang -fPIC -g";
  #elif defined(__GNUC__)
  ccomp = "gcc";
  cc    = "gcc -g";
  #elif defined(_MSC_VER)
  ccomp = "msc";
  cc    = "cl /nologo";
  #endif

  #ifdef _WIN32
    #ifdef _WIN64
      sprintf(prefixln, "%s\\olang", getenv("ProgramFiles"));
    #else
      sprintf(prefixln, "%s\\olang", getenv("ProgramFiles(x86)"));
    #endif
  #endif

  sprintf(flavour,   "%s.%s.%s",   ccomp, osarch, cpuarch);
  sprintf(builddir,  "build.%s",   flavour);
  sprintf(olangname, "olang.%s%s", flavour, binext);
  sprintf(prefix,    "%s-%s",      prefixln, version);
}




// Determination of basic type parameters - size, alignment and endianness.

struct {CHAR ch; CHAR     x;}    c;
struct {CHAR ch; BOOLEAN  x;}    b;
struct {CHAR ch; SHORTINT x;}    si;
struct {CHAR ch; INTEGER  x;}    i;
struct {CHAR ch; LONGINT  x;}    li;
struct {CHAR ch; SET      x;}    s;
struct {CHAR ch; REAL     x;}    r;
struct {CHAR ch; LONGREAL x;}    lr;
struct {CHAR ch; void*    x;}    p;
struct {CHAR ch; void   (*x)();} f;

struct {CHAR ch;}             rec0;
//struct {CHAR ch; LONGREAL x;} rec1;
struct {char x[65];}          rec2;

void writeBasicTypeParameters() {
  FILE *fd = fopen("BasicTypeParameters", "w");
  if (fd == NULL) fail("Couldn't create BasicTypeParameters.");

  /* get size and alignment of standard types */
  fprintf(fd, "CHAR %lu %lu\n",         (long)sizeof(CHAR),         (long)((char*)&c.x  - (char*)&c));
  fprintf(fd, "BOOLEAN %lu %lu\n",      (long)sizeof(BOOLEAN),      (long)((char*)&b.x  - (char*)&b));
  fprintf(fd, "SHORTINT %lu %lu\n",     (long)sizeof(SHORTINT),     (long)((char*)&si.x - (char*)&si));
  fprintf(fd, "INTEGER %lu %lu\n",      (long)sizeof(INTEGER),      (long)((char*)&i.x  - (char*)&i));
  fprintf(fd, "LONGINT %lu %lu\n",      (long)sizeof(LONGINT),      (long)((char*)&li.x - (char*)&li));
  fprintf(fd, "SET %lu %lu\n",          (long)sizeof(SET),          (long)((char*)&s.x  - (char*)&s));
  fprintf(fd, "REAL %lu %lu\n",         (long)sizeof(REAL),         (long)((char*)&r.x  - (char*)&r));
  fprintf(fd, "LONGREAL %lu %lu\n",     (long)sizeof(LONGREAL),     (long)((char*)&lr.x - (char*)&lr));
  fprintf(fd, "PTR %lu %lu\n",          (long)sizeof(p.x),          (long)((char*)&p.x  - (char*)&p));
  fprintf(fd, "PROC %lu %lu\n",         (long)sizeof(f.x),          (long)((char*)&f.x  - (char*)&f));
  fprintf(fd, "RECORD %d %lu\n",        (sizeof(rec2)==65) == (sizeof(rec0)==1), (long)(sizeof(rec2)-64));
  long x = 1;
  fprintf(fd, "ENDIAN %hhd %d\n",       *(char*)&x, 0);

  fclose(fd);
}




void testPlatformSupport() {
  if (sizeof(CHAR)    != 1)          printf("error: CHAR should have size 1\n");
  if (sizeof(BOOLEAN) != 1)          printf("error: BOOLEAN should have size 1\n");
  if (sizeof(SHORTINT)!= 1)          printf("error: SHORTINT should have size 1\n");
  if (sizeof(LONGINT)  < sizeof p.x) printf("error: LONGINT should have at least the same size as pointers\n");
  if (sizeof(LONGINT)  < sizeof f.x) printf("error: LONGINT should have at least the same size as function pointers\n");

  if (((sizeof(rec2)==65) == (sizeof(rec0)==1)) && ((sizeof(rec2)-64) != sizeof(rec0)))
    printf("error: unsupported record layout  sizeof(rec0) = %lu  sizeof(rec2) = %lu\n", (long)sizeof(rec0), (long)sizeof(rec2));

  /* test the __ASHR macro */
  if (__ASHR(-1, 1) != -1) printf("error: ASH(-1, -1) # -1\n");
  if (__ASHR(-2, 1) != -1) printf("error: ASH(-2, -1) # -1\n");
  if (__ASHR(0, 1)  !=  0) printf("error: ASH(0, 1) #  0\n");
  if (__ASHR(1, 1)  !=  0) printf("error: ASH(1, 1) #  0\n");
  if (__ASHR(2, 1)  !=  1) printf("error: ASH(2, 1) #  1\n");

  /* test the __SETRNG macro */
  long x = 0;
  long y = sizeof(SET)*8 - 1;
  if (__SETRNG(x, y) != -1) printf("error: SETRNG(0, MAX(SET)) != -1\n");

  /* test string comparison for extended ascii */
  {char a[10], b[10];
    a[0] = (CHAR)128; a[1] = 0;
    b[0] = 0;
    if (__STRCMP(a, b) < 0) printf("error: __STRCMP(a, b)  with extended ascii charcters; should be unsigned\n");
  }
}




void writeMakeParameters() {
  FILE *fd = fopen("make.include", "w");
  if (fd == NULL) fail("Couldn't create make.include.");

  fprintf(fd, "BUILDDATE=%s\n",  builddate);
  fprintf(fd, "CCOMP=%s\n",      ccomp);
  fprintf(fd, "OSARCH=%s\n",     osarch);
  fprintf(fd, "CPUARCH=%s\n",    cpuarch);
  fprintf(fd, "PLATFORM=%s\n",   platform);
  fprintf(fd, "PREFIX=%s\n",     prefix);
  fprintf(fd, "PREFIXLN=%s\n",   prefixln);
  fprintf(fd, "FLAVOUR=%s\n",    flavour);
  fprintf(fd, "BUILDDIR=%s\n",   builddir);
  fprintf(fd, "OLANGNAME=%s\n",  olangname);
  fprintf(fd, "BINEXT=%s\n",     binext);
  fprintf(fd, "CC=%s\n",         cc);
  fprintf(fd, "STATICLINK=%s\n", staticlink);

  fclose(fd);
}




void writeConfigurationMod() {
  FILE *fd = fopen("Configuration.Mod", "w");
  if (fd == NULL) fail("Couldn't create Configuration.Mod.");

  fprintf(fd, "MODULE Configuration;\n");
  fprintf(fd, "CONST\n");
  fprintf(fd, "  prefix*      = '%s';\n",   prefix);
  fprintf(fd, "  osarch*      = '%s';\n",   osarch);
  fprintf(fd, "  cpuarch*     = '%s';\n",   cpuarch);
  fprintf(fd, "  date*        = '[%s]';\n", builddate);
  fprintf(fd, "  cc*          = '%s';\n",   cc);
  fprintf(fd, "  compiler*    = '%s';\n",   ccomp);
  fprintf(fd, "  version*     = '%s';\n",   version);
  fprintf(fd, "  staticlink*  = '%s';\n",   staticlink); 
  fprintf(fd, "  versionLong* = 'Oberon compiler olang %s [%s] for %s %s using %s in %s';\n\n",
    version, builddate, osarch, cpuarch, ccomp, prefix);

  fprintf(fd, "  CharSize*    = %1lu;  CharAlign*    = %lu;\n", (long)sizeof(CHAR),         (long)((char*)&c.x  - (char*)&c));
  fprintf(fd, "  BoolSize*    = %1lu;  BoolAlign*    = %lu;\n", (long)sizeof(BOOLEAN),      (long)((char*)&b.x  - (char*)&b));
  fprintf(fd, "  SIntSize*    = %1lu;  SIntAlign*    = %lu;\n", (long)sizeof(SHORTINT),     (long)((char*)&si.x - (char*)&si));
  fprintf(fd, "  IntSize*     = %1lu;  IntAlign*     = %lu;\n", (long)sizeof(INTEGER),      (long)((char*)&i.x  - (char*)&i));
  fprintf(fd, "  LIntSize*    = %1lu;  LIntAlign*    = %lu;\n", (long)sizeof(LONGINT),      (long)((char*)&li.x - (char*)&li));
  fprintf(fd, "  SetSize*     = %1lu;  SetAlign*     = %lu;\n", (long)sizeof(SET),          (long)((char*)&s.x  - (char*)&s));
  fprintf(fd, "  RealSize*    = %1lu;  RealAlign*    = %lu;\n", (long)sizeof(REAL),         (long)((char*)&r.x  - (char*)&r));
  fprintf(fd, "  LRealSize*   = %1lu;  LRealAlign*   = %lu;\n", (long)sizeof(LONGREAL),     (long)((char*)&lr.x - (char*)&lr));
  fprintf(fd, "  PointerSize* = %1lu;  PointerAlign* = %lu;\n", (long)sizeof(p.x),          (long)((char*)&p.x  - (char*)&p));
  fprintf(fd, "  ProcSize*    = %1lu;  ProcAlign*    = %lu;\n", (long)sizeof(f.x),          (long)((char*)&f.x  - (char*)&f));
  fprintf(fd, "  RecSize*     = %01d;  RecAlign*     = %lu;\n", (sizeof(rec2)==65) == (sizeof(rec0)==1), (long)(sizeof(rec2)-64));
  long x = 1;
  fprintf(fd, "  ByteOrder*   = %hhd;  BitOrder*     = %d;\n",  *(char*)&x, 0);

  fprintf(fd, "END Configuration.\n");

  fclose(fd);
}




int main()
{
  computeParameters();
  testPlatformSupport();
  mkdir(builddir, 0744);
  writeBasicTypeParameters();
  writeConfigurationMod();
  writeMakeParameters();
}
