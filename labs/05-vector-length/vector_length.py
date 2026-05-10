"""
SAXPY throughput as a function of vector length.

Demonstrates the three regimes: call-overhead-dominated tiny vectors,
SIMD-cache-resident medium vectors, and DRAM-bound large vectors.
"""
import time
import numpy as np

def saxpy_np(x, y, a):
    np.add(np.multiply(a, x), y, out=y)

def benchmark(N, repeats=5, inner=200):
    x = np.ones(N, dtype=np.float64)
    y = np.full(N, 2.0, dtype=np.float64)
    a = 3.0
    # Warm up
    for _ in range(3):
        saxpy_np(x, y, a)
    best = float("inf")
    for _ in range(repeats):
        t0 = time.perf_counter()
        for _ in range(inner):
            saxpy_np(x, y, a)
        t1 = time.perf_counter()
        best = min(best, (t1 - t0) / inner)
    bytes_per_call = 3 * N * 8     # 2 reads + 1 write per element
    gbps = bytes_per_call / best / 1e9
    return best, gbps

if __name__ == "__main__":
    print(f"{'N':>10s} {'time(s)':>12s} {'GB/s':>10s}")
    for N in (1, 8, 64, 256, 1024, 8192, 65_536, 524_288, 4_194_304, 33_554_432):
        # Adjust inner repeats so total work is comparable
        inner = max(1, 1_000_000 // max(N, 1))
        t, gbps = benchmark(N, repeats=3, inner=inner)
        print(f"{N:10d} {t:12.3e} {gbps:10.2f}")
