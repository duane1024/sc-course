# References

Annotated reading list, organized roughly by chapter. Items marked **★** are primary sources I'd consider essential for anyone wanting to go deeper.

## General history

- ★ Murray, Charles J. (1997). *The Supermen: The Story of Seymour Cray and the Technical Wizards Behind the Supercomputer*. Wiley. The standard popular history. Especially good on Cray Research, ETA Systems, and the cultural texture of the era.
- August, David (ed.) (2010, ongoing). *Recollections of the History of HPC*. IEEE Computer Society's oral-history project. Many of these are public on the IEEE TCHPC site.
- *Top500 list*, top500.org. The list and its archive (June 1993 onward) is the single best primary source on which architectures shipped in volume and when. Do read it as a chronological sequence.
- *HPCG benchmark list*, top500.org/lists/hpcg. Use alongside Top500 when comparing memory-bound and sparse-solver behavior.
- *HPCwire* archive (hpcwire.com), 1986–present. Trade-press coverage with technical depth.
- *IEEE Annals of the History of Computing*. Multiple supercomputer-focused issues over the years, all peer-reviewed.
- ★ Dongarra, J. (continuous, 1979–present). *Performance of Various Computers Using Standard Linear Equations Software*. Technical report, University of Tennessee / Oak Ridge / Argonne. Updated quarterly. PDF: netlib.org/benchmark/performance.ps. The canonical record of per-CPU and per-system LINPACK results over four decades; the primary source for cross-vendor performance comparisons from 1979 through the rise of Top500.

## Week 1 — CDC 6600 and pre-history

- ★ Thornton, J.E. (1970). *Design of a Computer: The Control Data 6600*. Scott Foresman. The primary source. Available as PDF on bitsavers.org.
- Hennessy, J.L. & Patterson, D.A. *Computer Architecture: A Quantitative Approach* (any modern edition). Appendix C has the canonical scoreboarding example.
- Bell, C.G., Mudge, J.C., & McNamara, J.E. (1978). *Computer Engineering: A DEC View of Hardware Systems Design*. Includes the Watson memo and contemporary IBM-vs-CDC analysis.

## Week 2 — Cray-1

- ★ Russell, Richard M. (1978). "The CRAY-1 Computer System". *Communications of the ACM* 21(1):63–72. The canonical primary source.
- *Cray-1 Computer System Hardware Reference Manual*, Cray Research publication 2240004. On bitsavers.org.
- *Cray-1 Computer System Hardware Reference Manual*, online HTML mirror by Ed Thelen. Useful for instruction timing tables and register details.
- Hennessy & Patterson, Appendix G. Vector processors, Cray-1 worked example.

## Week 3 — Vector Fortran and vectorization

- ★ Allen, J.R. & Kennedy, K. (1987). "Automatic translation of FORTRAN programs to vector form". *ACM TOPLAS* 9(4):491–542.
- Padua, D.A. & Wolfe, M.J. (1986). "Advanced compiler optimizations for supercomputers". *CACM* 29(12):1184–1201.
- ★ Wolfe, M. (1996). *High Performance Compilers for Parallel Computing*. Addison-Wesley. The textbook.
- *CFT Reference Manual*, Cray Research publication SR-0009. On bitsavers.org.
- HPE/Cray Fortran `IVDEP` directive documentation. Useful for tracing the Cray-style directive vocabulary forward into the modern HPE compiler.
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
- Top500 June 1993 and November 1993 lists. Use these to check early Top500 #1 claims; the first Japanese #1 was Fujitsu's Numerical Wind Tunnel in November 1993.
- Top500 June 2002 list. Primary source for the Earth Simulator's 35.86 TFLOPS Rmax and ASCI White comparison.

## Week 6 — Vector wall, ETA-10, Cray-3

- ★ Brooks, E. (1989). "Attack of the killer micros". Lawrence Livermore National Laboratory. Widely circulated; reprinted in *HPCwire* 2009 retrospective.
- Schneck, P. (1987). *Supercomputer Architecture*. Kluwer. Contemporary analysis of Cyber 205, Cray X-MP, ETA-10.
- Wadsworth, A. (1996). "Cray Computer Corporation Chronology". Personal record of CCC engineer.
- Markoff, J. (1996). "Seymour Cray, computer industry pioneer and father of supercomputer, dies at 71". *NYT*, October 6.

## Week 7 — Connection Machine

