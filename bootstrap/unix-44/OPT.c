/* voc  Oberon compiler olang 0.5 [2016/03/14] for cygwin ILP32 using gcc xtspkaSF */
#include "SYSTEM.h"
#include "OPM.h"
#include "OPS.h"

typedef
	struct OPT_ConstDesc *OPT_Const;

typedef
	OPS_String *OPT_ConstExt;

typedef
	struct OPT_ConstDesc {
		OPT_ConstExt ext;
		LONGINT intval, intval2;
		SET setval;
		LONGREAL realval;
	} OPT_ConstDesc;

typedef
	struct OPT_ExpCtxt {
		LONGINT reffp;
		INTEGER ref;
		SHORTINT nofm;
		SHORTINT locmno[64];
	} OPT_ExpCtxt;

typedef
	struct OPT_StrDesc *OPT_Struct;

typedef
	struct OPT_ObjDesc *OPT_Object;

typedef
	struct OPT_ImpCtxt {
		LONGINT nextTag, reffp;
		INTEGER nofr, minr, nofm;
		BOOLEAN self;
		OPT_Struct ref[255];
		OPT_Object old[255];
		LONGINT pvfp[255];
		SHORTINT glbmno[64];
	} OPT_ImpCtxt;

typedef
	struct OPT_NodeDesc *OPT_Node;

typedef
	struct OPT_NodeDesc {
		OPT_Node left, right, link;
		SHORTINT class, subcl;
		BOOLEAN readonly;
		OPT_Struct typ;
		OPT_Object obj;
		OPT_Const conval;
	} OPT_NodeDesc;

typedef
	struct OPT_ObjDesc {
		OPT_Object left, right, link, scope;
		OPS_Name name;
		BOOLEAN leaf;
		SHORTINT mode, mnolev, vis, history;
		BOOLEAN used, fpdone;
		LONGINT fprint;
		OPT_Struct typ;
		OPT_Const conval;
		LONGINT adr, linkadr;
		INTEGER x;
	} OPT_ObjDesc;

typedef
	struct OPT_StrDesc {
		SHORTINT form, comp, mno, extlev;
		INTEGER ref, sysflag;
		LONGINT n, size, align, txtpos;
		BOOLEAN allocated, pbused, pvused, fpdone, idfpdone;
		LONGINT idfp, pbfp, pvfp;
		OPT_Struct BaseTyp;
		OPT_Object link, strobj;
	} OPT_StrDesc;


export void (*OPT_typSize)(OPT_Struct);
export OPT_Object OPT_topScope;
export OPT_Struct OPT_undftyp, OPT_bytetyp, OPT_booltyp, OPT_chartyp, OPT_sinttyp, OPT_inttyp, OPT_linttyp, OPT_realtyp, OPT_lrltyp, OPT_settyp, OPT_stringtyp, OPT_niltyp, OPT_notyp, OPT_sysptrtyp;
export SHORTINT OPT_nofGmod;
export OPT_Object OPT_GlbMod[64];
export OPS_Name OPT_SelfName;
export BOOLEAN OPT_SYSimported;
static OPT_Object OPT_universe, OPT_syslink;
static OPT_ImpCtxt OPT_impCtxt;
static OPT_ExpCtxt OPT_expCtxt;
static LONGINT OPT_nofhdfld;
static BOOLEAN OPT_newsf, OPT_findpc, OPT_extsf, OPT_sfpresent, OPT_symExtended, OPT_symNew;

export LONGINT *OPT_ConstDesc__typ;
export LONGINT *OPT_ObjDesc__typ;
export LONGINT *OPT_StrDesc__typ;
export LONGINT *OPT_NodeDesc__typ;
export LONGINT *OPT_ImpCtxt__typ;
export LONGINT *OPT_ExpCtxt__typ;

export void OPT_Close (void);
export void OPT_CloseScope (void);
static void OPT_DebugStruct (OPT_Struct btyp);
static void OPT_EnterBoolConst (OPS_Name name, LONGINT value);
static void OPT_EnterProc (OPS_Name name, INTEGER num);
static void OPT_EnterTyp (OPS_Name name, SHORTINT form, INTEGER size, OPT_Struct *res);
export void OPT_Export (BOOLEAN *ext, BOOLEAN *new);
export void OPT_FPrintErr (OPT_Object obj, INTEGER errcode);
static void OPT_FPrintName (LONGINT *fp, CHAR *name, LONGINT name__len);
export void OPT_FPrintObj (OPT_Object obj);
static void OPT_FPrintSign (LONGINT *fp, OPT_Struct result, OPT_Object par);
export void OPT_FPrintStr (OPT_Struct typ);
export void OPT_Find (OPT_Object *res);
export void OPT_FindField (OPS_Name name, OPT_Struct typ, OPT_Object *res);
export void OPT_FindImport (OPT_Object mod, OPT_Object *res);
export void OPT_IdFPrint (OPT_Struct typ);
export void OPT_Import (OPS_Name aliasName, OPS_Name name, BOOLEAN *done);
static void OPT_InConstant (LONGINT f, OPT_Const conval);
static OPT_Object OPT_InFld (void);
static void OPT_InMod (SHORTINT *mno);
static void OPT_InName (CHAR *name, LONGINT name__len);
static OPT_Object OPT_InObj (SHORTINT mno);
static void OPT_InSign (SHORTINT mno, OPT_Struct *res, OPT_Object *par);
static void OPT_InStruct (OPT_Struct *typ);
static OPT_Object OPT_InTProc (SHORTINT mno);
export void OPT_Init (OPS_Name name, SET opt);
static void OPT_InitStruct (OPT_Struct *typ, SHORTINT form);
export void OPT_Insert (OPS_Name name, OPT_Object *obj);
export void OPT_InsertImport (OPT_Object obj, OPT_Object *root, OPT_Object *old);
export OPT_Const OPT_NewConst (void);
export OPT_ConstExt OPT_NewExt (void);
export OPT_Node OPT_NewNode (SHORTINT class);
export OPT_Object OPT_NewObj (void);
export OPT_Struct OPT_NewStr (SHORTINT form, SHORTINT comp);
export void OPT_OpenScope (SHORTINT level, OPT_Object owner);
static void OPT_OutConstant (OPT_Object obj);
static void OPT_OutFlds (OPT_Object fld, LONGINT adr, BOOLEAN visible);
static void OPT_OutHdFld (OPT_Struct typ, OPT_Object fld, LONGINT adr);
static void OPT_OutMod (INTEGER mno);
static void OPT_OutName (CHAR *name, LONGINT name__len);
static void OPT_OutObj (OPT_Object obj);
static void OPT_OutSign (OPT_Struct result, OPT_Object par);
static void OPT_OutStr (OPT_Struct typ);
static void OPT_OutTProcs (OPT_Struct typ, OPT_Object obj);
static void OPT_err (INTEGER n);


static void OPT_err (INTEGER n)
{
	OPM_err(n);
}

OPT_Const OPT_NewConst (void)
{
	OPT_Const _o_result;
	OPT_Const const_ = NIL;
	__NEW(const_, OPT_ConstDesc);
	_o_result = const_;
	return _o_result;
}

OPT_Object OPT_NewObj (void)
{
	OPT_Object _o_result;
	OPT_Object obj = NIL;
	__NEW(obj, OPT_ObjDesc);
	_o_result = obj;
	return _o_result;
}

OPT_Struct OPT_NewStr (SHORTINT form, SHORTINT comp)
{
	OPT_Struct _o_result;
	OPT_Struct typ = NIL;
	__NEW(typ, OPT_StrDesc);
	typ->form = form;
	typ->comp = comp;
	typ->ref = 255;
	if (form != 0) {
		typ->txtpos = OPM_errpos;
	}
	typ->size = -1;
	typ->BaseTyp = OPT_undftyp;
	_o_result = typ;
	return _o_result;
}

OPT_Node OPT_NewNode (SHORTINT class)
{
	OPT_Node _o_result;
	OPT_Node node = NIL;
	__NEW(node, OPT_NodeDesc);
	node->class = class;
	_o_result = node;
	return _o_result;
}

OPT_ConstExt OPT_NewExt (void)
{
	OPT_ConstExt _o_result;
	OPT_ConstExt ext = NIL;
	ext = __NEWARR(NIL, ((LONGINT)(1)), 1, 1, 0, (LONGINT)256);
	_o_result = ext;
	return _o_result;
}

void OPT_OpenScope (SHORTINT level, OPT_Object owner)
{
	OPT_Object head = NIL;
	head = OPT_NewObj();
	head->mode = 12;
	head->mnolev = level;
	head->link = owner;
	if (owner != NIL) {
		owner->scope = head;
	}
	head->left = OPT_topScope;
	head->right = NIL;
	head->scope = NIL;
	OPT_topScope = head;
}

void OPT_CloseScope (void)
{
	OPT_topScope = OPT_topScope->left;
}

