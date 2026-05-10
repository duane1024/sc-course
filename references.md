# References

Annotated reading list, organized roughly by chapter. Items marked **★** are primary sources I'd consider essential for anyone wanting to go deeper.

## General history

- ★ Murray, Charles J. (1997). *The Supermen: The Story of Seymour Cray and the Technical Wizards Behind the Supercomputer*. Wiley. The standard popular history. Especially good on Cray Research, ETA Systems, and the cultural texture of the era.
- August, David (ed.) (2010, ongoing). *Recollections of the History of HPC*. IEEE Computer Society's oral-history project. Many of these are public on the IEEE TCHPC site.
- *Top500 list*, top500.org. The list and its archive (Nov 1993 onward) is the single best primary source on which architectures shipped in volume and when. Do read it as a chronological sequence.
- *HPCwire* archive (hpcwire.com), 1986–present. Trade-press coverage with technical depth.
- *IEEE Annals of the History of Computing*. Multiple supercomputer-focused issues over the years, all peer-reviewed.

## Week 1 — CDC 6600 and pre-history

- ★ Thornton, J.E. (1970). *Design of a Computer: The Control Data 6600*. Scott Foresman. The primary source. Available as PDF on bitsavers.org.
- Hennessy, J.L. & Patterson, D.A. *Computer Architecture: A Quantitative Approach* (any modern edition). Appendix C has the canonical scoreboarding example.
- Bell, C.G., Mudge, J.C., & McNamara, J.E. (1978). *Computer Engineering: A DEC View of Hardware Systems Design*. Includes the Watson memo and contemporary IBM-vs-CDC analysis.

## Week 2 — Cray-1

- ★ Russell, Richard M. (1978). "The CRAY-1 Computer System". *Communications of the ACM* 21(1):63–72. The canonical primary source.
- *Cray-1 Computer System Hardware Reference Manual*, Cray Research publication 2240004. On bitsavers.org.
- Hennessy & Patterson, Appendix G. Vector processors, Cray-1 worked example.

## Week 3 — Vector Fortran and vectorization

- ★ Allen, J.R. & Kennedy, K. (1987). "Automatic translation of FORTRAN programs to vector form". *ACM TOPLAS* 9(4):491–542.
- Padua, D.A. & Wolfe, M.J. (1986). "Advanced compiler optimizations for supercomputers". *CACM* 29(12):1184–1201.
- ★ Wolfe, M. (1996). *High Performance Compilers for Parallel Computing*. Addison-Wesley. The textbook.
- *CFT Reference Manual*, Cray Research publication SR-0009. On bitsavers.org.
- Maleki, Saeed et al. (2011). "An evaluation of vectorizing compilers". *PACT '11*. Empirical comparison of GCC, ICC, IBM XL on a 151-loop benchmark.

## Week 4 — X-MP, Cray-2, Y-MP

- ★ Chen, S.S. (1984). "Large-scale and high-speed multiprocessor system for scientific applications: Cray X-MP series". In Hwang (ed.), *Supercomputers: Design and Applications*.
- Cray Research (1989). *Multitasking Programmer's Manual*, publication SR-0222.
- Bailey, D.H. et al. (1991). "The NAS Parallel Benchmarks". *Int'l J. Supercomputing Applications* 5(3):63–73.

## Week 5 — Japanese vector machines

- Watanabe, T. (1987). "Architecture and performance of the NEC SX-2". *IEEE Computer* 20(4):3–13.
- Miura, K. & Uchida, K. (1983). "Fujitsu VP-100/200: Vector machines for scientific computation". *Proc. Supercomputing '83*.
- Habata, S., Yokokawa, M. & Kitawaki, S. (2003). "The Earth Simulator system". *NEC Research & Development* 44(1):3–8.
- Reed, D. & Dongarra, J. (2015). "Exascale computing and big data". *CACM* 58(7):56–68.

## Week 6 — Vector wall, ETA-10, Cray-3

- ★ Brooks, E. (1989). "Attack of the killer micros". Lawrence Livermore National Laboratory. Widely circulated; reprinted in *HPCwire* 2009 retrospective.
- Schneck, P. (1987). *Supercomputer Architecture*. Kluwer. Contemporary analysis of Cyber 205, Cray X-MP, ETA-10.
- Wadsworth, A. (1996). "Cray Computer Corporation Chronology". Personal record of CCC engineer.
- Markoff, J. (1996). "Seymour Cray, computer industry pioneer and father of supercomputer, dies at 71". *NYT*, October 6.

## Week 7 — Connection Machine

- ★ Hillis, W.D. (1985). *The Connection Machine*. MIT Press. Available as PDF from Hillis's website.
- Hillis, W.D. & Steele, G.L. (1986). "Data parallel algorithms". *CACM* 29(12):1170–1183.
- Steele, G.L. & Hillis, W.D. (1986). "Connection Machine Lisp". *Proc. LFP '86*.
- Thinking Machines Corp. (1991). *Programming the Connection Machine in C\* and CM-Fortran*. Manuals on archive.org.

