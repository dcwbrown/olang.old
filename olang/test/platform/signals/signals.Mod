MODULE signals;

IMPORT Console, Platform;

VAR 
   i,j: LONGINT;

BEGIN
  FOR i := 0 TO 60 DO
    Platform.Delay(1000);
    Console.Char('.');
  END;
  Console.Ln;
END signals.