void OPT_Init (OPS_Name name, SET opt)
{
	OPT_topScope = OPT_universe;
	OPT_OpenScope(0, NIL);
	OPT_SYSimported = 0;
	__MOVE(name, OPT_SelfName, 256);
	__MOVE(name, OPT_topScope->name, 256);
	OPT_GlbMod[0] = OPT_topScope;
	OPT_nofGmod = 1;
	OPT_newsf = __IN(4, opt);
	OPT_findpc = __IN(8, opt);
	OPT_extsf = OPT_newsf || __IN(9, opt);
	OPT_sfpresent = 1;
}

void OPT_Close (void)
{
	INTEGER i;
	OPT_CloseScope();
	i = 0;
	while (i < 64) {
		OPT_GlbMod[__X(i, ((LONGINT)(64)))] = NIL;
		i += 1;
	}
	i = 16;
	while (i < 255) {
		OPT_impCtxt.ref[__X(i, ((LONGINT)(255)))] = NIL;
		OPT_impCtxt.old[__X(i, ((LONGINT)(255)))] = NIL;
		i += 1;
	}
}

void OPT_FindImport (OPT_Object mod, OPT_Object *res)
{
	OPT_Object obj = NIL;
	obj = mod->scope;
	for (;;) {
		if (obj == NIL) {
			break;
		}
		if (__STRCMP(OPS_name, obj->name) < 0) {
			obj = obj->left;
		} else if (__STRCMP(OPS_name, obj->name) > 0) {
			obj = obj->right;
		} else {
			if ((obj->mode == 5 && obj->vis == 0)) {
				obj = NIL;
			} else {
				obj->used = 1;
			}
			break;
		}
	}
	*res = obj;
}

void OPT_Find (OPT_Object *res)
{
	OPT_Object obj = NIL, head = NIL;
	head = OPT_topScope;
	for (;;) {
		obj = head->right;
		for (;;) {
			if (obj == NIL) {
				break;
			}
			if (__STRCMP(OPS_name, obj->name) < 0) {
				obj = obj->left;
			} else if (__STRCMP(OPS_name, obj->name) > 0) {
				obj = obj->right;
			} else {
				break;
			}
		}
		if (obj != NIL) {
			break;
		}
		head = head->left;
		if (head == NIL) {
			break;
		}
	}
	*res = obj;
}

void OPT_FindField (OPS_Name name, OPT_Struct typ, OPT_Object *res)
{
	OPT_Object obj = NIL;
	while (typ != NIL) {
		obj = typ->link;
		while (obj != NIL) {
			if (__STRCMP(name, obj->name) < 0) {
				obj = obj->left;
			} else if (__STRCMP(name, obj->name) > 0) {
				obj = obj->right;
			} else {
				*res = obj;
				return;
			}
		}
		typ = typ->BaseTyp;
	}
	*res = NIL;
}

void OPT_Insert (OPS_Name name, OPT_Object *obj)
{
	OPT_Object ob0 = NIL, ob1 = NIL;
	BOOLEAN left;
	SHORTINT mnolev;
	ob0 = OPT_topScope;
	ob1 = ob0->right;
	left = 0;
	for (;;) {
		if (ob1 != NIL) {
			if (__STRCMP(name, ob1->name) < 0) {
				ob0 = ob1;
				ob1 = ob0->left;
				left = 1;
			} else if (__STRCMP(name, ob1->name) > 0) {
				ob0 = ob1;
				ob1 = ob0->right;
				left = 0;
			} else {
				OPT_err(1);
				ob0 = ob1;
				ob1 = ob0->right;
			}
		} else {
			ob1 = OPT_NewObj();
			ob1->leaf = 1;
			if (left) {
				ob0->left = ob1;
			} else {
				ob0->right = ob1;
			}
			ob1->left = NIL;
			ob1->right = NIL;
			__COPY(name, ob1->name, ((LONGINT)(256)));
			mnolev = OPT_topScope->mnolev;
			ob1->mnolev = mnolev;
			break;
		}
	}
	*obj = ob1;
}

static void OPT_FPrintName (LONGINT *fp, CHAR *name, LONGINT name__len)
{
	INTEGER i;
	CHAR ch;
	i = 0;
	do {
		ch = name[__X(i, name__len)];
		OPM_FPrint(&*fp, (int)ch);
		i += 1;
	} while (!(ch == 0x00));
}

static void OPT_DebugStruct (OPT_Struct btyp)
{
	OPM_LogLn();
	if (btyp == NIL) {
		OPM_LogWStr((CHAR*)"btyp is nil", (LONGINT)12);
		OPM_LogLn();
	}
	OPM_LogWStr((CHAR*)"btyp^.strobji^.name = ", (LONGINT)23);
	OPM_LogWStr(btyp->strobj->name, ((LONGINT)(256)));
	OPM_LogLn();
	OPM_LogWStr((CHAR*)"btyp^.form = ", (LONGINT)14);
	OPM_LogWInt(btyp->form, ((LONGINT)(0)));
	OPM_LogLn();
	OPM_LogWStr((CHAR*)"btyp^.comp = ", (LONGINT)14);
	OPM_LogWInt(btyp->comp, ((LONGINT)(0)));
	OPM_LogLn();
	OPM_LogWStr((CHAR*)"btyp^.mno = ", (LONGINT)13);
	OPM_LogWInt(btyp->mno, ((LONGINT)(0)));
	OPM_LogLn();
	OPM_LogWStr((CHAR*)"btyp^.extlev = ", (LONGINT)16);
	OPM_LogWInt(btyp->extlev, ((LONGINT)(0)));
	OPM_LogLn();
	OPM_LogWStr((CHAR*)"btyp^.size = ", (LONGINT)14);
	OPM_LogWInt(btyp->size, ((LONGINT)(0)));
	OPM_LogLn();
	OPM_LogWStr((CHAR*)"btyp^.align = ", (LONGINT)15);
	OPM_LogWInt(btyp->align, ((LONGINT)(0)));
	OPM_LogLn();
	OPM_LogWStr((CHAR*)"btyp^.txtpos = ", (LONGINT)16);
	OPM_LogWInt(btyp->txtpos, ((LONGINT)(0)));
	OPM_LogLn();
}

static void OPT_FPrintSign (LONGINT *fp, OPT_Struct result, OPT_Object par)
{
	OPT_IdFPrint(result);
	OPM_FPrint(&*fp, result->idfp);
	while (par != NIL) {
		OPM_FPrint(&*fp, par->mode);
		OPT_IdFPrint(par->typ);
		OPM_FPrint(&*fp, par->typ->idfp);
		par = par->link;
	}
}

void OPT_IdFPrint (OPT_Struct typ)
{
	OPT_Struct btyp = NIL;
	OPT_Object strobj = NIL;
	LONGINT idfp;
	INTEGER f, c;
	if (!typ->idfpdone) {
		typ->idfpdone = 1;
		idfp = 0;
		f = typ->form;
		c = typ->comp;
		OPM_FPrint(&idfp, f);
		OPM_FPrint(&idfp, c);
		btyp = typ->BaseTyp;
		strobj = typ->strobj;
		if ((strobj != NIL && strobj->name[0] != 0x00)) {
			OPT_FPrintName(&idfp, (void*)OPT_GlbMod[__X(typ->mno, ((LONGINT)(64)))]->name, ((LONGINT)(256)));
			OPT_FPrintName(&idfp, (void*)strobj->name, ((LONGINT)(256)));
		}
		if ((f == 13 || (c == 4 && btyp != NIL)) || c == 3) {
			OPT_IdFPrint(btyp);
			OPM_FPrint(&idfp, btyp->idfp);
		} else if (c == 2) {
			OPT_IdFPrint(btyp);
			OPM_FPrint(&idfp, btyp->idfp);
			OPM_FPrint(&idfp, typ->n);
		} else if (f == 14) {
			OPT_FPrintSign(&idfp, btyp, typ->link);
		}
		typ->idfp = idfp;
	}
}

static struct FPrintStr__12 {
	LONGINT *pbfp, *pvfp;
	struct FPrintStr__12 *lnk;
} *FPrintStr__12_s;

static void FPrintFlds__13 (OPT_Object fld, LONGINT adr, BOOLEAN visible);
static void FPrintHdFld__15 (OPT_Struct typ, OPT_Object fld, LONGINT adr);
static void FPrintTProcs__17 (OPT_Object obj);

static void FPrintHdFld__15 (OPT_Struct typ, OPT_Object fld, LONGINT adr)
{
	LONGINT i, j, n;
	OPT_Struct btyp = NIL;
	if (typ->comp == 4) {
		FPrintFlds__13(typ->link, adr, 0);
	} else if (typ->comp == 2) {
		btyp = typ->BaseTyp;
		n = typ->n;
		while (btyp->comp == 2) {
			n = btyp->n * n;
			btyp = btyp->BaseTyp;
		}
		if (btyp->form == 13 || btyp->comp == 4) {
			j = OPT_nofhdfld;
			FPrintHdFld__15(btyp, fld, adr);
			if (j != OPT_nofhdfld) {
				i = 1;
				while ((i < n && OPT_nofhdfld <= 2048)) {
					adr += btyp->size;
					FPrintHdFld__15(btyp, fld, adr);
					i += 1;
				}
			}
		}
	} else if (typ->form == 13 || __STRCMP(fld->name, "@ptr") == 0) {
		OPM_FPrint(&*FPrintStr__12_s->pvfp, ((LONGINT)(13)));
		OPM_FPrint(&*FPrintStr__12_s->pvfp, adr);
		OPT_nofhdfld += 1;
	}
}

