MODULE olang;  (* J. Templ 3.2.95 *)

  IMPORT
    SYSTEM, Heap, Platform,
    OPP, OPB, OPT,
    OPV, OPC, OPM,
    extTools, Strings, vt100;

  VAR mname : ARRAY 256 OF CHAR; (* noch *)


  PROCEDURE Module*(VAR done: BOOLEAN);
    VAR ext, new: BOOLEAN; p: OPT.Node;
  BEGIN
    OPP.Module(p, OPM.opt);
    IF OPM.noerr THEN
      OPV.Init;
      OPV.AdrAndSize(OPT.topScope);
      OPT.Export(ext, new);
      IF OPM.noerr THEN
        OPM.OpenFiles(OPT.SelfName);
        OPC.Init;
        OPV.Module(p);
        IF OPM.noerr THEN
          IF (OPM.mainProg OR OPM.mainLinkStat) & (OPM.modName # "SYSTEM") THEN
            OPM.DeleteNewSym;
	          (* 
              IF ~OPM.notColorOutput THEN vt100.SetAttr(vt100.Green) END;
              OPM.LogWStr("  main program");
	            IF ~OPM.notColorOutput THEN vt100.SetAttr(vt100.ResetAll) END;
            *)
          ELSE
            IF new THEN
              (*
	              IF ~OPM.notColorOutput THEN vt100.SetAttr(vt100.Green) END;
	              OPM.LogWStr("  new symbol file");
	              IF ~OPM.notColorOutput THEN vt100.SetAttr(vt100.ResetAll) END;
              *)
	            OPM.RegisterNewSym
            ELSIF ext THEN
              (*
                OPM.LogWStr("  extended symbol file"); 
              *)
              OPM.RegisterNewSym
            END
          END;
      	ELSE
          OPM.DeleteNewSym
        END
      END
    END;
    OPM.CloseFiles; OPT.Close;
    (* OPM.LogLn; *)
    done := OPM.noerr;
  END Module;


  PROCEDURE PropagateElementaryTypeSizes;
  BEGIN
    OPT.bytetyp.size   := OPM.ByteSize;
    OPT.sysptrtyp.size := OPM.PointerSize;
    OPT.chartyp.size   := OPM.CharSize;
    OPT.settyp.size    := OPM.SetSize;
    OPT.realtyp.size   := OPM.RealSize;
    OPT.inttyp.size    := OPM.IntSize;
    OPT.linttyp.size   := OPM.LIntSize;
    OPT.lrltyp.size    := OPM.LRealSize;
    OPT.sinttyp.size   := OPM.SIntSize;
    OPT.booltyp.size   := OPM.BoolSize;
  END PropagateElementaryTypeSizes;


  PROCEDURE Translate*;
    VAR done: BOOLEAN;
    VAR modulesobj: ARRAY 2048 OF CHAR; (* here we hold all modules name given on the command line, to add corresponding .o files to the external compiler options *)
  BEGIN
    modulesobj := "";
    IF OPM.OpenPar() THEN
      (* gclock();   slightly faste rtranslation but may lead to opening "too many files" *)

      LOOP
        OPM.Init(done, mname);
        IF ~done THEN RETURN END ;

        OPM.InitOptions;
        PropagateElementaryTypeSizes;

        Heap.GC(FALSE);
        Module(done);
        IF ~done THEN
          OPM.LogWStr("OPM module compilation failed."); OPM.LogLn;
          Platform.Exit(1)
        END;

        IF ~OPM.dontAsm THEN
  	      extTools.Assemble(OPM.modName);

          IF ~(OPM.mainProg OR OPM.mainLinkStat) THEN
            Strings.Append(" ",modulesobj);
            Strings.Append(OPM.modName, modulesobj);
            Strings.Append(".o ", modulesobj)
          END;
          IF ~OPM.dontLink & (OPM.mainProg OR OPM.mainLinkStat) THEN
            extTools.LinkMain (OPM.modName, OPM.mainLinkStat, modulesobj);
  	      END
  	    END
      END (* loop *)
    END
  END Translate;

  PROCEDURE Trap(sig: INTEGER);
  BEGIN
    Heap.FINALL();
    IF sig = 3 THEN
      Platform.Exit(0)
    ELSE
      IF (sig = 4) & (Platform.HaltCode = -15) THEN
        OPM.LogWStr(" --- olang: internal error");
        OPM.LogLn
      END ;
      Platform.Exit(2)
    END
  END Trap;

BEGIN
  Platform.SetInterruptHandler(Trap);
  Platform.SetQuitHandler(Trap);
  Platform.SetBadInstructionHandler(Trap);
  OPB.typSize := OPV.TypSize; OPT.typSize := OPV.TypSize; Translate
END olang.
