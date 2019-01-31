%{
#include <stdio.h>
#include "calc.h" 
int yylex();

%}
%union {
    long value;
}

%start input

%type <value> expression 
%token <value> NUMBER
%left PLUS MINUS
%left MUL DIV


%%

input: |
    expression { printf("result: %ld\n", $1);}


expression:NUMBER { $$ = $1; } |
     expression PLUS expression { $$ = $1 + $3; }
    | expression MINUS expression { $$ = $1 - $3; }
    | expression DIV expression { $$ = $1 - $3; }
    | expression MUL expression { $$ = $1 - $3; }
    ;
%%

void yyerror (char const *s) {
   fprintf (stderr, "ERROR %s\n", s);
 }

int main() {
  yyparse();
  return 0;
}
