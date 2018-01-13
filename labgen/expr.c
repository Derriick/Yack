#include "auge/top.h"
#include "auge/expr.h"

/*====== TEMPORAIRE ======*/
#include <stdbool.h>
#include <assert.h>
#define UNUSED(x) (void)(x)
/*========================*/

Texpr* expr_cst(int cst)
{
	UNUSED(cst);
	assert(false);
}

Texpr* expr_varCloned(Cstr var)
{
	UNUSED(var);
	assert(false);
}

Texpr* expr_varEated(char* var)
{
	UNUSED(*var);
	assert(false);
}

Texpr* expr_uniOp(TexprKind kd, Texpr* child)
{
	UNUSED(kd);
	UNUSED(*child);
	assert(false);
}

Texpr* expr_binOp(TexprKind kd, Texpr* lc, Texpr* rc)
{
	UNUSED(kd);
	UNUSED(*lc);
	UNUSED(*rc);
	assert(false);
}

void   expr_free(Texpr* expr)
{
	UNUSED(*expr);
	assert(false);
}

int expr_eval(const Texpr* expr, const Tvars* vars, int* val, Cstr* uv)
{
	UNUSED(*expr);
	UNUSED(*vars);
	UNUSED(*val);
	UNUSED(*uv);
	assert(false);
}
