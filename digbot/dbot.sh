#!/bin/bash
# Topmost shell. Enables quitting client and shutting down system. Good for
# leaving bot at bed time and making sure toons is not there annoying ppl.

. ./.env
. ./dig_all.sh $1 $2 $3 $4 | tee $DBOTFILE

if [ $1 == 0 ]; then
	exit 0
fi;

if [ $# -gt 2 ] && [ $3 == "quit" ]; then
	echo *** Telling client to quit

	xte "key $RKEY_QUIT"
	sleep 60
	echo *** Killing any remaining traces
	killall client_ryzom_rd
	if [ `whoami` == "root" ]; then
		sleep 60
		echo *** Shuting down
		shutdown -h now
	fi;
fi;

exit 0
