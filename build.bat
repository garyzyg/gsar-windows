PUSHD .
FOR %%I IN (C:\WinDDK\7600.16385.1) DO CALL %%I\bin\setenv.bat %%I fre %Platform% WIN7 no_oacr
POPD

IF %_BUILDARCH%==x86 SET Lib=%Lib%\Crt\i386;%DDK_LIB_DEST%\i386;%Lib%
IF %_BUILDARCH%==AMD64 SET Lib=%Lib%\Crt\amd64;%DDK_LIB_DEST%\amd64;%Lib%

FOR %%I IN (
"#ifndef S_ISDIR"
"#define S_ISDIR(m)  (((m)&(S_IFMT))==S_IFDIR)"
"#endif"
) DO C:\msys64\usr\bin\sed.exe "$a %%~I" -i comp_dep.h

FOR %%I IN (
"struct stat"
"stat("
) DO C:\msys64\usr\bin\sed.exe "/%%~I/s@stat@_&@" -i gsar.c

FOR /F %%I IN ('DIR /B /S *.c') DO CALL :cl /DMSDOS %%I
CALL :link gsar.exe

GOTO :EOF

:cl
cl.exe -nologo -O1 /GL /GS- /I%CRT_INC_PATH% /I. -c /MD /DNDEBUG %*
GOTO :EOF

:link
link.exe -nologo						^
	/LTCG							^
	/OUT:%1							^
	*.obj							^
	user32.lib advapi32.lib					^
	kernel32.lib						^
