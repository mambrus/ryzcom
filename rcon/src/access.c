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

int get_acces(char *filename, char *user,char *password){
	int found=0;
	FILE *fpasswd;
	char inline_str[LINE_MAX];
	int rc_access=-1;

	char *psw_username;
	char *psw_password;
	char *psw_access_code;

	fpasswd=fopen(filename,"r");
	if (!fpasswd){
		perror(PACKAGE"> ");			
		rcon_logwrite("!","Passwd error: %s",strerror(errno));
	}

	while (!feof(fpasswd) && !found){
		fgets(inline_str,LINE_MAX,fpasswd);
		if (inline_str[0]!='#' && (strnlen(inline_str,LINE_MAX)>3)){
			//sscanf(inline_str,"%s:%s:%d",&psw_username,&psw_password,&psw_access_code);
			psw_username=inline_str;
			psw_password=strchr(psw_username,':');
			psw_password[0]=0;psw_password++;
			psw_access_code=strchr(psw_password,':');
			psw_access_code[0]=0;psw_access_code++;

			if (strchr(psw_access_code,'\n'))
				strchr(psw_access_code,'\n')[0]=0;

			if (strncmp(user,psw_username,NAME_MAX)==0)
				found = 1;			
		}
	}
	fclose(fpasswd);

	if (found && (strncmp(password,psw_password,NAME_MAX)==0)){
		sscanf(psw_access_code,"%d",&rc_access);
	}

	if (found && (strncmp(user,"anonymous",NAME_MAX)==0)){
		if (strchr(password,'@')){
			sscanf(psw_access_code,"%d",&rc_access);
			rcon_logwrite(">","Anonymous login with e-mail: %s\n",password);
		}
	}
	
	return rc_access;	
}