static void FPrintFlds__13 (OPT_Object fld, LONGINT adr, BOOLEAN visible)
{
	while ((fld != NIL && fld->mode == 4)) {
		if ((fld->vis != 0 && visible)) {
			OPM_FPrint(&*FPrintStr__12_s->pbfp, fld->vis);
			OPT_FPrintName(&*FPrintStr__12_s->pbfp, (void*)fld->name, ((LONGINT)(256)));
			OPM_FPrint(&*FPrintStr__12_s->pbfp, fld->adr);
			OPT_FPrintStr(fld->typ);
			OPM_FPrint(&*FPrintStr__12_s->pbfp, fld->typ->pbfp);
			OPM_FPrint(&*FPrintStr__12_s->pvfp, fld->typ->pvfp);
		} else {
			FPrintHdFld__15(fld->typ, fld, fld->adr + adr);
		}
		fld = fld->link;
	}
}

static void FPrintTProcs__17 (OPT_Object obj)
{
	if (obj != NIL) {
		FPrintTProcs__17(obj->left);
		if (obj->mode == 13) {
			if (obj->vis != 0) {
				OPM_FPrint(&*FPrintStr__12_s->pbfp, ((LONGINT)(13)));
				OPM_FPrint(&*FPrintStr__12_s->pbfp, __ASHR(obj->adr, 16));
				OPT_FPrintSign(&*FPrintStr__12_s->pbfp, obj->typ, obj->link);
				OPT_FPrintName(&*FPrintStr__12_s->pbfp, (void*)obj->name, ((LONGINT)(256)));
			}
		}
		FPrintTProcs__17(obj->right);
	}
}

void OPT_FPrintStr (OPT_Struct typ)
{
	INTEGER f, c;
	OPT_Struct btyp = NIL;
	OPT_Object strobj = NIL, bstrobj = NIL;
	LONGINT pbfp, pvfp;
	struct FPrintStr__12 _s;
	_s.pbfp = &pbfp;
	_s.pvfp = &pvfp;
	_s.lnk = FPrintStr__12_s;
	FPrintStr__12_s = &_s;
	if (!typ->fpdone) {
		OPT_IdFPrint(typ);
		pbfp = typ->idfp;
		if (typ->sysflag != 0) {
			OPM_FPrint(&pbfp, typ->sysflag);
		}
		pvfp = pbfp;
		typ->pbfp = pbfp;
		typ->pvfp = pvfp;
		typ->fpdone = 1;
		f = typ->form;
		c = typ->comp;
		btyp = typ->BaseTyp;
		if (f == 13) {
			strobj = typ->strobj;
			bstrobj = btyp->strobj;
			if (((strobj == NIL || strobj->name[0] == 0x00) || bstrobj == NIL) || bstrobj->name[0] == 0x00) {
				OPT_FPrintStr(btyp);
				OPM_FPrint(&pbfp, btyp->pbfp);
				pvfp = pbfp;
			}
		} else if (f == 14) {
		} else if (__IN(c, 0x0c)) {
			OPT_FPrintStr(btyp);
			OPM_FPrint(&pbfp, btyp->pvfp);
			pvfp = pbfp;
		} else {
			if (btyp != NIL) {
				OPT_FPrintStr(btyp);
				OPM_FPrint(&pbfp, btyp->pbfp);
				OPM_FPrint(&pvfp, btyp->pvfp);
			}
			OPM_FPrint(&pvfp, typ->size);
			OPM_FPrint(&pvfp, typ->align);
			OPM_FPrint(&pvfp, typ->n);
			OPT_nofhdfld = 0;
			FPrintFlds__13(typ->link, ((LONGINT)(0)), 1);
			if (OPT_nofhdfld > 2048) {
				OPM_Mark(225, typ->txtpos);
			}
			FPrintTProcs__17(typ->link);
			OPM_FPrint(&pvfp, pbfp);
			strobj = typ->strobj;
			if (strobj == NIL || strobj->name[0] == 0x00) {
				pbfp = pvfp;
			}
		}
		typ->pbfp = pbfp;
		typ->pvfp = pvfp;
	}
	FPrintStr__12_s = _s.lnk;
}

void OPT_FPrintObj (OPT_Object obj)
{
	LONGINT fprint;
	INTEGER f, m;
	REAL rval;
	OPT_ConstExt ext = NIL;
	if (!obj->fpdone) {
		fprint = 0;
		obj->fpdone = 1;
		OPM_FPrint(&fprint, obj->mode);
		if (obj->mode == 3) {
			f = obj->typ->form;
			OPM_FPrint(&fprint, f);
			switch (f) {
				case 2: case 3: case 4: case 5: case 6: 
					OPM_FPrint(&fprint, obj->conval->intval);
					break;
				case 9: 
					OPM_FPrintSet(&fprint, obj->conval->setval);
					break;
				case 7: 
					rval = obj->conval->realval;
					OPM_FPrintReal(&fprint, rval);
					break;
				case 8: 
					OPM_FPrintLReal(&fprint, obj->conval->realval);
					break;
				case 10: 
					OPT_FPrintName(&fprint, (void*)*obj->conval->ext, ((LONGINT)(256)));
					break;
				case 11: 
					break;
				default: 
					OPT_err(127);
					break;
			}
		} else if (obj->mode == 1) {
			OPM_FPrint(&fprint, obj->vis);
			OPT_FPrintStr(obj->typ);
			OPM_FPrint(&fprint, obj->typ->pbfp);
		} else if (__IN(obj->mode, 0x0480)) {
			OPT_FPrintSign(&fprint, obj->typ, obj->link);
		} else if (obj->mode == 9) {
			OPT_FPrintSign(&fprint, obj->typ, obj->link);
			ext = obj->conval->ext;
			m = (int)(*ext)[0];
			f = 1;
			OPM_FPrint(&fprint, m);
			while (f <= m) {
				OPM_FPrint(&fprint, (int)(*ext)[__X(f, ((LONGINT)(256)))]);
				f += 1;
			}
		} else if (obj->mode == 5) {
			OPT_FPrintStr(obj->typ);
			OPM_FPrint(&fprint, obj->typ->pbfp);
		}
		obj->fprint = fprint;
	}
}

void OPT_FPrintErr (OPT_Object obj, INTEGER errcode)
{
	INTEGER i, j;
	CHAR ch;
	if (obj->mnolev != 0) {
		__COPY(OPT_GlbMod[__X(-obj->mnolev, ((LONGINT)(64)))]->name, OPM_objname, ((LONGINT)(64)));
		i = 0;
		while (OPM_objname[__X(i, ((LONGINT)(64)))] != 0x00) {
			i += 1;
		}
		OPM_objname[__X(i, ((LONGINT)(64)))] = '.';
		j = 0;
		i += 1;
		do {
			ch = obj->name[__X(j, ((LONGINT)(256)))];
			OPM_objname[__X(i, ((LONGINT)(64)))] = ch;
			j += 1;
			i += 1;
		} while (!(ch == 0x00));
	} else {
		__COPY(obj->name, OPM_objname, ((LONGINT)(64)));
	}
	if (errcode == 249) {
		if (OPM_noerr) {
			OPT_err(errcode);
		}
	} else if (errcode == 253) {
		if ((((!OPT_symNew && !OPT_symExtended)) && !OPT_extsf)) {
			OPT_err(errcode);
		}
		OPT_symExtended = 1;
	} else {
		if ((!OPT_symNew && !OPT_newsf)) {
			OPT_err(errcode);
		}
		OPT_symNew = 1;
	}
}

void OPT_InsertImport (OPT_Object obj, OPT_Object *root, OPT_Object *old)
{
	OPT_Object ob0 = NIL, ob1 = NIL;
	BOOLEAN left;
	if (*root == NIL) {
		*root = obj;
		*old = NIL;
	} else {
		ob0 = *root;
		ob1 = ob0->right;
		left = 0;
		if (__STRCMP(obj->name, ob0->name) < 0) {
			ob1 = ob0->left;
			left = 1;
		} else if (__STRCMP(obj->name, ob0->name) > 0) {
			ob1 = ob0->right;
			left = 0;
		} else {
			*old = ob0;
			return;
		}
		for (;;) {
			if (ob1 != NIL) {
				if (__STRCMP(obj->name, ob1->name) < 0) {
					ob0 = ob1;
					ob1 = ob1->left;
					left = 1;
				} else if (__STRCMP(obj->name, ob1->name) > 0) {
					ob0 = ob1;
					ob1 = ob1->right;
					left = 0;
				} else {
					*old = ob1;
					break;
				}
			} else {
				ob1 = obj;
				if (left) {
					ob0->left = ob1;
				} else {
					ob0->right = ob1;
				}
				ob1->left = NIL;
				ob1->right = NIL;
				*old = NIL;
				break;
			}
		}
	}
}

