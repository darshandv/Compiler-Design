#include<stdio.h>
#include<stdlib.h>

int main()
{
  int x, y;
  long long int total, diff;
  int *ptr;
  unsigned int a = 0x0f;
  unsigned int b = 0115;
  unsigned int o = 01187;
  long int mylong = 123456l;
  long int i, j;
  for(i=0; i < 10; i++){
    for(j=10; j > 0; j--){
    printf("%d",i);
    }
  }
  x = -10, y = 20;
  x=x*3/2;
  total = x + y;
  diff = x - y;
  int rem = x % y;
  printf ("Total = %d \n", total);
}
