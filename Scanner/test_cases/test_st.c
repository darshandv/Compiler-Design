#include "symbolTable.h"


/*
** tHIS IS A TEST
** SDSAD
*/
int main(int argc, char const *argv[])
{
	char *test = "while";
	stEntry** symbol_table = new_table();
	insert(symbol_table,test,100);
	display(symbol_table);
	insert(symbol_table,"if",150);
	insert(symbol_table,"if",150);
	display(symbol_table);
	return 0;
}

