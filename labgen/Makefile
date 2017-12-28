APP	= labgen
SRC	= my_labgen.c
AUGE = auge/

AUGE_SRC = $(wildcard $(AUGE)*.c)
AUGE_OBJ = $(AUGE_SRC:.c=.o)

CC		= gcc
CFLAGS	= -Wall -Wextra -pedantic
YACC	= bison
YFLAGS	= -v
FLEX	= lex
FFLAGS	=

all: $(APP)

%.c: %.y $(SRC)
	$(YACC) $(YFLAGS) -o $@ $<

%.yy.c: %.l
	$(FLEX) $(FFLAGS) -o $@ $<

%.o: %.c %.yy.c
	$(CC) $(CFLAGS) -o $@ -c $<

$(AUGE)%.o: $(AUGE)%.c $(AUGE)%.h
	$(CC) $(CFLAGS) -o $@ -c $<

$(APP): $(APP).o $(AUGE_OBJ)
	$(CC) -o $@ $^

clean:
	rm -rf $(APP) $(APP).c *.yy.c *.o $(AUGE)*.o *.output 2>/dev/null
