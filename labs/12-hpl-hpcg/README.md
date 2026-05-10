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

Note the ratio HPL_GFLOPS / HPCG_GFLOPS for your laptop. Then look up the same ratio for current Top500 systems (Frontier, Fugaku, El Capitan):

| System | HPL | HPCG | Ratio |
|---|---|---|---|
| Frontier | ~1100 PF | ~14 PF | ~75 |
| Fugaku   | ~440 PF  | ~16 PF | ~28 |
| El Capitan | ~1740 PF | ~17 PF | ~100 |

Fugaku has the **best HPCG** — exactly the workload Earth-Simulator-style architectures excel at. This is the empirical case that drives the "HPL is misleading" complaint about how the Top500 is reported.
