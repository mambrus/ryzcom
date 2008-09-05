#!/bin/bash
# This file contains the logic to performe one complete dig
# including prospecting  

THIS_SCRIPT="dig.sh"
THIS_SHELL=`echo ${0/#.*\//}` 

. ./bot_primitives.sh
# *** Internal calibration 
if [ $THIS_SCRIPT == $THIS_SHELL ]; then
	if [ -z $TOON_NAME ]; then
		TOON_NAME="DEFAULT"
	else
		echo "Digging as [$TOON_NAME]" 
	fi;
else
	TOON_NAME=$2
fi;

. ./.env
if [ $THIS_SCRIPT == $THIS_SHELL ]; then
	TOON_NAME="DEFAULT"
else
	TOON_NAME=$2
fi;
. ./.env

# *** Internal calibration 
. rbot_$TOON_NAME

# *** Create an event-system for this shell 
. ./event.sh

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

			Turn left 45;
		fi;
	done
}

function Dig {
	echo "Dig"
	SyncEvents
	TargetMats
	DigCycles $CYCLE_N "$E_DONEDIG|$E_BADDIG|$E_DMG|$E_DEAD"
	DefaultEventHndl
	echo "  Cycle last"
	for (( keep_digging=1 , retries=0 ; (keep_digging==1) && (retries<5) ; retries++ )) do
		#&& retries<5
		Extract
		if SleepEvent 40 "$E_DONEDIG|$E_BADDIG|$E_DMG|$E_DEAD|$E_NOFOCUS"; then
			if EventOccured "$E_NOFOCUS"; then
				echo "------> Low on focus <---------";				
				SyncEvents;
				let "keep_digging=1";
				UpDown_key;
				SleepEvent `expr $CYCLE_DIG_TIME / 5 + $CYCLE_CP_TIME / 5` "$E_DONEDIG|$E_BADDIG|$E_DMG|$E_DEAD"
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

function CompleteCycle {
	PrintTuningSettings
	SyncEvents
	FocusClientWindow

	Prospect
	DefaultEventHndl
	Dig
	DefaultEventHndl
	Dig
	DefaultEventHndl
}

if [ $THIS_SCRIPT == $THIS_SHELL ]; then
	echo "Performing $THIS_SCRIPT command:"
	echo "$@"
	FocusClientWindow
	"$@"
else
	CompleteCycle
	exit 0;
fi;


