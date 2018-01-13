%{
	#include <stdio.h>
	#include <stdlib.h>

	//typedef const char* Cstr;

	#include "auge/top.h"
	#include "auge/lds.h"
	#include "auge/expr.h"
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
	Texpr* type_expr;
	Tpoint type_pt;
	Tpoints* type_pt_list;
	Tpoint3 type_pt3;
	Tpoint3s* type_pt3_list;
	TdrawOpt type_dopt
}

%type <integer> CNUM xcst
%type <string> IDENT
%type <type_expr> expr
%type <type_pt> pt
%type <type_pt_list> pt_list pt_arrow_list
%type <type_pt3> pt3 range
%type <type_pt3_list> pt3_list vars_in_ranges
%type <type_dopt> dopt

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
	| IDENT '=' xcst {
			vars_chgOrAddEated(gl_pdt->vars, $1, $3);
		}
	| IDENT '+' '=' xcst {
			Tvar *v = NULL;
			if ((v = vars_get(gl_pdt->vars, $1)))
				v->val += $4;
			else
				yyerror("%s undefined\n", $1);
		}
	| IDENT '-' '=' xcst {
			Tvar *v = NULL;
			if ((v = vars_get(gl_pdt->vars, $1)))
				v->val -= $4;
			else
				yyerror("%s undefined\n", $1);
		}
	| IDENT '*' '=' xcst {
			Tvar *v = NULL;
			if ((v = vars_get(gl_pdt->vars, $1)))
				v->val *= $4;
			else
				yyerror("%s undefined\n", $1);
		}
	| IDENT '/' '=' xcst {
			Tvar *v = NULL;
			if ((v = vars_get(gl_pdt->vars, $1)))
				v->val /= $4;
			else
				yyerror("%s undefined\n", $1);
		}
	| IDENT '%' '=' xcst {
			Tvar *v = NULL;
			if ((v = vars_get(gl_pdt->vars, $1)))
				v->val %= $4;
			else
				yyerror("%s undefined\n", $1);
		}

size_initialization
	: SIZE xcst ';' {
			if ($2 < 0 || $2 >= LDS_SIZE)
				yyerror("%d: invalid Lab Size");
			else
				lds_size_set(gl_lds, $2, $2);
		}
	| SIZE xcst ',' xcst ';' {
			if ($2 < 0 || $2 >= LDS_SIZE || $4 < 0 || $4 >= LDS_SIZE)
				yyerror("%dx%d: invalid Lab Size");
			else
				lds_size_set(gl_lds, $2, $4);
		}
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
	| dopt
	| dopt PTA pt_list
	| dopt PTD pt
	| dopt PTD pt pt3_list
	| dopt R pt pt
	| dopt R F pt pt
	| dopt FOR vars_in_ranges '(' expr ',' expr ')'
	| WH pt_arrow_list
	| MD pt dest_list
;

expr
	: CNUM			{ $$ = expr_cst($1);					}
	| IDENT			{ $$ = expr_varEated($1);				}
	| expr '+' expr	{ $$ = expr_binOp(EXPKD_PLUS, $1, $3);	}
	| expr '-' expr	{ $$ = expr_binOp(EXPKD_MINUS, $1, $3);	}
	| expr '*' expr	{ $$ = expr_binOp(EXPKD_TIME, $1, $3);	}
	| expr '/' expr	{ $$ = expr_binOp(EXPKD_DIV, $1, $3);	}
	| expr '%' expr	{ $$ = expr_binOp(EXPKD_MOD, $1, $3);	}
	| '+' expr		{ $$ = expr_uniOp(EXPKD_NONE, $2);		}
	| '-' expr		{ $$ = expr_uniOp(EXPKD_NEG, $2);		}
	| '(' expr ')'	{ $$ = expr_uniOp(EXPKD_NONE, $2);		}
;