- ★ Hillis, W.D. (1985). *The Connection Machine*. MIT Press. Available as PDF from Hillis's website.
- Hillis, W.D. & Steele, G.L. (1986). "Data parallel algorithms". *CACM* 29(12):1170–1183.
- Steele, G.L. & Hillis, W.D. (1986). "Connection Machine Lisp". *Proc. LFP '86*.
- Thinking Machines Corp. (1987). *Connection Machine Model CM-2 Technical Summary*. Primary source for CM-2 memory and FPU organization.
- Thinking Machines Corp. (1991). *Programming the Connection Machine in C\* and CM-Fortran*. Manuals on archive.org.
- High Performance Fortran Forum (1993, 1997). *High Performance Fortran Language Specification*, versions 1.0 and 2.0. crpc.rice.edu/HPFF/. The standard.
- Kennedy, K., Koelbel, C. & Zima, H. (2007). "The rise and fall of High Performance Fortran: An historical object lesson". *Proc. HOPL III*. The retrospective by three principals in the HPF Forum; required reading on why HPF failed.
- Chamberlain, B.L., Callahan, D. & Zima, H.P. (2007). "Parallel programmability and the Chapel language". *Int'l J. HPC Applications* 21(3):291–312. The Chapel paper; Chapel is the most direct surviving HPF descendant.

## Week 8 — MIMD MPP

- Pierce, P. (1988). "The NX/2 Operating System". *Proc. Hypercube Concurrent Computers and Applications Conf.*.
- Cray Research (1995). *Cray T3E Programming Environment*, publication SR-2017. Defines SHMEM.
- Cray Research (1993). *Cray T3D System Architecture Overview*. Vendor architecture documentation; available via bitsavers.org and Cray user-group archives.
- Scott, S.L. & Thorson, G.M. (1996). "The Cray T3E network: Adaptive routing in a high-performance 3D torus". *Hot Interconnects IV*. T3E interconnect design and routing.
- Mattson, T.G. (1995). *Programming with the Intel Paragon*.
- Intel SSD (1992). *Paragon XP/S Product Overview*. Vendor specification for the mesh interconnect and node layout.
- Mattson, T.G. & Henderson, G. (1997). "ASCI Red: Experiences and lessons learned with a massively parallel teraFLOP supercomputer". *Proc. SC97*. The first sustained-TFLOPS retrospective.
- Agerwala, T., Martin, J.L., Mirza, J.H., Sadler, D.C., Dias, D.M. & Snir, M. (1995). "SP2 System Architecture". *IBM Systems Journal* 34(2):152–184. The canonical SP2 hardware reference.
- Geist, A. et al. (1994). *PVM: Parallel Virtual Machine*. MIT Press.
- Reed, D. (2003). "ASCI Red: A history". *HPCwire*.

## Week 9 — MPI

- ★ Gropp, W., Lusk, E. & Skjellum, A. (2014). *Using MPI: Portable Parallel Programming with the Message-Passing Interface*, 3rd ed. The textbook.
- *MPI Standard*, current version on mpi-forum.org. Free PDF.
- MPI Forum, *MPI 5.0 Standard* (2025), mpi-forum.org/docs/.
- Snir, M. et al. (1996). *MPI: The Complete Reference*.
- MPI Forum minutes (1992–94), public on mpi-forum.org. The standardization process is itself worth studying.

## Week 10 — Beowulf

- ★ Sterling, T. & Becker, D. (1995). *How to Build a Beowulf*. Goddard Space Flight Center. archive.org.
- Sterling, T. et al. (1995). "BEOWULF: A parallel workstation for scientific computation". *Proc. ICPP '95*.
- Yoo, A. et al. (2003). "SLURM: Simple Linux Utility for Resource Management". *JSSPP '03*.
- Schwan, P. (2003). "Lustre: Building a file system for 1000-node clusters". *Linux Symposium*.
- Boden, N.J., Cohen, D., Felderman, R.E., Kulawik, A.E., Seitz, C.L., Seizovic, J.N. & Su, W. (1995). "Myrinet: A gigabit-per-second local area network". *IEEE Micro* 15(1):29–36. The original Myrinet design.
- Petrini, F., Feng, W., Hoisie, A., Coll, S. & Frachtenberg, E. (2002). "The Quadrics network: high-performance clustering technology". *IEEE Micro* 22(1):46–57. QsNet architecture and performance.
- InfiniBand Trade Association. *InfiniBand Architecture Specification*. ibta.org. The standards body governing HDR, NDR, and XDR rates.
- NVIDIA Networking, current InfiniBand adapter and switch product documentation. Use for HDR/NDR/XDR line-rate claims.

## Week 11 — ASCI / BlueGene

