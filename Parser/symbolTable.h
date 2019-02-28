#ifndef SYMBOL_TABLE
#define SYMBOL_TABLE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define TABLE_SIZE 150

typedef struct symbolTableEntry
{
	char* lexeme;
	int token;
	double value;
	struct symbolTableEntry * next;
} stEntry;


unsigned int hash_value(char* lexeme){

	// djb2 alorithm
	unsigned long hash = 5381;

	int c;
	for (int i = 0; i < strlen(lexeme); ++i)
	{
		hash = ((hash << 5) + hash) + lexeme[i];
	}

	return (unsigned int)hash % TABLE_SIZE;
}


stEntry** new_table(){

	stEntry** table_ptr = NULL;
	int i=0;

	if(!(table_ptr = (stEntry **)malloc(sizeof(stEntry*) * TABLE_SIZE)))
		return NULL;

	for(;i<TABLE_SIZE;i++){
		table_ptr[i] = NULL;
	}
	return table_ptr;
}


stEntry* new_entry(char *lexeme, int token, double value)
{
	stEntry *new_entry = NULL;

	if(!(new_entry = (stEntry *) malloc(sizeof(stEntry))))
		return NULL;

	if((new_entry->lexeme = strdup(lexeme))==NULL)
		return NULL;

	new_entry->token = token;
	new_entry->next = NULL;
	new_entry->value = value;
}

stEntry* search(stEntry** hash_table, char* lexeme){
	unsigned int index;
	stEntry* key_entry;

	index = hash_value(lexeme);
	key_entry = hash_table[index];

	while(key_entry!=NULL && strcmp(key_entry->lexeme,lexeme)!=0)
		key_entry = key_entry->next;

	if(key_entry==NULL)return NULL;

	else return key_entry;
}

stEntry* insert(stEntry** hash_table, char* lexeme, int token, double value){
	if(search(hash_table, lexeme)!=NULL)
	{
		//printf("\nError : Token already exists. Not inserting\n");
		return NULL;
	}

	unsigned int index = hash_value(lexeme);
	stEntry* newentry= new_entry(lexeme,token, value);

	if (newentry == NULL){
		printf("Cannot insert token into the symbol table\n");
		exit(1);
	}

	stEntry* head = hash_table[index];

	if(head==NULL){
		hash_table[index] = newentry;
	}
	else
	{
		newentry->next = hash_table[index];
		hash_table[index] = newentry;
	}

	return hash_table[index];
}

void display(stEntry** hash_table){
	int i=0;
	stEntry* iterator;

	printf("\n=============================================================\n");
	printf("            lexeme            |            token               ");
	printf("\n=============================================================\n");

	for(;i<TABLE_SIZE;++i){
		iterator = hash_table[i];

		while(iterator!= NULL){
			printf("%-30s|%30d\n",iterator->lexeme,iterator->token );
			iterator = iterator->next;
		}
	}
	printf("\n=============================================================\n");
}

#endif



