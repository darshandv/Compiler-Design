#!/bin/bash
yacc -d parser.y --warnings=none
lex -l scanner.flex
gcc lex.yy.c y.tab.c -lfl -g