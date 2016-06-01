title Sort
rem @echo off

rem compiler settings
set COMPILER=TASM.EXE
set LINKER=TLINK.EXE

%COMPILER% sort.asm sort.obj
%LINKER% sort.obj

cls

sort.exe
