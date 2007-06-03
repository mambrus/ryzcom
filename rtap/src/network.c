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
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <strings.h>
#include <string.h>
#include <assert.h>

#include "network.h"

/**
Open a socket to the ryzcom server

On success, a valid handle will be returned. Otherwise, -1 shall be returned 
and errno set to indicate the error.
*/
int ryzcom_open(char *hostname,int port){
	//char hostname[PATH_MAX];
	struct hostent *hp;
	int mysock;	
	struct sockaddr_in sin;
	struct sockaddr *saddr;

	assert(sizeof(sin) == sizeof(*saddr));

	//gethostname(hostname, sizeof(hostname));
	
	hp = gethostbyname(hostname);
	if (hp == NULL){
		printf(PACKAGE"> Unknown host: %s\n",hostname);
		return -1;
	}

	mysock = socket(AF_INET, SOCK_STREAM, 0);
	if (mysock < 0){
		printf(PACKAGE"> client: socket\n");
		return -1;
	}

	sin.sin_family=AF_INET;
	sin.sin_port=htons(port);
	bcopy(hp->h_addr,&sin.sin_addr,hp->h_length);

	saddr = (struct sockaddr*)&sin;
	if (connect(mysock, saddr, sizeof(sin)) < 0){
		printf(PACKAGE"> client: connect\n");
		return -1;
	}
	return mysock;
}

char *ryzcom_readline_bad(FILE *fp,char *buffer){
	char c;
	int i=0;
	do{
		c=fgetc(fp);
		buffer[i]=c;
		i++;
	}while (!feof(fp) && c!='\n');
	if (feof(fp))
		return NULL;
	buffer[i-1]=0;
	return buffer;
}
char *ryzcom_readline(FILE *fp,char *buffer){
	char inline_str[LINE_MAX];
	int i=0,l=0;
	do{
		fscanf(fp,"%s",&inline_str);
		l=strlen(inline_str);
		strcpy(&buffer[i],inline_str);
		i+=l;
	}while (!feof(fp) && !strchr(inline_str,'\n'));
	if (feof(fp))
		return NULL;
	buffer[i-1]=0;
	return buffer;
}

/**
Log-in to the ryzcom server

On success, a valid handle will be returned. Otherwise, -1 shall be returned 
and errno set to indicate the error.
*/
int ryzcom_login(char *hostname,char *port_str,char *user){
	int mysock,port;
	FILE *fp;
	char inline_str[LINE_MAX];
	char *temp_str;
	
	sscanf(port_str,"%d",&port);
	
	mysock = ryzcom_open(hostname, port);
	fp = fdopen(mysock,"r+");
	
	for(temp_str=NULL;!feof(fp) && !temp_str;){
		//fgets(inline_str,LINE_MAX,fp);
		fscanf(fp,"%s",&inline_str);
		//ryzcom_readline(fp,inline_str);
		temp_str=strchr(inline_str,':');
		printf(PACKAGE"> Server says: %s\n",inline_str);

	}
	send(mysock,PACKAGE"-"VERSION,strlen(PACKAGE"-"VERSION),0);
	send(mysock,"\n",strlen("\n"),0);

	for(temp_str=NULL;!feof(fp) && !temp_str;){
		fscanf(fp,"%s",&inline_str);
		temp_str=strchr(inline_str,':');
		printf(PACKAGE"> Server says: %s\n",inline_str);
	
	}
	send(mysock,user,strlen(user),0);
	send(mysock,"\n",strlen("\n"),0);
	return mysock;
	
}


/**
Log-out from the ryzcom server
*/
int ryzcom_logout(int hndl){
	close(hndl);
}

/**
Send a user log line
*/
int ryzcom_sendline(int mysock, char *line){
	
	if (strchr(line,'\n')){
		strchr(line,'\n')[0]=0;
	}
	if (strchr(line,'\r')){
		strchr(line,'\r')[0]=0;
	}

	send(mysock,line,strlen(line),0);
	send(mysock,"\n",strlen("\n"),0);	
}

