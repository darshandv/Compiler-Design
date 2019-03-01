#!/bin/bash
flex scanner.flex 
yacc parser.y -d
gcc -g y.tab.c