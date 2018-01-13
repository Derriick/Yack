%{
	#include <stdio.h>
	#include <stdlib.h>

	void	yyerror(const char *mess);
	int	yylex();
%}

%token N E S W
%token NE NW SE SW

%start	cell_0_0

%%

cell_0_0
	: E	cell_1_0 
	| S	cell_0_1
;

cell_0_1
	: NE	cell_1_0
	| SE	cell_1_2
	| N	cell_0_0
	| S	cell_0_2
;

cell_0_2
	: N	cell_0_1
	| E	cell_1_2
;

cell_1_0
	: SE	cell_2_1
	| SW	cell_0_1
	| E	cell_2_0
	| W	cell_0_0
;

cell_1_2
	: NE	cell_2_1
	| NW	cell_0_1
	| E	cell_2_2
	| W	cell_0_2
;

cell_2_0
	: S	cell_2_1
	| W	cell_1_0
;

cell_2_1
	: NW	cell_1_0
	| SW	cell_1_2
	| N	cell_2_0
	| S	cell_2_2
;

cell_2_2
	: { return 0; }
;

%%

#include "labres.yy.c"
#include "my_labres.c"
