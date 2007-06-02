

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
