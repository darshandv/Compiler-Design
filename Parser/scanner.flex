/*
 * This file will contain the actual scanner written in fLEX.
*/
/* Definition section */
%{
    #include<stdio.h>
    #include <stdlib.h>
	#include "y.tab.h"
    #define NRML  "\x1B[0m"
    #define RED  "\x1B[31m"
    #define BLUE   "\x1B[34m"
    int comment_strt =0;
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
INVALID_IDENTIFIER [~`@#]
FUNCTION ({UND}|{ALPHA})({ALPHA}|{DIGIT}|{UND})*{SPACE}*\({SPACE}*\)
STRING \"([^\\\"]|\\.)*\"

%option yylineno

%x comment

/* Rules section */
%%


"/*"                              {comment_strt = yylineno; BEGIN comment;}
<comment>.|[ ]                      ;
<comment>\n                          {yylineno++;}
<comment>"*/"                        {BEGIN INITIAL;}
<comment>"/*"                        {}
<comment><<EOF>>                     {yyterminate();}
 /* Single Line Comment */ 
\/\/(.)*[\n]  {return SINGLE_LINE;}

[\t\r ]+ { 
  /* ignore whitespace */ }

 /* Include directives */
#include{SPACE}*<{ALPHA}+\.?{ALPHA}+>[^;] {return INCLUDE;}
#include{SPACE}*\"{ALPHA}+\.?{ALPHA}+\"[^;] { return INCLUDE;}

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
"int"                   {yylval.op_val=new std:string(yytext);return INT;}
"short"                 {yylval.op_val=new std:string(yytext);return SHORT;}
"long"                  {yylval.op_val=new std:string(yytext);return LONG;}
"long long"             {yylval.op_val=new std:string(yytext);return LONG_LONG;}
"signed"                {yylval.op_val=new std:string(yytext);return SIGNED;}
"unsigned"              {yylval.op_val=new std:string(yytext);return UNSIGNED;}
"char"                  {yylval.op_val=new std:string(yytext);return CHAR;}
"if"                    {yylval.op_val=new std:string(yytext);return IF;}
"else"                  {yylval.op_val=new std:string(yytext);return ELSE;}
"while"                 {yylval.op_val=new std:string(yytext);return WHILE;}
"continue"              {yylval.op_val=new std:string(yytext);return CONTINUE;}
"break"                 {yylval.op_val=new std:string(yytext);return BREAK;}
"return"                {yylval.op_val=new std:string(yytext);reutn RETURN;}

  /* Strings */
\"([^\\\"]|\\.)* {printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal String", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
\"([^\\\"]|\\.)*\" {yylval.op_val=new std:string(yytext);return STRING_CONSTANT;}

  /* Rules for numeric constants needs to be before identifiers otherwise giving error */
0([x|X])({DIGIT}|[a-fA-F])+    {yylval.val=strtol(yytext,0,16);return HEXADECIMAL_CONSTANT ;insert(constant_table,yytext,HEXADECIMAL_CONSTANT);}
0([x|X])({DIGIT}|[a-zA-Z])+    {printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal Hexadecimal Constant", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
0([0-7])+    {insert(constant_table,yytext,OCTAL_CONSTANT); yylval.value = strtol(yytext, 0, 8); return OCTAL_CONSTANT}
0([0-9])+   { printf("\n%s%30s%30s%30s%d\n", RED,  "  Illegal octal constant", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
{PLUS}?{DIGIT}*{DOT}{DIGIT}+ {insert(constant_table,yytext,FLOATING_CONSTANT);yylval.fraction = strtof(yytext, NULL); return FLOATING_CONSTANT}
{NEG}{DIGIT}*{DOT}{DIGIT}+   {insert(constant_table,yytext,FLOATING_CONSTANT);yylval.fraction = strtof(yytext, NULL); return FLOATING_CONSTANT}

 /* Invalid mantissa exponent forms */
({PLUS}?|{NEG}){DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}* {printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal Floating Constant ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}* {printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal Floating Constant ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}

 /* Valid Mantissa Exponent forms */ 
({PLUS}?|{NEG}){DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}+ {yylval.entry = insert(constant_table,yytext,FLOATING_CONSTANT); yytext.fraction = strtof(yytext, NULL); return FLOATING_CONSTANT ;}
({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}+ {insert(constant_table,yytext,FLOATING_CONSTANT); yytext.fraction = strtof(yytext, NULL); return FLOATING_CONSTANT ;}




{PLUS}?{DIGIT}+              {insert(constant_table,yytext,INTEGER_CONSTANT); yylval.val = strtol(yytext, 0, 10); return INTEGER_CONSTANT;}
{NEG}{DIGIT}+                {insert(constant_table,yytext,INTEGER_CONSTANT); yylval.val = strtol(yytext, 0, 10); return INTEGER_CONSTANT;}

({ALPHA}|{DIGIT}|{UND})*{INVALID_IDENTIFIER}+({ALPHA}|{DIGIT}|{UND})* { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal identifier ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
{IDENTIFIER}                 {insert(symbol_table,yytext,IDENTIFIER);yylval.op_val=std::new string(yytext);return IDENTIFIER;}

{DIGIT}+({ALPHA}|{UND})+   { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal identifier ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}



 /* Shorthand assignment operators */
"+="                {yylval.op_val=new std:string(yytext);return PLUSEQ ;}  
"-="                {yylval.op_val=new std:string(yytext);return MINUSEQ ;}  
"*="                {yylval.op_val=new std:string(yytext);return MULEQ ;}  
"/="                {yylval.op_val=new std:string(yytext);return DIVEQ ;}  
"%="                {yylval.op_val=new std:string(yytext);return MODEQ;}  

 /* Relational operators */
"="                     {yylval.op_val=new std:string(yytext); return EQ;}  
"!="                    {yylval.op_val=new std:string(yytext); return NEQ;}  
">"                     {yylval.op_val=new std:string(yytext); return GT;}  
"<"                     {yylval.op_val=new std:string(yytext); return LT;}  
">="                    {yylval.op_val=new std:string(yytext); return GE; }
"<="                    {yylval.op_val=new std:string(yytext); return LE;}  
"=="                    {yylval.op_val=new std:string(yytext); return EQEQ;}  

 /* Arithmetic Operators */
"++"                    {yylval.op_val=new std:string(yytext); return INC ;}  
"--"                    {yylval.op_val=new std:string(yytext); return DEC ;}  
"+"                     {yylval.op_val=new std:string(yytext); return PLUS;}  
"-"                     {yylval.op_val=new std:string(yytext); return MINUS;}  
"*"                     {yylval.op_val=new std:string(yytext); return MUL;}  
"/"                     {yylval.op_val=new std:string(yytext); return DIV;}  
"%"                     {yylval.op_val=new std:string(yytext); return MODULO;}  


 /* Punctuators */
","                 {yylval.op_val=new std:string(yytext); return COMMA;}   
";"                 {yylval.op_val=new std:string(yytext); return SEMICOLON;} 
"("                 {yylval.op_val=new std:string(yytext); return OPEN_PARENTHESIS;} 
")"                 {yylval.op_val=new std:string(yytext); return CLOSE_PARENTHESIS );} 
"{"                 {yylval.op_val=new std:string(yytext); return OPEN_BRACE ;} 
"}"                 {yylval.op_val=new std:string(yytext); return CLOSE_BRACE;} 
"["                 {yylval.op_val=new std:string(yytext); return OPEN_SQR_BKT ;} 
"]"                 {yylval.op_val=new std:string(yytext); return CLOSE_SQR_BKT ;} 


. {printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal Character ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
\n {}
%%

int yywrap(){
	return 1;
}

// int main(){
// 	symbol_table = new_table();
// 	constant_table = new_table();
// 	yylex();
// 	printf("\n\nDisplaying Symbol Table\n");
// 	display(symbol_table);
// 	printf("\n\nDisplaying Constant Table\n");
// 	display(constant_table);
// 	return 0;
// }