static void OPT_InName (CHAR *name, LONGINT name__len)
{
	INTEGER i;
	CHAR ch;
	i = 0;
	do {
		OPM_SymRCh(&ch);
		name[__X(i, name__len)] = ch;
		i += 1;
	} while (!(ch == 0x00));
}

static void OPT_InMod (SHORTINT *mno)
{
	OPT_Object head = NIL;
	OPS_Name name;
	LONGINT mn;
	SHORTINT i;
	mn = OPM_SymRInt();
	if (mn == 0) {
		*mno = OPT_impCtxt.glbmno[0];
	} else {
		if (mn == 16) {
			OPT_InName((void*)name, ((LONGINT)(256)));
			if ((__STRCMP(name, OPT_SelfName) == 0 && !OPT_impCtxt.self)) {
				OPT_err(154);
			}
			i = 0;
			while ((i < OPT_nofGmod && __STRCMP(name, OPT_GlbMod[__X(i, ((LONGINT)(64)))]->name) != 0)) {
				i += 1;
			}
			if (i < OPT_nofGmod) {
				*mno = i;
			} else {
				head = OPT_NewObj();
				head->mode = 12;
				__COPY(name, head->name, ((LONGINT)(256)));
				*mno = OPT_nofGmod;
				head->mnolev = -*mno;
				if (OPT_nofGmod < 64) {
					OPT_GlbMod[__X(*mno, ((LONGINT)(64)))] = head;
					OPT_nofGmod += 1;
				} else {
					OPT_err(227);
				}
			}
			OPT_impCtxt.glbmno[__X(OPT_impCtxt.nofm, ((LONGINT)(64)))] = *mno;
			OPT_impCtxt.nofm += 1;
		} else {
			*mno = OPT_impCtxt.glbmno[__X(-mn, ((LONGINT)(64)))];
		}
	}
}

static void OPT_InConstant (LONGINT f, OPT_Const conval)
{
	CHAR ch;
	INTEGER i;
	OPT_ConstExt ext = NIL;
	REAL rval;
	switch (f) {
		case 1: case 3: case 2: 
			OPM_SymRCh(&ch);
			conval->intval = (int)ch;
			break;
		case 4: case 5: case 6: 
			conval->intval = OPM_SymRInt();
			break;
		case 9: 
			OPM_SymRSet(&conval->setval);
			break;
		case 7: 
			OPM_SymRReal(&rval);
			conval->realval = rval;
			conval->intval = -1;
			break;
		case 8: 
			OPM_SymRLReal(&conval->realval);
			conval->intval = -1;
			break;
		case 10: 
			ext = OPT_NewExt();
			conval->ext = ext;
			i = 0;
			do {
				OPM_SymRCh(&ch);
				(*ext)[__X(i, ((LONGINT)(256)))] = ch;
				i += 1;
			} while (!(ch == 0x00));
			conval->intval2 = i;
			conval->intval = -1;
			break;
		case 11: 
			conval->intval = 0;
			break;
		default: 
			OPM_LogWStr((CHAR*)"unhandled case in OPT.InConstant(), f = ", (LONGINT)41);
			OPM_LogWInt(f, ((LONGINT)(0)));
			OPM_LogLn();
			break;
	}
}

static void OPT_InSign (SHORTINT mno, OPT_Struct *res, OPT_Object *par)
{
	OPT_Object last = NIL, new = NIL;
	LONGINT tag;
	OPT_InStruct(&*res);
	tag = OPM_SymRInt();
	last = NIL;
	while (tag != 18) {
		new = OPT_NewObj();
		new->mnolev = -mno;
		if (last == NIL) {
			*par = new;
		} else {
			last->link = new;
		}
		if (tag == 23) {
			new->mode = 1;
		} else {
			new->mode = 2;
		}
		OPT_InStruct(&new->typ);
		new->adr = OPM_SymRInt();
		OPT_InName((void*)new->name, ((LONGINT)(256)));
		last = new;
		tag = OPM_SymRInt();
	}
}

static OPT_Object OPT_InFld (void)
{
	OPT_Object _o_result;
	LONGINT tag;
	OPT_Object obj = NIL;
	tag = OPT_impCtxt.nextTag;
	obj = OPT_NewObj();
	if (tag <= 26) {
		obj->mode = 4;
		if (tag == 26) {
			obj->vis = 2;
		} else {
			obj->vis = 1;
		}
		OPT_InStruct(&obj->typ);
		OPT_InName((void*)obj->name, ((LONGINT)(256)));
		obj->adr = OPM_SymRInt();
	} else {
		obj->mode = 4;
		if (tag == 27) {
			__MOVE("@ptr", obj->name, 5);
		} else {
			__MOVE("@proc", obj->name, 6);
		}
		obj->typ = OPT_undftyp;
		obj->vis = 0;
		obj->adr = OPM_SymRInt();
	}
	_o_result = obj;
	return _o_result;
}

static OPT_Object OPT_InTProc (SHORTINT mno)
{
	OPT_Object _o_result;
	LONGINT tag;
	OPT_Object obj = NIL;
	tag = OPT_impCtxt.nextTag;
	obj = OPT_NewObj();
	obj->mnolev = -mno;
	if (tag == 29) {
		obj->mode = 13;
		obj->conval = OPT_NewConst();
		obj->conval->intval = -1;
		OPT_InSign(mno, &obj->typ, &obj->link);
		obj->vis = 1;
		OPT_InName((void*)obj->name, ((LONGINT)(256)));
		obj->adr = __ASHL(OPM_SymRInt(), 16);
	} else {
		obj->mode = 13;
		__MOVE("@tproc", obj->name, 7);
		obj->link = OPT_NewObj();
		obj->typ = OPT_undftyp;
		obj->vis = 0;
		obj->adr = __ASHL(OPM_SymRInt(), 16);
	}
	_o_result = obj;
	return _o_result;
}

