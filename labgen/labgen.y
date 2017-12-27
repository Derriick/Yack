%{
	//typedef const char* Cstr;

	#include "auge/top.h"
	#include "auge/lds.h"

	int	yylex();
%}


/* définition des terminaux */
%token CNUM IDENT DIR
%token SIZE IN OUT SHOW PTA PTD FOR
%token WALL UNWALL TOGGLE
%token R F
%token WH MD
%token ARROW

%left '+' '-'
%left '*' '/'
%left '%'

/* règle BNF principale */
%start labyrinthe

%%

labyrinthe
	: suite_declaration size_initialization suite_instruction
;

suite_declaration
	: suite_declaration declaration ';'
	| declaration ';'
;

declaration
	: ';'
	| IDENT '=' xcst
	| IDENT op '=' xcst

size_initialization
	: SIZE xcst ';'				{ ($2 < 0 || $2 >= LDS_SIZE) ? yyerror("%d: invalid Lab Size") : lds_size_set(gl_lds, $2, $2); }
	| SIZE xcst ',' xcst ';'	{ ($2 < 0 || $2 >= LDS_SIZE || $4 < 0 || $4 >= LDS_SIZE) ? yyerror("(%d, %d): invalid Lab Size") : lds_size_set(gl_lds, $2, $4); }
;

suite_instruction
	: suite_instruction instruction ';'
	| instruction ';'
	| suite_instruction SHOW
	| SHOW
;

instruction
	: ';'
	| IN pt
	| OUT pt_list
	| wall
	| wall PTA pt_list
	| wall PTD pt
	| wall PTD pt ptri_list
	| wall R pt pt
	| wall R F pt pt
	| wall FOR var_list IN range_list '(' expr ',' expr ')'
	| WH pt_arrow_list
	| MD pt dest_list
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
	| expr '+' expr	{ $$ = $1 + $3;	}
	| expr '-' expr	{ $$ = $1 - $3;	}
	| expr '*' expr	{ $$ = $1 * $3;	}
	| expr '/' expr	{ $$ = $1 / $3;	}
	| expr '%' expr	{ $$ = $1 % $3;	}
	| '+' expr			{ $$ = $2;			}
	| '-' expr			{ $$ = - $2;		}
	| '(' expr ')'		{ $$ = ( $2 );		}
;

xcst
	: var
	| xcst '+' xcst	{ $$ = $1 + $3;	}
	| xcst '-' xcst	{ $$ = $1 - $3;	}
	| xcst '*' xcst	{ $$ = $1 * $3;	}
	| xcst '/' xcst	{ $$ = $1 / $3;	}
	| xcst '%' xcst	{ $$ = $1 % $3;	}
	| '+' xcst			{ $$ = $2;			}
	| '-' xcst			{ $$ = - $2;		}
	| '(' xcst ')'		{ $$ = ( $2 );		}
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
	: pt_arrow_list ARROW pt
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
	: WALL
	| UNWALL
	| TOGGLE
;

dest_list
	: dest_list DIR pt
	| DIR pt
;

%%

#include "labgen.yy.c"
#include "my_labgen.c"
