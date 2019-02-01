#!/bin/bash
yacc -d parser.y
lex -l scanner.flex
gcc lex.yy.c y.tab.c -lfl