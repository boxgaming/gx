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
	"%QB64BIN%" -x %CD%\gx2web.bas -o %CD%\gx2web.exe
	"%QB64BIN%" -x %CD%\map2web.bas -o %CD%\map2web.exe
	"%QB64BIN%" -x %CD%\qb2js.bas -o %CD%\qb2js.exe
	"%QB64BIN%" -x %CD%\webserver.bas -o %CD%\webserver.exe
) else (
	echo QB64 not found at [%QB64_HOME%].
	echo Please ensure the QB64_HOME variable is set to the correct path.
)
