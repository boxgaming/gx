#!/bin/sh
CURDIR=`pwd`
QB64BIN=

if test -f "$QB64_HOME/qb64"
then
	QB64BIN="$QB64_HOME/qb64"
else
	if test -f "$QB64_HOME/qb64pe"
	then
		QB64BIN="$QB64_HOME/qb64pe"
	fi
fi

if [ "$QB64BIN" != "" ]
then
	$QB64BIN -x $CURDIR/gx2web.bas -o $CURDIR/gx2web
	$QB64BIN -x $CURDIR/map2web.bas -o $CURDIR/map2web
	$QB64BIN -x $CURDIR/qb2js.bas -o $CURDIR/qb2js
	$QB64BIN -x $CURDIR/webserver.bas -o $CURDIR/webserver
else
	if [ -z "$QB64_HOME" ]
	then
		echo "QB64_HOME variable is not set."
		echo "Set QB64_HOME to the QB64 installation path."
		echo "  Example: export QB64_HOME=~/qb64"
	else
		echo "QB64 not found at [$QB64_HOME]."
		echo "Please ensure that the QB64_HOME variable is set to the correct path."
	fi
fi