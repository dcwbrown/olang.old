MODULE Platform;
IMPORT SYSTEM;



CONST
  TimeUnit* = 1000;

  SUCCESS         = 0;      (* Cross platform success code *)

  EPERM           = 1;      (* Not owner *)
  ENOENT          = 2;      (* No such file or directory *)
  ESRCH           = 3;      (* No such process *)
  EINTR           = 4;      (* Interrupted system call *)
  EIO             = 5;      (* I/O error *)
  ENXIO           = 6;      (* No such device or address *)
  E2BIG           = 7;      (* Arg list too long *)
  ENOEXEC         = 8;      (* Exec format error *)
  EBADF           = 9;      (* Bad file number *)
  ECHILD          = 10;     (* No children *)
  EAGAIN          = 11;     (* No more processes *)
  ENOMEM          = 12;     (* Not enough core *)
  EACCES          = 13;     (* Permission denied *)
  EFAULT          = 14;     (* Bad address *)
  ENOTBLK         = 15;     (* Block device required *)
  EBUSY           = 16;     (* Mount device busy *)
  EEXIST          = 17;     (* File exists *)
  EXDEV           = 18;     (* Cross-device link *)
  ENODEV          = 19;     (* No such device *)
  ENOTDIR         = 20;     (* Not a directory*)
  EISDIR          = 21;     (* Is a directory *)
  EINVAL          = 22;     (* Invalid argument *)
  ENFILE          = 23;     (* File table overflow *)
  EMFILE          = 24;     (* Too many open files *)
  ENOTTY          = 25;     (* Not a typewriter *)
  ETXTBSY         = 26;     (* Text file busy *)
  EFBIG           = 27;     (* File too large *)
  ENOSPC          = 28;     (* No space left on device *)
  ESPIPE          = 29;     (* Illegal seek *)
  EROFS           = 30;     (* Read-only file system *)
  EMLINK          = 31;     (* Too many links *)
  EPIPE           = 32;     (* Broken pipe *)
  EDOM            = 33;     (* Argument too large *)
  ERANGE          = 34;     (* Result too large *)
  EDEADLK         = 35;     (* Resource deadlock would occur *)
  ENAMETOOLONG    = 36;     (* File name too long *)
  ENOLCK          = 37;     (* No record locks available *)
  ENOSYS          = 38;     (* Function not implemented *)
  ENOTEMPTY       = 39;     (* Directory not empty *)
  ELOOP           = 40;     (* Too many symbolic links encountered *)
  EWOULDBLOCK     = EAGAIN; (* Operation would block *)
  ENOMSG          = 42;     (* No message of desired type *)
  EIDRM           = 43;     (* Identifier removed *)
  ECHRNG          = 44;     (* Channel number out of range *)
  EL2NSYNC        = 45;     (* Level 2 not synchronized *)
  EL3HLT          = 46;     (* Level 3 halted *)
  EL3RST          = 47;     (* Level 3 reset *)
  ELNRNG          = 48;     (* Link number out of range *)
  EUNATCH         = 49;     (* Protocol driver not attached *)
  ENOCSI          = 50;     (* No CSI structure available *)
  EL2HLT          = 51;     (* Level 2 halted *)
  EBADE           = 52;     (* Invalid exchange *)
  EBADR           = 53;     (* Invalid request descriptor *)
  EXFULL          = 54;     (* Exchange full *)
  ENOANO          = 55;     (* No anode *)
  EBADRQC         = 56;     (* Invalid request code *)
  EBADSLT         = 57;     (* Invalid slot *)
  EDEADLOCK       = 58;     (* File locking deadlock error *)
  EBFONT          = 59;     (* Bad font file format *)
  ENOSTR          = 60;     (* Device not a stream *)
  ENODATA         = 61;     (* No data available *)
  ETIME           = 62;     (* Timer expired *)
  ENOSR           = 63;     (* Out of streams resources *)
  ENONET          = 64;     (* Machine is not on the network *)
  ENOPKG          = 65;     (* Package not installed *)
  EREMOTE         = 66;     (* Object is remote *)
  ENOLINK         = 67;     (* Link has been severed *)
  EADV            = 68;     (* Advertise error *)
  ESRMNT          = 69;     (* Srmount error *)
  ECOMM           = 70;     (* Communication error on send *)
  EPROTO          = 71;     (* Protocol error *)
  EMULTIHOP       = 72;     (* Multihop attempted *)
  EDOTDOT         = 73;     (* RFS specific error *)
  EBADMSG         = 74;     (* Not a data message *)
  EOVERFLOW       = 75;     (* Value too large for defined data type *)
  ENOTUNIQ        = 76;     (* Name not unique on network *)
  EBADFD          = 77;     (* File descriptor in bad state *)
  EREMCHG         = 78;     (* Remote address changed *)
  ELIBACC         = 79;     (* Can not access a needed shared library *)
  ELIBBAD         = 80;     (* Accessing a corrupted shared library *)
  ELIBSCN         = 81;     (* .lib section in a.out corrupted *)
  ELIBMAX         = 82;     (* Attempting to link in too many shared libraries *)
  ELIBEXEC        = 83;     (* Cannot exec a shared library directly *)
  EILSEQ          = 84;     (* Illegal byte sequence *)
  ERESTART        = 85;     (* Interrupted system call should be restarted *)
  ESTRPIPE        = 86;     (* Streams pipe error *)
  EUSERS          = 87;     (* Too many users *)
  ENOTSOCK        = 88;     (* Socket operation on non-socket *)
  EDESTADDRREQ    = 89;     (* Destination address required *)
  EMSGSIZE        = 90;     (* Message too long *)
  EPROTOTYPE      = 91;     (* Protocol wrong type for socket *)
  ENOPROTOOPT     = 92;     (* Protocol not available *)
  EPROTONOSUPPORT = 93;     (* Protocol not supported *)
  ESOCKTNOSUPPORT = 94;     (* Socket type not supported *)
  EOPNOTSUPP      = 95;     (* Operation not supported on transport endpoint *)
  EPFNOSUPPORT    = 96;     (* Protocol family not supported *)
  EAFNOSUPPORT    = 97;     (* Address family not supported by protocol *)
  EADDRINUSE      = 98;     (* Address already in use *)
  EADDRNOTAVAIL   = 99;     (* Cannot assign requested address *)
  ENETDOWN        = 100;    (* Network is down *)
  ENETUNREACH     = 101;    (* Network is unreachable *)
  ENETRESET       = 102;    (* Network dropped connection because of reset *)
  ECONNABORTED    = 103;    (* Software caused connection abort *)
  ECONNRESET      = 104;    (* Connection reset by peer *)
  ENOBUFS         = 105;    (* No buffer space available *)
  EISCONN         = 106;    (* Transport endpoint is already connected *)
  ENOTCONN        = 107;    (* Transport endpoint is not connected *)
  ESHUTDOWN       = 108;    (* Cannot send after transport endpoint shutdown *)
  ETOOMANYREFS    = 109;    (* Too many references: cannot splice *)
  ETIMEDOUT       = 110;    (* Connection timed out *)
  ECONNREFUSED    = 111;    (* Connection refused *)
  EHOSTDOWN       = 112;    (* Host is down *)
  EHOSTUNREACH    = 113;    (* No route to host *)
  EALREADY        = 114;    (* Operation already in progress *)
  EINPROGRESS     = 115;    (* Operation now in progress *)
  ESTALE          = 116;    (* Stale NFS file handle *)
  EUCLEAN         = 117;    (* Structure needs cleaning *)
  ENOTNAM         = 118;    (* Not a XENIX named type file *)
  ENAVAIL         = 119;    (* No XENIX semaphores available *)
  EISNAM          = 120;    (* Is a named type file *)
  EREMOTEIO       = 121;    (* Remote I/O error *)
  EDQUOT          = 122;    (* Quota exceeded *)



