CC = mpicc
CFLAGS = -O3 -march=native -Wall

all: heat1d

heat1d: heat1d.c
	$(CC) $(CFLAGS) $< -o $@ -lm

clean:
	rm -f heat1d
