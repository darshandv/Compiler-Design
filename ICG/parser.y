%{
#define YACC_FILE
#include <bits/stdc++.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include <iostream>
#define YYSTYPE char *
#include "lex.yy.c"
#include "symbolTable.h"

using namespace std;

#define SYMBOL_TABLE symbol_table_list[current_scope].symbol_table
#define SYMBOL_TABLE_INDEX symbol_table_list[current_scope]

extern stEntry** constant_table;
int che = 0;

int dtype = 0;
int in_loop = 0;
int is_declaration  =0 ;
int is_decl_temp = 0;
int is_func = 0;
int is_func_scope = 0;
int found_ret = 0;
extern int yylineno;


table_t symbol_table_list[NUM_TABLES];

stEntry ** constant_table, ** symbol_table;
int yylex();
void yyerror(const char *s);
void type_check(char* , char* );

/* Headers for ICG Functions and variables */
#include "icg.cpp"
void gencode(string s);
string print_label();
string print_element(pair<string,int> p);
vector<string> ICG;


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

function_decl: datatype id OPEN_PARENTHESIS CLOSE_PARENTHESIS SEMICOLON {is_declaration = 0;};

function_def: datatype id OPEN_PARENTHESIS CLOSE_PARENTHESIS  {is_func =1;is_func_scope = current_scope; is_declaration = 0; string instruction =  "func begin " + string($2) + ":"; gencode(instruction);} block_statement ;
                                                                                    

declaration: datatype declaration_list SEMICOLON {is_declaration = 0;};
declaration_list: declaration_list COMMA decl | decl;
decl: id { stEntry* first  =  search_recursive($1); first->data_type = dtype;}  
    | id OPEN_SQR_BKT int_constant CLOSE_SQR_BKT {
                                                    if(is_declaration) {
                                                        int array_index = strtol($3,0,10);
                                                        if(array_index<=0){ 
                                                            yyerror("Size of array is not positive\n");
                                                            exit(1);
                                                        }
                                                        else {
                                                            stEntry* result = search_recursive($1);
                                                            result->array_dimension = array_index; 
                                                        }
                                                        }
                                                }
    |assignment_exp {is_decl_temp=is_declaration;is_declaration=0;};
datatype: sign_extension type {is_declaration = 1;} | type {is_declaration = 1;};
sign_extension: SIGNED | UNSIGNED;
type: INT {dtype = INT;} 
      | LONG {dtype = LONG;}
      | SHORT {dtype=SHORT;}
      | CHAR {dtype=CHAR;}
      | LONG_LONG {dtype=LONG_LONG;}
      | FLOAT {dtype=FLOAT;};

assignment_exp: id EQ exp {
                        is_declaration = is_decl_temp;
                        pair <string,int> op1;
                        op1 = icg_stack.top();
                        icg_stack.pop();
                        string instruction = string($1) + " = " + print_element(op1);
                        gencode(instruction);
                    }
                | id EQ id {
                    type_check($1,$3);
                    stEntry* rhs = search_recursive($3);
                    stEntry* lhs = search_recursive($1);
                    int val = rhs->value;
                    lhs->value = val;
                    is_declaration = is_decl_temp;
                    string instruction = string($1) + " = " + string($3) ;
                    gencode(instruction);
                }
                | id EQ int_constant{
                    type_check($1,$3);
                    int val = strtol($3, 0 ,10);
                    stEntry* result = search_recursive($1);
                    result->value = val;
                    is_declaration = is_decl_temp;
                    string instruction = string($1) + " = " + string($3) ;
                    gencode(instruction);
                }
                | id EQ float_constant{
                    type_check($1,$3);
                    is_declaration = is_decl_temp;
                }
                ;
shorthand_exp: id PLUSEQ assignment_options 
                | id MINUSEQ assignment_options 
                | id MULEQ  assignment_options
                | id DIVEQ assignment_options
                | id MODEQ assignment_options;
                ;
                

assignment_options: id{$$=$1; icg_stack.push({$1,-1});}|
                    int_constant {$$ = $1; icg_stack.push({$1,-1});} 
                    | float_constant {$$ = $1; icg_stack.push({$1,-1});}  
                    | id OPEN_SQR_BKT id CLOSE_SQR_BKT 
                    | id OPEN_SQR_BKT int_constant CLOSE_SQR_BKT { int array_index = strtol($3,0,10); stEntry* result  = search_recursive($1);  if(array_index > result->array_dimension) {yyerror("Array index out of range");exit(1);} if(array_index < 0) {yyerror("Array index cannot be negative");exit(1);}};

statement_type: single_statement | block_statement ;

single_statement: if_statement | while_statement | return {found_ret =1;} | BREAK SEMICOLON {if(in_loop == 0) {printf("Line %3d: Illegal break statement, not in loop!\n", yylineno); exit(1);}} | CONTINUE SEMICOLON {if(in_loop == 0) {printf("Line %3d: Illegal continue statement, not in loop!\n", yylineno); exit(1);} } |  SEMICOLON | function_call SEMICOLON | 
                    function | declaration | preprocessor_directive | comments | assignment_exp SEMICOLON | inc_dec_exp SEMICOLON | shorthand_exp SEMICOLON;

return: RETURN SEMICOLON { string instruction = "return"; gencode(instruction);} | RETURN id SEMICOLON { string instruction = "return\n"; gencode(instruction);} | RETURN int_constant SEMICOLON { string instruction = "return\n"; gencode(instruction);} | RETURN arithmetic_exp SEMICOLON { string instruction = "return"; gencode(instruction);}

function_call: id OPEN_PARENTHESIS  CLOSE_PARENTHESIS {string instruction = "call " + string($1); gencode(instruction);};

block_statement: OPEN_BRACE {current_scope = create_new_scope();}

                 
                 statement 
                 
                 
                 CLOSE_BRACE {if(is_func ==1 && found_ret ==0 && is_func_scope == SYMBOL_TABLE_INDEX.parent ) {yyerror("Function has no return statement");exit(1);} if(found_ret) is_func =0; found_ret =0 ;current_scope = exit_scope();} ;

statement: statement statement_type | ;

if_statement: IF OPEN_PARENTHESIS exp CLOSE_PARENTHESIS {pair <string,int> op1;op1 = icg_stack.top();icg_stack.pop();string instruction = "if " + print_element(op1) + " goto " + "L"+ to_string(l_counter); gencode(instruction); string next_if = "goto L" + to_string(l_counter+1); gencode(next_if);  gencode(print_label());} block_statement  {gencode(print_label());}%prec IFX 
;

while_statement: WHILE OPEN_PARENTHESIS exp CLOSE_PARENTHESIS {in_loop =1;}statement_type {in_loop = 0;} ;

exp: exp_type COMMA exp {$$=$3;} | exp_type {$$ = $1;};

exp_type: sub_exp {$$ = $1;}| binary_exp;

sub_exp: sub_exp AND sub_exp {//type_check($1,$3);
        pair<string,int> op1, op2;
        op1 = icg_stack.top();
        icg_stack.pop();
        op2 = icg_stack.top();
        icg_stack.pop();
        icg_stack.push({"T", ++t_counter});
        string instruction = "T" + to_string(t_counter) + " = " + print_element(op2) + " && " + print_element(op1);
        gencode(instruction);
        }
        | sub_exp OR sub_exp {//type_check($1,$3);
        pair<string,int> op1, op2;
        op1 = icg_stack.top();
        icg_stack.pop();
        op2 = icg_stack.top();
        icg_stack.pop();
        icg_stack.push({"T", ++t_counter});
        string instruction = "T" + to_string(t_counter) + " = " + print_element(op2) + " || " + print_element(op1);
        gencode(instruction);
        }
        | NOT sub_exp 
        | sub_exp EQEQ sub_exp {//type_check($1,$3);
        pair<string,int> op1, op2;
        op1 = icg_stack.top();
        icg_stack.pop();
        op2 = icg_stack.top();
        icg_stack.pop();
        icg_stack.push({"T", ++t_counter});
        string instruction = "T" + to_string(t_counter) + " = " + print_element(op2) + " == " + print_element(op1);
        gencode(instruction);
        }
        | sub_exp NEQ sub_exp {//type_check($1,$3);
        pair<string,int> op1, op2;
        op1 = icg_stack.top();
        icg_stack.pop();
        op2 = icg_stack.top();
        icg_stack.pop();
        icg_stack.push({"T", ++t_counter});
        string instruction = "T" + to_string(t_counter) + " = " + print_element(op2) + " != " + print_element(op1);
        gencode(instruction);
        }
        | sub_exp GT sub_exp {//type_check($1,$3);
        pair<string,int> op1, op2;
        op1 = icg_stack.top();
        icg_stack.pop();
        op2 = icg_stack.top();
        icg_stack.pop();
        icg_stack.push({"T", ++t_counter});
        string instruction = "T" + to_string(t_counter) + " = " + print_element(op2) + " > " + print_element(op1);
        gencode(instruction);
        }
        | sub_exp LT sub_exp {//type_check($1,$3);
        pair<string,int> op1, op2;
        op1 = icg_stack.top();
        icg_stack.pop();
        op2 = icg_stack.top();
        icg_stack.pop();
        icg_stack.push({"T", ++t_counter});
        string instruction = "T" + to_string(t_counter) + " = " + print_element(op2) + " < " + print_element(op1);
        gencode(instruction);
        }
        | sub_exp GE sub_exp {//type_check($1,$3);
        pair<string,int> op1, op2;
        op1 = icg_stack.top();
        icg_stack.pop();
        op2 = icg_stack.top();
        icg_stack.pop();
        icg_stack.push({"T", ++t_counter});
        string instruction = "T" + to_string(t_counter) + " = " + print_element(op2) + " >= " + print_element(op1);
        gencode(instruction);
        }
        | sub_exp LE sub_exp {//type_check($1,$3);
        pair<string,int> op1, op2;
        op1 = icg_stack.top();
        icg_stack.pop();
        op2 = icg_stack.top();
        icg_stack.pop();
        icg_stack.push({"T", ++t_counter});
        string instruction = "T" + to_string(t_counter) + " = " + print_element(op2) + " <= " + print_element(op1);
        gencode(instruction);
        }
        | arithmetic_exp {$$ = $1;}
		;
 
arithmetic_exp: arithmetic_exp PLUS arithmetic_exp { //type_check($1,$3);
                 //stEntry* val1 = search_recursive($1); 
                 //stEntry* val2 = search_recursive($3); 
                //int  result = (int)(val1->value + val2->value); 
                // char tmp[10]; $$ = my_itoa(result, tmp);
                pair<string,int> op1, op2;
                op1 = icg_stack.top();
                icg_stack.pop();
                op2 = icg_stack.top();
                icg_stack.pop();
                icg_stack.push({"T", ++t_counter});
                string instruction = "T" + to_string(t_counter) + " = " + print_element(op2) + " + " + print_element(op1);
                gencode(instruction);
                }
                | arithmetic_exp MINUS arithmetic_exp {//type_check($1,$3);
                 //stEntry* val1 = search_recursive($1); 
                 //stEntry* val2 = search_recursive($3);  
                 //int  result = (int)(val1->value - val2->value); 
                 //char tmp[10]; $$ = my_itoa(result, tmp);
                pair<string,int> op1, op2;
                op1 = icg_stack.top();
                icg_stack.pop();
                op2 = icg_stack.top();
                icg_stack.pop();
                icg_stack.push({"T", ++t_counter});
                string instruction = "T" + to_string(t_counter) + " = " + print_element(op2) + " - " + print_element(op1);
                gencode(instruction);
                 }
		        | arithmetic_exp MUL arithmetic_exp	{//type_check($1,$3); 
                //stEntry* val1 = search_recursive($1); 
                //stEntry* val2 = search_recursive($3);  
                //int  result = (int)(val1->value * val2->value);  
                //char tmp[10]; $$ = my_itoa(result, tmp);
                pair<string,int> op1, op2;
                op1 = icg_stack.top();
                icg_stack.pop();
                op2 = icg_stack.top();
                icg_stack.pop();
                icg_stack.push({"T", ++t_counter});
                string instruction = "T" + to_string(t_counter) + " = " + print_element(op1) + " * " + print_element(op2);
                gencode(instruction);
                }
                | arithmetic_exp DIV arithmetic_exp {//type_check($1,$3); 
                //stEntry* val1 = search_recursive($1); 
                //stEntry* val2 = search_recursive($3);  
                //int  result = (int)(val1->value / val2->value);  
                //char tmp[10]; $$ = my_itoa(result, tmp);
                pair<string,int> op1, op2;
                op1 = icg_stack.top();
                icg_stack.pop();
                op2 = icg_stack.top();
                icg_stack.pop();
                icg_stack.push({"T", ++t_counter});
                string instruction = "T" + to_string(t_counter) + " = " + print_element(op2) + " / " + print_element(op1);
                gencode(instruction);
                }
                | assignment_options
                ;
binary_exp: binary_exp BIT_AND binary_exp {//type_check($1,$3);
            pair<string,int> op1, op2;
            op1 = icg_stack.top();
            icg_stack.pop();
            op2 = icg_stack.top();
            icg_stack.pop();
            icg_stack.push({"T", ++t_counter});
            string instruction = "T" + to_string(t_counter) + " = " + print_element(op2) + " & " + print_element(op1);
            gencode(instruction);
            }
            | binary_exp BIT_OR binary_exp {//type_check($1,$3);
            pair<string,int> op1, op2;
            op1 = icg_stack.top();
            icg_stack.pop();
            op2 = icg_stack.top();
            icg_stack.pop();
            icg_stack.push({"T", ++t_counter});
            string instruction = "T" + to_string(t_counter) + " = " + print_element(op2) + " | " + print_element(op1);
            gencode(instruction);
            }
            | binary_exp BIT_XOR binary_exp {//type_check($1,$3);
            pair<string,int> op1, op2;
            op1 = icg_stack.top();
            icg_stack.pop();
            op2 = icg_stack.top();
            icg_stack.pop();
            icg_stack.push({"T", ++t_counter});
            string instruction = "T" + to_string(t_counter) + " = " + print_element(op2) + " ^ " + print_element(op1);
            gencode(instruction);
            }
            | binary_exp LSHIFT binary_exp	{//type_check($1,$3);
            pair<string,int> op1, op2;
            op1 = icg_stack.top();
            icg_stack.pop();
            op2 = icg_stack.top();
            icg_stack.pop();
            icg_stack.push({"T", ++t_counter});
            string instruction = "T" + to_string(t_counter) + " = " + print_element(op2) + " << " + print_element(op1);
            gencode(instruction);
            }
            | binary_exp RSHIFT binary_exp {//type_check($1,$3);
            pair<string,int> op1, op2;
            op1 = icg_stack.top();
            icg_stack.pop();
            op2 = icg_stack.top();
            icg_stack.pop();
            icg_stack.push({"T", ++t_counter});
            string instruction = "T" + to_string(t_counter) + " = " + print_element(op2) + " >> " + print_element(op1);
            gencode(instruction);
            }
            | binary_exp MOD binary_exp {//type_check($1,$3);
            pair<string,int> op1, op2;
            op1 = icg_stack.top();
            icg_stack.pop();
            op2 = icg_stack.top();
            icg_stack.pop();
            icg_stack.push({"T", ++t_counter});
            string instruction = "T" + to_string(t_counter) + " = " + print_element(op2) + " % " + print_element(op1);
            gencode(instruction);
            }
            | int_constant {icg_stack.push({$1,-1});}
            | id {icg_stack.push({$1,-1});}
            | float_constant {icg_stack.push({$1,-1});}
            ;
            

inc_dec_exp: INC id  | DEC id | id INC | id DEC;


int_constant: INTEGER_CONSTANT {int val = strtol(yytext,0,10); insert(constant_table,$1, val,INT);$$=$1;}
            | CHARACTER_CONSTANT {int val = $1[1]; insert(constant_table,$1, val,INT);$$=$1;};
                                    


float_constant: FLOATING_CONSTANT   {float val = strtof($1,NULL); insert(constant_table,$1, val,FLOAT);$$=$1;};

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
                insert(SYMBOL_TABLE,$1,INT_MAX,dtype);
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
 }

