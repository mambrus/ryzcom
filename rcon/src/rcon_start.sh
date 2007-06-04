#!/bin/bash
#***************************************************************************
#    Copyright (C) 2007 by The RyzCom project                              *
#    ryzcom@gmail.com                                                      *
#                                                                          *
#    This program is free software; you can redistribute it and/or modify  *
#    it under the terms of the GNU General Public License as published by  *
#    the Free Software Foundation; either version 2 of the License, or     *
#    (at your option) any later version.                                   *
#                                                                          *
#    This program is distributed in the hope that it will be useful,       *
#    but WITHOUT ANY WARRANTY; without even the implied warranty of        *
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
#    GNU General Public License for more details.                          *
#                                                                          *
#    You should have received a copy of the GNU General Public License     *
#    along with this program; if not, write to the                         *
#    Free Software Foundation, Inc.,                                       *
#    59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
#***************************************************************************/
export MYFIFO=/tmp/rcon_$$.pipe


if test $# == 0; then
	PORT=13997
fi

if test $# == 1; then
	PORT=$1
fi

mkfifo $MYFIFO
RC=999

while test $RC != 130; do
	./tcpservlet.exp port=$PORT  <$MYFIFO | \
		rcon /home/ryzcom/etc /home/ryzcom/usersdata /home/ryzcom/bin_rcon > \
		$MYFIFO 2>&1
	RC=$?
	echo "Done! The return value is $RC"
done
rm $MYFIFO
