%{
	#include <stdio.h>
	#include <stdlib.h>

	void yyerror(const char *mess);
	int yylex();
%}


/* définition des terminaux */
%token tk_SIZE tk_IN tk_OUT tk_WALL tk_PTA tk_TOOGLE tk_R
%token CNUM IDENT DIR

%left '+' '-'
%left '*' '/'
%left '%'

/* règle BNF principale */
%start labyrinthe

%%

labyrinthe
	: suite_instructions;

suite_instructions
	: suite_instructions instruction ';'
	| instruction ';'
;

instruction
	: ';'
	| IDENT '=' xcst
	| tk_SIZE IDENT
	| tk_SIZE IDENT ',' expr
	| tk_IN pt
	| tk_OUT suite_pts
;

expr
	: CNUM
	| IDENT
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
	: CNUM
	| IDENT
	| xcst '+' xcst
	| xcst '-' xcst
	| xcst '*' xcst
	| xcst '/' xcst
	| xcst '%' xcst
	| '+' xcst
	| '-' xcst
	| '(' xcst ')'
;

suite_pts
	: suite_pts pt
	| pt
;

pt
	: '(' xcst ',' xcst ')'
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