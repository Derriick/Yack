%option noyywrap

%%


"NE"				{return NE ;}
"NW"				{return NW ;}
"SE"				{return SE ;}
"SW"				{return SW ;}


"N"				{return N ;}
"S"				{return S ;}
"E"				{return S ;}
"W"				{return S ;}

[ \t\n]					;
#.*\n ;
.							{ return *yytext; }
