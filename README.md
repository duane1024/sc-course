# From Cray-1 to Frontier

**A working engineer's history of supercomputer architecture, in 15 weeks plus a capstone.**

This is a free, self-paced course for software engineers who want to understand:

- What the word "supercomputer" actually meant in 1976, and what it means now.
- Why every architectural era won, and why each one was eventually displaced.
- How the code people wrote evolved, era by era — from CAL on a Cray-1, to vector Fortran, to Connection Machine `C*`, to MPI, to CUDA, to today's `std::execution::par_unseq`.
- Why vector processing — the thing Seymour Cray bet his career on in the 1970s — is now mainstream on every laptop, phone, and GPU, but for reasons Cray would not entirely recognize.

The course is structured as a Jupyter Book. Every chapter has a runnable lab that works on a normal laptop (Linux, macOS, or WSL). Where historical hardware is gone, we use modern stand-ins (NumPy for vector machines, MPICH for MPP, CUDA-on-Colab if you don't have an NVIDIA GPU).

## Who this is for

Working software engineers and curious systems people. We assume you can read C and basic Fortran, know what a cache is, and have written multi-threaded code. We do **not** assume formal computer architecture coursework — concepts are introduced as we hit them.

## Building the book locally

```bash
pip install -r requirements.txt
jupyter-book build .
open _build/html/index.html
```

## Repository layout

```
.
├── intro.md              Course intro
├── weeks/                15 chapters + capstone, one per week
├── labs/                 Runnable labs (one per chapter that has hands-on work)
├── code/                 The "evolution of SAXPY" gallery, one folder per era
├── references.md         Annotated primary-source reading list
├── assessment.md         Self-assessment rubric and project portfolio
├── appendix-hpc-vs-ai-cluster.md   Appendix: modern supercomputer vs. frontier-LLM training cluster
├── _config.yml           Jupyter Book config
└── _toc.yml              Table of contents
```

## Repository

[github.com/duane1024/sc-course](https://github.com/duane1024/sc-course)

## Acknowledgments

Created by [Duane Moore](https://fun-in-space.com/), with substantial drafting and editorial assistance from Anthropic's Claude and OpenAI's ChatGPT. The argument, factual review, and structural decisions are mine; the AI tools contributed prose drafting, citation aggregation, and consistency checking. Errors that remain are mine.

## License

CC BY 4.0 for prose, MIT for code. Fork it, remix it, teach it.
