%{
	#include <stdio.h>
	#include <stdlib.h>

	//typedef const char* Cstr;

	#include "auge/top.h"
	#include "auge/lds.h"
	#include "auge/vars.h"
	#include "auge/pdt.h"

	int	yylex();
%}


/* définition des terminaux */
%token CNUM IDENT DIR
%token SIZE IN OUT SHOW PTA PTD FOR
%token WALL UNWALL TOGGLE
%token R F
%token WH MD
%token ARROW

%union {
	int integer;
	char* string;
}

%type <integer> CNUM xcst expr
%type <string> IDENT

%left '+' '-'
%left '*' '/'
%left '%'

/* règle BNF principale */
%start labyrinth

%%

labyrinth
	: suite_declaration size_initialization suite_instruction
;

suite_declaration
	: suite_declaration declaration ';'
	| declaration ';'
;

declaration
	: ';'
	| IDENT '=' xcst		{ vars_chgOrAddEated(gl_pdt->vars, $1, $3); }
	| IDENT '+' '=' xcst	{ Tvar *v; if ((v = vars_get(gl_pdt->vars, $1))) v->val += $4; else yyerror("%s undefined\n", $1); }
	| IDENT '-' '=' xcst	{ Tvar *v; if ((v = vars_get(gl_pdt->vars, $1))) v->val -= $4; else yyerror("%s undefined\n", $1); }
	| IDENT '*' '=' xcst	{ Tvar *v; if ((v = vars_get(gl_pdt->vars, $1))) v->val *= $4; else yyerror("%s undefined\n", $1); }
	| IDENT '/' '=' xcst	{ Tvar *v; if ((v = vars_get(gl_pdt->vars, $1))) v->val /= $4; else yyerror("%s undefined\n", $1); }
	| IDENT '%' '=' xcst	{ Tvar *v; if ((v = vars_get(gl_pdt->vars, $1))) v->val %= $4; else yyerror("%s undefined\n", $1); }

size_initialization
	: SIZE xcst ';'				{ if ($2 < 0 || $2 >= LDS_SIZE) yyerror("%d: invalid Lab Size"); else lds_size_set(gl_lds, $2, $2); }
	| SIZE xcst ',' xcst ';'	{ if ($2 < 0 || $2 >= LDS_SIZE || $4 < 0 || $4 >= LDS_SIZE) yyerror("(%d, %d): invalid Lab Size"); else lds_size_set(gl_lds, $2, $4); }
;

suite_instruction
	: suite_instruction show
	| show
	| suite_instruction instruction ';'
	| instruction ';'
;

show
	: SHOW	{ lds_dump(gl_lds, stdout); }

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

expr
	: CNUM			{ $$ = $1;		}
	| IDENT			{ Tvar *v; $$ = (v = vars_get(gl_pdt->vars, $1)) ? v->val : $1; }
	| expr '+' expr	{ $$ = $1 + $3;	}
	| expr '-' expr	{ $$ = $1 - $3;	}
	| expr '*' expr	{ $$ = $1 * $3;	}
	| expr '/' expr	{ $$ = $1 / $3;	}
	| expr '%' expr	{ $$ = $1 % $3;	}
	| '+' expr		{ $$ = $2;		}
	| '-' expr		{ $$ = - $2;	}
	| '(' expr ')'	{ $$ = ( $2 );	}
;

xcst
	: CNUM			{ $$ = $1;		}
	| IDENT			{ Tvar *v; if ((v = vars_get(gl_pdt->vars, $1))) $$ = v->val; else yyerror("%s undefined\n", $1); }
	| xcst '+' xcst	{ $$ = $1 + $3;	}
	| xcst '-' xcst	{ $$ = $1 - $3;	}
	| xcst '*' xcst	{ $$ = $1 * $3;	}
	| xcst '/' xcst	{ $$ = $1 / $3;	}
	| xcst '%' xcst	{ $$ = $1 % $3;	}
	| '+' xcst		{ $$ = $2;		}
	| '-' xcst		{ $$ = - $2;	}
	| '(' xcst ')'	{ $$ = ( $2 );	}
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

var_list
	: var_list IDENT
	| IDENT
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
