%{
#define YACC_FILE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
//#include "symbolTable.h"
#include "share_symbol.h"
stEntry ** constant_table, ** symbol_table;
 int yylex();
void yyerror(const char *s);



%}

%union {
    stEntry* entry;
    double fraction;
    long val;
    int ival;
}

%start start_state

%token <val> NUMBER
%token <entry> IDENTIFIER
%token <ival> INTEGER_CONSTANT


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
%token PLUS MINUS MOD DIV MUL INC DEC

/* Assignment Operators */
%token PLUSEQ MINUSEQ MULEQ DIVEQ MODEQ 

/* Punctuators */
%token COMMA SEMICOLON OPEN_PARENTHESIS CLOSE_PARENTHESIS OPEN_BRACE CLOSE_BRACE OPEN_SQR_BKT CLOSE_SQR_BKT

/* Comments */
%token SINGLE_LINE

/* Constants */ 
%token STRING_CONSTANT HEXADECIMAL_CONSTANT OCTAL_CONSTANT FLOATING_CONSTANT

 
%type <fraction> exp 
%type <fraction> sub_exp
%type <ival> binary_exp
%type <fraction> arithmetic_exp

%left COMMA
%left OR
%left AND
%left BIT_OR
%left BIT_XOR
%left BIT_AND
%left EQEQ NEQ
%left GT LT GE LE 
%left LSHIFT RSHIFT
%left PLUS MINUS
%left MUL DIV MOD
%right NOT
%%

start_state: start_state option | option;

option:  function | declaration | preprocessor_directive;

preprocessor_directive: INCLUDE | DEF;


function: datatype ;

declaration: datatype declaration_list SEMICOLON;
declaration_list: declaration_list COMMA decl | decl;
decl: IDENTIFIER | assignment_exp;
datatype: sign_extension type | type;
sign_extension: SIGNED | UNSIGNED;
type: INT | LONG | SHORT | CHAR | LONG_LONG;



statement_type: single_statement | block_statement ;

single_statement: if_statement | while_statement | RETURN SEMICOLON | BREAK SEMICOLON | CONTINUE SEMICOLON | SEMICOLON | function_call | ;

block_statement: OPEN_BRACE statement CLOSE_BRACE;

statement: statement statement_type | ;

if_statement: ;

while_statement: WHILE OPEN_PARENTHESIS exp CLOSE_PARENTHESIS statement_type;

function_call: ;

exp: exp ',' sub_exp { $$ = $1,$3;} | sub_exp { $$ = $1;};

sub_exp: NUMBER	{ $$ = $1; }
        | sub_exp AND sub_exp	{ $$ = $1 && $3; }
        | sub_exp OR sub_exp { $$ = $1 || $3; }
        | sub_exp EQEQ sub_exp { $$ = $1 == $3; }
        | sub_exp NEQ sub_exp { $$ = $1 != $3; }
        | sub_exp GT sub_exp { $$ = $1 > $3; }
        | sub_exp LT sub_exp { $$ = $1 < $3; }
        | sub_exp GE sub_exp { $$ = $1 >= $3; }
        | sub_exp LE sub_exp { $$ = $1 <= $3; }
        | NOT sub_exp { $$  = !$2; }
        | binary_exp
		;
 
arithmetic_exp: arithmetic_exp PLUS arithmetic_exp	{ $$ = $1 + $3; }
                | arithmetic_exp MINUS arithmetic_exp { $$ = $1 - $3; }
		        | arithmetic_exp MUL arithmetic_exp	{ $$ = $1 * $3; }
                | arithmetic_exp DIV arithmetic_exp { $$ = $1 / $3; }
                | arithmetic_exp MOD arithmetic_exp { $$ = $1 % $3; }
                | NUMBER { $$ = $1; }
                ;

binary_exp: binary_exp BIT_AND binary_exp	{ $$ = $1 & $3; }
            | binary_exp BIT_OR binary_exp { $$ = $1 | $3; }
            | binary_exp BIT_XOR binary_exp { $$ = $1 ^ $3; }
            | binary_exp LSHIFT binary_exp	{ $$ = $1 << $3; }
            | binary_exp RSHIFT binary_exp { $$ = $1 >> $3; }
            | INTEGER_CONSTANT { $$ = $1; }
            ;

assignment_exp: ;
%%

void yyerror (char const *s) {

    extern int yylineno;
    extern char *yytext;
    printf ("ERROR: %s at symbol: %s Line Number: %d\n", s,yytext,yylineno);
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
