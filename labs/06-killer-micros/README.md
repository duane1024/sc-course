# Lab 06 — Replay the killer-micro crossover

Plot the Eugene-Brooks 1989 chart on your laptop. Compare four implementations of SAXPY:

1. Pure Python loop (proxy: 1980-ish unoptimized).
2. NumPy (proxy: vectorized commodity microprocessor of the 1990s).
3. NumPy with explicit BLAS (proxy: hand-tuned scientific library).
4. Optional compiled C/SIMD using `code/era2-vector/saxpy_vec.c` (proxy: modern microprocessor).

## Run

```bash
python3 killer_micros.py
```

The script reports time and GB/s for each Python/NumPy implementation at fixed problem size, plus a pointer to the optional compiled C/SIMD comparison.

## What to compare

The ratios you observe — typically 100×–1000× between the slowest and fastest — are the same ratios that drove the cluster-of-microprocessors victory in 1995. Today the same exponential is closing the gap between CPU SIMD and GPU SIMT.
