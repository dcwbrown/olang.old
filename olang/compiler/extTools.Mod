MODULE extTools;

IMPORT Strings, Console, Configuration, Platform, OPM;

VAR compilationOptions, CFLAGS: ARRAY 1023 OF CHAR;


PROCEDURE execute(title: ARRAY OF CHAR; cmd: ARRAY OF CHAR);
  VAR r: INTEGER;
BEGIN
  IF OPM.Verbose THEN Console.String(title); Console.String(cmd); Console.Ln END;
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
    execute("Compile: ", cmd);
  END Assemble;


PROCEDURE LinkMain*(VAR moduleName: ARRAY OF CHAR; statically: BOOLEAN; additionalopts: ARRAY OF CHAR);
  VAR
    cmd: ARRAY 1023 OF CHAR;
  BEGIN
    cmd := Configuration.cc;
    Strings.Append(" ",                   cmd);
    Strings.Append(compilationOptions,    cmd);
    Strings.Append(moduleName,            cmd);
    Strings.Append(".c ",                 cmd);
    Strings.Append(additionalopts,        cmd);
    IF statically THEN Strings.Append(Configuration.staticlink, cmd) END;

    IF Configuration.compiler # "msc" THEN
      Strings.Append(" -o ",              cmd)
    ELSE 
      Strings.Append(" -Fe",              cmd)
    END;    
    Strings.Append(moduleName,            cmd);

    IF Configuration.compiler # "msc" THEN
      Strings.Append(' -L"',              cmd)
    ELSE
      Strings.Append(' -link -libpath:"', cmd)
    END;
    Strings.Append(Configuration.prefix,  cmd);
    Strings.Append('/lib"',               cmd);
    
    IF Configuration.compiler # "msc" THEN
      Strings.Append(" -lolang",          cmd)
    ELSE
      Strings.Append(" libolang.lib",     cmd)
    END;

    execute("Link: ", cmd);
  END LinkMain;

BEGIN
  Strings.Append(' -I "',                 compilationOptions);
  Strings.Append(Configuration.prefix,    compilationOptions);
  Strings.Append('/include" ',            compilationOptions);
  Platform.GetEnv("CFLAGS", CFLAGS);
  Strings.Append (CFLAGS,                 compilationOptions);
  Strings.Append (" ",                    compilationOptions);
END extTools.
