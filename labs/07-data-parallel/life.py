"""
Conway's Game of Life, two ways.
"""
import argparse
import time
import numpy as np

def life_step_loop(grid):
    n, m = grid.shape
    new = np.zeros_like(grid)
    for i in range(1, n-1):
        for j in range(1, m-1):
            s = (grid[i-1, j-1] + grid[i-1, j] + grid[i-1, j+1] +
                 grid[i, j-1]                  + grid[i, j+1] +
                 grid[i+1, j-1] + grid[i+1, j] + grid[i+1, j+1])
            if grid[i, j] == 1:
                new[i, j] = 1 if s in (2, 3) else 0
            else:
                new[i, j] = 1 if s == 3 else 0
    return new

def life_step_array(grid):
    """The Connection Machine / Fortran 90 idiom: whole-array operations."""
    n_neighbors = (
        np.roll(grid,  1, 0) + np.roll(grid, -1, 0) +
        np.roll(grid,  1, 1) + np.roll(grid, -1, 1) +
        np.roll(np.roll(grid,  1, 0),  1, 1) +
        np.roll(np.roll(grid,  1, 0), -1, 1) +
        np.roll(np.roll(grid, -1, 0),  1, 1) +
        np.roll(np.roll(grid, -1, 0), -1, 1)
    )
    return ((n_neighbors == 3) | ((grid == 1) & (n_neighbors == 2))).astype(np.uint8)

def time_steps(step_fn, grid, T):
    t0 = time.perf_counter()
    for _ in range(T):
        grid = step_fn(grid)
    return (time.perf_counter() - t0), grid

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--N", type=int, default=128)
    ap.add_argument("--T", type=int, default=50)
    args = ap.parse_args()

    rng = np.random.default_rng(0)
    grid = (rng.random((args.N, args.N)) > 0.7).astype(np.uint8)

    t_loop, _ = time_steps(life_step_loop, grid.copy(), args.T)
    t_arr,  _ = time_steps(life_step_array, grid.copy(), args.T)

    print(f"N={args.N}, T={args.T}")
    print(f"  Python loops:        {t_loop*1000:8.2f} ms")
    print(f"  Array ('C*' style):  {t_arr*1000:8.2f} ms   ({t_loop/t_arr:.1f}x)")
