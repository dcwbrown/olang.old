/* voc  Oberon compiler olang 0.5 [2016/02/24] for windows LLP64 using msc in C:\Program Files\olang-0.5 xtpkav */
#include "SYSTEM.h"
#include "Console.h"
#include "Platform.h"


static LONGINT syscmd_i, syscmd_j;


static void syscmd_TestCommand (CHAR *command, LONGINT command__len);

#define syscmd_splurd()	splurgle ploop crunge

static void syscmd_TestCommand (CHAR *command, LONGINT command__len)
{
	INTEGER r, status, exitcode, coredump;
	__DUP(command, command__len, CHAR);
	Console_String((CHAR*)"Executing: \'", (LONGINT)13);
	Console_String(command, command__len);
	Console_String((CHAR*)"\'.", (LONGINT)3);
	Console_Ln();
	r = Platform_System(command, command__len);
	status = __MASK(r, -128);
	coredump = __MASK(__ASHR(r, 7), -2);
	exitcode = __ASHR(r, 8);
	if (exitcode > 127) {
		exitcode = exitcode - 256;
	}
	Console_String((CHAR*)"Return value ", (LONGINT)14);
	Console_Hex(r);
	Console_String((CHAR*)": status ", (LONGINT)10);
	Console_Int(status, ((LONGINT)(1)));
	Console_String((CHAR*)", coredump ", (LONGINT)12);
	Console_Int(coredump, ((LONGINT)(1)));
	Console_String((CHAR*)", exitcode ", (LONGINT)12);
	Console_Int(exitcode, ((LONGINT)(1)));
	Console_String((CHAR*)".", (LONGINT)2);
	Console_Ln();
	Console_Ln();
	__DEL(command);
}


export int main(int argc, char **argv)
{
	__INIT(argc, argv);
	__MODULE_IMPORT(Console);
	__MODULE_IMPORT(Platform);
	__REGMAIN("syscmd", 0);
/* BEGIN */
	syscmd_TestCommand((CHAR*)"splurgle", (LONGINT)9);
	syscmd_TestCommand((CHAR*)"cmd /c echo hello", (LONGINT)18);
	syscmd_TestCommand((CHAR*)"cmd /c type splunge", (LONGINT)20);
	syscmd_TestCommand((CHAR*)"where splunge", (LONGINT)14);
	syscmd_TestCommand((CHAR*)"where xcopy", (LONGINT)12);
	syscmd_TestCommand((CHAR*)"./retcode.exe 123", (LONGINT)18);
	syscmd_TestCommand((CHAR*)"./retcode.exe -123", (LONGINT)19);
	syscmd_TestCommand((CHAR*)"cc retcode.Mod", (LONGINT)15);
	syscmd_TestCommand((CHAR*)"cl retcode.Mod", (LONGINT)15);
	__FINI;
}
