#!/bin/bash
# This file contains the logic to performe one complete dig
# including prospecting  

. ./bot_primitives.sh

THIS_SCRIPT="dig.sh"
THIS_SHELL=`echo ${0/#.*\//}`

# *** Internal calibration 
if [ $THIS_SCRIPT == $THIS_SHELL ]; then
	if [ -z $TOON_NAME ]; then
		export TOON_NAME="DEFAULT"
	else
		echo "Digging as [$TOON_NAME]"
	fi;
else
	export TOON_NAME=$2
fi;
. ./.env

# *** Internal calibration 
. rbot_$TOON_NAME

# *** Create an event-system for this shell 
. ./event.sh
E_EXIT_REASONS="$E_DMG|$E_DEAD|$E_BROKENPICK|$E_HEAL"


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
		
		if SleepEvent $PROSPECT_INITIAL_TIME "$E_MATS|$E_EXIT_REASONS"; then
			echo "      *** Prospecting event detected ##"
			DefaultEventHndl
			UpDown_key;
			XteSleep $PROSPECT_REST_TIME;
			UpDown_key;
			if EventOccured "$E_MATS"; then
				echo "You've found mats!!!";
				#return 0;
				let "ppf = 1";
			fi;			
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

			Turn left 90;
		fi;
	done
}

function ExtractMats {
	echo "Dig"
	SyncEvents
	TargetMats
	DigCycles $CYCLE_N "$E_DONEDIG|$E_BADDIG|$E_EXIT_REASONS"
	DefaultEventHndl
	echo "  Cycle last"
	Extract
	if SleepEvent 40 "$E_DONEDIG|$E_BADDIG|$E_NOFOCUS|$E_EXIT_REASONS"; then
		DefaultEventHndl
		if EventOccured "$E_NOFOCUS"; then
			echo "------> Low on focus <---------";							
				UpDown_key;
		fi;
	fi;
	echo "  Pickup"
	PickUp
	if SleepEvent 10 "$E_ITEMTOBAG|$E_EXIT_REASONS"; then
		DefaultEventHndl
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
	echo "TOON_NAME=$TOON_NAME"	
	echo "CYCLE_DIG_TIME=$CYCLE_DIG_TIME"
	echo "CYCLE_CP_TIME=$CYCLE_CP_TIME"
	echo "PROSPECT_INITIAL_TIME=$PROSPECT_INITIAL_TIME"
	echo "PROSPECT_REST_TIME=$PROSPECT_REST_TIME"
	echo "*************************************"
}

function Dig {
	PrintTuningSettings
	SyncEvents
	FocusClientWindow

	Prospect
	DefaultEventHndl
	ExtractMats
	DefaultEventHndl
	ExtractMats
	DefaultEventHndl
}

if [ $THIS_SCRIPT == $THIS_SHELL ]; then
	echo "Performing $THIS_SCRIPT ($THIS_SHELL) command:"
	echo "$@"											
	FocusClientWindow
	"$@"
else
	echo "$THIS_SCRIPT != $THIS_SHELL" 1>&2
	Dig
	exit 0;
fi;


