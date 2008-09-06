#!/bin/bash

export TOON_NAME=$2
. ./.env

# *** Internal calibration 
. rbot_$TOON_NAME
echo "" > $DLOGFILE;

THIS_SCRIPT="dig_all.sh"
THIS_SHELL=`echo ${0/#.*\//}` 


function NotifyMaster {
	case $1 in
	$RC_DMG	) 
		echo "*********************************"
		echo "**** You have been hurt. RUN! ***"
		echo "*********************************"
		$PLAYER  "$PLAYER_ARGS" "$PDIR/$PFILE_DMG" >> /dev/null;;
	$RC_PROSPECTGIVUP	) 
		echo "*********************************"
		echo "***** Giving up prospecting *****"
		echo "*********************************"
		$PLAYER  "$PLAYER_ARGS" "$PDIR/$PFILE_PROSPECTGIVUP" >> /dev/null;;
	$RC_BAGFULL		) 
		echo "*********************************"
		echo "*****     Bag is full       *****"
		echo "*********************************"
		$PLAYER  "$PLAYER_ARGS" "$PDIR/$PFILE_BAGFULL" >> /dev/null;;
	$RC_DEAD		) 
		echo "*********************************"
		echo "*****  Youre dead (sorry)   *****"
		echo "*********************************"
		$PLAYER  "$PLAYER_ARGS" "$PDIR/$PFILE_DEAD"  >> /dev/null;;
	$RC_BROKENPICK		) 
		echo "*********************************"
		echo "*****  Your pick is broken  *****"
		echo "*********************************"
		$PLAYER  "$PLAYER_ARGS" "$PDIR/$PFILE_BROKENPICK" >> /dev/null;;
	$RC_HEAL		) 
		echo "*********************************"
		echo "*****  Healed (cmd needed)  *****"
		echo "*********************************"
		$PLAYER  "$PLAYER_ARGS" "$PDIR/$PFILE_HEAL" >> /dev/null;;		
	*			) 
		echo "*********************************"
		echo "*** Unknown exit reason ($1)  ****"
		echo "*********************************"
		$PLAYER  "$PLAYER_ARGS" "$PDIR/$PFILE_DEFAULT" >> /dev/null;;
	esac
}

	SUMOF_MATS_AWK='
		BEGIN{
			SUMMA=0;
		}{
			SUMMA=SUMMA+$3;
		}
		END{
			print SUMMA
		}
	'

function ClearMatsLog {
	rm -f $MATSLOG
	sync
	echo "" > $MATSLOG;
	echo "*********************************"
	echo "*** Inventory account cleared ***"
	echo "*********************************"
}

function MatsSum {
	awk "$SUMOF_MATS_AWK" < $MATSLOG
}


function Dig_all {
	if [ $1 == 0 ]; then
		ClearMatsLog
		exit 0;
	fi;
	
	if [ $# == 3 ]; then
		if [ $3 != "daring" ]; then
			echo "Arg #3 ($3) must be \"daring\" if used at all"
			exit 1;
		fi; 
	else
		echo "Syntax error: dig_all.sh (<Dig count>|<0=clean internal inventory counter>) [<TG Toon name>] ["daring"]" 1>&2
	fi;
	
	echo "Digging until bag full or user interaction needed" 1>&2
	echo -n "*** Inventory  ****     : "
	if ! [ -a $MATSLOG ]; then
		echo "" > $MATSLOG;
	fi;
	MATSUM=$(MatsSum)
	echo "$MATSUM"

	
	for (( loop=0 , rc=0 ; $MATSUM<$1 && rc==0 ; loop++ )) ; do
		echo -n "*** Digging #$loop ****     : "
		./dig.sh Dig >> $DLOGFILE
		let "rc=$?";
		if [ $rc != 0 ]; then
			NotifyMaster $rc
		fi;
		MATSUM=$(MatsSum)
		echo "$MATSUM"
		./bot_primitives.sh Turn right 180 >> $DLOGFILE
		if [ $# -ge 3 ]; then
			if [ $3 == "daring" ]; then
				if [ $rc == $RC_DMG ]; then
					echo "######-----< Waiting extra time before trying again >-----#####"
					sleep 180;
				fi;
				if [ $rc != $RC_DEAD ]; then
					let "rc = 0";
				fi;
			fi;
		fi;
		./bot_primitives.sh Turn right 180 >> $DLOGFILE
	done
	
	if [ $rc == 0 ]; then
		echo "*********************************"
		echo "***** Target # mats reached *****"
		echo "*********************************"
		$PLAYER  "$PLAYER_ARGS" "$PDIR/$PFILE_BAGFULL" >> /dev/null
	fi;
}

if [ $THIS_SCRIPT == $THIS_SHELL ]; then
	echo "Performing $THIS_SCRIPT ($THIS_SHELL) command:" 
	echo "$@"												
	"$@"
else
	echo "$THIS_SCRIPT != $THIS_SHELL" 1>&2
	Dig_all $1 $2 $3
fi;


