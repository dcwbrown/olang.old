#ifndef SYSTEM__h
#define SYSTEM__h

#include <stdlib.h>  // For malloc, exit ...
#include <string.h>  // For memcpy ...



// The compiler uses 'import' and 'export' which translate to 'extern' and
// nothing repectively.

#define import extern
#define export



// Known constants

#define NIL          ((void*)0)
#define __MAXEXT     16
#define POINTER__typ ((LONGINT*)(1))  // not NIL and not a valid type


// Oberon types

#include <stdint.h>
#define BOOLEAN      char
#define SYSTEM_BYTE  unsigned char
#define CHAR         unsigned char
#define SHORTINT     signed char
#define INTEGER      int
#define REAL         float
#define LONGREAL     double
#define SYSTEM_INT8  int8_t
#define SYSTEM_INT16 int16_t
#define SYSTEM_INT32 int32_t
#define SYSTEM_INT64 int64_t
#define SYSTEM_PTR   void*

// Ensure LONGINT and SET are 64 bits even on 32 bit Windows.

#if ULONG_MAX != UINT_MAX
  #define LONGINT  long
#else
  #define LONGINT  long long
#endif

#define SET unsigned LONGINT

// Expose heap initialisation to main proram so it can
// be called in the correct order.

extern void Heap_InitHeap();
extern void *Heap__init();
extern void *Platform__init();



/* Run time system routines in SYSTEM.c */

extern LONGINT SYSTEM_XCHK   (LONGINT i, LONGINT ub);
extern LONGINT SYSTEM_RCHK   (LONGINT i, LONGINT ub);
extern LONGINT SYSTEM_ASH    (LONGINT i, LONGINT n);
extern LONGINT SYSTEM_ABS    (LONGINT i);
extern double  SYSTEM_ABSD   (double i);
extern void    SYSTEM_INHERIT(LONGINT *t, LONGINT *t0);
extern void    SYSTEM_ENUMP  (void *adr, LONGINT n, void (*P)());
extern void    SYSTEM_ENUMR  (void *adr, LONGINT *typ, LONGINT size, LONGINT n, void (*P)());
extern LONGINT SYSTEM_DIV    (unsigned LONGINT x, unsigned LONGINT y);
extern LONGINT SYSTEM_MOD    (unsigned LONGINT x, unsigned LONGINT y);
extern LONGINT SYSTEM_ENTIER (double x);



// String comparison

static int __STRCMP(CHAR *x, CHAR *y){
  LONGINT i = 0;
  CHAR ch1, ch2;
  do {ch1 = x[i]; ch2 = y[i]; i++;
    if (!ch1) return -(int)ch2;
  } while (ch1==ch2);
  return (int)ch1 - (int)ch2;
}



// Inline string, record and array copy

#define __COPY(s, d, n)	{char*_a=(void*)s,*_b=(void*)d; LONGINT _i=0,_t=n-1; while(_i<_t&&((_b[_i]=_a[_i])!=0)){_i++;};_b[_i]=0;}
#define __DUP(x, l, t)  x=(void*)memcpy(malloc(l*sizeof(t)),x,l*sizeof(t))
#define __DUPARR(v, t)	v=(void*)memcpy(v##__copy,v,sizeof(t))
#define __DEL(x)        free(x)



/* SYSTEM ops */

// #define __VAL(t, x)	    (*(t*)&(x))
#define __VAL(t, x)	    ((t)(x))

