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



#ifndef O_VER
#define O_VER local
#endif

#define macrotostringhelper(s) #s
#define macrotostring(s) macrotostringhelper(s)



void fail(char *msg) {printf("Error: %s\n", msg); exit(1);}
void assert(int truth, char *complaint) {if (!truth) fail(complaint);}



char builddate[256];
//char olangname[256];
//char builddir[256];
//char flavour[256];
//char prefix[256];
char installdir[256];
char versionstring[256];

char* version    = macrotostring(O_VER);

char* dataModel   = NULL;
char* sizeAlign   = NULL;
char* compiler    = NULL;
char* cc          = NULL;
char* os          = NULL;
char* platform    = NULL;
char* binext      = NULL;
char* staticlink  = NULL;  // Static compilation option - though disabled on darwin.
int   alignment   = 0;
int   addressSize = 0;





void determineOS() {
  #ifdef _WIN32
    os = "windows";  platform = "windows";  binext = ".exe"; staticlink = "";
  #else
    os = "unknown";  platform = "unix";     binext = "";     staticlink = "-static";

    struct utsname sys;
    if (uname(&sys)<0) fail("Couldn't get sys name - uname() failed.");
  
    if      (strncasecmp(sys.sysname, "cygwin",  6) == 0) {os = "cygwin";  binext = ".exe";}
    else if (strncasecmp(sys.sysname, "linux",   5) == 0) {os = "linux";}
    else if (strncasecmp(sys.sysname, "freebsd", 5) == 0) {os = "freebsd";}
    else if (strncasecmp(sys.sysname, "openbsd", 5) == 0) {os = "openbsd";}
    else if (strncasecmp(sys.sysname, "darwin",  5) == 0) {os = "darwin";  staticlink = "";}
    else {
      printf("sysname: '%s'\n", sys.sysname);
      fail("Unrecognised OS architecture name (sysname) returned by uname.");
    }
  #endif
}


void determineCCompiler() {
  #if defined(__MINGW32__)
    compiler = "mingw";
    if (sizeof (void*) == 4) {
      cc = "i686-w64-mingw32-gcc -g"; 
    } else {
      cc = "x86_64-w64-mingw32-gcc -g";
    }
  #elif defined(__clang__)
    compiler = "clang";
    cc       = "clang -fPIC -g";
  #elif defined(__GNUC__)
    compiler = "gcc";
    cc       = "gcc -g";
  #elif defined(_MSC_VER)
    compiler = "msc";
    cc       = "cl /nologo";
  #else
    fail("Unrecognised C compiler.");
  #endif
}



void determineInstallDirectory() {
  #if defined(_MSC_VER)  
    #ifdef _WIN64
      sprintf(installdir, "%s\\olang", getenv("ProgramFiles"));
    #else
      sprintf(installdir, "%s\\olang", getenv("ProgramFiles(x86)"));
    #endif
  #else
    sprintf(installdir, "/opt/olang");
  #endif
}



void determineBuildDate() {
  time_t t = time(0);
  strftime(builddate, sizeof(builddate), "%Y/%m/%d", localtime(&t));
}



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

struct {CHAR ch;}    rec0;
struct {CHAR x[65];} rec2;


