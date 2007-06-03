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

#ifndef PATH_MAX
#include <sys/syslimits.h>
#endif

#ifndef LINE_MAX
#define LINE_MAX 2048
#endif

char *ctime_curr(char *buff){
	time_t time_data;	

	time(&time_data);
	strcpy(buff,ctime(&time_data));
	buff[strlen(buff)-1]=0;
	return buff;
}

int main(int argc, char *argv[])
{
	char username[NAME_MAX];
	char rtap_vstr[NAME_MAX];
	char data_dir[PATH_MAX];
	char logfile_name[PATH_MAX];
	FILE *logfile;	
	char timebuff[NAME_MAX];
	char inline_str[LINE_MAX];
	//char outline_str[LINE_MAX];

	if (argc != 2){
		fprintf(stderr,"Wrong arguments to rdrain service\n");
		exit(1);
	}
	strncpy(data_dir,argv[1],PATH_MAX);
	//fprintf(stderr,"rsink data-path: %s\n",data_dir);

	printf("rsink> Welcome to RyzCom sink service!\n");
	//fflush(stdout);
	printf("rsink> Enter client ID and version number: ");
	fflush(stdout);
	scanf("%s",&rtap_vstr);
	printf("rsink> Enter username: ");
	fflush(stdout);
	scanf("%s",&username);
	printf("rsink> User %s using rtap version %s is accepted.\n",username,rtap_vstr);
	fflush(stdout);

	sprintf(logfile_name,"%s/%s",data_dir,username);
	//fprintf(stderr,"rsink data-path: %s\n",logfile_name);

	logfile = fopen(logfile_name,"a");
	if (!logfile){
		perror(strerror(errno));
		exit(1);
	}

	
	fprintf(logfile,"rdain> ========================================================================\n");
	fprintf(logfile,"rdain> = -STARTED- client id: %s\n",rtap_vstr);
	fprintf(logfile,"rdain> %s\n",ctime_curr(timebuff));
	fprintf(logfile,"rdain> ========================================================================\n");
	fflush(logfile);

	while (!feof(stdin)){
		fgets(inline_str,LINE_MAX,stdin);
		fprintf(logfile,"%s@%s",ctime_curr(timebuff),inline_str);
	}

	fprintf(logfile,"rdain> ========================================================================\n");
	fprintf(logfile,"rdain> = -STOPPED- client id: %s\n",rtap_vstr);
	fprintf(logfile,"rdain> %s\n",ctime_curr(timebuff));
	fprintf(logfile,"rdain> ========================================================================\n");


	fclose(logfile);	
	return EXIT_SUCCESS;
}
