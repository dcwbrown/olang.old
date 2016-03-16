MODULE syscmd;

IMPORT Console, Platform, SYSTEM;

VAR 
   i,j: LONGINT;


PROCEDURE TestCommand(command: ARRAY OF CHAR);
VAR r, status, exitcode, coredump: INTEGER;
BEGIN
   Console.String("Executing: '"); Console.String(command); 
   Console.String("'."); Console.Ln;
   r := Platform.System(command);
   status   := r MOD 128;
   coredump := (r DIV 128) MOD 2;
   exitcode := r DIV 256;
   IF exitcode > 127 THEN exitcode := exitcode - 256 END; (* Handle signed exit code *)
   Console.String("Return value "); Console.Hex(r); 
   Console.String(": status "); Console.Int(status,1);
   Console.String(", coredump "); Console.Int(coredump,1);
   Console.String(", exitcode "); Console.Int(exitcode,1);
   Console.String("."); Console.Ln; Console.Ln;
END TestCommand;

PROCEDURE -splurd "splurgle ploop crunge";

BEGIN
   (*splurd;*) crubgle pllop
   TestCommand("splurgle");
   TestCommand("cmd /c echo hello");
   TestCommand("cmd /c type splunge");
   TestCommand("where splunge");
   TestCommand("where xcopy");
   TestCommand("./retcode.exe 123");
   TestCommand("./retcode.exe -123");
   TestCommand("cc retcode.Mod");
   TestCommand("cl retcode.Mod");
END syscmd.
