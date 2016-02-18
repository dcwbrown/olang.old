@echo off

whoami /groups | find "12288" >nul
if errorlevel 1 (
echo fullmake - administrator rights required. Please run under an administrator command prompt.
goto :eof
)

@echo on
call make clean 
call make 
call make setnew 
call make clean 
call make
call make setnew
call make install
call make library
call make install
