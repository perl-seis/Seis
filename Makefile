CFLAGS = -g -Wall $(OFLAGS) $(XFLAGS)
OFLAGS = -O3 -DNDEBUG
#OFLAGS = -pg

OBJS = tree.o compile.o

all : leg

leg : leg.o $(OBJS)
	$(CC) $(CFLAGS) -o $@-new leg.o $(OBJS)
	mv $@-new $@

ROOT	=
PREFIX	= /usr/local
BINDIR	= $(ROOT)$(PREFIX)/bin

install : $(BINDIR)/leg

$(BINDIR)/% : %
	cp -p $< $@
	strip $@

uninstall : .FORCE
	rm -f $(BINDIR)/leg

leg.o : leg.c

leg.c : leg.leg
#	./leg -o $@ $<

clean : .FORCE
	rm -f *~ *.o *.leg.[cd]

spotless : clean .FORCE
	rm -f leg

.FORCE :
