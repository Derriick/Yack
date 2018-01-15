%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	//typedef const char* Cstr;

	#include "auge/top.h"
	#include "auge/lds.h"
	#include "auge/expr.h"
	#include "auge/pdt.h"

	#define MIN(a, b) ((a)<(b) ? (a) : (b))
	#define MAX(a, b) ((a)>(b) ? (a) : (b))

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
	TdrawOpt type_dopt;
	Twr type_dir;
}

%type <integer> CNUM xcst
%type <string> IDENT DIR
%type <type_expr> expr
%type <type_pt> pt vect
%type <type_pt_list> pt_list pt_arrow_list
%type <type_pt3> vectn range
%type <type_pt3_list> vectn_list vars_in_ranges dest_list
%type <type_dopt> dopt
%type <type_dir> dir

%left '+' '-'
%left '*' '/'
%left '%'

/* règle BNF principale */
%start labyrinth

%%

labyrinth
	: suite_declaration size_initialization suite_instruction
	| size_initialization suite_instruction
;

suite_declaration
	: suite_declaration declaration
	| declaration
;

declaration
	: ';'
	| IDENT '=' xcst ';' {
			vars_chgOrAddEated(gl_pdt->vars, $1, $3);
		}
	| IDENT '+' '=' xcst ';' {
			Tvar *v = NULL;
			if ((v = vars_get(gl_pdt->vars, $1)))
				v->val += $4;
			else
				yyerror("%s undefined", $1);
		}
	| IDENT '-' '=' xcst ';' {
			Tvar *v = NULL;
			if ((v = vars_get(gl_pdt->vars, $1)))
				v->val -= $4;
			else
				yyerror("%s undefined", $1);
		}
	| IDENT '*' '=' xcst ';' {
			Tvar *v = NULL;
			if ((v = vars_get(gl_pdt->vars, $1)))
				v->val *= $4;
			else
				yyerror("%s undefined", $1);
		}
	| IDENT '/' '=' xcst ';' {
			Tvar *v = NULL;
			if ((v = vars_get(gl_pdt->vars, $1)))
				v->val /= $4;
			else
				yyerror("%s undefined", $1);
		}
	| IDENT '%' '=' xcst ';' {
			Tvar *v = NULL;
			if ((v = vars_get(gl_pdt->vars, $1)))
				v->val %= $4;
			else
				yyerror("%s undefined", $1);
		}

size_initialization
	: SIZE xcst ';' {
			int d = $2 + 1;

			if (d <= 0 || d > LDS_SIZE)
				yyerror("%dx%d: invalid size", d, d);
			else
				lds_size_set(gl_lds, d, d);
		}
	| SIZE xcst ',' xcst ';' {
			int dx = $2 + 1;
			int dy = $4 + 1;

			if (dx <= 0 || dx > LDS_SIZE || dy <= 0 || dy > LDS_SIZE)
				yyerror("%dx%d: invalid size", $2, $4);
			else
				lds_size_set(gl_lds, dx, dy);
		}
;

suite_instruction
	: suite_instruction instruction
	| instruction
;

instruction
	: declaration
	| SHOW { lds_dump(gl_lds, stdout); }
	| IN pt ';' {
			if (lds_checkborder_pt(gl_lds, $2))
				yyerror("(%d,%d) must be on the border to be an input", $2.x, $2.y);
			else {
				gl_lds->squares[$2.x][$2.y].kind = LDS_IN;
				gl_lds->in = $2;
			}
		}
	| OUT pt_list ';' {
			for (int i = 0; i < $2->nb; ++i) {
				Tpoint pt = $2->t[i];
				if (lds_checkborder_pt(gl_lds, pt))
					yyerror("(%d,%d) must be on the border to be an output",  pt.x, pt.y);
				else
					gl_lds->squares[pt.x][pt.y].kind = LDS_OUT;
			}
		}
	| dopt ';' {
		Tpoint size = (Tpoint){gl_lds->dx, gl_lds->dy};
		for (int i = 0; i < size.x; ++i)
			for (int j = 0; j < size.y; ++j)
				lds_draw_xy(gl_lds, $1, i, j);
	}
	| dopt PTA pt_list ';' {
			lds_draw_pts(gl_lds, $1, $3);
			pts_free($3);
		}
	| dopt PTD pt ';'
	| dopt PTD pt vectn_list ';' {
		// @TODO
		pt3s_free($4);
	}
	| dopt R pt pt {
			Tpoint rectMin = (Tpoint){MIN($3.x, $4.x), MIN($3.y, $4.y)};
			Tpoint rectMax = (Tpoint){MAX($3.x, $4.x), MAX($3.y, $4.y)};

			for (int i = rectMin.x; i <= rectMax.x; ++i) {
				lds_draw_xy(gl_lds, $1, i, rectMin.y);
				lds_draw_xy(gl_lds, $1, i, rectMax.y);
			}

			for (int i = rectMin.y + 1 ; i < rectMax.y; ++i) {
				lds_draw_xy(gl_lds, $1, rectMin.x, i);
				lds_draw_xy(gl_lds, $1, rectMax.x, i);
			}
		}
	| dopt R F pt pt ';' {
			Tpoint rectMin = (Tpoint){MIN($4.x, $5.x), MIN($4.y, $5.y)};
			Tpoint rectMax = (Tpoint){MAX($4.x, $5.x), MAX($4.y, $5.y)};

			for (int i = rectMin.x; i < rectMax.x; ++i)
				for (int j = rectMin.y; j < rectMax.y; ++j)
					lds_draw_xy(gl_lds, $1, i, j);
		}
	| dopt FOR vars_in_ranges '(' expr ',' expr ')' ';' {

			/**************************************/
			/*********        TODO        *********/
			/**************************************/
		}
	| WH pt_arrow_list ';' {

			// @TODO VERIFIER S'IL Y A DEJA QQCH SUR LA CASE
			//       ET QUE LES POINTS SONT DIFFERENTS

			for (int i = 0; i < $2->nb - 1; ++i)
				pdt_wormhole_add(gl_pdt, $2->t[i], $2->t[i + 1]);
			
			pts_free($2);
		}
	| MD pt dest_list ';' {
			// @TODO VERIFIER S'IL Y A DEJA QQCH SUR LA CASE
			//       ET QUE LES POINTS SONT DIFFERENTS

			Tsqmd* sqmd = pdt_magicdoor_getcreate(gl_pdt, gl_lds, $2);

			for (int i = 0; i < $3->nb; ++i) {
				Tpoint3 pt3 = $3->t[i];

				sqmd = lds_sqmd_update(sqmd, pt3.z, pt3.xy);
			}

			pt3s_free($3);
		}
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
				yyerror("%s undefined", $1);
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
				yyerror("(%d:%d) is outside of the labyrinth", $2, $4);
			else
				$$ = (Tpoint){$2, $4};
		}