## Week 8 — MIMD MPP

- Pierce, P. (1988). "The NX/2 Operating System". *Proc. Hypercube Concurrent Computers and Applications Conf.*.
- Cray Research (1995). *Cray T3E Programming Environment*, publication SR-2017. Defines SHMEM.
- Mattson, T.G. (1995). *Programming with the Intel Paragon*.
- Geist, A. et al. (1994). *PVM: Parallel Virtual Machine*. MIT Press.
- Reed, D. (2003). "ASCI Red: A history". *HPCwire*.

## Week 9 — MPI

- ★ Gropp, W., Lusk, E. & Skjellum, A. (2014). *Using MPI: Portable Parallel Programming with the Message-Passing Interface*, 3rd ed. The textbook.
- *MPI Standard*, current version on mpi-forum.org. Free PDF.
- Snir, M. et al. (1996). *MPI: The Complete Reference*.
- MPI Forum minutes (1992–94), public on mpi-forum.org. The standardization process is itself worth studying.

## Week 10 — Beowulf

- ★ Sterling, T. & Becker, D. (1995). *How to Build a Beowulf*. Goddard Space Flight Center. archive.org.
- Sterling, T. et al. (1995). "BEOWULF: A parallel workstation for scientific computation". *Proc. ICPP '95*.
- Yoo, A. et al. (2003). "SLURM: Simple Linux Utility for Resource Management". *JSSPP '03*.
- Schwan, P. (2003). "Lustre: Building a file system for 1000-node clusters". *Linux Symposium*.

## Week 11 — ASCI / BlueGene

- ★ Adiga, N.R. et al. (2002). "An overview of the BlueGene/L supercomputer". *Proc. SC02*.
- Bhatele, A. et al. (2013). "Identifying the culprits behind network congestion". *Proc. SC13*.
- Foster, I. et al. (2005). "ASCI Red: The first TFLOPS computer at Sandia". *IEEE Computer* 38(8):54–62.
- DOE Exascale Computing Project, final report (2023). exascaleproject.org/final-report.

## Week 12 — Earth Simulator

- ★ Habata, S. et al. (2003). "The Earth Simulator system". *NEC Research & Development* 44(1):3–8.
- Yokokawa, M. et al. (2002). "Performance evaluation of the Earth Simulator". *Proc. SC02*.
- Dongarra, J. (2002). "The Earth Simulator system: A wake-up call". Widely circulated commentary.
- Lazowska, E. & Patterson, D. (2005). "Computing research: A looming crisis". *CACM* 48(3):27–30.

## Week 13 — CUDA / SIMT

- ★ Lindholm, E. et al. (2008). "NVIDIA Tesla: A unified graphics and computing architecture". *IEEE Micro* 28(2):39–55.
- Nickolls, J. & Dally, W. (2010). "The GPU computing era". *IEEE Micro* 30(2):56–69.
- Owens, J.D. et al. (2007). "A survey of general-purpose computation on graphics hardware". *Computer Graphics Forum* 26(1):80–113.
- ★ NVIDIA, *CUDA Programming Guide*, current. docs.nvidia.com/cuda/.
- Volkov, V. (2010). "Better performance at lower occupancy". *GTC '10*.

## Week 14 — Exascale

- Atchley, S. et al. (2023). "Frontier: Exploring exascale". *Proc. SC23*.
- Sato, M. et al. (2020). "Co-design for A64FX manycore processor and Fugaku". *Proc. SC20*.
- Garcia, K. et al. (2022). "El Capitan: An advanced architecture exascale system at LLNL". *Proc. SC22*.
- ECP Software Technology Capability Assessment Reports (multi-year). exascaleproject.org.

## Week 15 — Anatomy

- ORNL OLCF documentation (olcf.ornl.gov/frontier).
- Argonne ALCF documentation (alcf.anl.gov/aurora).
- LLNL Livermore Computing documentation (hpc.llnl.gov).
- HPE (2021). *Slingshot Architecture White Paper*.
- *HPC User Reports* from NERSC (nersc.gov), updated annually. Real-world operational experience.

## Capstone

- Reinders, J. et al. (2024). *Data Parallel C++: Mastering DPC++ for Programming of Heterogeneous Systems Using C++ and SYCL*. Apress (free PDF).
- Trott, C.R. et al. (2022). "Kokkos 3: Programming model extensions for the exascale era". *IEEE TPDS* 33(4):805–817.
- Reed, D., Gannon, D. & Dongarra, J. (2022). "Reinventing high performance computing: Challenges and opportunities". arXiv:2203.02544.

## Modern long-form essays (free online, recommended)

- Patterson, D. (2012). "The trouble with multicore". *IEEE Spectrum*. The post-Dennard dynamics, lay reader.
- Hennessy, J.L. & Patterson, D.A. (2019). "A new golden age for computer architecture". *CACM* 62(2):48–60. Their Turing lecture.
- Kim, S. (2019). "Computational Fluid Dynamics on Modern HPC Systems". DOE INCITE introduction. Good plain-language picture of why bandwidth and topology matter for real workloads.
