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

#define POLL_PERIOD 1000000
#define IDLE_MAX_1 10
#define IDLE_MAX_2 120

#include "network.h"

/**
Read a environment file into process environment
*/
void modify_environment(char *env_filename){
	FILE *conf_file;
	char confline_str[LINE_MAX];
	int rc;
	
	conf_file = fopen(env_filename,"r");
	if (!conf_file){
		perror(strerror(errno));
		exit(1);
	}	
	while (!feof(conf_file)){
		char *envname;
		char *envval;

		fgets(confline_str,LINE_MAX,conf_file);
		if(confline_str[0]!='#'){			
			//int setenv(const char *envname, const char *envval, int overwrite);
			envname = strdup(confline_str);
			envval=strchr(envname,'=');
			envval[0]=0;
			envval++;
			if (strchr(envval,'\n')){
				strchr(envval,'\n')[0]=0;
			}
			if (envval[0]=='"'){
				envval[0]=0;
				envval++;
			}
			if (strchr(envval,'"')){
				strchr(envval,'"')[0]=0;
			}
			/*
			printf("%s",confline_str);
			printf("%s-%s",envname,envval);
			*/

			//Set environment var (but dont overwrite in case it's set)
			rc=setenv(envname,envval,0);
			if(rc!=0){
				perror(strerror(errno));
				printf("%s",confline_str);
				assert("Bad line in config file"==0);
				exit(1);
			}
			free(envname);
		}
	}
	fflush(stdout);
	fclose(conf_file);
}

int main(int argc, char *argv[])
{	
	char conf_file_name[PATH_MAX];
	char inline_str[LINE_MAX];
	char *env_execute="wine ~/bin/Ryzom/client_ryzom_rd.exe";
	char *env_server="kato.homelinux.org";
	char *env_port="13999";
	char *env_tapfile=NULL;
	FILE *subproc_io;
	char username[NAME_MAX];
	int do_run;

	username[0]=0;

	switch (argc) {
		case 1:
			//Config file is expected to be in the invocing directory
			sprintf(conf_file_name,".%s",PACKAGE);
			
			break;
		case 2:
			//Config file is expected to the first argument
			sprintf(conf_file_name,"%s.%s",argv[1],PACKAGE);
			break;
		default:
			fprintf(stderr,"Bad arguments to %s\n",PACKAGE);
			exit(1);
	};

	modify_environment(conf_file_name);

	env_execute=getenv("RC_EXECUTE");
	env_server=getenv("RC_SERVER");
	env_port=getenv("RC_PORT");
	env_tapfile=getenv("RC_TAPFILE");

	printf("%s@%s:%s\n",env_execute,env_server,env_port);

	if (env_tapfile==NULL){
		printf(PACKAGE"> Interacting...\n");
		subproc_io=popen(env_execute,"r");		
	}else{
		char cmd[PATH_MAX];
		printf(PACKAGE"> Taping via: %s\n",env_tapfile);
		sprintf(cmd,"%s > /dev/null  2>&1 &",env_execute);
		system(cmd);
		subproc_io=fopen(env_tapfile,"r");
	}
	if (!subproc_io){
		perror(strerror(errno));
		exit(1);
	}	

	//Start searching for username
	//It should look something like:
	//INF    9 client_ryzom_rd.exe group_html.cpp 2243 : WEB: GET 'http://su1.rzl01.gameforge.fr:50000/mailbox.php?shard=103&user_login=Aprak&session_cookie='D659D954|80C1CED9|0003304F''

	do {
		int early_break;
		int ryz_socket;		
		int idle_cntr=0;

		early_break = 0;
		do_run = 1;
		ryz_socket =0;

		printf(PACKAGE"> Username scan:\n");
		while ((!feof(subproc_io) || env_tapfile) && !username[0] ){
			char *temp_name;

			printf(".");fflush(stdout);
			fgets(inline_str,LINE_MAX,subproc_io);
			//fscanf(subproc_io,"%s",&inline_str);	
			//printf(PACKAGE"> %s",inline_str);
	
			temp_name=strstr(inline_str,"user_login=");
			if (temp_name){
				temp_name=strchr(temp_name,'=');
				temp_name++;
				if (strchr(temp_name,'&')){
					strchr(temp_name,'&')[0]=0;
				};
				strncpy(username,temp_name,NAME_MAX);
			}
			if (env_tapfile && feof(subproc_io)){
				usleep(POLL_PERIOD);
				idle_cntr++;
				if (idle_cntr>=IDLE_MAX_1){
					fclose(subproc_io);
					printf("\n");
					printf(PACKAGE"> Idletime exceeded. Reopening tapfile:\n");
					subproc_io=fopen(env_tapfile,"r");
					idle_cntr=0;
				}
			}else
				idle_cntr=0;
		}
		printf("\n");
		printf(PACKAGE"> User login: %s\n",username);
		/**
		Log in here
		*/
		ryz_socket=ryzcom_login(env_server,env_port,username);
		if (ryz_socket<0){
			printf(PACKAGE"> Can't connect with server: [%s@%s:%s]\n",username,env_server,env_port);
			printf(PACKAGE"> Bailing out.. Sorry!: [%s@%s:%s]\n");
			exit(1);
		}

		//Simple filter of lines beginning with INF
		while ((!feof(subproc_io) || env_tapfile) && !early_break && do_run){
			char *temp_str;
			char *temp_name;
			fgets(inline_str,LINE_MAX,subproc_io);
			printf(".");fflush(stdout);

			//char lastline_str[LINE_MAX];

			if (!feof(subproc_io)){
				//Should be true only if we _pass_ EOF. I.e. there should be no risk of missing lines
				temp_str=strstr(inline_str,"INF");
				if (temp_str){
					printf(PACKAGE"> %s",temp_str);
					ryzcom_sendline(ryz_socket,temp_str);
				}
						
				temp_name=strstr(inline_str,"User request to reselect character");
				if (strstr(inline_str,"Main loop releasing of Ryzom")){
					printf(PACKAGE"> Quit detected!\n");
					do_run=0;
					early_break = 1;
				}
				if (strstr(inline_str,"User request to reselect character")){
					printf(PACKAGE"> User change detected!\n");
					early_break = 1;
				}
			}

			if (env_tapfile && feof(subproc_io)){
				usleep(POLL_PERIOD);
				idle_cntr++;
				if (idle_cntr>=IDLE_MAX_2){
					fclose(subproc_io);
					printf("\n");
					printf(PACKAGE"> Idletime exceeded. Reopening tapfile:\n");
					subproc_io=fopen(env_tapfile,"r");
					idle_cntr=0;
				}
			}else
				idle_cntr=0;
				
		}
		printf(PACKAGE"> Logging out: %s\n",username);
		/**
		Log out here
		*/
		ryzcom_logout(ryz_socket);
		
		//Invalidate the username
		username[0]=0;

		if (!feof(subproc_io) && do_run){
			printf(PACKAGE"> Re-iterate\n");
		}
	} while (!feof(subproc_io) && do_run);

	pclose(subproc_io);
  	return EXIT_SUCCESS;
}
