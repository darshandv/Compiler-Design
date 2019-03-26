int main() {
    int a,b,c,d;
    a = (b-c) * d + (c-b)*d;
    b = (a<<d) ^ (c&d) | (a);
    return 0;
}