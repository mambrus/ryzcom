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
#ifndef PATH_MAX
#include <sys/syslimits.h>
#endif

int main(int argc, char *argv[])
{
	char username[NAME_MAX];
	char rtap_vstr[NAME_MAX];
	char data_dir[PATH_MAX];
	char logfile_name[PATH_MAX];
	FILE *logfile;
	time_t time_data;
	char time_str[NAME_MAX];	

	if (argc != 2){
		fprintf(stderr,"Wrong arguments to rdrain service\n");
		exit(1);
	}
	strncpy(data_dir,argv[1],PATH_MAX);
	//fprintf(stderr,"rsink data-path: %s\n",data_dir);

	printf("rsink> Welcome to RyzCom sink service!\n");
	fflush(stdout);
	printf("rsink> Enter rtap version number: ");
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

	time(&time_data);
	fprintf(logfile,"rdain> ========================================================================\n");
	fprintf(logfile,"rdain> %s",ctime(&time_data));
	fprintf(logfile,"rdain> ========================================================================\n");
	fflush(logfile);


	fclose(logfile);	
	return EXIT_SUCCESS;
}
