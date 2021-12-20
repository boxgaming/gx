@echo off
if exist "%QB64_HOME%\qb64.exe" (
	echo Using %QB64_HOME%...
	"%QB64_HOME%\qb64.exe" -x %CD%\gx2web.bas -o %CD%\gx2web.exe
	"%QB64_HOME%\qb64.exe" -x %CD%\map2web.bas -o %CD%\map2web.exe
	"%QB64_HOME%\qb64.exe" -x %CD%\qb2js.bas -o %CD%\qb2js.exe
	"%QB64_HOME%\qb64.exe" -x %CD%\webserver.bas -o %CD%\webserver.exe
) else (
	echo QB64 not found at [%QB64_HOME%].
	echo Please ensure the QB64_HOME variable is set to the correct path.
)
