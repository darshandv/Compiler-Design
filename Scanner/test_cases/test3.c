#include <stdio.h>
#include <stdlib.h>

int main(int argc, char const *argv[])
{
    int a@b =5; //error
    int a = 045; // octal
    int b = 078; // error in octal
    int c = 0x7b; // hexadecimal
    int d = 0x6j; // should be an error

    return 0;
}
