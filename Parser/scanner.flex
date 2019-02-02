/*
 * This file will contain the actual scanner written in fLEX.
*/
/* Definition section */
%{
    #define LEXER_FILE
    #define NRML  "\x1B[0m"
    #define RED  "\x1B[31m"
    #define BLUE   "\x1B[34m"
    #include <stdlib.h>
    #include <string.h>
    #include <ctype.h>
    //#include "symbolTable.h"
    #include "share_symbol.h"
    
    

    // stEntry ** constant_table, ** symbol_table;
    
    
    int comment_strt =0;
    // stEntry ** constant_table, **symbol_table;

    
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
"int"                   { return INT;}
"short"                 { return SHORT;}
"long"                  { return LONG;}
"long long"             { return LONG_LONG;}
"signed"                { return SIGNED;}
"unsigned"              { return UNSIGNED;}
"char"                  { return CHAR;}
"if"                    { return IF;}
"else"                  { return ELSE;}
"while"                 { return WHILE;}
"continue"              { return CONTINUE;}
"break"                 { return BREAK;}
"return"                { return RETURN;}

  /* Strings */
\"([^\\\"]|\\.)* {printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal String", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
\"([^\\\"]|\\.)*\" { return STRING_CONSTANT;}

  /* Rules for numeric constants needs to be before identifiers otherwise giving error */
0([x|X])({DIGIT}|[a-fA-F])+    {yylval.val=strtol(yytext,0,16);return HEXADECIMAL_CONSTANT ;insert(constant_table,yytext,HEXADECIMAL_CONSTANT);}
0([x|X])({DIGIT}|[a-zA-Z])+    {printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal Hexadecimal Constant", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
0([0-7])+    {insert(constant_table,yytext,OCTAL_CONSTANT); yylval.val = strtol(yytext, 0, 8); return OCTAL_CONSTANT;}
0([0-9])+   { printf("\n%s%30s%30s%30s%d\n", RED,  "  Illegal octal constant", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
{PLUS}?{DIGIT}*{DOT}{DIGIT}+ {insert(constant_table,yytext,FLOATING_CONSTANT);yylval.fraction = strtof(yytext, NULL); return FLOATING_CONSTANT;}
{NEG}{DIGIT}*{DOT}{DIGIT}+   {insert(constant_table,yytext,FLOATING_CONSTANT);yylval.fraction = strtof(yytext, NULL); return FLOATING_CONSTANT;}

 /* Invalid mantissa exponent forms */
({PLUS}?|{NEG}){DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}* {printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal Floating Constant ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}* {printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal Floating Constant ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}

 /* Valid Mantissa Exponent forms */ 
({PLUS}?|{NEG}){DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}+ {yylval.entry = insert(constant_table,yytext,FLOATING_CONSTANT); yylval.fraction = strtof(yytext, NULL); return FLOATING_CONSTANT ;}
({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}+ {insert(constant_table,yytext,FLOATING_CONSTANT); yylval.fraction = strtof(yytext, NULL); return FLOATING_CONSTANT ;}




{PLUS}?{DIGIT}+              {insert(constant_table,yytext,INTEGER_CONSTANT); yylval.val = strtol(yytext, 0, 10); return INTEGER_CONSTANT;}
{NEG}{DIGIT}+                {insert(constant_table,yytext,INTEGER_CONSTANT); yylval.val = strtol(yytext, 0, 10); return INTEGER_CONSTANT;}

({ALPHA}|{DIGIT}|{UND})*{INVALID_IDENTIFIER}+({ALPHA}|{DIGIT}|{UND})* { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal identifier ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
{IDENTIFIER}                 {insert(symbol_table,yytext,IDENTIFIER);return IDENTIFIER;}

{DIGIT}+({ALPHA}|{UND})+   { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal identifier ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}



 /* Shorthand assignment operators */
"+="                { return PLUSEQ ;}  
"-="                { return MINUSEQ ;}  
"*="                { return MULEQ ;}  
"/="                { return DIVEQ ;}  
"%="                { return MODEQ;}  


 /* Logical Operators */

"&&"                { return AND ;}
"||"				        { return OR ;}
"!"                 { return NOT ;}

 /* Bitwise Operators */

">>"                    { return RSHIFT ;}
"<<"                    { return LSHIFT ;}
"^"                    { return BIT_XOR ;}
"&"                    { return BIT_AND ;}
"|"                    { return BIT_OR ;}

 /* Relational operators */
"="                     {  return EQ;}  
"!="                    {  return NEQ;}  
">"                     {  return GT;}  
"<"                     {  return LT;}  
">="                    {  return GE; }
"<="                    {  return LE;}  
"=="                    {  return EQEQ;}  

 /* Arithmetic Operators */
"++"                    {  return INC ;}  
"--"                    {  return DEC ;}  
"+"                     {  return PLUS;}  
"-"                     {  return MINUS;}  
"*"                     {  return MUL;}  
"/"                     {  return DIV;}  
"%"                     {  return MOD;}  


 /* Punctuators */
","                 {  return COMMA;}   
";"                 {  return SEMICOLON;} 
"("                 {  return OPEN_PARENTHESIS;} 
")"                 {  return CLOSE_PARENTHESIS ;} 
"{"                 {  return OPEN_BRACE ;} 
"}"                 {  return CLOSE_BRACE;} 
"["                 {  return OPEN_SQR_BKT ;} 
"]"                 {  return CLOSE_SQR_BKT ;} 


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