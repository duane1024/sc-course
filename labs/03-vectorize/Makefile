CC ?= clang
CFLAGS = -O3 -march=native -Rpass=loop-vectorize -Rpass-missed=loop-vectorize -Rpass-analysis=loop-vectorize

all: loops.o

loops.o: loops.c
	$(CC) $(CFLAGS) -c $< -o $@

asm: loops.c
	$(CC) -O3 -march=native -S $< -o loops.s

clean:
	rm -f loops.o loops.s
