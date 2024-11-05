#include <stdio.h> 
#include <sys/types.h> 
#include <sys/stat.h>
#include <fcntl.h> 
#include <unistd.h>
#include <errno.h> 
#include <string.h>
#include <stdlib.h>

#define MAX_BUFFER 				1024
#define SYSFS_pjebarg1_IN 		"/sys/kernel/sykom/pjebarg1"
#define SYSFS_pjebarg2_IN 		"/sys/kernel/sykom/pjebarg2"
#define SYSFS_pjebresult_OUT 	"/sys/kernel/sykom/pjebresult"
#define SYSFS_pjebstatus_OUT 	"/sys/kernel/sykom/pjebstatus"

unsigned int read_file(char *file){
	// Opening file
	int f=open(file, O_RDONLY);
	if(f<0){
		printf("Open %s – error: %d\n", file, errno);
		close(f);
		return -1;
	}

	char buffer[MAX_BUFFER];
	// Reading data from the driver
	int n=read(f, buffer, MAX_BUFFER); 
	if(n>0){
		buffer[n] = '\0';
		//printf("%s\n", buffer);
	}
	if(n<0){
		printf("Reading data from a file %s failed\n", f);
		close(f);
		return -1;
	}
	close(f);
	return strtoul(buffer, NULL, 16);
}

int write_file(char *file, unsigned int arg){
	// Opening file
	int f=open(file, O_WRONLY);
	if(f<0){
		printf("Open %s – error: %d\n", file, errno);
		close(f);
		return -1;
	}

	char buffer[MAX_BUFFER];
	// Data for the driver
	snprintf(buffer, MAX_BUFFER, "%x", arg);
	// Forwarding data to the driver
	int n=write(f, buffer, strlen(buffer)); 
	if(n!=strlen(buffer)){ 
		printf("Writing data to a file %s failed\n", f);
		close(f);
		return -1;
	}
	close(f);
	return 0;
}

int GCD_module(unsigned int A1, unsigned int A2){
	// Saving two numbers to the files
	int err;
	err = write_file(SYSFS_pjebarg1_IN, A1);
	if(err<0) return -1;
	err = write_file(SYSFS_pjebarg2_IN, A2);
	if(err<0) return -1;

	// Since the module starts when we write something under A2,
	// we check the operation status, if it is 0,
	// it means that the module has determined the GCD
	unsigned int status;
	while(1){
		status = read_file(SYSFS_pjebstatus_OUT);
		if(status < 0) return -1; 
		if(status == 0) break;
	}

	// Reading calculated GCD from the file
	unsigned int result;
	result = read_file(SYSFS_pjebresult_OUT);
	if(result < 0) return -1; 
	printf("Podane argumenty:\n");
	printf("A1 = 0x%lx,\tA2 = 0x%lx,\tGCD = 0x%lx\n", A1, A2, result);
	return 0;
}

int GCD_module_test(){
	// Test numbers and correct caluclated values
	unsigned int A1[9] = {10, 12, 100, 56, 461952, 314080416, 45296490, 290456829, 4294967295};
	unsigned int A2[9] = {5, 3, 25, 42, 116298, 7966496, 24826148, 53667, 4294967295};
	unsigned int W[9] = {5, 3, 25, 14, 18, 32, 526, 9, 4294967295};
	int err;

	// Starting tests in a loop
	for(int i; i<9; i++){
		printf("*Test %d*\n", i+1);
		err = GCD_module(A1[i], A2[i]);
		if(err<0) return -1;
		printf("Prawidlowy wynik: 0x%lx\n", W[i]);
		printf("------------------------------\n");
	}
	
	return 0;
}

int main(void){
	printf("***Testing module***\n");
	printf("Files opend correctly.\n");
	printf("Testing module...\n");

	// Calling a function to test the module along with error handling
	int err = GCD_module_test();
	if(err<0) exit(1);

	printf("\nTests passed!\n");
	printf("Everything is OK. Bye!\n");

	return 0;
} 
