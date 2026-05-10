# Era 1 — Scalar Fortran (CDC 6600, 1964)

Sequential loop, one element per iteration. Compiler does no vectorization (or, on a modern compiler, gets out of its way to compare).

## Build and run

```bash
gfortran -O0 -fno-tree-vectorize saxpy.f90 -o saxpy_scalar
./saxpy_scalar
```

`-O0 -fno-tree-vectorize` is *deliberate*: we want this to look like 1964 code on 1964 hardware, where the only parallelism comes from the scoreboard finding instruction-level parallelism between iterations. A modern compiler at `-O3` would happily vectorize this loop, defeating the demonstration. We disable that here so you can compare against Era 2.

## Why it's slow

Each iteration: one multiply, one add, two loads, one store. The CPU is doing exactly what the source says. Modern superscalar will overlap consecutive iterations (the same way the 6600 scoreboard did), but there's no SIMD-width amortization.
