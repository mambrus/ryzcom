#!/bin/bash
. ./.env ""

# Lists all users ever have said anything in any of your available chats
function users {
	grep -E ' String .* available.*\(.*\)' $RYZOMDIR/client.log | sed -e 's/.*\[//' | sed -e 's/\].*$//'
}

# Lists all users ever have said anything in any of your available chats
function INF {
	grep -E 'INF' $RYZOMDIR/client.log 
}

# Lists all users ever have said anything in any of your available chats
function rtail {
	tail -f  $RYZOMDIR/client.log | grep -E "$1" | sed -e 's/.*://'
}


$1 $2 $3 $4
