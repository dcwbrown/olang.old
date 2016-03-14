/* voc  Oberon compiler olang 0.5 [2016/03/14] for cygwin ILP32 using gcc xtspkaSF */

#ifndef Platform__h
#define Platform__h

#include "SYSTEM.h"

typedef
	struct Platform_FileIdentity {
		LONGINT volume, index, mtime;
	} Platform_FileIdentity;

typedef
	void (*Platform_HaltProcedure)(LONGINT);

typedef
	void (*Platform_SignalHandler)(INTEGER);


import BOOLEAN Platform_LittleEndian;
import LONGINT Platform_MainStackFrame, Platform_HaltCode;
import INTEGER Platform_PID;
import CHAR Platform_CWD[256];
import INTEGER Platform_ArgCount;
import LONGINT Platform_ArgVector;
import INTEGER Platform_SeekSet, Platform_SeekCur, Platform_SeekEnd;

import LONGINT *Platform_FileIdentity__typ;

import BOOLEAN Platform_Absent (INTEGER e);
import INTEGER Platform_ArgPos (CHAR *s, LONGINT s__len);
import void Platform_AssertFail (LONGINT code);
import INTEGER Platform_Chdir (CHAR *n, LONGINT n__len);
import INTEGER Platform_Close (LONGINT h);
import void Platform_Delay (LONGINT ms);
import BOOLEAN Platform_DifferentFilesystems (INTEGER e);
import void Platform_Exit (INTEGER code);
import void Platform_GetArg (INTEGER n, CHAR *val, LONGINT val__len);
import void Platform_GetClock (LONGINT *t, LONGINT *d);
import void Platform_GetEnv (CHAR *var, LONGINT var__len, CHAR *val, LONGINT val__len);
import void Platform_GetIntArg (INTEGER n, LONGINT *val);
import void Platform_GetTimeOfDay (LONGINT *sec, LONGINT *usec);
import void Platform_Halt (LONGINT code);
import INTEGER Platform_Identify (LONGINT h, Platform_FileIdentity *identity, LONGINT *identity__typ);
import INTEGER Platform_IdentifyByName (CHAR *n, LONGINT n__len, Platform_FileIdentity *identity, LONGINT *identity__typ);
import BOOLEAN Platform_Inaccessible (INTEGER e);
import void Platform_Init (INTEGER argc, LONGINT argvadr);
import INTEGER Platform_New (CHAR *n, LONGINT n__len, LONGINT *h);
import BOOLEAN Platform_NoSuchDirectory (INTEGER e);
import LONGINT Platform_OSAllocate (LONGINT size);
import void Platform_OSFree (LONGINT address);
import INTEGER Platform_OldRO (CHAR *n, LONGINT n__len, LONGINT *h);
import INTEGER Platform_OldRW (CHAR *n, LONGINT n__len, LONGINT *h);
import INTEGER Platform_Read (LONGINT h, LONGINT p, LONGINT l, LONGINT *n);
import INTEGER Platform_ReadBuf (LONGINT h, SYSTEM_BYTE *b, LONGINT b__len, LONGINT *n);
import INTEGER Platform_Rename (CHAR *o, LONGINT o__len, CHAR *n, LONGINT n__len);
import void Platform_SecondsToClock (LONGINT s, LONGINT *t, LONGINT *d);
import INTEGER Platform_Seek (LONGINT h, LONGINT o, INTEGER r);
import void Platform_SetBadInstructionHandler (Platform_SignalHandler handler);
import void Platform_SetHalt (Platform_HaltProcedure p);
import void Platform_SetInterruptHandler (Platform_SignalHandler handler);
import void Platform_SetQuitHandler (Platform_SignalHandler handler);
import INTEGER Platform_Size (LONGINT h, LONGINT *l);
import INTEGER Platform_Sync (LONGINT h);
import INTEGER Platform_System (CHAR *cmd, LONGINT cmd__len);
import LONGINT Platform_Time (void);
import BOOLEAN Platform_TooManyFiles (INTEGER e);
import INTEGER Platform_Truncate (LONGINT h, LONGINT l);
import INTEGER Platform_Unlink (CHAR *n, LONGINT n__len);
import INTEGER Platform_Write (LONGINT h, LONGINT p, LONGINT l);
import INTEGER Platform_WriteBuf (LONGINT h, SYSTEM_BYTE *b, LONGINT b__len);
import BOOLEAN Platform_getEnv (CHAR *var, LONGINT var__len, CHAR *val, LONGINT val__len);
import void *Platform__init(void);


#endif
