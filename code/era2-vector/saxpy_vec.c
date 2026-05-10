#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void saxpy(long n, double a, const double *restrict x, double *restrict y) {
    for (long i = 0; i < n; i++) y[i] = a * x[i] + y[i];
}

int main(void) {
    const long N = 1L << 24;
    double *x = aligned_alloc(64, N * sizeof(double));
    double *y = aligned_alloc(64, N * sizeof(double));
    for (long i = 0; i < N; i++) { x[i] = 1.0; y[i] = 2.0; }

    struct timespec t0, t1;
    clock_gettime(CLOCK_MONOTONIC, &t0);
    saxpy(N, 3.0, x, y);
    clock_gettime(CLOCK_MONOTONIC, &t1);
    double ms = (t1.tv_sec - t0.tv_sec) * 1e3 + (t1.tv_nsec - t0.tv_nsec) / 1e6;

    double sum = 0;
    for (long i = 0; i < N; i++) sum += y[i];
    printf("N=%ld, time=%.2f ms, sum=%g\n", N, ms, sum);

    free(x); free(y);
    return 0;
}
