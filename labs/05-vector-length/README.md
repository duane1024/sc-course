# Lab 05 — Long vectors vs. short vectors

Show empirically why the Cray-1 sweet spot was vectors of 64, the NEC SX sweet spot was vectors of 256+, and modern CPU SIMD is happy with vectors of 8.

## Run

```bash
python3 vector_length.py
```

The script benchmarks a SAXPY-equivalent operation in NumPy across vector lengths from 1 to 1,000,000, reports throughput per length, and plots the curve.

## What you should see

A curve with three regimes:

1. Tiny lengths (< 64): Python and NumPy call overhead dominates; throughput is low.
2. Medium lengths (64 – 100,000): the SIMD/cache region; throughput is high and roughly flat.
3. Large lengths (> 1,000,000): exceeds last-level cache; throughput drops to DRAM bandwidth.

Each historical machine had a "sweet spot" along this curve. Map the named machines from Week 5 onto the curve.
