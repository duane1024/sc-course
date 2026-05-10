# Lab 12 — HPL vs. HPCG: peak vs. real

Run the two principal Top500 benchmarks and observe the gap.

## HPL (LINPACK)

Get HPL from netlib:

```bash
wget https://netlib.org/benchmark/hpl/hpl-2.3.tar.gz
tar -xzf hpl-2.3.tar.gz
cd hpl-2.3
# Edit Make.<arch> for your compiler/BLAS, then:
make arch=Linux_AMD64
cd bin/Linux_AMD64
mpirun -n 4 ./xhpl
```

HPL solves `Ax = b` for a dense `A`. Peaks of theoretical FLOPS are 80–95% achievable on tuned hardware.

## HPCG

```bash
git clone https://github.com/hpcg-benchmark/hpcg
cd hpcg
mkdir build && cd build
../configure Linux_MPI
make
mpirun -n 4 ./xhpcg
```

HPCG runs preconditioned conjugate gradient on a 3D sparse system. *Memory-bandwidth* and *latency* bound. Modern systems hit 1–5% of peak FLOPS.

## Compare

Note the ratio HPL_GFLOPS / HPCG_GFLOPS for your laptop. Then look up the same ratio for current Top500/HPCG systems. These public-list numbers change twice a year; the table below is a rough orientation, not a source of record:

| System | HPL | HPCG | Ratio |
|---|---|---|---|
| Frontier | ~1350 PF | ~14 PF | ~95 |
| Fugaku   | ~440 PF  | ~16 PF | ~28 |
| El Capitan | ~1800 PF | ~17 PF | ~100 |

Fugaku no longer has the highest absolute HPCG score on the current list, but its HPL/HPCG ratio remains unusually strong. That is the empirical case behind the "HPL is misleading" complaint: a system designed for memory bandwidth and application balance can look modest on HPL while staying highly competitive on a sparse, bandwidth-bound benchmark.
