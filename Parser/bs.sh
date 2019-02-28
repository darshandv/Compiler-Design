#!/bin/bash
flex scanner.flex 
yacc parser.y -d
gcc y.tab.c