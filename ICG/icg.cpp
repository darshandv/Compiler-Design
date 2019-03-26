#include <bits/stdc++.h>

using namespace std;


stack<pair<string, int> > icg_stack;

int t_counter = -1; // temp counter
int TAC_lineno = 1;
int l_counter = 1; // label counter


void check() {
    pair<string, int> tmp = icg_stack.top();
    if(tmp.first == "T")
        t_counter--;
}