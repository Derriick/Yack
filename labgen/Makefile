APP	= labgen
AUGE = auge/

YSRC = top.c
CSRC = expr.c
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

%.yy.c: %.l
	$(FLEX) $(FFLAGS) -o $@ $<

%.o: %.c %.yy.c
	$(CC) -o $@ -c $<

%.o: %.c %.h
	$(CC) $(CFLAGS) -o $@ -c $<

$(AUGE)%.o: $(AUGE)%.c $(AUGE)%.h
	$(CC) -o $@ -c $<

$(APP): $(APP).o $(COBJ) $(AUGE_OBJ)
	$(CC) -o $@ $^

clean:
	rm -rf $(APP) $(APP).c *.yy.c *.o $(AUGE)*.o *.output 2>/dev/null
