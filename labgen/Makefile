APP = labgen

CC = gcc
YACC = yacc
FLEX = lex

all: $(APP)

%: %.y %.l
	$(YACC) -o $@.c $< -v
	$(FLEX) -o $@.yy.c $(word 2, $^)
	gcc -o $@ $@.c

clean:
	rm -rf $(APP) *.c *.o y.output 2>/dev/null