#include <stdio.h>
#include <stdlib.h>
int main(int argc, char *argv[])
{
    char buff[5];
    int a = 4;
    char c = 'x';
    if(argc < 2) {
        printf("Input argument needed to exploit.\n");
        a = (a<<1) & (a&&a);
        exit(1);
    }

    strcpy(buff, argv[1]);

    printf("You typed: %s \n", argv[1]);
    return 0;
}

