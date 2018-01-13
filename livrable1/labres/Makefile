APP = labres1 labres2
SRC = my_labres.c labres.yy.c

CC = gcc
YACC = yacc
FLEX = lex

all: $(APP)

%: %.y $(SRC)
	$(YACC) -o $@.c $< -v
	$(CC) -o $@ $@.c

labres.yy.c: labres.l
	$(FLEX) -o $@ $<

clean:
	rm -rf $(APP) $(APP:=.c) *.yy.c *.o *.output 2>/dev/null