- ★ Adiga, N.R. et al. (2002). "An overview of the BlueGene/L supercomputer". *Proc. SC02*.
- LLNL, "BlueGene/L" historic machine page. Useful for installed node/processor counts and delivered system context.
- IBM Research, "Overview of the BlueGene/L system architecture". Primary architecture overview.
- Barker, K.J., Davis, K., Hoisie, A., Kerbyson, D.J., Lang, M., Pakin, S. & Sancho, J.C. (2008). "Entering the petaflop era: The architecture and performance of Roadrunner". *Proc. SC08*. The Roadrunner Cell + Opteron design paper; primary source for the first sustained-petaflop system.
- Haring, R.A. et al. (2012). "The IBM Blue Gene/Q compute chip". *IEEE Micro* 32(2):48–60. BG/Q architecture, including the A2 core and hardware transactional memory.
- LLNL Computing, ASCI Blue Pacific, Blue Mountain, White, Q, Purple historic machine pages (hpc.llnl.gov / lanl.gov ASCI archives). System summaries with installed configurations.
- Bhatele, A. et al. (2013). "Identifying the culprits behind network congestion". *Proc. SC13*.
- Foster, I. et al. (2005). "ASCI Red: The first TFLOPS computer at Sandia". *IEEE Computer* 38(8):54–62.
- DOE Exascale Computing Project, final report (2023). exascaleproject.org/final-report.

## Week 12 — Earth Simulator

- ★ Habata, S. et al. (2003). "The Earth Simulator system". *NEC Research & Development* 44(1):3–8.
- Yokokawa, M. et al. (2002). "Performance evaluation of the Earth Simulator". *Proc. SC02*.
- Dongarra, J. (2002). "The Earth Simulator system: A wake-up call". Widely circulated commentary.
- Lazowska, E. & Patterson, D. (2005). "Computing research: A looming crisis". *CACM* 48(3):27–30.
- DARPA, *High Productivity Computing Systems* program materials and final reports. Use for HPCS phase/vendor claims.

## Week 13 — CUDA / SIMT

- ★ Lindholm, E. et al. (2008). "NVIDIA Tesla: A unified graphics and computing architecture". *IEEE Micro* 28(2):39–55.
- Nickolls, J. & Dally, W. (2010). "The GPU computing era". *IEEE Micro* 30(2):56–69.
- Owens, J.D. et al. (2007). "A survey of general-purpose computation on graphics hardware". *Computer Graphics Forum* 26(1):80–113.
- ★ NVIDIA, *CUDA Programming Guide*, current. docs.nvidia.com/cuda/.
- NVIDIA H100 and Blackwell product briefs. Use for FP64, HBM capacity, and current GPU spec claims.
- Yang, X. et al. (2011). "MilkyWay-2 (and TianHe-1A) supercomputer: A technical perspective". Documents the design and Top500 #1 history of NUDT's GPU-accelerated systems.
- Vazhkudai, S.S. et al. (2018). "The design, deployment, and evaluation of the CORAL pre-exascale systems". *Proc. SC18*. The Summit (ORNL) and Sierra (LLNL) architecture paper.
- Volkov, V. (2010). "Better performance at lower occupancy". *GTC '10*.
- ★ Pharr, M. & Mark, W.R. (2012). "ISPC: A SPMD compiler for high-performance CPU programming". *InPar '12*. llvm.org/pubs/2012-05-13-InPar-ispc.html. The argument for SPMD-on-SIMD as the right model for CPU vectorization. Required reading for the Week 13 sidebar.
- ISPC documentation, ispc.github.io. The compiler is open source (BSD).
- OpenACC standard, openacc.org. Current version (3.4) covers directive-based accelerator offload. The historically important alternative to OpenMP target offload.

## Week 14 — Exascale

