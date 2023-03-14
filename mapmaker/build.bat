@echo off

if exist "%QB64_HOME%\qb64.exe" (
	set QB64BIN="%QB64_HOME%\qb64.exe"
) else (
	if exist "%QB64_HOME%\qb64pe.exe" (
		set QB64BIN="%QB64_HOME%\qb64pe.exe"
	)
)

if not "%QB64BIN%" == "" (
	echo Using %QB64_HOME%...
	copy %CD%\inform\gx_falcon.h %QB64_HOME%
	"%QB64BIN%" -x %CD%\MapMaker.bas -o %CD%\MapMaker.exe
) else (
	echo QB64 not found at [%QB64_HOME%].
	echo Please ensure the QB64_HOME variable is set to the correct path.
)