void determineCDataModel() {
  addressSize = sizeof(void*);
  alignment = (char*)&li.x - (char*)&li; 

  // Check type sizes. By design these are fixed across all supported platfroms.

  assert(sizeof(CHAR)     == 1, "Size of CHAR not 1.");
  assert(sizeof(BOOLEAN)  == 1, "Size of BOOLEAN not 1.");
  assert(sizeof(SHORTINT) == 1, "Size of SHORTINT not 1.");
  assert(sizeof(INTEGER)  == 4, "Size of INTEGER not 4 bytes.");
  assert(sizeof(LONGINT)  == 8, "Size of LONGINT not 8 bytes.");
  assert(sizeof(SET)      == 8, "Size of SET not 8 bytes.");
  assert(sizeof(REAL)     == 4, "Size of REAL not 4 bytes.");
  assert(sizeof(LONGREAL) == 8, "Size of LONGREAL not 8 bytes.");
  assert(sizeof(f.x) == sizeof(p.x), "Size of function pointer differs from size of data pointer.");

  assert((alignment == 4) || (alignment == 8), "Alignment of LONGINT neither 4 nor 8 bytes.");

  assert(((char*)&c.x  - (char*)&c) == 1, "Alignment of CHAR not 1.");
  assert(((char*)&b.x  - (char*)&b) == 1, "Alignment of BOOLEAN not 1.");
  assert(((char*)&si.x - (char*)&si) == 1, "Alignment of SHORTINT not 1.");
  assert(((char*)&i.x  - (char*)&i) == 4, "Alignment of INTEGER not 4 bytes.");
  assert(((char*)&r.x  - (char*)&r) == 4, "Alignment of REAL not 4 bytes.");
  assert(((char*)&lr.x - (char*)&lr) == alignment, "Alignment of LONGREAL differs from alignment of LONGINT.");
  assert(((char*)&s.x  - (char*)&s) == alignment, "Alignment of SET differs from alignmnet of LONGINT.");
  assert(((char*)&p.x  - (char*)&p) == addressSize, "Alignment of data pointer differs from address size.");
  assert(((char*)&f.x  - (char*)&f) == addressSize, "Alignment of data pointer differs from address size.");

  assert(sizeof(rec0) ==  1, "CHAR wrapped in record aligns differently to CHAR alone.");
  assert(sizeof(rec2) == 65, "CHAR array wrapped in record aligns differently to CHAR array alone.");

  assert(sizeof(LONGINT) >= sizeof p.x, "LONGINT should have at least the same size as data pointers.");
  assert(sizeof(LONGINT) >= sizeof f.x, "LONGINT should have at least the same size as function pointers.");

  if (((sizeof(rec2)==65) == (sizeof(rec0)==1)) && ((sizeof(rec2)-64) != sizeof(rec0)))
    printf("error: unsupported record layout  sizeof(rec0) = %lu  sizeof(rec2) = %lu\n", (long)sizeof(rec0), (long)sizeof(rec2));

  long x = 1;
  assert(*(char*)&x == 1, "C compiler does not store multibyte numeric values in little-endian order.");

  // Now we know type sizes are as expected, generate C memory model parameters

  if      (addressSize == 4  &&  sizeof(int)  == 4) dataModel = "ILP32";  // Unix/Linux and modern Windows
  else if (addressSize == 8  &&  sizeof(long) == 4) dataModel = "LLP64";  // Windows/mingw 64 bit
  else if (addressSize == 8  &&  sizeof(long) == 8) dataModel = "LP64";   // Unix/Linux 64 bit
  else fail("Unsupported combination of address size and int/long size.");

  if      (addressSize == 4  &&  alignment == 4) sizeAlign = "44";
  else if (addressSize == 4  &&  alignment == 8) sizeAlign = "48";
  else if (addressSize == 8  &&  alignment == 8) sizeAlign = "88";
  else fail("Unsupported combination of address size and LONGINT alignment.");
}





// Determination of basic type parameters - size, alignment and endianness.

