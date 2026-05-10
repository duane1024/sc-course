#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>

int main(void) {
    const long N = 1L << 24;
    double *x = aligned_alloc(64, N * sizeof(double));
    double *y = aligned_alloc(64, N * sizeof(double));

    #pragma omp parallel for simd
    for (long i = 0; i < N; i++) { x[i] = 1.0; y[i] = 2.0; }

    double a = 3.0;
    double t0 = omp_get_wtime();
    #pragma omp parallel for simd
    for (long i = 0; i < N; i++) y[i] = a * x[i] + y[i];
    double t1 = omp_get_wtime();

    double sum = 0;
    #pragma omp parallel for simd reduction(+:sum)
    for (long i = 0; i < N; i++) sum += y[i];

    printf("threads=%d, N=%ld, time=%.2f ms, sum=%g\n",
           omp_get_max_threads(), N, (t1-t0)*1e3, sum);

    free(x); free(y);
    return 0;
}
