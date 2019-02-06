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
double Evaluate (double lhs_value,int assign_type,double rhs_value);


%}

%union {
    stEntry* entry;
    double fraction;
    long val;
    int ival;
    char *st;
}

%start start_state

%token <val> NUMBER
%token <entry> IDENTIFIER
%token <ival> INTEGER_CONSTANT
%token <fraction> FLOATING_CONSTANT
%token <ival> HEXADECIMAL_CONSTANT
%token <ival> OCTAL_CONSTANT
%token <st> STRING_CONSTANT
%token <entry> CHARACTER_CONSTANT



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
%token SINGLE_LINE MULTI_LINE

/* Preprocessor directives */
%token INCLUDE DEF

%type <fraction> exp 
%type <fraction> sub_exp
%type <fraction> exp_type
%type <ival> binary_exp
%type <fraction> arithmetic_exp
%type <fraction> assignment_exp
%type <fraction> float_constant
%type <ival> int_constant
%type <entry> id
%type <ival> assign_op
%type <fraction> unary_expr

%left COMMA
%right PLUSEQ MINUSEQ MULEQ DIVEQ MODEQ
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

%nonassoc IFX
%nonassoc ELSE

%%

start_state:  option start_state | option ;

option:  function | declaration | preprocessor_directive | comments;

preprocessor_directive: INCLUDE | DEF;

comments: SINGLE_LINE | MULTI_LINE;

function: function_decl | function_def;

function_decl: datatype IDENTIFIER OPEN_PARENTHESIS args CLOSE_PARENTHESIS SEMICOLON;

function_def: datatype IDENTIFIER OPEN_PARENTHESIS args CLOSE_PARENTHESIS block_statement;

args: args COMMA args_def |
      args_def |
      ;

args_def: datatype IDENTIFIER;

declaration: datatype declaration_list SEMICOLON;
declaration_list: declaration_list COMMA decl | decl;
decl: id | id OPEN_SQR_BKT int_constant CLOSE_SQR_BKT | assignment_exp;
datatype: sign_extension type | type;
sign_extension: SIGNED | UNSIGNED;
type: INT | LONG | SHORT | CHAR | LONG_LONG | FLOAT;

assignment_exp: id assign_op arithmetic_exp     {$$ = $1->value = Evaluate($1->value,$2,$3);}
    |id assign_op id OPEN_SQR_BKT int_constant CLOSE_SQR_BKT  {$$ = 0;}
	|id assign_op unary_expr                      {$$ = $1->value = Evaluate($1->value,$2,$3);}
	|unary_expr assign_op unary_expr               {$$ = 0;}
    ;

assign_op: EQ                                      {$$ = EQ;}
    |PLUSEQ                                   {$$ = PLUSEQ;}
    |MINUSEQ                                    {$$ = MINUSEQ;}
    |MULEQ                                    {$$ = MULEQ;}
    |DIVEQ                                    {$$ = DIVEQ;}
    |MODEQ                                    {$$ = MODEQ;}
;

unary_expr:	id INC  {$$ = $1->value = ($1->value)++;}
	        |id DEC  {$$ = $1->value = ($1->value)--;}
	        |DEC id  {$$ = $2->value = --($2->value);}
            |INC id {$$ = $2->value = ++($2->value);}
            ;
statement_type: single_statement | block_statement ;

single_statement: if_statement | while_statement | RETURN SEMICOLON | BREAK SEMICOLON | CONTINUE SEMICOLON | SEMICOLON | 
                    function | declaration | preprocessor_directive | comments   ;

block_statement: OPEN_BRACE statement CLOSE_BRACE;

statement: statement statement_type | ;

if_statement: IF OPEN_PARENTHESIS exp CLOSE_PARENTHESIS statement_type %prec IFX| IF OPEN_PARENTHESIS exp CLOSE_PARENTHESIS statement_type ELSE statement_type ;

while_statement: WHILE OPEN_PARENTHESIS exp CLOSE_PARENTHESIS statement_type;

exp: exp_type COMMA exp { $$ = $1,$3;} | exp_type | OPEN_PARENTHESIS exp CLOSE_PARENTHESIS { $$ = $2;};

exp_type: sub_exp | binary_exp;

sub_exp: sub_exp AND sub_exp	{ $$ = $1 && $3; }
        | sub_exp OR sub_exp { $$ = $1 || $3; }
        | NOT sub_exp { $$  = !$2; }
        | sub_exp EQEQ sub_exp { $$ = $1 == $3; }
        | sub_exp NEQ sub_exp { $$ = $1 != $3; }
        | sub_exp GT sub_exp { $$ = $1 > $3; }
        | sub_exp LT sub_exp { $$ = $1 < $3; }
        | sub_exp GE sub_exp { $$ = $1 >= $3; }
        | sub_exp LE sub_exp { $$ = $1 <= $3; }
        | arithmetic_exp 
        | unary_expr {$$ = $1;}
        | assignment_exp
		;
 
arithmetic_exp: arithmetic_exp PLUS arithmetic_exp	{ $$ = $1 + $3; }
                | arithmetic_exp MINUS arithmetic_exp { $$ = $1 - $3; }
		        | arithmetic_exp MUL arithmetic_exp	{ $$ = $1 * $3; }
                | arithmetic_exp DIV arithmetic_exp { $$ = $1 / $3; }
                | float_constant
                | int_constant
                | id 
                ;
binary_exp: binary_exp BIT_AND binary_exp	{ $$ = $1 & $3; }
            | binary_exp BIT_OR binary_exp { $$ = $1 | $3; }
            | binary_exp BIT_XOR binary_exp { $$ = $1 ^ $3; }
            | binary_exp LSHIFT binary_exp	{ $$ = $1 << $3; }
            | binary_exp RSHIFT binary_exp { $$ = $1 >> $3; }
            | binary_exp MOD binary_exp { $$ = $1 % $3; }
            | int_constant
            | id
            ;


int_constant: INTEGER_CONSTANT { $$ = $1;}
            | CHARACTER_CONSTANT { $$ = $1; }
            ;

float_constant: FLOATING_CONSTANT { $$ = $1;}
                        ;

id: IDENTIFIER;


%%

double Evaluate (double lhs_value,int assign_type,double rhs_value)
{
	switch(assign_type)
	{
		case EQ: return rhs_value;
		case PLUSEQ: return (lhs_value + rhs_value);
		case MINUSEQ: return (lhs_value - rhs_value);
		case MULEQ: return (lhs_value * rhs_value);
		case DIVEQ: return (lhs_value / rhs_value);
		case MODEQ: return ((int)lhs_value % (int)rhs_value);
	}
}


void yyerror (char const *s) {

    extern int yylineno;
    printf("Error message: %s Line no: %d \n", s, yylineno);
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
