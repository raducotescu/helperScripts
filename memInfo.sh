#!/bin/bash
################################################################################
# Script used to display the memory consumed by the processes of a user.       #
################################################################################

if [[ -n $1 ]]; then
	CUSER="$1"
else
	CUSER=$USER
fi

check=`finger $CUSER 2>/dev/null | grep -c Login`
if [[ $check -eq 1 ]]; then
	ps u -U $CUSER --sort -rss | tee memory-${CUSER}.log
else
	echo "The user $CUSER does not exist on this system!"
fi
exit 0

