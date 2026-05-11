# Week 1 — Before the Word: CDC 6600 and the Idea of "Fast"

## Where we are in 2026

When you write a tight loop in C and the compiler unrolls it, schedules independent instructions onto different functional units, and reorders memory loads to hide latency — you are using techniques that were invented for, and first proven on, the **CDC 6600** in 1964. Every modern out-of-order CPU is a direct descendant. Most of the things we now call "the boring parts of computer architecture" started life as Seymour Cray trying to make one specific machine the fastest in the world.

This week we look at the machine that defined what "fastest" meant before vectors existed.

## The world before the 6600

In the early 1960s, IBM ran scientific computing. Their flagship was the **7030 Stretch** (1961), a $7.8M behemoth with 64-bit words, a deep instruction pipeline, and a delivery slip so embarrassing that IBM cut the contracted price in half rather than ship a machine slower than promised. Stretch hit roughly 1.2 MIPS — fast for the era, but its pipeline hazards meant the worst-case throughput was a small fraction of peak. IBM's culture, post-Stretch, was deeply skeptical of pipeline aggressiveness.

Meanwhile in Chippewa Falls, Wisconsin, **Control Data Corporation** had set Seymour Cray loose with what amounted to a blank check and an order to build the fastest scientific computer in the world. Cray's design philosophy was already crystallized:

> "Anyone can build a fast CPU. The trick is to build a fast system."

He meant: simple, regular, fast logic, surrounded by I/O processors that kept the CPU fed. Cut anything that compromised peak throughput. Decimal arithmetic? Out. Microcode? Out. Multi-level interrupt systems? Out. Memory protection? Out (the 6600 ran one user job at a time — anything else was the I/O processors' problem).

## The CDC 6600 (1964)

- **Clock**: 10 MHz (100 ns cycle)
- **Word**: 60 bits
- **Memory**: 128 kilowords core, 1 µs cycle, ten-way interleaved banks
- **Functional units**: 10 independent units in the central processor — adder, multiplier, divider, shifter, boolean, branch, increment ×2, long-add. Each could start a new operation while others were still working.
- **Performance**: ~3 MFLOPS sustained, 10× the IBM 7094 it replaced.
- **Price**: $2.37M (roughly $24M in 2026 dollars).
- **Cooling**: Freon, in a plus-shaped cabinet.

The architectural masterstroke was **the scoreboard**, the world's first dynamic instruction scheduling mechanism. The scoreboard tracked which functional units were busy, which registers were being written, and which instructions could fire next without violating data dependencies. It was *dynamic, in-order issue with out-of-order completion* — exactly the design pattern that, twenty-five years later, the MIPS R10000 and IBM POWER1 would re-introduce as "out-of-order execution" and take credit for.

The 6600 also pioneered the **peripheral processor** model: ten little CPUs (the "barrel processor") cycled in lockstep, handling all I/O, OS calls, and disk access. The central CPU never touched a peripheral directly. This is why the 6600 felt so much faster than its raw clock implied — it was *never* stalled on I/O. Modern systems-on-chip with dedicated DMA engines, IOMMUs, and management controllers are doing the same thing.

When the 6600 shipped in 1964 and a CDC 6600 outran the IBM 7030 by 3×, IBM CEO Thomas Watson Jr. wrote his famous memo:

> "Last week, Control Data ... announced the 6600 system. I understand that in the laboratory developing the system there are only 34 people including the janitor... Contrasting this modest effort with our vast development activities, I fail to understand why we have lost our industry leadership position by letting someone else offer the world's most powerful computer."

Cray's reply: "It seems Mr. Watson has answered his own question."

## What the code looked like

The 6600 had a 60-bit instruction format, with 15- or 30-bit instructions packed into words. Programs were written in **FORTRAN II** or **COMPASS** (assembly). Here's a scalar inner product, FORTRAN II:

```fortran
      DIMENSION X(N), Y(N)
      S = 0.0
      DO 10 I = 1, N
        S = S + X(I) * Y(I)
   10 CONTINUE
```

There is no vector instruction here, and no parallelism that the programmer can see. But the compiler — and at runtime, the 6600's scoreboard — would happily issue the multiply for iteration `I` while the add for iteration `I-1` was still in flight on the adder unit. *That was the parallelism.* Within one loop iteration, the multiplier and adder ran concurrently. Across iterations, the scoreboard kept multiple operations in flight, limited only by data dependencies through `S` and by the memory subsystem's ability to deliver `X(I)` and `Y(I)`.

This is the model: **the programmer writes a sequential loop, and the hardware finds parallelism in the instruction stream.** It is the model that absolutely dominated the next thirty years of microprocessor design, and it is still how every Intel, AMD, ARM, and Apple CPU works today. Cray invented it.

## Why it won. Why it eventually lost.

The 6600 won because Cray's bet was right: scientific code spends most of its time in tight loops over arrays, those loops have lots of independent operations, and a smart instruction scheduler can extract that parallelism without burdening the programmer. The 6600 was the world's #1 computer for five years.

It lost — or rather, it was succeeded — because Cray figured out how to make the parallelism *explicit and amortized* with vector registers. That's the **CDC 7600** (1969, 36 MFLOPS) and the **Cray-1** (1976, 160 MFLOPS). Once you can issue one instruction that operates on 64 elements, you no longer need a scoreboard tracking dozens of in-flight scalar instructions to get the same throughput. You get it for free, with a much simpler control unit and far better memory bandwidth utilization.

We'll get there next week.

## Lab — Build a tiny scoreboard simulator

In `labs/01-scoreboard/`, you'll find a Python skeleton that simulates a simplified 6600 with three functional units (multiply, add, load). Your task: implement the scoreboarding logic so that independent instructions issue in parallel but data hazards stall correctly. Run it on the inner-product kernel and observe how throughput changes when you increase the multiplier latency or reduce the number of memory ports.

## Discussion questions

1. The 6600 had no virtual memory and no memory protection. Knowing this, what kind of operating system did it run? (Hint: SCOPE, then KRONOS. Look up the calling convention.) How does this constraint shape the entire system?
2. IBM's response to the 6600 was the System/360 Model 91 (1967), which used Tomasulo's algorithm for dynamic scheduling. Compare scoreboarding (CDC) to Tomasulo (IBM). Why did Tomasulo eventually win in microprocessors?
3. The 6600's peripheral processors were essentially ten cooperating "smaller computers" handling I/O. What 2026 SoC component is doing the same job?

## Further reading

- Thornton, J.E., [*Design of a Computer: The Control Data 6600*, 1970](https://archive.computerhistory.org/resources/text/CDC/cdc.6600.thornton.design_of_a_computer_the_control_data_6600.1970.102630394.pdf).
- Hennessy & Patterson, [*Computer Architecture: A Quantitative Approach*](https://shop.elsevier.com/books/computer-architecture/hennessy/978-0-443-15406-5), Appendix C — has the canonical scoreboarding example.
- Watson memo (1963): widely reprinted, e.g., in Bell, Mudge & McNamara, [*Computer Engineering: A DEC View of Hardware Systems Design*](https://archive.org/details/computerengineer00bell).
- Murray, Charles J. (1997). [*The Supermen: The Story of Seymour Cray and the Technical Wizards Behind the Supercomputer*](https://archive.org/details/supermenstory00murr). The standard popular biography.
