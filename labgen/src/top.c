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
	int ret = 0;
	Tsquare* square = NULL;

	// RS-1 Le labyrinthe doit avoir au moins 2 lignes et au moins 2 colonnes.
	if (ds->dx <= 0 || ds->dx <= 0)
		ret = 1;
	
	// RS-2 Le labyrinthe doit avoir une et une seule entrée. Elle ne peut pas
	// 		être ni une sortie ni une entrée d’un trou de vers.
	// RS-3 Le labyrinthe doit avoir au moins une sortie. Elles ne peuvent pas
	// 		être ni l’entrée ni une entrée d’un trou de vers.
	// RS-4 L’entrée et les sorties du labyrinthe doivent se situer sur la pé-
	// 		riphérie du labyrinthe (x=0 ou y=0 ou x=COLONNEmax ou y=LIGNEmax )
	int nb_in = 0;
	int nb_out = 0;

	for (int i = 0; i < ds->dx; ++i) {
		for (int j = 0; j < ds->dy; ++j) {
			square = &ds->squares[i][j];

			switch(square->kind) {
				case LDS_WALL:
					
					break;
				case LDS_IN:
					nb_in++;

					if (square->opt == LDS_OptWH) {
						fprintf(stderr, "(%d:%d): Labyrinth input square can't be in a Wormhole (RS-2)\n", i, j);
						ret = 1;
					}

					if (i != 0 && i != ds->dx - 1 && j != 0 && j != ds->dy - 1) {
						fprintf(stderr, "(%d:%d): Labyrinth input square must be on a border (RS-4)\n", i, j);
						ret = 1;
					}

					break;
				case LDS_OUT:
					nb_out++;

					if (square->opt == LDS_OptWH) {
						fprintf(stderr, "(%d:%d): Labyrinth output squares can't be in a Wormhole (RS-2)\n", i, j);
						ret = 1;
					}

					if (i != 0 && i != ds->dx - 1 && j != 0 && j != ds->dy - 1) {
						fprintf(stderr, "(%d:%d): Labyrinth output squares must be on a border (RS-4)\n", i, j);
						ret = 1;
					}

					break;
				case LDS_FREE:
				default:
					break;
			}

			switch (square->opt) {
				case LDS_OptWH:
					if (square->sq_mdp != NULL) {
						fprintf(stderr, "(%d:%d): A Wormhole input can't be a Magic Door (RS-9)\n", i, j);
					}
					break;
				case LDS_OptMD:
					// if (square->sq_whd != NULL) {
					// 	fprintf(stderr, "(%d:%d): A Magic Door can't be a Wormhole input (RS-9)\n", i, j);
					// }
					break;
				default:
					break;
			}
		}
	}
	
	if (nb_in != 1) {
		fprintf(stderr, "Labyrinth must have one input square (RS-2)\n");
		ret = 1;
	}
	if (nb_out < 1) {
		fprintf(stderr, "Labyrinth must have at least one output square (RS-2)\n");
		ret = 1;
	}
	

	// RS-10 Il ne doit pas y avoir de boucle infinie dans les trous de vers.
	// 		WH (0,0) –> (0,1) –> (0,0); # ou
	// 		WH (0,1) –> (0,0); WH (0,0) –> (0,1);
	
	
	// RS-11 Les instructions de définition de l’entrée, des sorties, des trous de
	// 		vers et des portes magiques sont interprétées dans n’importe quel
	// 		ordre après la dernière instruction de tracé.
	// 		Si une entrée ou une sortie de ces instructions est un mur, le mur
	// 		est supprimé avec un message d’attention (warning).

	return ret;
}

int write_template(char* filename, FILE* output_stream)
{
	FILE* file = NULL;
	char* buf = NULL;
	size_t len = 0;

	if ( !(file = fopen(filename, "r")) ) {
		fprintf(stderr,"Error: can not open %s file for reading: %s\n", filename, strerror(errno));
		return 1;
	}

	while (getline(&buf, &len, file) != -1) {
		fprintf(output_stream, "%s", buf);
	}

	fclose(file);
	free(buf);

	return 0;
}

