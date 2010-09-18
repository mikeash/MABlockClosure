all: tests

tests:
	gcc -framework Foundation -lffi --std=c99 -g main.m MABlockClosure.m

clean:
	rm -f a.out
