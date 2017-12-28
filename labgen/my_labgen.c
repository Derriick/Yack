/*void yyerror(const char *mess)
{
	fprintf(stderr, "file:%d: %s (near %s)\n", yylineno, mess, yytext);
	exit(1);
}*/

extern void yyerror(const char* fmt, ...)
{
	char buf[10000];
	va_list ap;

	va_start(ap, fmt);
	vsprintf(buf, fmt, ap);
	va_end(ap);

	fprintf(stderr, "%s:%d: %s (near %s)\n", gl_infname, yylineno, buf, yytext);
	exit(1);
}

/*int main(int argc, char *argv[])
{
	FILE *f = NULL;
	int res;

	if (argc == 1) {
	return yyparse();
	}
	else if (argc > 1 && argc <= 3) {
		if (!strcmp(argv[1], "-")) {
			return yyparse();
		}
		else {
			if ((f = fopen(argv[1], "r")) == NULL) {
				fprintf(stderr, "%s: %s\n", argv[1], strerror errno);
				exit(1);
			}

			if (argc == 3) {
				printf("3e argument utilisé pour changer le nom de l'exécutable généré -> pas encore implémenté\n");
			}

			yyin = f;
			res = yyparse();

			if (!res)
				printf("Correct syntax\n");

			fclose(f);

			return res;
		}
	}
	else {
		fprintf(stderr, "Usage: %s [file] [exe]\n", argv[0]);
		exit(1);
	}
}*/
