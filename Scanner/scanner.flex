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
FUNCTION ({UND} | {ALPHA})*({ALPHA} | {UND} | {DIGIT})*{SPACE}*"()"

%%

\/\/(.)*[\n]                {line_no++;}



#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+({PLUS}|{NEG})?{DIGIT}*{DOT}{DIGIT}+ { printf("\n%30s%30s%30s%d%30s%d\n", "MACRO", yytext, "Line Number:", yylineno, "Token Number:",DEF );}
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+{DIGIT}+                             { printf("\n%30s%30s%30s%d%30s%d\n", "MACRO", yytext, "Line Number:", yylineno, "Token Number:",DEF );}
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+{ALPHA}({ALPHA}|{UND}|{DIGIT})*      { printf("\n%30s%30s%30s%d%30s%d\n", "MACRO", yytext, "Line Number:", yylineno, "Token Number:",DEF); }

"int"                   {printf("\n%s: %d %d\n", yytext, yylineno, INT);}
"short"                 {printf("\n%s: %d\n", yytext, SHORT);}
"long"                  {printf("\n%s: %d\n", yytext, LONG);}
"long long"             {printf("\n%s: %d\n", yytext, LONG_LONG);}
"signed"                {printf("\n%s: %d\n", yytext, SIGNED);}
"unsigned"              {printf("\n%s: %d\n", yytext, UNSIGNED);}
"char"                  {printf("\n%s: %d\n", yytext, CHAR);}
"if"                    {printf("\n%s: %d\n", yytext, IF);}
"else"                  {printf("\n%s: %d\n", yytext, ELSE);}
"while"                 {printf("\n%s: %d\n", yytext, WHILE);}
"continue"              {printf("\n%s: %d\n", yytext, CONTINUE);}
"break"                 {printf("\n%s: %d\n", yytext, BREAK);}
"return"                {printf("\n%s: %d\n", yytext, RETURN);}

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







