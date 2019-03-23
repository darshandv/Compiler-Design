/*
 * This file will contain the actual scanner written in fLEX.
*/
/* Definition section */
%{
    #define NRML  "\x1B[0m"
    #define RED  "\x1B[31m"
    #define BLUE   "\x1B[34m"
    #include <stdlib.h>
    #include <string.h>
    #include <ctype.h>
    #include <limits.h>

    #include "y.tab.h"
  
    
    int comment_strt =0;

    char *my_itoa(int num, char *str)
{
        if(str == NULL)
        {
                return NULL;
        }
        sprintf(str, "%d", num);
        return str;
}

    
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
<comment>"*/"                        { BEGIN INITIAL;return MULTI_LINE;}
<comment>"/*"                        {printf("\n%s%30s%30s%30s%d\n", RED,  "Nested comment", yytext ,"Line Number:", yylineno-1);printf("%s", NRML);yylineno--;yyterminate();}
<comment><<EOF>>                     {printf("\n%s%30s%30s%30s%d\n", RED,  "Unterminated comment", yytext ,"Line Number:", yylineno-1);printf("%s", NRML);yylineno--;yyterminate();}
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
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+({PLUS}|{NEG})?{DIGIT}*{DOT}{DIGIT}+[^;] {return DEF;}
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+{DIGIT}+[^;]                             { return DEF ;}
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+{ALPHA}({ALPHA}|{UND}|{DIGIT})*[^;]      { return DEF; }


 /* Illegal #define statements */ 
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+({PLUS}|{NEG})?{DIGIT}*{DOT}{DIGIT}+{SPACE}*[;] { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal macro definition. Ended with semicolon at ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+{DIGIT}+{SPACE}*[;]                             { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal macro definition. Ended with semicolon at ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
#define{SPACE}+{ALPHA}({ALPHA}|{DIGIT}|{UND})*{SPACE}+{ALPHA}({ALPHA}|{UND}|{DIGIT})*{SPACE}*[;]      { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal macro definition. Ended with semicolon at ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}

 /* Keywords */
"int"                   { return INT;}
"float"                 { return FLOAT;}
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
\"([^\\\"]|\\.)*\" {yylval = (char*)malloc(100 * sizeof(char)); strcpy(yylval, yytext); return STRING_CONSTANT;} // insert(constant_table,yytext,STRING_CONSTANT, INT_MAX);

\'([^\\\"]|\\.)\' {yylval = (char*)malloc(100 * sizeof(char)); strcpy(yylval, yytext); return CHARACTER_CONSTANT; } // insert(constant_table,yytext,CHARACTER_CONSTANT, INT_MAX); 
 \''             {printf("\n%s%30s%30s%30s%d\n", RED,  "Empty character constant", yytext ,"Line Number:", yylineno);printf("%s", NRML);}

  /* Rules for numeric constants needs to be before identifiers otherwise giving error */
{PLUS}?{DIGIT}*{DOT}{DIGIT}+ { yylval = (char*)malloc(100 * sizeof(char)); strcpy(yylval, yytext); return FLOATING_CONSTANT;} // insert(constant_table,yytext,FLOATING_CONSTANT, INT_MAX); // yylval.fraction = strtof(yytext, NULL);
{NEG}{DIGIT}*{DOT}{DIGIT}+   { yylval = (char*)malloc(100 * sizeof(char)); strcpy(yylval, yytext); return FLOATING_CONSTANT;} // insert(constant_table,yytext,FLOATING_CONSTANT, INT_MAX);

 /* Invalid mantissa exponent forms */
({PLUS}?|{NEG}){DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}* {printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal Floating Constant ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}* {printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal Floating Constant ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}

 /* Valid Mantissa Exponent forms */ 
({PLUS}?|{NEG}){DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}+ { yylval = (char*)malloc(100 * sizeof(char)); strcpy(yylval, yytext);return FLOATING_CONSTANT ;} // yylval.entry = insert(constant_table,yytext,FLOATING_CONSTANT, INT_MAX);
({PLUS}?|{NEG}){DIGIT}*{DOT}{DIGIT}+([e|E])({PLUS}?|{NEG}){DIGIT}+ {yylval = (char*)malloc(100 * sizeof(char)); strcpy(yylval, yytext);return FLOATING_CONSTANT ;} // insert(constant_table,yytext,FLOATING_CONSTANT, INT_MAX); 




{PLUS}?{DIGIT}+              { yylval = (char*)malloc(100 * sizeof(char)); strcpy(yylval, yytext); return INTEGER_CONSTANT;} // insert(constant_table,yytext,INTEGER_CONSTANT, INT_MAX); yylval.val = strtol(yytext, 0, 10);
{NEG}{DIGIT}+                { yylval = (char*)malloc(100 * sizeof(char)); strcpy(yylval, yytext); return INTEGER_CONSTANT;} // insert(constant_table,yytext,INTEGER_CONSTANT, INT_MAX); yylval.val = strtol(yytext, 0, 10);

({ALPHA}|{DIGIT}|{UND})*{INVALID_IDENTIFIER}+({ALPHA}|{DIGIT}|{UND})* { printf("\n%s%30s%30s%30s%d\n", RED,  "Illegal identifier ", yytext ,"Line Number:", yylineno);printf("%s", NRML);}
{IDENTIFIER}                 {yylval = (char*)malloc(100 * sizeof(char)); strcpy(yylval, yytext); return IDENTIFIER;} // yylval.entry = insert(symbol_table,yytext,IDENTIFIER, INT_MAX);

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