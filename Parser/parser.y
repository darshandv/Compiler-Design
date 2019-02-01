%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "symbolTable.h"
#include "share_symbol.h"
stEntry ** constant_table, ** symbol_table;
int yylex();
void yyerror(const char *s);



%}

%union {
    stEntry* entry;
    double fraction;
    long val;
}

%start start_state

%token <value> NUMBER
%token <entry> IDENTIFIER


/* Preprocessing Directive Tokens */
%token INCLUDE DEF

/* Data Type Tokens */
%token CHAR SHORT INT LONG LONG_LONG SIGNED UNSIGNED

/* Keyword Tokens */
%token IF ELSE WHILE RETURN CONTINUE BREAK

/* Relational Operators */
%token EQ EQEQ NEQ GT LT GE LE 

/* Logical and Bitwise Operators */
%token OR AND NOT BIT_OR BIT_XOR BIT_AND LSHIFT RSHIFT

/* Arithmetic Operators */
%token PLUS MINUS MOD DIV MUL INC DEC MODULO

/* Assignment Operators */
%token PLUSEQ MINUSEQ MULEQ DIVEQ MODEQ 

/* Punctuators */
%token COMMA SEMICOLON OPEN_PARENTHESIS CLOSE_PARENTHESIS OPEN_BRACE CLOSE_BRACE OPEN_SQR_BKT CLOSE_SQR_BKT

/* Special */
%token OPEN_SQR_BKT CLOSE_SQR_BKT 

/* Comments */
%token SINGLE_LINE

/* Constants */ 
%token STRING_CONSTANT INTEGER_CONSTANT HEXADECIMAL_CONSTANT OCTAL_CONSTANT FLOATING_CONSTANT

 
%type <fraction> exp 

%left COMMA
%left OR
%left AND
%left BIT_OR
%left BIT_XOR
%left BIT_AND
%left EQEQ NEQ
%left GT LT GE LE 
%left LSHIFT RSHIFT
%left	PLUS MINUS
%left	MUL DIV MOD
%right NOT
%%

start_state: start_state option | option;

option:  preprocessor_directive;

preprocessor_directive: INCLUDE | DEF;

/*
declaration: ;

datatype: sign_extension type | type;
sign_extension: SIGNED | UNSIGNED;
type: INT | LONG | SHORT | CHAR | LONG_LONG;

statement_type: single_statement | block_statement ;

single_statement: if_statement | while_statement | RETURN SEMICOLON | BREAK SEMICOLON | CONTINUE SEMICOLON | SEMICOLON | function_call | ;

block_statement: OPEN_BRACE statement CLOSE_BRACE;

statement: statement statement_type | ;




exp: exp ',' sub_exp { $$ = $1,$3;} | sub_exp { $$ = $1;};

sub_exp: NUMBER	{ $$ = $1; }
		| sub_exp PLUS sub_exp	{ $$ = $1 + $3; }
        | sub_exp MINUS sub_exp { $$ = $1 - $3; }
		| sub_exp MUL sub_exp	{ $$ = $1 * $3; }
        | sub_exp DIV sub_exp { $$ = $1 / $3; }
    | sub_exp LSHIFT sub_exp	{ $$ = $1 << $3; }
        | sub_exp RSHIFT sub_exp { $$ = $1 >> $3; }
    | sub_exp AND sub_exp	{ $$ = $1 && $3; }
        | sub_exp OR sub_exp { $$ = $1 || $3; }
    | sub_exp BIT_AND sub_exp	{ $$ = $1 & $3; }
        | sub_exp BIT_OR sub_exp { $$ = $1 | $3; }
    | sub_exp BIT_XOR sub_exp { $$ = $1 ^ $3; }
        | sub_exp EQEQ sub_exp { $$ = $1 == $3; }
    | sub_exp NEQ sub_exp { $$ = $1 != $3; }
        | sub_exp GT sub_exp { $$ = $1 > $3; }
    | sub_exp LT sub_exp { $$ = $1 < $3; }
        | sub_exp GE sub_exp { $$ = $1 >= $3; }
    | sub_exp LE sub_exp { $$ = $1 <= $3; }
        | NOT sub_exp { $$  = !$2; }
		;
 */

%%

void yyerror (char const *s) {
   fprintf (stderr, "ERROR %s\n", s);
 }

int main(int argc, char *argv[])
{
    extern FILE *yyin;
	symbol_table = new_table();
	constant_table = new_table();
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
