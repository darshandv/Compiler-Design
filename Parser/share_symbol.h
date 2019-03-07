

#ifndef LEXER_FILE
#include "symbolTable.h" 
extern stEntry ** constant_table, ** symbol_table;
#endif
#ifndef YACC_FILE
typedef struct symbolTableEntry
{
	char* lexeme;
	int token;
	int value;
	struct symbolTableEntry * next;
} stEntry;
stEntry ** constant_table, ** symbol_table;
#include "y.tab.h"
#endif





