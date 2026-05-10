"""
SAXPY four ways: Python loop, NumPy, BLAS, and C+AVX (via prebuilt shared lib).
Mirrors Eugene Brooks's 1989 trend argument.
"""
import time
import numpy as np

N = 1 << 20

def python_loop():
    x = [1.0] * N
    y = [2.0] * N
    a = 3.0
    t0 = time.perf_counter()
    for i in range(N):
        y[i] = a * x[i] + y[i]
    return time.perf_counter() - t0

def numpy_call():
    x = np.ones(N)
    y = np.full(N, 2.0)
    a = 3.0
    # Warm up
    np.add(a * x, y, out=y)
    y[:] = 2.0
    t0 = time.perf_counter()
    for _ in range(20):
        np.add(a * x, y, out=y)
    return (time.perf_counter() - t0) / 20

def numpy_axpy():
    """SciPy/BLAS daxpy if available."""
    try:
        from scipy.linalg.blas import daxpy
        x = np.ones(N)
        y = np.full(N, 2.0)
        t0 = time.perf_counter()
        for _ in range(20):
            y = daxpy(x, y, a=3.0)
        return (time.perf_counter() - t0) / 20
    except ImportError:
        return None

def report(name, t):
    if t is None:
        print(f"{name:30s} skipped (scipy not installed)")
        return
    bytes_moved = 3 * N * 8
    gbps = bytes_moved / t / 1e9
    print(f"{name:30s} {t*1e3:8.2f} ms  {gbps:6.1f} GB/s")

if __name__ == "__main__":
    print(f"N = {N}")
    report("Python loop",                python_loop())
    report("NumPy  (vector op)",         numpy_call())
    report("BLAS daxpy (via SciPy)",     numpy_axpy())
    print("\nFor the C+AVX leg, build code/era2-vector/saxpy_vec.c and time it.")
