# Lab 15 — Virtual datacenter on your laptop

Same Docker setup as Lab 10, but extended:

- 4 compute nodes
- 1 head node with Slurm controller
- 1 monitoring node running Grafana + Prometheus

## Run

```bash
docker compose up -d
docker exec -it headnode bash
sbatch -N 4 hello.sbatch     # submit a multi-node job
```

In a browser, open Grafana at `http://localhost:3000` (credentials `admin`/`admin`) and look at the per-node CPU and memory dashboards.

## Exercises

1. Submit a long-running MPI job (`heat1d 100_000_000 10000`). Watch the per-node CPU utilization in Grafana while it runs. You should see all 4 nodes light up evenly.
2. Kill one of the compute containers mid-job: `docker stop node03`. Observe what happens to the MPI job (it should fail; one rank dies). This is the basic exascale failure mode — you have to checkpoint, or the job dies on first hardware glitch.
3. Restart `node03`, resubmit. Add a wall-clock budget to your sbatch script. Welcome to the operations side of HPC.

## Why this lab matters

You can't run on Frontier from your laptop. But you can experience, in miniature, what an HPC site operations team does in production: scheduling, monitoring, fault response. The architecture is the same; only the scale differs.
