#include <stdio.h>
#include <stdlib.h>
#include <math.h>

__global__ void saxpy(long n, double a, const double *x, double *y) {
    long i = (long)blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) y[i] = a * x[i] + y[i];
}

int main(void) {
    const long N = 1L << 24;
    double *x, *y;
    cudaMallocManaged(&x, N * sizeof(double));
    cudaMallocManaged(&y, N * sizeof(double));
    for (long i = 0; i < N; i++) { x[i] = 1.0; y[i] = 2.0; }

    cudaEvent_t s, e;
    cudaEventCreate(&s); cudaEventCreate(&e);

    int block = 256;
    int grid  = (int)((N + block - 1) / block);

    cudaEventRecord(s);
    saxpy<<<grid, block>>>(N, 3.0, x, y);
    cudaEventRecord(e);
    cudaEventSynchronize(e);

    float ms = 0;
    cudaEventElapsedTime(&ms, s, e);
    double gbps = (3.0 * (double)N * sizeof(double)) / (ms * 1e6);

    double maxerr = 0;
    for (long i = 0; i < N; i++) {
        double err = fabs(y[i] - 5.0);
        if (err > maxerr) maxerr = err;
    }
    printf("N=%ld, time=%.3f ms, %.1f GB/s, maxerr=%g\n",
           N, ms, gbps, maxerr);

    cudaFree(x); cudaFree(y);
    return 0;
}