TYPE
  FileHandle* = LONGINT;

  FileIdentity* = RECORD
    volume*: LONGINT;  (* dev on Unix filesystems, volume serial number on NTFS *)
    index*:  LONGINT;  (* inode on Unix filesystems, file id on NTFS *)
    mtime*:  LONGINT;  (* File modification time, value is system dependent *)
  END;

  ErrorCode*  = INTEGER;

  HaltProcedure = PROCEDURE(n: LONGINT);

  EnvPtr = POINTER TO ARRAY 1024 OF CHAR;

  SignalHandler = PROCEDURE(signal: INTEGER);

  TYPE
    ArgPtr    = POINTER TO ARRAY 1024 OF CHAR;
    ArgVec    = POINTER TO ARRAY 1024 OF ArgPtr;
    ArgVecPtr = POINTER TO ARRAY 1 OF LONGINT;


VAR
  LittleEndian-:   BOOLEAN;
  MainStackFrame-: LONGINT;
  HaltCode-:       LONGINT;
  AssertCode-:     LONGINT;
  PID-:            INTEGER;    (* Note: Must be updated by Fork implementation *)
  CWD-:            ARRAY 256 OF CHAR;
  ArgCount-:       INTEGER;
  (*
    MODULES-:        ARRAY 1024 OF CHAR;
    OBERON-:         ARRAY 1024 OF CHAR;
    LIB-:            ARRAY 1024 OF CHAR;
    HOME-:           ARRAY 1024 OF CHAR;
  *)

  HaltHandler:     HaltProcedure;
  ArgVector:       LONGINT;
  TimeStart:       LONGINT;

