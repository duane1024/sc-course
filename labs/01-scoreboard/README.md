# Lab 01 — Tiny Scoreboard Simulator

A Python simulation of a CDC 6600-style scoreboard. You implement the issue/wait logic to enforce data dependencies between independent functional units (a multiplier, an adder, a load unit), then observe how throughput changes as you vary unit latencies.

## Run

```bash
python3 scoreboard.py
```

## Files

- `scoreboard.py` — the simulator. Reads a small instruction trace and executes it cycle-by-cycle. Today, the dependency-tracking is stubbed — you implement it.
- `programs/dot.txt` — a 6-instruction inner-product kernel.

## Your job

1. Read `scoreboard.py` end-to-end. The `step()` method has TODO markers where you'd insert hazard detection.
2. Implement the WAW (write-after-write), WAR (write-after-read), and RAW (read-after-write) checks.
3. Run on `programs/dot.txt` and report the cycle count.
4. Now change `MUL_LATENCY` from 4 to 10 and re-run. The cycle count should grow more than the total of the latency increases — explain why.

## Discussion in the chapter

Refer back to Week 1 — this is the architectural mechanism behind the 6600's 10× speedup over the IBM 7094.
