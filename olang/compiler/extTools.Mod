MODULE extTools;

IMPORT Strings, Console, Configuration, Platform;

VAR compilationOptions, CFLAGS: ARRAY 1023 OF CHAR;


PROCEDURE execute(title: ARRAY OF CHAR; cmd: ARRAY OF CHAR);
  VAR r: INTEGER;
BEGIN
  (* Console.Ln; Console.String(title); Console.String(" command: "); Console.String(cmd); Console.Ln; *)
  r := Platform.System(cmd);
  IF (r < 0) OR (r = 127) THEN
    Console.String(title);
    Console.String(" failed with termination status ");
    Console.Int(r,1); Console.Ln;
    Platform.Exit(r);
  END;
END execute;


PROCEDURE Assemble*(moduleName: ARRAY OF CHAR);
  VAR
    cmd: ARRAY 1023 OF CHAR;
  BEGIN
    cmd := Configuration.cc;
    Strings.Append(compilationOptions, cmd);
    Strings.Append("-c ",              cmd);
    Strings.Append(moduleName,         cmd);
    Strings.Append(".c",               cmd);
    execute("C compilation", cmd);
  END Assemble;


PROCEDURE LinkMain*(VAR moduleName: ARRAY OF CHAR; statically : BOOLEAN; additionalopts : ARRAY OF CHAR);
  VAR
    cmd: ARRAY 1023 OF CHAR;
  BEGIN
    cmd := Configuration.cc;
    Strings.Append(" ",                  cmd);
    Strings.Append(compilationOptions,   cmd);
    Strings.Append(moduleName,           cmd);
    Strings.Append(".c ",                cmd);
    Strings.Append(additionalopts,       cmd);
    IF statically THEN
      Strings.Append(" -static ",        cmd)
    END;
    Strings.Append(" -o ",               cmd);
    Strings.Append(moduleName,           cmd);
    Strings.Append(" -L",                cmd);
    Strings.Append(Configuration.prefix, cmd);
    Strings.Append(" -lolang ",          cmd);
    execute("Linking", cmd);
  END LinkMain;

BEGIN
  (* compilationOptions := " -c -Wno-pointer-sign -g -I ";*)
  (*
    compilationOptions := " -I ";
    Strings.Append(Configuration.prefix,    compilationOptions);
    Strings.Append("/",                     compilationOptions);
    Strings.Append("src/lib/system/linux/", compilationOptions);
    Strings.Append(Configuration.compiler,  compilationOptions);
    Strings.Append("/",                     compilationOptions);
    Strings.Append(Configuration.cpuarch,   compilationOptions);
    IF Configuration.compiler # "gcc" THEN
      Strings.Append(" -fPIC",              compilationOptions)
    END;
  *)
  Strings.Append(" -I ",                  compilationOptions);
  Strings.Append(Configuration.prefix,    compilationOptions);
  Strings.Append("/include ",             compilationOptions);
  Platform.GetEnv("CFLAGS", CFLAGS);
  Strings.Append (CFLAGS,                 compilationOptions);
  Strings.Append (" ",                    compilationOptions);
END extTools.
