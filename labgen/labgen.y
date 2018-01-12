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
	Tpoints* type_pt_list;
	Tpoint type_point;
	Tpoint3s* type_ptri_list;
	Tpoint3s type_ptri;
}

%type <integer> CNUM xcst expr
%type <string> IDENT
%type <type_pt_list> pt_list
%type <type_point> pt
%type <type_ptri_list> ptri_list 
%type <type_ptri> ptri

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
	| IDENT '=' xcst		{ vars_chgOrAddEated(gl_pdt->vars, $1, $3); }
	| IDENT '+' '=' xcst	{ Tvar *v; (v = vars_get(gl_pdt->vars, $1)) ? (v->val += $4) : yyerror("%s undefined\n", $1); }
	| IDENT '-' '=' xcst	{ Tvar *v; (v = vars_get(gl_pdt->vars, $1)) ? (v->val -= $4) : yyerror("%s undefined\n", $1); }
	| IDENT '*' '=' xcst	{ Tvar *v; (v = vars_get(gl_pdt->vars, $1)) ? (v->val *= $4) : yyerror("%s undefined\n", $1); }
	| IDENT '/' '=' xcst	{ Tvar *v; (v = vars_get(gl_pdt->vars, $1)) ? (v->val /= $4) : yyerror("%s undefined\n", $1); }
	| IDENT '%' '=' xcst	{ Tvar *v; (v = vars_get(gl_pdt->vars, $1)) ? (v->val %= $4) : yyerror("%s undefined\n", $1); }

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

expr
	: CNUM			{ $$ = $1;		}
	| IDENT			{ Tvar *v; (v = vars_get(gl_pdt->vars, $1)) ? ($$ = v->val) : yyerror("%s undefined\n", $1); }
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
	| IDENT			{ Tvar *v; (v = vars_get(gl_pdt->vars, $1)) ? ($$ = v->val) : yyerror("%s undefined\n", $1); }
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
	: '(' xcst ',' xcst ')' { if (lds_check_xy(gl_lds,$2,$4)) yyerror("[%s:%s] outside of the labyrinth\n",$2,$4); $$.x = $2; $$.y = $4; }
;

pt_list
	: pt_list pt 	{ pts_app_pt($1,$2); $$=$1;}
	| pt 			{ $$ = pts_new_pt($1);}
;


ptri
	: pt 			{ Tpoint3 pt3; pt3.Tpoint = $1; pt3.z = 1; $$=pt3; }
	| pt ':' xcst	{ if ($3 <= 0) yyerror("[%s:%s]:$3 error \n",$1.x, $1.y, $3); Tpoint3 pt3; pt3.Tpoint = $1; pt3.z = $3; $$=pt3; }
	| pt ':' '*'	{ Tpoint3 pt3; pt3.Tpoint = $1; pt3.z = 0; $$=pt3; }
;

ptri_list
	: ptri_list ptri 	{ pt3s_app_pt3 ($1, $2[0]) }
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
