/* voc  Oberon compiler olang 0.5 [2016/03/14] for cygwin ILP32 using gcc xtspkaSF */

#ifndef OPV__h
#define OPV__h

#include "SYSTEM.h"
#include "OPT.h"




import void OPV_AdrAndSize (OPT_Object topScope);
import void OPV_Init (void);
import void OPV_Module (OPT_Node prog);
import void OPV_TypSize (OPT_Struct typ);
import void *OPV__init(void);


#endif
