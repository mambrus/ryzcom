#!/bin/bash
. ./.env ""

# Lists all users ever have said anything in any of your available chats
function lusers {
grep -E 'SM.*(.*)' $RYZOMDIR/client.log | sed -e 's/^.*\[//' | sed -e 's/\].*$//' | sort 
}

# Tails according to pattern
function rtail {
	tail -f  $RYZOMDIR/client.log | grep -E "$1" | sed -e 's/.*://'
}

"$@"
