MODULE Platform;
IMPORT SYSTEM;

TYPE
  HaltProc = PROCEDURE(code: INTEGER);

VAR
  MainStackFrame-: LONGINT;
  HaltCode-:       INTEGER;
  HaltHandler:     HaltProc;
  LockDepth:       INTEGER;
  Interrupted:     BOOLEAN;


PROCEDURE -Exit(code: INTEGER) "exit(code)";

PROCEDURE -Allocate*(size: LONGINT): LONGINT
  "(LONGINT)malloc(size)";


PROCEDURE Init(argc: INTEGER; argv: LONGINT);
BEGIN
END Init;


PROCEDURE Halt(code: INTEGER);
BEGIN
  HaltCode := code;
  IF HaltHandler # NIL THEN HaltHandler(code) END;
  Exit(code);
END Halt;



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
END Platform.

