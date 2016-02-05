MODULE oocSysClock; 
IMPORT SYSTEM;
  
PROCEDURE -Aincludesystime  '#include <sys/time.h>';  (* for gettimeofday *)
PROCEDURE -Aincludetime     '#include <time.h>';      (* for localtime *)

PROCEDURE -gettimeval          "struct timeval tv; gettimeofday(&tv,0)";
PROCEDURE -tvsec():  LONGINT   "tv.tv_sec";
PROCEDURE -tvusec(): LONGINT   "tv.tv_usec";

PROCEDURE CanGetClock*(): BOOLEAN; BEGIN RETURN TRUE END CanGetClock;

PROCEDURE GetTimeOfDay* (VAR sec, usec: LONGINT): LONGINT;
(* PRIVAT.  Don't use this.  Take Time.GetTime instead.  
   Equivalent to the C function `gettimeofday'.  The return value is `0' on 
   success and `-1' on failure; in the latter case `sec' and `usec' are set to
   zero.  *)
BEGIN
  gettimeval;
  sec := tvsec();
  usec := tvusec();
  RETURN 0;
END GetTimeOfDay;

END oocSysClock.
