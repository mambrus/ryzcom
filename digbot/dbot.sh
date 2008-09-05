#!/bin/bash
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