static void OPT_InStruct (OPT_Struct *typ)
{
	SHORTINT mno;
	INTEGER ref;
	LONGINT tag;
	OPS_Name name;
	OPT_Struct t = NIL;
	OPT_Object obj = NIL, last = NIL, fld = NIL, old = NIL, dummy = NIL;
	tag = OPM_SymRInt();
	if (tag != 34) {
		*typ = OPT_impCtxt.ref[__X(-tag, ((LONGINT)(255)))];
	} else {
		ref = OPT_impCtxt.nofr;
		OPT_impCtxt.nofr += 1;
		if (ref < OPT_impCtxt.minr) {
			OPT_impCtxt.minr = ref;
		}
		OPT_InMod(&mno);
		OPT_InName((void*)name, ((LONGINT)(256)));
		obj = OPT_NewObj();
		if (name[0] == 0x00) {
			if (OPT_impCtxt.self) {
				old = NIL;
			} else {
				__MOVE("@", obj->name, 2);
				OPT_InsertImport(obj, &OPT_GlbMod[__X(mno, ((LONGINT)(64)))]->right, &old);
				obj->name[0] = 0x00;
			}
			*typ = OPT_NewStr(0, 1);
		} else {
			__MOVE(name, obj->name, 256);
			OPT_InsertImport(obj, &OPT_GlbMod[__X(mno, ((LONGINT)(64)))]->right, &old);
			if (old != NIL) {
				OPT_FPrintObj(old);
				OPT_impCtxt.pvfp[__X(ref, ((LONGINT)(255)))] = old->typ->pvfp;
				if (OPT_impCtxt.self) {
					*typ = OPT_NewStr(0, 1);
				} else {
					*typ = old->typ;
					(*typ)->link = NIL;
					(*typ)->sysflag = 0;
					(*typ)->fpdone = 0;
					(*typ)->idfpdone = 0;
				}
			} else {
				*typ = OPT_NewStr(0, 1);
			}
		}
		OPT_impCtxt.ref[__X(ref, ((LONGINT)(255)))] = *typ;
		OPT_impCtxt.old[__X(ref, ((LONGINT)(255)))] = old;
		(*typ)->ref = ref + 255;
		(*typ)->mno = mno;
		(*typ)->allocated = 1;
		(*typ)->strobj = obj;
		obj->mode = 5;
		obj->typ = *typ;
		obj->mnolev = -mno;
		obj->vis = 0;
		tag = OPM_SymRInt();
		if (tag == 35) {
			(*typ)->sysflag = (int)OPM_SymRInt();
			tag = OPM_SymRInt();
		}
		switch (tag) {
			case 36: 
				(*typ)->form = 13;
				(*typ)->size = OPM_PointerSize;
				(*typ)->n = 0;
				OPT_InStruct(&(*typ)->BaseTyp);
				break;
			case 37: 
				(*typ)->form = 15;
				(*typ)->comp = 2;
				OPT_InStruct(&(*typ)->BaseTyp);
				(*typ)->n = OPM_SymRInt();
				(*OPT_typSize)(*typ);
				break;
			case 38: 
				(*typ)->form = 15;
				(*typ)->comp = 3;
				OPT_InStruct(&(*typ)->BaseTyp);
				if ((*typ)->BaseTyp->comp == 3) {
					(*typ)->n = (*typ)->BaseTyp->n + 1;
				} else {
					(*typ)->n = 0;
				}
				(*OPT_typSize)(*typ);
				break;
			case 39: 
				(*typ)->form = 15;
				(*typ)->comp = 4;
				OPT_InStruct(&(*typ)->BaseTyp);
				if ((*typ)->BaseTyp == OPT_notyp) {
					(*typ)->BaseTyp = NIL;
				}
				(*typ)->extlev = 0;
				t = (*typ)->BaseTyp;
				while (t != NIL) {
					(*typ)->extlev += 1;
					t = t->BaseTyp;
				}
				(*typ)->size = OPM_SymRInt();
				(*typ)->align = OPM_SymRInt();
				(*typ)->n = OPM_SymRInt();
				OPT_impCtxt.nextTag = OPM_SymRInt();
				last = NIL;
				while ((OPT_impCtxt.nextTag >= 25 && OPT_impCtxt.nextTag <= 28)) {
					fld = OPT_InFld();
					fld->mnolev = -mno;
					if (last != NIL) {
						last->link = fld;
					}
					last = fld;
					OPT_InsertImport(fld, &(*typ)->link, &dummy);
					OPT_impCtxt.nextTag = OPM_SymRInt();
				}
				while (OPT_impCtxt.nextTag != 18) {
					fld = OPT_InTProc(mno);
					OPT_InsertImport(fld, &(*typ)->link, &dummy);
					OPT_impCtxt.nextTag = OPM_SymRInt();
				}
				break;
			case 40: 
				(*typ)->form = 14;
				(*typ)->size = OPM_ProcSize;
				OPT_InSign(mno, &(*typ)->BaseTyp, &(*typ)->link);
				break;
			default: 
				OPM_LogWStr((CHAR*)"unhandled case at OPT.InStruct, tag = ", (LONGINT)39);
				OPM_LogWInt(tag, ((LONGINT)(0)));
				OPM_LogLn();
				break;
		}
		if (ref == OPT_impCtxt.minr) {
			while (ref < OPT_impCtxt.nofr) {
				t = OPT_impCtxt.ref[__X(ref, ((LONGINT)(255)))];
				OPT_FPrintStr(t);
				obj = t->strobj;
				if (obj->name[0] != 0x00) {
					OPT_FPrintObj(obj);
				}
				old = OPT_impCtxt.old[__X(ref, ((LONGINT)(255)))];
				if (old != NIL) {
					t->strobj = old;
					if (OPT_impCtxt.self) {
						if (old->mnolev < 0) {
							if (old->history != 5) {
								if (old->fprint != obj->fprint) {
									old->history = 2;
								} else if (OPT_impCtxt.pvfp[__X(ref, ((LONGINT)(255)))] != t->pvfp) {
									old->history = 3;
								}
							}
						} else if (old->fprint != obj->fprint) {
							old->history = 2;
						} else if (OPT_impCtxt.pvfp[__X(ref, ((LONGINT)(255)))] != t->pvfp) {
							old->history = 3;
						} else if (old->vis == 0) {
							old->history = 1;
						} else {
							old->history = 0;
						}
					} else {
						if (OPT_impCtxt.pvfp[__X(ref, ((LONGINT)(255)))] != t->pvfp) {
							old->history = 5;
						}
						if (old->fprint != obj->fprint) {
							OPT_FPrintErr(old, 249);
						}
					}
				} else if (OPT_impCtxt.self) {
					obj->history = 4;
				} else {
					obj->history = 1;
				}
				ref += 1;
			}
			OPT_impCtxt.minr = 255;
		}
	}
}

static OPT_Object OPT_InObj (SHORTINT mno)
{
	OPT_Object _o_result;
	INTEGER i, s;
	CHAR ch;
	OPT_Object obj = NIL, old = NIL;
	OPT_Struct typ = NIL;
	LONGINT tag;
	OPT_ConstExt ext = NIL;
	tag = OPT_impCtxt.nextTag;
	if (tag == 19) {
		OPT_InStruct(&typ);
		obj = typ->strobj;
		if (!OPT_impCtxt.self) {
			obj->vis = 1;
		}
	} else {
		obj = OPT_NewObj();
		obj->mnolev = -mno;
		obj->vis = 1;
		if (tag <= 13) {
			obj->mode = 3;
			obj->typ = OPT_impCtxt.ref[__X(tag, ((LONGINT)(255)))];
			obj->conval = OPT_NewConst();
			OPT_InConstant(tag, obj->conval);
		} else if (tag >= 31) {
			obj->conval = OPT_NewConst();
			obj->conval->intval = -1;
			OPT_InSign(mno, &obj->typ, &obj->link);
			switch (tag) {
				case 31: 
					obj->mode = 7;
					break;
				case 32: 
					obj->mode = 10;
					break;
				case 33: 
					obj->mode = 9;
					ext = OPT_NewExt();
					obj->conval->ext = ext;
					s = (int)OPM_SymRInt();
					(*ext)[0] = (CHAR)s;
					i = 1;
					while (i <= s) {
						OPM_SymRCh(&(*ext)[__X(i, ((LONGINT)(256)))]);
						i += 1;
					}
					break;
				default: 
					OPM_LogWStr((CHAR*)"unhandled case at OPT.InObj, tag = ", (LONGINT)36);
					OPM_LogWInt(tag, ((LONGINT)(0)));
					OPM_LogLn();
					break;
			}
		} else if (tag == 20) {
			obj->mode = 5;
			OPT_InStruct(&obj->typ);
		} else {
			obj->mode = 1;
			if (tag == 22) {
				obj->vis = 2;
			}
			OPT_InStruct(&obj->typ);
		}
		OPT_InName((void*)obj->name, ((LONGINT)(256)));
	}
	OPT_FPrintObj(obj);
	if ((obj->mode == 1 && (obj->typ->strobj == NIL || obj->typ->strobj->name[0] == 0x00))) {
		OPM_FPrint(&OPT_impCtxt.reffp, obj->typ->ref - 255);
	}
	if (tag != 19) {
		OPT_InsertImport(obj, &OPT_GlbMod[__X(mno, ((LONGINT)(64)))]->right, &old);
		if (OPT_impCtxt.self) {
			if (old != NIL) {
				if (old->vis == 0) {
					old->history = 4;
				} else {
					OPT_FPrintObj(old);
					if (obj->fprint != old->fprint) {
						old->history = 2;
					} else if (obj->typ->pvfp != old->typ->pvfp) {
						old->history = 3;
					} else {
						old->history = 1;
					}
				}
			} else {
				obj->history = 4;
			}
		}
	} else {
		if (OPT_impCtxt.self) {
			if (obj->vis == 0) {
				obj->history = 4;
			} else if (obj->history == 0) {
				obj->history = 1;
			}
		}
	}
	_o_result = obj;
	return _o_result;
}

void OPT_Import (OPS_Name aliasName, OPS_Name name, BOOLEAN *done)
{
	OPT_Object obj = NIL;
	SHORTINT mno;
	OPS_Name aliasName__copy;
	__DUPARR(aliasName, OPS_Name);
	if (__STRCMP(name, "SYSTEM") == 0) {
		OPT_SYSimported = 1;
		OPT_Insert(aliasName, &obj);
		obj->mode = 11;
		obj->mnolev = 0;
		obj->scope = OPT_syslink;
		obj->typ = OPT_notyp;
	} else {
		OPT_impCtxt.nofr = 16;
		OPT_impCtxt.minr = 255;
		OPT_impCtxt.nofm = 0;
		OPT_impCtxt.self = __STRCMP(aliasName, "@self") == 0;
		OPT_impCtxt.reffp = 0;
		OPM_OldSym((void*)name, ((LONGINT)(256)), &*done);
		if (*done) {
			OPT_InMod(&mno);
			OPT_impCtxt.nextTag = OPM_SymRInt();
			while (!OPM_eofSF()) {
				obj = OPT_InObj(mno);
				OPT_impCtxt.nextTag = OPM_SymRInt();
			}
			OPT_Insert(aliasName, &obj);
			obj->mode = 11;
			obj->scope = OPT_GlbMod[__X(mno, ((LONGINT)(64)))]->right;
			OPT_GlbMod[__X(mno, ((LONGINT)(64)))]->link = obj;
			obj->mnolev = -mno;
			obj->typ = OPT_notyp;
			OPM_CloseOldSym();
		} else if (OPT_impCtxt.self) {
			OPT_newsf = 1;
			OPT_extsf = 1;
			OPT_sfpresent = 0;
		} else {
			OPT_err(152);
		}
	}
}

