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

int rcon_exec(int access, char *command, char *bin_dir){
	char tstr[LINE_MAX];
	char inline_str[LINE_MAX];
	FILE *subproc_io;

	if (access & SUPER){
		sprintf(tstr,"%s:%s",bin_dir,getenv("PATH"));
		setenv("PATH",tstr,1);
		//printf("%s",getenv("PATH"));

		subproc_io=popen(command,"r");
	}else{
		sprintf(tstr,"%s/%s",bin_dir,command);
		subproc_io=popen(tstr,"r");
	}


	if (subproc_io == NULL){
		perror(PACKAGE"> ");			
		rcon_logwrite("<","Cmd error: %s",strerror(errno));
		return (-1);
	}
	while (!feof(subproc_io)){
		fgets(inline_str,LINE_MAX,subproc_io);
		if (!feof(subproc_io)){
			printf("%s",inline_str);
			rcon_logwrite("<","%s",inline_str);
		}
	}

	pclose(subproc_io);
	return(0);
}

