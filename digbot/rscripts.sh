#!/bin/bash
. ./.env ""

# Lists all users ever have said anything in any of your available chats
function lusers {
	grep 'SM.*(.*)' $RYZOMDIR/client.log | sed -e 's/^.*\[//' | sed -e 's/\].*$//' | grep -v '&' | grep -v '%' 
}

# Lists all unique users 
function lqusers {
	lusers | sed -e 's/).*//' | sed -e 's/(/ -> /' | sort -u | nl 
}

# Tails according to pattern
function rtail {
	tail -f  $RYZOMDIR/client.log | grep -E "$1" | sed -e 's/.*://'
}

"$@"
