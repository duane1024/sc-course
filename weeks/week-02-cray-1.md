# Week 2 — The Cray-1 (1976): Vectors Become a Product

## Where we are in 2026

Open the assembly listing for any modern numerical kernel — a SAXPY loop compiled with `clang -O3` on an Apple M3, a CUDA kernel running on an H100, a chunk of NumPy's BLAS path. You will see the same architectural concept: a single instruction operating on a register that holds many values at once, fed by a memory subsystem deliberately designed to keep that register full.

The Cray-1 did not invent vector processing, but it made register-to-register vector execution the dominant commercial form.

## The Cray-1 in one breath

- **Year**: 1976. First customer: Los Alamos.
- **Clock**: 80 MHz (12.5 ns cycle) — three to four times faster than the fastest minicomputer of the era.
- **Peak**: 160 MFLOPS (one floating-point add and one multiply per cycle, fully chained).
- **Memory**: 1 megaword (8 MB), 16-way interleaved, 50 ns access — the bandwidth was as much of an engineering achievement as the CPU.
- **Registers**: 8 vector registers (64 elements × 64 bits each), 8 scalar registers, 8 address registers, plus banks of "T" and "B" intermediate registers.
- **Word**: 64-bit IEEE-ish floating point (Cray's format predated IEEE 754).
- **Cooling**: Liquid Freon piped through the metal frame between every PCB stack.
- **Form**: a 12-sided C-shaped tower, padded benches around it (the "love seat" hid the power supplies and made repair access easier). Five tons.
- **Price**: $8.8M in 1976. Roughly $48M in 2026 dollars.

Around 80 Cray-1s were ever built. Most are in museums. One sits in the Computer History Museum in Mountain View, eerily quiet, no Freon left to circulate.

## The four ideas that made it fast

### 1. Vector registers

Before the Cray-1, "vector" computers — like the [**CDC STAR-100**](https://link.springer.com/chapter/10.1007/978-1-4615-7957-1_5) (1974) and [**Texas Instruments ASC**](https://dl.acm.org/doi/10.1109/2.19823) (1973) — operated on vectors **memory-to-memory**. You issued an instruction that said "add elements of array A starting at address α to array B starting at address β, store at γ, length N." The hardware streamed values through a pipelined adder. Conceptually clean. In practice, *terrible*, because every vector operation paid the full memory-access latency on its first element. Short vectors were dramatically slower than scalar code. Real scientific codes have lots of short vectors.

Cray's insight: keep a small number of vectors *resident in registers*, fast-cycle them through the functional units, and fill them from memory in advance. Every Cray vector operation is **register-to-register**. The startup cost of a vector instruction was still real — measured in several cycles depending on the functional unit — but it was small enough that short vectors became profitable. The Cray-1's break-even vector length was a handful of elements, not the dozens needed on memory-to-memory machines like the STAR-100.

The eight vector registers (V0–V7) each held 64 elements of 64 bits each. That's 4 KB of vector register file, in 1976, in ECL.

_ECL = Emitter-Coupled Logic — a family of bipolar transistor logic circuits known for very high switching speed (the transistors stay out of saturation, so they switch faster than TTL or CMOS of the era)._ ECL was fast but power-hungry and ran hot, which is why Cray-1 famously needed its Freon-cooled cooling system.

### 2. Vector chaining

Suppose you write:

```
V2 = V0 + V1   ; vector add
V3 = V2 * V4   ; vector multiply
```

A naïve implementation runs the add through the adder unit (64 cycles to drain a full vector pipe), waits for V2 to be fully written, then runs the multiply. 128 cycles total.

The Cray-1 **chains** the multiply onto the add: the moment the first element of V2 emerges from the adder, it is forwarded directly into the multiplier as input — the multiplier does not wait for V2 to fully exist. Both pipelines run concurrently. About 64 + a few cycles total, and you've doubled throughput. Chain three operations and you've tripled it.

This is *why* the Cray-1 hit 160 MFLOPS peak rather than 80 — chained multiply-add ran at 2 floating-point ops per cycle.

This is also why "fused multiply-add" (FMA) appears on every modern CPU: it's the chaining idea, hardened into a single instruction. Same throughput target, fewer ports needed.

### 3. Interleaved memory

Vector registers are useless if you can't fill them. The Cray-1's memory was divided into **16 independent banks**. A vector load with stride 1 hit each bank in turn, so you could sustain one element per cycle as long as your stride didn't collide. Stride-2, stride-4, stride-8, stride-16 — depending on which one you hit, you'd hit a hot bank and stall. (This is why a great deal of Cray-era performance tuning was about *padding arrays* so that critical strides didn't alias to the same bank.)

Modern DRAM is still organized in banks. The technique of interleaved access to overlap memory cycles is the same.

### 4. Ruthless simplicity

The Cray-1 had no virtual memory, no memory protection, no caches (vector registers *were* the cache), no I/O on the central CPU (a separate "I/O Subsystem", later "IOS-V", handled all that), and no microcode (every instruction was a hardwired state machine). The ECL gates Cray used for the logic were among the fastest of the era, but only because the design was simple enough to wire densely. The C-shape was about wire length: no two PCBs in the central pipeline were further than four feet apart, because at 80 MHz a signal travels less than 12 feet per cycle in copper and Cray needed margin.

When asked years later about the C-shape, Cray said: "The bookcases worked out the right shape, and we built around them." That was probably a joke. Probably.

## What the code looked like — CAL

CAL is the Cray Assembly Language. Here is SAXPY (`y = a*x + y`) for vectors of 64 elements, register-to-register:

```text
        VL      A1            ; vector length := scalar A1 (= 64)
        V0      ,A2,1         ; load V0 from memory starting at A2, stride 1  (this is x)
        V1      ,A3,1         ; load V1 from memory starting at A3, stride 1  (this is y)
        V2      S1*V0         ; V2 := scalar S1 * V0                          (a * x), scalar-vector multiply
        V1      V1+V2         ; V1 := V1 + V2                                  (y + a*x)
        ,A3,1   V1            ; store V1 back to memory at A3, stride 1
```

Six instructions for what would be a 64-iteration loop in scalar code. The chaining is implicit: the second-to-last instruction ("V1+V2") starts as soon as the first element of V2 emerges from the multiplier — the assembler knows the dependency, the hardware honors it.

Notice what's *not* there: no loop counter, no branch, no induction-variable update. The loop is gone. This is the source of the speedup, and it is exactly the same source of speedup you get on a modern CPU when the auto-vectorizer turns a `for` loop into a sequence of `vfmadd231ps` AVX-512 instructions — the loop overhead vanishes, the per-iteration work is amortized, and the memory subsystem can prefetch much more aggressively because the access pattern is statically known to the hardware.

For longer arrays you **strip-mine**: outer loop in scalar code, inner loop is one of these 64-element register-to-register sequences, with a clean-up tail for `N mod 64`. We'll write this out in next week's lab.

## Why it won

- **Backward-compatible parallelism.** Cray-1 vector code was Fortran with vendor extensions, not a new language. A scientist's FORTRAN-IV from a CDC 7600 ran on the Cray-1 as scalar code, often *faster than the 7600* because the scalar pipeline was also better. Then they could add vectorization incrementally. This is exactly the dynamic that AVX-512 enjoys today.
- **Register-residency made short vectors profitable.** STAR-100 needed long vectors to break even with scalar code. Cray-1's break-even was a few elements for favorable operations, according to contemporary vector-processor analyses.
- **The bandwidth was real.** Many "vector" machines had peak FLOPS that no kernel ever sustained. The Cray-1 sustained 80–120 MFLOPS on real LINPACK code, not just peak math.

## Why it eventually lost

Two reasons, both for next week's chapter:

1. Cray himself moved on to multiprocessor designs (Cray-2, then Cray-3) and the X-MP team built an even more successful single-vendor lineage.
2. Microprocessors eventually got vector units of their own — first as multimedia extensions in the 1990s, then as serious SIMD in the 2000s. The bespoke ECL vector machine eventually couldn't justify its cost.

But that took twenty years. From 1976 to ~1995, the Cray-1's design philosophy *was* high-performance computing.

## Lab — Read a CAL listing

In `labs/02-cal-listing/`, you'll find an annotated CAL listing for a 1D stencil kernel and a corresponding modern AVX-512 listing for the same kernel. Your job is to map every Cray-1 instruction to its closest modern equivalent and identify what doesn't translate (and why). Two pages of code, an hour of work. The point is to make the lineage *physically obvious*.

## Discussion questions

1. The Cray-1 had no cache. Vector registers were used as a programmer-managed working set. What modern accelerator architecture also has no general-purpose cache and gives you programmer-managed scratch memory? What does that suggest about the relationship between caches and vector workloads?
2. The Cray-1 had 8 vector registers of 64 elements. Modern AVX-512 has 32 vector registers of 8 doubles each. Modern NVIDIA Tensor Cores work on 16×16 tiles. Why have register *widths* shrunk while register *counts* and *tile shapes* grew? (Hint: think about how compilers schedule independent operations.)
3. SAXPY in CAL is six instructions. SAXPY in modern AVX-512 hand-tuned assembly is roughly six instructions per 8-element block plus a strip-mining loop. Why did "do 64 elements at once" stop being the right register width? What does the answer have to do with branch prediction, OoO windows, and L1 cache?

## Further reading

- Russell, Richard M. (1978). ["The CRAY-1 Computer System"](https://dl.acm.org/doi/10.1145/359327.359336). *Communications of the ACM*. The canonical primary source. 10 pages, dense, beautiful.
- [*Cray-1 Computer System Hardware Reference Manual*](https://bitsavers.org/pdf/cray/CRAY-1/2240004C_CRAY-1_Hardware_Reference_Nov77.pdf), publication 2240004.
- Murray, Charles J. (1997). [*The Supermen: The Story of Seymour Cray and the Technical Wizards Behind the Supercomputer*](https://archive.org/details/supermenstory00murr), chapters 6–8.
- Hennessy & Patterson, [*Computer Architecture: A Quantitative Approach*](https://shop.elsevier.com/books/computer-architecture/hennessy/978-0-443-15406-5), Appendix G (Vector Processors). Cray-1 and CDC STAR-100 are the worked examples.