// void writeBasicTypeParameters() {
//   FILE *fd = fopen("BasicTypeParameters", "w");
//   if (fd == NULL) fail("Couldn't create BasicTypeParameters.");
// 
//   /* get size and alignment of standard types */
//   fprintf(fd, "CHAR %lu %lu\n",         (long)sizeof(CHAR),         (long)((char*)&c.x  - (char*)&c));
//   fprintf(fd, "BOOLEAN %lu %lu\n",      (long)sizeof(BOOLEAN),      (long)((char*)&b.x  - (char*)&b));
//   fprintf(fd, "SHORTINT %lu %lu\n",     (long)sizeof(SHORTINT),     (long)((char*)&si.x - (char*)&si));
//   fprintf(fd, "INTEGER %lu %lu\n",      (long)sizeof(INTEGER),      (long)((char*)&i.x  - (char*)&i));
//   fprintf(fd, "LONGINT %lu %lu\n",      (long)sizeof(LONGINT),      (long)((char*)&li.x - (char*)&li));
//   fprintf(fd, "SET %lu %lu\n",          (long)sizeof(SET),          (long)((char*)&s.x  - (char*)&s));
//   fprintf(fd, "REAL %lu %lu\n",         (long)sizeof(REAL),         (long)((char*)&r.x  - (char*)&r));
//   fprintf(fd, "LONGREAL %lu %lu\n",     (long)sizeof(LONGREAL),     (long)((char*)&lr.x - (char*)&lr));
//   fprintf(fd, "PTR %lu %lu\n",          (long)sizeof(p.x),          (long)((char*)&p.x  - (char*)&p));
//   fprintf(fd, "PROC %lu %lu\n",         (long)sizeof(f.x),          (long)((char*)&f.x  - (char*)&f));
//   fprintf(fd, "RECORD %d %lu\n",        (sizeof(rec2)==65) == (sizeof(rec0)==1), (long)(sizeof(rec2)-64));
//   long x = 1;
//   fprintf(fd, "ENDIAN %hhd %d\n",       *(char*)&x, 0);
// 
//   fclose(fd);
// }




void testSystemH() {
  /* test the __ASHR macro */
  assert(__ASHR(-1, 1) == -1, "ASH(-1, -1) # -1.");
  assert(__ASHR(-2, 1) == -1, "ASH(-2, -1) # -1.");
  assert(__ASHR(0, 1)  ==  0, "ASH(0, 1) #  0.");
  assert(__ASHR(1, 1)  ==  0, "ASH(1, 1) #  0.");
  assert(__ASHR(2, 1)  ==  1, "ASH(2, 1) #  1.");

  /* test the __SETRNG macro */
  long x = 0;
  long y = sizeof(SET)*8 - 1;
  assert(__SETRNG(x, y) == -1, "SETRNG(0, MAX(SET)) != -1.");

  /* test string comparison for extended ascii */
  {char a[10], b[10];
    a[0] = (CHAR)128; a[1] = 0;
    b[0] = 0;
    assert(__STRCMP(a, b) >= 0, "__STRCMP(a, b) with extended ascii charcters; should be unsigned.");
  }
}




void writeMakeParameters() {
  FILE *fd = fopen("Configuration.Make", "w");
  if (fd == NULL) fail("Couldn't create build.make.");
  fprintf(fd, "COMPILER=%s\n",   compiler);
  fprintf(fd, "OS=%s\n",         os);
  fprintf(fd, "VERSION=%s\n",    version);
  fprintf(fd, "DATAMODEL=%s\n",  dataModel);
  fprintf(fd, "SIZEALIGN=%s\n",  sizeAlign);
  fprintf(fd, "INSTALLDIR=%s\n", installdir);
  fprintf(fd, "PLATFORM=%s\n",   platform);
  fprintf(fd, "BINEXT=%s\n",     binext);
  fprintf(fd, "COMPILE=%s\n",    cc);
  fprintf(fd, "STATICLINK=%s\n", staticlink);
//fprintf(fd, "BUILDDATE=%s\n",  builddate);
//fprintf(fd, "FLAVOUR=%s\n",    flavour);
//fprintf(fd, "PREFIX=%s\n",     prefix);
//fprintf(fd, "BUILDDIR=%s\n",   builddir);
//fprintf(fd, "OLANGNAME=%s\n",  olangname);
  fclose(fd);
}




//void displayParameters() {
//  printf("\n");
//  printf("C compiler command:  %s\n", cc);
//  printf("Build subdirectory:  %s\n", builddir);
//  printf("Version string:      %s\n", versionstring);
//}




