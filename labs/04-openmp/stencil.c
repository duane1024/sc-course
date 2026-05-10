#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <omp.h>

int main(int argc, char **argv) {
    int N = (argc > 1) ? atoi(argv[1]) : 1024;
    int T = (argc > 2) ? atoi(argv[2]) : 100;

    double *u  = aligned_alloc(64, N*N*sizeof(double));
    double *un = aligned_alloc(64, N*N*sizeof(double));

    #pragma omp parallel for collapse(2)
    for (int j = 0; j < N; j++)
        for (int i = 0; i < N; i++)
            u[j*N + i] = (i==N/2 && j==N/2) ? 1.0 : 0.0;

    double t0 = omp_get_wtime();
    for (int t = 0; t < T; t++) {
        #pragma omp parallel for collapse(2)
        for (int j = 1; j < N-1; j++) {
            #pragma omp simd
            for (int i = 1; i < N-1; i++) {
                un[j*N + i] = 0.25 * (u[(j-1)*N + i] + u[(j+1)*N + i] +
                                       u[j*N + i-1]   + u[j*N + i+1]);
            }
        }
        double *tmp = u; u = un; un = tmp;
    }
    double t1 = omp_get_wtime();

    double sum = 0;
    #pragma omp parallel for reduction(+:sum)
    for (int k = 0; k < N*N; k++) sum += u[k];

    printf("N=%d, T=%d, threads=%d, time=%.3f s, sum=%g\n",
           N, T, omp_get_max_threads(), t1-t0, sum);

    free(u); free(un);
    return 0;
}
