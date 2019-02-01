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
    INCLUDE = 260,
    DEF = 261,
    CHAR = 262,
    SHORT = 263,
    INT = 264,
    LONG = 265,
    LONG_LONG = 266,
    SIGNED = 267,
    UNSIGNED = 268,
    IF = 269,
    ELSE = 270,
    WHILE = 271,
    RETURN = 272,
    CONTINUE = 273,
    BREAK = 274,
    EQ = 275,
    EQEQ = 276,
    NEQ = 277,
    GT = 278,
    LT = 279,
    GE = 280,
    LE = 281,
    OR = 282,
    AND = 283,
    NOT = 284,
    BIT_OR = 285,
    BIT_XOR = 286,
    BIT_AND = 287,
    LSHIFT = 288,
    RSHIFT = 289,
    PLUS = 290,
    MINUS = 291,
    MOD = 292,
    DIV = 293,
    MUL = 294,
    INC = 295,
    DEC = 296,
    MODULO = 297,
    PLUSEQ = 298,
    MINUSEQ = 299,
    MULEQ = 300,
    DIVEQ = 301,
    MODEQ = 302,
    COMMA = 303,
    SEMICOLON = 304,
    OPEN_PARENTHESIS = 305,
    CLOSE_PARENTHESIS = 306,
    OPEN_BRACE = 307,
    CLOSE_BRACE = 308,
    OPEN_SQR_BKT = 309,
    CLOSE_SQR_BKT = 310,
    SINGLE_LINE = 311,
    STRING_CONSTANT = 312,
    INTEGER_CONSTANT = 313,
    HEXADECIMAL_CONSTANT = 314,
    OCTAL_CONSTANT = 315,
    FLOATING_CONSTANT = 316
  };
#endif
/* Tokens.  */
#define NUMBER 258
#define IDENTIFIER 259
#define INCLUDE 260
#define DEF 261
#define CHAR 262
#define SHORT 263
#define INT 264
#define LONG 265
#define LONG_LONG 266
#define SIGNED 267
#define UNSIGNED 268
#define IF 269
#define ELSE 270
#define WHILE 271
#define RETURN 272
#define CONTINUE 273
#define BREAK 274
#define EQ 275
#define EQEQ 276
#define NEQ 277
#define GT 278
#define LT 279
#define GE 280
#define LE 281
#define OR 282
#define AND 283
#define NOT 284
#define BIT_OR 285
#define BIT_XOR 286
#define BIT_AND 287
#define LSHIFT 288
#define RSHIFT 289
#define PLUS 290
#define MINUS 291
#define MOD 292
#define DIV 293
#define MUL 294
#define INC 295
#define DEC 296
#define MODULO 297
#define PLUSEQ 298
#define MINUSEQ 299
#define MULEQ 300
#define DIVEQ 301
#define MODEQ 302
#define COMMA 303
#define SEMICOLON 304
#define OPEN_PARENTHESIS 305
#define CLOSE_PARENTHESIS 306
#define OPEN_BRACE 307
#define CLOSE_BRACE 308
#define OPEN_SQR_BKT 309
#define CLOSE_SQR_BKT 310
#define SINGLE_LINE 311
#define STRING_CONSTANT 312
#define INTEGER_CONSTANT 313
#define HEXADECIMAL_CONSTANT 314
#define OCTAL_CONSTANT 315
#define FLOATING_CONSTANT 316

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 16 "parser.y" /* yacc.c:1909  */

    stEntry* entry;
    double fraction;
    long val;

#line 182 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
