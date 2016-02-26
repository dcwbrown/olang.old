/* voc  Oberon compiler olang 0.5 [2016/02/24] for cygwin ILP32 using clang in /opt/olang-0.5 xtpkal */
#include "SYSTEM.h"
#include "Console.h"
#include "Platform.h"


static LONGINT retcode_argval;





export void *retcode__init(void)
{
	__DEFMOD;
	__MODULE_IMPORT(Console);
	__MODULE_IMPORT(Platform);
	__REGMOD("retcode", 0);
/* BEGIN */
	if (Platform_ArgCount < 2) {
		Platform_Exit(-1);
	}
	Platform_GetIntArg(1, &retcode_argval);
	Console_String((CHAR*)"(argval ", (LONGINT)9);
	Console_Int(retcode_argval, ((LONGINT)(1)));
	Console_String((CHAR*)") ", (LONGINT)3);
	Console_Flush();
	Platform_Exit((int)retcode_argval);
	__ENDMOD;
}
