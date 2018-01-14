#include <stdlib.h>

#include "auge/top.h"
#include "auge/expr.h"

/*====== TEMPORAIRE ======*/
#include <stdbool.h>
#include <assert.h>
#define UNUSED(x) (void)(x)
/*========================*/

Texpr* expr_cst(int cst)
{
	Texpr* expr = malloc(sizeof(*expr));

	expr->e_kd = EXPKD_CST;
	expr->e_lc = NULL;
	expr->e_rc = NULL;
	expr->e_cst = cst;

	return expr;
}

Texpr* expr_varCloned(Cstr var)
{
	Texpr* expr = malloc(sizeof(*expr));

	expr->e_kd = EXPKD_VAR;
	expr->e_lc = NULL;
	expr->e_rc = NULL;
	expr->e_var = u_strdup(var); // PAS SÛR DE ÇA !!!
	
	return expr;
}

Texpr* expr_varEated(char* var)
{
	Texpr* expr = malloc(sizeof(*expr));

	expr->e_kd = EXPKD_VAR;
	expr->e_lc = NULL;
	expr->e_rc = NULL;
	expr->e_var = var;
	
	return expr;
}

Texpr* expr_uniOp(TexprKind kd, Texpr* child)
{
	Texpr* expr = malloc(sizeof(*expr));

	expr->e_kd = kd;
	expr->e_lc = NULL;
	expr->e_rc = NULL;
	expr->e_child = child;
	
	return expr;
}

Texpr* expr_binOp(TexprKind kd, Texpr* lc, Texpr* rc)
{
	Texpr* expr = malloc(sizeof(*expr));

	expr->e_kd = kd;
	expr->e_lc = lc;
	expr->e_rc = rc;
	
	return expr;
}

void expr_free(Texpr* expr)
{
	if (expr->e_child)
		expr_free(expr->e_child);

	if (expr->e_lc)
		expr_free(expr->e_lc);

	if (expr->e_rc)
		expr_free(expr->e_rc);

	free(expr);
}

int expr_eval(const Texpr* expr, const Tvars* vars, int* val, Cstr* uv)
{
	UNUSED(*expr);
	UNUSED(*vars);
	UNUSED(*val);
	UNUSED(*uv);
	assert(false);
}
