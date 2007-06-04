/***************************************************************************
 *   Copyright (C) 2007 by The RyzCom project                              *
 *   ryzcom@gmail.com                                                      *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <stdio.h>
#include <stdlib.h>

#include <errno.h>
#include <string.h>
#include <limits.h>
#include <time.h>
#include <assert.h>
#include <stdarg.h>

#ifndef PATH_MAX
#include <sys/syslimits.h>
#endif

#ifndef LINE_MAX
#define LINE_MAX 2048
#endif

#include "logfile.h"


FILE *logfile;
char username[NAME_MAX];

char *ctime_curr(char *buff){
	time_t time_data;	

	time(&time_data);
	strcpy(buff,ctime(&time_data));
	buff[strlen(buff)-1]=0;
	return buff;
}


int rcon_logopen(const char *filename, const char *_username){
	strncpy(username,_username,NAME_MAX);
	logfile=fopen(filename,"a");
	if (!logfile){
		perror(strerror(errno));
		exit(1);
	}
	return 0;
}

int rcon_logclose(){
	fclose(logfile);
	return 0;
}

int rcon_logwrite(const char *prefix, const char *format, ...){
	va_list ap;		
		char timebuff[NAME_MAX];
		char buff1[LINE_MAX];
		char buff2[LINE_MAX];
		int rc;
	va_start (ap, format);
		/*Copy to locals*/
	//va_end(ap);			//Don't end AP here - we're piping the variable to sprintf function for final parsing
	
	rc=vsprintf(buff1,format,ap);
	va_end(ap);

	fseek(logfile,SEEK_END,0);
	fprintf(logfile,"%s %s%s %s",ctime_curr(timebuff),username,prefix,buff1);
	fflush(logfile);
	return 0;
}
