%option noyywrap

nombre [0-9]+
identifiant [a-zA-Z][0-9a-zA-Z]*

%%

{nombre} {
	return CNUM;
}

{identifiant} {
	return IDENT;
}

. return *yytext;