void writeConfigurationMod() {
  FILE *fd = fopen("Configuration.Mod", "w");
  if (fd == NULL) fail("Couldn't create Configuration.Mod.");

  fprintf(fd, "MODULE Configuration;\n");
  fprintf(fd, "CONST\n");
  fprintf(fd, "  versionLong* = '%s';\n", versionstring);
  fprintf(fd, "  addressSize* = %d;\n",   addressSize);
  fprintf(fd, "  alignment*   = %d;\n",   alignment);
  fprintf(fd, "  compiler*    = '%s';\n", compiler);
  fprintf(fd, "  compile*     = '%s';\n", cc);
  fprintf(fd, "  dataModel*   = '%s';\n", dataModel);
//fprintf(fd, "  os*          = '%s';\n", os);
  fprintf(fd, "  prefix*      = '%s-%s';\n", installdir, version);
//fprintf(fd, "  buildDate*   = '%s';\n", builddate);
//fprintf(fd, "  version*     = '%s';\n", version);
  fprintf(fd, "  staticLink*  = '%s';\n", staticlink); 

  //fprintf(fd, "  CharSize*    = %1lu;  CharAlign*    = %lu;\n", (long)sizeof(CHAR),         (long)((char*)&c.x  - (char*)&c));
  //fprintf(fd, "  BoolSize*    = %1lu;  BoolAlign*    = %lu;\n", (long)sizeof(BOOLEAN),      (long)((char*)&b.x  - (char*)&b));
  //fprintf(fd, "  SIntSize*    = %1lu;  SIntAlign*    = %lu;\n", (long)sizeof(SHORTINT),     (long)((char*)&si.x - (char*)&si));
  //fprintf(fd, "  IntSize*     = %1lu;  IntAlign*     = %lu;\n", (long)sizeof(INTEGER),      (long)((char*)&i.x  - (char*)&i));
  //fprintf(fd, "  LIntSize*    = %1lu;  LIntAlign*    = %lu;\n", (long)sizeof(LONGINT),      (long)((char*)&li.x - (char*)&li));
  //fprintf(fd, "  SetSize*     = %1lu;  SetAlign*     = %lu;\n", (long)sizeof(SET),          (long)((char*)&s.x  - (char*)&s));
  //fprintf(fd, "  RealSize*    = %1lu;  RealAlign*    = %lu;\n", (long)sizeof(REAL),         (long)((char*)&r.x  - (char*)&r));
  //fprintf(fd, "  LRealSize*   = %1lu;  LRealAlign*   = %lu;\n", (long)sizeof(LONGREAL),     (long)((char*)&lr.x - (char*)&lr));
  //fprintf(fd, "  PointerSize* = %1lu;  PointerAlign* = %lu;\n", (long)sizeof(p.x),          (long)((char*)&p.x  - (char*)&p));
  //fprintf(fd, "  ProcSize*    = %1lu;  ProcAlign*    = %lu;\n", (long)sizeof(f.x),          (long)((char*)&f.x  - (char*)&f));
  //fprintf(fd, "  RecSize*     = %01d;  RecAlign*     = %lu;\n", (sizeof(rec2)==65) == (sizeof(rec0)==1), (long)(sizeof(rec2)-64));
  //long x = 1;
  //fprintf(fd, "  ByteOrder*   = %hhd;  BitOrder*     = %d;\n",  *(char*)&x, 0);

  fprintf(fd, "END Configuration.\n");

  fclose(fd);
}




int main()
{
  determineOS();
  determineCCompiler();
  determineCDataModel();
  determineBuildDate();
  determineInstallDirectory();

  testSystemH();

  //sprintf(flavour,       "%s.%s.%s",   compiler, os, dataModel);
  //sprintf(builddir,      "build.%s",   flavour);
  //sprintf(olangname,     "olang.%s%s", flavour, binext);
  //sprintf(prefix,        "%s-%s",      installdir, version);
  sprintf(versionstring, "Oberon compiler olang %s [%s] for %s %s using %s",
                         version, builddate, os, dataModel, compiler);
  //mkdir(builddir, 0744);

  //writeBasicTypeParameters();
  writeConfigurationMod();
  writeMakeParameters();
  //displayParameters();
}
