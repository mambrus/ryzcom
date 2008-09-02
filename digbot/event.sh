#!/bin/bash
. ./.env $1

# ** This file contains the logic to handle the event system
  
# * Regular expressions defining various events

E_MATS='\[&ITM&You found .* raw material sources.\]'
E_DONEDIG='INF.*\[&XP&'
E_BADDIG='INF.*\[&CHK&You need a target'
E_NOFOCUS='INF.*\[&CHKCB&Not enough focus' 
E_BROKENPICK='INF.*\[&CHK&You don.* forage'
E_DMG='INF.*\[&DMG&'
E_DEAD='INF.*\[&SYS&You have been killed'
E_ITEMTOBAG='INF.*\[&ITM&You obtain'
E_HEAL='INF.*\[&SPL&.* invokes a beneficial spell'

# * 
# * Synchronizing the eventgenerator system
# * 
function SyncEvents {
	echo "      SyncingEvents"
	cp $RYZOMDIR/client.log client.log.sync	
}

# * 
# * Checks is an event occured since last SyncEvents
# *  
function EventOccured {
	diff $RYZOMDIR/client.log client.log.sync | sed -e 's/^< //' > $ESCANFILE
	#echo "Scanning for: $1"
	grep -E "$1" < $ESCANFILE > $GREPDUMP
	if [ $? == 0  ]; then
		#cat $ESCANFILE
		return 0;
	else
		#cat $ESCANFILE
		return 1;
	fi;
}

# * 
# * Sleeps $1 seconds or until the $2 event occurs.
# * 
function SleepEvent {
	indrag="      "
	echo "$indrag Sleeping either for [$1]s or when [$2] happens"
	
	echo -n "$indrag "
	for (( i=0 ; i<($1*10) ; i++ )) do
		XteUSleep 50000;
		if EventOccured "$2"; then
			return 0;
		fi;		
		let "j=$i+1";
		if [ `expr $j % 10` == 0  ]; then
			echo -n `expr $j % 100 / 10`;
		#else
		#	echo -n ".";
		fi;

		if [ `expr $j % 100` == 0  ]; then
			echo;	
			echo -n "$indrag "
		fi;
	done
	echo

	return 1;
}

# * 
# * Emergency or common handling of certain events
# * 
function DefaultEventHndl {
			if EventOccured "$E_DMG"; then
				EvadeToxicCloud
				echo "Event found: $E_DMG";
				exit $RC_DMG;
			fi;
			if EventOccured "$E_BROKENPICK"; then
				echo "Event found: $E_BROKENPICK";
				exit $RC_BROKENPICK;
			fi;
			if EventOccured "$E_DEAD"; then
				echo "Event found: $E_DEAD";
				exit $RC_DEAD;
			fi;
}

