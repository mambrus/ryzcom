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

#ifndef PATH_MAX
#include <sys/syslimits.h>
#endif

#ifndef LINE_MAX
#define LINE_MAX 2048
#endif

#include "access.h"
#include "logfile.h"

#define HOME "/home/ryzcom"
#define COMMAND_LOG "/home/ryzcom/rcon.log"

int main(int argc, char *argv[])
{
	char *etc_dir=HOME"/etc";
	char *data_dir=HOME"/usersdata";
	char *bin_dir=HOME"/bin_rcon";
	char username[NAME_MAX];
	char password[NAME_MAX];
	FILE *logfile;
	char inline_str[LINE_MAX];
	int access = 0;
	
	switch (argc) {
		case 2:
			//etc directory given
			etc_dir = argv[1];
			break;
		case 3:
			//etc & data directory given
			etc_dir = argv[1];
			data_dir = argv[2];
			break;
		case 4:
			//etc & data & bin directory given
			etc_dir = argv[1];
			data_dir = argv[2];
			bin_dir = argv[3];
			break;

		default:
			fprintf(stderr,"Bad arguments to %s\n",PACKAGE);
			exit(1);
	};

	printf(PACKAGE"> Welcome to RyzCom control service!\n");
	fflush(stdout);
	

	sprintf(inline_str,"%s/passwd.rcon",etc_dir);
	do {
		printf(PACKAGE"> Enter username: ");
		fflush(stdout);
		scanf("%s",&username);

		rcon_logopen(COMMAND_LOG,username);
		printf(PACKAGE"> Enter password: ");
		fflush(stdout);
		scanf("%s",&password);
		access=get_acces(inline_str, username, password);
		if (!(access>0)){
			printf(PACKAGE"> Acces denied!\n");
			fflush(stdout);
			rcon_logwrite("!","Acces denied!\n");
			rcon_logclose();
		}
		if (feof(stdin)){
			rcon_logwrite("!","EOF detected");
			rcon_logclose();
			return EXIT_SUCCESS;
		}
	}while (!(access>0));

	printf(PACKAGE"> User %s is accepted. Welcome to RyzCom control!\n",username);
	fflush(stdout);
	rcon_logwrite(">","Acces granted!\n");
	fgets(inline_str,LINE_MAX,stdin); //Get rid of some fishyness (dunno why it's needed)

	setenv("RC_DATA",data_dir,1);
	setenv("RC_BIN",bin_dir,1);
	//printf("%s %s\n",data_dir,bin_dir);

	while (!feof(stdin)){
		printf(PACKAGE"> ");
		fflush(stdout);
		fgets(inline_str,LINE_MAX,stdin);
		rcon_logwrite(">","%s",inline_str);
		rcon_exec(access, inline_str, bin_dir);
	}
	rcon_logwrite("!","EOF detected");
	rcon_logclose();
	

	return EXIT_SUCCESS;
}
