APP	= labgen
AUGE = auge/

YSRC = src/top.c
CSRC = src/expr.c
COBJ = $(CSRC:.c=.o)
AUGE_SRC = $(wildcard $(AUGE)*.c)
AUGE_OBJ = $(AUGE_SRC:.c=.o)

CC		= gcc
CFLAGS	= -Wall -Wextra
YACC	= bison
YFLAGS	= -v
FLEX	= lex
FFLAGS	=

all: $(APP)

%.c: %.y $(YSRC)
	$(YACC) $(YFLAGS) -o $@ $<

%.o: %.c %.h
	$(CC) $(CFLAGS) -o $@ -c $<

$(AUGE)%.o: $(AUGE)%.c $(AUGE)%.h
	$(CC) -o $@ -c $<

%.yy.c: %.l
	$(FLEX) $(FFLAGS) -o $@ $<

%.o: %.c %.yy.c
	$(CC) -o $@ -c $<

$(APP): $(APP).o $(COBJ) $(AUGE_OBJ)
	$(CC) -o $@ $^

clean:
	rm -rf $(APP) $(APP).c *.yy.c *.o src/*.o $(AUGE)*.o *.output labres.y labres.l 2>/dev/null
