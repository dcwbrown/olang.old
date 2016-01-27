MODULE Platform;
IMPORT SYSTEM;



CONST
  TimeUnit* = 1000;

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

  ArgVector:       LONGINT;
  HaltHandler:     HaltProcedure;
  TimeStart:       LONGINT;



(* Unix headers to include *)

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
PROCEDURE -Aerrno           '#include <errno.h>';




(* Error code tests *)

PROCEDURE -EMFILE(): ErrorCode 'EMFILE';
PROCEDURE -ENFILE(): ErrorCode 'ENFILE';
PROCEDURE -ENOENT(): ErrorCode 'ENOENT';
PROCEDURE -EXDEV():  ErrorCode 'EXDEV';
PROCEDURE -EACCES(): ErrorCode 'EACCES';
PROCEDURE -EROFS():  ErrorCode 'EROFS';
PROCEDURE -EAGAIN(): ErrorCode 'EAGAIN';

PROCEDURE TooManyFiles*(e: ErrorCode): BOOLEAN;
BEGIN RETURN (e = EMFILE()) OR (e = ENFILE()) END TooManyFiles;

PROCEDURE NoSuchDirectory*(e: ErrorCode): BOOLEAN;
BEGIN RETURN e = ENOENT() END NoSuchDirectory;

PROCEDURE DifferentFilesystems*(e: ErrorCode): BOOLEAN;
BEGIN RETURN e = EXDEV() END DifferentFilesystems;

PROCEDURE Inaccessible*(e: ErrorCode): BOOLEAN;
BEGIN RETURN (e = EACCES()) OR (e = EROFS()) OR (e = EAGAIN()) END Inaccessible;

PROCEDURE Absent*(e: ErrorCode): BOOLEAN;
BEGIN RETURN (e = ENOENT()) END Absent;




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
  (*HeapModuleInit();*)
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
PROCEDURE -sectotm(s: LONGINT) "struct tm *time = localtime((time_t*)&s)";
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

(* Note: Consider also using flags O_SYNC and O_DIRECT as we do buffering *)
PROCEDURE -openrw (n: ARRAY OF CHAR): INTEGER "open(n, O_RDWR)";
PROCEDURE -openro (n: ARRAY OF CHAR): INTEGER "open(n, O_RDONLY)";
PROCEDURE -opennew(n: ARRAY OF CHAR): INTEGER "open(n, O_CREAT | O_TRUNC | O_RDWR, 0660)";

PROCEDURE -writefile(fd: LONGINT; p: LONGINT; l: LONGINT): LONGINT "write(fd, (void*)p, l)";
PROCEDURE -readfile (fd: LONGINT; p: LONGINT; l: LONGINT): LONGINT "read(fd, (void*)p, l)";

PROCEDURE -fsync     (fd: LONGINT):             INTEGER "fsync(fd)";
PROCEDURE -closefile (fd: LONGINT):             INTEGER "close(fd)";
PROCEDURE -lseek     (fd: LONGINT; o: LONGINT): INTEGER "lseek(fd, o, SEEK_SET)";
PROCEDURE -ftruncate (fd: LONGINT; l: LONGINT): INTEGER "ftruncate(fd, l)";
PROCEDURE -fstat     (fd: LONGINT):             INTEGER "fstat(fd, &s)";

PROCEDURE -stat      (n: ARRAY OF CHAR):        INTEGER "stat(n, &s)";
PROCEDURE -unlink    (n: ARRAY OF CHAR):        INTEGER "unlink(n)";
PROCEDURE -chdir     (n: ARRAY OF CHAR):        INTEGER "chdir(n)";
PROCEDURE -rename    (o,n: ARRAY OF CHAR):      INTEGER "rename(o,n)";

PROCEDURE -structstats          "struct stat s";
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
END Platform.

