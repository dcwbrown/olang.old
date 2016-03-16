MODULE retcode;

IMPORT Console, Platform;

VAR argval: LONGINT;

BEGIN
   IF Platform.ArgCount < 2 THEN Platform.Exit(-1) END;

   Platform.GetIntArg(1, argval);
   Console.String("(argval "); Console.Int(argval,1); Console.String(") "); Console.Flush;
   Platform.Exit(SHORT(argval));
END retcode.