;

pt_list
	: pt_list pt { pts_app_pt(($$ = $1), $2); }
	| pt { $$ = pts_new_pt($1); }
;

pt_arrow_list
	: pt_arrow_list ARROW pt { pts_app_pt(($$ = $1), $3); }
	| pt ARROW pt {
			$$ = pts_new_pt($3);
			pts_app_pt($$, $1);
		}
;

vect
	: '(' xcst ',' xcst ')' { $$ = (Tpoint){$2, $4}; }
;

vectn
	: vect { $$ = (Tpoint3){$1, 1}; }
	| vect ':' xcst {
			if ($3 <= 0)
				yyerror("%d can't be negative or null", $3);
			else
				$$ = (Tpoint3){$1, $3};
		}
	| vect ':' '*' { $$ = (Tpoint3){$1, 0}; }
;

vectn_list
	: vectn_list vectn { pt3s_app_pt3(($$ = $1), $2); }
	| vectn { $$ = pt3s_new_p2z($1.xy, $1.z); }
;

range
	: '[' xcst ':' xcst ']' {
			if ($2 < $4)
				yyerror("Error: %d < %d", $2, $4);
			else 
				$$ = (Tpoint3){(Tpoint){$2, $4}, 1};
		}
	| '[' xcst ':' xcst ':' xcst ']' {
			if ($2 < $4 || $6 < 1)
				yyerror("Error: %d < %d or %d < 1", $2, $4, $6);
			else
				$$ = (Tpoint3){(Tpoint){$2, $4}, $6};
		}
	| '[' xcst ':' xcst '[' {
			if ($2 <= $4)
				yyerror("Error: %d <= %d", $2, $4);
			else
				$$ = (Tpoint3){(Tpoint){$2, $4 - 1}, 1};
		}
	| '[' xcst ':' xcst ':' xcst '[' {
			if ($2 <= $4 || $6 < 1)
				yyerror("Error: %d <= %d or %d < 1", $2, $4, $6);
			else
				$$ = (Tpoint3){(Tpoint){$2, $4 - 1}, $6};
		}
;

vars_in_ranges
	: IDENT IN range {
			vars_chgOrAddEated(gl_pdt->vars, $1, ($3.xy).x);
			$$ = pt3s_new_p2z($3.xy, $3.z);
		}
	| IDENT vars_in_ranges range {
			vars_chgOrAddEated(gl_pdt->vars, $1, ($3.xy).x);
			pt3s_app_pt3(($$ = $2), $3);
		}
;

dopt
	: WALL		{ $$ = LG_DrawWall;		}
	| UNWALL	{ $$ = LG_DrawUnwall;	}
	| TOGGLE	{ $$ = LG_DrawToggle;	}
;

dir
	: DIR {
			if (!strcmp($1, "N"))
				$$ = LG_WrNN;
			else if (!strcmp($1, "NE"))
				$$ = LG_WrNE;
			else if (!strcmp($1, "E"))
				$$ = LG_WrEE;
			else if (!strcmp($1, "SE"))
				$$ = LG_WrSE;
			else if (!strcmp($1, "S"))
				$$ = LG_WrSS;
			else if (!strcmp($1, "SW"))
				$$ = LG_WrSW;
			else if (!strcmp($1, "W"))
				$$ = LG_WrWW;
			else if (!strcmp($1, "NW"))
				$$ = LG_WrNW;
			else
				$$ = LG_WrUU;
		}
;

dest_list
	: dest_list dir pt { pt3s_app_p2z(($$ = $1), $3, $2); }
	| dir pt { $$ = pt3s_new_p2z($2, $1); }
;

%%

#include "labgen.yy.c"
#include "top.c"
