#include <stdio.h>

int add_something (){
    int a = 10;
    int b = 20;
    int c;
    c = a + b;
    return c;
}

int condition(){
    float d = 10.0;
    float e = 40.0;
    float f;
    
    if(d>f){
        f = d * e;
    }

    return f;
}

int main(){
    float p = 11.0;
    {   
        float k = 5.0;
        while (p && k){
            add_something();
            condition();
        }
    }
    return 0;
}