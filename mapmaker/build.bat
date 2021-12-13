@echo off
if exist "%QB64_HOME%\qb64.exe" (
	echo Using %QB64_HOME%...
	copy %CD%\inform\gx_falcon.h %QB64_HOME%
	"%QB64_HOME%\qb64.exe" -x %CD%\MapMaker.bas -o %CD%\MapMaker.exe
) else (
	echo QB64 not found at [%QB64_HOME%].
	echo Please ensure the QB64_HOME variable is set to the correct path.
)
