# AVX-512 listing for SAXPY (8 doubles per register), strip-mined.
# Compiler: clang -O3 -march=skylake-avx512 -S saxpy_vec.c
# Edited slightly for readability (kept inner loop, dropped prologue/epilogue).
#
# On entry:
#   %rdi = N
#   %xmm0 (= zmm0 lower) holds 'a'
#   %rsi = base address of x
#   %rdx = base address of y
#   The compiler unrolls 4× -- each iteration does 32 elements.

.LOOP:
    vbroadcastsd  %xmm0, %zmm1                  # broadcast 'a' to all 8 lanes
    vmovupd       (%rsi,%rcx,8),  %zmm2         # load x[i..i+7]
    vmovupd       64(%rsi,%rcx,8), %zmm3        # load x[i+8..i+15]
    vmovupd       128(%rsi,%rcx,8), %zmm4       # load x[i+16..i+23]
    vmovupd       192(%rsi,%rcx,8), %zmm5       # load x[i+24..i+31]

    vfmadd213pd   (%rdx,%rcx,8),   %zmm1, %zmm2 # zmm2 := a*x + y[i..i+7]
    vfmadd213pd   64(%rdx,%rcx,8), %zmm1, %zmm3 # zmm3 := a*x + y[i+8..]
    vfmadd213pd   128(%rdx,%rcx,8),%zmm1, %zmm4
    vfmadd213pd   192(%rdx,%rcx,8),%zmm1, %zmm5

    vmovupd       %zmm2, (%rdx,%rcx,8)          # store y[i..]
    vmovupd       %zmm3, 64(%rdx,%rcx,8)
    vmovupd       %zmm4, 128(%rdx,%rcx,8)
    vmovupd       %zmm5, 192(%rdx,%rcx,8)

    addq          $32, %rcx                     # advance index by 32
    cmpq          %rdi, %rcx
    jb            .LOOP

# Epilogue handles N mod 32 with masked instructions or scalar fallback.
