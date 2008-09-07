#!/bin/bash
. ./.env

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
E_XP='INF.*\[&XP&You gain .* experience'
E_HEAL='INF.*\[&SPL&.* invokes a beneficial spell'
E_TEAMOFFER='DynString.*\[.* offers you to join .* team.\]'
E_EMOTE='INF.*\[&EMT&.*\]'


# * 
# * Synchronizing events for the eventgenerator system ID passed as arg #1
# * 
function SyncEvents {
	echo "      SyncingEvents"
	cp $RYZOMDIR/client.log logs/$1.sync	
	sync
}

# * 
# * Checks is the event in $2 occured since last SyncEvents related to eventsystem ID in $1
# *  
function EventOccured {
	diff $RYZOMDIR/client.log logs/$1.sync | sed -e 's/^< //' > $ESCANFILE.$1.scan
	#echo "Scanning for: $2 in eventsystem $1"
	grep -E "$2" < $ESCANFILE.$1.scan > $GREPDUMP.$1.grp
	if [ $? == 0  ]; then
		#cat $ESCANFILE.$1.scan
		return 0;
	else
		#cat $ESCANFILE.$1.scan
		return 1;
	fi;
}

# * 
# * Output results of the last EventOccured query
# *  
function PrintEvent {
	cat $GREPDUMP.$1.grp
}

# * 
# * Output the definitions used as event triggers in $1. $2 is optionally used as indent
# *  
function PrintEventTriggers {
	echo -n "$2 "
	echo -e ${1//'|'/"\n$2 "}
}



# * 
# * Sleeps $2 seconds or until the $3 event occurs. Relates to eventsystem ID in $1
# * 
function SleepEvent {
	indrag="      "
	echo "$indrag Waiting for events in scope [$1] with timeout [$2]:"
	PrintEventTriggers "$3" "------->"
#	PrintEventTriggers "$3" "        "

	echo -n "$indrag "
	for (( i=0 ; i<($2*10) ; i++ )) do
		XteUSleep 50000;
		if EventOccured $1 "$3"; then
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
# * Emergency or common handling of certain events. Relates to eventsystem ID in $1
# * 
function DefaultEventHndl {
			if EventOccured $1 "$E_DMG"; then
				EvadeToxicCloud
				echo "Event found: $E_DMG";
				exit $RC_DMG;
			fi;
			if EventOccured $1 "$E_BROKENPICK"; then
				echo "Event found: $E_BROKENPICK";
				exit $RC_BROKENPICK;
			fi;
			if EventOccured $1 "$E_DEAD"; then
				echo "Event found: $E_DEAD";
				exit $RC_DEAD;
			fi;
			if EventOccured $1 "$E_HEAL"; then
				echo "Event found: $E_HEAL";
				exit $RC_HEAL;
			fi;
}

