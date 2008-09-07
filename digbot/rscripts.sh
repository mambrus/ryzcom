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

# Tails all chats heard
function chats {
	tail -f  $RYZOMDIR/client.log | sed -e 's/with category sys//' | grep "Received CHAT : @{" | sed -e 's/.*Received CHAT : //' 
}

# Universe chats heard
function unichats {
	tail -f  $RYZOMDIR/client.log | sed -e 's/with category sys//' | grep "Received CHAT : .*@{F80F}" | sed -e 's/.*Received CHAT : @{EE3F}//' | sed -e 's/@{.*}//' 
}

# Kara chats heard
function karachats {
	tail -f  $RYZOMDIR/client.log | sed -e 's/with category sys//' | grep "Received CHAT : .*@{FFFF}" | sed -e 's/.*Received CHAT : @{EE3F}//' | sed -e 's/@{.*}//' 
}

# Team chats heard
function teamchats {
	tail -f  $RYZOMDIR/client.log | sed -e 's/with category sys//' | grep "Received CHAT : .*@{BBFF}" | sed -e 's/.*Received CHAT : @{EE3F}//' | sed -e 's/@{.*}//' 
}

# Guild chats heard
function guildchats {
	tail -f  $RYZOMDIR/client.log | sed -e 's/with category sys//' | grep "Received CHAT : .*@{4F4F}" | sed -e 's/.*Received CHAT : @{EE3F}//' | sed -e 's/@{.*}//' 
}

"$@"
