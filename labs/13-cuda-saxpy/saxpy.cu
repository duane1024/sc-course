/*
 * CUDA SAXPY.  Minimal — 30 lines of code that would have been
 * the entire program of a 1976 Cray-1 ($8.8M for 160 MFLOPS) and now
 * runs on a $200 GPU at >2 TFLOPS.
 *
 * Build: nvcc -O3 saxpy.cu -o saxpy
 */
#include <stdio.h>
#include <stdlib.h>

__global__ void saxpy(int n, double a, const double *x, double *y) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) y[i] = a * x[i] + y[i];
}

int main(void) {
    const long N = 1L << 24;            // ~16M elements -> 256 MB total

    double *x, *y;
    cudaMallocManaged(&x, N * sizeof(double));
    cudaMallocManaged(&y, N * sizeof(double));

    for (long i = 0; i < N; i++) { x[i] = 1.0; y[i] = 2.0; }

    cudaEvent_t start, stop;
    cudaEventCreate(&start); cudaEventCreate(&stop);

    int block = 256;
    int grid  = (N + block - 1) / block;

    cudaEventRecord(start);
    saxpy<<<grid, block>>>(N, 3.0, x, y);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms = 0;
    cudaEventElapsedTime(&ms, start, stop);

    /* Bytes moved: 2 reads + 1 write per element = 24 bytes/elem. */
    double gbps = (3.0 * N * sizeof(double)) / (ms * 1e6);
    printf("N=%ld, time=%.3f ms, %.1f GB/s\n", N, ms, gbps);

    /* Verify: y should now be 3.0*1.0 + 2.0 = 5.0 everywhere */
    double maxerr = 0;
    for (long i = 0; i < N; i++) {
        double err = fabs(y[i] - 5.0);
        if (err > maxerr) maxerr = err;
    }
    printf("max error = %g\n", maxerr);

    cudaFree(x); cudaFree(y);
    return 0;
}
