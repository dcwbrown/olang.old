/* voc  Oberon compiler olang 0.5 [2016/02/20] for windows LLP64 using msc in C:\Program Files\olang-0.5 xtpka */
#include "SYSTEM.h"
#include "Console.h"
#include "Platform.h"


static LONGINT signals_i, signals_j;


static void signals_interrupted (INTEGER n);
static void signals_quitted (INTEGER n);


static void signals_interrupted (INTEGER n)
{
	Console_Ln();
	Console_String((CHAR*)" *TERMINATED*", (LONGINT)14);
	Console_Ln();
	__HALT(98);
}

static void signals_quitted (INTEGER n)
{
	Console_String((CHAR*)"Quitted", (LONGINT)8);
	Console_Ln();
	Platform_Exit(98);
}


export int main(int argc, char **argv)
{
	__INIT(argc, argv);
	__MODULE_IMPORT(Console);
	__MODULE_IMPORT(Platform);
	__REGMAIN("signals", 0);
/* BEGIN */
	Platform_SetInterruptHandler(signals_interrupted);
	Platform_SetQuitHandler(signals_quitted);
	signals_i = 0;
	while (signals_i <= 3) {
		Platform_Delay(((LONGINT)(1000)));
		Console_Char('.');
		Console_Flush();
		signals_i += 1;
	}
	Console_Ln();
	__ASSERT(signals_i == -1, 0);
	__FINI;
}
