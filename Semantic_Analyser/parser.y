%{
#define YACC_FILE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#define YYSTYPE char *
#include "lex.yy.c"
#include "symbolTable.h"

#define SYMBOL_TABLE symbol_table_list[current_scope].symbol_table
#define SYMBOL_TABLE_INDEX symbol_table_list[current_scope]

extern stEntry** constant_table;
int che = 0;

int dtype = 0;
int in_loop = 0;
int is_declaration  =0 ;
int is_decl_temp = 0;
extern int yylineno;

table_t symbol_table_list[NUM_TABLES];

stEntry ** constant_table, ** symbol_table;
int yylex();
void yyerror(const char *s);
bool type_check(char* , char* );
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

declaration: datatype declaration_list SEMICOLON {is_declaration = 0;};
declaration_list: declaration_list COMMA decl | decl;
decl: id { stEntry* first  =  search_recursive($1); first->data_type = dtype;}  
    | id OPEN_SQR_BKT int_constant CLOSE_SQR_BKT {
                                                    if(is_declaration) {
                                                        int array_index = strtol($3,0,10);
                                                        if(array_index<=0) 
                                                            yyerror("Size of array is not positive\n");
                                                        else {
                                                            stEntry* result = search_recursive($1);
                                                            result->array_dimension = array_index; 
                                                        }
                                                        }
                                                }
    |assignment_exp {is_decl_temp=is_declaration;is_declaration=0;};
datatype: sign_extension type {is_declaration = 1;} | type {is_declaration = 1;}
sign_extension: SIGNED | UNSIGNED;
type: INT {dtype = INT;} 
      | LONG {dtype = LONG;}
      | SHORT {dtype=SHORT;}
      | CHAR {dtype=CHAR;}
      | LONG_LONG {dtype=LONG_LONG;}
      | FLOAT {dtype=FLOAT;};

assignment_exp: id EQ 
                assignment_options {
    // Recursive search needs to be added here as well, we'll deal with this later
    // if($3[0] >= 48 && $3[0] <=57) {
    //     stEntry* result =  search(constant_table, $3);
    //     stEntry* first  =  search(SYMBOL_TABLE, $1);
    //     printf("%p %p\n",result, first );
    //     if(result->data_type != first->data_type) {
    //         printf("Datatype mismatch!\n");
    //         exit(1);
    //     }
    //     } else {
    //     stEntry* result =  search(SYMBOL_TABLE, $3);
    //     stEntry* first  =  search(SYMBOL_TABLE, $1);
    //     printf("%p %p\n",result, first );
    //     if(result->data_type != first->data_type) {
    //         printf("Datatype mismatch!\n");
    //         exit(1);

    //     }
    is_declaration = is_decl_temp;
}
                |
                id EQ exp {is_declaration = is_decl_temp;}|
                id EQ id {
                    
                    if(!type_check($1,$3)){
                        yyerror("Type mismatch");
                        exit(0);
                    }
                    is_declaration = is_decl_temp;
                };
shorthand_exp: id PLUSEQ assignment_options 
                | id MINUSEQ assignment_options 
                | id MULEQ  assignment_options
                | id DIVEQ assignment_options
                | id MODEQ assignment_options;
                ;
                

assignment_options: int_constant {$$ = $1;} 
                    | float_constant {$$ = $1;}  
                    | id OPEN_SQR_BKT id CLOSE_SQR_BKT 
                    | id OPEN_SQR_BKT int_constant CLOSE_SQR_BKT { int array_index = strtol($3,0,10); stEntry* result  = search_recursive($1);  if(array_index > result->array_dimension) yyerror("Array index out of range"); if(array_index < 0) yyerror("Array index cannot be negative");}

statement_type: single_statement | block_statement ;

single_statement: if_statement | while_statement | return  | BREAK SEMICOLON {if(in_loop == 0) {printf("Line %3d: Illegal break statement, not in loop!\n", yylineno); exit(1);} } | CONTINUE SEMICOLON {if(in_loop == 0) {printf("Line %3d: Illegal continue statement, not in loop!\n", yylineno); exit(1);} } |  SEMICOLON | function_call SEMICOLON | 
                    function | declaration | preprocessor_directive | comments | assignment_exp SEMICOLON | inc_dec_exp SEMICOLON | shorthand_exp SEMICOLON;

return: RETURN SEMICOLON | RETURN id SEMICOLON | RETURN int_constant SEMICOLON;

function_call: id OPEN_PARENTHESIS args_call_def CLOSE_PARENTHESIS ;

block_statement: OPEN_BRACE {current_scope = create_new_scope();}

                 
                 statement 
                 
                 
                 CLOSE_BRACE {current_scope = exit_scope();} ;

statement: statement statement_type | ;

if_statement: IF OPEN_PARENTHESIS exp CLOSE_PARENTHESIS statement_type %prec IFX| IF OPEN_PARENTHESIS exp CLOSE_PARENTHESIS statement_type ELSE statement_type ;

while_statement: WHILE OPEN_PARENTHESIS exp CLOSE_PARENTHESIS {in_loop =1;}statement_type {in_loop = 0;} ;

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

id: IDENTIFIER {
    //stEntry* is_Present =  search(SYMBOL_TABLE, $1);
    stEntry* is_Present = NULL;
    int current_search_scope = current_scope;
    int scope_where_lexeme_found;
    table_t current_table = symbol_table_list[current_search_scope];
    // recursive search
    while(is_Present == NULL) {
        is_Present = search(current_table.symbol_table, $1);
        scope_where_lexeme_found = current_search_scope;
        if(current_search_scope==0) // if at outermost scope and still did not find.
            break;
        current_search_scope = current_table.parent;
        current_table = symbol_table_list[current_search_scope];
    }
    if(is_declaration==1){
        if(is_Present != NULL && scope_where_lexeme_found == current_scope) {
            printf("Line %3d: ERROR: %s is already declared!\n", yylineno, $1); exit(1);
        } else {
            insert(SYMBOL_TABLE,$1,INT_MAX,IDENTIFIER);
        }
        
    } else {  
        if(is_Present == NULL) {
            printf("Line %3d: ERROR: %s is an undeclared variable.\n", yylineno, $1); exit(1);
        }
        }
}

//


%%

void yyerror (char const *s) {
    extern int yylineno;
    printf("Error: Line %3d:  %s \n", yylineno, s);
    exit(1);
 }

bool type_check(char* lexeme, char* lexeme_prime){
    stEntry* entry = search_recursive(lexeme);
    stEntry* entry_prime = search_recursive(lexeme_prime);

    return entry->data_type == entry_prime->data_type;
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