#define __GET(a, x, t)	x= *(t*)(a)
#define __PUT(a, x, t)	*(t*)(a)=x
#define __LSHL(x, n, t)	((t)((unsigned t)(x)<<(n)))
#define __LSHR(x, n, t)	((t)((unsigned t)(x)>>(n)))
#define __LSH(x, n, t)	((n)>=0? __LSHL(x, n, t): __LSHR(x, -(n), t))
#define __ROTL(x, n, t)	((t)((unsigned t)(x)<<(n)|(unsigned t)(x)>>(8*sizeof(t)-(n))))
#define __ROTR(x, n, t)	((t)((unsigned t)(x)>>(n)|(unsigned t)(x)<<(8*sizeof(t)-(n))))
#define __LSHR(x, n, t)	((t)((unsigned t)(x)>>(n)))
#define __LSH(x, n, t)	((n)>=0? __LSHL(x, n, t): __LSHR(x, -(n), t))
#define __ROTL(x, n, t)	((t)((unsigned t)(x)<<(n)|(unsigned t)(x)>>(8*sizeof(t)-(n))))
#define __ROTR(x, n, t)	((t)((unsigned t)(x)>>(n)|(unsigned t)(x)<<(8*sizeof(t)-(n))))
#define __ROT(x, n, t)	((n)>=0? __ROTL(x, n, t): __ROTR(x, -(n), t))
#define __BIT(x, n)	    (*(unsigned LONGINT*)(x)>>(n)&1)
#define __MOVE(s, d, n)	memcpy((char*)(d),(char*)(s),n)
#define __ASHL(x, n)	((LONGINT)(x)<<(n))
#define __ASHR(x, n)	((LONGINT)(x)>>(n))
#define __ASH(x, n)	    ((n)>=0?__ASHL(x,n):__ASHR(x,-(n)))
#define __ASHF(x, n)	SYSTEM_ASH((LONGINT)(x), (LONGINT)(n))
#define __SHORT(x, y)	((int)((unsigned LONGINT)(x)+(y)<(y)+(y)?(x):(__HALT(-8),0)))
#define __SHORTF(x, y)	((int)(__RF((x)+(y),(y)+(y))-(y)))
#define __CHR(x)	    ((CHAR)__R(x, 256))
#define __CHRF(x)	    ((CHAR)__RF(x, 256))
#define __DIV(x, y)	    ((x)>=0?(x)/(y):-(((y)-1-(x))/(y)))
#define __DIVF(x, y)	SYSTEM_DIV((LONGINT)(x),(LONGINT)(y))
#define __MOD(x, y)	    ((x)>=0?(x)%(y):__MODF(x,y))
#define __MODF(x, y)	SYSTEM_MOD((LONGINT)(x),(LONGINT)(y))
#define __ENTIER(x)	    SYSTEM_ENTIER(x)
#define __ABS(x)	    (((x)<0)?-(x):(x))
#define __ABSF(x)	    SYSTEM_ABS((LONGINT)(x))
#define __ABSFD(x)	    SYSTEM_ABSD((double)(x))
#define __CAP(ch)	    ((CHAR)((ch)&0x5f))
#define __ODD(x)	    ((x)&1)
#define __IN(x, s)	    (((s)>>(x))&1)
#define __SETOF(x)	    ((SET)1<<(x))
#define __SETRNG(l, h)	((~(SET)0<<(l))&~(SET)0>>(8*sizeof(SET)-1-(h)))
#define __MASK(x, m)	((x)&~(m))



// Runtime checks

#define __X(i, ub)	 (((unsigned LONGINT)(i)<(unsigned LONGINT)(ub))?i:(__HALT(-2),0))
#define __XF(i, ub)	 SYSTEM_XCHK((LONGINT)(i), (LONGINT)(ub))
#define __R(i, ub)	 (((unsigned LONGINT)(i)<(unsigned LONGINT)(ub))?i:(__HALT(-8),0))
#define __RF(i, ub)	 SYSTEM_RCHK((LONGINT)(i),(LONGINT)(ub))
#define __RETCHK	 __retchk: __HALT(-3); return 0;
#define __CASECHK	 __HALT(-4)
#define __WITHCHK	 __HALT(-7)

#define __GUARDP(p, typ, level)	   ((typ*)(__ISP(p,typ,level)?p:(__HALT(-5),p)))
#define __GUARDR(r, typ, level)	   (*((typ*)(__IS(r##__typ,typ,level)?r:(__HALT(-5),r))))
#define __GUARDA(p, typ, level)	   ((struct typ*)(__IS(__TYPEOF(p),typ,level)?p:(__HALT(-5),p)))
#define __GUARDEQR(p, dyntyp, typ) if(dyntyp!=typ##__typ) __HALT(-6);*(p)
#define __GUARDEQP(p, typ)	       if(__TYPEOF(p)!=typ##__typ)__HALT(-6);*(p)



