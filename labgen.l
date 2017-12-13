%option noyywrap

%%

[0-9]+					{ yylval = atoi(yytext); return CNUM; }
[a-zA-Z][0-9a-zA-Z]*	{ return IDENT;		}
"SIZE"					{ return tk_SIZE;		}
"IN"						{ return tk_IN;		}
"OUT"						{ return tk_OUT;		}
"SHOW"					{ return tk_SHOW;		}
"WALL"					{ return tk_WALL;		}
"PTA"						{ return tk_PTA;		}
"PTD"						{ return tk_PTD;		}
"TOGGLE"					{ return tk_TOGGLE;	}
"R"						{ return tk_R;			}
"F"						{ return tk_F;			}
"FOR"						{ return tk_FOR;		}
"#"						{ return tk_SHARP;	}

[\t\n]					;

.							{ return *yytext; }