xcst
	: CNUM { $$ = $1; }
	| IDENT {
			Tvar *v = NULL;
			if ((v = vars_get(gl_pdt->vars, $1)))
				$$ = v->val;
			else
				yyerror("%s undefined\n", $1);
		}
	| xcst '+' xcst	{ $$ = $1 + $3;	}
	| xcst '-' xcst	{ $$ = $1 - $3;	}
	| xcst '*' xcst	{ $$ = $1 * $3;	}
	| xcst '/' xcst	{ $$ = $1 / $3;	}
	| xcst '%' xcst	{ $$ = $1 % $3;	}
	| '+' xcst		{ $$ = $2;		}
	| '-' xcst		{ $$ = - $2;	}
	| '(' xcst ')'	{ $$ = $2;		}
;

pt
	: '(' xcst ',' xcst ')' {
			if (lds_check_xy(gl_lds, $2, $4))
				yyerror("[%s:%s] outside of the labyrinth\n", $2, $4);
			else
				$$.x = $2; $$.y = $4;
		}
;

pt_list
	: pt_list pt {
			pts_app_pt($1, $2);
			$$ = $1;
		}
	| pt { $$ = pts_new_pt($1); }
;


pt3
	: pt {
			$$.xy = $1;
			$$.z = 1;
		}
	| pt ':' xcst {
			if ($3 <= 0)
				yyerror("$3 can't be negative or null\n", $3);
			else {
				$$.xy = $1;
				$$.z = $3;
			}
		}
	| pt ':' '*' {
			$$.xy = $1;
			$$.z = 0;
		}
;

pt3_list
	: pt3_list pt3 {
			pt3s_app_pt3($1, $2);
			$$ = $1;
		}
	| pt3 { $$ = pt3s_new_p2z($1.xy, $1.z); }
;

pt_arrow_list
	: pt_arrow_list ARROW pt {
			pts_app_pt($1, $3);
			$$ = $1;
		}
	| pt { $$ = pts_new_pt($1); }
;

range
	: '[' xcst ':' xcst ']' {
			if ($2 < $4)
				yyerror("Error: %d < %d\n", $2, $4);
			else {
				($$.xy).x = $2;
				($$.xy).y = $4;
				$$.z = 1;
			}
		}
	| '[' xcst ':' xcst ':' xcst ']' {
			if ($2 < $4 || $6 < 1)
				yyerror("Error: %d < %d or $6 < 1\n", $2, $4, $6);
			else {
				($$.xy).x = $2;
				($$.xy).y = $4;
				$$.z = $6;
			}
		}
	| '[' xcst ':' xcst '[' {
			if ($2 <= $4)
				yyerror("Error: %d <= %d\n", $2, $4);
			else {
				($$.xy).x = $2;
				($$.xy).y = $4 - 1;
				$$.z = 1;
			}
		}
	| '[' xcst ':' xcst ':' xcst '[' {
			if ($2 <= $4 || $6 < 1)
				yyerror("Error: %d <= %d or $6 < 1\n", $2, $4, $6);
			else {
				($$.xy).x = $2;
				($$.xy).y = $4 - 1;
				$$.z = $6;
			}
		}
;

vars_in_ranges
	: IDENT IN range {
		vars_chgOrAddEated(gl_pdt->vars, $1, ($3.xy).x);
		$$ = pt3s_new_p2z($3.xy, $3.z);
	}
	| IDENT vars_in_ranges range {
		vars_chgOrAddEated(gl_pdt->vars, $1, ($3.xy).x);
		pt3s_app_pt3($2, $3);
		$$ = $2;
	}
;

dopt
	: WALL		{ $$ = LG_DrawWall;		}
	| UNWALL	{ $$ = LG_DrawUnwall;	}
	| TOGGLE	{ $$ = LG_DrawToggle;	}
;

dest_list
	: dest_list DIR pt
	| DIR pt
;

%%

#include "labgen.yy.c"
#include "top.c"