Twr get_wr(int i, int j)
{
	switch (i) {
		case 0:
			switch (j) {
				case 0:
					return LG_WrNW;
				case 1:
					return LG_WrNN;
				case 2:
					return LG_WrNE;
			}
		case 1:
			switch (j) {
				case 0:
					return LG_WrWW;
				case 1:
					return LG_WrUU;
				case 2:
					return LG_WrEE;	
			}
		case 2:
			switch (j) {
				case 0:
					return LG_WrSW;
				case 1:
					return LG_WrSS;
				case 2:
					return LG_WrSE;
			}
		default:
			return LG_WrUU;
	}
}

int lg_gen(Tlds* ds, FILE* lstream, FILE* ystream, Cstr lcfname)
{
	char* lex_temp = strdup("src/lex_template");
	char* yacc_temp1 = strdup("src/yacc_template1");
	char* yacc_temp2 = strdup("src/yacc_template2");

	if (write_template(lex_temp, lstream))
		return 1;

	if (write_template(yacc_temp1, ystream))
		return 1;

	Tpoint pt_in = ds->in;

	fprintf(ystream, "\n%%start cell_%d_%d\n\n%%%%\n\n", pt_in.x, pt_in.y);

	Tsquare sq;
	Tsquare sq2;
	Tsquare sq3;
	char* card[3][3] = {{"NW", "N", "NE"},
						{ "W",  "",  "E" },
						{"SW", "S", "SE"}};

	for (int i = 0; i < ds->dx; ++i)
		for (int j = 0; j < ds->dy; ++j) {
			char sep = '|';

			sq = ds->squares[i][j];

			if (sq.kind == LDS_OUT) {
				fprintf(ystream, "cell_%d_%d\n\t: { return 0; }\n;\n\n", i, j);
			}
			else if (sq.kind != LDS_WALL) {
				fprintf(ystream, "cell_%d_%d\n\t:\n", i, j);
				for (int i2 = 0; i2 <= 2; ++i2)
					for (int j2 = 0; j2 <= 2; ++j2) {
						int x = i + i2 - 1;
						int y = j + j2 - 1;
						if (sq.opt == LDS_OptMD) {
							Tsqmd* sqmd = sq.sq_mdp;
							Twr wr = get_wr(j2, i2);
							Tpoint dest = sqmd->t[wr].dest;
							if(!lds_check_xy (ds, dest.x, dest.y)){
								sq3 = ds->squares[dest.x][dest.y];
								if(sq3.kind != LDS_WALL && (dest.x != x || dest.y != y)){
									fprintf(ystream, "\t%c %s cell_%d_%d\n", sep, card[j2][i2], dest.x, dest.y);
								}
							}
						}
						if ((i2 != 1 || j2 != 1) &&	x >= 0 && x < ds->dx &&	y >= 0 && y < ds->dy)
						{
							sq2 = ds->squares[x][y];
							if (sq2.kind != LDS_WALL) {								
								if (sq2.opt == LDS_OptWH) {
									// const Tpoint* dest = pdt_wormhole_dest(gl_pdt, (Tpoint){x, y});
									// if (!dest)
									// 	assert(false);
									// x = dest->x;
									// y = dest->y;

									Tpoint dest = sq2.sq_whd;

									fprintf(ystream, "\t%c %s cell_%d_%d\n", sep, card[j2][i2], dest.x, dest.y);
								}
								else if ((i2+j2)%2 == 0) {
									if (ds->squares[x][j].kind != LDS_WALL ||
										ds->squares[i][y].kind != LDS_WALL)
									{
										fprintf(ystream, "\t%c %s cell_%d_%d\n", sep, card[j2][i2], x, y);
									}
								}
								else
									fprintf(ystream, "\t%c %s cell_%d_%d\n", sep, card[j2][i2], x, y);
								
								
							}	
												
						}
					}

				fprintf(ystream, ";\n\n");
			}

		}

	if (write_template(yacc_temp2, ystream))
		return 1;

	free(lex_temp);
	free(yacc_temp1);
	free(yacc_temp2);

	return 0;
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
