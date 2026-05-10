# Lab 03 — Auto-vectorization on a Modern Compiler

Walk through six small loops, each chosen to exercise a different vectorizer behavior. Build with clang or gcc and read the optimization report.

## Build

```bash
make
```

Or directly:

```bash
clang -O3 -march=native -Rpass=loop-vectorize \
      -Rpass-missed=loop-vectorize -Rpass-analysis=loop-vectorize \
      -c loops.c
```

(GCC equivalent: `gcc -O3 -march=native -fopt-info-vec -fopt-info-vec-missed`.)

## What you'll see

For each loop, the compiler will emit one of:

- "vectorized loop (vectorization width: 8)" — success
- "loop not vectorized: ..." — and a reason

## Exercises

1. For each unsuccessful loop in `loops.c`, modify the source to make it vectorize. Common fixes: `restrict`-qualify pointers (loop 2), avoid the function call (loop 3), add `#pragma omp simd` to override the analysis (loop 4).
2. For loop 5 (the dot product), notice it auto-vectorizes today even though the reduction is a loop-carried dependency. Why? (Hint: `-ffast-math`, or `#pragma omp simd reduction(+:sum)`.)
3. Compile each loop with `-march=native` and look at the generated assembly with `clang -O3 -S`. Count the vector instructions. Compare to a CAL listing of the same kernel from the chapter — they should be structurally similar.
