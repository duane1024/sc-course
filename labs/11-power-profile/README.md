# Lab 11 — Profile your laptop's power

Measure joules per FLOP across three SAXPY implementations.

## On macOS

```bash
sudo powermetrics -i 1000 --samplers cpu_power &
PMID=$!
# now run benchmarks
python3 saxpy_python.py
./saxpy_c
./saxpy_omp
kill $PMID
```

## On Linux

```bash
# Install s-tui or powerstat
sudo apt-get install s-tui  # or powerstat
# Or read RAPL directly:
cat /sys/class/powercap/intel-rapl:0/energy_uj  # before
# run benchmark
cat /sys/class/powercap/intel-rapl:0/energy_uj  # after
# difference is microjoules consumed during run
```

## What to compute

For each implementation:

- Wall-clock time (T) in seconds
- FLOPs performed (2 × N for SAXPY)
- Energy (E) in joules during the run
- Joules per FLOP = E / FLOPs
- FLOPS per watt = FLOPs / (E during run)

Report the ratio between the slowest (Python) and fastest (OpenMP+SIMD) implementations. Typically 2–3 orders of magnitude. **This ratio is what drives every modern HPC architecture decision.**

## Why this matters

A modern Frontier-class machine spends ~30 MW. Every joule per FLOP saved by smarter implementation is a megawatt of operating cost over the system's life. Power, not silicon, is the constraint.
