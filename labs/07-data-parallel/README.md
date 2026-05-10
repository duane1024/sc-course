# Lab 07 — Data-parallel programming, NumPy as a Connection Machine emulator

Three implementations of Conway's Game of Life:

1. Imperative Python with explicit loops.
2. NumPy whole-array operations (the CM Fortran / `C*` idiom).
3. (Optional) CuPy or NumPy with `numba.cuda` for GPU.

## Run

```bash
python3 life.py
```

(Add `--gpu` to use CuPy if you have it installed.)

## What to observe

The NumPy version is shorter, runs faster (5–50× depending on hardware), and is the *direct descendant* of how you would have written this on a CM-2 in 1989. The same idiom — express the computation as whole-array updates, no inner loops — is what Hillis was selling and what Fortran 90 standardized.