PROCEDURE -Aincludesystime  '#include <sys/time.h>';  (* for gettimeofday *)
PROCEDURE -Aincludetime     '#include <time.h>';      (* for localtime *)
PROCEDURE -Aincludesystypes '#include <sys/types.h>';
PROCEDURE -Aincludesignal   '#include <signal.h>';
PROCEDURE -Aincludeunistd   '#include <unistd.h>';
PROCEDURE -Aincludesysstat  '#include <sys/stat.h>';
PROCEDURE -Aincludefcntl    '#include <fcntl.h>';
PROCEDURE -Aincludeerrno    '#include <errno.h>';
PROCEDURE -Astdlib          '#include <stdlib.h>';
PROCEDURE -Astdio           '#include <stdio.h>';




(* Error code tests *)

PROCEDURE TooManyFiles*(e: ErrorCode): BOOLEAN;
BEGIN RETURN (e = EMFILE) OR (e = ENFILE) END TooManyFiles;

PROCEDURE NoSuchDirectory*(e: ErrorCode): BOOLEAN;
BEGIN RETURN e = ENOENT END NoSuchDirectory;

PROCEDURE DifferentFilesystems*(e: ErrorCode): BOOLEAN;
BEGIN RETURN e = EXDEV END DifferentFilesystems;

PROCEDURE Inaccessible*(e: ErrorCode): BOOLEAN;
BEGIN RETURN (e = EACCES) OR (e = EROFS) OR (e = EAGAIN) END Inaccessible;

PROCEDURE Absent*(e: ErrorCode): BOOLEAN;
BEGIN RETURN (e = ENOENT) END Absent;




(* Program startup *)

PROCEDURE -HeapInitHeap()       "Heap_InitHeap()";
PROCEDURE -HeapModuleInit()     "Heap__init()";
PROCEDURE -PlatformModuleInit() "Platform__init()";

PROCEDURE Init*(argc: INTEGER; argvadr: LONGINT);
VAR  av: ArgVecPtr;
BEGIN
  MainStackFrame := argvadr;
  ArgCount       := argc;
  av             := SYSTEM.VAL(ArgVecPtr, argvadr);
  ArgVector      := av[0];
  HaltCode       := -128;

  (* This function (Platform.Init) is called at program startup BEFORE any
     modules have been initalised. In turn we must initialise first the heap
     itself, then the rest of the heap module. *)
  HeapInitHeap();
  PlatformModuleInit();
  HeapModuleInit();
END Init;




(* Program arguments and environmet access *)

PROCEDURE -getenv(var: ARRAY OF CHAR): EnvPtr "(Platform_EnvPtr)getenv(var)";

PROCEDURE GetEnv*(var: ARRAY OF CHAR; VAR val: ARRAY OF CHAR);
  VAR p: EnvPtr;
BEGIN
  p := getenv(var);
  IF p # NIL THEN COPY(p^, val) END;
END GetEnv;

PROCEDURE GetArg*(n: INTEGER; VAR val: ARRAY OF CHAR);
  VAR av: ArgVec;
BEGIN
  IF n < ArgCount THEN
    av := SYSTEM.VAL(ArgVec,ArgVector);
    (*
      c.String("  n: "); c.Int(n,1);
      c.String(", argv[0]: "); c.Hex(SYSTEM.VAL(LONGINT,(av[0])));
      c.String(", argv[1]: "); c.Hex(SYSTEM.VAL(LONGINT,(av[1])));
      c.String(", argv[2]: "); c.Hex(SYSTEM.VAL(LONGINT,(av[2])));
      c.Ln;
    *)
    COPY(av[n]^, val)
  END
