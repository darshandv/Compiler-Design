/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    NUMBER = 258,
    IDENTIFIER = 259,
    INTEGER_CONSTANT = 260,
    FLOATING_CONSTANT = 261,
    HEXADECIMAL_CONSTANT = 262,
    OCTAL_CONSTANT = 263,
    STRING_CONSTANT = 264,
    CHARACTER_CONSTANT = 265,
    CHAR = 266,
    SHORT = 267,
    INT = 268,
    LONG = 269,
    LONG_LONG = 270,
    FLOAT = 271,
    SIGNED = 272,
    UNSIGNED = 273,
    IF = 274,
    ELSE = 275,
    WHILE = 276,
    RETURN = 277,
    CONTINUE = 278,
    BREAK = 279,
    EQ = 280,
    EQEQ = 281,
    NEQ = 282,
    GT = 283,
    LT = 284,
    GE = 285,
    LE = 286,
    OR = 287,
    AND = 288,
    NOT = 289,
    BIT_OR = 290,
    BIT_XOR = 291,
    BIT_AND = 292,
    LSHIFT = 293,
    RSHIFT = 294,
    PLUS = 295,
    MINUS = 296,
    MOD = 297,
    DIV = 298,
    MUL = 299,
    INC = 300,
    DEC = 301,
    PLUSEQ = 302,
    MINUSEQ = 303,
    MULEQ = 304,
    DIVEQ = 305,
    MODEQ = 306,
    COMMA = 307,
    SEMICOLON = 308,
    OPEN_PARENTHESIS = 309,
    CLOSE_PARENTHESIS = 310,
    OPEN_BRACE = 311,
    CLOSE_BRACE = 312,
    OPEN_SQR_BKT = 313,
    CLOSE_SQR_BKT = 314,
    SINGLE_LINE = 315,
    MULTI_LINE = 316,
    INCLUDE = 317,
    DEF = 318,
    IFX = 319
  };
#endif
/* Tokens.  */
#define NUMBER 258
#define IDENTIFIER 259
#define INTEGER_CONSTANT 260
#define FLOATING_CONSTANT 261
#define HEXADECIMAL_CONSTANT 262
#define OCTAL_CONSTANT 263
#define STRING_CONSTANT 264
#define CHARACTER_CONSTANT 265
#define CHAR 266
#define SHORT 267
#define INT 268
#define LONG 269
#define LONG_LONG 270
#define FLOAT 271
#define SIGNED 272
#define UNSIGNED 273
#define IF 274
#define ELSE 275
#define WHILE 276
#define RETURN 277
#define CONTINUE 278
#define BREAK 279
#define EQ 280
#define EQEQ 281
#define NEQ 282
#define GT 283
#define LT 284
#define GE 285
#define LE 286
#define OR 287
#define AND 288
#define NOT 289
#define BIT_OR 290
#define BIT_XOR 291
#define BIT_AND 292
#define LSHIFT 293
#define RSHIFT 294
#define PLUS 295
#define MINUS 296
#define MOD 297
#define DIV 298
#define MUL 299
#define INC 300
#define DEC 301
#define PLUSEQ 302
#define MINUSEQ 303
#define MULEQ 304
#define DIVEQ 305
#define MODEQ 306
#define COMMA 307
#define SEMICOLON 308
#define OPEN_PARENTHESIS 309
#define CLOSE_PARENTHESIS 310
#define OPEN_BRACE 311
#define CLOSE_BRACE 312
#define OPEN_SQR_BKT 313
#define CLOSE_SQR_BKT 314
#define SINGLE_LINE 315
#define MULTI_LINE 316
#define INCLUDE 317
#define DEF 318
#define IFX 319

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 18 "parser.y" /* yacc.c:1909  */

    stEntry* entry;
    double fraction;
    long val;
    int ival;
    char *st;

#line 190 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