static void OPT_OutName (CHAR *name, LONGINT name__len)
{
	INTEGER i;
	CHAR ch;
	i = 0;
	do {
		ch = name[__X(i, name__len)];
		OPM_SymWCh(ch);
		i += 1;
	} while (!(ch == 0x00));
}

static void OPT_OutMod (INTEGER mno)
{
	if (OPT_expCtxt.locmno[__X(mno, ((LONGINT)(64)))] < 0) {
		OPM_SymWInt(((LONGINT)(16)));
		OPT_expCtxt.locmno[__X(mno, ((LONGINT)(64)))] = OPT_expCtxt.nofm;
		OPT_expCtxt.nofm += 1;
		OPT_OutName((void*)OPT_GlbMod[__X(mno, ((LONGINT)(64)))]->name, ((LONGINT)(256)));
	} else {
		OPM_SymWInt(-OPT_expCtxt.locmno[__X(mno, ((LONGINT)(64)))]);
	}
}

static void OPT_OutHdFld (OPT_Struct typ, OPT_Object fld, LONGINT adr)
{
	LONGINT i, j, n;
	OPT_Struct btyp = NIL;
	if (typ->comp == 4) {
		OPT_OutFlds(typ->link, adr, 0);
	} else if (typ->comp == 2) {
		btyp = typ->BaseTyp;
		n = typ->n;
		while (btyp->comp == 2) {
			n = btyp->n * n;
			btyp = btyp->BaseTyp;
		}
		if (btyp->form == 13 || btyp->comp == 4) {
			j = OPT_nofhdfld;
			OPT_OutHdFld(btyp, fld, adr);
			if (j != OPT_nofhdfld) {
				i = 1;
				while ((i < n && OPT_nofhdfld <= 2048)) {
					adr += btyp->size;
					OPT_OutHdFld(btyp, fld, adr);
					i += 1;
				}
			}
		}
	} else if (typ->form == 13 || __STRCMP(fld->name, "@ptr") == 0) {
		OPM_SymWInt(((LONGINT)(27)));
		OPM_SymWInt(adr);
		OPT_nofhdfld += 1;
	}
}

static void OPT_OutFlds (OPT_Object fld, LONGINT adr, BOOLEAN visible)
{
	while ((fld != NIL && fld->mode == 4)) {
		if ((fld->vis != 0 && visible)) {
			if (fld->vis == 2) {
				OPM_SymWInt(((LONGINT)(26)));
			} else {
				OPM_SymWInt(((LONGINT)(25)));
			}
			OPT_OutStr(fld->typ);
			OPT_OutName((void*)fld->name, ((LONGINT)(256)));
			OPM_SymWInt(fld->adr);
		} else {
			OPT_OutHdFld(fld->typ, fld, fld->adr + adr);
		}
		fld = fld->link;
	}
}

static void OPT_OutSign (OPT_Struct result, OPT_Object par)
{
	OPT_OutStr(result);
	while (par != NIL) {
		if (par->mode == 1) {
			OPM_SymWInt(((LONGINT)(23)));
		} else {
			OPM_SymWInt(((LONGINT)(24)));
		}
		OPT_OutStr(par->typ);
		OPM_SymWInt(par->adr);
		OPT_OutName((void*)par->name, ((LONGINT)(256)));
		par = par->link;
	}
	OPM_SymWInt(((LONGINT)(18)));
}

static void OPT_OutTProcs (OPT_Struct typ, OPT_Object obj)
{
	if (obj != NIL) {
		OPT_OutTProcs(typ, obj->left);
		if (obj->mode == 13) {
			if ((((typ->BaseTyp != NIL && __ASHR(obj->adr, 16) < typ->BaseTyp->n)) && obj->vis == 0)) {
				OPM_Mark(109, typ->txtpos);
			}
			if (obj->vis != 0) {
				if (obj->vis != 0) {
					OPM_SymWInt(((LONGINT)(29)));
					OPT_OutSign(obj->typ, obj->link);
					OPT_OutName((void*)obj->name, ((LONGINT)(256)));
					OPM_SymWInt(__ASHR(obj->adr, 16));
				} else {
					OPM_SymWInt(((LONGINT)(30)));
					OPM_SymWInt(__ASHR(obj->adr, 16));
				}
			}
		}
		OPT_OutTProcs(typ, obj->right);
	}
}

static void OPT_OutStr (OPT_Struct typ)
{
	OPT_Object strobj = NIL;
	if (typ->ref < OPT_expCtxt.ref) {
		OPM_SymWInt(-typ->ref);
	} else {
		OPM_SymWInt(((LONGINT)(34)));
		typ->ref = OPT_expCtxt.ref;
		OPT_expCtxt.ref += 1;
		if (OPT_expCtxt.ref >= 255) {
			OPT_err(228);
		}
		OPT_OutMod(typ->mno);
		strobj = typ->strobj;
		if ((strobj != NIL && strobj->name[0] != 0x00)) {
			OPT_OutName((void*)strobj->name, ((LONGINT)(256)));
			switch (strobj->history) {
				case 2: 
					OPT_FPrintErr(strobj, 252);
					break;
				case 3: 
					OPT_FPrintErr(strobj, 251);
					break;
				case 5: 
					OPT_FPrintErr(strobj, 249);
					break;
				default: 
					break;
			}
		} else {
			OPM_SymWCh(0x00);
		}
		if (typ->sysflag != 0) {
			OPM_SymWInt(((LONGINT)(35)));
			OPM_SymWInt(typ->sysflag);
		}
		switch (typ->form) {
			case 13: 
				OPM_SymWInt(((LONGINT)(36)));
				OPT_OutStr(typ->BaseTyp);
				break;
			case 14: 
				OPM_SymWInt(((LONGINT)(40)));
				OPT_OutSign(typ->BaseTyp, typ->link);
				break;
			case 15: 
				switch (typ->comp) {
					case 2: 
						OPM_SymWInt(((LONGINT)(37)));
						OPT_OutStr(typ->BaseTyp);
						OPM_SymWInt(typ->n);
						break;
					case 3: 
						OPM_SymWInt(((LONGINT)(38)));
						OPT_OutStr(typ->BaseTyp);
						break;
					case 4: 
						OPM_SymWInt(((LONGINT)(39)));
						if (typ->BaseTyp == NIL) {
							OPT_OutStr(OPT_notyp);
						} else {
							OPT_OutStr(typ->BaseTyp);
						}
						OPM_SymWInt(typ->size);
						OPM_SymWInt(typ->align);
						OPM_SymWInt(typ->n);
						OPT_nofhdfld = 0;
						OPT_OutFlds(typ->link, ((LONGINT)(0)), 1);
						if (OPT_nofhdfld > 2048) {
							OPM_Mark(223, typ->txtpos);
						}
						OPT_OutTProcs(typ, typ->link);
						OPM_SymWInt(((LONGINT)(18)));
						break;
					default: 
						OPM_LogWStr((CHAR*)"unhandled case at OPT.OutStr, typ^.comp = ", (LONGINT)43);
						OPM_LogWInt(typ->comp, ((LONGINT)(0)));
						OPM_LogLn();
						break;
				}
				break;
			default: 
				OPM_LogWStr((CHAR*)"unhandled case at OPT.OutStr, typ^.form = ", (LONGINT)43);
				OPM_LogWInt(typ->form, ((LONGINT)(0)));
				OPM_LogLn();
				break;
		}
	}
}

static void OPT_OutConstant (OPT_Object obj)
{
	INTEGER f;
	REAL rval;
	f = obj->typ->form;
	OPM_SymWInt(f);
	switch (f) {
		case 2: case 3: 
			OPM_SymWCh((CHAR)obj->conval->intval);
			break;
		case 4: case 5: case 6: 
			OPM_SymWInt(obj->conval->intval);
			break;
		case 9: 
			OPM_SymWSet(obj->conval->setval);
			break;
		case 7: 
			rval = obj->conval->realval;
			OPM_SymWReal(rval);
			break;
		case 8: 
			OPM_SymWLReal(obj->conval->realval);
			break;
		case 10: 
			OPT_OutName((void*)*obj->conval->ext, ((LONGINT)(256)));
			break;
		case 11: 
			break;
		default: 
			OPT_err(127);
			break;
	}
}