END GetArg;

PROCEDURE GetIntArg*(n: INTEGER; VAR val: LONGINT);
  VAR s: ARRAY 64 OF CHAR; k, d, i: LONGINT;
BEGIN
  s := ""; GetArg(n, s); i := 0;
  IF s[0] = "-" THEN i := 1 END ;
  k := 0; d := ORD(s[i]) - ORD("0");
  WHILE (d >= 0 ) & (d <= 9) DO k := k*10 + d; INC(i); d := ORD(s[i]) - ORD("0") END ;
  IF s[0] = "-" THEN d := -d; DEC(i) END ;
  IF i > 0 THEN val := k END
END GetIntArg;

PROCEDURE ArgPos*(s: ARRAY OF CHAR): INTEGER;
  VAR i: INTEGER; arg: ARRAY 256 OF CHAR;
BEGIN
  i := 0; GetArg(i, arg);
  WHILE (i < ArgCount) & (s # arg) DO INC(i); GetArg(i, arg) END ;
  RETURN i
END ArgPos;





(* Process termination *)

PROCEDURE -Exit*(code: INTEGER) "exit(code)";

PROCEDURE Halt*(code: LONGINT);
BEGIN
  HaltCode := code;
  IF HaltHandler # NIL THEN HaltHandler(code) END;
  Exit(SYSTEM.VAL(INTEGER,code));
END Halt;

PROCEDURE AssertFail*(code: LONGINT);
BEGIN
  AssertCode := code;
  Halt(-1);
END AssertFail;

PROCEDURE -killself() "kill(getpid(), 4);";  (* SIGILL: Illegal instruction *)

PROCEDURE Suicide(n: LONGINT);
BEGIN
  killself;
END Suicide;

PROCEDURE SetHalt*(p: HaltProcedure );
BEGIN
  HaltHandler := p;
END SetHalt;




(* Signals and traps *)

PROCEDURE -signal(sig: LONGINT; func: SignalHandler) "signal(sig, func)";

PROCEDURE SetInterruptHandler*(handler: SignalHandler);
BEGIN signal(2, handler); END SetInterruptHandler;

PROCEDURE SetQuitHandler*(handler: SignalHandler);
BEGIN signal(3, handler); END SetQuitHandler;

PROCEDURE SetBadInstructionHandler*(handler: SignalHandler);
BEGIN signal(4, handler); END SetBadInstructionHandler;




(* Time of day *)

PROCEDURE -gettimeval          "struct timeval tv; gettimeofday(&tv,0)";
PROCEDURE -tvsec():  LONGINT   "tv.tv_sec";
PROCEDURE -tvusec(): LONGINT   "tv.tv_usec";
PROCEDURE -sectotm(s: LONGINT) "struct tm *time = localtime(&s)";
PROCEDURE -tmsec():  LONGINT   "(LONGINT)time->tm_sec";
PROCEDURE -tmmin():  LONGINT   "(LONGINT)time->tm_min";
PROCEDURE -tmhour(): LONGINT   "(LONGINT)time->tm_hour";
PROCEDURE -tmmday(): LONGINT   "(LONGINT)time->tm_mday";
PROCEDURE -tmmon():  LONGINT   "(LONGINT)time->tm_mon";
PROCEDURE -tmyear(): LONGINT   "(LONGINT)time->tm_year";


PROCEDURE SecondsToClock*(s: LONGINT; VAR t, d: LONGINT);
BEGIN
  sectotm(s);
  t := tmsec()  + ASH(tmmin(), 6)   + ASH(tmhour(), 12);
  d := tmmday() + ASH(tmmon()+1, 5) + ASH(tmyear() MOD 100, 9)
END SecondsToClock;

PROCEDURE GetClock*(VAR t, d: LONGINT);
BEGIN gettimeval; SecondsToClock(tvsec(), t, d) END GetClock;


PROCEDURE Time*(): LONGINT;
VAR ms: LONGINT;
BEGIN
  gettimeval;
  ms := (tvusec() DIV 1000) + (tvsec() * 1000);
  RETURN (ms - TimeStart) MOD 7FFFFFFFH;
END Time;



PROCEDURE -getcwd(VAR cwd: ARRAY OF CHAR) "getcwd(cwd, cwd__len)";
PROCEDURE -getpid(): INTEGER              "(INTEGER)getpid()";



(* System call *)

PROCEDURE -system(str: ARRAY OF CHAR): INTEGER "system(str)";

PROCEDURE System*(cmd : ARRAY OF CHAR): INTEGER;
BEGIN RETURN system(cmd); END System;




(* File system *)

PROCEDURE -err(): INTEGER "errno";

PROCEDURE -openrw(n: ARRAY OF CHAR): INTEGER
  "open(n, O_RDWR)";  (* Consider flags O_SYNC and O_DIRECT as we do buffering *)

PROCEDURE -openro(n: ARRAY OF CHAR): INTEGER
  "open(n, O_RDONLY)";  (* Consider flags O_SYNC and O_DIRECT as we do buffering *)

PROCEDURE -opennew(n: ARRAY OF CHAR): INTEGER
  "open(n, O_CREAT | O_TRUNC | O_RDWR, 0660)";  (* Consider flags O_SYNC and O_DIRECT as we do buffering *)

PROCEDURE -writefile(fd: LONGINT; p: LONGINT; l: LONGINT): LONGINT
  "write(fd, (void*)p, l)";

PROCEDURE -readfile(fd: LONGINT; p: LONGINT; l: LONGINT): LONGINT
  "read(fd, (void*)p, l)";

PROCEDURE -fsync    (fd: LONGINT):             INTEGER "fsync(fd)";
PROCEDURE -closefile(fd: LONGINT):             INTEGER "close(fd)";
PROCEDURE -unlink   (n: ARRAY OF CHAR):        INTEGER "unlink(n)";
PROCEDURE -chdir    (n: ARRAY OF CHAR):        INTEGER "chdir(n)";
PROCEDURE -rename   (o,n: ARRAY OF CHAR):      INTEGER "rename(o,n)";
PROCEDURE -lseek    (fd: LONGINT; o: LONGINT): INTEGER "lseek(fd, o, SEEK_SET)";
PROCEDURE -ftruncate(fd: LONGINT; l: LONGINT): INTEGER "ftruncate(fd, l)";
PROCEDURE -structstats()                               "struct stat s";
PROCEDURE -fstat    (fd: LONGINT):             INTEGER "fstat(fd, &s)";
PROCEDURE -stat     (n: ARRAY OF CHAR):        INTEGER "stat(n, &s)";

PROCEDURE -statdev():   LONGINT "(LONGINT)s.st_dev";
PROCEDURE -statino():   LONGINT "(LONGINT)s.st_ino";
PROCEDURE -statmtime(): LONGINT "(LONGINT)s.st_mtime";
PROCEDURE -statsize():  LONGINT "(LONGINT)s.st_size";



(* File APIs *)

PROCEDURE OldRO*(VAR n: ARRAY OF CHAR; VAR h: FileHandle): ErrorCode;
VAR fd: INTEGER;
BEGIN
  fd := openro(n);
  IF (fd < 0) THEN RETURN err() ELSE h := fd; RETURN 0 END;
END OldRO;

PROCEDURE OldRW*(VAR n: ARRAY OF CHAR; VAR h: FileHandle): ErrorCode;
VAR fd: INTEGER;
BEGIN
  fd := openrw(n);
  IF (fd < 0) THEN RETURN err() ELSE h := fd; RETURN 0 END;
END OldRW;

PROCEDURE New*(VAR n: ARRAY OF CHAR; VAR h: FileHandle): ErrorCode;
VAR fd: INTEGER;
BEGIN
  fd := opennew(n);
  IF (fd < 0) THEN RETURN err() ELSE h := fd; RETURN 0 END;
END New;

PROCEDURE Identify*(h: FileHandle; VAR identity: FileIdentity): ErrorCode;
BEGIN
  structstats;
  IF (fstat(h) < 0) THEN RETURN err() END;
  identity.volume := statdev();
  identity.index  := statino();
  identity.mtime  := statmtime();
  RETURN 0
END Identify;

PROCEDURE IdentifyByName*(n: ARRAY OF CHAR; VAR identity: FileIdentity): ErrorCode;
BEGIN
  structstats;
  IF (stat(n) < 0) THEN RETURN err() END;
  identity.volume := statdev();
  identity.index  := statino();
  identity.mtime  := statmtime();
  RETURN 0
END IdentifyByName;

PROCEDURE Size*(h: FileHandle; VAR l: LONGINT): ErrorCode;
BEGIN
  structstats;
  IF (fstat(h) < 0) THEN RETURN err() END;
  l := statsize();
  RETURN 0;
END Size;

PROCEDURE Read*(h: FileHandle; p: LONGINT; l: LONGINT; VAR n: LONGINT): ErrorCode;
BEGIN
  n := readfile(h, p, l);
  IF n < 0 THEN n := 0; RETURN err() ELSE RETURN 0 END
END Read;

PROCEDURE ReadBuf*(h: FileHandle; VAR b: ARRAY OF SYSTEM.BYTE; VAR n: LONGINT): ErrorCode;
BEGIN
  n := readfile(h, SYSTEM.ADR(b), LEN(b));
  IF n < 0 THEN n := 0; RETURN err() ELSE RETURN 0 END
END ReadBuf;

PROCEDURE Write*(h: FileHandle; p: LONGINT; l: LONGINT): ErrorCode;
  VAR written: LONGINT;
BEGIN
  written := writefile(h, p, l);
  IF written < 0 THEN RETURN err() ELSE RETURN 0 END
END Write;

PROCEDURE WriteBuf*(h: FileHandle; b: ARRAY OF SYSTEM.BYTE; l: LONGINT): ErrorCode;
  VAR written: LONGINT;
BEGIN
  written := writefile(h, SYSTEM.ADR(b), LEN(b));
  IF written < 0 THEN RETURN err() ELSE RETURN 0 END
END WriteBuf;

PROCEDURE Sync*(h: FileHandle): ErrorCode;
BEGIN
  IF fsync(h) < 0 THEN RETURN err() ELSE RETURN 0 END
END Sync;

PROCEDURE Seek*(h: FileHandle; o: LONGINT): ErrorCode;
BEGIN
  IF lseek(h, o) < 0 THEN RETURN err() ELSE RETURN 0 END
END Seek;

PROCEDURE Truncate*(h: FileHandle; l: LONGINT): ErrorCode;
BEGIN
  IF (ftruncate(h, l) < 0) THEN RETURN err() ELSE RETURN 0 END;
END Truncate;

PROCEDURE Close*(h: FileHandle): ErrorCode;
BEGIN
  IF closefile(h) < 0 THEN RETURN err() ELSE RETURN 0 END
END Close;

PROCEDURE Unlink*(VAR n: ARRAY OF CHAR): ErrorCode;
BEGIN
  IF unlink(n) < 0 THEN RETURN err() ELSE RETURN 0 END
END Unlink;

PROCEDURE Chdir*(VAR n: ARRAY OF CHAR): ErrorCode;
  VAR r: INTEGER;
BEGIN
  r := chdir(n);  getcwd(CWD);
  IF r < 0 THEN RETURN err() ELSE RETURN 0 END
END Chdir;

PROCEDURE Rename*(VAR o,n: ARRAY OF CHAR): ErrorCode;
BEGIN
  IF rename(o,n) < 0 THEN RETURN err() ELSE RETURN 0 END
END Rename;


PROCEDURE TestLittleEndian;
  VAR i: INTEGER;
 BEGIN i := 1; SYSTEM.GET(SYSTEM.ADR(i), LittleEndian); END TestLittleEndian;



BEGIN
  TestLittleEndian;

  HaltCode    := -128;
  HaltHandler := Suicide;
  AssertCode  := 0;
  TimeStart   := 0;   TimeStart := Time();
  CWD         := "";  getcwd(CWD);
  PID         := getpid();

  (*
    MODULES := "";  GetEnv("MODULES", MODULES);
    LIB     := "";  GetEnv("OBERON_LIB", LIB);
    HOME    := "";  GetEnv("HOME", HOME);
    OBERON  := "."; GetEnv("OBERON", OBERON);

    Strings.Append(":.:",                OBERON);
    Strings.Append(MODULES,              OBERON);
    Strings.Append(":",                  OBERON);
    Strings.Append(Configuration.prefix, OBERON);
    Strings.Append("/lib/voc/sym:",      OBERON);
  *)
END Platform.

