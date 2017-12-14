%{
	#include <stdio.h>
	#include <stdlib.h>

	void yyerror(const char *mess);
	int yylex();
%}

%token N S E W NE NW SE SW



cell_0_0
	: E cell_1_0 
	| S cell_0_1
;

cell_1_0
	: SE cell_2_1
	| W cell_0_0
	| SW cell_0_1
;

cell_0_1
	: N cell_0_0
	| SE cell_1_2
	| NE cell_1_0
;


cell_1_2
	: E cell_2_2
	| NW cell_0_1
	| NE cell_2_1
;


cell_2_1
	: NW cell_1_0
	| S cell_2_2
	| SW cell_1_2
;

cell_2_2:;


%%
#include "labres2.yy.c"
void yyerror(const char *mess)
{
	fprintf(stderr, "FATAL: %s (near %s)\n", mess, yytext);
	exit(1);
}

int main(int argc, char *argv[])
{
	if(argc == 2){
		FILE file = fopen(const char* argv[1], "r");
		if(file != NULL){
			yyin = file;
		}
		else{
			yyerror("error in the file");
		}
	}
	else if(argc != 1){
		yyerror("error in the args");
	}

	int succ = yyparse();

	if(succ){
		printf("\n Izi win !");
	}
	else{
		printf("Too bad, looser !");
	}
	return(succ);
}
