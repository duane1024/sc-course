# Lab 02 — Annotated CAL listing vs. AVX-512

A read-and-annotate lab. We provide:

- `cal-saxpy.txt` — a Cray Assembly Language listing for SAXPY, annotated with what each line does.
- `avx512-saxpy.s` — the same kernel as compiled by `clang -O3 -march=skylake-avx512 -S` in 2026, annotated.

## Your job

For each instruction in the CAL listing, find its closest analog in the AVX-512 listing and write a one-line note describing the mapping. Some instructions translate cleanly (vector load → `vmovupd`); some don't translate at all (the implicit chaining is just "fused multiply-add as a single instruction"). Where there's no clean mapping, explain *why* — that's where the architectural difference lives.

You don't need a Cray-1 to do this lab. You just need to read carefully.
