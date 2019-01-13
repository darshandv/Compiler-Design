/*
 * This file will contain the actual scanner written in fLEX.
*/
/* Definition section */
%{
    #include<stdio.h>
    #include <stdlib.h>
    #include "tokens.h"
    #define NRML  "\x1B[0m"
    #define RED  "\x1B[31m"
    #define BLUE   "\x1B[34m"
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
FUNCTION ({UND}|{ALPHA})({ALPHA}|{DIGIT}|{UND})*{SPACE}*\({SPACE}*\)


/* Rules section */
%%

 /* Single Line Comment */ 
\/\/(.)*[\n]  {printf("\n%30s%30s%30s%d%30s%d\n", "SINGLE LINE COMMENT", yytext, "Line Number:", yylineno, "Token Number:",SINGLE_LINE);yylineno++;}


#include{SPACE}*<{ALPHA}+\.h>[^;] { printf("\n%30s%30s%30s%d%30s%d\n", "PREPROCESSING DIRECTIVE", yytext, "Line Number:", yylineno, "Token Number:",INCLUDE);}
#include{SPACE}*\"{ALPHA}+\"[^;] { printf("\n%30s%30s%30s%d%30s%d\n", "PREPROCESSING DIRECTIVE", yytext, "Line Number:", yylineno, "Token Number:",INCLUDE);}

#include{SPACE}*<{ALPHA}+\.h>{SPACE}*[;] { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal preprocessing detective. Ended with semicolon at ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
#include{SPACE}*\"{ALPHA}+\"{SPACE}*[;] { printf("\n%s%30s%30s%30s%d\n", RED, "Illegal preprocessing detective. Ended with semicolon at", yytext ,"Line Number:", yylineno);printf("%s", NRML);}


#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+({PLUS}|{NEG})?{DIGIT}*{DOT}{DIGIT}+[^;] { printf("\n%30s%30s%30s%d%30s%d\n", "MACRO", yytext, "Line Number:", yylineno, "Token Number:",DEF );}
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+{DIGIT}+[^;]                             { printf("\n%30s%30s%30s%d%30s%d\n", "MACRO", yytext, "Line Number:", yylineno, "Token Number:",DEF );}
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+{ALPHA}({ALPHA}|{UND}|{DIGIT})*[^;]      { printf("\n%30s%30s%30s%d%30s%d\n", "MACRO", yytext, "Line Number:", yylineno, "Token Number:",DEF); }

#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+({PLUS}|{NEG})?{DIGIT}*{DOT}{DIGIT}+{SPACE}*[;] { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal macro definition. Ended with semicolon at ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+{DIGIT}+{SPACE}*[;]                             { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal macro definition. Ended with semicolon at ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+{ALPHA}({ALPHA}|{UND}|{DIGIT})*{SPACE}*[;]      { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal macro definition. Ended with semicolon at ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}


"int"                   {printf("\n%30s%30s%30s%d%30s%d\n", "INTEGER", yytext, "Line Number:", yylineno, "Token Number:",INT);}
"short"                 {printf("\n%30s%30s%30s%d%30s%d\n", "SHORT INT", yytext, "Line Number:", yylineno, "Token Number:",SHORT );}
"long"                  {printf("\n%30s%30s%30s%d%30s%d\n", "LONG INT", yytext, "Line Number:", yylineno, "Token Number:", LONG );}
"long long"             {printf("\n%30s%30s%30s%d%30s%d\n", "LONG LONG INT", yytext, "Line Number:", yylineno, "Token Number:", LONG_LONG );}
"signed"                {printf("\n%30s%30s%30s%d%30s%d\n", "SIGNED INT", yytext, "Line Number:", yylineno, "Token Number:", SIGNED );}
"unsigned"              {printf("\n%30s%30s%30s%d%30s%d\n", "UNSIGNED INT", yytext, "Line Number:", yylineno, "Token Number:",UNSIGNED );}
"char"                  {printf("\n%30s%30s%30s%d%30s%d\n", "CHAR", yytext, "Line Number:", yylineno, "Token Number:",CHAR );}
"if"                    {printf("\n%30s%30s%30s%d%30s%d\n", "IF", yytext, "Line Number:", yylineno, "Token Number:",IF );}
"else"                  {printf("\n%30s%30s%30s%d%30s%d\n", "ELSE", yytext, "Line Number:", yylineno, "Token Number:",ELSE );}
"while"                 {printf("\n%30s%30s%30s%d%30s%d\n", "WHILE", yytext, "Line Number:", yylineno, "Token Number:",WHILE );}
"continue"              {printf("\n%30s%30s%30s%d%30s%d\n", "CONTINUE", yytext, "Line Number:", yylineno, "Token Number:",CONTINUE );}
"break"                 {printf("\n%30s%30s%30s%d%30s%d\n", "BREAK", yytext, "Line Number:", yylineno, "Token Number:",BREAK );}
"return"                {printf("\n%30s%30s%30s%d%30s%d\n", "RETURN", yytext, "Line Number:", yylineno, "Token Number:",RETURN );}

  /* Rules for numeric constants needs to be before identifiers otherwise giving error */
0([x|X])({DIGIT}|[a-fA-F])+    {printf("\n%30s%30s%30s%d%30s%d\n", "HEXADECIMAL INTEGER", yytext, "Line Number:", yylineno, "Token Number:",HEXADECIMAL_CONSTANT );}
{PLUS}?{DIGIT}*{DOT}{DIGIT}+ {printf("\n%30s%30s%30s%d%30s%d\n", "POSITIVE FRACTION", yytext, "Line Number:", yylineno, "Token Number:",FLOATING_CONSTANT  );}
{NEG}{DIGIT}*{DOT}{DIGIT}+   {printf("\n%30s%30s%30s%d%30s%d\n", "NEGATIVE FRACTION", yytext, "Line Number:", yylineno, "Token Number:",FLOATING_CONSTANT );}

 /* Invalid mantissa exponent forms */
({PLUS}?|{NEG}){DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}* {printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal Floating Constant ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}* {printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal Floating Constant ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}

 /* Valid Mantissa Exponent forms */ 
({PLUS}?|{NEG}){DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}+ {printf("\n%30s%30s%30s%d%30s%d\n", "FLOATING CONSTANT", yytext, "Line Number:", yylineno, "Token Number:",FLOATING_CONSTANT );printf("%s", NRML);}
({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}+ {printf("\n%30s%30s%30s%d%30s%d\n", "FLOATING CONSTANT", yytext, "Line Number:", yylineno, "Token Number:",FLOATING_CONSTANT );printf("%s", NRML);}




{PLUS}?{DIGIT}+              {printf("\n%30s%30s%30s%d%30s%d\n", "POSITIVE INTEGER", yytext, "Line Number:", yylineno, "Token Number:",INTEGER_CONSTANT );}
{NEG}{DIGIT}+                {printf("\n%30s%30s%30s%d%30s%d\n", "NEGATIVE INTEGER", yytext, "Line Number:", yylineno, "Token Number:",INTEGER_CONSTANT );}


{FUNCTION}                   {printf("\n%30s%30s%30s%d%30s%d\n", "FUNCTION", yytext, "Line Number:", yylineno, "Token Number:",FUNC );}
{IDENTIFIER}                 {printf("\n%30s%30s%30s%d%30s%d\n", "IDENTIFIER", yytext, "Line Number:", yylineno, "Token Number:",IDENTIFIER );}
{DIGIT}+({ALPHA}|{UND})+   { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal identifier ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}




"+="                {printf("\n%30s%30s%30s%d%30s%d\n", "PLUS EQUAL TO", yytext, "Line Number:", yylineno, "Token Number:",PLUSEQ );}  
"-="                {printf("\n%30s%30s%30s%d%30s%d\n", "MINUS EQUAL TO", yytext, "Line Number:", yylineno, "Token Number:",MINUSEQ );}  
"*="                {printf("\n%30s%30s%30s%d%30s%d\n", "MUL EQUAL TO", yytext, "Line Number:", yylineno, "Token Number:",MULEQ );}  
"/="                {printf("\n%30s%30s%30s%d%30s%d\n", "DIV EQUAL TO", yytext, "Line Number:", yylineno, "Token Number:",DIVEQ );}  
"%="                {printf("\n%30s%30s%30s%d%30s%d\n", "MOD EQUAL TO", yytext, "Line Number:", yylineno, "Token Number:",MODEQ);}  


"="                     {printf("\n%30s%30s%30s%d%30s%d\n", "EQUALTO", yytext, "Line Number:", yylineno, "Token Number:",EQ );}  
"!="                    {printf("\n%30s%30s%30s%d%30s%d\n", "UNEQUAL", yytext, "Line Number:", yylineno, "Token Number:",NEQ );}  
">"                     {printf("\n%30s%30s%30s%d%30s%d\n", "GREATER THAN", yytext, "Line Number:", yylineno, "Token Number:",GT );}  
"<"                     {printf("\n%30s%30s%30s%d%30s%d\n", "LESS THAN", yytext, "Line Number:", yylineno, "Token Number:",LT );}  
">="                    {printf("\n%30s%30s%30s%d%30s%d\n", "GREATER THAN EQUAL TO", yytext, "Line Number:", yylineno, "Token Number:",GE );}  
"<="                    {printf("\n%30s%30s%30s%d%30s%d\n", "LESSER THAN EQUAL TO", yytext, "Line Number:", yylineno, "Token Number:",LE );}  
"=="                    {printf("\n%30s%30s%30s%d%30s%d\n", "EQUAL TO EQUAL TO", yytext, "Line Number:", yylineno, "Token Number:",EQEQ );}  

"++"                    {printf("\n%30s%30s%30s%d%30s%d\n", "INCREMENT", yytext, "Line Number:", yylineno, "Token Number:",INC );}  
"--"                    {printf("\n%30s%30s%30s%d%30s%d\n", "DECREMENT", yytext, "Line Number:", yylineno, "Token Number:",DEC );}  
"+"                     {printf("\n%30s%30s%30s%d%30s%d\n", "PLUS", yytext, "Line Number:", yylineno, "Token Number:",PLUS );}  
"-"                     {printf("\n%30s%30s%30s%d%30s%d\n", "MINUS", yytext, "Line Number:", yylineno, "Token Number:",MINUS );}  
"*"                     {printf("\n%30s%30s%30s%d%30s%d\n", "MULTIPLICATION", yytext, "Line Number:", yylineno, "Token Number:",MUL );}  
"/"                     {printf("\n%30s%30s%30s%d%30s%d\n", "FORWARD SLASH or DIVISION", yytext, "Line Number:", yylineno, "Token Number:",DIV );}  
"%"                     {printf("\n%30s%30s%30s%d%30s%d\n", "MODULUS", yytext, "Line Number:", yylineno, "Token Number:",MODULO);}  



","                 {printf("\n%30s%30s%30s%d%30s%d\n", "COMMA", yytext, "Line Number:", yylineno, "Token Number:",COMMA );}   
";"                 {printf("\n%30s%30s%30s%d%30s%d\n", "SEMICOLON", yytext, "Line Number:", yylineno, "Token Number:",SEMICOLON );} 

"("                 {printf("\n%30s%30s%30s%d%30s%d\n", "OPEN PARANTHESIS", yytext, "Line Number:", yylineno, "Token Number:",OPEN_PARANTHESIS );} 
")"                 {printf("\n%30s%30s%30s%d%30s%d\n", "CLOSE PARANTHESIS", yytext, "Line Number:", yylineno, "Token Number:",CLOSE_PARANTHESIS );} 
"{"                 {printf("\n%30s%30s%30s%d%30s%d\n", "OPEN_BRACE", yytext, "Line Number:", yylineno, "Token Number:",OPEN_BRACE );} 
"}"                 {printf("\n%30s%30s%30s%d%30s%d\n", "CLOSE_BRACE", yytext, "Line Number:", yylineno, "Token Number:",CLOSE_BRACE);} 
"["                 {printf("\n%30s%30s%30s%d%30s%d\n", "OPEN_SQR_BKT", yytext, "Line Number:", yylineno, "Token Number:",OPEN_SQR_BKT );} 
"]"                 {printf("\n%30s%30s%30s%d%30s%d\n", "CLOSE_SQR_BKT", yytext, "Line Number:", yylineno, "Token Number:",CLOSE_SQR_BKT );} 






