#include <stdarg.h>

/*====== TEMPORAIRE ======*/
#include <stdbool.h>
#include <assert.h>
#define UNUSED(x) (void)(x)
/*========================*/

void lg_sem0(Tlds* ds, const Tpdt* pdt)
{
	UNUSED(ds);
	UNUSED(pdt);
	assert(false);
}

int lg_sem(Tlds* ds, const Tpdt* pdt)
{
	UNUSED(ds);
	UNUSED(pdt);
	assert(false);
}

int lg_gen(Tlds* ds, FILE* lstream, FILE* ystream, Cstr lcfname)
{
	UNUSED(ds);
	UNUSED(lstream);
	UNUSED(ystream);
	UNUSED(lcfname);
	assert(false);
}

// It prints error messages like printf and then exits with 1 status
void yyerror(const char* fmt, ...)
{
	char buf[10000];
	va_list ap;

	va_start(ap, fmt);
	vsprintf(buf, fmt, ap);
	va_end(ap);

	fprintf(stderr, "%s:%d: %s (near %s)\n", gl_infname, yylineno, buf, yytext);
	exit(1);
}
