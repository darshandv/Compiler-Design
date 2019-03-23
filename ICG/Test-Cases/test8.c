#include <stdio.h>

int main() {
    int i = 1<<10;
    int j = 1e4;
    int k = 012;
    int l = 0x8;
    i /= 4;
    int j  = i ^ 3;
