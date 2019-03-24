int f1() {
    return 0;
}

int f2() {
    return 1;
}

int main() {
    int a =2 + 3;

    int b= 4;

    if(a > b) {
        f1();
        if(a == 4) {
            int in_in_if = 4;
        }
        int in_out_if = 5;
    }
    else {
        f2();
    }
    return 0;
}