#!/bin/sh
CURDIR=`pwd`

if test -f "$QB64_HOME/qb64"
then
	cp $CURDIR/inform/gx_falcon.h $QB64_HOME
	$QB64_HOME/qb64 -x $CURDIR/MapMaker.bas -o $CURDIR/MapMaker
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