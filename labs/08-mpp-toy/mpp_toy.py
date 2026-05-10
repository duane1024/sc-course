"""
A miniature MPP simulator.

16 nodes arranged in a 4x4 mesh; each runs the same stencil on its slice
of a 1D domain (halo exchange to nearest mesh neighbors, just left/right).
Messages take MSG_LATENCY cycles to traverse one link.
"""
from collections import defaultdict
import math

GRID_X = 4
GRID_Y = 4
N_NODES = GRID_X * GRID_Y
SLICE_SIZE = 100
TIMESTEPS = 50
MSG_LATENCY = 1
COMPUTE_PER_CELL = 1

def neighbors(rank):
    """Mesh neighbors (left/right of each row, ignoring rows for simplicity)."""
    x = rank % GRID_X
    y = rank // GRID_X
    nbrs = []
    if x > 0: nbrs.append(y * GRID_X + (x - 1))
    if x < GRID_X-1: nbrs.append(y * GRID_X + (x + 1))
    return nbrs

class Node:
    def __init__(self, rank):
        self.rank = rank
        self.data = [float(rank)] * SLICE_SIZE
        self.halo_left = 0.0
        self.halo_right = 0.0
        self.inbox = []  # list of (arrival_cycle, payload, src)

def main():
    nodes = [Node(r) for r in range(N_NODES)]
    cycle = 0
    msgs_sent = 0

    for t in range(TIMESTEPS):
        # Send halo updates to left/right
        for n in nodes:
            for nbr in neighbors(n.rank):
                payload = n.data[0] if nbr < n.rank else n.data[-1]
                arrival = cycle + MSG_LATENCY
                nodes[nbr].inbox.append((arrival, payload, n.rank))
                msgs_sent += 1

        cycle += MSG_LATENCY  # simulate transit

        # Receive halos
        for n in nodes:
            ready = [m for m in n.inbox if m[0] <= cycle]
            n.inbox = [m for m in n.inbox if m[0] > cycle]
            for arr, payload, src in ready:
                if src < n.rank: n.halo_left = payload
                else:            n.halo_right = payload

        # Compute (stencil): one cycle per cell
        for n in nodes:
            new = [0.0] * SLICE_SIZE
            for i in range(SLICE_SIZE):
                left  = n.halo_left  if i == 0             else n.data[i-1]
                right = n.halo_right if i == SLICE_SIZE-1  else n.data[i+1]
                new[i] = 0.25 * left + 0.5 * n.data[i] + 0.25 * right
            n.data = new
        cycle += SLICE_SIZE * COMPUTE_PER_CELL

    print(f"Total simulated cycles: {cycle}")
    print(f"Messages sent: {msgs_sent}")
    print(f"Avg messages per node per timestep: {msgs_sent / N_NODES / TIMESTEPS:.2f}")

if __name__ == "__main__":
    main()
