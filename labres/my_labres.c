void yyerror(const char *mess)
{
	return;
}

int main(int argc, char *argv[])
{
	FILE *f = NULL;
	int res;

	if (argc == 2) {
		if ((f = fopen(argv[1], "r")) == NULL) {
			fprintf(stderr, "%s: %s\n", argv[1], strerror errno);
			exit(1);
		}

		yyin = f;
	}
	else if (argc != 1) {
		fprintf(stderr, "Usage: %s [file]\n", argv[0]);
		exit(1);
	}

	res = yyparse();

	if (f)
		fclose(f);

	printf("%d\n", res);

	if (!res)
		printf("gagné\n");
	else
		printf("perdu\n");

	return res;
}