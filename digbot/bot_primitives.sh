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

