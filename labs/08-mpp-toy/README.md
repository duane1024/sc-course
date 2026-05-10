# Lab 08 — Toy MPP simulator

A pure-Python simulation of a 16-node MPP. Each node has incoming/outgoing message queues. You implement halo exchange + a stencil computation across them.

## Run

```bash
python3 mpp_toy.py
```

The simulator reports:
- Total simulated cycles to complete the computation.
- Number of messages per node.
- Average message latency.

## Exercises

1. The default topology is a 4×4 mesh (each node has up to 4 neighbors). Modify `topology.py` to use a 4D hypercube instead. Re-run. The hypercube has higher node degree (4 neighbors per node) but a different distance distribution. Compare cycle counts.
2. Increase the per-message latency in `params.py` from 1 to 10 cycles. The stencil computation should slow down dramatically — but by less than 10×, because of compute/communication overlap. Quantify the overlap fraction.
