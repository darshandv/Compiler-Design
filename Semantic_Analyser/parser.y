%{
#define YACC_FILE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#define YYSTYPE char *
#include "lex.yy.c"
#include "symbolTable.h"

#define SYMBOL_TABLE symbol_table_list[current_scope].symbol_table

extern stEntry** constant_table;
int che = 0;

int dtype = 0;
int in_loop = 0;

table_t symbol_table_list[NUM_TABLES];

stEntry ** constant_table, ** symbol_table;
int yylex();
void yyerror(const char *s);
%}

%define parse.lac full
%define parse.error verbose


%start start_state



/* Constants */
%token IDENTIFIER INTEGER_CONSTANT FLOATING_CONSTANT STRING_CONSTANT CHARACTER_CONSTANT

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
%left INC DEC

%nonassoc IFX
%nonassoc ELSE

%%

start_state:  option start_state | option ;

option:  function | declaration | preprocessor_directive | comments;

preprocessor_directive: INCLUDE | DEF;

comments: SINGLE_LINE | MULTI_LINE;

function: function_decl | function_def;

function_decl: datatype IDENTIFIER OPEN_PARENTHESIS args CLOSE_PARENTHESIS SEMICOLON;

function_def: datatype IDENTIFIER  OPEN_PARENTHESIS function_def_continue 
                                                                                    
                                                                                     
function_def_continue:
    args CLOSE_PARENTHESIS block_statement ;


args: args COMMA args_def |
      args_def |
      ;

args_def: datatype id;

args_call_def: id COMMA args_call_def | id |  int_constant |; 

declaration: datatype declaration_list SEMICOLON ;
declaration_list: declaration_list COMMA decl | decl;
decl: id { stEntry* first  =  search(SYMBOL_TABLE, $1); first->data_type = dtype; printf("%s %d\n", first->lexeme, first->data_type);}  
    | id OPEN_SQR_BKT int_constant CLOSE_SQR_BKT |assignment_exp ;
datatype: sign_extension type | type;
sign_extension: SIGNED | UNSIGNED;
type: INT {dtype = INT;} 
      | LONG | SHORT | CHAR | LONG_LONG | FLOAT;

assignment_exp: id EQ assignment_options {
    if($3[0] >= 48 && $3[0] <=57) {
        stEntry* result =  search(constant_table, $3);
        stEntry* first  =  search(SYMBOL_TABLE, $1);
        printf("%p %p\n",result, first );
        if(result->data_type != first->data_type) {
            printf("Datatype mismatch!\n");
            exit(1);
        }
        } else {
        stEntry* result =  search(SYMBOL_TABLE, $3);
        stEntry* first  =  search(SYMBOL_TABLE, $1);
        printf("%p %p\n",result, first );
        if(result->data_type != first->data_type) {
            printf("Datatype mismatch!\n");
            exit(1);

        }

    }
}
                |
                id EQ exp ;
shorthand_exp: id PLUSEQ assignment_options 
                | id MINUSEQ assignment_options 
                | id MULEQ  assignment_options
                | id DIVEQ assignment_options
                | id MODEQ assignment_options;
                ;
                

assignment_options: int_constant {$$ = $1;} | float_constant {$$ = $1;} | id {$$ = $1;} | id OPEN_SQR_BKT id CLOSE_SQR_BKT | id OPEN_SQR_BKT int_constant CLOSE_SQR_BKT ;

statement_type: single_statement | block_statement ;

single_statement: if_statement | while_statement | return  | BREAK SEMICOLON {if(in_loop == 0) {printf("Illegal break statement, not in loop!\n"); exit(1);} } | CONTINUE SEMICOLON {if(in_loop == 0) {printf("Illegal continue statement, not in loop!\n"); exit(1);} } |  SEMICOLON | function_call SEMICOLON | 
                    function | declaration | preprocessor_directive | comments | assignment_exp SEMICOLON | inc_dec_exp SEMICOLON | shorthand_exp SEMICOLON;

return: RETURN SEMICOLON | RETURN id SEMICOLON | RETURN int_constant SEMICOLON;

function_call: id OPEN_PARENTHESIS args_call_def CLOSE_PARENTHESIS ;

block_statement: OPEN_BRACE {current_scope = create_new_scope();}

                 
                 statement 
                 
                 
                 CLOSE_BRACE {current_scope = exit_scope();} ;

statement: statement statement_type | ;

if_statement: IF OPEN_PARENTHESIS exp CLOSE_PARENTHESIS statement_type %prec IFX| IF OPEN_PARENTHESIS exp CLOSE_PARENTHESIS statement_type ELSE statement_type ;

while_statement: WHILE OPEN_PARENTHESIS exp CLOSE_PARENTHESIS {in_loop =1;}statement_type {in_loop = 0;}

exp: exp_type COMMA exp | exp_type;

exp_type: sub_exp | binary_exp;

sub_exp: sub_exp AND sub_exp
        | sub_exp OR sub_exp
        | NOT sub_exp
        | sub_exp EQEQ sub_exp
        | sub_exp NEQ sub_exp
        | sub_exp GT sub_exp 
        | sub_exp LT sub_exp
        | sub_exp GE sub_exp
        | sub_exp LE sub_exp
        | arithmetic_exp 
		;
 
arithmetic_exp: arithmetic_exp PLUS arithmetic_exp
                | arithmetic_exp MINUS arithmetic_exp 
		        | arithmetic_exp MUL arithmetic_exp	
                | arithmetic_exp DIV arithmetic_exp
                | assignment_options
                ;
binary_exp: binary_exp BIT_AND binary_exp
            | binary_exp BIT_OR binary_exp 
            | binary_exp BIT_XOR binary_exp 
            | binary_exp LSHIFT binary_exp	
            | binary_exp RSHIFT binary_exp 
            | binary_exp MOD binary_exp 
            | int_constant
            | id
            ;
            

inc_dec_exp: INC id  | DEC id | id INC | id DEC;


int_constant: INTEGER_CONSTANT {int val = strtol(yytext,0,10); insert(constant_table,$1, val,INT);$$=$1;}
            | CHARACTER_CONSTANT {int val = $1[1]; insert(constant_table,$1, val,INT);$$=$1;};
                                    


float_constant: FLOATING_CONSTANT   {float val = strtof($1,NULL); insert(constant_table,$1, val,FLOATING_CONSTANT);$$=$1;};

id: IDENTIFIER { insert(SYMBOL_TABLE,$1,INT_MAX,IDENTIFIER);}
%%


void yyerror (char const *s) {
    extern int yylineno;
    printf("Error message: %s Line no: %d \n", s, yylineno);
 }


int main(int argc, char *argv[])
{
    extern FILE *yyin;
	int i;
	 for(i=0; i<NUM_TABLES;i++)
	 {
	  symbol_table_list[i].symbol_table = NULL;
	  symbol_table_list[i].parent = -1;
	 }

	constant_table = create_table();
    symbol_table_list[0].symbol_table = create_table();
	yyin = fopen(argv[1], "r");
	if(!yyparse())
	{
		printf("\nParsing complete\n");
	}
	else
	{
			printf("\nParsing failed\n");
	}

    printf("SYMBOL TABLES\n\n");
    display_all();

	printf("CONSTANT TABLE");
	display_constant_table(constant_table);    

	return 0;
}