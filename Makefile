CFLAGS=-Wall -DYY_DEBUG=1 -g

all: pvip

pvip: libpvip.a src/main.c src/commander.o
	gcc $(CFLAGS) -o pvip src/commander.o src/main.c libpvip.a

libpvip.a: src/gen.pvip.y.o src/pvip.h src/pvip_node.o src/gen.node.o src/pvip_string.o
	ar rsv libpvip.a src/gen.pvip.y.o src/pvip_node.o src/gen.node.o src/pvip_string.o

test: pvip
	prove -lr t

.c.o: src/pvip.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/main.o: src/pvip.h
src/pvip_node.o: src/pvip.h

src/gen.node.c: build/node.pl src/pvip.h
	perl build/node.pl

src/gen.pvip.y.c: src/pvip.y src/pvip.h src/gen.node.c
	../greg/greg -o src/gen.pvip.y.c src/pvip.y

clean:
	rm -f src/*.o src/gen.* pvip libpvip.a

.PHONY: all test