static void OPT_OutObj (OPT_Object obj)
{
	INTEGER i, j;
	OPT_ConstExt ext = NIL;
	if (obj != NIL) {
		OPT_OutObj(obj->left);
		if (__IN(obj->mode, 0x06ea)) {
			if (obj->history == 4) {
				OPT_FPrintErr(obj, 250);
			} else if (obj->vis != 0) {
				switch (obj->history) {
					case 0: 
						OPT_FPrintErr(obj, 253);
						break;
					case 1: 
						break;
					case 2: 
						OPT_FPrintErr(obj, 252);
						break;
					case 3: 
						OPT_FPrintErr(obj, 251);
						break;
					default: 
						OPM_LogWStr((CHAR*)"unhandled case at OPT.OutObj, obj^.history = ", (LONGINT)46);
						OPM_LogWInt(obj->history, ((LONGINT)(0)));
						OPM_LogLn();
						break;
				}
				switch (obj->mode) {
					case 3: 
						OPT_OutConstant(obj);
						OPT_OutName((void*)obj->name, ((LONGINT)(256)));
						break;
					case 5: 
						if (obj->typ->strobj == obj) {
							OPM_SymWInt(((LONGINT)(19)));
							OPT_OutStr(obj->typ);
						} else {
							OPM_SymWInt(((LONGINT)(20)));
							OPT_OutStr(obj->typ);
							OPT_OutName((void*)obj->name, ((LONGINT)(256)));
						}
						break;
					case 1: 
						if (obj->vis == 2) {
							OPM_SymWInt(((LONGINT)(22)));
						} else {
							OPM_SymWInt(((LONGINT)(21)));
						}
						OPT_OutStr(obj->typ);
						OPT_OutName((void*)obj->name, ((LONGINT)(256)));
						if (obj->typ->strobj == NIL || obj->typ->strobj->name[0] == 0x00) {
							OPM_FPrint(&OPT_expCtxt.reffp, obj->typ->ref);
						}
						break;
					case 7: 
						OPM_SymWInt(((LONGINT)(31)));
						OPT_OutSign(obj->typ, obj->link);
						OPT_OutName((void*)obj->name, ((LONGINT)(256)));
						break;
					case 10: 
						OPM_SymWInt(((LONGINT)(32)));
						OPT_OutSign(obj->typ, obj->link);
						OPT_OutName((void*)obj->name, ((LONGINT)(256)));
						break;
					case 9: 
						OPM_SymWInt(((LONGINT)(33)));
						OPT_OutSign(obj->typ, obj->link);
						ext = obj->conval->ext;
						j = (int)(*ext)[0];
						i = 1;
						OPM_SymWInt(j);
						while (i <= j) {
							OPM_SymWCh((*ext)[__X(i, ((LONGINT)(256)))]);
							i += 1;
						}
						OPT_OutName((void*)obj->name, ((LONGINT)(256)));
						break;
					default: 
						OPM_LogWStr((CHAR*)"unhandled case at OPT.OutObj, obj.mode = ", (LONGINT)42);
						OPM_LogWInt(obj->mode, ((LONGINT)(0)));
						OPM_LogLn();
						break;
				}
			}
		}
		OPT_OutObj(obj->right);
	}
}

void OPT_Export (BOOLEAN *ext, BOOLEAN *new)
{
	INTEGER i;
	SHORTINT nofmod;
	BOOLEAN done;
	OPT_symExtended = 0;
	OPT_symNew = 0;
	nofmod = OPT_nofGmod;
	OPT_Import((CHAR*)"@self", OPT_SelfName, &done);
	OPT_nofGmod = nofmod;
	if (OPM_noerr) {
		OPM_NewSym((void*)OPT_SelfName, ((LONGINT)(256)));
		if (OPM_noerr) {
			OPM_SymWInt(((LONGINT)(16)));
			OPT_OutName((void*)OPT_SelfName, ((LONGINT)(256)));
			OPT_expCtxt.reffp = 0;
			OPT_expCtxt.ref = 16;
			OPT_expCtxt.nofm = 1;
			OPT_expCtxt.locmno[0] = 0;
			i = 1;
			while (i < 64) {
				OPT_expCtxt.locmno[__X(i, ((LONGINT)(64)))] = -1;
				i += 1;
			}
			OPT_OutObj(OPT_topScope->right);
			*ext = (OPT_sfpresent && OPT_symExtended);
			*new = !OPT_sfpresent || OPT_symNew;
			if (OPM_forceNewSym) {
				*new = 1;
			}
			if ((((OPM_noerr && OPT_sfpresent)) && OPT_impCtxt.reffp != OPT_expCtxt.reffp)) {
				*new = 1;
				if (!OPT_extsf) {
					OPT_err(155);
				}
			}
			OPT_newsf = 0;
			OPT_symNew = 0;
			if (!OPM_noerr || OPT_findpc) {
				OPM_DeleteNewSym();
			}
		}
	}
}

static void OPT_InitStruct (OPT_Struct *typ, SHORTINT form)
{
	*typ = OPT_NewStr(form, 1);
	(*typ)->ref = form;
	(*typ)->size = OPM_ByteSize;
	(*typ)->allocated = 1;
	(*typ)->strobj = OPT_NewObj();
	(*typ)->pbfp = form;
	(*typ)->pvfp = form;
	(*typ)->fpdone = 1;
	(*typ)->idfp = form;
	(*typ)->idfpdone = 1;
}

static void OPT_EnterBoolConst (OPS_Name name, LONGINT value)
{
	OPT_Object obj = NIL;
	OPS_Name name__copy;
	__DUPARR(name, OPS_Name);
	OPT_Insert(name, &obj);
	obj->conval = OPT_NewConst();
	obj->mode = 3;
	obj->typ = OPT_booltyp;
	obj->conval->intval = value;
}

static void OPT_EnterTyp (OPS_Name name, SHORTINT form, INTEGER size, OPT_Struct *res)
{
	OPT_Object obj = NIL;
	OPT_Struct typ = NIL;
	OPS_Name name__copy;
	__DUPARR(name, OPS_Name);
	OPT_Insert(name, &obj);
	typ = OPT_NewStr(form, 1);
	obj->mode = 5;
	obj->typ = typ;
	obj->vis = 1;
	typ->strobj = obj;
	typ->size = size;
	typ->ref = form;
	typ->allocated = 1;
	typ->pbfp = form;
	typ->pvfp = form;
	typ->fpdone = 1;
	typ->idfp = form;
	typ->idfpdone = 1;
	*res = typ;
}

static void OPT_EnterProc (OPS_Name name, INTEGER num)
{
	OPT_Object obj = NIL;
	OPS_Name name__copy;
	__DUPARR(name, OPS_Name);
	OPT_Insert(name, &obj);
	obj->mode = 8;
	obj->typ = OPT_notyp;
	obj->adr = num;
}

static void EnumPtrs(void (*P)(void*))
{
	P(OPT_topScope);
	P(OPT_undftyp);
	P(OPT_bytetyp);
	P(OPT_booltyp);
	P(OPT_chartyp);
	P(OPT_sinttyp);
	P(OPT_inttyp);
	P(OPT_linttyp);
	P(OPT_realtyp);
	P(OPT_lrltyp);
	P(OPT_settyp);
	P(OPT_stringtyp);
	P(OPT_niltyp);
	P(OPT_notyp);
	P(OPT_sysptrtyp);
	__ENUMP(OPT_GlbMod, 64, P);
	P(OPT_universe);
	P(OPT_syslink);
	__ENUMR(&OPT_impCtxt, OPT_ImpCtxt__typ, 4176, 1, P);
}

