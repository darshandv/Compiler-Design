#!/bin/bash
flex scanner.flex 
yacc parser.y -d
g++ -g y.tab.c -fpermissive -std=c++11 -g -ly -ll