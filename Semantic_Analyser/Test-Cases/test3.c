#include <stdio.h>

int main() {
    int a= 5;
    unsigned int b = 10;
    int arr[5];
    short c = 2;
    a++;
    while(a > 0) {
        int d = a + b - c + arr[0];
        --a;
    }
} 