__TDESC(OPT_ConstDesc, 1, 1) = {__TDFLDS("ConstDesc", 36), {0, -16}};
__TDESC(OPT_ObjDesc, 1, 6) = {__TDFLDS("ObjDesc", 316), {0, 4, 8, 12, 288, 292, -56}};
__TDESC(OPT_StrDesc, 1, 3) = {__TDFLDS("StrDesc", 88), {76, 80, 84, -32}};
__TDESC(OPT_NodeDesc, 1, 6) = {__TDFLDS("NodeDesc", 28), {0, 4, 8, 16, 20, 24, -56}};
__TDESC(OPT_ImpCtxt, 1, 510) = {__TDFLDS("ImpCtxt", 4176), {32, 36, 40, 44, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 92, 
	96, 100, 104, 108, 112, 116, 120, 124, 128, 132, 136, 140, 144, 148, 152, 156, 
	160, 164, 168, 172, 176, 180, 184, 188, 192, 196, 200, 204, 208, 212, 216, 220, 
	224, 228, 232, 236, 240, 244, 248, 252, 256, 260, 264, 268, 272, 276, 280, 284, 
	288, 292, 296, 300, 304, 308, 312, 316, 320, 324, 328, 332, 336, 340, 344, 348, 
	352, 356, 360, 364, 368, 372, 376, 380, 384, 388, 392, 396, 400, 404, 408, 412, 
	416, 420, 424, 428, 432, 436, 440, 444, 448, 452, 456, 460, 464, 468, 472, 476, 
	480, 484, 488, 492, 496, 500, 504, 508, 512, 516, 520, 524, 528, 532, 536, 540, 
	544, 548, 552, 556, 560, 564, 568, 572, 576, 580, 584, 588, 592, 596, 600, 604, 
	608, 612, 616, 620, 624, 628, 632, 636, 640, 644, 648, 652, 656, 660, 664, 668, 
	672, 676, 680, 684, 688, 692, 696, 700, 704, 708, 712, 716, 720, 724, 728, 732, 
	736, 740, 744, 748, 752, 756, 760, 764, 768, 772, 776, 780, 784, 788, 792, 796, 
	800, 804, 808, 812, 816, 820, 824, 828, 832, 836, 840, 844, 848, 852, 856, 860, 
	864, 868, 872, 876, 880, 884, 888, 892, 896, 900, 904, 908, 912, 916, 920, 924, 
	928, 932, 936, 940, 944, 948, 952, 956, 960, 964, 968, 972, 976, 980, 984, 988, 
	992, 996, 1000, 1004, 1008, 1012, 1016, 1020, 1024, 1028, 1032, 1036, 1040, 1044, 1048, 1052, 
	1056, 1060, 1064, 1068, 1072, 1076, 1080, 1084, 1088, 1092, 1096, 1100, 1104, 1108, 1112, 1116, 
	1120, 1124, 1128, 1132, 1136, 1140, 1144, 1148, 1152, 1156, 1160, 1164, 1168, 1172, 1176, 1180, 
	1184, 1188, 1192, 1196, 1200, 1204, 1208, 1212, 1216, 1220, 1224, 1228, 1232, 1236, 1240, 1244, 
	1248, 1252, 1256, 1260, 1264, 1268, 1272, 1276, 1280, 1284, 1288, 1292, 1296, 1300, 1304, 1308, 
	1312, 1316, 1320, 1324, 1328, 1332, 1336, 1340, 1344, 1348, 1352, 1356, 1360, 1364, 1368, 1372, 
	1376, 1380, 1384, 1388, 1392, 1396, 1400, 1404, 1408, 1412, 1416, 1420, 1424, 1428, 1432, 1436, 
	1440, 1444, 1448, 1452, 1456, 1460, 1464, 1468, 1472, 1476, 1480, 1484, 1488, 1492, 1496, 1500, 
	1504, 1508, 1512, 1516, 1520, 1524, 1528, 1532, 1536, 1540, 1544, 1548, 1552, 1556, 1560, 1564, 
	1568, 1572, 1576, 1580, 1584, 1588, 1592, 1596, 1600, 1604, 1608, 1612, 1616, 1620, 1624, 1628, 
	1632, 1636, 1640, 1644, 1648, 1652, 1656, 1660, 1664, 1668, 1672, 1676, 1680, 1684, 1688, 1692, 
	1696, 1700, 1704, 1708, 1712, 1716, 1720, 1724, 1728, 1732, 1736, 1740, 1744, 1748, 1752, 1756, 
	1760, 1764, 1768, 1772, 1776, 1780, 1784, 1788, 1792, 1796, 1800, 1804, 1808, 1812, 1816, 1820, 
	1824, 1828, 1832, 1836, 1840, 1844, 1848, 1852, 1856, 1860, 1864, 1868, 1872, 1876, 1880, 1884, 
	1888, 1892, 1896, 1900, 1904, 1908, 1912, 1916, 1920, 1924, 1928, 1932, 1936, 1940, 1944, 1948, 
	1952, 1956, 1960, 1964, 1968, 1972, 1976, 1980, 1984, 1988, 1992, 1996, 2000, 2004, 2008, 2012, 
	2016, 2020, 2024, 2028, 2032, 2036, 2040, 2044, 2048, 2052, 2056, 2060, 2064, 2068, -4088}};
__TDESC(OPT_ExpCtxt, 1, 0) = {__TDFLDS("ExpCtxt", 80), {-8}};

export void *OPT__init(void)
{
	__DEFMOD;
	__MODULE_IMPORT(OPM);
	__MODULE_IMPORT(OPS);
	__REGMOD("OPT", EnumPtrs);
	__REGCMD("Close", OPT_Close);
	__REGCMD("CloseScope", OPT_CloseScope);
	__INITYP(OPT_ConstDesc, OPT_ConstDesc, 0);
	__INITYP(OPT_ObjDesc, OPT_ObjDesc, 0);
	__INITYP(OPT_StrDesc, OPT_StrDesc, 0);
	__INITYP(OPT_NodeDesc, OPT_NodeDesc, 0);
	__INITYP(OPT_ImpCtxt, OPT_ImpCtxt, 0);
	__INITYP(OPT_ExpCtxt, OPT_ExpCtxt, 0);
/* BEGIN */
	OPT_topScope = NIL;
	OPT_OpenScope(0, NIL);
	OPM_errpos = 0;
	OPT_InitStruct(&OPT_undftyp, 0);
	OPT_InitStruct(&OPT_notyp, 12);
	OPT_InitStruct(&OPT_stringtyp, 10);
	OPT_InitStruct(&OPT_niltyp, 11);
	OPT_undftyp->BaseTyp = OPT_undftyp;
	OPT_EnterTyp((CHAR*)"BYTE", 1, OPM_ByteSize, &OPT_bytetyp);
	OPT_EnterTyp((CHAR*)"PTR", 13, OPM_PointerSize, &OPT_sysptrtyp);
	OPT_EnterProc((CHAR*)"ADR", 20);
	OPT_EnterProc((CHAR*)"CC", 21);
	OPT_EnterProc((CHAR*)"LSH", 22);
	OPT_EnterProc((CHAR*)"ROT", 23);
	OPT_EnterProc((CHAR*)"GET", 24);
	OPT_EnterProc((CHAR*)"PUT", 25);
	OPT_EnterProc((CHAR*)"GETREG", 26);
	OPT_EnterProc((CHAR*)"PUTREG", 27);
	OPT_EnterProc((CHAR*)"BIT", 28);
	OPT_EnterProc((CHAR*)"VAL", 29);
	OPT_EnterProc((CHAR*)"NEW", 30);
	OPT_EnterProc((CHAR*)"MOVE", 31);
	OPT_syslink = OPT_topScope->right;
	OPT_universe = OPT_topScope;
	OPT_topScope->right = NIL;
	OPT_EnterTyp((CHAR*)"CHAR", 3, OPM_CharSize, &OPT_chartyp);
	OPT_EnterTyp((CHAR*)"SET", 9, OPM_SetSize, &OPT_settyp);
	OPT_EnterTyp((CHAR*)"REAL", 7, OPM_RealSize, &OPT_realtyp);
	OPT_EnterTyp((CHAR*)"INTEGER", 5, OPM_IntSize, &OPT_inttyp);
	OPT_EnterTyp((CHAR*)"LONGINT", 6, OPM_LIntSize, &OPT_linttyp);
	OPT_EnterTyp((CHAR*)"LONGREAL", 8, OPM_LRealSize, &OPT_lrltyp);
	OPT_EnterTyp((CHAR*)"SHORTINT", 4, OPM_SIntSize, &OPT_sinttyp);
	OPT_EnterTyp((CHAR*)"BOOLEAN", 2, OPM_BoolSize, &OPT_booltyp);
	OPT_EnterBoolConst((CHAR*)"FALSE", ((LONGINT)(0)));
	OPT_EnterBoolConst((CHAR*)"TRUE", ((LONGINT)(1)));
	OPT_EnterProc((CHAR*)"HALT", 0);
	OPT_EnterProc((CHAR*)"NEW", 1);
	OPT_EnterProc((CHAR*)"ABS", 2);
	OPT_EnterProc((CHAR*)"CAP", 3);
	OPT_EnterProc((CHAR*)"ORD", 4);
	OPT_EnterProc((CHAR*)"ENTIER", 5);
	OPT_EnterProc((CHAR*)"ODD", 6);
	OPT_EnterProc((CHAR*)"MIN", 7);
	OPT_EnterProc((CHAR*)"MAX", 8);
	OPT_EnterProc((CHAR*)"CHR", 9);
	OPT_EnterProc((CHAR*)"SHORT", 10);
	OPT_EnterProc((CHAR*)"LONG", 11);
	OPT_EnterProc((CHAR*)"SIZE", 12);
	OPT_EnterProc((CHAR*)"INC", 13);
	OPT_EnterProc((CHAR*)"DEC", 14);
	OPT_EnterProc((CHAR*)"INCL", 15);
	OPT_EnterProc((CHAR*)"EXCL", 16);
	OPT_EnterProc((CHAR*)"LEN", 17);
	OPT_EnterProc((CHAR*)"COPY", 18);
	OPT_EnterProc((CHAR*)"ASH", 19);
	OPT_EnterProc((CHAR*)"ASSERT", 32);
	OPT_impCtxt.ref[0] = OPT_undftyp;
	OPT_impCtxt.ref[1] = OPT_bytetyp;
	OPT_impCtxt.ref[2] = OPT_booltyp;
	OPT_impCtxt.ref[3] = OPT_chartyp;
	OPT_impCtxt.ref[4] = OPT_sinttyp;
	OPT_impCtxt.ref[5] = OPT_inttyp;
	OPT_impCtxt.ref[6] = OPT_linttyp;
	OPT_impCtxt.ref[7] = OPT_realtyp;
	OPT_impCtxt.ref[8] = OPT_lrltyp;
	OPT_impCtxt.ref[9] = OPT_settyp;
	OPT_impCtxt.ref[10] = OPT_stringtyp;
	OPT_impCtxt.ref[11] = OPT_niltyp;
	OPT_impCtxt.ref[12] = OPT_notyp;
	OPT_impCtxt.ref[13] = OPT_sysptrtyp;
	__ENDMOD;
}
