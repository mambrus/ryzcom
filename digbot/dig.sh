#!/bin/bash
. ./.env $1
. ./bot_primitives.sh $1

# This file contains the logic to performe one complete dig
# including prospecting  

E_MATS='\[&ITM&You found .* raw material sources.\]'
E_DONEDIG='INF.*\[&XP&'
E_BADDIG='INF.*\[&CHK&You need a target'
E_NOFOCUS='INF.*\[&CHKCB&Not enough focus' 
E_BROKENPICK='INF.*\[&CHK&You don.* forage'
E_DMG='INF.*\[&DMG&'
E_DEAD='INF.*\[&SYS&You have been killed'
E_ITEMTOBAG='INF.*\[&ITM&You obtain'


function SyncEvents {
	echo "      SyncingEvents"
	cp $RYZOMDIR/client.log client.log.sync	
}

#2008/08/23 13:43:56 INF   20 client_ryzom_rd.exe string_manager_client.cpp 541 : DynString 2254507851 available : [&ITM&You found 6 raw material sources.]

function EventOccured {
#	diff $RYZOMDIR/client.log client.log.sync | sed -e 's/^< //' | grep -E '617.*Rece.* CHAT' > eventscan.txt; echo $?
	#diff $RYZOMDIR/client.log client.log.sync | sed -e 's/^< //' | grep -E $1 > $ESCANFILE
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
	//SyncEvents
}

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

function OneCycle {
	#SyncEvents
	Extract
	SleepEvent $CYCLE_DIG_TIME "$1"
	Careplan
	SleepEvent $CYCLE_CP_TIME "$1"
}

function DigCycles {
	for (( loop=0 ; loop<$1 ; loop++ )) ; do
		echo "  Cycle $loop"
		OneCycle "$2";
		DefaultEventHndl
	done
}

function PickUp {
	echo "mousemove 125 300" | xte
	Paus
	echo "mouseclick 1" | xte
	Paus
	echo "mouseclick 1" | xte
	Paus
}

function EvadeToxicCloud {
	RunForward 4
}

function Prospect {
	for (( ppf=0 , ppi=0 ; ppf==0 ; ppi++ )) do
		let "ppj=$ppi+1";
		let "pf=0";
		echo " Prospec #$ppj";

#		if [ $j -ge 2 ]; then
		if [ `expr $ppj % 3` == 0 ] || [ $ppj -ge 10 ]; then
			echo "*** Trying far prospect ***";
			ProspectFar_key;
			let "pf=1";
		else
			echo "     Near prospecting";
			Prospect_key;
		fi;
		#XteSleep 5
		if [ $ppi -ge 25 ]; then
			#let "f = 1";
			exit $RC_PROSPECTGIVUP;
		fi
		
		if SleepEvent $PROSPECT_INITIAL_TIME "$E_MATS|$E_BROKENPICK|$E_DMG|$E_DEAD"; then
			#echo "      *** Prospecting event detected"
			UpDown_key;
			XteSleep $PROSPECT_REST_TIME;
			UpDown_key;
			if EventOccured "$E_MATS"; then
				echo "You've found mats!!!";
				#return 0;
				let "ppf = 1";
			fi;
			DefaultEventHndl
		else
			#cat $ESCANFILE;
			#exit 100;

			echo "      Mats not found-------------------------------------------------"
			UpDown_key
			XteSleep 5
			if [ $pf == 1  ]; then
				echo "                     zZzz...rr"
				XteSleep $PROSPECT_REST_TIME;
				XteSleep $PROSPECT_REST_TIME;
			fi;
			UpDown_key

			xte "keydown $RKEY_TURNLEFT"
			Paus
			XteUSleep 350000
			xte "keyup $RKEY_TURNLEFT"
			Paus
		fi;
	done
}

function Dig {
	echo "Dig"
	SyncEvents
	TargetMats
	DigCycles $CYCLE_N "$E_DONEDIG|$E_BADDIG|$E_DMG|$E_DEAD"
	#DefaultEventHndl
	echo "  Cycle last"
	for (( keep_digging=1 , retries=0 ; (keep_digging==1) && (retries<5) ; retries++ )) do
		#&& retries<5
		Extract
		if SleepEvent 40 "$E_DONEDIG|$E_BADDIG|$E_DMG|$E_DEAD|$E_NOFOCUS"; then
			if EventOccured "$E_NOFOCUS"; then
				SyncEvents
				echo "------> Low on focus <---------";				
				let "keep_digging=1";
				UpDown_key;
				XteSleep 3;
				UpDown_key;
			else
				let "keep_digging=0";
			fi;
			
			echo "Sleep aborted due to event";
		else
			echo "-- Timeout --";
			let "keep_digging=0";
		fi;
	done;
	Paus
	echo "  Pickup"
	PickUp
	if SleepEvent 10 "$E_ITEMTOBAG"; then
		echo "X Mats picked up";
		cat $GREPDUMP | sed -e 's/INF.*&//' | sed -e 's/You obtain //' >> $MATSLOG
	else
		echo "@@@@@@@@@@@@@@@ Pickup Timeout -> Bag must be full @@@@@@";
		exit $RC_BAGFULL;
	fi;
}

function PrintTuningSettings {
	echo "********** Tuning settings **********"
	echo "CYCLE_N=$CYCLE_N"
	echo "CYCLE_DIG_TIME=$CYCLE_DIG_TIME"
	echo "CYCLE_CP_TIME=$CYCLE_CP_TIME"
	echo "PROSPECT_INITIAL_TIME=$PROSPECT_INITIAL_TIME"
	echo "PROSPECT_REST_TIME=$PROSPECT_REST_TIME"
	echo "*************************************"
}

PrintTuningSettings
SyncEvents
FocusClientWindow

Prospect
DefaultEventHndl
Dig
DefaultEventHndl
Dig
DefaultEventHndl

exit 0;


