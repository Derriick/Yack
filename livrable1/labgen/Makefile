APP = labgen
SRC = my_labgen.c labgen.yy.c

CC = gcc
YACC = yacc
FLEX = lex

all: $(APP)

%: %.y $(SRC)
	$(YACC) -o $@.c $< -v
	$(CC) -o $@ $@.c

labgen.yy.c: labgen.l
	$(FLEX) -o $@ $<

clean:
	rm -rf $(APP) $(APP:=.c) *.yy.c *.o *.output 2>/dev/null