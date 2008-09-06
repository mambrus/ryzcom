#!/bin/bash
. ./.env

# This file contains xtpe primitives for the digbot
# A primitive is the smallest possible entity of code that 
# will perform a certain operation.

TIME_FULL_TURN=3000000
THIS_SCRIPT="bot_primitives.sh"
THIS_SHELL=`echo ${0/#.*\//}` 

function FocusClientWindow {
	echo "mousemove 100 100" | xte
	echo "mouseclick 1" | xte
	Paus
}

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

function UpDown_key {
	xte "key $RKEY_UPDOWN"
	Paus
}

function Prospect_key {
	xte "key $RKEY_PROSPECT"
	Paus
}

function ProspectFar_key {
	xte "key $RKEY_PROSPECT_FAR"
	Paus
}

function Extract {
	xte "key $RKEY_EXTRACT_1"
	Paus
}

function ExtractLow {
	xte "key $RKEY_EXTRACT_2"
	Paus
}

function Careplan {
	xte "key $RKEY_CP"
	Paus
}

function SelfHealFocus {
	xte "key $RKEY_SH_FOCUS"
	Paus
}

function SelfHealHp {
	xte "key $RKEY_SH_HP"
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
		PrintStr $aWord;
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

function PickUp {
	echo "mousemove 125 300" | xte
	Paus
	echo "mouseclick 1" | xte
	Paus
	echo "mouseclick 1" | xte
	Paus
}

function TurnLeft360 {
	xte "keydown $RKEY_TURNLEFT"
	Paus
	XteUSleep $TIME_FULL_TURN
	xte "keyup $RKEY_TURNLEFT"
	Paus
}

function TurnLeft90 {
	xte "keydown $RKEY_TURNLEFT"
	Paus
	XteUSleep `expr $TIME_FULL_TURN / 4`
	xte "keyup $RKEY_TURNLEFT"
	Paus
}

function TurnRight90 {
	xte "keydown $RKEY_TURNRIGHT"
	Paus
	XteUSleep `expr $TIME_FULL_TURN / 4`
	xte "keyup $RKEY_TURNRIGHT"
	Paus
}

function TurnLeft {	
	let "ttime=$TIME_FULL_TURN * $1 / 360"
	echo "turning left $1 degrees ($ttime uS)"
	xte "keydown $RKEY_TURNLEFT"
	Paus
	XteUSleep $ttime
	xte "keyup $RKEY_TURNLEFT"
	Paus
}

function TurnRight {
	let "ttime=$TIME_FULL_TURN * $1 / 360"
	echo "turning left $1 degrees ($ttime uS)"
	xte "keydown $RKEY_TURNRIGHT"
	Paus
	XteUSleep $ttime
	xte "keyup $RKEY_TURNRIGHT"
	Paus
}

function Turn {
	if [ $# != 2 ]; then
		echo "Turn: Syntax error"
		return 1;
	fi;
	
	if [ $1 == "left" ]; then
		TurnLeft $2
	elif [ $1 == "right" ]; then
		TurnRight $2
	else
		echo "Turn: unknown direction $1"
	fi;
}

if [ $THIS_SCRIPT == $THIS_SHELL ]; then
	echo "Performing $THIS_SCRIPT command:"
	echo "$@"
	FocusClientWindow
	"$@"
fi;

