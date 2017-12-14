%option noyywrap
%option yylineno

%%

[0-9]+					{ yylval = atoi(yytext); return CNUM; }
"SIZE"					{ return tk_SIZE;		}
"IN"						{ return tk_IN;		}
"OUT"						{ return tk_OUT;		}
"SHOW"					{ return tk_SHOW;		}
"WALL"					{ return tk_WALL;		}
"UNWALL"					{ return tk_UNWALL;	}
"TOGGLE"					{ return tk_TOGGLE;	}
"PTA"						{ return tk_PTA;		}
"PTD"						{ return tk_PTD;		}
"R"						{ return tk_R;			}
"F"						{ return tk_F;			}
"FOR"						{ return tk_FOR;		}
[a-zA-Z][a-zA-Z0-9]*	{ return IDENT;		}

[ \t\n]					;
#.*\n						;

.							{ return *yytext; }