- Atchley, S. et al. (2023). "Frontier: Exploring exascale". *Proc. SC23*.
- Sato, M. et al. (2020). "Co-design for A64FX manycore processor and Fugaku". *Proc. SC20*.
- ★ Stephens, N., Biles, S., Boettcher, M., Eapen, J., Eyole, M. et al. (2017). "The ARM Scalable Vector Extension". *IEEE Micro* 37(2):26–39. The canonical SVE design paper; introduces vector-length-agnostic programming.
- ARM, *SVE and SVE2 Programmer's Guide*, developer.arm.com. Practical reference for the intrinsics.
- Garcia, K. et al. (2022). "El Capitan: An advanced architecture exascale system at LLNL". *Proc. SC22*.
- RIKEN R-CCS, "About Fugaku". Current public system specifications.
- LLNL Livermore Computing, *El Capitan* platform documentation (hpc.llnl.gov/hardware/compute-platforms/el-capitan). Primary public source for the as-deployed node count and on-site configuration.
- Forschungszentrum Jülich, *JUPITER* platform documentation (fz-juelich.de/jupiter). Primary public source for the EuroHPC JU exascale system: Booster (NVIDIA GH200) and Cluster (SiPearl Rhea1) module configurations.
- EuroHPC Joint Undertaking, *EuroHPC supercomputer announcements* (eurohpc-ju.europa.eu). Procurement and policy framing for JUPITER, LUMI, Leonardo, MareNostrum 5.
- Dongarra, J. & Luszczek, P. (2024–). *HPL-MxP Mixed-Precision Benchmark*. icl.utk.edu/hpl-mxp/. The mixed-precision LINPACK companion benchmark; rationale and current rankings.
- *Top500 HPL-MxP list*, top500.org. The mixed-precision ranking that, alongside HPCG, bounds the achievable performance of leadership-class machines.
- Mudigere, D. et al. (2022). "Software-hardware co-design for fast and scalable training of deep learning recommendation models". *Proc. MLSys '22*. Representative of how hyperscaler AI clusters are documented in the literature, useful for framing the "is this a supercomputer?" question.
- Cerebras Systems (2024). *CS-3 architecture white paper*. cerebras.ai. Wafer-scale-engine architecture reference for the "alternative supercomputers" discussion.
- Top500 and HPCG current lists, plus the Top500 archive (top500.org/lists). Use dated list entries for Frontier, Aurora, El Capitan, and Fugaku rankings; these values change twice per year and the archive preserves every June/November list since 1993.
- ECP Software Technology Capability Assessment Reports (multi-year). exascaleproject.org.

## Week 15 — Anatomy

- ORNL OLCF documentation (olcf.ornl.gov/frontier).
- ORNL OLCF, *Frontier User Guide*. Primary public source for node count, memory per node, and storage details.
- Argonne ALCF documentation (alcf.anl.gov/aurora).
- Argonne ALCF, Aurora user documentation. Primary public source for PBS/DAOS/Aurora operational details.
- LLNL Livermore Computing documentation (hpc.llnl.gov).
- HPE (2021). *Slingshot Architecture White Paper*.
- *HPC User Reports* from NERSC (nersc.gov), updated annually. Real-world operational experience.
- ★ Williams, S., Waterman, A. & Patterson, D. (2009). "Roofline: An insightful visual performance model for multicore architectures". *CACM* 52(4):65–76. The canonical Roofline paper. The single best one-page tool for reasoning about kernel performance across architectures.
- ★ McCalpin, J.D. (1995, ongoing). *STREAM: Sustainable Memory Bandwidth in High Performance Computers*. University of Virginia. cs.virginia.edu/stream. The canonical memory-bandwidth microbenchmark.
- HPCG benchmark project, hpcg-benchmark.org. The complement to HPL for memory- and communication-bound applications.

## Capstone

- Reinders, J. et al. (2024). *Data Parallel C++: Mastering DPC++ for Programming of Heterogeneous Systems Using C++ and SYCL*. Apress (free PDF).
- Trott, C.R. et al. (2022). "Kokkos 3: Programming model extensions for the exascale era". *IEEE TPDS* 33(4):805–817.
- Reed, D., Gannon, D. & Dongarra, J. (2022). "Reinventing high performance computing: Challenges and opportunities". arXiv:2203.02544.

### Datasets and mini-apps for projects

- Bailey, D.H. et al. (1991, ongoing). *NAS Parallel Benchmarks*. nas.nasa.gov/publications/npb.html. The canonical benchmark suite for CFD-adjacent parallel work; eight kernels and pseudo-applications across multiple problem-size classes.
- Norman, M. *miniWeather*. github.com/mrnorman/miniWeather. A miniature climate-modeling proxy app explicitly designed for HPC training, with reference implementations in MPI, OpenMP, OpenACC, CUDA, SYCL, and Kokkos. The single best capstone mini-app.
- LLNL. *LULESH*: Livermore Unstructured Lagrangian Explicit Shock Hydrodynamics. github.com/LLNL/LULESH. A widely cited proxy application for shock-physics workloads; used in many HPC performance papers.
- Davis, T. & Hu, Y. (2011). "The University of Florida sparse matrix collection". *ACM TOMS* 38(1):1–25. The SuiteSparse Matrix Collection at sparse.tamu.edu — primary source of real-world sparse matrices for SpMV benchmarking.
- Matrix Market, math.nist.gov/MatrixMarket. Older companion sparse-matrix archive, still useful.

## Modern long-form essays (free online, recommended)

- Patterson, D. (2012). "The trouble with multicore". *IEEE Spectrum*. The post-Dennard dynamics, lay reader.
- Hennessy, J.L. & Patterson, D.A. (2019). "A new golden age for computer architecture". *CACM* 62(2):48–60. Their Turing lecture.
- Kim, S. (2019). "Computational Fluid Dynamics on Modern HPC Systems". DOE INCITE introduction. Good plain-language picture of why bandwidth and topology matter for real workloads.
