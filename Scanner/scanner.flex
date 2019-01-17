/*
 * This file will contain the actual scanner written in fLEX.
 * Team Members: Mahir Jain (16CO123), Suraj Singh (16CO146), Darshan DV(16CO216)
*/
/* Definition section */
%{
    #include<stdio.h>
    #include <stdlib.h>
    #include "tokens.h"
	#include "symbolTable.h"
    #define NRML  "\x1B[0m"
    #define RED  "\x1B[31m"
    #define BLUE   "\x1B[34m"
    int comment_strt =0;

	stEntry** symbol_table;
	stEntry** constant_table;
%}


/* States to simplify readability of the Regular Expressions */
ALPHA [a-zA-Z]
SPACE [ ]
UND [_]
PLUS [+]
NEG [-] 
DOT [.]
DIGIT [0-9]
IDENTIFIER {ALPHA}({ALPHA}|{DIGIT}|{UND})* 
INVALID_IDENTIFIER [`@#]
FUNCTION ({UND}|{ALPHA})({ALPHA}|{DIGIT}|{UND})*{SPACE}*\({SPACE}*\)
STRING \"([^\\\"]|\\.)*\"

%option yylineno

%x comment

/* Rules section */
%%


"/*"                              {comment_strt = yylineno; BEGIN comment;}
<comment>.|[ ]                     ;
<comment>\n                          {yylineno++;}
<comment>"*/"                        { { printf("\n%30s%30s%30s%d%30s%d\n", "MULTI LINE COMMENT", yytext, "Line Number:", yylineno, "Token Number:",MULTI_LINE);}BEGIN INITIAL;}
<comment>"/*"                        {printf("\n%s%30s%30s%30s%d\n", RED,  "Nested comment", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
<comment><<EOF>>                     {printf("\n%s%30s%30s%30s%d\n", RED,  "Unterminated comment", yytext ,"Line Number:", yylineno);printf("%s", NRML); yyterminate();}
 /* Single Line Comment */ 
\/\/(.)*[\n]  {printf("\n%30s%30s%30s%d%30s%d\n", "SINGLE LINE COMMENT", yytext, "Line Number:", yylineno, "Token Number:",SINGLE_LINE);}

[\t\r ]+ { 
  /* ignore whitespace */ }

 /* Include directives */
#include{SPACE}*<{ALPHA}+\.?{ALPHA}+>[^;] { printf("\n%30s%30s%30s%d%30s%d\n", "PREPROCESSING DIRECTIVE", yytext, "Line Number:", yylineno, "Token Number:",INCLUDE);}
#include{SPACE}*\"{ALPHA}+\.?{ALPHA}+\"[^;] { printf("\n%30s%30s%30s%d%30s%d\n", "PREPROCESSING DIRECTIVE", yytext, "Line Number:", yylineno, "Token Number:",INCLUDE);}

 /* Illegal include statements */ 
#include{SPACE}*<{ALPHA}+\.?{ALPHA}+>{SPACE}*[;] { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal preprocessing detective. Ended with semicolon at ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
#include{SPACE}*\"{ALPHA}+\.?{ALPHA}+\"{SPACE}*[;] { printf("\n%s%30s%30s%30s%d\n", RED, "Illegal preprocessing detective. Ended with semicolon at", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
#include[^\n]* { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal preprocessing directive ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
 /* #define statements */
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+({PLUS}|{NEG})?{DIGIT}*{DOT}{DIGIT}+[^;] { printf("\n%30s%30s%30s%d%30s%d\n", "MACRO", yytext, "Line Number:", yylineno, "Token Number:",DEF );}
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+{DIGIT}+[^;]                             { printf("\n%30s%30s%30s%d%30s%d\n", "MACRO", yytext, "Line Number:", yylineno, "Token Number:",DEF );}
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+{ALPHA}({ALPHA}|{UND}|{DIGIT})*[^;]      { printf("\n%30s%30s%30s%d%30s%d\n", "MACRO", yytext, "Line Number:", yylineno, "Token Number:",DEF); }


 /* Illegal #define statements */ 
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+({PLUS}|{NEG})?{DIGIT}*{DOT}{DIGIT}+{SPACE}*[;] { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal macro definition. Ended with semicolon at ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+{DIGIT}+{SPACE}*[;]                             { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal macro definition. Ended with semicolon at ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+{ALPHA}({ALPHA}|{UND}|{DIGIT})*{SPACE}*[;]      { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal macro definition. Ended with semicolon at ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}

 /* Keywords */
"int"                   {printf("\n%s%30s%30s%30s%d%30s%d%s\n",BLUE, "KEYWORD: INTEGER DATA TYPE", yytext, "Line Number:", yylineno, "Token Number:",INT, NRML);}
"short"                 {printf("\n%s%30s%30s%30s%d%30s%d%s\n",BLUE, "KEYWORD: SHORT INT DATATYPE", yytext, "Line Number:", yylineno, "Token Number:",SHORT,NRML );}
"long"                  {printf("\n%s%30s%30s%30s%d%30s%d%s\n",BLUE, "KEYWORD: LONG INT DATATYPE", yytext, "Line Number:", yylineno, "Token Number:", LONG,NRML );}
"long long"             {printf("\n%s%30s%30s%30s%d%30s%d%s\n",BLUE, "KEYWORD: LONG LONG INT DATATYPE", yytext, "Line Number:", yylineno, "Token Number:", LONG_LONG,NRML );}
"signed"                {printf("\n%s%30s%30s%30s%d%30s%d%s\n",BLUE, "KEYWORD: SIGNED INT", yytext, "Line Number:", yylineno, "Token Number:", SIGNED,NRML );}
"unsigned"              {printf("\n%s%30s%30s%30s%d%30s%d%s\n",BLUE, "KEYWORD: UNSIGNED INT", yytext, "Line Number:", yylineno, "Token Number:",UNSIGNED,NRML );}
"char"                  {printf("\n%s%30s%30s%30s%d%30s%d%s\n",BLUE, "KEYWORD: CHAR DATATYPE", yytext, "Line Number:", yylineno, "Token Number:",CHAR,NRML );}
"if"                    {printf("\n%s%30s%30s%30s%d%30s%d%s\n",BLUE, "KEYWORD: IF", yytext, "Line Number:", yylineno, "Token Number:",IF,NRML );}
"else"                  {printf("\n%s%30s%30s%30s%d%30s%d%s\n",BLUE, "KEYWORD: ELSE", yytext, "Line Number:", yylineno, "Token Number:",ELSE,NRML );}
"while"                 {printf("\n%s%30s%30s%30s%d%30s%d%s\n",BLUE, "KEYWORD: WHILE", yytext, "Line Number:", yylineno, "Token Number:",WHILE,NRML );}
"continue"              {printf("\n%s%30s%30s%30s%d%30s%d%s\n",BLUE, "KEYWORD: CONTINUE", yytext, "Line Number:", yylineno, "Token Number:",CONTINUE,NRML );}
"break"                 {printf("\n%s%30s%30s%30s%d%30s%d%s\n",BLUE, "KEYWORD: BREAK", yytext, "Line Number:", yylineno, "Token Number:",BREAK,NRML );}
"return"                {printf("\n%s%30s%30s%30s%d%30s%d%s\n",BLUE, "KEYWORD: RETURN", yytext, "Line Number:", yylineno, "Token Number:",RETURN,NRML );}

  /* Strings */
\"([^\\\"]|\\.)* {printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal String", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
\"([^\\\"]|\\.)*\" {printf("\n%30s%30s%30s%d%30s%d\n", "STRING CONSTANT", yytext, "Line Number:", yylineno, "Token Number:",STRING_CONSTANT );}

 /* Character Constant */
 \'([^\\\"]|\\.)\' {printf("\n%30s%30s%30s%d%30s%d\n", "CHARACTER CONSTANT", yytext, "Line Number:", yylineno, "Token Number:",CHARACTER_CONSTANT );}
 \''             {printf("\n%s%30s%30s%30s%d\n", RED,  "Empty character constant", yytext ,"Line Number:", yylineno);printf("%s", NRML);}

  /* Rules for numeric constants needs to be before identifiers otherwise giving error */
0([x|X])({DIGIT}|[a-fA-F])+    {printf("\n%30s%30s%30s%d%30s%d\n", "HEXADECIMAL INTEGER", yytext, "Line Number:", yylineno, "Token Number:",HEXADECIMAL_CONSTANT );insert(constant_table,yytext,HEXADECIMAL_CONSTANT);}
0([x|X])({DIGIT}|[a-zA-Z])+    {printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal Hexadecimal Constant", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
0([0-7])+    {printf("\n%30s%30s%30s%d%30s%d\n", "OCTAL INTEGER", yytext, "Line Number:", yylineno, "Token Number:",OCTAL_CONSTANT );insert(constant_table,yytext,OCTAL_CONSTANT);}
0([0-9])+   { printf("\n%s%30s%30s%30s%d\n", RED,  "  Illegal octal constant", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
{PLUS}?{DIGIT}*{DOT}{DIGIT}+ {printf("\n%30s%30s%30s%d%30s%d\n", "POSITIVE FRACTION", yytext, "Line Number:", yylineno, "Token Number:",FLOATING_CONSTANT  );insert(constant_table,yytext,FLOATING_CONSTANT);}
{NEG}{DIGIT}*{DOT}{DIGIT}+   {printf("\n%30s%30s%30s%d%30s%d\n", "NEGATIVE FRACTION", yytext, "Line Number:", yylineno, "Token Number:",FLOATING_CONSTANT );insert(constant_table,yytext,FLOATING_CONSTANT);}

 /* Invalid mantissa exponent forms */
({PLUS}?|{NEG}){DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}* {printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal Floating Constant ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}* {printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal Floating Constant ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}

 /* Valid Mantissa Exponent forms */ 
({PLUS}?|{NEG}){DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}+ {printf("\n%30s%30s%30s%d%30s%d\n", "FLOATING CONSTANT", yytext, "Line Number:", yylineno, "Token Number:",FLOATING_CONSTANT );printf("%s", NRML);insert(constant_table,yytext,FLOATING_CONSTANT);}
({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}+ {printf("\n%30s%30s%30s%d%30s%d\n", "FLOATING CONSTANT", yytext, "Line Number:", yylineno, "Token Number:",FLOATING_CONSTANT );printf("%s", NRML);insert(constant_table,yytext,FLOATING_CONSTANT);}




{PLUS}?{DIGIT}+              {printf("\n%30s%30s%30s%d%30s%d\n", "POSITIVE INTEGER", yytext, "Line Number:", yylineno, "Token Number:",INTEGER_CONSTANT );insert(constant_table,yytext,INTEGER_CONSTANT);}
{NEG}{DIGIT}+                {printf("\n%30s%30s%30s%d%30s%d\n", "NEGATIVE INTEGER", yytext, "Line Number:", yylineno, "Token Number:",INTEGER_CONSTANT );insert(constant_table,yytext,INTEGER_CONSTANT);}

({ALPHA}|{DIGIT}|{UND})*{INVALID_IDENTIFIER}+({ALPHA}|{DIGIT}|{UND})* { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal identifier ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
{UND}{IDENTIFIER} { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal identifier ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
{IDENTIFIER}                 {printf("\n%30s%30s%30s%d%30s%d\n", "IDENTIFIER", yytext, "Line Number:", yylineno, "Token Number:",IDENTIFIER );insert(symbol_table,yytext,IDENTIFIER);}

{DIGIT}+({ALPHA}|{UND})+   { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal identifier ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}



 /* Shorthand assignment operators */
"+="                {printf("\n%30s%30s%30s%d%30s%d\n", "PLUS EQUAL TO", yytext, "Line Number:", yylineno, "Token Number:",PLUSEQ );}  
"-="                {printf("\n%30s%30s%30s%d%30s%d\n", "MINUS EQUAL TO", yytext, "Line Number:", yylineno, "Token Number:",MINUSEQ );}  
"*="                {printf("\n%30s%30s%30s%d%30s%d\n", "MUL EQUAL TO", yytext, "Line Number:", yylineno, "Token Number:",MULEQ );}  
"/="                {printf("\n%30s%30s%30s%d%30s%d\n", "DIV EQUAL TO", yytext, "Line Number:", yylineno, "Token Number:",DIVEQ );}  
"%="                {printf("\n%30s%30s%30s%d%30s%d\n", "MOD EQUAL TO", yytext, "Line Number:", yylineno, "Token Number:",MODEQ);}  


 /* Logical Operators */

"&&"                {printf("\n%30s%30s%30s%d%30s%d\n", "LOGICAL AND", yytext, "Line Number:", yylineno, "Token Number:",AND );}
"||"				{printf("\n%30s%30s%30s%d%30s%d\n", "LOGICAL OR", yytext, "Line Number:", yylineno, "Token Number:",OR );}
"!"                 {printf("\n%30s%30s%30s%d%30s%d\n", "LOGICAL NOT", yytext, "Line Number:", yylineno, "Token Number:",NOT );}

 /* Bitwise Operators */

">>"                    {printf("\n%30s%30s%30s%d%30s%d\n", "RIGHT SHIFT", yytext, "Line Number:", yylineno, "Token Number:",RSHIFT );}
"<<"                    {printf("\n%30s%30s%30s%d%30s%d\n", "LEFT SHIFT", yytext, "Line Number:", yylineno, "Token Number:",LSHIFT );}
"^"                    {printf("\n%30s%30s%30s%d%30s%d\n", "BITWISE XOR", yytext, "Line Number:", yylineno, "Token Number:",BIT_XOR );}
"&"                    {printf("\n%30s%30s%30s%d%30s%d\n", "BITWISE AND", yytext, "Line Number:", yylineno, "Token Number:",BIT_AND );}
"|"                    {printf("\n%30s%30s%30s%d%30s%d\n", "BITWISE OR", yytext, "Line Number:", yylineno, "Token Number:",BIT_OR );}
"~"                    {printf("\n%30s%30s%30s%d%30s%d\n", "BITWISE NOT", yytext, "Line Number:", yylineno, "Token Number:",BIT_NOT );}

 /* Relational operators */
"="                     {printf("\n%30s%30s%30s%d%30s%d\n", "EQUALTO", yytext, "Line Number:", yylineno, "Token Number:",EQ );}  
"!="                    {printf("\n%30s%30s%30s%d%30s%d\n", "UNEQUAL", yytext, "Line Number:", yylineno, "Token Number:",NEQ );}  
">"                     {printf("\n%30s%30s%30s%d%30s%d\n", "GREATER THAN", yytext, "Line Number:", yylineno, "Token Number:",GT );}  
"<"                     {printf("\n%30s%30s%30s%d%30s%d\n", "LESS THAN", yytext, "Line Number:", yylineno, "Token Number:",LT );}  
">="                    {printf("\n%30s%30s%30s%d%30s%d\n", "GREATER THAN EQUAL TO", yytext, "Line Number:", yylineno, "Token Number:",GE );}  
"<="                    {printf("\n%30s%30s%30s%d%30s%d\n", "LESSER THAN EQUAL TO", yytext, "Line Number:", yylineno, "Token Number:",LE );}  
"=="                    {printf("\n%30s%30s%30s%d%30s%d\n", "EQUAL TO EQUAL TO", yytext, "Line Number:", yylineno, "Token Number:",EQEQ );}  

 /* Arithmetic Operators */
"++"                    {printf("\n%30s%30s%30s%d%30s%d\n", "INCREMENT", yytext, "Line Number:", yylineno, "Token Number:",INC );}  
"--"                    {printf("\n%30s%30s%30s%d%30s%d\n", "DECREMENT", yytext, "Line Number:", yylineno, "Token Number:",DEC );}  
"+"                     {printf("\n%30s%30s%30s%d%30s%d\n", "PLUS", yytext, "Line Number:", yylineno, "Token Number:",PLUS );}  
"-"                     {printf("\n%30s%30s%30s%d%30s%d\n", "MINUS", yytext, "Line Number:", yylineno, "Token Number:",MINUS );}  
"*"                     {printf("\n%30s%30s%30s%d%30s%d\n", "MULTIPLICATION", yytext, "Line Number:", yylineno, "Token Number:",MUL );}  
"/"                     {printf("\n%30s%30s%30s%d%30s%d\n", "FORWARD SLASH or DIVISION", yytext, "Line Number:", yylineno, "Token Number:",DIV );}  
"%"                     {printf("\n%30s%30s%30s%d%30s%d\n", "MODULUS", yytext, "Line Number:", yylineno, "Token Number:",MODULO);}  


 /* Punctuators */
","                 {printf("\n%30s%30s%30s%d%30s%d\n", "COMMA", yytext, "Line Number:", yylineno, "Token Number:",COMMA );}   
";"                 {printf("\n%30s%30s%30s%d%30s%d\n", "SEMICOLON", yytext, "Line Number:", yylineno, "Token Number:",SEMICOLON );} 
"("                 {printf("\n%30s%30s%30s%d%30s%d\n", "OPEN PARANTHESIS", yytext, "Line Number:", yylineno, "Token Number:",OPEN_PARANTHESIS );} 
")"                 {printf("\n%30s%30s%30s%d%30s%d\n", "CLOSE PARANTHESIS", yytext, "Line Number:", yylineno, "Token Number:",CLOSE_PARANTHESIS );} 
"{"                 {printf("\n%30s%30s%30s%d%30s%d\n", "OPEN_BRACE", yytext, "Line Number:", yylineno, "Token Number:",OPEN_BRACE );} 
"}"                 {printf("\n%30s%30s%30s%d%30s%d\n", "CLOSE_BRACE", yytext, "Line Number:", yylineno, "Token Number:",CLOSE_BRACE);} 
"["                 {printf("\n%30s%30s%30s%d%30s%d\n", "OPEN_SQR_BKT", yytext, "Line Number:", yylineno, "Token Number:",OPEN_SQR_BKT );} 
"]"                 {printf("\n%30s%30s%30s%d%30s%d\n", "CLOSE_SQR_BKT", yytext, "Line Number:", yylineno, "Token Number:",CLOSE_SQR_BKT );} 


. {printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal Character ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
\n {}
%%

int yywrap(){
	return 1;
}

int main(){
	symbol_table = new_table();
	constant_table = new_table();
	yylex();
	printf("\n\nDisplaying Symbol Table\n");
	display(symbol_table);
	printf("\n\nDisplaying Constant Table\n");
	display(constant_table);
	return 0;
}

