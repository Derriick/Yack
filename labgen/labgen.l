%option noyywrap
%option yylineno

%%

#.*\n												;
[0-9]+												{	return CNUM;	}
"SIZE"												{	return SIZE;	}
"IN"												{	return IN;		}
"SHOW"												{	return SHOW;	}
"WALL"												{	return WALL;	}
"UNWALL"											{	return UNWALL;	}
"TOGGLE"											{	return TOGGLE;	}
"PTA"												{	return PTA;		}
"PTD"												{	return PTD;		}
"R"													{	return R;		}
"F"													{	return F;		}
"FOR"												{	return FOR;		}
"WH"												{	return WH;		}
"MD"												{	return MD;		}
"NE" | "NW" | "SE" | "SW" | "N" | "S" | "E" | "W"	{	return DIR;		}
-+>													{	return ARROW;	}
[a-zA-Z][a-zA-Z0-9]*								{	return IDENT;	}
[ \t\n]												;
.													{	return *yytext;	}
