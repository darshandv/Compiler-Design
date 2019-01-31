%{
#include <stdio.h>
#include "calc.h" 
int yylex();
stEntry ** constant_table, symbol_table;

%}
%union {
    double fraction;
    long val;
    string * op_val;
    stEntry* entry;
}

%start input

%type <value> expression 
%token <value> NUMBER
%left PLUS MINUS
%left MUL DIV


%%

start_state: |
    expression { printf("result: %ld\n", $1);}
    | declaration
    ;


expression:NUMBER { $$ = $1; } |
     expression PLUS expression { $$ = $1 + $3; }
    | expression MINUS expression { $$ = $1 - $3; }
    | expression DIV expression { $$ = $1 - $3; }
    | expression MUL expression { $$ = $1 - $3; }
    ;

declaration: 
%%

void yyerror (char const *s) {
   fprintf (stderr, "ERROR %s\n", s);
 }

int main(int argc, char *argv[])
{
	symbol_table = create_table();
	constant_table = create_table();
	yyin = fopen(argv[1], "r");
	if(!yyparse())
	{
		printf("\nParsing complete\n");
	}
	else
	{
			printf("\nParsing failed\n");
	}
	printf("\n\tSymbol table");
	display(symbol_table);
	fclose(yyin);
	return 0;
}
