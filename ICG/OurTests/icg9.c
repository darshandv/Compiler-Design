int main() {
    int a,b,c;
    a =5;
    b =6 ;
    c =9;
    while(a> 0) {
        while(b>1){
            while(c>2) {
                c = c - 1;
            }
            if(b==2) {
                break;
            }
            b = b - 1;

        }
        a = a - 3;
    }
    return 0;
}