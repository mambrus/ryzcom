#!/bin/bash
. ./.env $1

# This file contains xtpe primitives for the digbot
# A primitive is the smallest possible entity of code that 
# will perform a certain operation. 

function XteSleep {
	echo "sleep $1" | xte
}

function XteUSleep {
	echo "usleep $1" | xte
}

function Paus {
	XteUSleep 200000
}
function uPaus {
	XteUSleep 50000
}

function FocusClientWindow {
	echo "mousemove 100 100" | xte
	echo "mouseclick 1" | xte
	Paus
}

function UpDown_key {
	xte "key $RKEY_UPDOWN"
	Paus
}

function Prospect_key {
	xte "key $RKEY3"
	Paus
}

function ProspectFar_key {
	xte "key $RKEY10"
	Paus
}

function Extract {
	xte "key $RKEY1"
	Paus
}

function Careplan {
	xte "key $RKEY2"
	Paus
}

function RunForward {
	xte "keydown $RKEY_FORWARD"
	XteSleep $1
	xte "keyup $RKEY_FORWARD"
}

function PrintChar {
	echo "key $1" | xte
#	echo "key $1" 
	uPaus
}

function PrintSpace {
	echo 'str ' | xte
	uPaus
}

function PrintStr {
	theStr=`echo $1 | sed -e 's/./& /g'`
	for aChar in $theStr; do
		PrintChar $aChar;
	done	
}

function PrintLine {
	for aWord in $1; do
#		PrintStr $aWord;
		echo $aWord;
	done	
}

function xPrintLine {
	echo "key Return" | xte
	Paus
	for aWord in $1; do
		PrintStr $aWord;
		PrintSpace;
#		echo $aWord;
	done	
	echo "key Return" | xte
	Paus
}

function ccTargetMats {
	PrintLine 'str /tar Raw Material Source [Aprak]'
}

function TargetMats {
	xte  "key $RKEY_MATS"
	Paus
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


function Dig {
	echo "Dig"
	SyncEvents
	TargetMats
	DigCycles $CYCLE_N "$E_DONEDIG|$E_BADDIG|$E_DMG|$E_DEAD"
	#DefaultEventHndl
	echo "  Cycle last"
	Extract
	if SleepEvent 40 "$E_DONEDIG|$E_BADDIG|$E_DMG|$E_DEAD"; then
	#if SleepEvent 40 "/$E_DONEDIG/"; then
		echo "Sleep aborted due to event";
	else
		echo "-- Timeout --";
	fi;
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


