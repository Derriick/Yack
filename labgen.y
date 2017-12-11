%{
	#include <stdio.h>
	#include <stdlib.h>

	void yyerror(const char *mess);
	int yylex();
%}


/* définition des terminaux */
%token CNUM IDENT DIR
%token tk_SIZE tk_IN tk_OUT tk_SHOW tk_WALL tk_PTA tk_PTD tk_TOGGLE tk_R tk_F tk_FOR
%token tk_SHARP

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
	| tk_OUT suite_pt
	| tk_SHOW
	| IDENT op'=' xcst
	| tk_WALL
	| tk_WALL tk_PTA suite_pt
	| tk_WALL tk_PTD suite_ptd
	| tk_WALL tk_R pt pt
	| tk_WALL tk_R tk_F pt pt
	| tk_WALL tk_FOR suite_value tk_IN suite_range '(' expr ',' expr ')'
	| tk_TOGGLE tk_R pt pt
;

expr
	: value
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
	: value
	| xcst '+' xcst
	| xcst '-' xcst
	| xcst '*' xcst
	| xcst '/' xcst
	| xcst '%' xcst
	| '+' xcst
	| '-' xcst
	| '(' xcst ')'
;

pt
	: '(' xcst ',' xcst ')'
;

suite_pt
	: suite_pt pt
	| pt
;

ptd
	: pt
	| pt ':' ri
;

suite_ptd
	: suite_ptd ptd
	| ptd
;

ri
	: xcst
	| '*'
;

op
	: '+'
	| '-'
	| '*'
	| '/'
	| '%'
;

value
	: CNUM
	| IDENT
;

suite_value
	: suite_value value
	| value
;

range
	: '[' xcst ',' xcst ']'
	| '[' xcst ',' xcst ',' xcst ']'
;

suite_range
	: suite_range range
	| range
;

%%
#include "lex.yy.c"

void yyerror(const char *mess)
{
	fprintf(stderr, "FATAL: %s (near %s)\n", mess, yytext);
	exit(1);
}

int main()
{
	return yyparse();
}
