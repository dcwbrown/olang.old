MODULE Platform;
IMPORT SYSTEM;

(* TODO:
   Use Unicode APIs with manual UTF8 conversion and prepend '\\?\' to
   file paths in order to get 32768 character path length limit (as
   opposed to 256 bytes. *)


TYPE
  HaltProcedure = PROCEDURE(n: LONGINT);
  SignalHandler = PROCEDURE(signal: INTEGER);

  ErrorCode*  = INTEGER;
  FileHandle* = LONGINT;

  FileIdentity* = RECORD
    volume*: LONGINT;  (* dev on Unix filesystems, volume serial number on NTFS *)
    index*:  LONGINT;  (* inode on Unix filesystems, file id on NTFS *)
    mtime*:  LONGINT;  (* File modification time, value is system dependent *)
  END;

  EnvPtr    = POINTER TO ARRAY 1024 OF CHAR;
  ArgPtr    = POINTER TO ARRAY 1024 OF CHAR;
  ArgVec    = POINTER TO ARRAY 1024 OF ArgPtr;
  ArgVecPtr = POINTER TO ARRAY 1 OF LONGINT;


VAR
  LittleEndian-:   BOOLEAN;
  MainStackFrame-: LONGINT;
  HaltCode-:       LONGINT;
  AssertCode-:     LONGINT;
  PID-:            INTEGER;    (* Note: Must be updated by Fork implementation *)
  CWD-:            ARRAY 4096 OF CHAR;
  ArgCount-:       INTEGER;

  ArgVector-:      LONGINT;
  HaltHandler:     HaltProcedure;
  TimeStart:       LONGINT;

  SeekSet-:        INTEGER;
  SeekCur-:        INTEGER;
  SeekEnd-:        INTEGER;




(* Unix headers to be included *)

(*
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
*)

PROCEDURE -Awindows           '#include <windows.h>';


(* Error code tests *)

PROCEDURE -ERRORTOOMANYOPENFILES(): ErrorCode 'ERROR_TOO_MANY_OPEN_FILES';
PROCEDURE -ERRORPATHNOTFOUND():     ErrorCode 'ERROR_PATH_NOT_FOUND';
PROCEDURE -ERRORFILENOTFOUND():     ErrorCode 'ERROR_FILE_NOT_FOUND';
PROCEDURE -ERRORNOTSAMEDEVICE():    ErrorCode 'ERROR_NOT_SAME_DEVICE';
PROCEDURE -ERRORACCESSDENIED():     ErrorCode 'ERROR_ACCESS_DENIED';
PROCEDURE -ERRORWRITEPROTECT():     ErrorCode 'ERROR_WRITE_PROTECT';
PROCEDURE -ERRORSHARINGVIOLATION(): ErrorCode 'ERROR_SHARING_VIOLATION';
PROCEDURE -ERRORNOTREADY():         ErrorCode 'ERROR_NOT_READY';

PROCEDURE TooManyFiles*(e: ErrorCode): BOOLEAN;
BEGIN RETURN e = ERRORTOOMANYOPENFILES() END TooManyFiles;

PROCEDURE NoSuchDirectory*(e: ErrorCode): BOOLEAN;
BEGIN RETURN e = ERRORPATHNOTFOUND() END NoSuchDirectory;

PROCEDURE DifferentFilesystems*(e: ErrorCode): BOOLEAN;
BEGIN RETURN e = ERRORNOTSAMEDEVICE() END DifferentFilesystems;

PROCEDURE Inaccessible*(e: ErrorCode): BOOLEAN;
BEGIN 
  RETURN (e = ERRORACCESSDENIED()) OR (e = ERRORWRITEPROTECT()) 
      OR (e = ERRORNOTREADY())     OR (e = ERRORSHARINGVIOLATION()); 
END Inaccessible;

PROCEDURE Absent*(e: ErrorCode): BOOLEAN;
BEGIN RETURN (e = ERRORFILENOTFOUND()) OR (e = ERRORPATHNOTFOUND()) END Absent;




(* OS memory allocaton *)

PROCEDURE -allocate(size: LONGINT): LONGINT "(LONGINT)(uintptr_t)((void*)HeapAlloc(GetProcessHeap(), 0, (size_t)size))";
PROCEDURE Allocate*(size: LONGINT): LONGINT; BEGIN RETURN allocate(size) END Allocate;




(* Program startup *)

PROCEDURE -ExternInitHeap  "extern void Heap_InitHeap();";
PROCEDURE -HeapInitHeap()  "Heap_InitHeap()";

PROCEDURE Init*(argc: INTEGER; argvadr: LONGINT);
VAR  av: ArgVecPtr;
BEGIN
  MainStackFrame := argvadr;
  ArgCount       := argc;
  av             := SYSTEM.VAL(ArgVecPtr, argvadr);
  ArgVector      := av[0];
  HaltCode       := -128;

  (* This function (Platform.Init) is called at program startup BEFORE any
     modules have been initalised. In turn we must initialise the heap
     before module startup (xxx__init) code is run. *)
  HeapInitHeap();
END Init;




(* Program arguments and environmet access *)

PROCEDURE -getenv(name: ARRAY OF CHAR; VAR buf: ARRAY OF CHAR): INTEGER 
"(INTEGER)GetEnvironmentVariable((char*)name, (char*)buf, buf__len)";

PROCEDURE getEnv*(var: ARRAY OF CHAR; VAR val: ARRAY OF CHAR): BOOLEAN;
  VAR 
    buf: ARRAY 4096 OF CHAR;
    res: INTEGER;
BEGIN
  res := getenv(var, buf);
  IF (res > 0) & (res < LEN(buf)) THEN 
    COPY(buf, val);
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END;
END getEnv;

PROCEDURE GetEnv*(var: ARRAY OF CHAR; VAR val: ARRAY OF CHAR);
BEGIN
  IF ~getEnv(var, val) THEN val[0] := 0X END;
END GetEnv;

PROCEDURE GetArg*(n: INTEGER; VAR val: ARRAY OF CHAR);
  VAR av: ArgVec;
BEGIN
  IF n < ArgCount THEN
    av := SYSTEM.VAL(ArgVec,ArgVector);
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

PROCEDURE -getpid(): INTEGER    "(INTEGER)GetCurrentProcessId()";
PROCEDURE -Exit*(code: INTEGER) "ExitProcess((UINT)code)";

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

PROCEDURE -killself() "TerminateProcess(GetCurrentProcess(), 4);";  (* 4 is SIGILL: Illegal instruction *)

PROCEDURE Suicide(n: LONGINT);
BEGIN killself; END Suicide;

PROCEDURE SetHalt*(p: HaltProcedure);
BEGIN HaltHandler := p; END SetHalt;




(* Signals and traps *)

(* PROCEDURE -signal(sig: LONGINT; func: SignalHandler) "signal(sig, func)"; *)

(* TODO *)

PROCEDURE SetInterruptHandler*(handler: SignalHandler);
BEGIN (* signal(2, handler); *) END SetInterruptHandler;

PROCEDURE SetQuitHandler*(handler: SignalHandler);
BEGIN (* signal(3, handler); *) END SetQuitHandler;

PROCEDURE SetBadInstructionHandler*(handler: SignalHandler);
BEGIN (* signal(4, handler); *) END SetBadInstructionHandler;




(* Time of day *)

PROCEDURE -getLocalTime  "SYSTEMTIME st; GetLocalTime(&st)";
PROCEDURE -stsec():  LONGINT  "(LONGINT)st.wSecond";
PROCEDURE -stmin():  LONGINT  "(LONGINT)st.wMinute";
PROCEDURE -sthour(): LONGINT  "(LONGINT)st.wHour";
PROCEDURE -stmday(): LONGINT  "(LONGINT)st.wDay";
PROCEDURE -stmon():  LONGINT  "(LONGINT)st.wMonth";
PROCEDURE -styear(): LONGINT  "(LONGINT)st.wYear";

PROCEDURE GetClock*(VAR t, d: LONGINT);
BEGIN 
  getLocalTime;
  t := stsec()  + ASH(stmin(), 6)   + ASH(sthour(), 12);
  d := stmday() + ASH(stmon()+1, 5) + ASH(styear() MOD 100, 9)
END GetClock;

PROCEDURE -fileTime(seconds: LONGINT)
"FILETIME ft; seconds *= 10000000L; ft.dwHighDateTime = seconds>>32; ft.dwLowDateTime = seconds & 0xffffffff";

PROCEDURE -fileTimeToSysTime
"SYSTEMTIME st; FileTimeToSystemTime(&ft, &st)";

PROCEDURE SecondsToClock*(s: LONGINT; VAR t, d: LONGINT);
BEGIN
  fileTime(s); fileTimeToSysTime;
  t := stsec()  + ASH(stmin(), 6)   + ASH(sthour(), 12);
  d := stmday() + ASH(stmon()+1, 5) + ASH(styear() MOD 100, 9)
END SecondsToClock;

PROCEDURE -GetTickCount(): LONGINT "(LONGINT)(uint32_t)GetTickCount()";

PROCEDURE Time*(): LONGINT;
VAR ms: LONGINT;
BEGIN
  ms := GetTickCount();
  RETURN (ms - TimeStart) MOD 7FFFFFFFH;
END Time;


PROCEDURE -sleep(ms: LONGINT) "Sleep((DWORD)ms)";

PROCEDURE Delay*(ms: LONGINT);
BEGIN
  WHILE ms > 30000 DO sleep(30000); ms := ms-30000 END;
  IF ms > 0 THEN sleep(ms) END;
END Delay;




(* System call *)

PROCEDURE -startupInfo                                "STARTUPINFO si = {0}; si.cb = sizeof(si);";
PROCEDURE -processInfo                                "PROCESS_INFORMATION pi = {0};";
PROCEDURE -createProcess(str: ARRAY OF CHAR): INTEGER "(INTEGER)CreateProcess(0, (char*)str, 0,0,0,0,0,0,&si,&pi)";
PROCEDURE -waitForProcess(): INTEGER                  "(INTEGER)WaitForSingleObject(pi.hProcess, INFINITE)";
PROCEDURE -getExitCodeProcess(VAR exitcode: INTEGER)  "GetExitCodeProcess(pi.hProcess, (DWORD*)exitcode);";
PROCEDURE -cleanupProcess                             "CloseHandle(pi.hProcess); CloseHandle(pi.hThread);";

PROCEDURE System*(cmd : ARRAY OF CHAR): INTEGER;
VAR 
  result: INTEGER;
BEGIN 
  result := 2;
  startupInfo; processInfo;
  IF createProcess(cmd) = 0 THEN RETURN 2 END;  
  IF waitForProcess() = 0 THEN getExitCodeProcess(result) END;
  cleanupProcess;
  RETURN result;
END System;




(* File system *)

PROCEDURE -err(): INTEGER "(INTEGER)GetLastError()";

PROCEDURE -openrw (n: ARRAY OF CHAR): LONGINT 
"(LONGINT)(uintptr_t)CreateFile((char*)n, GENERIC_READ|GENERIC_WRITE, FILE_SHARE_READ|FILE_SHARE_WRITE, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0)";

PROCEDURE -openro (n: ARRAY OF CHAR): LONGINT 
"(LONGINT)(uintptr_t)CreateFile((char*)n, GENERIC_READ              , FILE_SHARE_READ|FILE_SHARE_WRITE, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0)";

PROCEDURE -opennew(n: ARRAY OF CHAR): LONGINT 
"(LONGINT)(uintptr_t)CreateFile((char*)n, GENERIC_READ|GENERIC_WRITE, FILE_SHARE_READ|FILE_SHARE_WRITE, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0)";

(*
PROCEDURE -fsync     (fd: LONGINT):                         INTEGER "fsync(fd)";
PROCEDURE -closefile (fd: LONGINT):                         INTEGER "close(fd)";
PROCEDURE -lseek     (fd: LONGINT; o: LONGINT; r: INTEGER): INTEGER "lseek(fd, o, r)";
PROCEDURE -ftruncate (fd: LONGINT; l: LONGINT):             INTEGER "ftruncate(fd, l)";
PROCEDURE -fstat     (fd: LONGINT):                         INTEGER "fstat(fd, &s)";

PROCEDURE -stat      (n: ARRAY OF CHAR):                    INTEGER "stat((char* )n, &s)";
PROCEDURE -unlink    (n: ARRAY OF CHAR):                    INTEGER "unlink((char* )n)";
PROCEDURE -chdir     (n: ARRAY OF CHAR):                    INTEGER "chdir((char* )n)";
PROCEDURE -rename    (o,n: ARRAY OF CHAR):                  INTEGER "rename((char* )o, (char* )n)";

PROCEDURE -getcwd(VAR cwd: ARRAY OF CHAR) "getcwd((char* )cwd, cwd__len)";

PROCEDURE -structstats          "struct stat s";
PROCEDURE -statdev():   LONGINT "(LONGINT)s.st_dev";
PROCEDURE -statino():   LONGINT "(LONGINT)s.st_ino";
PROCEDURE -statmtime(): LONGINT "(LONGINT)s.st_mtime";
PROCEDURE -statsize():  LONGINT "(LONGINT)s.st_size";

PROCEDURE -seekset(): INTEGER "SEEK_SET";
PROCEDURE -seekcur(): INTEGER "SEEK_CUR";
PROCEDURE -seekend(): INTEGER "SEEK_END";
*)


(* File APIs *)

PROCEDURE -invalidHandleValue(): LONGINT "((LONGINT)(uintptr_t)INVALID_HANDLE_VALUE)";

PROCEDURE OldRO*(VAR n: ARRAY OF CHAR; VAR h: FileHandle): ErrorCode;
VAR fd: LONGINT;
BEGIN
  fd := openro(n);
  IF (fd = invalidHandleValue()) THEN RETURN err() ELSE h := fd; RETURN 0 END;
END OldRO;

PROCEDURE OldRW*(VAR n: ARRAY OF CHAR; VAR h: FileHandle): ErrorCode;
VAR fd: LONGINT;
BEGIN
  fd := openrw(n);
  IF (fd = invalidHandleValue()) THEN RETURN err() ELSE h := fd; RETURN 0 END;
END OldRW;

PROCEDURE New*(VAR n: ARRAY OF CHAR; VAR h: FileHandle): ErrorCode;
VAR fd: LONGINT;
BEGIN
  fd := opennew(n);
  IF (fd = invalidHandleValue()) THEN RETURN err() ELSE h := fd; RETURN 0 END;
END New;

PROCEDURE -closeHandle(h: FileHandle): INTEGER "(INTEGER)CloseHandle((HANDLE)(uintptr_t)h)";

PROCEDURE Close*(h: FileHandle): ErrorCode;
BEGIN
  IF closeHandle(h) = 0 THEN RETURN err() ELSE RETURN 0 END
END Close;

PROCEDURE -byHandleFileInformation "BY_HANDLE_FILE_INFORMATION bhfi";
PROCEDURE -getFileInformationByHandle(h: FileHandle): INTEGER "(INTEGER)GetFileInformationByHandle((HANDLE)(uintptr_t)h, &bhfi)";
PROCEDURE -bhfiMtime(): LONGINT "((LONGINT)bhfi.ftLastWriteTime.dwHighDateTime)<<32 | (LONGINT)(uint32_t)bhfi.ftLastWriteTime.dwLowDateTime";
PROCEDURE -bhfiVsn():   LONGINT "(LONGINT)bhfi.dwVolumeSerialNumber";
PROCEDURE -bhfiIndex(): LONGINT "((LONGINT)bhfi.nFileIndexHigh)<<32 | (LONGINT)(uint32_t)bhfi.nFileIndexLow";

PROCEDURE Identify*(h: FileHandle; VAR identity: FileIdentity): ErrorCode;
BEGIN
  byHandleFileInformation;
  IF getFileInformationByHandle(h) = 0 THEN RETURN err() END;
  identity.volume := bhfiVsn();
  identity.index  := bhfiIndex();
  identity.mtime  := bhfiMtime();
  RETURN 0
END Identify;

PROCEDURE IdentifyByName*(n: ARRAY OF CHAR; VAR identity: FileIdentity): ErrorCode;
VAR 
  h:   FileHandle; 
  e,i: ErrorCode;
BEGIN
  e := OldRO(n, h);
  IF e # 0 THEN RETURN e END;
  e := Identify(h, identity);
  i := Close(h);
  RETURN e;
END IdentifyByName;


PROCEDURE -largeInteger "LARGE_INTEGER li";
PROCEDURE -liLongint(): LONGINT "(LONGINT)li.QuadPart";
PROCEDURE -getFileSize(h: FileHandle): INTEGER "(INTEGER)GetFileSizeEx((HANDLE)(uintptr_t)h, &li)";

PROCEDURE Size*(h: FileHandle; VAR l: LONGINT): ErrorCode;
BEGIN
  largeInteger;
  IF getFileSize(h) = 0 THEN RETURN err() END;
  l := liLongint();
  RETURN 0;
END Size;


PROCEDURE -readfile (fd: LONGINT; p: LONGINT; l: LONGINT; VAR n: LONGINT): INTEGER 
"(INTEGER)ReadFile ((HANDLE)(uintptr_t)fd, (void*)(uintptr_t)(p), (DWORD)l, (DWORD*)n, 0)";

PROCEDURE Read*(h: FileHandle; p: LONGINT; l: LONGINT; VAR n: LONGINT): ErrorCode;
VAR lengthread: LONGINT; result: INTEGER;
BEGIN
  lengthread := 0;
  result := readfile(h, p, l, lengthread);
  n := lengthread;
  IF result = 0 THEN RETURN err() ELSE RETURN 0 END
END Read;

PROCEDURE ReadBuf*(h: FileHandle; VAR b: ARRAY OF SYSTEM.BYTE; VAR n: LONGINT): ErrorCode;
VAR lengthread: LONGINT; result: INTEGER;
BEGIN
  lengthread := 0;
  result := readfile(h, SYSTEM.ADR(b), LEN(b), lengthread);
  n := lengthread;
  IF result = 0 THEN RETURN err() ELSE RETURN 0 END
END ReadBuf;


PROCEDURE -writefile(fd: LONGINT; p: LONGINT; l: LONGINT): INTEGER "(INTEGER)WriteFile((HANDLE)(uintptr_t)fd, (void*)(uintptr_t)(p), (DWORD)l, 0,0)";

PROCEDURE Write*(h: FileHandle; p: LONGINT; l: LONGINT): ErrorCode;
BEGIN
  IF writefile(h, p, l) = 0 THEN RETURN err() ELSE RETURN 0 END
END Write;

PROCEDURE WriteBuf*(h: FileHandle; b: ARRAY OF SYSTEM.BYTE): ErrorCode;
BEGIN
  IF writefile(h, SYSTEM.ADR(b), LEN(b)) = 0 THEN RETURN err() ELSE RETURN 0 END
END WriteBuf;


PROCEDURE -flushFileBuffers(h: FileHandle): INTEGER "(INTEGER)FlushFileBuffers((HANDLE)(uintptr_t)h)";

PROCEDURE Sync*(h: FileHandle): ErrorCode;
BEGIN
  (* Leave windows to manage its own buffer flushing, as calling FlushFileBuffers can
     return with the file busy. *)
  IF flushFileBuffers(h) = 0 THEN RETURN err() ELSE RETURN 0 END
  (* *)
END Sync;

PROCEDURE -setFilePointerEx(h: FileHandle; o: LONGINT; r: INTEGER): INTEGER
"(INTEGER)SetFilePointerEx((HANDLE)(uintptr_t)h, (LARGE_INTEGER)o, 0, (DWORD)r)";

PROCEDURE -seekset(): INTEGER "FILE_BEGIN";
PROCEDURE -seekcur(): INTEGER "FILE_CURRENT";
PROCEDURE -seekend(): INTEGER "FILE_END";

PROCEDURE Seek*(h: FileHandle; o: LONGINT; r: INTEGER): ErrorCode;
BEGIN
  IF setFilePointerEx(h, o, r) = 0 THEN RETURN err() ELSE RETURN 0 END
END Seek;


PROCEDURE -setEndOfFile(h: FileHandle): INTEGER "(INTEGER)SetEndOfFile((HANDLE)(uintptr_t)h)";
PROCEDURE -getFilePos(h: FileHandle): INTEGER
"(INTEGER)SetFilePointerEx((HANDLE)(uintptr_t)h, (LARGE_INTEGER)0LL, &li, FILE_CURRENT)";

PROCEDURE Truncate*(h: FileHandle; l: LONGINT): ErrorCode;
VAR e: ErrorCode;
BEGIN
  largeInteger;
  IF getFilePos(h) = 0                               THEN RETURN err() END;
  IF setFilePointerEx(h, l, seekset()) = 0           THEN RETURN err() END;
  IF setEndOfFile(h) = 0                             THEN RETURN err() END;
  IF setFilePointerEx(h, liLongint(), seekset()) = 0 THEN RETURN err() END; (* Restore original file position *)
  RETURN 0;
END Truncate;


PROCEDURE -deleteFile(n: ARRAY OF CHAR): INTEGER "(INTEGER)DeleteFile((char*)n)";

PROCEDURE Unlink*(VAR n: ARRAY OF CHAR): ErrorCode;
BEGIN
  IF deleteFile(n) = 0 THEN RETURN err() ELSE RETURN 0 END
END Unlink;


PROCEDURE -setCurrentDirectory(n: ARRAY OF CHAR): INTEGER "(INTEGER)SetCurrentDirectory((char*)n)";
PROCEDURE -getCurrentDirectory(VAR n: ARRAY OF CHAR) "GetCurrentDirectory(n__len, (char*)n)";

PROCEDURE Chdir*(VAR n: ARRAY OF CHAR): ErrorCode;
  VAR r: INTEGER;
BEGIN
  r := setCurrentDirectory(n);  
  IF r = 0 THEN RETURN err() END;
  getCurrentDirectory(CWD);
  RETURN 0;
END Chdir;


PROCEDURE -moveFile(o,n: ARRAY OF CHAR): INTEGER "(INTEGER)MoveFileEx((char*)o, (char*)n, MOVEFILE_REPLACE_EXISTING)";
PROCEDURE Rename*(VAR o,n: ARRAY OF CHAR): ErrorCode;
BEGIN
  IF moveFile(o,n) = 0 THEN RETURN err() ELSE RETURN 0 END
END Rename;


PROCEDURE TestLittleEndian;
  VAR i: INTEGER;
 BEGIN i := 1; SYSTEM.GET(SYSTEM.ADR(i), LittleEndian); END TestLittleEndian;



BEGIN
  TestLittleEndian;

  HaltCode    := -128;
  HaltHandler := Suicide;
  AssertCode  := 0;
  TimeStart   := Time();
  CWD         := "";  getCurrentDirectory(CWD);
  PID         := getpid();

  SeekSet    := seekset();
  SeekCur    := seekcur();
  SeekEnd    := seekend();
END Platform.