void type_check(char* lexeme, char* lexeme_prime){
    stEntry* entry = search_recursive(lexeme);
    stEntry* entry_prime = search_recursive(lexeme_prime);
    
    if(!entry){
        entry = search(constant_table,lexeme);
        if(entry==NULL){
            yyerror("Entry not found in constant table");
            exit(1);
        }
    }
    
    if(!entry_prime){
        entry_prime = search(constant_table,lexeme_prime);
        if(entry_prime==NULL){
            return;
           yyerror("Entry not found in constant table");
           exit(1);
        }
    }
    
    if (entry->data_type != entry_prime->data_type){
        yyerror("Type mismatch");
        printf("Mismatch between %d %d. (Refer y.tab.h to know the printed data type variables)\n",entry->data_type,entry_prime->data_type);
        exit(0);
    }
}

string print_element(pair<string, int> p) {
    if(p.second == -1)
        return p.first;
    return (p.first + to_string(p.second)); 

}

string print_label() {
    string label = "L" + to_string(l_counter++) + ":";
    return label;
}

void gencode(string s) {
    std:: string insn; // instruction
    
    insn = to_string(TAC_lineno++) + string(": ") + s;
    ICG.push_back(insn);
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

    printf("Three Address Code:\n");
    for(int i =0; i < ICG.size() ;i++) {
        cout << ICG[i] << endl;
    }
	return 0;
}