

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	char username[80];
	char rtap_vstr[80];

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
	
	return EXIT_SUCCESS;
}
