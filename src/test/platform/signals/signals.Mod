MODULE signals;

IMPORT Console, Platform;

VAR 
   i,j: LONGINT;

PROCEDURE interrupted(n: INTEGER);
BEGIN Console.Ln; Console.String(" *TERMINATED*"); Console.Ln; HALT(98) END interrupted;

PROCEDURE quitted(n: INTEGER);
BEGIN Console.String("Quitted"); Console.Ln; Platform.Exit(98) END quitted;
   

BEGIN
  Platform.SetInterruptHandler(interrupted);
  Platform.SetQuitHandler(quitted);
  FOR i := 0 TO 3 DO
    Platform.Delay(1000);
    Console.Char('.'); Console.Flush;
  END;
  Console.Ln;
  ASSERT(i = -1);
END signals.
