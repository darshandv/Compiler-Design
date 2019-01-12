/*
 * This file will contain the actual scanner written in fLEX.
*/
%{
    #include<stdio.h>
    #include <stdlib.h>
    #include "tokens.h"
    int line_no =0;
%}

ALPHA [a-zA-Z]
SPACE [ ]
UND [_]
PLUS [+]
NEG [-] 
DOT [.]
DIGIT [0-9]
IDENTIFIER {ALPHA}({ALPHA}|{DIGIT}|{UND})* 
FUNCTION ({UND}|{ALPHA})({ALPHA}|{DIGIT}|{UND})*{SPACE}*\({SPACE}*\)

%%

\/\/(.)*[\n]                {line_no++;}

#include{SPACE}*<{ALPHA}+\.h>[^;] { printf("\n%30s%30s%30s%d%30s%d\n", "PREPROCESSING DIRECTIVE", yytext, "Line Number:", yylineno, "Token Number:",PREPROCES);}
#include{SPACE}*\"{ALPHA}+\"[^;] { printf("\n%30s%30s%30s%d%30s%d\n", "PREPROCESSING DIRECTIVE", yytext, "Line Number:", yylineno, "Token Number:",PREPROCES);}

#include{SPACE}*<{ALPHA}+\.h> { printf("\n%30s%30s%d\n", "Illegal preprocessing detective. Ended with semicolon at ", "Line Number:", yylineno);}
#include{SPACE}*\"{ALPHA}+\" { printf("\n%30s%30s%d\n", "Illegal preprocessing detective. Ended with semicolon at", "Line Number:", yylineno);}


#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+({PLUS}|{NEG})?{DIGIT}*{DOT}{DIGIT}+ { printf("\n%30s%30s%30s%d%30s%d\n", "MACRO", yytext, "Line Number:", yylineno, "Token Number:",DEF );}
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+{DIGIT}+                             { printf("\n%30s%30s%30s%d%30s%d\n", "MACRO", yytext, "Line Number:", yylineno, "Token Number:",DEF );}
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+{ALPHA}({ALPHA}|{UND}|{DIGIT})*      { printf("\n%30s%30s%30s%d%30s%d\n", "MACRO", yytext, "Line Number:", yylineno, "Token Number:",DEF); }

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

{FUNCTION}                   {printf("\n%30s%30s%30s%d%30s%d\n", "FUNCTION", yytext, "Line Number:", yylineno, "Token Number:",FUNC );}
{IDENTIFIER}                 {printf("\n%30s%30s%30s%d%30s%d\n", "IDENTIFIER", yytext, "Line Number:", yylineno, "Token Number:",IDENTIFIER );}
{PLUS}?{DIGIT}*{DOT}{DIGIT}+ {printf("\n%30s%30s%30s%d%30s%d\n", "POSITIVE FRACTION", yytext, "Line Number:", yylineno, "Token Number:",CONST  );}
{NEG}{DIGIT}*{DOT}{DIGIT}+   {printf("\n%30s%30s%30s%d%30s%d\n", "NEGATIVE FRACTION", yytext, "Line Number:", yylineno, "Token Number:",CONST );} 


"="                     {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno, EQ  );}
"!="                    {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno, NEQ );}
">"                     {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno,  GT);}
"<"                     {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno,  LT);}
">="                    {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno, GE);}
"<="                    {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno, LE);}
"=="                    {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno, EQEQ);}

"++"                    {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno, INC);}
"--"                    {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno, DEC);}
"+"                     {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno, PLUS);}
"-"                     {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno, MINUS);}
"*"                     {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno, MUL);}
"/"                     {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno, DIV);}
"%"                     {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno, MODULO);}

"+="                {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno, PLUSEQ);}
"-="                {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno, MINUSEQ);}
"*="                {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno, MULEQ);}
"/="                {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno, DIVEQ);}
"%="                {printf("\n%s: Line Number: %d Token ID: %d\n", yytext, yylineno, MODEQ);}







