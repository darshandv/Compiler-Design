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
%token <fraction> FLOATING_CONSTANT
%token <ival> HEXADECIMAL_CONSTANT
%token <ival> OCTAL_CONSTANT
%token <entry> STRING_CONSTANT
%token <entry> CHARACTER_CONSTANT




/* Preprocessing Directive Tokens */
%token INCLUDE DEF

/* Data Type Tokens */
%token CHAR SHORT INT LONG LONG_LONG FLOAT SIGNED UNSIGNED

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

%type <fraction> exp 
%type <fraction> sub_exp
%type <ival> binary_exp
%type <fraction> arithmetic_exp
%type <fraction> relational_exp
%type <fraction> logical_exp

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

start_state: start_state option | option ;

option:  function | declaration | preprocessor_directive | comments;

preprocessor_directive: INCLUDE | DEF;

comments: SINGLE_LINE;

function: function_decl | function_def;

function_decl: datatype IDENTIFIER OPEN_PARENTHESIS args CLOSE_PARENTHESIS SEMICOLON;

function_def: datatype IDENTIFIER OPEN_PARENTHESIS args CLOSE_PARENTHESIS OPEN_BRACE function_body CLOSE_BRACE;

function_body: declaration | 
               statement |
               function_body function_body;

args: args COMMA args_def |
      args_def |
      ;

args_def: datatype IDENTIFIER;

declaration: datatype declaration_list SEMICOLON;
declaration_list: declaration_list COMMA decl | decl;
decl: IDENTIFIER | assignment_exp;
datatype: sign_extension type | type;
sign_extension: SIGNED | UNSIGNED;
type: INT | LONG | SHORT | CHAR | LONG_LONG | FLOAT;

assignment_exp: IDENTIFIER EQ value_exp;
value_exp: IDENTIFIER | INTEGER_CONSTANT | FLOATING_CONSTANT; 
statement_type: single_statement | block_statement ;

single_statement: if_statement | while_statement | RETURN SEMICOLON | BREAK SEMICOLON | CONTINUE SEMICOLON | SEMICOLON |  ;

block_statement: OPEN_BRACE statement CLOSE_BRACE;

statement: statement statement_type | ;

if_statement: IF OPEN_PARENTHESIS exp CLOSE_PARENTHESIS statement_type | IF OPEN_PARENTHESIS exp CLOSE_PARENTHESIS statement_type ELSE statement_type ;

while_statement: WHILE OPEN_PARENTHESIS exp CLOSE_PARENTHESIS statement_type;
/*
function_call: IDENTIFIER OPEN_PARENTHESIS args_call CLOSE_PARENTHESIS SEMICOLON;

args_call: args_call COMMA args_call_def | args_call_def | ;

args_call_def: IDENTIFIER | INTEGER_CONSTANT | FLOATING_CONSTANT | OCTAL_CONSTANT | STRING_CONSTANT | HEXADECIMAL_CONSTANT ;
*/

exp: exp ',' sub_exp { $$ = $1,$3;} | sub_exp { $$ = $1;};

sub_exp: logical_exp 
        | binary_exp 
        | relational_exp 
        | arithmetic_exp 
        | assignment_exp 
		;
 
arithmetic_exp: arithmetic_exp PLUS arithmetic_exp	{ $$ = $1 + $3; }
                | arithmetic_exp MINUS arithmetic_exp { $$ = $1 - $3; }
		        | arithmetic_exp MUL arithmetic_exp	{ $$ = $1 * $3; }
                | arithmetic_exp DIV arithmetic_exp { $$ = $1 / $3; }
                | INTEGER_CONSTANT { $$ = $1; }
                | FLOATING_CONSTANT { $$ = $1 ;}
                | OCTAL_CONSTANT { $$ = $1 ;}
                | HEXADECIMAL_CONSTANT { $$ = $1 ;}
                | IDENTIFIER { $$ = $1->value; }
                ;

logical_exp:    sub_exp AND sub_exp	{ $$ = $1 && $3; }
                | sub_exp OR sub_exp { $$ = $1 || $3; }
                | NOT sub_exp { $$  = !$2; }
                | INTEGER_CONSTANT { $$ = $1; }
                | FLOATING_CONSTANT { $$ = $1 ;}
                | OCTAL_CONSTANT { $$ = $1 ;}
                | HEXADECIMAL_CONSTANT { $$ = $1 ;}
                | IDENTIFIER { $$ = $1->value; }
                ;

binary_exp: binary_exp BIT_AND binary_exp	{ $$ = $1 & $3; }
            | binary_exp BIT_OR binary_exp { $$ = $1 | $3; }
            | binary_exp BIT_XOR binary_exp { $$ = $1 ^ $3; }
            | binary_exp LSHIFT binary_exp	{ $$ = $1 << $3; }
            | binary_exp RSHIFT binary_exp { $$ = $1 >> $3; }
            | binary_exp MOD binary_exp { $$ = $1 % $3; }
            | INTEGER_CONSTANT { $$ = $1; }
            | IDENTIFIER { $$ = $1->value; }
            ;

relational_exp: relational_exp EQEQ relational_exp { $$ = $1 == $3; }
                | relational_exp NEQ relational_exp { $$ = $1 != $3; }
                | relational_exp GT relational_exp { $$ = $1 > $3; }
                | relational_exp LT relational_exp { $$ = $1 < $3; }
                | relational_exp GE relational_exp { $$ = $1 >= $3; }
                | relational_exp LE relational_exp { $$ = $1 <= $3; }
                | IDENTIFIER { $$ = $1->value; }
                | INTEGER_CONSTANT { $$ = $1 ;}
                | FLOATING_CONSTANT { $$ = $1 ;}
                | OCTAL_CONSTANT { $$ = $1 ;}
                | HEXADECIMAL_CONSTANT { $$ = $1 ;}
                ;

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
    printf("\n\tConstant table");
	display(constant_table);
	fclose(yyin);
	return 0;
}
