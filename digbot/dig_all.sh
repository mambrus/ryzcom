#!/bin/bash

if [ $# == 1 ]; then
	. ./.env ""
elif [ $# == 2 ]; then
	. ./.env $2
elif [ $# == 3 ]; then
	if [ $3 != "daring" ]; then
		exit 1;
	fi; 
	. ./.env $2
else
	echo "Syntax error: dig_all.sh (<Dig count>|<0=clean internal inventory counter>) [<TG Toon name>] ["daring"]"
fi;

	export DISPLAY=:0.0	
	echo "" > $DLOGFILE;


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

#function dig_all {
	if [ $1 == 0 ]; then
		rm -f $MATSLOG
		sync
		echo "" > $MATSLOG;
		echo "*********************************"
		echo "*** Inventory account cleared ***"
		echo "*********************************"
		exit 0;
	fi;
	
	echo "Digging until bag full or user interaction needed"
	echo -n "*** Inventory  ****     : "
	MATSUM=$(awk "$SUMOF_MATS_AWK" < $MATSLOG)
	echo "$MATSUM"

	
	for (( loop=0 , rc=0 ; $MATSUM<$1 && rc==0 ; loop++ )) ; do
		echo -n "*** Digging #$loop ****     : "
		./dig.sh $2 >> $DLOGFILE
		let "rc=$?";
		MATSUM=$(awk "$SUMOF_MATS_AWK" < $MATSLOG)
		echo "$MATSUM"
		if [ $rc != 0 ]; then
			NotifyMaster $rc
		fi;
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
	done
	
	if [ $rc == 0 ]; then
		echo "*********************************"
		echo "***** Target # mats reached *****"
		echo "*********************************"
		$PLAYER  "$PLAYER_ARGS" "$PDIR/$PFILE_BAGFULL" >> /dev/null
	fi;
	
	
#}

#dig_all $1 $2 $3

