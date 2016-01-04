MODULE Platform;
IMPORT SYSTEM;

TYPE
  HaltProc = PROCEDURE(code: INTEGER);

VAR
  MainStackFrame-: LONGINT;
  HaltCode-:       INTEGER;
  AssertCode-:     LONGINT;
  HaltHandler:     HaltProc;
  LockDepth:       INTEGER;
  Interrupted:     BOOLEAN;
  ArgCount-:       INTEGER;
  ArgVector-:      LONGINT;


(* Exit to operating system *)

PROCEDURE -Exit*(code: INTEGER) "exit(code)";
PROCEDURE -Allocate*(size: LONGINT): LONGINT "(LONGINT)malloc(size)";



PROCEDURE -HeapModuleInit() "Heap__init()";
PROCEDURE -HeapInitHeap()   "Heap_InitHeap()";

PROCEDURE Init*(argc: INTEGER; argv: LONGINT);
BEGIN
  MainStackFrame := argv;
  ArgCount       := argc;
  ArgVector      := argv;
  HaltCode       := -128;

  HeapInitHeap();    (* Note: must be initialised before heap module itself. *)
  HeapModuleInit();
END Init;


PROCEDURE Halt*(code: INTEGER);
BEGIN
  HaltCode := code;
  IF HaltHandler # NIL THEN HaltHandler(code) END;
  Exit(code);
END Halt;

PROCEDURE AssertFail*(code: LONGINT);
BEGIN
  AssertCode := code;
  Halt(-1);
END AssertFail;



PROCEDURE Lock*;
BEGIN
  INC(LockDepth);
END Lock;


PROCEDURE Unlock*;
BEGIN
  DEC(LockDepth);
  IF Interrupted & (LockDepth = 0) THEN
    Halt(-9);
  END
END Unlock;



BEGIN
  LockDepth   := 0;
  HaltCode    := -128;
  HaltHandler := NIL;
  AssertCode  := 0;
END Platform.

