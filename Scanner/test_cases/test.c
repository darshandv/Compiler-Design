#include <stdio.h>

// program to run a loop from 10 to 0
int main() {
	int i =10;
	long long unsigned int b = 10;
	/* this should be ignored*/while(i>=0) {
		printf("Current value of i: %d", i); // print statement
	}
	int a@b =5; //error
    int a = 045; // octal
    int b = 078; // error in octal
    int c = 0x7b; // hexadecimal
    int d = 0x6j; // should be an error
}
