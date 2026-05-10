#!/usr/bin/env python3
"""SAXPY on Apple Silicon using MLX.

MLX uses Apple's GPU backend when available. This version uses float32, which
is the practical fast path for Apple GPU arithmetic.
"""

import argparse
import time

import mlx.core as mx


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--n", type=int, default=1 << 24)
    args = parser.parse_args()

    n = args.n
    x = mx.ones((n,), dtype=mx.float32)
    y = mx.full((n,), 2.0, dtype=mx.float32)
    a = mx.array(3.0, dtype=mx.float32)
    mx.eval(x, y, a)

    warmup = a * x + y
    mx.eval(warmup)

    start = time.perf_counter()
    result = a * x + y
    mx.eval(result)
    elapsed = time.perf_counter() - start

    max_error = mx.max(mx.abs(result - 5.0))
    mx.eval(max_error)

    bytes_moved = 3 * n * 4
    gbps = bytes_moved / elapsed / 1e9
    print(f"N={n}, time={elapsed * 1e3:.3f} ms, {gbps:.1f} GB/s")
    print(f"max error = {float(max_error.item()):g}")


if __name__ == "__main__":
    main()