// Module entry/registration/exit

extern void       Heap_REGCMD();
extern SYSTEM_PTR Heap_REGMOD();
extern void       Heap_REGTYP();
extern void       Heap_INCREF();

#define __DEFMOD	          static void *m; if (m!=0) {return m;}
#define __REGCMD(name, cmd)	  Heap_REGCMD(m, name, cmd)
#define __REGMOD(name, enum)  if (m==0) {m = Heap_REGMOD((CHAR*)name,enum);}
#define __ENDMOD	          return m
#define __MODULE_IMPORT(name) Heap_INCREF(name##__init())



// Main module initialisation, registration and finalisation

extern void Platform_Init(INTEGER argc, LONGINT argv);
extern void *Platform_MainModule;
extern void Heap_FINALL();

#define __INIT(argc, argv)    static void *m; Platform_Init((INTEGER)argc, (LONGINT)&argv);
#define __REGMAIN(name, enum) m = Heap_REGMOD((CHAR*)name,enum)
#define __FINI	              Heap_FINALL(); return 0


// Assertions and Halts

extern void Platform_Halt(LONGINT x);
extern void Platform_AssertFail(LONGINT x);

#define __HALT(x)	      Platform_Halt(x)
#define __ASSERT(cond, x) if (!(cond)) Platform_AssertFail((LONGINT)(x))


// Memory allocation

extern SYSTEM_PTR Heap_NEWBLK (LONGINT size);
extern SYSTEM_PTR Heap_NEWREC (LONGINT tag);
extern SYSTEM_PTR SYSTEM_NEWARR(LONGINT*, LONGINT, int, int, int, ...);

#define __SYSNEW(p, len) p = Heap_NEWBLK((LONGINT)(len))
#define __NEW(p, t)	     p = Heap_NEWREC((LONGINT)t##__typ)
#define __NEWARR	     SYSTEM_NEWARR



/* Type handling */

#define __TDESC(t, m, n)                                                 \
	static struct t##__desc {                                            \
		LONGINT  tproc[m];         /* Proc for each ptr field     */     \
		LONGINT  tag;                                                    \
		LONGINT  next;                                                   \
		LONGINT  level;                                                  \
		LONGINT  module;                                                 \
		char     name[24];                                               \
		LONGINT  basep[__MAXEXT];  /* List of bases this extends  */     \
		LONGINT  reserved;                                               \
		LONGINT  blksz;                                                  \
		LONGINT  ptr[n+1];         /* Offsets of ptrs + sentinel  */     \
	} t##__desc

#define __BASEOFF	(__MAXEXT+1)                           // blksz as index to base.
#define __TPROC0OFF	(__BASEOFF+24/sizeof(LONGINT)+5)       // blksz as index to tproc IFF m=1.
#define __EOM	1
#define __TDFLDS(name, size)	      {__EOM}, 1, 0, 0, 0, name, {0}, 0, size
#define __ENUMP(adr, n, P)	          SYSTEM_ENUMP(adr, (LONGINT)(n), P)
#define __ENUMR(adr, typ, size, n, P) SYSTEM_ENUMR(adr, typ, (LONGINT)(size), (LONGINT)(n), P)

