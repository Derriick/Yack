%{
	#include <stdio.h>
	#include <stdlib.h>

	void yyerror(const char *mess);
	int yylex();
%}


/* définition des terminaux */
%token CNUM IDENT DIR
%token tk_SIZE tk_IN tk_OUT tk_SHOW tk_PTA tk_PTD tk_FOR
%token tk_WALL tk_UNWALL tk_TOGGLE
%token tk_R tk_F
%token tk_WH tk_MD

%left '+' '-'
%left '*' '/'
%left '%'

/* règle BNF principale */
%start labyrinthe

%%

labyrinthe
	: suite_instruction;

suite_instruction
	: suite_instruction instruction ';'
	| instruction ';'
;

instruction
	: ';'
	| IDENT '=' xcst
	| tk_SIZE xcst
	| tk_SIZE xcst ',' xcst
	| tk_IN pt
	| tk_OUT pt_list
	| tk_SHOW
	| IDENT op '=' xcst
	| wall
	| wall tk_PTA pt_list
	| wall tk_PTD pt
	| wall tk_PTD pt ptri_list
	| wall tk_R pt pt
	| wall tk_R tk_F pt pt
	| wall tk_FOR var_list tk_IN range_list '(' expr ',' expr ')'
	| tk_WH pt pt_arrow_list
	| tk_MD dest_list
;

var
	: CNUM
	| IDENT
;

var_list
	: var_list var
	| var
;

expr
	: var
	| expr '+' expr
	| expr '-' expr
	| expr '*' expr
	| expr '/' expr
	| expr '%' expr
	| '+' expr
	| '-' expr
	| '(' expr ')'
;

xcst
	: expr
;

pt
	: '(' xcst ',' xcst ')'
;

pt_list
	: pt_list pt
	| pt
;

ri
	: xcst
	| '*'
;

ptri
	: pt
	| pt ':' ri
;

ptri_list
	: ptri_list ptri
	| ptri
;

pt_arrow_list
	: pt_arrow_list '-' '>' pt
	| pt
;

op
	: '+'
	| '-'
	| '*'
	| '/'
	| '%'
;

range
	: '[' xcst ',' xcst ']'
	| '[' xcst ',' xcst ',' xcst ']'
;

range_list
	: range_list range
	| range
;

wall
	: tk_WALL
	| tk_UNWALL
	| tk_TOGGLE
;

dest_list
	: dest_list DIR pt
	| DIR pt
;

%%

#include "labgen.yy.c"
#include "my_labgen.c"
