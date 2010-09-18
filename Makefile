all: tests

tests:
	gcc -framework Foundation -lffi --std=c99 main.m

clean:
	rm -f a.out