#define __INITYP(t, t0, level) \
	t##__typ               = (LONGINT*)&t##__desc.blksz;                                                    \
	memcpy(t##__desc.basep, t0##__typ - __BASEOFF, level*sizeof(LONGINT));                                  \
	t##__desc.basep[level] = (LONGINT)t##__typ;                                                             \
	t##__desc.module       = (LONGINT)m;                                                                    \
	if(t##__desc.blksz!=sizeof(struct t)) __HALT(-15);                                                      \
	t##__desc.blksz        = (t##__desc.blksz+5*sizeof(LONGINT)-1)/(4*sizeof(LONGINT))*(4*sizeof(LONGINT)); \
	Heap_REGTYP(m, (LONGINT)&t##__desc.next);                                                               \
	SYSTEM_INHERIT(t##__typ, t0##__typ)

#define __IS(tag, typ, level)	(*(tag-(__BASEOFF-level))==(LONGINT)typ##__typ)
#define __TYPEOF(p)	            ((LONGINT*)(*(((LONGINT*)(p))-1)))
#define __ISP(p, typ, level)	__IS(__TYPEOF(p),typ,level)

// Oberon-2 type bound procedures support
#define __INITBP(t, proc, num)	*(t##__typ-(__TPROC0OFF+num))=(LONGINT)proc
#define __SEND(typ, num, funtyp, parlist)	((funtyp)(*(typ-(__TPROC0OFF+num))))parlist



#endif


//
//
//
//  #include <alloca.h>
//  #include <stdint.h> /* for type sizes -- noch */
//  #include <unistd.h>
//  #include <sys/time.h>
//  #include <signal.h>
//  #include <fcntl.h>
//  #include <stdio.h>
//  #include <signal.h>
//  #include <stdlib.h>
//  #include <sys/ioctl.h>
//
//
//
//
//
//
//
//
//  extern void *memcpy(void *dest, const void *src, unsigned LONGINT n);
//  extern void *malloc(size_t size);
//  extern void exit(int status);
//
//  /* constants */
//
//  /* basic types */
//
//  //extern void SYSTEM_GC (BOOLEAN markStack);
//
//
//
//
//
//
//  /* std procs and operator mappings */
//  static int __STRCMP(x, y)
//  	CHAR *x, *y;
//  {LONGINT i = 0; CHAR ch1, ch2;
//  	do {ch1 = x[i]; ch2 = y[i]; i++;
//  		if (!ch1) return -(int)ch2;
//  	} while (ch1==ch2);
//  	return (int)ch1 - (int)ch2;
//  }
//  // commented out to use malloc -- noch
//  //#define __DUP(x, l, t)	x=(void*)memcpy(alloca(l*sizeof(t)),x,l*sizeof(t))
//  //#define __DEL(x)	/* DUP with alloca frees storage automatically */
//
//
//
//  /* Oberon-2 type bound procedures support */
//  #define __INITBP(t, proc, num)	*(t##__typ-(__TPROC0OFF+num))=(long)proc
//  #define __SEND(typ, num, funtyp, parlist)	((funtyp)(*(typ-(__TPROC0OFF+num))))parlist
//
//  /* runtime system variables */
//  extern LONGINT SYSTEM_argc;
//  extern LONGINT SYSTEM_argv;
//  extern void (*SYSTEM_Halt)();
//  extern LONGINT SYSTEM_halt;
//  extern LONGINT SYSTEM_assert;
//  extern SYSTEM_PTR SYSTEM_modules;
//  extern LONGINT SYSTEM_heapsize;
//  extern LONGINT SYSTEM_allocated;
//  extern LONGINT SYSTEM_lock;
//  extern SHORTINT SYSTEM_gclock;
//  extern BOOLEAN SYSTEM_interrupted;
//
//  /* ANSI prototypes; not used so far
//  static int __STRCMP(CHAR *x, CHAR *y);
//  void SYSTEM_INIT(int argc, long argvadr);
//  void SYSTEM_FINI(void);
//  long SYSTEM_XCHK(long i, long ub);
//  long SYSTEM_RCHK(long i, long ub);
//  long SYSTEM_ASH(long i, long n);
//  long SYSTEM_ABS(long i);
//  double SYSTEM_ABSD(double i);
//  void SYSTEM_INHERIT(long *t, long *t0);
//  void SYSTEM_ENUMP(long *adr, long n, void (*P)(void*));
//  void SYSTEM_ENUMR(char *adr, long *typ, long size, long n, void (*P)(void*));
//  long SYSTEM_ENTIER(double x);
//  void SYSTEM_HALT(int n);
//  */
//
//
//