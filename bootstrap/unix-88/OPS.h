/* voc  Oberon compiler olang 0.5 [2016/03/14] for cygwin ILP32 using gcc tspkaSF */

#ifndef OPS__h
#define OPS__h

#include "SYSTEM.h"

typedef
	CHAR OPS_Name[256];

typedef
	CHAR OPS_String[256];


import OPS_Name OPS_name;
import OPS_String OPS_str;
import INTEGER OPS_numtyp;
import LONGINT OPS_intval;
import REAL OPS_realval;
import LONGREAL OPS_lrlval;


import void OPS_Get (SHORTINT *sym);
import void OPS_Init (void);
import void *OPS__init(void);


#endif
